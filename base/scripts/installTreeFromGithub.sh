#!/usr/bin/env bash
# Install a directory-tree release (bin/lib/share, not a single binary) from a
# GitHub release .tar.gz into /opt/<name>, and symlink one of its executables into PATH.
#
# Usage:
#   installTreeFromGithub.sh <owner/repo> <asset-template> <name> <relative-bin-path> [tag]
#
#   <asset-template>     release asset filename, {version} placeholder for the
#                        release tag (leading "v" stripped)
#   <name>               install directory under /opt, and the symlinked command name
#   <relative-bin-path>  path to the executable inside the extracted tree,
#                        relative to the tree root (e.g. "bin/nvim")
#   [tag]                specific release tag to install (e.g. "v0.10.2" or "stable");
#                        defaults to whatever GitHub currently reports as latest
#
# Example:
#   installTreeFromGithub.sh neovim/neovim "nvim-linux-x86_64.tar.gz" nvim bin/nvim stable

set -euo pipefail

repo="$1"
asset_template="$2"
name="$3"
relative_bin="$4"
tag="${5:-}"

if [[ -z "$tag" ]]; then
    tag=$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
        | grep -Po '"tag_name": *"\K[^"]*')
fi
version="${tag#v}"
asset="${asset_template//\{version\}/${version}}"
url="https://github.com/${repo}/releases/download/${tag}/${asset}"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

curl -fsSL -o "$tmpdir/asset.tar.gz" "$url"
mkdir "$tmpdir/extracted"
tar -C "$tmpdir/extracted" -xzf "$tmpdir/asset.tar.gz"

# release tarballs like this normally contain a single top-level directory; use
# whatever it's actually called rather than assuming a naming convention
extracted_dir=$(find "$tmpdir/extracted" -mindepth 1 -maxdepth 1 -type d)

sudo rm -rf "/opt/${name}"
sudo mv "$extracted_dir" "/opt/${name}"
sudo ln -sf "/opt/${name}/${relative_bin}" "/usr/local/bin/${name}"
