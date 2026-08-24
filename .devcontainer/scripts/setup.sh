#! /bin/bash
set -euo pipefail

## Dotfiles are cloned and checked out at image build time (see Dockerfile), together
## with the tmux/nvim plugins that depend on them. All that's left per container is
## picking up dotfile commits made since the image was built.
git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" pull --ff-only
