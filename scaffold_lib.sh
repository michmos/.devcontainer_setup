#!/usr/bin/env bash
# Shared functions for create_new_project.sh and init_project.sh. Not meant to
# be run directly — source it.

# Prints an error message to stderr in red (only when stderr is a terminal).
err() {
  if [[ -t 2 ]]; then
    printf '\033[31m%s\033[0m\n' "$1" >&2
  else
    printf '%s\n' "$1" >&2
  fi
}

# Docker image/container names must be lowercase; enforce lowercase
# alnum-separated-by-single-._- groups, starting and ending with alnum.
validate_project_name() {
  local name="$1"
  if [[ ! "$name" =~ ^[a-z0-9]+([._-][a-z0-9]+)*$ ]]; then
    err "Project name must be a valid docker identifier: lowercase alphanumeric, optionally separated by single '.', '_', or '-' (e.g. 'my-project')."
    return 1
  fi
}

# Copies example/{Dockerfile,docker-compose.yaml} into project_dir, replacing
# the "myproject" placeholder, and adds them to .gitignore (appending rather
# than overwriting, in case one already exists).
scaffold_project_files() {
  local example_dir="$1" project_dir="$2" project_name="$3"

  for f in Dockerfile docker-compose.yaml; do
    if [[ -e "$project_dir/$f" ]]; then
      err "$project_dir/$f already exists, refusing to overwrite."
      exit 1
    fi
  done

  cp "$example_dir/Dockerfile" "$example_dir/docker-compose.yaml" "$project_dir/"
  sed -i "s/myproject/$project_name/g" "$project_dir/Dockerfile" "$project_dir/docker-compose.yaml"

  for entry in Dockerfile docker-compose.yaml; do
    if [[ ! -f "$project_dir/.gitignore" ]] || ! grep -qxF "$entry" "$project_dir/.gitignore"; then
      printf '%s\n' "$entry" >> "$project_dir/.gitignore"
    fi
  done
}

print_next_steps() {
  local project_dir="$1" project_name="$2"
  cat <<EOF
Dockerfile + docker-compose.yaml ready in $project_dir (.gitignore'd).

Next steps:
  - adapt Dockerfile (project-specific tooling section)
  - add bind mounts to docker-compose.yaml if required (workspace source, etc.)
  - run: docker compose build
  - run: docker compose up -d
  - run: docker compose exec $project_name tmux new -A -s main
EOF
}
