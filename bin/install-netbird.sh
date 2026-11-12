# This code is based on the netbird-installer contribution by physk on GitHub.
# Source: https://github.com/physk/netbird-installer
set -e

CONFIG_FOLDER="/etc/netbird"
CONFIG_FILE="$CONFIG_FOLDER/install.conf"

OWNER="netbirdio"
REPO="netbird"
CLI_APP="netbird"
UI_APP="netbird-ui"

# Set default variable
OS_NAME=""
OS_TYPE=""
ARCH="$(uname -m)"
PACKAGE_MANAGER="bin"
INSTALL_DIR=""
SUDO=""
# curl protocol set for --proto / --proto-redir: https and nothing else, so no
# request and no redirect in a chain can fall back to plaintext.
PROTO_HTTPS="=https"


if command -v sudo > /dev/null && [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
elif command -v doas > /dev/null && [ "$(id -u)" -ne 0 ]; then
    SUDO="doas"
fi

# Downloads are staged in a private directory instead of /tmp. Fixed names in a
# shared directory can collide with entries created there beforehand, and the
# paths staged here are consumed by the privileged install steps below.
NB_TMPDIR="$(mktemp -d "${TMPDIR:-/tmp}/netbird.XXXXXXXXXX")" || {
    echo "Unable to create a temporary directory for the downloads"
    exit 1
}
trap 'rm -rf "$NB_TMPDIR"' EXIT

# The GitHub token is handed to curl from a file (-H @file) so it never shows
# up in argv, where other local users can read it via ps or /proc/*/cmdline.
# printf is a builtin, so writing it doesn't expose it either.
GH_AUTH_FILE=""
if [ -n "$GITHUB_TOKEN" ]; then
    GH_AUTH_FILE="${NB_TMPDIR}/gh-auth-header"
    (umask 077 && printf 'Authorization: token %s\n' "$GITHUB_TOKEN" > "$GH_AUTH_FILE")
fi

if [ -z ${NETBIRD_RELEASE+x} ]; then
    NETBIRD_RELEASE=latest
fi

TAG_NAME=""

get_release() {
    local RELEASE=$1
    if [ "$RELEASE" = "latest" ]; then
        local TAG="latest"
        local URL="https://pkgs.netbird.io/releases/latest"
    else
        local TAG="tags/${RELEASE}"
        local URL="https://api.github.com/repos/${OWNER}/${REPO}/releases/${TAG}"
    fi
	OUTPUT=""
    # Only api.github.com gets the token. The "latest" lookup goes to
    # pkgs.netbird.io, which must never see it.
    if [ -n "$GH_AUTH_FILE" ] && [ "$RELEASE" != "latest" ]; then
          OUTPUT=$(curl -H "@${GH_AUTH_FILE}" -s --proto "$PROTO_HTTPS" "${URL}")
    else
          OUTPUT=$(curl -s --proto "$PROTO_HTTPS" "${URL}")
    fi
	TAG_NAME=$(echo ${OUTPUT} |  grep -Eo '\"tag_name\":\s*\"v([0-9]+\.){2}[0-9]+"' | tail -n 1)
	echo "${TAG_NAME}" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+'
}

fetch_https() {
    # $1 = url, $2 = destination. HTTPS only, and fail on HTTP errors so an
    # error page is never saved as the payload.
    curl -fL --proto "$PROTO_HTTPS" --proto-redir "$PROTO_HTTPS" -o "$2" "$1"
}

sha256_of() {
    if command -v sha256sum > /dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum > /dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        echo "Neither sha256sum nor shasum is available to verify the download" >&2
        return 1
    fi
}

verify_checksum() {
    # $1 = downloaded file, $2 = asset name, $3 = checksums file name
    SUMS_PATH="${NB_TMPDIR}/$3"
    fetch_https "${BASE_URL}/${VERSION}/$3" "$SUMS_PATH"

    EXPECTED=$(awk -v f="$2" '$2 == f || $2 == "*" f {print $1}' "$SUMS_PATH")
    if ! echo "$EXPECTED" | grep -qxE '[0-9a-fA-F]{64}'; then
        echo "No unique SHA-256 entry for $2 in $3, refusing to install it" >&2
        exit 1
    fi

    ACTUAL=$(sha256_of "$1")
    if [ "$(echo "$ACTUAL" | tr 'A-F' 'a-f')" != "$(echo "$EXPECTED" | tr 'A-F' 'a-f')" ]; then
        echo "Checksum mismatch for $2 (expected $EXPECTED, got $ACTUAL), refusing to install it" >&2
        exit 1
    fi
    echo "Checksum verified for $2"
}

download_release_binary() {
    VERSION=$(get_release "$NETBIRD_RELEASE") || {
        echo "Unable to determine the NetBird release version" >&2
        exit 1
    }
	echo "Using the following tag name for binary installation: ${VERSION}"
    BASE_URL="https://github.com/${OWNER}/${REPO}/releases/download"
    BINARY_BASE_NAME="${VERSION#v}_${OS_TYPE}_${ARCH}.tar.gz"

    # for Darwin, download the signed NetBird-UI
    if [ "$OS_TYPE" = "darwin" ] && [ "$1" = "$UI_APP" ]; then
        BINARY_BASE_NAME="${VERSION#v}_${OS_TYPE}_${ARCH}_signed.zip"
    fi

    if [ "$1" = "$UI_APP" ]; then
       BINARY_NAME="$1-${OS_TYPE}_${BINARY_BASE_NAME}"
       if [ "$OS_TYPE" = "darwin" ]; then
         BINARY_NAME="$1_${BINARY_BASE_NAME}"
       fi
    else
       BINARY_NAME="$1_${BINARY_BASE_NAME}"
    fi

    # Each asset is checked against the release's checksums file. NetBird
    # publishes no checksum for the signed macOS UI zip, so that one is refused
    # rather than installed unverified.
    if [ "$1" = "$UI_APP" ] && [ "$OS_TYPE" = "darwin" ]; then
        echo "No published checksum for ${BINARY_NAME}; refusing to install it unverified." >&2
        echo "Re-run with SKIP_UI_APP=true, or use the default .pkg install (unset USE_BIN_INSTALL)." >&2
        exit 1
    fi
    SUMS_NAME="$1_${VERSION#v}_checksums.txt"

    DOWNLOAD_URL="${BASE_URL}/${VERSION}/${BINARY_NAME}"

    echo "Installing $1 from $DOWNLOAD_URL"
    ARCHIVE_PATH="${NB_TMPDIR}/${BINARY_NAME}"
    # Public release assets need no token, so none is sent here.
    fetch_https "$DOWNLOAD_URL" "$ARCHIVE_PATH"
    verify_checksum "$ARCHIVE_PATH" "$BINARY_NAME" "$SUMS_NAME"


    if [ "$OS_TYPE" = "darwin" ] && [ "$1" = "$UI_APP" ]; then
        INSTALL_DIR="/Applications/NetBird UI.app"

        if test -d "$INSTALL_DIR" ; then
          echo "removing $INSTALL_DIR"
          rm -rfv "$INSTALL_DIR"
        fi

        # Unzip the app and move to INSTALL_DIR
        unzip -q -o "$ARCHIVE_PATH" -d "$NB_TMPDIR"
        mv -v "${NB_TMPDIR}/netbird_ui_${OS_TYPE}/" "$INSTALL_DIR/" || mv -v "${NB_TMPDIR}/netbird_ui_${OS_TYPE}_${ARCH}/" "$INSTALL_DIR/"
    else
        ${SUDO} mkdir -p "$INSTALL_DIR"
        tar -xzvf "$ARCHIVE_PATH" -C "$NB_TMPDIR"
        # install, not mv: the extracted file belongs to the invoking user, and
        # a root-run binary that user could overwrite is a privilege escalation.
        ${SUDO} install -o 0 -g 0 -m 0755 "${NB_TMPDIR}/$1" "$INSTALL_DIR/$1"
    fi
}

add_apt_repo() {
    ${SUDO} apt-get update
    ${SUDO} apt-get install ca-certificates curl gnupg -y

    # Remove old keys and repo source files
    ${SUDO} rm -f \
        /etc/apt/sources.list.d/netbird.list \
        /etc/apt/sources.list.d/wiretrustee.list \
        /etc/apt/trusted.gpg.d/wiretrustee.gpg \
        /usr/share/keyrings/netbird-archive-keyring.gpg \
        /usr/share/keyrings/wiretrustee-archive-keyring.gpg

    curl -sSL --proto "$PROTO_HTTPS" --proto-redir "$PROTO_HTTPS" https://pkgs.netbird.io/debian/public.key \
    | ${SUDO} gpg --dearmor -o /usr/share/keyrings/netbird-archive-keyring.gpg

    # Explicitly set the file permission
    ${SUDO} chmod 0644 /usr/share/keyrings/netbird-archive-keyring.gpg

    echo 'deb [signed-by=/usr/share/keyrings/netbird-archive-keyring.gpg] https://pkgs.netbird.io/debian stable main' \
    | ${SUDO} tee /etc/apt/sources.list.d/netbird.list

    ${SUDO} apt-get update
}

add_rpm_repo() {
cat <<-EOF | ${SUDO} tee /etc/yum.repos.d/netbird.repo
[NetBird]
name=NetBird
baseurl=https://pkgs.netbird.io/yum/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.netbird.io/yum/repodata/repomd.xml.key
repo_gpgcheck=1
EOF
}

prepare_tun_module() {
  # Create the necessary file structure for /dev/net/tun
  if [ ! -c /dev/net/tun ]; then
    if [ ! -d /dev/net ]; then
      mkdir -m 755 /dev/net
    fi
    mknod /dev/net/tun c 10 200
    chmod 0755 /dev/net/tun
  fi

  # Load the tun module if not already loaded
  if ! lsmod | grep -q "^tun\s"; then
    insmod /lib/modules/tun.ko
  fi
}

install_native_binaries() {
    # Checks  for supported architecture
    case "$ARCH" in
        x86_64|amd64)
            ARCH="amd64"
        ;;
        i?86|x86)
            ARCH="386"
        ;;
        aarch64|arm64)
            ARCH="arm64"
        ;;
        *)
            echo "Architecture ${ARCH} not supported"
            exit 2
        ;;
    esac

    # download and copy binaries to INSTALL_DIR
    download_release_binary "$CLI_APP"
    if [ "$SKIP_UI_APP" != true ]; then
        download_release_binary "$UI_APP"
    fi
}

