#!/usr/bin/env bash
# release.sh [-n] [major|minor|patch|X.Y.Z]  (default: patch)
#
# Cut a new release of the tap: tag the version, compute the GitHub tarball
# sha256, bump the formula's url + sha256, and push. Run from the tap repo.
#
#   ./release.sh            # patch bump (v0.1.1 -> v0.1.2)
#   ./release.sh minor      # v0.1.x -> v0.2.0
#   ./release.sh 1.0.0      # explicit version
#   ./release.sh -n minor   # dry run: print what it would do, change nothing
#
# After it runs, users update with:  brew update && brew upgrade warp-worktree
set -euo pipefail

dry=0
[[ "${1:-}" == "-n" || "${1:-}" == "--dry-run" ]] && { dry=1; shift; }
arg="${1:-patch}"

cd "$(git rev-parse --show-toplevel)"
formula="Formula/warp-worktree.rb"
[[ -f "$formula" ]] || { echo "release: $formula not found — run inside the tap repo" >&2; exit 1; }

# Preconditions: clean tree, on main, in sync with origin.
[[ -z "$(git status --porcelain)" ]] || { echo "release: working tree not clean — commit or stash first" >&2; exit 1; }
branch="$(git rev-parse --abbrev-ref HEAD)"
[[ "$branch" == "main" ]] || { echo "release: not on main (on '$branch')" >&2; exit 1; }
git fetch -q origin
[[ "$(git rev-parse HEAD)" == "$(git rev-parse origin/main)" ]] || { echo "release: main is not in sync with origin — push/pull first" >&2; exit 1; }

# Resolve the new version from the latest v* tag (or an explicit one).
latest="$(git tag --list 'v*' --sort=-v:refname | head -1)"; latest="${latest#v}"; latest="${latest:-0.0.0}"
IFS=. read -r MA MI PA <<<"$latest"
case "$arg" in
  major) ver="$((MA + 1)).0.0" ;;
  minor) ver="${MA}.$((MI + 1)).0" ;;
  patch) ver="${MA}.${MI}.$((PA + 1))" ;;
  v[0-9]*|[0-9]*) ver="${arg#v}" ;;
  *) echo "usage: release.sh [-n] [major|minor|patch|X.Y.Z]" >&2; exit 2 ;;
esac
tag="v$ver"
git rev-parse "$tag" >/dev/null 2>&1 && { echo "release: tag $tag already exists" >&2; exit 1; }

# Derive owner/repo from origin for the tarball URL.
slug="$(git remote get-url origin | sed -E 's#(git@github.com:|https://github.com/)##; s#\.git$##')"
tarurl="https://github.com/$slug/archive/refs/tags/$tag.tar.gz"

echo "release: $slug  v$latest -> $tag"
if (( dry )); then
  echo "release: [dry run] would tag $tag, push it, then:"
  echo "  - fetch $tarurl, compute sha256"
  echo "  - bump url -> /$tag.tar.gz and sha256 in $formula"
  echo "  - commit 'release: $tag' and push main"
  exit 0
fi

# Tag and push the tag first so GitHub generates the archive.
git tag "$tag"
git push -q origin "$tag"

# Fetch the tarball sha256 (retry — GitHub takes a moment to generate it).
sha=""
for _ in {1..10}; do
  sha="$(curl -fsSL "$tarurl" | shasum -a 256 | awk '{print $1}')" && [[ ${#sha} -eq 64 ]] && break
  sleep 2
done
[[ ${#sha} -eq 64 ]] || { echo "release: could not fetch a valid sha256 from $tarurl" >&2; exit 1; }
echo "release: sha256=$sha"

# Bump the formula and push.
sed -i '' -E "s#/v[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz#/$tag.tar.gz#" "$formula"
sed -i '' -E "s/sha256 \"[0-9a-f]*\"/sha256 \"$sha\"/" "$formula"
git add "$formula"
git commit -q -m "release: $tag"
git push -q origin main

echo "release: $tag pushed ✅  — users: brew update && brew upgrade warp-worktree"
