# dotfiles

Bootstrap script for setting up a new dev environment (e.g. RunPod).

## Usage

```bash
git clone https://github.com/AMindToThink/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

## What `setup.sh` does

1. **Git identity** — sets user to `AMindToThink`
2. **GitHub auth** — runs `gh auth login`
3. **Dotfiles** — symlinks `.tmux.conf` and `.gitconfig` into `~`, appends shell additions to `.bashrc`
4. **Secrets** — creates `~/.secrets.env` from template (fill in your API keys)
5. **Claude Code** — clones [claude-code-settings](https://github.com/AMindToThink/claude-code-settings) to `~/.claude`
6. **uv** — installs [uv](https://github.com/astral-sh/uv) for Python package management

## After setup

1. Fill in `~/.secrets.env` with your API keys
2. Run `source ~/.bashrc`
3. Verify with `git config user.name`