# Handle macOS .pkg installer
install_pkg() {
  case "$(uname -m)" in
    x86_64) ARCH="amd64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *) echo "Unsupported macOS arch: $(uname -m)" >&2; exit 1 ;;
  esac

  PKG_URL=$(curl -sIL --proto "$PROTO_HTTPS" --proto-redir "$PROTO_HTTPS" -o /dev/null -w '%{url_effective}' "https://pkgs.netbird.io/macos/${ARCH}")
  echo "Downloading NetBird macOS installer from https://pkgs.netbird.io/macos/${ARCH}"
  curl -fsSL --proto "$PROTO_HTTPS" --proto-redir "$PROTO_HTTPS" -o "${NB_TMPDIR}/netbird.pkg" "${PKG_URL}"
  ${SUDO} installer -pkg "${NB_TMPDIR}/netbird.pkg" -target /
}

check_use_bin_variable() {
    if [ "${USE_BIN_INSTALL}-x" = "true-x" ]; then
      echo "The installation will be performed using binary files"
      return 0
    fi
    return 1
}

install_netbird() {
    if [ -x "$(command -v netbird)" ]; then
      status_output="$(netbird status 2>&1 || true)"

      if echo "$status_output" | grep -q 'failed to connect to daemon error: context deadline exceeded'; then
          echo "Warning: could not reach NetBird daemon (timeout), proceeding anyway"
      else
          if echo "$status_output" | grep -q 'Management: Connected' && \
              echo "$status_output" | grep -q 'Signal: Connected'; then
              echo "NetBird service is running, please stop it before proceeding"
              exit 1
          fi

          if [ -n "$status_output" ]; then
              echo "NetBird seems to be installed already, please remove it before proceeding"
              exit 1
          fi
      fi
    fi

    # Run the installation, if a desktop environment is not detected
    # only the CLI will be installed
    case "$PACKAGE_MANAGER" in
    apt)
        add_apt_repo
        ${SUDO} apt-get install netbird -y

        if [ "$SKIP_UI_APP" != true ]; then
            ${SUDO} apt-get install netbird-ui -y
        fi
    ;;
    yum)
        add_rpm_repo
        ${SUDO} yum -y install netbird
        if [ "$SKIP_UI_APP" != true ]; then
            ${SUDO} yum -y install netbird-ui
        fi
    ;;
    dnf)
        add_rpm_repo
        ${SUDO} dnf -y install netbird

        if [ "$SKIP_UI_APP" != true ]; then
            ${SUDO} dnf -y install netbird-ui
        fi
    ;;
    rpm-ostree)
        add_rpm_repo
        ${SUDO} rpm-ostree -y install netbird
        if [ "$SKIP_UI_APP" != true ]; then
            ${SUDO} rpm-ostree -y install netbird-ui
        fi
        # ensure the service is started after install
         ${SUDO} netbird service install || true
         ${SUDO} netbird service start || true
    ;;
    pkg)
        # Check if the package is already installed
        if [ -f /Library/Receipts/netbird.pkg ]; then
            echo "NetBird is already installed. Please remove it before proceeding."
            exit 1
        fi

        # Install the package
        install_pkg
    ;;
    brew)
        # Remove Netbird if it had been installed using Homebrew before
        if brew ls --versions netbird >/dev/null 2>&1; then
            echo "Removing existing netbird client"

            # Stop and uninstall daemon service:
            netbird service stop
            netbird service uninstall

            # Unlink the app
            brew unlink netbird
        fi

        brew install netbirdio/tap/netbird
        if [ "$SKIP_UI_APP" != true ]; then
            brew install --cask netbirdio/tap/netbird-ui
        fi
    ;;
    *)
      if [ "$OS_NAME" = "nixos" ];then
        echo "Please add NetBird to your NixOS configuration.nix directly:"
			  echo ""
			  echo "services.netbird.enable = true;"

        if [ "$SKIP_UI_APP" != true ]; then
          echo "environment.systemPackages = [ pkgs.netbird-ui ];"
        fi

        echo "Build and apply new configuration:"
        echo ""
        echo "${SUDO} nixos-rebuild switch"
			  exit 0
      fi

        install_native_binaries
    ;;
    esac

    if [ "$OS_NAME" = "synology" ]; then
        prepare_tun_module
    fi

    # Add package manager to config
    ${SUDO} mkdir -p "$CONFIG_FOLDER"
    echo "package_manager=$PACKAGE_MANAGER" | ${SUDO} tee "$CONFIG_FILE" > /dev/null

    # Load and start netbird service
    if [ "$PACKAGE_MANAGER" != "rpm-ostree" ] && [ "$PACKAGE_MANAGER" != "pkg" ]; then
        if ! ${SUDO} netbird service install 2>&1; then
            echo "NetBird service has already been loaded"
        fi
        if ! ${SUDO} netbird service start 2>&1; then
            echo "NetBird service has already been started"
        fi
    fi


    echo "Installation has been finished. To connect, you need to run NetBird by executing the following command:"
    echo ""
    echo "netbird up"
}

