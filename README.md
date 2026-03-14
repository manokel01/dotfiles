# System Architecture & Configuration Guide

**Hardware:** Lenovo ThinkPad P14s Gen 4 (AMD Ryzen 7 Pro 7840U, 64GB RAM, 2TB NVMe)  
**Display:** 400-nit Matte IPS  
**Peripherals:** NuPhy Air75 V3 (2.4G/BT), Bowers & Wilkins Px8 (LDAC/aptX), Logitech MX Master 3S  
**OS:** Fedora Linux (v43+)  
**Window Manager:** Hyprland (Wayland)  

## 1. Design Philosophy
This system is configured to strip away flashy aesthetics in favor of a strictly professional, minimalist workflow. 
* **Visuals:** High-contrast, pure black backgrounds, zero rounded corners, zero blur, and no UI clutter.
* **Performance:** Unnecessary graphical effects and background polling scripts are aggressively disabled to maximize responsiveness and battery life.
* **Control:** Configuration is a hybrid architecture utilizing a central Git vault (`~/dotfiles`). It uses **GNU Stow** for stable binaries/apps and **Decoupled Physical Files** for dynamic UI components. This allows for live testing and granular file-diffing without corrupting the version-controlled vault.

## 2. Core Stack & Tools
* **Base Template:** **"Native Void"** (100% custom, single-file Hyprland architecture).
* **Session Manager:** UWSM (Universal Wayland Session Manager)
* **Dotfile Management:** Git repository at `~/dotfiles` synced to GitHub, deployed via **GNU Stow** and custom `void` sync logic.
* **Terminal:** Kitty
* **Text Editing:** micro (Primary terminal editor with CUA keybinds)
* **Status Bar:** Waybar (Minimalist "Pill-less" layout)
* **App Launcher:** Walker
* **File Management:** Nautilus (GUI)
* **System/Network TUIs:** btop, wiremix, nmtui
* **Browser:** Brave
* **Clipboard Manager:** Cliphist
* **Screenshot Tool:** Grim + Slurp + wl-copy
* **GTK Management:** `nwg-look` (Overrides global `/etc/` defaults).
* **Custom Scripts:** Located in `~/.local/bin/`. These are tracked by Git and deployed to the live system via GNU Stow.

## 3. Kernel, Filesystem & Hardware Tuning
* **Filesystem (Btrfs):** `/etc/fstab` is configured with `noatime`, `compress=zstd:1`, and `discard=async` to reduce SSD wear.
* **Shared Storage:** A dedicated `/mnt/data` partition for read/write compatibility across dual-boot environments.
* **Memory Management:** **8GB ZRAM** (lzo-rle). `vm.swappiness` is set to `10` to prioritize the 64GB RAM pool.
* **Battery Longevity:** Hardware-locked to **80% charge threshold** via the ThinkPad EC. 
* **Power Efficiency:** `powertop --auto-tune` runs at boot. Idle discharge is optimized to **<6W**.

## 4. Disaster Recovery (Snapper)
System backups are managed via **Snapper** leveraging Fedora's native Btrfs subvolume layout.
* **Automated Snapshots:** Pre- and post-transaction snapshots for every `dnf` upgrade.
* **Pre-Sync Snapshots:** The `void` script triggers a `sudo snapper create` before any Git push.
* **Rollbacks:** Accessible via Btrfs Assistant GUI.

## 5. UI & Theming Decisions
* **Global Theme:** Flat-Remix-GTK-Blue-Dark
* **Icon Pack:** Tokyonight-Moon
* **Theming Sync:** Flatpaks respect the theme via `DarkLight.sh` punching through the sandbox.
* **Hyprland Aesthetics:** Pure black background (`0x000000`), `0` rounding, zero shadows/blur.
* **Cursor:** Nordzy (White), Size 24.
* **Vibrancy Fix:** `hyprshade` applied to boost saturation on the Matte IPS panel.

## 6. Keybindings (Native Hardware Swap)
**Modifier Key:** `SUPER` (Windows Key)

### Navigation & Management
| Action | Shortcut | Command/Tool |
| :--- | :--- | :--- |
| **Terminal** | `Super + Return` | Kitty |
| **Close Window** | `Super + Q` | `killactive` |
| **App Launcher** | `Super + Space` | Walker |
| **File Manager** | `Super + E` | Nautilus |
| **Toggle Floating** | `Super + V` | `togglefloating` |
| **Workspaces** | `Super + [1-4]` | `workspace [1-4]` |
| **Move to Workspace**| `Super + Shift + [1-4]`| `movetoworkspace [1-4]` |

### Essential Utilities & Screenshots
| Action | Shortcut | Command/Tool |
| :--- | :--- | :--- |
| **ThinkPad Screenshot** | `Print` | `/home/manokel/.local/bin/screenshot.sh` |
| **NuPhy Screenshot** | `XF86Tools` (F13) | `/home/manokel/.local/bin/screenshot.sh` |
| **Area Snipping** | `Super + Shift + S` | Grim + Slurp -> wl-copy |
| **Clipboard History**| `Super + Shift + V` | Cliphist -> Rofi |
| **Lock Screen** | `Super + L` | Hyprlock |

## 7. Critical System Quirks
1. **UWSM Integration:** All core apps (Waybar, Polkit, Idle) are launched as systemd units (`uwsm app --`) to eliminate race conditions.
2. **Audio Stability:** `wireplumber` is locked to **v0.5.11**. Upgrading past this version crashes Bluetooth high-fidelity audio.
3. **NuPhy Firmware Master:** Keyboard layout (Super/Alt swap, Alt Gr mapping) is handled at the **hardware firmware level** via NuPhyIO. This ensures identical physical layouts between the ThinkPad and Air75 without software-level "double-swaps."
4. **Absolute Path Binding:** Hyprland keybinds for local scripts MUST use absolute paths (e.g., `/home/manokel/.local/bin/screenshot.sh`) to bypass the restricted environment `$PATH`.
5. **Decoupled UI Testing:** `~/.config/waybar/` and `~/.config/hypr/` MUST remain physical directories in the live OS, NOT Stow symlinks. This physical separation is required for `git_sync_status.sh` to execute `diff` checks against the `~/dotfiles` vault.

## 8. Maintenance Workflow (The "Void" Sync)
Dotfiles are managed via a centralized repository at `~/dotfiles/` and pushed to GitHub (`origin main`). The system relies on a hybrid deployment strategy:

* **Stable Apps & Scripts:** Managed by GNU Stow (e.g., `kitty`, `scripts` deployed to `~/.local/bin/`).
* **Dynamic UI (Waybar/Hyprland):** Kept as decoupled, physical files in `~/.config/` for live editing.

Changes are synchronized using the custom `void` script:
1. **Live Audit:** `git_sync_status.sh` constantly runs `diff` to compare live physical UI files against the Git vault. If unsaved changes exist, the Waybar Git icon alerts the user.
2. **Physical Copy:** The `void` script physically copies (`cp`) the live UI files into `~/dotfiles/` to prepare for atomic tracking.
3. **Cloud Sync:** `git add`, `git commit`, and `git push` are executed against the GitHub remote.
4. **Waybar Signal:** Sends a `SIGUSR2` signal to Waybar to turn the Git icon **Green** upon successful sync.
