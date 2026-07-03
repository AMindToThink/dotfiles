# Shared environment detection for setup.sh and apply.sh.
# Source this, don't execute it: `source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"`

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# RunPod containers run as root with ephemeral $HOME and persistent /workspace.
# Regular machines have neither trait: $HOME already persists across restarts.
if [ -d /workspace ]; then
    IS_RUNPOD=true
    WORKSPACE="/workspace"
else
    IS_RUNPOD=false
    WORKSPACE="$HOME"
fi

# Call this before any command that needs root (apt-get, writes under /etc).
# Not called unconditionally at source-time: scripts that never touch the
# system package manager (e.g. apply.sh) shouldn't be forced through it.
require_sudo() {
    if [ "$EUID" -eq 0 ]; then
        SUDO=""
    elif sudo -n true 2>/dev/null; then
        SUDO="sudo"
    else
        echo "This script needs sudo to install system packages, and no cached/passwordless"
        echo "sudo access is available. Run this yourself in an interactive terminal, then re-run:"
        echo "  sudo -v"
        echo "  bash $DOTFILES/setup.sh"
        exit 1
    fi
}
