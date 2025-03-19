#!/bin/bash

yad --question \
  --title="Reboot" \
  --text="<b>Confirm reboot?</b>" \
  --button="Cancel:1" \
  --button="Confirm:0" \
  --timeout=30 \
  --timeout-indicator=top

case $? in
  0) shutdown -r now ;;  # Confirm
  1) shutdown -c ;;      # Cancel
  70) shutdown -r now ;; # Timeout (execute reboot)
  *) shutdown -c ;;      # Window closed
esac
