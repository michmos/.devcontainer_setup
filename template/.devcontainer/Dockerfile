# syntax=docker/dockerfile:1
# Project image: the base already carries nvim, tmux, zsh + dotfiles, claude, git.
# Add only what this project needs on top.
#
# The base's helper scripts are on PATH, so they can be used here as well:
#   RUN installBinaryFromGithub.sh <owner/repo> <asset-template> [binary-name]
#   RUN installTreeFromGithub.sh <owner/repo> <asset-template> <name> <relative-bin> [version]

FROM mydevbox:latest

# runs as the unprivileged "ubuntu" user, which has passwordless sudo
# RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
#         some-package \
#     && sudo rm -rf /var/lib/apt/lists/*
