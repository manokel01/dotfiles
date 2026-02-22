# System Architecture & Configuration Guide

**Hardware:** Lenovo ThinkPad P14s Gen 4 (AMD Ryzen 7 Pro 7840U, 64GB RAM, 2TB NVMe)  
**Display:** 400-nit Matte IPS  
**Peripherals:** Bowers & Wilkins Px8 (Bluetooth, LDAC/aptX), Logitech MX Master 3S  
**OS:** Fedora Linux (v43+)  
**Window Manager:** Hyprland (Wayland)  

## 1. Design Philosophy
This system is configured to strip away flashy aesthetics in favor of a strictly professional, minimalist workflow. 
* **Visuals:** High-contrast, pure black backgrounds, zero rounded corners, zero blur, and no UI clutter.
* **Performance:** Unnecessary graphical effects are disabled to maximize responsiveness and battery life.
* **Control:** Configuration is managed transparently via GNU Stow and Git, avoiding black-box install scripts.

## 2. Core Stack & Tools
* **Base Template:** JaKooLit's Hyprland Starter Kit (heavily modified and stripped down)
* **Dotfile Management:** GNU Stow (`~/dotfiles` symlinked to `~/.config`)
* **Terminal:** Kitty
* **Status Bar:** Waybar
* **App Launcher:** Rofi (`rofi -show drun`)
* **File Manager:** Thunar
* **Browser:** Brave
* **Clipboard Manager:** Cliphist
* **Screenshot Tool:** Grim + Slurp + Swappy

## 3. Kernel, Filesystem & Hardware Tuning
The underlying operating system has been optimized for this specific hardware configuration:

* **Filesystem (Btrfs) Optimization:** `/etc/fstab` is configured with `noatime`, `compress=zstd:1`, and `discard=async` to reduce SSD write amplification and optimize read/write speeds.
* **Shared Storage:** A dedicated `/mnt/data` partition is configured for read/write compatibility across dual-boot environments.
* **Memory Management:** The system utilizes **8GB of ZRAM** (lzo-rle compression). The swap tendency (`vm.swappiness`) is hardcoded to `10` to prioritize the 64GB physical RAM pool, utilizing ZRAM only for compressed background overflow.
* **Battery Longevity:** The battery charge threshold is hardware-locked to 80% via the ThinkPad Embedded Controller (EC). This persists across operating systems and prevents degradation from constant AC power.

## 4. Disaster Recovery (Snapper)
System backups are managed via **Snapper** and **Btrfs Assistant**, leveraging Fedora's native `root` and `home` subvolume layout.
* **Automated Snapshots:** The `python3-dnf-plugin-snapper` package guarantees pre- and post-transaction snapshots for every `dnf` upgrade.
* **Rollbacks:** System state can be instantly restored via the Btrfs Assistant GUI.

## 5. UI & Theming Decisions

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
* **Management:** Installed locally to `~/.icons/` to prevent bloating the Git repository with binary image files.

### Display Colors (The "Vibrancy" Fix)
* **The Context:** The ThinkPad's Matte IPS panel and AMD's power-saving defaults ("Vari-Bright") occasionally result in flat/washed-out colors.
* **The Solution:** 1. `hyprshade` is installed and set to `vibrance` to artificially boost saturation and mimic a glossy display. 
  2. The system power profile can be forced to performance (`powerprofilesctl set performance`) to bypass AMD's contrast shifting during media consumption.

### Browser (Brave)
* **UI Scaling Fix:** Brave's default UI renders too large. It is forced to render at 90% scale using the `--force-device-scale-factor=0.90` flag, which is hardcoded into the local desktop entry (`~/.local/share/applications/brave-browser.desktop`).

## 6. Keybindings (The "Smart Hybrid" Layout)
The layout combines Hyprland Official Navigation Defaults with essential utilities.

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

## 7. Critical System Quirks & Maintenance

1. **Audio Stability (WirePlumber Lock):** High-fidelity Bluetooth audio (LDAC/aptX) for the Bowers & Wilkins Px8 requires a specific audio stack state. `wireplumber` is strictly locked to version `0.5.11` via the DNF versionlock plugin (`sudo dnf versionlock add wireplumber`). Upgrading past this version causes catastrophic audio crashes. **Do not unlock this package.**
2. **Automated Watchdog:** A custom watchdog script (`~/dotfiles/scripts/check_locks.sh`) is integrated into `.bashrc` to monitor system state. It performs a silent check of the DNF versionlock list upon every terminal session; if the `wireplumber` lock is missing, a high-visibility red warning is issued to prevent accidental breakage of the audio stack.
3. **System Updates:** Running `sudo dnf upgrade` is safe. The audio package is shielded by the version lock, configuration files are insulated in the `~/dotfiles` vault, and Snapper guarantees a recovery point.
4. **Hyprland Syntax:** This configuration uses modern Hyprland syntax (e.g., the dedicated `shadow {}` block instead of the deprecated `drop_shadow` variable inside the `decoration {}` block). Verify syntax against current documentation before modifying.

## 8. Maintenance Workflow

### Standard Sync
When making changes to the UI or system config:
```bash
void
