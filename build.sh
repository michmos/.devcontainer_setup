#!/usr/bin/env bash
# Build the base image that all project containers derive from.
# Needs a running ssh agent with access to the private dotfiles repo.
# Extra arguments are forwarded to docker build, e.g. --no-cache or
# --build-arg DOTFILES_REF=some-branch

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
image="${MYDEVBOX_IMAGE:-mydevbox:latest}"
keep_container="${MYDEVBOX_KEEP_CONTAINER:-mydevbox-keep}"

docker build --ssh default -t "$image" "$@" "$script_dir/base"

# An idle container holding a reference to the image, so a bare
# 'docker image prune -a' never reclaims the base. Recreated on every build so
# that only the current base stays pinned and superseded ones become prunable.
docker rm -f "$keep_container" >/dev/null 2>&1 || true
docker run -d --restart=always --name "$keep_container" "$image" sleep infinity >/dev/null

echo ""
echo "Built $image, pinned by container '$keep_container'"
echo "Existing project containers keep their old base until rebuilt:"
echo "  devpod up --recreate <workspace>"
