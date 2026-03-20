#!/bin/bash
# Native Void: Quick Note Taker

# 1. Open Walker in dmenu mode to capture the text
NOTE=$(walker --dmenu --placeholder "Append to notes.txt...")

# 2. Exit if the user pressed Escape or entered nothing
[ -z "$NOTE" ] && exit 0

# 3. Append to file with a timestamp
echo "$(date '+%Y-%m-%d %H:%M') | $NOTE" >> ~/notes.txt

# 4. Success feedback
notify-send "Void Note" "Saved to ~/notes.txt" -i accessories-text-editor
