#!/usr/bin/env bash
# Scaffold a new project on top of mydevbox: creates a directory, initializes
# git, and copies example/{Dockerfile,docker-compose.yaml} into it with the
# "myproject" placeholder replaced by the actual project name.
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

project_dir="$location/$project_name"
if [[ -e "$project_dir" ]]; then
  err "$project_dir already exists."
  exit 1
fi

mkdir -p "$project_dir"
git init --quiet "$project_dir"

scaffold_project_files "$EXAMPLE_DIR" "$project_dir" "$project_name"

cd "$project_dir"

echo "Created $project_dir (git initialized)."
print_next_steps "$project_dir" "$project_name"
