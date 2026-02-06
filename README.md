# 🌿 Fedora 43 Hyprland Dotfiles

**System:** ThinkPad P14s Gen 4 (AMD Ryzen 7 Pro 7840U)
**OS:** Fedora 43 Workstation
**Base Configuration:** [JaKooLit Fedora-Hyprland](https://github.com/JaKooLit/Fedora-Hyprland)
**Management:** GNU Stow

## 📂 Structure
This repository uses **GNU Stow** to manage symlinks.
- `hypr/`: Hyprland configuration (links to `~/.config/hypr`)

## ⚠️ Critical Constraints
1. **WirePlumber:** Locked to version `0.5.11` to prevent Bluetooth crash.
2. **Scaling:** Optimized for mixed DPI (Internal 1200p/1800p + External 4K).

## 🚀 Installation (How to Restore)
If setting up on a fresh machine:

```bash
# 1. Install Stow
sudo dnf install stow git

# 2. Clone this repo
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles

# 3. Apply configurations
cd ~/dotfiles
stow hypr
```
