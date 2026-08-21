# syntax=docker/dockerfile:1
# Base dev image: personal tooling only (nvim, tmux, claude, git, dotfiles).
# Project-specific images (e.g. ROS2) should FROM this and add their own deps.
#
# Build with SSH agent forwarding so the private dotfiles repo can be cloned:
#   docker build --ssh default -t mydevbox:latest ~/.mydevbox

FROM ubuntu:24.04

ARG NVIM_VERSION=stable

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
        tmux \
        git \
        curl \
        ca-certificates \
        build-essential \
        ripgrep \
        sudo \
        zsh \
        openssh-client \
        unzip \
        nodejs \
        npm \
        python3 \
        python3-venv \
        lsof \
    && rm -rf /var/lib/apt/lists/*

COPY scripts/installBinaryFromGithub.sh /usr/local/bin/installBinaryFromGithub.sh
COPY scripts/installTreeFromGithub.sh /usr/local/bin/installTreeFromGithub.sh

# update ubuntu:24.04's default user - grant sudo, and update login shell
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu \
    && usermod -s /bin/zsh ubuntu

USER ubuntu
WORKDIR /home/ubuntu

# Dotfiles: bare git repo at ~/.dotfiles with work-tree=$HOME (see michmos/.dotfiles).
# Private repo, so this needs SSH agent forwarding at build time (--ssh default, see
# top of file). github.com's host key is well-known/public, safe to trust here.
RUN mkdir -p ~/.ssh && chmod 700 ~/.ssh \
    && ssh-keyscan -t ed25519,rsa github.com >> ~/.ssh/known_hosts \
    && chmod 600 ~/.ssh/known_hosts
RUN --mount=type=ssh,uid=1000,gid=1000 \
    git clone --bare git@github.com:michmos/.dotfiles.git ~/.dotfiles \
    && git --git-dir=$HOME/.dotfiles --work-tree=$HOME config --local status.showUntrackedFiles no \
    && git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout

##############################################################################
# Install more tools
##############################################################################
# Claude Code CLI (native installer, installs a standalone binary, no Node.js needed)
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/ubuntu/.local/bin:${PATH}"

# powerlevel10k theme, referenced directly by ~/.zshrc.d/plugins.zsh
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

# install tmux plugin manager (tpm) and plugins
RUN git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm \
    && tmux new-session -d -s install_plugins \
    && tmux source-file ~/.config/tmux/tmux.conf \
    && ~/.config/tmux/plugins/tpm/bin/install_plugins \
    && sleep 3 \
    && tmux kill-server

# Neovim: apt's version lags far behind upstream, so install the official release tarball.
RUN installTreeFromGithub.sh neovim/neovim "nvim-linux-x86_64.tar.gz" nvim bin/nvim "${NVIM_VERSION}"

# install binaries from github if apt version lags behind (or doesn't ship them at all)
# Add further tools here the same way: installBinaryFromGithub.sh <owner/repo> <asset-template>
RUN installBinaryFromGithub.sh jesseduffield/lazygit "lazygit_{version}_Linux_x86_64.tar.gz"
RUN installBinaryFromGithub.sh junegunn/fzf "fzf-{version}-linux_amd64.tar.gz"
RUN installBinaryFromGithub.sh sharkdp/fd "fd-v{version}-x86_64-unknown-linux-gnu.tar.gz"
RUN installBinaryFromGithub.sh tree-sitter/tree-sitter "tree-sitter-cli-linux-x64.zip" tree-sitter
RUN installBinaryFromGithub.sh sxyazi/yazi "yazi-x86_64-unknown-linux-gnu.zip" yazi
RUN installBinaryFromGithub.sh sxyazi/yazi "yazi-x86_64-unknown-linux-gnu.zip" ya

# run nvim setup
RUN nvim --headless "+Lazy! sync" -c "sleep 90" +qa
RUN test -x "$HOME/.local/share/nvim/mason/bin/codelldb"

CMD ["zsh"]
