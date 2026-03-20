#!/bin/bash
DOTFILES_DIR="$HOME/dotfiles"

# 1. LIVE AUDIT: Only check Decoupled UI files
DIFF_HYPR=$(diff -q ~/.config/hypr/hyprland.conf "$DOTFILES_DIR/hypr/.config/hypr/hyprland.conf" 2>/dev/null)
DIFF_WB_C=$(diff -q ~/.config/waybar/config.jsonc "$DOTFILES_DIR/waybar/.config/waybar/config.jsonc" 2>/dev/null)
DIFF_WB_S=$(diff -q ~/.config/waybar/style.css "$DOTFILES_DIR/waybar/.config/waybar/style.css" 2>/dev/null)
DIFF_WALKER=$(diff -q ~/.config/walker/config.toml "$DOTFILES_DIR/walker/.config/walker/config.toml" 2>/dev/null)

cd "$DOTFILES_DIR" || exit

# 2. GIT STATUS (Catches changes in Stow-managed scripts and the vault itself)
STATUS=$(git status --porcelain)
LOCAL=$(git rev-parse @ 2>/dev/null)
REMOTE=$(git rev-parse "origin/main" 2>/dev/null)
ICON=""

sanitize() {
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g'
}

# 3. PRIORITY LOGIC
# Removed DIFF_NOTE as git status handles all stowed scripts
if [[ -n "$DIFF_HYPR" || -n "$DIFF_WB_C" || -n "$DIFF_WB_S" || -n "$DIFF_WALKER" || -n "$STATUS" ]]; then
    echo "{\"text\": \"$ICON\", \"tooltip\": \"󱈸 UNCOMMITTED OR LIVE CHANGES\", \"class\": \"dirty\"}"
elif [[ -n "$LOCAL" && -n "$REMOTE" && "$LOCAL" != "$REMOTE" ]]; then
    HISTORY=$(git log -3 --format="- %s (%ar)" origin/main..HEAD 2>/dev/null | sanitize)
    echo "{\"text\": \"$ICON\", \"tooltip\": \"󰇚 UNPUSHED COMMITS:\\n$HISTORY\", \"class\": \"unpushed\"}"
else
    HISTORY=$(git log -3 --format="- %s (%ar)" 2>/dev/null | sanitize)
    echo "{\"text\": \"$ICON\", \"tooltip\": \"✅ SYNCED\\n$HISTORY\", \"class\": \"clean\"}"
fi
