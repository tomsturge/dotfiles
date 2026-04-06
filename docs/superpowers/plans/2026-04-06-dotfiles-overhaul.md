# Dotfiles Overhaul Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Modernise the dotfiles repo with GNU Stow-based config management and a platform-aware bootstrap script.

**Architecture:** Each config (zsh, tmux, nvim, ghostty, git) lives in its own stow package directory mirroring `$HOME`. A single `install.sh` entry point detects the platform, installs tools, stows packages, and installs fonts. Dev-only extras (tmux autostart, Claude Code) are gated behind a `--dev` flag.

**Tech Stack:** GNU Stow, ZSH, Oh My Zsh, Powerlevel10k, tmux + TPM, Neovim, Ghostty, fnm, Homebrew (macOS), apt (Linux)

**Spec:** `docs/superpowers/specs/2026-04-06-dotfiles-overhaul-design.md`

---

## File Map

### New files to create

| File | Purpose |
|------|---------|
| `zsh/.zshrc` | Clean ZSH config |
| `p10k/.p10k.zsh` | Powerlevel10k config (copied from live) |
| `tmux/.tmux.conf` | Tmux config |
| `tmux-autostart/.local/bin/start_tmux.sh` | Dev-only tmux session startup |
| `nvim/.config/nvim/init.lua` | Neovim config with shiftround fix |
| `ghostty/.config/ghostty/config` | Catppuccin Mocha + FiraCode Nerd Font |
| `git/.gitconfig` | Cleaned git config |
| `Brewfile` | macOS Homebrew bundle |
| `fonts/FiraCodeNerdFont/Fira Code Nerd Font Regular.ttf` | Font file (copied from system) |
| `fonts/FiraCodeNerdFont/MesloLGS NF Bold from Powerlevel10k.ttf` | Font file (copied from system) |
| `scripts/install-tools.sh` | Platform-aware tool installation |
| `install.sh` | Bootstrap entry point |
| `.gitignore` | New repo gitignore |

### Files to remove

| File | Reason |
|------|--------|
| `.aliases` | Old employer shortcuts, macOS-specific |
| `.functions` | Sublime, Atom, Finder, Python 2 |
| `.oh-my-zsh/` | Installed fresh by script |
| `.vim/` | Replaced by nvim stow package |
| `.vimrc` | Replaced by nvim stow package |
| `.viminfo` | Runtime artefact |
| `.wgetrc` | Not needed |
| `.inputrc` | Not needed |
| `.p10k.zsh` (root) | Moves to `p10k/` |
| `.tmux.conf` (root) | Moves to `tmux/` |
| `.zshrc` (root) | Moves to `zsh/` |
| `.gitconfig` (root) | Moves to `git/` |
| `.gitignore` (root) | Replaced with new one |
| `bin/` | Replaced by `install.sh` + `scripts/` |
| `vscode/` | No longer used |

---

### Task 1: Clean the repo — remove old files

**Files:**
- Remove: `.aliases`, `.functions`, `.oh-my-zsh/`, `.vim/`, `.vimrc`, `.viminfo`, `.wgetrc`, `.inputrc`, `.p10k.zsh`, `.tmux.conf`, `.zshrc`, `.gitconfig`, `.gitignore`, `bin/`, `vscode/`
- Create: `.gitignore`

- [ ] **Step 1: Remove all old files**

```bash
cd ~/dotfiles
git rm .aliases .functions .vimrc .viminfo .wgetrc .inputrc .p10k.zsh .tmux.conf .zshrc .gitconfig .gitignore
git rm -r .oh-my-zsh/ .vim/ bin/ vscode/
```

- [ ] **Step 2: Create new `.gitignore`**

Create `.gitignore`:

```gitignore
.DS_Store
*.swp
*.swo
*~
.env
.env.*
```

- [ ] **Step 3: Commit**

```bash
git add .gitignore
git commit -m "chore: remove old configs and scaffold for stow-based structure"
```

---

### Task 2: Create the Neovim stow package

