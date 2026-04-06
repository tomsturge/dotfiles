#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

info() { printf "\033[0;34m[info]\033[0m %s\n" "$1"; }
ok()   { printf "\033[0;32m[ok]\033[0m   %s\n" "$1"; }

# ─── Parse flags ─────────────────────────────────────────────────────────────

DEV_MODE=false
for arg in "$@"; do
  case "$arg" in
    --dev) DEV_MODE=true ;;
  esac
done

# ─── Step 1: Install tools ──────────────────────────────────────────────────

info "Installing tools..."
bash "$DOTFILES_DIR/scripts/install-tools.sh" "$@"

# ─── Step 2: Stow packages ──────────────────────────────────────────────────

STOW_PACKAGES=(zsh p10k tmux nvim ghostty git)

info "Stowing config packages..."
for pkg in "${STOW_PACKAGES[@]}"; do
  info "Stowing $pkg..."
  stow -d "$DOTFILES_DIR" -t "$HOME" --adopt "$pkg"
done
ok "Standard packages stowed"

if [ "$DEV_MODE" = true ]; then
  info "Stowing dev-only packages..."
  stow -d "$DOTFILES_DIR" -t "$HOME" --adopt tmux-autostart
  ok "Dev packages stowed"
fi

# After --adopt, restore repo versions over any adopted local files
info "Restoring repo config versions..."
stow -d "$DOTFILES_DIR" -t "$HOME" -R "${STOW_PACKAGES[@]}"
if [ "$DEV_MODE" = true ]; then
  stow -d "$DOTFILES_DIR" -t "$HOME" -R tmux-autostart
fi

# ─── Step 3: Install fonts ──────────────────────────────────────────────────

info "Installing fonts..."
case "$OS" in
  Darwin)
    FONT_DIR="$HOME/Library/Fonts"
    ;;
  Linux)
    FONT_DIR="$HOME/.local/share/fonts"
    ;;
esac

mkdir -p "$FONT_DIR"
cp -n "$DOTFILES_DIR/fonts/FiraCodeNerdFont/"*.ttf "$FONT_DIR/" 2>/dev/null || true

if [ "$OS" = "Linux" ]; then
  fc-cache -fv > /dev/null 2>&1
fi
ok "Fonts installed"

# ─── Step 4: Set default shell ──────────────────────────────────────────────

ZSH_PATH="$(which zsh)"
if [ "$SHELL" != "$ZSH_PATH" ]; then
  info "Setting zsh as default shell..."
  chsh -s "$ZSH_PATH"
  ok "Default shell set to zsh"
else
  ok "zsh is already the default shell"
fi

# ─── Done ────────────────────────────────────────────────────────────────────

echo ""
ok "Dotfiles installation complete!"
if [ "$DEV_MODE" = true ]; then
  ok "Dev mode enabled (tmux autostart + Claude Code)"
fi
echo ""
info "Restart your terminal or run: exec zsh"
