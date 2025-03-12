#!/bin/bash

yad --question \
  --title="Shutdown" \
  --text="<b>System shutdown in 30 seconds.</b>" \
  --button="Cancel:1" \
  --button="Confirm:0" \
  --timeout=30 \
  --timeout-indicator=top

case $? in
  0) shutdown -h now ;;  # Confirm
  1) shutdown -c ;;      # Cancel
  *) shutdown -c ;;      # Timeout ou fechar janela
esac
