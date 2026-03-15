#!/usr/bin/env bash
# Lightweight re-apply script for RunPod pod restarts.
# Recreates symlinks and bashrc additions that live in ephemeral /root.
# Add to your RunPod start command: bash /workspace/dotfiles/apply.sh
set -euo pipefail

WORKSPACE="/workspace"
DOTFILES="$WORKSPACE/dotfiles"

echo "Applying dotfiles from $DOTFILES..."

# Config symlinks
ln -sf "$DOTFILES/.tmux.conf" ~/.tmux.conf
ln -sf "$DOTFILES/.gitconfig" ~/.gitconfig

# Secrets symlink (points to persistent location)
if [ -f "$WORKSPACE/.secrets.env" ]; then
    ln -sf "$WORKSPACE/.secrets.env" ~/.secrets.env
fi

# Claude Code settings symlink
if [ -d "$WORKSPACE/.claude" ]; then
    ln -sfn "$WORKSPACE/.claude" ~/.claude
fi

# Append bashrc additions if not already present
if ! grep -q "Matthew's shell additions" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    cat "$DOTFILES/.bashrc_additions" >> ~/.bashrc
    echo "  Added shell additions to ~/.bashrc"
else
    echo "  Shell additions already in ~/.bashrc"
fi

# Re-apply git identity (stored in ephemeral ~/.gitconfig.local or global)
git config --global user.name "AMindToThink"
git config --global user.email "AMindToThink@users.noreply.github.com"
git config --global credential.helper store

echo "Dotfiles applied. Run: source ~/.bashrc"
