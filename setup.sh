#!/usr/bin/env bash
set -euo pipefail

echo "=== Matthew's RunPod Environment Setup ==="

# ---- System dependencies ----
echo "[1/7] Installing system dependencies..."
apt-get update -qq
apt-get install -y curl wget vim jq tmux

if ! command -v gh &>/dev/null; then
    mkdir -p -m 755 /etc/apt/keyrings
    out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg
    cat "$out" | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli-stable.list > /dev/null
    apt-get update -qq
    apt-get install -y gh
    echo "  gh CLI installed."
else
    echo "  gh CLI already installed."
fi

# ---- Git identity ----
echo "[2/7] Configuring git..."
git config --global user.name "AMindToThink"
git config --global user.email "AMindToThink@users.noreply.github.com"
git config --global credential.helper store

# ---- GitHub auth ----
echo "[3/7] Authenticating with GitHub..."
if ! gh auth status &>/dev/null; then
    echo "  Logging in via gh CLI (will open browser or prompt for token)..."
    gh auth login --git-protocol https
else
    echo "  Already authenticated."
fi

# ---- Dotfiles ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[4/7] Installing dotfiles..."
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
echo "[5/7] Setting up secrets..."
if [ ! -f ~/.secrets.env ]; then
    cp "$SCRIPT_DIR/secrets.env.template" ~/.secrets.env
    echo "  Created ~/.secrets.env from template — fill in your values!"
    echo "  Then run: source ~/.bashrc"
else
    echo "  ~/.secrets.env already exists"
fi

# ---- Claude Code settings ----
echo "[6/7] Setting up Claude Code..."
if [ ! -d ~/.claude/.git ]; then
    tmpdir=$(mktemp -d)
    git clone https://github.com/AMindToThink/claude-code-settings.git "$tmpdir"
    mkdir -p ~/.claude
    cp -a "$tmpdir"/. ~/.claude/
    rm -rf "$tmpdir"
    echo "  Claude Code settings cloned into ~/.claude (existing files preserved)."
else
    echo "  ~/.claude repo already exists, pulling latest..."
    git -C ~/.claude pull
fi

# ---- uv ----
echo "[7/7] Installing uv..."
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
