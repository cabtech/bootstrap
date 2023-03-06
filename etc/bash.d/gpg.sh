# --------------------------------

alias yubihup="sudo systemctl restart pcscd"
alias yubisrc="source ~/src/cabtech/bootstrap/etc/yubi-gpg.inc"

alias        verify-tor="gpg --keyid-format long --verify torbrowser-install-win64-11.5.1_en-US.exe.asc torbrowser-install-win64-11.5.1_en-US.exe"
alias     verify-ubuntu="gpg --keyid-format long --verify SHA256SUMS.gpg SHA256SUMS"
alias       get-tor-key="gpg --keyid-format long --keyserver hkp://keyserver.ubuntu.com --recv-keys 0xEF6E286DDA85EA2A4BA7DE684E2C6E8793298290"
alias    get-ubuntu-key="gpg --keyid-format long --keyserver hkp://keyserver.ubuntu.com --recv-keys 0x46181433FBB75451 0xD94AA3F0EFE21092"
alias get-hashicorp-key="gpg --keyid-format long --keyserver hkp://keyserver.ubuntu.com --recv-keys 0x91A6E7F85D05C65630BEF18951852D87348FFC4C"

# gpg -k :: --list-keys
alias gpgcs="gpg --card-status"
alias  gpgd="gpg --decrypt"
#alias gpgdo="gpg --decrypt --recipient tim.short@example.com"
#alias  gpge="gpg --encrypt --recipient tim.short@example.com"
alias gpglk="gpg --list-keys"

# to trust a key
# gpg --edit-key tim.short@example.com
# > trust
# > 5
# > y
# > save

# gpg --gen-key
# gpg --armor --encrypt --output NAME.gpg --recipient tim.short@example.com < NAME.cfg
# gpgconf
# gpgconf --kill gpg-agent
# gpgconf --list-dir

# --------------------------------
