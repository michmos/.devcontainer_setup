#! /bin/bash
set -euo pipefail

## Dotfiles: bare git repo at ~/.dotfiles with work-tree=$HOME (see michmos/.dotfiles).
if [ ! -d "$HOME/.dotfiles" ]; then
  git clone --bare git@github.com:michmos/.dotfiles.git "$HOME/.dotfiles"
  git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" config --local status.showUntrackedFiles no
  git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout
fi

## tmux plugins (tpm itself is cloned in the Dockerfile); needs tmux.conf from dotfiles.
tmux new-session -d -s install_plugins
tmux source-file ~/.config/tmux/tmux.conf
~/.config/tmux/plugins/tpm/bin/install_plugins
sleep 3
tmux kill-server

## nvim plugins/LSP setup; needs nvim config from dotfiles.
nvim --headless "+Lazy! sync" -c "sleep 90" +qa
test -x "$HOME/.local/share/nvim/mason/bin/codelldb"
