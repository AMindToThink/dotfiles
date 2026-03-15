# dotfiles

Bootstrap script for setting up a new RunPod dev environment with persistent storage.

## Key concept

On RunPod, `/root` (home) is **ephemeral** — wiped on pod restart. `/workspace` is **persistent**. This repo is designed to live in `/workspace/dotfiles` so your config survives restarts.

## First-time setup

```bash
git clone https://github.com/AMindToThink/dotfiles.git /workspace/dotfiles
cd /workspace/dotfiles
./setup.sh
```

## Pod restarts

Set your RunPod **start command** to:

```
bash /workspace/dotfiles/apply.sh
```

This re-creates symlinks and bashrc additions in the ephemeral `/root` on each restart.

## What `setup.sh` does

1. **System deps** — installs curl, wget, vim, jq, tmux, gh CLI
2. **Git identity** — sets user to `AMindToThink`
3. **GitHub auth** — runs `gh auth login`
4. **Dotfiles** — runs `apply.sh` (symlinks configs, appends bashrc additions)
5. **Secrets** — creates `/workspace/.secrets.env` from template (fill in your API keys)
6. **Claude Code** — clones [claude-code-settings](https://github.com/AMindToThink/claude-code-settings) to `/workspace/.claude`
7. **uv** — installs [uv](https://github.com/astral-sh/uv) for Python package management

## What `apply.sh` does (fast, runs on every restart)

- Symlinks `.tmux.conf`, `.gitconfig` from `/workspace/dotfiles` → `~`
- Symlinks `/workspace/.secrets.env` → `~/.secrets.env`
- Symlinks `/workspace/.claude` → `~/.claude`
- Appends shell additions to `~/.bashrc` (if not already present)
- Sets git global identity

## Persistent storage layout

```
/workspace/
├── dotfiles/          # this repo
├── .secrets.env       # your API keys (gitignored, persistent)
└── .claude/           # Claude Code settings repo (persistent)
```

## After setup

1. Fill in `/workspace/.secrets.env` with your API keys
2. Run `source ~/.bashrc`
3. Verify with `git config user.name`
