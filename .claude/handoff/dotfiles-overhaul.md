# Dotfiles Overhaul — Handoff Status

**Date:** 2026-04-06
**Status:** Implementation complete, needs post-install verification

## What Was Done

Full overhaul of the dotfiles repo from flat config files to GNU Stow-based structure. All files created, scripts working, install.sh runs end-to-end.

### Files in repo

```
.gitignore, README.md, Brewfile, install.sh, scripts/install-tools.sh
zsh/.zshrc, p10k/.p10k.zsh, tmux/.tmux.conf, nvim/.config/nvim/init.lua
ghostty/.config/ghostty/config, git/.gitconfig
tmux-autostart/.local/bin/start_tmux.sh
fonts/FiraCodeNerdFont/ (2 ttf files)
docs/superpowers/specs/2026-04-06-dotfiles-overhaul-design.md
docs/superpowers/plans/2026-04-06-dotfiles-overhaul.md
```

## Known Issue: ZSH config not applying after install

The user ran `install.sh --dev` but the shell is still showing the old Oh My Zsh default setup rather than the clean `.zshrc` from the repo.

### Likely cause

Oh My Zsh's `--unattended` install creates its own `.zshrc`, which conflicts with stow. The `--adopt` + `-R` restow flow in `install.sh` should handle this, but may not be working correctly. On the new session, verify:

1. **Is `~/.zshrc` a symlink?** `ls -la ~/.zshrc` — should point to `~/repos/dotfiles/zsh/.zshrc`
2. **If not**, Oh My Zsh's install overwrote it. Fix: `rm ~/.zshrc && cd ~/repos/dotfiles && stow zsh`
3. **Check all stow links:** `for pkg in zsh p10k tmux nvim ghostty git; do echo "--- $pkg ---"; ls -la $(stow -n -v -d ~/repos/dotfiles -t ~ "$pkg" 2>&1 | grep -oP '(?<=LINK: ).*(?= =>)' || echo "check manually"); done`
4. **The clean `.zshrc` should have:** p10k instant prompt, plugins (git, zsh-syntax-highlighting, zsh-autosuggestions), eza/bat/fzf/zoxide aliases, nvim as editor, conditional tmux autostart

### Quick fix if symlinks are broken

```bash
cd ~/repos/dotfiles
for pkg in zsh p10k tmux nvim ghostty git tmux-autostart; do
  stow -d ~/repos/dotfiles -t ~ -R "$pkg" 2>/dev/null
done
exec zsh
```

## Bugs Fixed During Implementation

- **Neovim:** `shiftaround` (invalid) → `shiftround` in `init.lua`
- **install-tools.sh:** Hardcoded `amd64` for delta/lazygit → now detects architecture via `dpkg --print-architecture` and `uname -m`
- **Stale PPA:** User removed `ppa:saiarcot895/chromium-beta` which was breaking `apt update`

## Pending Commits

The user manages their own git. Suggested messages for any uncommitted work:

- `fix: detect system architecture for delta and lazygit installs`
- `docs: add README with setup instructions and tool list`

## Spec & Plan

- Spec: `docs/superpowers/specs/2026-04-06-dotfiles-overhaul-design.md`
- Plan: `docs/superpowers/plans/2026-04-06-dotfiles-overhaul.md`
