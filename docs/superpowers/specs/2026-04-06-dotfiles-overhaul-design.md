# Dotfiles Overhaul — Design Spec

## Overview

Modernise the dotfiles repo with GNU Stow-based config management and a platform-aware bootstrap script that installs all tooling and symlinks configs. Supports macOS (daily driver) and Linux (dev environment), with an optional `--dev` flag for dev-only extras.

## Repository Structure

```
dotfiles/
├── install.sh                          # Entry point
├── scripts/
│   └── install-tools.sh                # Platform-aware tool installation
├── zsh/
│   └── .zshrc                          # Clean ZSH config
├── p10k/
│   └── .p10k.zsh                       # Powerlevel10k config
├── tmux/
│   └── .tmux.conf                      # Tmux config
├── tmux-autostart/
│   └── .local/
│       └── bin/
│           └── start_tmux.sh           # Tmux session startup script
├── nvim/
│   └── .config/
│       └── nvim/
│           └── init.lua                # Neovim config (shiftround fix)
├── ghostty/
│   └── .config/
│       └── ghostty/
│           └── config                  # Catppuccin Mocha + FiraCode Nerd Font
├── git/
│   └── .gitconfig                      # Git config (cleaned up)
├── Brewfile                            # macOS Homebrew bundle (CLI + casks)
├── fonts/
│   └── FiraCodeNerdFont/               # Font files for install
└── docs/
    └── superpowers/
        └── specs/
            └── 2026-04-06-dotfiles-overhaul-design.md
```

Each top-level directory (except `scripts/`, `fonts/`, `docs/`) is a **GNU Stow package**. Contents mirror the target `$HOME` structure. Stow creates symlinks from `$HOME` pointing back into the repo.

## Bootstrap: `install.sh`

Single entry point. Usage:

```bash
git clone <repo> ~/dotfiles && cd ~/dotfiles && ./install.sh [--dev]
```

### Steps

1. **Detect platform** — `uname -s` to distinguish macOS from Linux.
2. **Install tools** — delegates to `scripts/install-tools.sh`.
3. **Stow standard packages** — `zsh`, `p10k`, `tmux`, `nvim`, `ghostty`, `git`.
4. **Install fonts** — copies FiraCode Nerd Font to the platform-appropriate font directory.
5. **If `--dev` flag is passed:**
   - Stow `tmux-autostart` package.
   - Install Claude Code CLI via the official native installer.

6. **Set zsh as default shell** — `chsh -s $(which zsh)` if not already the login shell.

All steps are **idempotent** — safe to re-run. Tools/clones/symlinks are skipped if already present.

## Tool Installation: `scripts/install-tools.sh`

### macOS: Brewfile

On macOS, after Homebrew is installed, the script runs `brew bundle --file=Brewfile`. The Brewfile contains:

**Formulae (CLI):**
`stow`, `tmux`, `neovim`, `fnm`, `bat`, `fzf`, `ripgrep`, `eza`, `jq`, `htop`, `tree`, `wget`, `curl`, `tldr`, `fd`, `zoxide`, `lazygit`, `git-delta`

**Casks (GUI):**
`ghostty`, `1password`, `1password-cli`, `raycast`, `slack`, `obsidian`

### Linux (apt + install scripts)

| Tool       | Method                                     |
|------------|--------------------------------------------|
| stow       | `sudo apt install stow`                    |
| zsh        | `sudo apt install zsh`                     |
| tmux       | `sudo apt install tmux`                    |
| neovim     | `sudo apt install neovim`                  |
| fnm        | Official install script                    |
| bat        | `sudo apt install bat`                     |
| fzf        | `sudo apt install fzf`                     |
| ripgrep    | `sudo apt install ripgrep`                 |
| eza        | `sudo apt install eza` (or cargo)          |
| jq         | `sudo apt install jq`                      |
| htop       | `sudo apt install htop`                    |
| tree       | `sudo apt install tree`                    |
| fd         | `sudo apt install fd-find`                 |
| zoxide     | Official install script                    |
| tldr       | `npm install -g tldr` (via fnm)            |
| delta      | `sudo apt install git-delta`               |
| lazygit    | Official install script                    |
| wget/curl  | `sudo apt install wget curl`               |
| Ghostty    | Official install / package manager         |

### Cross-platform (both)

| Tool                    | Method                                                        |
|-------------------------|---------------------------------------------------------------|
| Oh My Zsh               | Official install script (`--unattended`) if `~/.oh-my-zsh` missing |
| Powerlevel10k           | `git clone` to `~/powerlevel10k` if missing                   |
| TPM (tmux plugin mgr)   | `git clone` to `~/.tmux/plugins/tpm` if missing              |
| zsh-syntax-highlighting | `git clone` to `$ZSH_CUSTOM/plugins/` if missing             |
| zsh-autosuggestions     | `git clone` to `$ZSH_CUSTOM/plugins/` if missing             |

### Dev-only (`--dev`)