**Files:**
- Create: `nvim/.config/nvim/init.lua`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p ~/dotfiles/nvim/.config/nvim
```

- [ ] **Step 2: Create `nvim/.config/nvim/init.lua`**

```lua
-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs/indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.shiftround = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep some lines visible when scrolling
vim.opt.scrolloff = 8

-- System clipboard
vim.opt.clipboard = "unnamedplus"
```

- [ ] **Step 3: Verify stow dry-run**

```bash
cd ~/dotfiles && stow -n -v nvim
```

Expected: output shows it would create symlink `~/.config/nvim/init.lua` -> `dotfiles/nvim/.config/nvim/init.lua`. No errors.

- [ ] **Step 4: Commit**

```bash
git add nvim/
git commit -m "feat: add neovim stow package with fixed config"
```

---

### Task 3: Create the Git stow package

**Files:**
- Create: `git/.gitconfig`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p ~/dotfiles/git
```

- [ ] **Step 2: Create `git/.gitconfig`**

Cleaned version of the existing config. Editor set to `nvim`, pager set to `delta`, stale references removed.

```gitconfig
[user]
  name = Tom
  email = tomsturge+github@gmail.com

[core]
  editor = nvim
  pager = delta
  excludesfile = ~/.gitignore
  whitespace = space-before-tab,-indent-with-non-tab,trailing-space
  precomposeunicode = false

[interactive]
  diffFilter = delta --color-only

[delta]
  navigate = true
  side-by-side = true

[apply]
  whitespace = fix

[color]
  ui = auto

[color "branch"]
  current = yellow reverse
  local = yellow
  remote = green

[color "diff"]
  meta = yellow bold
  frag = magenta bold
  old = red
  new = green

[color "status"]
  added = yellow
  changed = green
  untracked = cyan

[help]
  autocorrect = 1

[merge]
  log = true
  conflictstyle = diff3

[push]
  default = current
  followTags = true

[diff]
  colorMoved = default
```

- [ ] **Step 3: Verify stow dry-run**

```bash
cd ~/dotfiles && stow -n -v git
```

Expected: would create symlink `~/.gitconfig` -> `dotfiles/git/.gitconfig`. No errors.

- [ ] **Step 4: Commit**

```bash
git add git/
git commit -m "feat: add git stow package with delta pager and nvim editor"
```

---

### Task 4: Create the Tmux stow package

**Files:**
- Create: `tmux/.tmux.conf`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p ~/dotfiles/tmux
```

- [ ] **Step 2: Create `tmux/.tmux.conf`**

```tmux
# Remap prefix to C-a
set -g prefix C-a
unbind C-b

# Vim-style pane navigation
bind -r h select-pane -L
bind -r j select-pane -D
bind -r k select-pane -U
bind -r l select-pane -R

# Start windows and panes at 1
set -g base-index 1
setw -g pane-base-index 1

# Mouse support
set -g mouse on

# No escape delay
set -sg escape-time 0

# True colour support
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"

# Reload config
bind r source-file ~/.tmux.conf \; display "Config reloaded"

# TPM plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Catppuccin
set -g @plugin 'catppuccin/tmux'
set -g @catppuccin_flavor 'mocha'

# Initialise TPM (keep at bottom)
run '~/.tmux/plugins/tpm/tpm'
```

- [ ] **Step 3: Verify stow dry-run**

```bash
cd ~/dotfiles && stow -n -v tmux
```

Expected: would create symlink `~/.tmux.conf` -> `dotfiles/tmux/.tmux.conf`. No errors.

- [ ] **Step 4: Commit**

```bash
git add tmux/
git commit -m "feat: add tmux stow package with catppuccin mocha and TPM"
```

---

### Task 5: Create the Tmux Autostart stow package

**Files:**
- Create: `tmux-autostart/.local/bin/start_tmux.sh`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p ~/dotfiles/tmux-autostart/.local/bin
```

- [ ] **Step 2: Create `tmux-autostart/.local/bin/start_tmux.sh`**

Copy the current live script from `~/start_tmux.sh`:

```bash
cp ~/start_tmux.sh ~/dotfiles/tmux-autostart/.local/bin/start_tmux.sh
chmod +x ~/dotfiles/tmux-autostart/.local/bin/start_tmux.sh
```

