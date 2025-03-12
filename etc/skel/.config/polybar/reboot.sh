#!/bin/bash

yad --question \
  --title="Reboot" \
  --text="<b>Reboot in 30 seconds.</b>" \
  --button="Cancel:1" \
  --button="Confirm:0" \
  --timeout=30

case $? in
  0) shutdown -r now ;;
  1|*) shutdown -c ;;
esac
