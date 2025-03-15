#!/bin/bash

yad --question \
  --title="Shutdown" \
  --text="<b>Confirm shutdown?</b>" \
  --button="Cancel:1" \
  --button="Confirm:0" \
  --timeout=30 \
  --timeout-indicator=top

case $? in
  0) shutdown -h now ;;  # Confirm
  1) shutdown -c ;;      # Cancel
  70) shutdown -h now ;; # Timeout (execute shutdown)
  *) shutdown -c ;;      # Window closed
esac
