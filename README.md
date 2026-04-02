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
* **Status Bar:** Waybar (Minimalist "Pill-less" layout with Git/Sync auditors)
* **App Launcher:** Walker (Rust-based, native Wayland)
* **System/Network TUIs:** btop, wiremix, nmtui
* **Browser:** Brave
* **Clipboard Manager:** Cliphist
* **Screenshot Tool:** Grim + Slurp + wl-copy
* **GTK Management:** `nwg-look` (Overrides global `/etc/` defaults).
* **Custom Scripts:** Located in `~/.local/bin/`. These are tracked by Git and deployed to the live system via GNU Stow.
* **Cloud/Hardware Sync:** Rclone (Guarded Two-Way Bisync)
* **Secret Management:** Bitwarden (via `walker` plugin and `rbw` CLI)
* **Quick Notes:** `note.sh` (Custom Walker dmenu frontend -> `~/notes.txt`)

### 📂 File Management & Portals (Native Void Stack)
- **Primary File Manager:** Dolphin (KDE) - Replaced Nautilus for rock-solid GDrive (KIO) network stability and async I/O.
- **UI Theming:** Native Void #000000 aesthetics enforced via `QT_QPA_PLATFORMTHEME=qt6ct` and `kvantum`.
- **Terminal Integration:** Embedded panel (F4) and right-click actions strictly bound to Kitty.
- **MIME Associations:** Hard-coded in `~/.config/mimeapps.list` (`inode/directory=org.kde.dolphin.desktop`) to prevent system fallback to GNOME tools.
- **XDG Portals (The GTK Override):** - `xdg-desktop-portal-kde` handles file chooser dialogs to enforce UI parity in GTK/Chromium apps (like Brave).
  - Globally enforced via `env = GTK_USE_PORTAL,1` in `hyprland.conf`.
  - Portal routing locked in `~/.config/xdg-desktop-portal/portals.conf` (`org.freedesktop.impl.portal.FileChooser=kde`).

## 3. Kernel, Filesystem & Hardware Tuning
* **Filesystem (Btrfs):** `/etc/fstab` is configured with `noatime`, `compress=zstd:1`, and `discard=async` to reduce SSD wear.
  **Partition Layout:**
	- Partition 1: Linux root (Btrfs) — Snapper-managed (root + home configs), subvolumes: root, home, .snapshots
	- Partition 2: /mnt/data (exFAT) — shared read/write across dual-boot, excluded from Snapper
	- Partition 3: Windows (NTFS)
* **Shared Storage:** A dedicated `/mnt/data` partition for read/write compatibility across dual-boot environments.
* **Memory Management:** **8GB ZRAM** (lzo-rle). `vm.swappiness` is set to `10` to prioritize the 64GB RAM pool.
* **Battery Longevity:** Hardware-locked to **80% charge threshold** via the ThinkPad EC. 
* **Power Efficiency:** `powertop --auto-tune` runs at boot. Idle discharge is optimized to **<6W**.
* **GPU Media Engine (AMD Radeon 780M):** Swapped drivers to `mesa-va-drivers-freeworld` via RPM Fusion to unlock H.264/H.265 hardware decoding.
* **Browser Acceleration:** Forced via `~/.config/brave-flags.conf` using Vulkan and VA-API. Achieved **0 RPM fan curves** and **~45°C thermals** during 1080p live streams.
* **Disk I/O & SSD Optimizations (The Hard Filter):** Set `Storage=persistent` but applied `MaxLevelStore=warning` via a drop-in file (`/etc/systemd/journald.conf.d/10-hard-filter.conf`). This drops 95% of routine OS logging (Info/Debug), allowing the NVMe drive to remain in its deepest sleep states to preserve battery. Only system Warnings, Errors, and Panics are written to disk for post-mortem crash analysis, capped at `SystemMaxUse=100M`.
* **Background Service Scheduling:** Converted cyclical systemd timers (`nl_auto`, `void-auditor`, `rclone-sync`) to fixed-point daily triggers. This eliminates redundant background CPU wake-ups, strictly prioritizing AMD Ryzen C10 deep-sleep efficiency.
* **Adaptive Idle (hypridle):** Implemented dual-path power sensing via `/sys/class/power_supply/AC/online`. 
    - **Battery Path:** Aggressive 150s Dim / 180s Lock / 210s DPMS / 900s Suspend.
    - **AC Path:** Relaxed 540s Dim / 600s Lock / 660s DPMS for home/desk workflow.

