# --------------------------------

alias      tf='terraform'
alias tfapply='terraform apply PLAN'
alias   tffmt='terraform fmt'
alias  tfinit='terraform init'
alias  tfplan='terraform plan -out PLAN'
alias   tfval='terraform validate'

alias tfcheck='tffmt && tfval'

alias  lltf='_ls -l *.tf'
alias lltfx='_ls -l *.tf *.tfx'

if [[ -d /var/lib/terraform/plugins ]]; then
	export TF_PLUGIN_CACHE_DIR=/var/lib/terraform/plugins
fi

# --------------------------------