version_greater_equal() {
    printf '%s\n%s\n' "$2" "$1" | sort -V -c
}

is_bin_package_manager() {
  if ${SUDO} test -f "$1" && ${SUDO} grep -q "package_manager=bin" "$1" ; then
    return 0
  else
    return 1
  fi
}

stop_running_netbird_ui() {
  NB_UI_PROC=$(ps -ef | grep "[n]etbird-ui" | awk '{print $2}')
  if [ -n "$NB_UI_PROC" ]; then
    echo "NetBird UI is running with PID $NB_UI_PROC. Stopping it..."
    kill -9 "$NB_UI_PROC"
  fi
}

update_netbird() {
  if is_bin_package_manager "$CONFIG_FILE"; then
    latest_release=$(get_release "latest")
    latest_version=${latest_release#v}
    installed_version=$(netbird version)

    if [ "$latest_version" = "$installed_version" ]; then
      echo "Installed NetBird version ($installed_version) is up-to-date"
      exit 0
    fi

    if version_greater_equal "$latest_version" "$installed_version"; then
      echo "NetBird new version ($latest_version) available. Updating..."
      echo ""
      echo "Initiating NetBird update. This will stop the netbird service and restart it after the update"

      ${SUDO} netbird service stop || true
      ${SUDO} netbird service uninstall || true
      stop_running_netbird_ui
      install_native_binaries

      ${SUDO} netbird service install
      ${SUDO} netbird service start
    fi
  else
     echo "NetBird installation was done using a package manager. Please use your system's package manager to update"
  fi
}

# Checks if SKIP_UI_APP env is set
# Only the literal values true/false are accepted; the value is never executed.
case "$SKIP_UI_APP" in
    "")
      SKIP_UI_APP=false
    ;;
    true)
      echo "SKIP_UI_APP has been set to true in the environment"
      echo "NetBird UI installation will be omitted based on your preference"
    ;;
    false)
    ;;
    *)
      echo "SKIP_UI_APP must be 'true' or 'false', got '$SKIP_UI_APP'" >&2
      exit 1
    ;;
