# --------------------------------

alias      tf="terraform"
alias tfapply="terraform apply plan"
alias   tffmt="terraform fmt"
alias  tfinit="terraform init"
alias  tfplan="terraform plan -out plan"
alias   tfval="terraform validate"

alias tfcheck="tffmt && tfval"

alias  lltf="_ls -l *.tf"
alias lltfx="_ls -l *.tf*"

export TF_PLUGIN_CACHE_DIR=/var/lib/terraform/plugins

# --------------------------------
