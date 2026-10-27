# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

This directory is not itself a git repo. It is a workspace holding Cabtech's Ansible roles, and each `ansible-role-*` subdirectory is its own repo (`git@github.com:cabtech/<dir>.git`). Run git commands inside the role directory. Every role uses `main` as its default branch. `repos.cfg` lists the `cabtech/<repo>` names.

`CLAUDE.md` and `repos.cfg` in this directory are symlinks into `../bootstrap/roles/`. Commit and push changes to them in the `bootstrap` repo (`cabtech/bootstrap`, branch `main`).

Role name prefixes:
- `ct-*`: current-generation roles that follow the template conventions below.
- `app-*`, `crypto-*`, `calibri-*`: older roles. Their structure varies more.
- `distro-*`, `family-*`, `hashicorp-*`, `opsys-unix`, `util-*`: oldest generation, mostly untouched since 2020–2024.
- `ct-template`: the skeleton for new roles. Its placeholders (`ct-TODO` tags, `TODO` meta fields, `dummy` files) are deliberate.
- `ct-terragen`: the outlier. It uses Ansible only as a templating engine to generate Terraform HCL on localhost.

`ct-template`, `ct-terragen`, `ct-twingate` and `ct-netbirdclient` each have their own `CLAUDE.md`. Read the role's own file before working there, because it overrides this one.

## Commands

Run these inside a role directory. There are no tests (no molecule), so linting is the only check.

- `make lint`: runs yamllint and ansible-lint, plus Python and shell linters in some roles. The targets are Make stamp files (`.lintyaml`, `.lintansible`, `.lintpython`, `.lintshell`), so a passing target is skipped until its inputs change. Run `make clean` (`rm -f .lint*`) to force a re-lint.- Run a linter directly: `uv run yamllint --strict --config-file=.config/yamllint .` and `uv run ansible-lint --config-file=.config/ansible-lint` (some roles name it `.config/ansible-lint.yml`, so check `.config/`). The exact commands CI runs are in each role's `.github/workflows/*.yml`.
- Tool versions: every role has a `uv` project (Python 3.14, a per-role `.venv`) with `init-uv`/`update-uv` targets. To change tools, edit `requirements.raw` and then run `make update-uv`. All lint targets call the linters through `uv run`. In roles with Python under `files/`, the `.lintpython` target runs `black`, which reformats files in place.

Every role has CI in `.github/workflows/`, triggered by manual dispatch and by a push to `main`. Roles that ship shell scripts in `files/` also have a `lint-scripts.yml` that runs `shellcheck` on the named scripts. In the oldest-generation roles it runs with `--severity=warning --shell=bash`, because several scripts are sourced snippets without a shebang. Every role has `lint-ansible.yml` with yamllint and ansible-lint jobs. The ansible-lint job runs the same command as the role's `.lintansible` Makefile target. Each job runs `astral-sh/setup-uv`, `uv sync --locked --no-install-project` and then `uv run --no-sync <tool>`, so CI uses the versions in `uv.lock`; after `make update-uv`, commit `uv.lock` for CI to pick them up. CI runs yamllint with `--strict`, so warnings fail CI even when `make lint` looks clean.

If pushes stop triggering a workflow that still runs from manual dispatch, rename the workflow file: GitHub registers it as a new workflow, which fixed 15 private repos in October 2026.

## Role architecture

### Current pattern (`ct-*`, from `ct-template`)

`tasks/main.yml` includes `tasks/variables.yml`, which loads one file from `vars/` using `first_found`. It then uses `first_found` again to include one task file from `tasks/`. Both lookups use this order:

1. `<ansible_distribution>-<major>.yml`
2. `<ansible_distribution>.yml`
3. `<ansible_os_family>.yml`
4. `default.yml`

The cross-OS logic follows in `main.yml`. To add OS-specific behaviour, add matching files and keep `default.yml` as the fallback. Settings that users can override go in `defaults/main.yml`, and per-OS values go in `vars/`.

### Legacy pattern (some `app-*` roles)

`app-datadog`, `app-envoy` and others depend in `meta/main.yml` on `cabtech/ansible-role-util-facts`, which sets `ct_family` and other `ct_*` facts. That role is in this workspace, but consumers pull a pinned version from GitHub, so a change there only takes effect after you tag a release and bump the `version:` in each consumer's `meta/main.yml`. The `hashicorp-*` roles depend on `hashicorp-common` in the same way. Their `tasks/main.yml` runs `common-pre.yml`, then `setup-{{ ct_family }}.yml` (`debian`/`redhat`), then `common-post.yml`. Keep this structure when editing these roles unless you are explicitly migrating one to the FF pattern.

## Conventions

These apply across roles, and yamllint and ansible-lint enforce most of them:

- YAML files start with `---` and end with `...`. Sections are separated by `# --------------------------------` lines.
- Indentation is 2 spaces, and sequences are **not** indented under their parent key (`indent-sequences: false`). ansible-lint skips `yaml[indentation]` so the two tools agree. Line length is effectively unlimited.
- Task names are double-quoted, modules use FQCNs (`ansible.builtin.*`), and keys within a module call are alphabetised. Use `become: true` on privileged tasks.
- Every task has a role tag: `tags: ["ct-<name>"]`. App roles also use the `ct-` prefix, e.g. `ct-envoy`.
- Role variables are prefixed with the role's short name (`prometheus_*`, `twingate_*`), even though ansible-lint's `var-naming[no-role-prefix]` check is skipped.
- Several `ct-*` templates (twingate, terragen, nomadjobs, openonload) that find missing or invalid config write an `# ERROR ::` or `WARNING` comment into the rendered file instead of failing the play.
- When you add or change a variable, update `defaults/main.yml` and the role's `README.md` as well.
