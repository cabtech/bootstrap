# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

This directory is not itself a git repo. It is a workspace holding Cabtech's Ansible roles, and each `ansible-role-*` subdirectory is its own repo (`git@github.com:cabtech/<dir>.git`). Run git commands inside the role directory. Every role uses `main` except `app-freeradius`, which is still on `master`. `repos.cfg` lists the `cabtech/<repo>` names.

`CLAUDE.md` and `repos.cfg` in this directory are symlinks into `../bootstrap/roles/`. Commit and push changes to them in the `bootstrap` repo (`cabtech/bootstrap`, branch `main`).

Role name prefixes:
- `ct-*`: current-generation roles that follow the template conventions below.
- `app-*`, `crypto-*`, `calibri-*`: older roles. Their structure varies more.
- `ct-template`: the skeleton for new roles. Its placeholders (`ct-TODO` tags, `TODO` meta fields, `dummy` files) are deliberate.
- `ct-terragen`: the outlier. It uses Ansible only as a templating engine to generate Terraform HCL on localhost.

`ct-template`, `ct-terragen` and `ct-twingate` each have their own `CLAUDE.md` (and the latter two an `AGENTS.md`). Read the role's own file before working there, because it overrides this one.

## Commands

Run these inside a role directory. There are no tests (no molecule), so linting is the only check.

- `make lint`: runs yamllint and ansible-lint, plus Python and shell linters in some roles. The targets are Make stamp files (`.lintyaml`, `.lintansible`, or `.ylint`/`.alint` in older roles), so a passing target is skipped until its inputs change. Run `make clean` to force a re-lint.
- Run a linter directly: `yamllint --config-file=.config/yamllint .` and `ansible-lint --config-file=.config/ansible-lint` (some roles name it `.config/ansible-lint.yml`, so check `.config/`).
- Tool versions: every role has a `uv` project (Python 3.14, a per-role `.venv`) with `init-uv`/`update-uv` targets. To change tools, edit `requirements.raw` and then run `make update-uv`. All lint targets call the linters through `uv run`. In roles with Python under `files/`, the Python lint target (`.lintpython` or `.pylint`) runs `black`, which reformats files in place.
- `make push`: rsyncs the role to `/mnt/hgfs/shared/<role>` (a VM shared folder). It does not do a git push.
- `app-freeradius`, `app-kafka` and `app-opengrok` keep their yamllint config in `.yamllint` at the role root, not `.config/yamllint`. They were never linted before October 2026 and still fail ansible-lint.

CI is usually `.github/workflows/yamllint.yml`, which runs yamllint only, in **strict** mode, on push to main/master. Warnings therefore fail CI even when `make lint` looks clean. Many older roles have no CI.

## Role architecture

### Current pattern (`ct-*`, from `ct-template`)

`tasks/main.yml` includes `tasks/variables.yml`, which loads one file from `vars/` using `first_found`. It then uses `first_found` again to include one task file from `tasks/`. Both lookups use this order:

1. `<ansible_distribution>-<major>.yml`
2. `<ansible_distribution>.yml`
3. `<ansible_os_family>.yml`
4. `default.yml`

The cross-OS logic follows in `main.yml`. To add OS-specific behaviour, add matching files and keep `default.yml` as the fallback. Settings that users can override go in `defaults/main.yml`, and per-OS values go in `vars/`.

### Legacy pattern (some `app-*` roles)

`app-datadog`, `app-envoy` and others depend in `meta/main.yml` on `cabtech/ansible-role-util-facts` (that role is not in this workspace), which sets `ct_family`. Their `tasks/main.yml` runs `common-pre.yml`, then `setup-{{ ct_family }}.yml` (`debian`/`redhat`), then `common-post.yml`. Keep this structure when editing these roles unless you are explicitly migrating one to the FF pattern.

## Conventions

These apply across roles, and yamllint and ansible-lint enforce most of them:

- YAML files start with `---` and end with `...`. Sections are separated by `# --------------------------------` lines.
- Indentation is 2 spaces, and sequences are **not** indented under their parent key (`indent-sequences: false`). ansible-lint skips `yaml[indentation]` so the two tools agree. Line length is effectively unlimited.
- Task names are double-quoted, modules use FQCNs (`ansible.builtin.*`), and keys within a module call are alphabetised. Use `become: true` on privileged tasks.
- Every task has a role tag: `tags: ["ct-<name>"]`. App roles also use the `ct-` prefix, e.g. `ct-envoy`.
- Role variables are prefixed with the role's short name (`prometheus_*`, `twingate_*`), even though ansible-lint's `var-naming[no-role-prefix]` check is skipped.
- Several `ct-*` templates (twingate, terragen, nomadjobs, openonload) that find missing or invalid config write an `# ERROR ::` or `WARNING` comment into the rendered file instead of failing the play.
- When you add or change a variable, update `defaults/main.yml` and the role's `README.md` as well.
