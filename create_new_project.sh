#!/usr/bin/env bash
# Scaffold a new project on top of mydevbox: creates a directory, initializes
# git, and copies example/{Dockerfile,docker-compose.yaml} into it with the
# "myproject" placeholder replaced by the actual project name.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLE_DIR="$SCRIPT_DIR/example"

read -r -p "Project name: " project_name
if [[ -z "$project_name" ]]; then
  echo "Project name must not be empty." >&2
  exit 1
fi
if [[ ! "$project_name" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]]; then
  echo "Project name must be a valid docker identifier (start with alnum, then alnum/._-)." >&2
  exit 1
fi

read -r -e -p "Location [$PWD]: " location
location=${location:-$PWD}
location="${location/#\~/$HOME}"

project_dir="$location/$project_name"
if [[ -e "$project_dir" ]]; then
  echo "$project_dir already exists." >&2
  exit 1
fi

mkdir -p "$project_dir"
git init --quiet "$project_dir"

cp "$EXAMPLE_DIR/Dockerfile" "$EXAMPLE_DIR/docker-compose.yaml" "$project_dir/"
sed -i "s/myproject/$project_name/g" "$project_dir/Dockerfile" "$project_dir/docker-compose.yaml"

printf '%s\n' "Dockerfile" "docker-compose.yaml" > "$project_dir/.gitignore"

cd "$project_dir"

cat <<EOF
Created $project_dir (git initialized, Dockerfile + docker-compose.yaml ready, .gitignore'd).

Next steps:
  - adapt Dockerfile (project-specific tooling section)
  - add bind mounts to docker-compose.yaml if required (workspace source, etc.)
  - run: docker compose build
  - run: docker compose up -d
  - run: docker compose exec $project_name tmux new -A -s main
EOF
