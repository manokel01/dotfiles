#!/bin/bash
# Toggle all keyboards between US (index 0) and Greek (index 1).
# Uses the ThinkPad keyboard as the reference for current state.
current=$(hyprctl devices -j | python3 -c "
import json, sys
for kb in json.load(sys.stdin)['keyboards']:
    if kb['name'] == 'at-translated-set-2-keyboard':
        print(1 if 'English' in kb['active_keymap'] else 0)
        break
")
hyprctl switchxkblayout all "$current"
