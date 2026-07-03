# dotfiles

Bootstrap script for Matthew's dev environment — works on both RunPod pods and regular machines.

## Key concept

On RunPod, `/root` (home) is **ephemeral** — wiped on pod restart. `/workspace` is **persistent**. On a regular machine, `$HOME` already persists across restarts, so there's nothing to work around.

`setup.sh` and `apply.sh` detect which situation they're in (`[ -d /workspace ]`) and behave accordingly — see `lib.sh`:

- **RunPod mode** (`/workspace` exists): unchanged from before. Repo should live at `/workspace/dotfiles`; secrets and Claude Code settings live in `/workspace` and get symlinked into ephemeral `$HOME` on every restart.
- **Local mode** (no `/workspace`): the repo can live anywhere (e.g. `~/dotfiles`); secrets and Claude Code settings are just placed directly in `$HOME`, no symlink layer needed. `setup.sh` never touches an existing `~/.claude` — it only bootstraps it from [claude-code-settings](https://github.com/AMindToThink/claude-code-settings) on a genuinely fresh machine where `~/.claude` doesn't exist yet.

## First-time setup

**RunPod:**

```bash
git clone https://github.com/AMindToThink/dotfiles.git /workspace/dotfiles
cd /workspace/dotfiles
./setup.sh
```

**Regular machine:**

```bash
git clone https://github.com/AMindToThink/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

`setup.sh` installs system packages via `apt-get`/`sudo`, so run it yourself in a real interactive terminal (not through an automated agent) if your account isn't root — it needs a tty to prompt for your sudo password. If it can't get sudo access non-interactively, it'll tell you to run `sudo -v` first and re-run.

## Pod restarts

Set your RunPod **start command** to:

```
bash /workspace/dotfiles/apply.sh
```

This re-creates symlinks and bashrc additions in the ephemeral `/root` on each restart. Not needed on a regular machine, since nothing gets wiped — but safe to re-run any time (idempotent).

## What `setup.sh` does

1. **System deps** — installs curl, wget, vim, jq, tmux, gh CLI
2. **Git identity** — sets user to `AMindToThink`
3. **GitHub auth** — runs `gh auth login`
4. **Dotfiles** — runs `apply.sh` (symlinks configs, appends bashrc additions)
5. **Secrets** — creates `.secrets.env` from template (fill in your API keys)
6. **Claude Code** — clones [claude-code-settings](https://github.com/AMindToThink/claude-code-settings) into `~/.claude` (RunPod: via `/workspace/.claude` symlink; local: directly, only if `~/.claude` doesn't already exist)
7. **uv** — installs [uv](https://github.com/astral-sh/uv) for Python package management

## What `apply.sh` does (fast, runs on every restart)

- Symlinks `.tmux.conf`, `.gitconfig` from the dotfiles repo → `~`
- RunPod mode only: symlinks `/workspace/.secrets.env` → `~/.secrets.env` and `/workspace/.claude` → `~/.claude`
- Appends shell additions to `~/.bashrc` (if not already present)
- Sets git global identity

## Persistent storage layout (RunPod mode)

```
/workspace/
├── dotfiles/          # this repo
├── .secrets.env       # your API keys (gitignored, persistent)
└── .claude/           # Claude Code settings repo (persistent)
```

On a regular machine, `.secrets.env` and `.claude` just live directly under `~`.

## After setup

1. Fill in `.secrets.env` (`/workspace/.secrets.env` on RunPod, `~/.secrets.env` locally) with your API keys
2. Run `source ~/.bashrc`
3. Verify with `git config user.name`
