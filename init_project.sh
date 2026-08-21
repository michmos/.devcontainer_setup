#!/usr/bin/env bash
# Initialize an existing project directory on top of mydevbox: moves the
# current directory (git history and all) into a new cont_<name>/<name>/
# working dir, and places example/{Dockerfile,docker-compose.yaml} in
# cont_<name>/ next to it - so the container files never enter the project's
# own git tree. Doesn't touch git if it's already initialized.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLE_DIR="$SCRIPT_DIR/example"
source "$SCRIPT_DIR/scaffold_lib.sh"

read -r -p "Is $PWD the project root? [y/N] " confirm_root
if [[ ! "$confirm_root" =~ ^[Yy]$ ]]; then
  err "cd into the project root and re-run."
  exit 1
fi

old_dir="$PWD"
default_name="$(basename "$old_dir")"
while true; do
  read -r -p "Project name [$default_name]: " project_name
  project_name=${project_name:-$default_name}
  validate_project_name "$project_name" && break
done

parent_dir="$(dirname "$old_dir")"
container_dir="$parent_dir/cont_$project_name"
work_dir="$container_dir/$project_name"
if [[ -e "$container_dir" ]]; then
  err "$container_dir already exists."
  exit 1
fi

cd "$parent_dir"
mkdir "$container_dir"
mv "$old_dir" "$work_dir"

if [[ ! -d "$work_dir/.git" ]]; then
  git init --quiet "$work_dir"
fi

scaffold_project_files "$EXAMPLE_DIR" "$container_dir" "$project_name"

echo "Moved $old_dir -> $work_dir. cd there (your shell's cwd is now gone)."
print_next_steps "$container_dir" "$work_dir" "$project_name"
