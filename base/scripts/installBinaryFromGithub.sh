#!/usr/bin/env bash
# Install a single binary from a GitHub release's .tar.gz or .zip asset into
# /usr/local/bin. Handles both flat archives (binary at the root) and archives
# that nest it inside a subdirectory (e.g. most Rust cross-built releases).
#
# Usage:
#   installBinaryFromGithub.sh <owner/repo> <asset-template> [binary-name]
#
#   <asset-template>  release asset filename, with {version} as a placeholder
#                      for the latest release tag (leading "v" stripped)
#   [binary-name]      file to extract from the archive and install;
#                      defaults to the part of <owner/repo> after the slash
#
# Examples:
#   installBinaryFromGithub.sh jesseduffield/lazygit "lazygit_{version}_Linux_x86_64.tar.gz"
#   installBinaryFromGithub.sh junegunn/fzf "fzf-{version}-linux_amd64.tar.gz"
#   installBinaryFromGithub.sh sharkdp/fd "fd-v{version}-x86_64-unknown-linux-gnu.tar.gz"
#   installBinaryFromGithub.sh tree-sitter/tree-sitter "tree-sitter-cli-linux-x64.zip" tree-sitter

set -euo pipefail

repo="$1"
asset_template="$2"
binary="${3:-${repo##*/}}"

tag=$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
    | grep -Po '"tag_name": *"\K[^"]*')
version="${tag#v}"
asset="${asset_template//\{version\}/${version}}"
url="https://github.com/${repo}/releases/download/${tag}/${asset}"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

curl -fsSL -o "$tmpdir/asset" "$url"
mkdir "$tmpdir/extracted"
case "$asset" in
    *.zip) unzip -q "$tmpdir/asset" -d "$tmpdir/extracted" ;;
    *) tar -C "$tmpdir/extracted" -xzf "$tmpdir/asset" ;;
esac

binary_path=$(find "$tmpdir/extracted" -type f -name "$binary" | head -1)
sudo install "$binary_path" -D -t /usr/local/bin/
