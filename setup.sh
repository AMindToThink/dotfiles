#!/usr/bin/env bash
set -euo pipefail

echo "=== Matthew's RunPod Environment Setup ==="

# ---- Git identity ----
echo "[1/6] Configuring git..."
git config --global user.name "AMindToThink"
git config --global user.email "AMindToThink@users.noreply.github.com"
git config --global credential.helper store

# ---- GitHub auth ----
echo "[2/6] Authenticating with GitHub..."
if ! gh auth status &>/dev/null; then
    echo "  Logging in via gh CLI (will open browser or prompt for token)..."
    gh auth login --git-protocol https
else
    echo "  Already authenticated."
fi

# ---- Dotfiles ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[3/6] Installing dotfiles..."
ln -sf "$SCRIPT_DIR/.tmux.conf" ~/.tmux.conf
ln -sf "$SCRIPT_DIR/.gitconfig" ~/.gitconfig

# Append bashrc additions if not already present
if ! grep -q "Matthew's shell additions" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    cat "$SCRIPT_DIR/.bashrc_additions" >> ~/.bashrc
    echo "  Added shell additions to ~/.bashrc"
else
    echo "  Shell additions already in ~/.bashrc"
fi

# ---- Secrets ----
echo "[4/6] Setting up secrets..."
if [ ! -f ~/.secrets.env ]; then
    cp "$SCRIPT_DIR/secrets.env.template" ~/.secrets.env
    echo "  Created ~/.secrets.env from template — fill in your values!"
    echo "  Then run: source ~/.bashrc"
else
    echo "  ~/.secrets.env already exists"
fi

# ---- Claude Code settings ----
echo "[5/6] Setting up Claude Code..."
if [ ! -d ~/.claude/.git ]; then
    git clone https://github.com/AMindToThink/claude-code-settings.git ~/.claude
else
    echo "  ~/.claude repo already exists, pulling latest..."
    git -C ~/.claude pull
fi

# ---- uv ----
echo "[6/6] Installing uv..."
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "  uv installed. You may need to restart your shell or run: source ~/.bashrc"
else
    echo "  uv already installed."
fi

echo ""
echo "=== Done! ==="
echo "Next steps:"
echo "  1. Fill in ~/.secrets.env with your API keys"
echo "  2. Run: source ~/.bashrc"
echo "  3. Verify: git config user.name  (should be AMindToThink)"
