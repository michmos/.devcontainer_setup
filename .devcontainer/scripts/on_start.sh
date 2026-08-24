#! /bin/bash
set -euo pipefail

## Clone newest version of dotfiles
git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" pull --ff-only ||
  echo "on_start.sh: could not update dotfiles, continuing with the ones baked into the image" >&2
