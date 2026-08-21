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

# Copies example/{Dockerfile,docker-compose.yaml} into container_dir, replacing
# the "myproject" placeholder. container_dir is the "cont_<name>" wrapper dir,
# a sibling of (not an ancestor/descendant of) the git-initialized work dir,
# so the container files never enter the project's git tree at all — no
# .gitignore needed.
scaffold_project_files() {
  local example_dir="$1" container_dir="$2" project_name="$3"

  for f in Dockerfile docker-compose.yaml; do
    if [[ -e "$container_dir/$f" ]]; then
      err "$container_dir/$f already exists, refusing to overwrite."
      exit 1
    fi
  done

  cp "$example_dir/Dockerfile" "$example_dir/docker-compose.yaml" "$container_dir/"
  sed -i "s/myproject/$project_name/g" "$container_dir/Dockerfile" "$container_dir/docker-compose.yaml"
}

print_next_steps() {
  local container_dir="$1" work_dir="$2" project_name="$3"
  cat <<EOF
Dockerfile + docker-compose.yaml ready in $container_dir.
Project working dir (git root, bind-mounted into /workspace): $work_dir

Next steps:
  - adapt Dockerfile (project-specific tooling section)
  - cd $container_dir
  - docker compose build
  - docker compose up -d
  - docker compose exec $project_name tmux new -A -s main
EOF
}
