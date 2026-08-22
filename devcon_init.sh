#!/usr/bin/env bash
# add an alias to this script in your shell config

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$script_dir/.devcontainer"
dest="$(pwd)/.devcontainer"

if [ -e "$dest" ]; then
  echo "Error: $dest already exists" >&2
  exit 1
fi

cp -r "$src" "$dest"
echo "Copied $src -> $dest"
echo ""
echo "- Update '.devcontainer/devcontainer.json' and the '.devcontainer/scripts/setup.sh' to your project needs"
echo "- Run 'devpod up .' to build and run the devcontainer"