esac

# Identify OS name and default package manager
if type uname >/dev/null 2>&1; then
	case "$(uname)" in
        Linux)
          OS_TYPE="linux"
          UNAME_OUTPUT="$(uname -a)"
          if echo "$UNAME_OUTPUT" | grep -qi "synology"; then
            OS_NAME="synology"
            INSTALL_DIR="/usr/local/bin"
            PACKAGE_MANAGER="bin"
            SKIP_UI_APP=true
          else
            if [ -f /etc/os-release ]; then
              OS_NAME="$(. /etc/os-release && echo "$ID")"
              INSTALL_DIR="/usr/bin"

              # Allow netbird UI installation for x64 arch only
              if [ "$ARCH" != "amd64" ] && [ "$ARCH" != "arm64" ] \
                  && [ "$ARCH" != "x86_64" ];then
                  SKIP_UI_APP=true
                  echo "NetBird UI installation will be omitted as $ARCH is not a compatible architecture"
              fi

              # Allow netbird UI installation for linux running desktop environment
              if [ -z "$XDG_CURRENT_DESKTOP" ];then
                  SKIP_UI_APP=true
                  echo "NetBird UI installation will be omitted as Linux does not run desktop environment"
              fi

              # Check the availability of a compatible package manager
              if check_use_bin_variable; then
                  PACKAGE_MANAGER="bin"
              elif [ -e /run/ostree-booted ]; then
                  if [ -x "$(command -v rpm-ostree)" ]; then
                      PACKAGE_MANAGER="rpm-ostree"
                      echo "The installation will be performed using rpm-ostree package manager"
                  elif [ -x "$(command -v bootc)" ]; then
                      echo "Detected bootc system without rpm-ostree." >&2
                      echo "NetBird cannot be installed via package manager on this system." >&2
                      echo "Options:" >&2
                      echo "  1. Install via Distrobox (instructions in the installation docs)" >&2
                      echo "  2. Rebuild your base image with rpm-ostree included" >&2
                      echo "  3. Bake NetBird into your Containerfile" >&2
                      exit 1
                  else
                      echo "Detected ostree-booted system without rpm-ostree or bootc." >&2
                      echo "NetBird cannot be installed automatically on this atomic system." >&2
                      echo "Please install NetBird by rebuilding your base image or use a supported package manager." >&2
                      exit 1
                  fi
              elif [ -x "$(command -v apt-get)" ]; then
                  PACKAGE_MANAGER="apt"
                  echo "The installation will be performed using apt package manager"
              elif [ -x "$(command -v dnf)" ]; then
                  PACKAGE_MANAGER="dnf"
                  echo "The installation will be performed using dnf package manager"
              elif [ -x "$(command -v yum)" ]; then
                  PACKAGE_MANAGER="yum"
                  echo "The installation will be performed using yum package manager"
              fi
            else
              echo "Unable to determine OS type from /etc/os-release"
              exit 1
            fi
          fi


		;;
		Darwin)
            OS_NAME="macos"
			OS_TYPE="darwin"
            INSTALL_DIR="/usr/local/bin"

            # Check the availability of a compatible package manager
            if check_use_bin_variable; then
                PACKAGE_MANAGER="bin"
            else
              PACKAGE_MANAGER="pkg"
            fi
		;;
	esac
fi

UPDATE_FLAG=$1

if [ "${UPDATE_NETBIRD}-x" = "true-x" ]; then
  UPDATE_FLAG="--update"
fi

case "$UPDATE_FLAG" in
    --update)
      update_netbird
    ;;
    *)
      install_netbird
esac
