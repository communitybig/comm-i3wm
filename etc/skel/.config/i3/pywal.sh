#!/bin/bash

# Restaura o último tema ou aplica um novo com uma imagem específica
wal -R || wal -i "/usr/share/backgrounds/owl-main.jpg"

# Recarrega o i3 para aplicar as cores
i3-msg reload
