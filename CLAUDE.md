# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal base Docker image (`mydevbox`) for isolated development: nvim, tmux, zsh + dotfiles,
Claude Code, git, and related CLI tools, all baked into one image. Project-specific images
(e.g. a ROS2 project) `FROM mydevbox:latest` and layer their own dependencies on top — see
`example/Dockerfile`. The point of the isolation is to be able to run Claude Code with full
privileges inside the container without trusting it on the host machine.

## Commands

Build (needs SSH agent forwarding — clones the private dotfiles repo mid-build):
```sh
docker build --ssh default -t mydevbox:latest ~/.mydevbox
```

Run (also needs SSH agent forwarding, for `git`/`dotfiles` push/pull inside the container):
```sh
docker run --rm -it \
  -v "$SSH_AUTH_SOCK:/ssh-agent" -e SSH_AUTH_SOCK=/ssh-agent \
  mydevbox:latest
```

Rebuild after any change to the Dockerfile or `scripts/` — there's no incremental "test" step,
verification is smoke-testing the built image directly:
```sh
# tool versions
docker run --rm mydevbox:latest zsh -lc 'nvim --version; lazygit --version; fzf --version'

# nvim health (after touching anything nvim/mason/plugin related) — write to a
# mounted file rather than piping through `tail`, the report is long and gets truncated
docker run --rm -v /some/host/dir:/output mydevbox:latest zsh -lc '
  nvim --headless "+Lazy! sync" -c "checkhealth" -c "write! /tmp/health.txt" -c "qa"
  cp /tmp/health.txt /output/health.txt
'
```

The `Lazy! sync` + codelldb build step (see Architecture) alone takes ~2 minutes; a full
rebuild from scratch is several minutes. This is expected, not a hang.

## Architecture

**Image layering**: `mydevbox` (this repo) is the base; project repos add a thin `FROM
mydevbox:latest` Dockerfile on top (template in `example/Dockerfile`). Project source is never
`COPY`'d into an image — it's bind-mounted at `docker run` time into `/workspace`, specifically
*not* `$HOME`: the dotfiles step below checks real content directly into `$HOME` inside the
base image, and a bind mount there would shadow it.

**Two generic install scripts** in `scripts/` do most tool installation, instead of one-off `RUN`
blocks per tool — adding a new CLI tool to the Dockerfile is almost always a single line calling
one of these:
- `installBinaryFromGithub.sh <owner/repo> <asset-template> [binary-name]` — single-binary
  GitHub releases (`.tar.gz` or `.zip`). Handles both flat archives and ones that nest the binary
  in a subdirectory (common for Rust cross-built releases) by locating it with `find` rather than
  assuming a fixed path.
- `installTreeFromGithub.sh <owner/repo> <asset-template> <name> <relative-bin-path> [tag]` —
  whole directory-tree releases (bin/lib/share, e.g. neovim) that can't be reduced to one file.
  Installs to `/opt/<name>`, symlinks one binary into `PATH`. The optional `tag` argument skips
  the "latest release" GitHub API lookup and pins an exact tag (neovim uses this for
  `NVIM_VERSION`, default `stable`).

Both scripts substitute `{version}` in the asset template with the release tag stripped of a
leading `v`; check the real asset filename via the GitHub API before guessing a template — asset
naming conventions vary per project (see git history for cases where this was gotten wrong first).

**Dotfiles**: pulled from a private bare git repo (`github.com/michmos/.dotfiles`), cloned to
`~/.dotfiles` and checked out with `--work-tree=$HOME`, mirroring the same convention used on the
host machine. Cloning it needs BuildKit SSH agent forwarding (`--mount=type=ssh` in the
Dockerfile, `--ssh default` on the build command) since the repo is private — no key material is
ever baked into a layer.

**User**: runs as `ubuntu:24.04`'s built-in `ubuntu` user (uid/gid 1000) rather than a
custom-created one — simpler, and already in useful groups (`dialout`, `video`) for later
hardware access. Login shell is set to `zsh` since the dotfiles assume it.

**Plugin/tool pre-install**: the final `RUN nvim --headless "+Lazy! sync" -c "sleep 90" +qa`
bakes all LazyVim plugins and treesitter parsers into the image so there's no bootstrap wait on
first launch. `codelldb` (the nvim-dap C/C++/Rust adapter) is mason-managed rather than a plain
GitHub binary, and mason-nvim-dap auto-triggers its install as a side effect of normal plugin
config loading during this same nvim startup — `:sleep` (unlike a shell `sleep`) keeps pumping
nvim's event loop, giving that async job time to actually finish before the process exits. This
is deliberately one nvim invocation, not two: a separate follow-up launch was tried first and
discarded because it re-triggers config loading, which races the treesitter parser builds from
the sync against themselves. The next `RUN test -x .../mason/bin/codelldb` exists so a broken
install fails the build loudly instead of shipping silently.
