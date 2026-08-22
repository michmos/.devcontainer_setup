# mydevbox
Personal base dev image: nvim, tmux, zsh + dotfiles, claude, git, lazygit, fzf.
Project-specific images `FROM mydevbox:latest` and add their own deps.

## Structure
```
.devcontainer/
├── devcontainer.json    # build context ".." (repo root), runs setup.sh on create
├── Dockerfile            # base image
└── scripts/
    ├── setup.sh
    ├── installBinaryFromGithub.sh
    └── installTreeFromGithub.sh
devcon_init.sh            # copies .devcontainer/ into the cwd for a new project
```

## New project setup
1. Init default:
```sh
cd ~/my-new-project
bash ~/.mydevbox/devcon_init.sh # replace this by an alias
```
2. Adjust `.devcontainer/devcontainer.json` / `scripts/setup.sh` to the project's
needs
3. Run:
```sh
devpod up .
```
4. Manage container through devpod cli
