#!/usr/bin/env bash
# Initialize an existing project directory on top of mydevbox: copies
# example/{Dockerfile,docker-compose.yaml} into the current directory with the
# "myproject" placeholder replaced by the actual project name. Unlike
# create_new_project.sh, this operates in-place on an already-existing
# project (cwd), and doesn't touch git if it's already initialized.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLE_DIR="$SCRIPT_DIR/example"
source "$SCRIPT_DIR/scaffold_lib.sh"

read -r -p "Is $PWD the project root? [y/N] " confirm_root
if [[ ! "$confirm_root" =~ ^[Yy]$ ]]; then
  err "cd into the project root and re-run."
  exit 1
fi

default_name="$(basename "$PWD")"
while true; do
  read -r -p "Project name [$default_name]: " project_name
  project_name=${project_name:-$default_name}
  validate_project_name "$project_name" && break
done

project_dir="$PWD"

scaffold_project_files "$EXAMPLE_DIR" "$project_dir" "$project_name"

if [[ ! -d "$project_dir/.git" ]]; then
  git init --quiet "$project_dir"
fi

echo "Initialized $project_dir."
print_next_steps "$project_dir" "$project_name"
