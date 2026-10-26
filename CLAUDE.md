# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

The author's personal store of machine-setup scripts, shell config and project templates for Cabtech work (`cabtech/bootstrap`, branch `main`). It has no build and no tests. Most of it gets **copied out** to other places (`~/etc/bash.d`, `~/.ssh/cfg.d`, new infra-site directories), so after a file here changes, any copy that was already installed elsewhere stays stale.

There are usually two clones:
- `~/work/cabtech/bootstrap`: the SSH clone where edits are made and pushed.
- `~/src/cabtech/bootstrap`: the HTTPS clone that is actually used at runtime. `etc/bash.d/cabtech.sh` puts `~/src/cabtech/bootstrap/bin` on `PATH`, and the `~/work/cabtech/roles/{CLAUDE.md,repos.cfg}` symlinks point into it. Changes made here only take effect there after a push and a pull in `~/src`.

## Layout and how the pieces connect

- `bin/`: standalone bash scripts (installers, `setup-mac.sh`/`setup-linux.sh`, git helpers like `multi-git.sh` and `clone-repos.sh`). Most locate the repo with `base=$(cd $(dirname $0)/.. && pwd)` and read from `$base/etc` or `$base/template`. `install-claude.sh` is a copy of Anthropic's Claude Code installer.
- `etc/bash.d/*.sh`: shell snippets that `install-core.sh`/`setup-mac.sh` copy into `~/etc/bash.d/`. A line appended to `~/.bashrc`/`~/.zshrc` sources them all. They must work in both bash and zsh. The installers only copy a file that doesn't exist yet, so an edit here doesn't reach a machine that already has the file.
- `bin/setup-new-product.sh` + `etc/` + `template/`: this scaffolds a new **infra-site** directory (run it from inside the new site dir, e.g. under `~/work/infra-sites/<org>/<env>/<product>`). It copies `etc/Makefile`, `etc/ansible.cfg`, `etc/ansible.env`, `etc/requirements.{raw,yml}`, `etc/segs.yml`, `etc/group-vars-all.yml` and the linter configs (`etc/yamllint`, `etc/ansible-lint`, `etc/tflint.hcl` → `.config/`) as-is. It renders `template/*` with `sed`, substituting `__ORG__`, `__DOMAIN__`, `__PRODUCT__`, `__VERSION__`, `__ACCTID__`, `__HCP_ORG__`, `__CIDRPREFIX__` and `__CIDRLEN__`. Per-cloud vars come from `template/clouds/<cloud>.yml`. When you add a placeholder to a template, add the matching `sed` to the script as well.
- `etc/Makefile` is **not** this repo's Makefile. It is the infra-site Makefile: Terraform (`plan`/`apply`), uv setup and Ansible plays through `ct-play-uv.sh` from `cabtech/ansible-scripts`, with targets per cloud, function and role (a trailing `_` adds `-x`). Its paths (`.config/`, `inv.d/`, `roles/galaxy`) are relative to a site directory.
- `roles/`: `CLAUDE.md` and `repos.cfg` for the `~/work/cabtech/roles` workspace, which symlinks to them. Edit them here.
- `etc/*repos.cfg`, `etc/cabtech-*-repos.cfg`: repo lists consumed by `clone-repos.sh` (lines are `owner/name[,ssh-host]`, and the host defaults to `cabtech-github.com`) and the install scripts.
- `tmp/`: scratch files, not part of any workflow.

## Commands

- `make lint` (repo root): runs `jq` on the template JSON, `shellcheck` and `yamllint -c etc/yamllint template/*.yml`. To check a single script, run `shellcheck bin/<script>.sh`.
- `bin/Makefile`: `make lint` there runs shellcheck on `setup-new-product.sh` only.

## Conventions

- Scripts use `getopts` with short flags. Bad args print `ERROR :: ...` and `exit 42`, other errors `exit 4`. Messages are prefixed `# INFO ::`, `# WARN ::` or `ERROR ::`. Scripts end with an explicit `exit 0`.
- Sections are separated by `# --------------------------------` lines.
- Installers are written to be idempotent: they check before copying (`[[ ! -e ... ]]`) and guard rc-file edits with a `grep -q` marker. Keep new steps rerunnable.
