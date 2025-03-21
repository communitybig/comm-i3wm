#!/bin/bash

# Pega o wallpaper atual do nitrogen
WALLPAPER=$(grep -oP "file=\K.*" ~/.config/nitrogen/bg-saved.cfg)

# Aplica o tema pywal com o wallpaper atual
wal -i "$WALLPAPER"

# Recarrega o i3
i3-msg reload

# Reinicia o polybar para aplicar as novas cores
if pgrep -x "polybar" > /dev/null; then
    polybar-msg cmd restart || (pkill polybar && sleep 1 && polybar main &)
else
    polybar main &
fi
