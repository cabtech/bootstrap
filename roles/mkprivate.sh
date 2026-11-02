#!/usr/bin/env bash
# Create a private ansible-role-ct-<name> copy of a public Cabtech role,
# keeping the public history so changes can be merged back for release.
#
# Usage: mkprivate.sh [-n] [-L] PUBLIC_ROLE_DIR [NEW_NAME]
#   NEW_NAME  name of the private role: "foo", "ct-foo" or "ansible-role-ct-foo"
#             (default: ct-<last part of PUBLIC_ROLE_DIR>, e.g. util-debug -> ct-debug)
#   -n  dry run: print what would be done
#   -L  don't link the public repo (skip the "merge -s ours" commit there)
#
# Run from the roles workspace (the directory holding repos.cfg).
# Steps, each skipped if already done, so it is safe to re-run:
#   1. create private GitHub repo cabtech/ansible-role-ct-<name>
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
	*) sed -n '4,10p' "$0"; exit 2 ;;
	esac
done
shift $((OPTIND - 1))
[[ $# -ge 1 && $# -le 2 ]] || { sed -n '4,10p' "$0"; exit 2; }
[[ -f repos.cfg ]] || { echo "run from the roles workspace (no repos.cfg here)" >&2; exit 2; }

run() {
	if ((dry)); then
		printf '  [dry] %s\n' "$*"
	else
		"$@"
	fi
}

old=${1%/}
case ${2:-} in
"") new=ansible-role-ct-${old##*-} ;;
ansible-role-*) new=$2 ;;
ct-*) new=ansible-role-$2 ;;
*) new=ansible-role-ct-$2 ;;
esac
[[ $new =~ ^ansible-role-ct-[a-z0-9]+$ ]] || { echo "bad new name '$new': want ansible-role-ct-<lowercase word>" >&2; exit 2; }

echo "== $old -> $new"

if [[ $old == *-ct-* ]]; then echo "  skip: already a ct role"; exit 1; fi
[[ -d $old/.git ]] || { echo "  skip: $old is not a git repo here"; exit 1; }

# Always use the cabtech SSH alias (~/.ssh/config) so the cabtech key is used,
# whatever host the public checkout's origin uses.
newurl=git@cabtech-github.com:cabtech/$new.git

# A private copy must share the public role's root commit; anything else is an unrelated repo.
same_history() {
	local root roots
	root=$(git -C "$old" rev-list --max-parents=0 origin/main | head -1)
	roots=$(git -C "$new" rev-list --max-parents=0 HEAD 2>/dev/null) || return 1
	grep -qx "$root" <<<"$roots"
}
collision() {
	echo "  COLLISION: $new exists and is not a copy of $old; pick another name" >&2
	exit 1
}

if [[ -e $new ]] && ! same_history; then collision; fi

# 1. private repo
if gh repo view "cabtech/$new" >/dev/null 2>&1; then
	echo "  repo cabtech/$new exists (history checked after clone)"
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
if [[ -d $new ]] && ! same_history; then
	rm -rf "$new"
	collision
fi

# 4. rename commit
if [[ -d $new ]] && [[ -n $(git -C "$new" log --format=%H --grep="^Rename to $new\$" -1) ]]; then
	echo "  rename already committed"
elif ((dry)); then
	echo "  [dry] rename $old -> $new in pyproject.toml meta/main.yml README.md; uv lock; uv export; commit; push"
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
	if [[ $(git -C "$old" remote get-url private 2>/dev/null) == "$newurl" ]]; then
		echo "  public already has remote 'private'"
	elif git -C "$old" remote get-url private >/dev/null 2>&1; then
		run git -C "$old" remote set-url private "$newurl"
	else
		run git -C "$old" remote add private "$newurl"
	fi
	rename=""
	if git -C "$old" remote get-url private >/dev/null 2>&1 && git -C "$old" fetch -q private; then
		rename=$(git -C "$old" log --format=%H --grep="^Rename to $new\$" -1 private/main)
	fi
	if [[ -n $rename ]] && git -C "$old" merge-base --is-ancestor "$rename" HEAD; then
		echo "  public already records the rename as merged"
	elif ((dry)); then
		echo "  [dry] in $old: fetch private; merge -s ours <rename commit>; push"
	elif [[ -z $rename ]]; then
		echo "  WARN: no 'Rename to $new' commit in private/main, not linking" >&2
		exit 1
	else
		[[ $(git -C "$old" rev-parse --abbrev-ref HEAD) == main ]] || { echo "  WARN: $old not on main, not linking (rerun later)"; exit 1; }
		[[ -z $(git -C "$old" status --porcelain) ]] || { echo "  WARN: $old has uncommitted changes, not linking (rerun later)"; exit 1; }
		git -C "$old" pull -q --ff-only origin main
		# merge only the rename commit: anything after it is real work still to be released
		git -C "$old" merge -q -s ours "$rename" -m "Record $new rename as merged" \
			-m "Lets 'git merge private/main' bring over only real changes." \
			-m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
		git -C "$old" push -q origin main
		echo "  linked public repo"
	fi
fi
