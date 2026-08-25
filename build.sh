#!/usr/bin/env bash
# Build the base image that all project containers derive from.
# Needs a running ssh agent with access to the private dotfiles repo.
#
# Usage: build.sh [--if-missing] [docker build args...]
#   --if-missing   only build when the image does not exist yet; project
#                  devcontainers call it this way from initializeCommand
# Remaining arguments go to docker build, e.g. --no-cache or
# --build-arg DOTFILES_REF=some-branch

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
image="${MYDEVBOX_IMAGE:-mydevbox:latest}"

if [ "${1:-}" = "--if-missing" ]; then
  shift
  if docker image inspect "$image" >/dev/null 2>&1; then
    echo "$image already present, skipping build"
    exit 0
  fi
fi

docker build --ssh default -t "$image" "$@" "$script_dir/base"

echo ""
echo "Built $image"
echo "Existing project containers keep their old base until rebuilt:"
echo "  devpod up --recreate <workspace>"
