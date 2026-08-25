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
build.sh                  # builds mydevbox:latest
devcon_init.sh
```

## Build the base image
Needs a running ssh agent with access to the private dotfiles repo.
```sh
./build.sh
```
Rerun after changing anything under `base/`. Project containers keep their old
base until rebuilt with `devpod up --recreate <workspace>`.

Project devcontainers run this with `--if-missing` from `initializeCommand`, so
`devpod up` builds the base on demand when it is absent.

## Cleanup
Project images are thin layers over the base, so they cost almost nothing.
```sh
docker image prune -a
```
This may drop the base image or just its tag. That is fine: a rerun of
`build.sh` restores it from the build cache in a few seconds.

The build cache is what makes that cheap, so prune it deliberately rather than
by habit - afterwards the base needs a full cold rebuild and a loaded ssh agent.
```sh
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
