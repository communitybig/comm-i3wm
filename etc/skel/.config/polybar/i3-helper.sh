#!/bin/bash

# Verifica se já existe uma instância em execução
if pidof -x "$(basename "$0")" -o $$ >/dev/null; then
    # Se já estiver em execução, sai sem fazer nada
    exit 0
fi

# Cria um arquivo temporário para o conteúdo
TMPFILE=$(mktemp /tmp/i3-helper.XXXXXX)

# Escreve os atalhos no arquivo temporário com formatação melhorada
cat > "$TMPFILE" <<EOF
i3 ShortCuts

Mod+Enter  → Open Terminal

Mod+d      → Open Menu (rofi/dmenu)

Mod+b      → Open Browser

Mod+t      → Open Thunar

Mod+Shift+q → Close App/Window

Mod+1-9     → Alt Workspace

Mod+Shift+1-9 → Move app/window to Workspace

Mod+arrows  → Alt Window

Mod+Shift+arrows → Move Window

Mod+e      → Tilling vertical & horizontal

Mod+w      → Tilling like tabs

Mod+f      → Full screen/exit full screen

Mod+Shift+p → Open power manager

Mod+Shift+r → Restart i3

Mod+space   → Change keyboard layout (default options: br, us, ru)
EOF

# Define o tema escuro (para ajudar com o tema Nordic-darker)
export GTK_THEME=Nordic-darker

# Exibe os atalhos usando uma janela flutuante
if command -v yad >/dev/null 2>&1; then
    # Se yad estiver instalado, use-o para uma exibição mais bonita
    yad --text-info --filename="$TMPFILE" --title="i3 Shortcuts" \
        --width=450 --height=350 --center --button="Close:0" \
        --window-icon=gtk-info --fontname="Monospace 11" \
        --text-info --markup --wrap \
        --borders=10
elif command -v zenity >/dev/null 2>&1; then
    # Se zenity estiver instalado, use-o como alternativa
    zenity --text-info --filename="$TMPFILE" --title="i3 Shortcuts" \
        --width=450 --height=500 \
        --html
else
    # Se nada estiver disponível, use o i3-nagbar
    i3-nagbar -t warning -m "$(cat "$TMPFILE")" -b "Close" "kill \$(pidof i3-nagbar)"
fi

# Remove o arquivo temporário
rm "$TMPFILE"
