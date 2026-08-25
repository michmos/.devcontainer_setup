#!/usr/bin/env bash
# Copy the project devcontainer template into the current directory.
# add an alias to this script in your shell config

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$script_dir/template/.devcontainer"
dest="$(pwd)/.devcontainer"
image="${MYDEVBOX_IMAGE:-mydevbox:latest}"

if [ -e "$dest" ]; then
  echo "Error: $dest already exists" >&2
  exit 1
fi

if ! docker image inspect "$image" >/dev/null 2>&1; then
  echo "Error: base image '$image' not found - run '$script_dir/build.sh' first" >&2
  exit 1
fi

cp -r "$src" "$dest"
echo "Copied $src -> $dest"
echo ""
echo "- Update '.devcontainer/devcontainer.json' and '.devcontainer/Dockerfile' to your project needs"
echo "- Run 'devpod up .' to build and run the devcontainer"
