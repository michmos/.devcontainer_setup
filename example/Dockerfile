# Example project image built on top of mydevbox.
# Copy this into a project's container dir (cont_<name>/, see
# create_new_project.sh / init_project.sh) as `Dockerfile` and adjust the
# "project-specific tooling" section below.

FROM mydevbox:latest

# --- Project-specific tooling ----------------------------------------------
# Add whatever this project needs on top of the base devbox here
#   RUN sudo apt-get update && sudo apt-get install -y <some-package>
# -----------------------------------------------------------------------------

# Project source is bind-mounted at `docker run` time (see below),
WORKDIR /workspace

CMD ["zsh"]

# --- Usage -------------------------------------------------------------------
# Build (from this project's directory, where this Dockerfile lives):
#   docker build -t myproject:latest .
#
# Quick throwaway check, bind-mounting the current directory into /workspace.
# Also forwards the SSH agent, same as mydevbox itself, so git push/pull works:
#   docker run --rm -it \
#     -v "$(pwd):/workspace" \
#     -v "$SSH_AUTH_SOCK:/ssh-agent" -e SSH_AUTH_SOCK=/ssh-agent \
#     myproject:latest
#
# For regular day-to-day work, don't use --rm - see "Recommended workflow" in
# ../README.md: a long-lived named container + `docker exec`, so Claude Code's
# login, shell/nvim history, and any ad-hoc installs survive between sessions.
# -------------------------------------------------------------------------------
