#!/bin/bash

# Pega o wallpaper atual do nitrogen
WALLPAPER=$(grep -oP "file=\K.*" ~/.config/nitrogen/bg-saved.cfg)

# Aplica o tema pywal com o wallpaper atual
wal -i "$WALLPAPER"

# Recarrega o i3
i3-msg reload


