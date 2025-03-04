#!/bin/bash

# Verifica se já existe uma instância em execução
if pidof -x "$(basename "$0")" -o $$ >/dev/null; then
    # Se já estiver em execução, sai sem fazer nada
    exit 0
fi

# Cria um arquivo temporário para o conteúdo
TMPFILE=$(mktemp /tmp/i3-helper.XXXXXX)

# Escreve os atalhos no arquivo temporário
cat > "$TMPFILE" <<EOF
i3 ShortCuts
Mod+Enter  → Open Terminal
Mod+d      → Open Menu (rofi/dmenu)
Mod+Shift+q → Close App/Window
Mod+1-9    → Alt Workspace
Mod+Shift+1-9 → Move app/window to Workspace
Mod+arrows → Alt Window
Mod+Shift+arrows → Move Window
Mod+f → full screen/exit full screen
EOF

# Exibe os atalhos usando uma janela flutuante
if command -v yad >/dev/null 2>&1; then
    # Se yad estiver instalado, use-o para uma exibição mais bonita
    yad --text-info --filename="$TMPFILE" --title="i3 Shortcuts" \
        --width=400 --height=300 --center --button="Close:0" \
        --window-icon=gtk-info --fontname="Monospace 11"
elif command -v zenity >/dev/null 2>&1; then
    # Se zenity estiver instalado, use-o como alternativa
    zenity --text-info --filename="$TMPFILE" --title="i3 Shortcuts" \
        --width=400 --height=300
else
    # Se nada estiver disponível, use o i3-nagbar
    i3-nagbar -t warning -m "$(cat "$TMPFILE")" -b "Close" "kill \$(pidof i3-nagbar)"
fi

# Remove o arquivo temporário
rm "$TMPFILE"
