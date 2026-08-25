# mydevbox
Personal base dev image: nvim, tmux, zsh + dotfiles, claude, git, lazygit, fzf.
Project containers are thin layers `FROM mydevbox:latest` and add their own deps.

## Structure
```
base/                     # source of mydevbox:latest, built by build.sh
├── Dockerfile
└── scripts/
    ├── on_start.sh                 # baked into the image, pulls newest dotfiles
    ├── installBinaryFromGithub.sh  # on PATH, usable from project Dockerfiles too
    └── installTreeFromGithub.sh
template/.devcontainer/   # copied into a new project by devcon_init.sh
├── devcontainer.json
└── Dockerfile            # FROM mydevbox:latest
build.sh                  # builds mydevbox:latest and pins it against prunes
devcon_init.sh
```

## Build the base image
Needs a running ssh agent with access to the private dotfiles repo.
```sh
./build.sh
```
Rerun after changing anything under `base/`. Project containers keep their old
base until rebuilt with `devpod up --recreate <workspace>`.

The build leaves an idle `mydevbox-keep` container running. It holds a reference
to the image so a bare `docker image prune -a` cannot reclaim the base. It is
recreated on every build, so superseded bases stay prunable.

## Cleanup
Project images are thin layers over the base, so they cost almost nothing. The
standard commands are safe to run:
```sh
docker image prune -a          # base is pinned, so it survives
docker builder prune --keep-storage 10GB
```

## New project setup
1. Init default:
```sh
cd ~/my-new-project
bash ~/.devcontainer_setup/devcon_init.sh # replace this by an alias
```
2. Adjust `.devcontainer/devcontainer.json` / `.devcontainer/Dockerfile` to the
   project's needs
3. Run:
```sh
devpod up .
```
4. Manage container through devpod cli

## Developing this repo in a container
Run `devcon_init.sh` here like in any other project. The generated
`.devcontainer/` is gitignored, so local-only mounts can live in it.