## 4. Disaster Recovery (Snapper)
System backups are managed via **Snapper** leveraging Fedora's native Btrfs subvolume layout.
* **Configurations:** Two active configs — `root` covering `/` (NUMBER_LIMIT=10) and `home` covering `/home` (NUMBER_LIMIT=100).
* **Automated Snapshots:** Pre- and post-transaction snapshots for every `dnf` upgrade.
* **Pre-Sync Snapshots:** The `void` script triggers a `sudo snapper create` before any Git push.
* **Claude Code Snapshots:** A pre-tool hook triggers `snapper -c home create` before every individual file write inside the Claude Code container.
* **Rollbacks:** Accessible via Btrfs Assistant GUI (v2.2, installed via RPM).

## 5. UI & Theming Decisions
* **Global Theme:** Flat-Remix-GTK-Blue-Dark
* **Icon Pack:** Tokyonight-Moon
* **Theming Sync:** Flatpaks respect the theme via `DarkLight.sh` punching through the sandbox.
* **Hyprland Aesthetics:** Pure black background (`0x000000`), `0` rounding, zero shadows/blur.
* **Cursor:** Nordzy (White), Size 24.
* **Vibrancy Fix:** `hyprshade` applied to boost saturation on the Matte IPS panel.
* **Window Rule Architecture:** Strict block-syntax rules enforce the Dwindle layout. LibreOffice is explicitly stripped of `maximize` and `fullscreen` Wayland requests and forced to tile via `float = off`, abandoning splash-screen vanity rules in favor of structural workspace integrity.

## 6. Keybindings (Native Hardware Swap)
**Modifier Key:** `SUPER` (Windows Key)

### Navigation & Management
| Action | Shortcut | Command/Tool |
| :--- | :--- | :--- |
| **Terminal** | `Super + Return` | Kitty |
| **Close Window** | `Super + Q` | `killactive` (Smart Viber kill logic) |
| **App Launcher** | `Super + D` | Walker |
| **File Manager** | `Super + E` | Dolphin |
| **Toggle Floating** | `Super + V` | `togglefloating` |
| **Quick Note** | `Super + Alt + N` | `note.sh` (Append to `~/notes.txt`) |

### Essential Utilities & Screenshots
| Action | Shortcut | Command/Tool |
| :--- | :--- | :--- |
| **ThinkPad Screenshot** | `Print` | `/home/manokel/.local/bin/screenshot.sh` |
| **NuPhy Screenshot** | `XF86Tools` (F13) | `/home/manokel/.local/bin/screenshot.sh` |
| **Area Snipping** | `Super + Shift + S` | Grim + Slurp -> wl-copy |
| **Bitwarden Vault** | `Super + P` | Walker (Bitwarden plugin) |
| **Clipboard History**| `Super + Shift + V` | Walker (Clipboard plugin) |
| **Sync Vault** | `Waybar Click` | `void` script (launched in `floating_terminal`) |
| **Lock Screen** | `Super + L` | Hyprlock |
| **Reload Waybar** | `Super + Shift + W` | killall waybar \|\| uwsm app -- waybar |

## 7. Critical System Quirks
1. **UWSM Integration:** All core apps (Waybar, Polkit, Idle) are launched as systemd units (`uwsm app --`) to eliminate race conditions.
2. **Audio Stability:** `wireplumber` is locked to **v0.5.11**. Upgrading past this version crashes Bluetooth high-fidelity audio.
3. **NuPhy Firmware Master:** Keyboard layout (Super/Alt swap, Alt Gr mapping) is handled at the **hardware firmware level** via NuPhyIO. This ensures identical physical layouts between the ThinkPad and Air75 without software-level "double-swaps."
4. **Absolute Path Binding:** Hyprland keybinds for local scripts MUST use absolute paths (e.g., `/home/manokel/.local/bin/screenshot.sh`) to bypass the restricted environment `$PATH`.
5. **Decoupled UI Testing:** `~/.config/waybar/` and `~/.config/hypr/` MUST remain physical directories in the live OS, NOT Stow symlinks. This physical separation is required for `git_sync_status.sh` to execute `diff` checks against the `~/dotfiles` vault.

