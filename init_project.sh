#!/usr/bin/env bash
# Initialize an existing project directory on top of mydevbox: copies
# example/{Dockerfile,docker-compose.yaml} into the current directory with the
# "myproject" placeholder replaced by the actual project name. Unlike
# create_new_project.sh, this operates in-place on an already-existing
# project (cwd), and doesn't touch git if it's already initialized.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLE_DIR="$SCRIPT_DIR/example"

read -r -p "Is $PWD the project root? [y/N] " confirm_root
if [[ ! "$confirm_root" =~ ^[Yy]$ ]]; then
  echo "cd into the project root and re-run." >&2
  exit 1
fi

default_name="$(basename "$PWD")"
read -r -p "Project name [$default_name]: " project_name
project_name=${project_name:-$default_name}
if [[ ! "$project_name" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]]; then
  echo "Project name must be a valid docker identifier (start with alnum, then alnum/._-)." >&2
  exit 1
fi

project_dir="$PWD"

for f in Dockerfile docker-compose.yaml; do
  if [[ -e "$project_dir/$f" ]]; then
    echo "$project_dir/$f already exists, refusing to overwrite." >&2
    exit 1
  fi
done

cp "$EXAMPLE_DIR/Dockerfile" "$EXAMPLE_DIR/docker-compose.yaml" "$project_dir/"
sed -i "s/myproject/$project_name/g" "$project_dir/Dockerfile" "$project_dir/docker-compose.yaml"

for entry in Dockerfile docker-compose.yaml; do
  if [[ ! -f "$project_dir/.gitignore" ]] || ! grep -qxF "$entry" "$project_dir/.gitignore"; then
    printf '%s\n' "$entry" >> "$project_dir/.gitignore"
  fi
done

if [[ ! -d "$project_dir/.git" ]]; then
  git init --quiet "$project_dir"
fi

cat <<EOF
Initialized $project_dir (Dockerfile + docker-compose.yaml ready, .gitignore'd).

Next steps:
  - adapt Dockerfile (project-specific tooling section)
  - add bind mounts to docker-compose.yaml if required (workspace source, etc.)
  - run: docker compose build
  - run: docker compose up -d
  - run: docker compose exec $project_name tmux new -A -s main
EOF