| Tool        | Method                          |
|-------------|---------------------------------|
| Claude Code | Official native installer       |

## Config Details

### ZSH (`.zshrc`)

Based on the current live config, cleaned up:

- P10k instant prompt block at the top
- `$ZSH` export, theme set to `robbyrussell` (overridden by p10k source below)
- Plugins: `git`, `zsh-syntax-highlighting`, `zsh-autosuggestions`
- Source Oh My Zsh
- Source Powerlevel10k theme (once, not duplicated)
- Source `.p10k.zsh`
- fnm setup (platform-aware path)
- `$EDITOR` and `$VISUAL` set to `nvim`
- Alias: `cat` mapped to `bat` (with `--paging=never` to preserve cat-like behaviour). On Debian/Ubuntu where the binary is `batcat`, create a `~/.local/bin/bat` symlink pointing to `batcat` so the alias works uniformly.
- Alias: `ls` mapped to `eza` (with `--icons --group-directories-first`)
- `eval "$(zoxide init zsh)"` — provides `z` as a smart `cd`
- `fzf` key bindings and completion sourced; uses `fd` as default finder (`FZF_DEFAULT_COMMAND`)
- `$HOME/.local/bin` on `$PATH`
- Default working directory: `cd ~/repos` (creates if missing)
- **No** tmux autostart in `.zshrc` — that lives in `tmux-autostart` package

### Tmux (`.tmux.conf`)

From the current live config:

- Prefix remapped to `C-a`
- Vim-style pane navigation (`hjkl`)
- Base index 1
- Mouse on
- Escape time 0
- TPM plugin block at the bottom

### Tmux Autostart (`start_tmux.sh`)

From the current live `~/start_tmux.sh`:

- Creates a `main` session with a 3-pane layout
- Displays IP info and SSH connection details (ASCII art banner)
- Idempotent — attaches to existing session if present
- Deployed to `~/.local/bin/start_tmux.sh`
- Only stowed with `--dev` flag
- Invoked from a small snippet added to `.zshrc` conditionally — **note:** since `.zshrc` is a single stow package, the autostart check will look for `~/.local/bin/start_tmux.sh` and only run it if present, making the behaviour conditional on whether `tmux-autostart` is stowed without needing two separate `.zshrc` files.

### Neovim (`init.lua`)

From the current live config with the bug fix:

- Line numbers (absolute + relative)
- Tabs: 2 spaces, expandtab
- `shiftround = true` (fixed from `shiftaround`)
- Smart case search
- Scroll offset of 8
- System clipboard integration

### Ghostty Config

Catppuccin Mocha theme defined inline:

- `font-family = FiraCode Nerd Font`
- `font-size = 14`
- Full Catppuccin Mocha colour palette (base, mantle, crust, surface, overlay, text, subtext, and accent colours mapped to Ghostty's `palette` and `background`/`foreground` settings)

### Git (`.gitconfig`)

Cleaned from the existing repo version:

- User name/email preserved
- Core settings (editor set to `nvim`, pager, autocrlf)
- Diff/merge tool settings
- Useful aliases (if any exist in current config)
- Remove any stale references

### Fonts

FiraCode Nerd Font files stored in `fonts/FiraCodeNerdFont/`.

Install target:
- **Linux:** `~/.local/share/fonts/` + `fc-cache -fv`
- **macOS:** `~/Library/Fonts/`

## What Gets Removed

The following files/directories are deleted from the repo:

- `.aliases` — old employer shortcuts, macOS-specific bits
- `.functions` — Sublime, Atom, Finder, Python 2 references
- `.oh-my-zsh/` — installed fresh by the script
- `.vim/` — replaced by nvim stow package
- `.vimrc` — replaced by nvim stow package
- `.viminfo` — runtime artefact, should never have been committed
- `.wgetrc` — not needed
- `.inputrc` — not needed
- `.p10k.zsh` (at repo root) — moves into `p10k/` stow package
- `.tmux.conf` (at repo root) — moves into `tmux/` stow package
- `.zshrc` (at repo root) — moves into `zsh/` stow package
- `.gitconfig` (at repo root) — moves into `git/` stow package
- `.gitignore` (at repo root) — replaced with a new one ignoring `.DS_Store`, `*.swp`, `.env`, and other common artefacts
- `bin/` — `bootstrap.sh`, `setup.js`, `subl`, `utilites.sh` all replaced by `install.sh`
- `vscode/` — no longer used

## Edge Cases

- **Re-running `install.sh`**: All operations check before acting. Stow warns on conflicts but does not overwrite non-symlinked files — the user must back up or remove conflicting files manually.
- **Switching from non-dev to dev**: Run `install.sh --dev` again; it stows the extra package and installs Claude Code.
- **No sudo on macOS**: Homebrew handles its own permissions. No `sudo` needed for stow or config linking.
- **Existing oh-my-zsh install**: Skipped if `~/.oh-my-zsh` exists.
