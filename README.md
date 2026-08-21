# mydevbox
Personal base dev image: nvim, tmux, zsh + dotfiles, claude, git, lazygit, fzf.
Project-specific images (e.g. ROS2) `FROM mydevbox:latest` and add their own deps.

## Build
Needs SSH agent forwarding to clone private dotfiles repo:
Rebuild every time the setup is being updated
```sh
docker build --ssh default -t mydevbox:latest ~/.mydevbox
```

## Run
Also needs SSH agent forwarding, for `git`/`dotfiles` push/pull inside the container:
```sh
docker run --rm -it \
  -v "$SSH_AUTH_SOCK:/ssh-agent" -e SSH_AUTH_SOCK=/ssh-agent \
  mydevbox:latest
```

# Project-specific Dockerfile
## Build
This is just the base image containing all the dependencies required for development. 
But each project might require some additional deps. For this create a new Dockerfile 
building on top of this one - see `./example/Dockerfile`

## Run
Run one long-lived named container per project and `exec` into it:
```sh
# once per project: start it detached, kept alive independently of any shell
docker run -d --name myproject \
  -v "$(pwd):/workspace" \
  -v "$SSH_AUTH_SOCK:/ssh-agent" -e SSH_AUTH_SOCK=/ssh-agent \
  myproject:latest sleep infinity

# every session: attach via tmux so it's reattachable across multiple execs
docker exec -it myproject tmux new -A -s main

# end of day / freeing resources: stops all processes (tmux included), but the
# container's filesystem - and everything in it - persists
docker stop myproject

# resume later: state (Claude auth, shell/nvim history, ad-hoc installs) is
# still there; only the tmux session needs restarting
docker start myproject
docker exec -it myproject tmux new -A -s main
```

Reserve `--rm -it` for quick, genuinely throwaway checks.
