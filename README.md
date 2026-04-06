# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```bash
git clone git@github.com:tomsturge/dotfiles.git ~/repos/dotfiles
cd ~/repos/dotfiles
./install.sh        # Standard setup
./install.sh --dev  # Dev environment (adds tmux autostart + Claude Code)
```

## What It Does

1. **Installs tools** — Homebrew + Brewfile on macOS, apt + install scripts on Linux
2. **Symlinks configs** — Stow creates symlinks from `$HOME` into this repo
3. **Installs fonts** — FiraCode Nerd Font + MesloLGS NF
4. **Sets zsh as default shell**

Editing files in this repo updates your live config — they're the same file via symlink.

## Stow Packages

| Package | Config | Target |
|---------|--------|--------|
| `zsh` | `.zshrc` | `~/.zshrc` |
| `p10k` | `.p10k.zsh` | `~/.p10k.zsh` |
| `tmux` | `.tmux.conf` | `~/.tmux.conf` |
| `nvim` | `.config/nvim/init.lua` | `~/.config/nvim/init.lua` |
| `ghostty` | `.config/ghostty/config` | `~/.config/ghostty/config` |
| `git` | `.gitconfig` | `~/.gitconfig` |

### Dev-only

| Package | Config | Target |
|---------|--------|--------|
| `tmux-autostart` | `.local/bin/start_tmux.sh` | `~/.local/bin/start_tmux.sh` |

## Tools Installed

### CLI (both platforms)

stow, tmux, neovim, fnm, bat, fzf, ripgrep, eza, jq, htop, tree, wget, curl, tldr, fd, zoxide, lazygit, git-delta

Plus: Oh My Zsh, Powerlevel10k, TPM, zsh-syntax-highlighting, zsh-autosuggestions

### macOS Casks

Ghostty, 1Password, 1Password CLI, Raycast, Slack, Obsidian

### Dev-only

Claude Code CLI

## Shell Aliases

| Alias | Command |
|-------|---------|
| `cat` | `bat --paging=never` |
| `ls` | `eza --icons --group-directories-first` |
| `ll` | `eza --icons --group-directories-first -la` |
| `la` | `eza --icons --group-directories-first -a` |
| `z` | `zoxide` (smart cd) |

## Theme

Catppuccin Mocha across Ghostty and tmux. FiraCode Nerd Font at 14pt.

## Re-running

The install script is idempotent — safe to run again. It skips anything already installed and uses `stow --adopt` to handle existing config files.
