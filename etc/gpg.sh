# --------------------------------

# gpg --gen-key
# gpg --list-keys
# gpg -k

alias  verify-tor='gpg --keyid-format long --verify torbrowser-install-win64-11.5.1_en-US.exe.asc torbrowser-install-win64-11.5.1_en-US.exe'
alias get-tor-key='gpg --keyid-format long --keyserver hkp://keyserver.ubuntu.com --recv-keys 0xEF6E286DDA85EA2A4BA7DE684E2C6E8793298290'

alias  verify-ubuntu='gpg --keyid-format long --verify SHA256SUMS.gpg SHA256SUMS'
alias get-ubuntu-key='gpg --keyid-format long --keyserver hkp://keyserver.ubuntu.com --recv-keys 0x46181433FBB75451 0xD94AA3F0EFE21092'


# --------------------------------
