#!/usr/bin/env python
import subprocess
import json
import imaplib

def get_gmail_count():
    try:
        # Pull the password from the GNOME Keyring
        password = subprocess.check_output(
            ["secret-tool", "lookup", "service", "gmail", "user", "manokel"], 
            text=True
        ).strip()

        # Connect to Gmail via IMAP
        obj = imaplib.IMAP4_SSL('imap.gmail.com', 993)
        obj.login('manokel@gmail.com', password) # <-- REPLACE THIS WITH YOUR EMAIL
        obj.select()
        
        # Search for unread messages
        count = len(obj.search(None, 'Unseen')[1][0].split())
        obj.logout()
        return str(count)
    except Exception:
        return "!"

count = get_gmail_count()
print(json.dumps({"text": count, "class": "custom-gmail"}))