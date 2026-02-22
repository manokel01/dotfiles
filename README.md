# System Architecture & Configuration Guide

**Hardware:** Lenovo ThinkPad P14s (AMD Ryzen, 400-nit Matte IPS)  
**OS:** Fedora Linux (v43+)  
**Window Manager:** Hyprland (Wayland)  

## 1. Design Philosophy
This system is configured to strip away "gamer" or flashy aesthetics in favor of a **Professional Minimalist** workflow. 
* **Visuals:** High-contrast, pure black backgrounds, zero rounded corners, zero blur, and no UI clutter.
* **Performance:** Unnecessary graphical effects are disabled to maximize responsiveness and battery life.
* **Control:** Configuration is managed transparently via GNU Stow and Git, avoiding black-box install scripts.

## 2. Core Stack & Tools
* **Base Template:** JaKooLit's Hyprland Starter Kit (Heavily modified/stripped down)
* **Dotfile Management:** GNU Stow (`~/dotfiles` symlinked to `~/.config`)
* **Terminal:** Kitty
* **Status Bar:** Waybar
* **App Launcher:** Rofi (`rofi -show drun`)
* **File Manager:** Thunar
* **Browser:** Brave
* **Clipboard Manager:** Cliphist
* **Screenshot Tool:** Grim + Slurp + Swappy

## 3. UI & Theming Decisions

### Windows & Borders (Hyprland)
* **Rounding:** `0` (Strictly square corners).
* **Shadows & Blur:** Disabled for maximum sharpness and performance.
* **Trackpad:** Natural scrolling enabled (`natural_scroll = true`).

### The Terminal (Kitty)
* **Aesthetic:** GitHub Dark Mode.
* **Font:** JetBrains Mono Light (Size 12.5). Automatic bolding disabled for a thinner, cleaner look. Ligatures disabled for the cursor.
* **Window:** `background_opacity 1.0`, no window decorations, 6px padding.

### The Status Bar (Waybar)
* **Aesthetic:** "The Void". 
* **Design:** Pure black background (`#000000`), crisp white text. All background bubbles, gradients, and rounded modules from the default JaKooLit config were intentionally removed.

### The Cursor
* **Theme:** Nordzy (White). 
* **Size:** 24.
* **Why Nordzy?:** Chosen as a pre-compiled, drop-in alternative to Volantes. It provides a sharp, triangular, high-contrast, futuristic look.
* **Management:** Installed locally to `~/.icons/` (Simple Method) rather than managed by Stow, to prevent bloating the Git repository with binary image files.

### Display Colors (The "Vibrancy" Fix)
* **The Context:** The ThinkPad's Matte IPS panel and AMD's power-saving defaults ("Vari-Bright") occasionally result in flat/washed-out colors.
* **The Solution:** 1. `hyprshade` is installed and set to `vibrance` to artificially boost saturation and mimic a glossy display. 
  2. The system power profile can be forced to performance (`powerprofilesctl set performance`) to bypass AMD's contrast shifting during media consumption.

### Browser (Brave)
* **UI Scaling Fix:** Brave's default UI renders too large. It is forced to render at 90% scale using the `--force-device-scale-factor=0.90` flag, which is hardcoded into the local desktop entry (`~/.local/share/applications/brave-browser.desktop`).

## 4. Keybindings (The "Smart Hybrid" Layout)
The default complex keybindings were abandoned for a hybrid layout that combines **Hyprland Official Navigation Defaults** with **Essential Utilities**.

**Modifier Key:** `SUPER` (Windows Key)

### Navigation & Management
| Action | Shortcut | Command/Tool |
| :--- | :--- | :--- |
| **Terminal** | `Super + Q` | Kitty |
| **Close Window** | `Super + C` | `killactive` |
| **App Launcher** | `Super + Space` | Rofi |
| **File Manager** | `Super + E` | Thunar |
| **Toggle Floating** | `Super + V` | `togglefloating` |
| **Fullscreen** | `Super + F` | `fullscreen` |
| **Focus Window** | `Super + Arrow Keys` | `movefocus` |
| **Move Window** | `Super + Shift + Arrows`| `movewindow` |
| **Workspaces** | `Super + [1-0]` | `workspace [1-10]` |
| **Move to Workspace**| `Super + Shift + [1-0]`| `movetoworkspace [1-10]` |

### Essential Utilities
| Action | Shortcut | Command/Tool |
| :--- | :--- | :--- |
| **Area Screenshot** | `Super + Shift + S` | Grim + Slurp -> Swappy |
| **Clipboard History**| `Super + Shift + V` | Cliphist -> Rofi |
| **Lock Screen** | `Super + L` | Hyprlock |
| **Power Menu** | `Super + M` | Wlogout |
| **Reload Waybar** | `Super + Shift + B` | `killall waybar && waybar & disown` |

## 5. Critical System Quirks & Maintenance

1. **Audio Stability (WirePlumber Lock):** `wireplumber` is strictly locked to version `0.5.11` via DNF `versionlock`. Upgrading past this version on this specific hardware combination causes catastrophic Bluetooth audio crashes. **Do not unlock this package.**
2. **System Updates:** Running `sudo dnf upgrade` is safe. The audio package is shielded by the version lock, and configuration files are insulated in the `~/dotfiles` vault.
3. **Hyprland Syntax:** This configuration uses modern Hyprland syntax (e.g., the dedicated `shadow {}` block instead of the deprecated `drop_shadow` variable inside the `decoration {}` block). Keep this in mind when referencing older documentation online.

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
