#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OS="$(uname -s)"

info() { printf "\033[0;34m[info]\033[0m %s\n" "$1"; }
ok()   { printf "\033[0;32m[ok]\033[0m   %s\n" "$1"; }
warn() { printf "\033[0;33m[warn]\033[0m %s\n" "$1"; }

# ─── Platform-specific package installation ──────────────────────────────────

install_macos() {
  if ! command -v brew &> /dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    ok "Homebrew already installed"
  fi

  info "Running brew bundle..."
  brew bundle --file="$DOTFILES_DIR/Brewfile"
  ok "Brew bundle complete"
}

install_linux() {
  info "Updating apt..."
  sudo apt update -y

  local apt_packages=(
    stow zsh tmux neovim bat fzf ripgrep jq htop tree wget curl fd-find
  )

  info "Installing apt packages..."
  sudo apt install -y "${apt_packages[@]}"
  ok "apt packages installed"

  # bat -> batcat symlink on Debian/Ubuntu
  if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
    ok "Created bat symlink for batcat"
  fi

  # fd -> fdfind symlink on Debian/Ubuntu
  if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
    ok "Created fd symlink for fdfind"
  fi

  # eza
  if ! command -v eza &> /dev/null; then
    info "Installing eza..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo apt update && sudo apt install -y eza
    ok "eza installed"
  else
    ok "eza already installed"
  fi

  # fnm
  if ! command -v fnm &> /dev/null; then
    info "Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    ok "fnm installed"
  else
    ok "fnm already installed"
  fi

  # zoxide
  if ! command -v zoxide &> /dev/null; then
    info "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    ok "zoxide installed"
  else
    ok "zoxide already installed"
  fi

  # delta
  if ! command -v delta &> /dev/null; then
    info "Installing git-delta..."
    local delta_version="0.18.2"
    local arch
    arch="$(dpkg --print-architecture)"
    local delta_deb="git-delta_${delta_version}_${arch}.deb"
    wget -q "https://github.com/dandavison/delta/releases/download/${delta_version}/${delta_deb}" -O "/tmp/${delta_deb}"
    sudo dpkg -i "/tmp/${delta_deb}"
    rm -f "/tmp/${delta_deb}"
    ok "git-delta installed"
  else
    ok "git-delta already installed"
  fi

  # lazygit
  if ! command -v lazygit &> /dev/null; then
    info "Installing lazygit..."
    local lazygit_arch
    case "$(uname -m)" in
      x86_64)  lazygit_arch="x86_64" ;;
      aarch64) lazygit_arch="arm64" ;;
      *)       lazygit_arch="$(uname -m)" ;;
    esac
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${lazygit_arch}.tar.gz"
    sudo tar xf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit
    rm -f /tmp/lazygit.tar.gz
    ok "lazygit installed"
  else
    ok "lazygit already installed"
  fi

  # tldr (via npm once fnm is available)
  if ! command -v tldr &> /dev/null; then
    if command -v fnm &> /dev/null; then
      eval "$(fnm env)"
      if command -v node &> /dev/null; then
        info "Installing tldr..."
        npm install -g tldr
        ok "tldr installed"
      else
        warn "Node not installed via fnm — skipping tldr. Run 'fnm install --lts' then 'npm i -g tldr'"
      fi
    fi
  else
    ok "tldr already installed"
  fi
}

# ─── Cross-platform installations ────────────────────────────────────────────

install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    ok "Oh My Zsh installed"
  else
    ok "Oh My Zsh already installed"
  fi
}

install_zsh_plugins() {
  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [ ! -d "$custom/plugins/zsh-syntax-highlighting" ]; then
    info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom/plugins/zsh-syntax-highlighting"
    ok "zsh-syntax-highlighting installed"
  else
    ok "zsh-syntax-highlighting already installed"
  fi

  if [ ! -d "$custom/plugins/zsh-autosuggestions" ]; then
    info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$custom/plugins/zsh-autosuggestions"
    ok "zsh-autosuggestions installed"
  else
    ok "zsh-autosuggestions already installed"
  fi
}

install_powerlevel10k() {
  if [ ! -d "$HOME/powerlevel10k" ]; then
    info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"
    ok "Powerlevel10k installed"
  else
    ok "Powerlevel10k already installed"
  fi
}

install_tpm() {
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    info "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    ok "TPM installed"
  else
    ok "TPM already installed"
  fi
}

# ─── Dev-only installations ──────────────────────────────────────────────────

install_claude_code() {
  if ! command -v claude &> /dev/null; then
    info "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | sh
    ok "Claude Code installed"
  else
    ok "Claude Code already installed"
  fi
}

# ─── Main ────────────────────────────────────────────────────────────────────

main() {
  local dev_mode=false
  for arg in "$@"; do
    case "$arg" in
      --dev) dev_mode=true ;;
    esac
  done

  info "Detected OS: $OS"

  case "$OS" in
    Darwin) install_macos ;;
    Linux)  install_linux ;;
    *)      warn "Unsupported OS: $OS"; exit 1 ;;
  esac

  install_oh_my_zsh
  install_zsh_plugins
  install_powerlevel10k
  install_tpm

  if [ "$dev_mode" = true ]; then
    install_claude_code
  fi

  ok "Tool installation complete"
}

main "$@"