- [ ] **Step 3: Verify stow dry-run**

```bash
cd ~/dotfiles && stow -n -v tmux-autostart
```

Expected: would create symlink `~/.local/bin/start_tmux.sh`. No errors.

- [ ] **Step 4: Commit**

```bash
git add tmux-autostart/
git commit -m "feat: add tmux-autostart stow package (dev-only)"
```

---

### Task 6: Create the Ghostty stow package

**Files:**
- Create: `ghostty/.config/ghostty/config`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p ~/dotfiles/ghostty/.config/ghostty
```

- [ ] **Step 2: Create `ghostty/.config/ghostty/config`**

Catppuccin Mocha theme with FiraCode Nerd Font:

```
# Font
font-family = FiraCode Nerd Font
font-size = 14

# Catppuccin Mocha
background = 1e1e2e
foreground = cdd6f4
cursor-color = f5e0dc
selection-background = 45475a
selection-foreground = cdd6f4

# Black
palette = 0=#45475a
palette = 8=#585b70

# Red
palette = 1=#f38ba8
palette = 9=#f38ba8

# Green
palette = 2=#a6e3a1
palette = 10=#a6e3a1

# Yellow
palette = 3=#f9e2af
palette = 11=#f9e2af

# Blue
palette = 4=#89b4fa
palette = 12=#89b4fa

# Magenta
palette = 5=#f5c2e7
palette = 13=#f5c2e7

# Cyan
palette = 6=#94e2d5
palette = 14=#94e2d5

# White
palette = 7=#bac2de
palette = 15=#a6adc8
```

- [ ] **Step 3: Verify stow dry-run**

```bash
cd ~/dotfiles && stow -n -v ghostty
```

Expected: would create symlink `~/.config/ghostty/config`. No errors.

- [ ] **Step 4: Commit**

```bash
git add ghostty/
git commit -m "feat: add ghostty stow package with catppuccin mocha theme"
```

---

### Task 7: Create the P10k stow package

**Files:**
- Create: `p10k/.p10k.zsh`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p ~/dotfiles/p10k
```

- [ ] **Step 2: Copy live p10k config**

```bash
cp ~/.p10k.zsh ~/dotfiles/p10k/.p10k.zsh
```

- [ ] **Step 3: Verify stow dry-run**

```bash
cd ~/dotfiles && stow -n -v p10k
```

Expected: would create symlink `~/.p10k.zsh` -> `dotfiles/p10k/.p10k.zsh`. No errors.

- [ ] **Step 4: Commit**

```bash
git add p10k/
git commit -m "feat: add p10k stow package"
```

---

### Task 8: Create the ZSH stow package

**Files:**
- Create: `zsh/.zshrc`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p ~/dotfiles/zsh
```

- [ ] **Step 2: Create `zsh/.zshrc`**

```zsh
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source "$ZSH/oh-my-zsh.sh"

# Powerlevel10k
source ~/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# PATH
export PATH="$HOME/.local/bin:$PATH"

# fnm
if [ -d "$HOME/.local/share/fnm" ]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
fi
if command -v fnm &> /dev/null; then
  eval "$(fnm env)"
fi

# bat (aliased as cat)
alias cat='bat --paging=never'

# eza (aliased as ls)
alias ls='eza --icons --group-directories-first'
alias ll='eza --icons --group-directories-first -la'
alias la='eza --icons --group-directories-first -a'

# fzf
if command -v fzf &> /dev/null; then
  source <(fzf --zsh 2>/dev/null) || true
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# zoxide
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# Default working directory
[[ -d ~/repos ]] || mkdir -p ~/repos
cd ~/repos

# Tmux autostart (only if start_tmux.sh is present — deployed via --dev)
if command -v tmux &> /dev/null && [ -z "$TMUX" ] && [ -x "$HOME/.local/bin/start_tmux.sh" ]; then
  "$HOME/.local/bin/start_tmux.sh"