## 8. Maintenance Workflow (The "Void" Sync)
Dotfiles are managed via a centralized repository at `~/dotfiles/` and pushed to GitHub (`origin main`). The system uses a **Hybrid Deployment Strategy** to balance stability with live UI experimentation.

## The Hybrid Logic
- **Stow-Managed (Stable):** Core applications and internal logic including `micro`, `kitty`, and all scripts within `~/.local/bin/` (specifically `network-controller.sh`, `note.sh`, and `pass-picker.sh`). These reside permanently in the vault and are symlinked to the system. Changes are detected automatically via `git status`.
- **Decoupled (Experimental):** UI-critical configurations for `hypr` (including `hyprland.conf` and `hypridle.conf`), `waybar`, and `walker`. To facilitate zero-latency hot-reloading and live testing, these remain **physical files** in `~/.config/`. The `void` script utilizes an explicit **Ingestion Array** (`UI_TARGETS`) to map and pull these into the vault during sync while safely ignoring stowed symlinks to prevent circular reference errors.

### The Sync Process (`void` script)
1. **Live Audit:** A background script (`git_sync_status.sh`) runs a `diff` between physical UI files (`hypr`, `waybar`, `walker`), core scripts (`note.sh`), and the vault. If they differ, the Waybar Git icon alerts the user.
2. **Vault Ingestion:** The `void` script executes `cp` to pull physical UI and script changes into `~/dotfiles/`, allowing for live testing and manual auditing before committing to the vault.

## The Sync Architecture (`void` & `git_sync_status.sh`)
1. **Array-Driven Audit:** Both scripts share a unified `UI_TARGETS` array. The background auditor executes a `diff` on these specific paths to detect live system "drift."
2. **Visual Alerting:** Detected drift or uncommitted vault changes trigger a state change in the Waybar Git icon (Color/Tooltip), signaling the system is "dirty."
3. **Atomic Ingestion:** The `void` script iterates through the target array, copying physical UI files into the vault while **explicitly ignoring symlinks** (preventing the `cp: same file` error).
4. **GitHub Serialization:** Changes are staged (`git add -A`), committed with a manual description, and pushed. A `SIGUSR2` signal resets the Waybar icon to **Green (Synced)** upon success.

## 9. Data Integrity & "Split-Brain" Cloud Sync
The local data directory (`~/gdrive-manokel`) serves as the Ground Truth, syncing bidirectionally with Google Drive and mirroring to a physical T7 drive. 

* **The Silent Auditor:** A systemd user-timer triggers `rclone_auditor.sh` daily (shifted from hourly to maximize battery). 
    * **Safe Auto-Commit:** If only additions ("Queue copy") are detected, it syncs invisibly.
    * **Guarded Interrupt:** If "Queue delete" or "Queue update" is detected, it aborts and drops `~/.rclone_pending_review`.
* **Strict Exclusions:** Python virtual environments (`.venv`), cache directories (`__pycache__`), and logs are hard-filtered from all sync and audit operations to prevent massive file-count API throttling on Google Drive.
* **UI Feedback:** Waybar module (`custom/rclone`) uses `rclone_status.sh` to change colors based on state: Green (Idle), Red (Active), Blue (Pending Review), Yellow (Error).
* **Manual Approval (The Gatekeeper):** Clicking the Blue icon launches `rclone_sync.sh` in a floating Kitty window. It utilizes a `pgrep` memory check to stall execution until background database locks are cleared, then prompts for line-item review and `y/n` confirmation.
* **Vault Integration:** All sync scripts are managed via GNU Stow under the `scripts` package.

## 10. Secrets & Biometrics (Bitwarden Native)
The system uses a strictly non-GUI password architecture to minimize memory overhead.

* **Stack:** `rbw` (Rust CLI) + `walker` (Bitwarden plugin) + `pinentry-gnome3`.
* **Biometrics:** Integrated via `fprintd` and `authselect`. Master password decryption is bridged to the ThinkPad P14s fingerprint sensor via PAM.
* **Workflow:** `Super + P` launches the Walker Bitwarden provider. Fingerprint auth unlocks the `rbw-agent`, and the selected secret is piped to `wl-copy`.
* **Sync:** Manual sync via `rbw sync`; fully functional offline for read-access.
