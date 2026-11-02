#!/usr/bin/env bash
# Create private ansible-role-ct-<name> copies of public Cabtech roles,
# keeping the public history so changes can be merged back for release.
#
# Usage: mkprivate.sh [-n] [-L] ROLE_DIR [ROLE_DIR ...]
#   -n  dry run: print what would be done
#   -L  don't link the public repo (skip the "merge -s ours" commit there)
#
# Run from the roles workspace (the directory holding repos.cfg).
# Steps per role, each skipped if already done:
#   1. create private GitHub repo cabtech/ansible-role-ct-<suffix>
#   2. push public origin/main into it
#   3. clone it next to the public role
#   4. commit the rename (pyproject, meta role_name, README title, uv.lock, requirements.txt)
#   5. add the new repo to repos.cfg
#   6. in the public repo, add remote "private" and record the rename as merged
set -euo pipefail

dry=0
link=1
while getopts "nL" opt; do
	case $opt in
	n) dry=1 ;;
	L) link=0 ;;
	*) sed -n '4,8p' "$0"; exit 2 ;;
	esac
done
shift $((OPTIND - 1))
[[ $# -gt 0 ]] || { sed -n '4,8p' "$0"; exit 2; }
[[ -f repos.cfg ]] || { echo "run from the roles workspace (no repos.cfg here)" >&2; exit 2; }

run() {
	if ((dry)); then
		printf '  [dry] %s\n' "$*"
	else
		"$@"
	fi
}

for old in "$@"; do
	old=${old%/}
	new=ansible-role-ct-${old##*-}
	echo "== $old -> $new"

	if [[ $old == *-ct-* ]]; then echo "  skip: already a ct role"; continue; fi
	[[ -d $old/.git ]] || { echo "  skip: $old is not a git repo here"; continue; }

	origin=$(git -C "$old" remote get-url origin)
	newurl=${origin%/*}/$new.git

	if [[ -e $new ]] && ! git -C "$new" log -1 --format=%s 2>/dev/null | grep -q "^Rename to $new"; then
		echo "  COLLISION: $new already exists and is not a copy of $old, skipping"
		continue
	fi

	# 1. private repo
	if gh repo view "cabtech/$new" >/dev/null 2>&1; then
		echo "  repo cabtech/$new exists"
	else
		desc=$(gh repo view "cabtech/$old" --json description -q .description)
		run gh repo create "cabtech/$new" --private --description "$desc"
	fi

	# 2. seed with public history (only into an empty repo)
	if [[ -z $(git ls-remote --heads "$newurl" main 2>/dev/null) ]]; then
		run git -C "$old" fetch origin main
		run git -C "$old" push "$newurl" refs/remotes/origin/main:refs/heads/main
	else
		echo "  cabtech/$new already has main"
	fi

	# 3. clone
	if [[ -d $new ]]; then
		echo "  $new already cloned"
	else
		run git clone -q "$newurl" "$new"
	fi

	# 4. rename commit
	if ((dry)); then
		echo "  [dry] rename $old -> $new in pyproject.toml meta/main.yml README.md; uv lock; uv export; commit; push"
	elif git -C "$new" log --format=%s | grep -q "^Rename to $new"; then
		echo "  rename already committed"
	else
		(
			cd "$new"
			mapfile -t files < <(git grep -l -e "$old" -e "${old//-/_}" -- pyproject.toml meta/main.yml README.md || true)
			((${#files[@]})) && sed -i "s/$old/$new/g; s/${old//-/_}/${new//-/_}/g" "${files[@]}"
			uv lock -q
			uv export -q -o requirements.txt >/dev/null
			git add -A pyproject.toml meta/main.yml README.md uv.lock requirements.txt
			git commit -q -m "Rename to $new" -m "Private copy of cabtech/$old." \
				-m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
			git push -q origin main
		)
		echo "  committed and pushed rename"
	fi

	# 5. repos.cfg
	if grep -qx "cabtech/$new" repos.cfg; then
		echo "  already in repos.cfg"
	elif ((dry)); then
		echo "  [dry] add cabtech/$new to repos.cfg"
	else
		{ cat repos.cfg; echo "cabtech/$new"; } | sort -u >repos.cfg.tmp && cat repos.cfg.tmp >repos.cfg && rm repos.cfg.tmp
		echo "  added to repos.cfg"
	fi
	# 6. link public repo so later merges from private/main skip the rename
	if ((link)); then
		if git -C "$old" remote get-url private >/dev/null 2>&1; then
			echo "  public already has remote 'private'"
		else
			run git -C "$old" remote add private "$newurl"
		fi
		if ((dry)); then
			echo "  [dry] in $old: fetch private; merge -s ours private/main; push"
		else
			git -C "$old" fetch -q private
			if git -C "$old" merge-base --is-ancestor private/main HEAD; then
				echo "  public already records the rename as merged"
			else
				[[ $(git -C "$old" rev-parse --abbrev-ref HEAD) == main ]] || { echo "  WARN: $old not on main, not linking (rerun later)"; continue; }
				[[ -z $(git -C "$old" status --porcelain) ]] || { echo "  WARN: $old has uncommitted changes, not linking (rerun later)"; continue; }
				git -C "$old" pull -q --ff-only origin main
				git -C "$old" merge -q -s ours private/main -m "Record $new rename as merged" \
					-m "Lets 'git merge private/main' bring over only real changes." \
					-m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
				git -C "$old" push -q origin main
				echo "  linked public repo"
			fi
		fi
	fi

done
