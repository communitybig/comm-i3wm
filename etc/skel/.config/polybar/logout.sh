#!/bin/bash

yad --question \
  --title="Logout" \
  --text="<b>Confirm logout?</b>" \
  --button="Cancel:1" \
  --button="Confirm:0" \
  --timeout=30

case $? in
  0) i3-msg exit ;;
  1|*) exit 0 ;;
esac
