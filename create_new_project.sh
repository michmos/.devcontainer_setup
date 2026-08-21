#!/usr/bin/env bash
# Scaffold a new project on top of mydevbox: creates a cont_<name>/ wrapper
# directory holding Dockerfile + docker-compose.yaml, and a cont_<name>/<name>/
# working dir (git-initialized, bind-mounted into /workspace) next to them -
# so the container files never enter the project's own git tree.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLE_DIR="$SCRIPT_DIR/example"
source "$SCRIPT_DIR/scaffold_lib.sh"

while true; do
  read -r -p "Project name: " project_name
  if [[ -z "$project_name" ]]; then
    err "Project name must not be empty."
    continue
  fi
  validate_project_name "$project_name" && break
done

read -r -e -p "Location [$PWD]: " location
location=${location:-$PWD}
location="${location/#\~/$HOME}"

container_dir="$location/cont_$project_name"
work_dir="$container_dir/$project_name"
if [[ -e "$container_dir" ]]; then
  err "$container_dir already exists."
  exit 1
fi

mkdir -p "$work_dir"
git init --quiet "$work_dir"

scaffold_project_files "$EXAMPLE_DIR" "$container_dir" "$project_name"

echo "Created $container_dir (git initialized in $work_dir)."
print_next_steps "$container_dir" "$work_dir" "$project_name"
