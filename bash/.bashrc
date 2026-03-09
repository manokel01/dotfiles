# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Security check for critical system locks
check_locks.sh

alias maintain='sudo dnf upgrade --refresh -y && flatpak update -y && sudo fwupdmgr get-updates && sudo fwupdmgr update && sudo dnf autoremove -y && [ -f /var/run/reboot-required ] && echo ">>> REBOOT RECOMMENDED <<<" || echo ">>> System up to date, no reboot needed. <<<"'

eval "$(starship init bash)"

# Eza replaces ls
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --header'

# --- THE VOID: ARCHITECT ALIASES ---
alias conf-hypr='nano ~/.config/hypr/hyprland.conf'
alias conf-waybar='nano ~/.config/waybar/config.jsonc'
alias conf-waycss='nano ~/.config/waybar/style.css'
alias conf-rofi='nano ~/.config/rofi/config.rasi'
alias conf-dunst='nano ~/.config/dunst/dunstrc'

# Reload Hyprland and Waybar in one shot
alias reload-void='hyprctl reload && killall waybar; waybar & disown'

# Quick System Updates
alias update='sudo dnf update -y'
export PATH=$PATH:$HOME/go/bin
