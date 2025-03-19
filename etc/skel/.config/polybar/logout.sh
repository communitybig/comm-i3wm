#!/bin/bash

yad --question \
  --title="Logout" \
  --text="<b>Confirm logout?</b>" \
  --button="Cancel:1" \
  --button="Confirm:0" \
  --timeout=30 \
  --timeout-indicator=top

case $? in
  0) i3-msg exit ;;     # Confirm
  1) exit 0 ;;          # Cancel
  70) i3-msg exit ;;    # Timeout (execute logout)
  *) exit 0 ;;          # Window closed
esac