fi
```

- [ ] **Step 3: Verify stow dry-run**

```bash
cd ~/dotfiles && stow -n -v zsh
```

Expected: would create symlink `~/.zshrc` -> `dotfiles/zsh/.zshrc`. No errors.

- [ ] **Step 4: Commit**

```bash
git add zsh/
git commit -m "feat: add zsh stow package with modern tool aliases"
```

---

### Task 9: Bundle fonts

**Files:**
- Create: `fonts/FiraCodeNerdFont/Fira Code Nerd Font Regular.ttf`
- Create: `fonts/FiraCodeNerdFont/MesloLGS NF Bold from Powerlevel10k.ttf`

- [ ] **Step 1: Create directory and copy fonts**

```bash
mkdir -p ~/dotfiles/fonts/FiraCodeNerdFont
cp ~/.local/share/fonts/"Fira Code Nerd Font Regular.ttf" ~/dotfiles/fonts/FiraCodeNerdFont/
cp ~/.local/share/fonts/"MesloLGS NF Bold from Powerlevel10k.ttf" ~/dotfiles/fonts/FiraCodeNerdFont/
```

- [ ] **Step 2: Commit**

```bash
git add fonts/
git commit -m "feat: bundle FiraCode Nerd Font and MesloLGS NF"
```

---

### Task 10: Create the Brewfile

**Files:**
- Create: `Brewfile`

- [ ] **Step 1: Create `Brewfile`**

```ruby
# CLI tools
brew "stow"
brew "tmux"
brew "neovim"
brew "fnm"
brew "bat"
brew "fzf"
brew "ripgrep"
brew "eza"
brew "jq"
brew "htop"
brew "tree"
brew "wget"
brew "curl"
brew "tldr"
brew "fd"
brew "zoxide"
brew "lazygit"
brew "git-delta"

# GUI apps
cask "ghostty"
cask "1password"
cask "1password-cli"
cask "raycast"
cask "slack"
cask "obsidian"
```

- [ ] **Step 2: Commit**

```bash
git add Brewfile
git commit -m "feat: add Brewfile for macOS tool installation"
```

---

### Task 11: Create the tool installation script

**Files:**
- Create: `scripts/install-tools.sh`

- [ ] **Step 1: Create directory**

```bash
mkdir -p ~/dotfiles/scripts
```

- [ ] **Step 2: Create `scripts/install-tools.sh`**

```bash
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
    local delta_deb="git-delta_${delta_version}_amd64.deb"
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
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
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
```

- [ ] **Step 3: Make executable**

```bash
chmod +x ~/dotfiles/scripts/install-tools.sh
```

- [ ] **Step 4: Commit**

```bash
git add scripts/
git commit -m "feat: add platform-aware tool installation script"
```

---

### Task 12: Create the bootstrap entry point

**Files:**
- Create: `install.sh`

- [ ] **Step 1: Create `install.sh`**

```bash
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
```

- [ ] **Step 2: Make executable**

```bash
chmod +x ~/dotfiles/install.sh
```

- [ ] **Step 3: Verify the script parses correctly**

```bash
bash -n ~/dotfiles/install.sh
```

Expected: no output (no syntax errors).

- [ ] **Step 4: Commit**

```bash
git add install.sh
git commit -m "feat: add bootstrap install.sh entry point"
```

---

### Task 13: Verify end-to-end with stow dry-run

- [ ] **Step 1: Dry-run all stow packages**

```bash
cd ~/dotfiles
for pkg in zsh p10k tmux nvim ghostty git; do
  echo "--- $pkg ---"
  stow -n -v "$pkg" 2>&1
done
```

Expected: each package shows the symlink it would create. No `CONFLICT` errors. If there are conflicts (existing non-symlink files), back them up first:

```bash
# Example for a conflict with ~/.zshrc:
mv ~/.zshrc ~/.zshrc.bak
```

- [ ] **Step 2: Dry-run dev package**

```bash
stow -n -v tmux-autostart 2>&1
```

Expected: would create `~/.local/bin/start_tmux.sh` symlink.

- [ ] **Step 3: Final commit (if any fixups needed)**

```bash
git add -A
git commit -m "fix: resolve any stow conflicts or path issues"
```

Only commit if changes were needed. Otherwise skip.
