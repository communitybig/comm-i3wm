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
<b>i3 ShortCuts</b>

<span color="#81A1C1"><b>Mod+Enter</b></span>  → Open Terminal
<span color="#81A1C1"><b>Mod+d</b></span>      → Open Menu (rofi/dmenu)
<span color="#81A1C1"><b>Mod+Shift+q</b></span> → Close App/Window
<span color="#81A1C1"><b>Mod+1-9</b></span>    → Alt Workspace
<span color="#81A1C1"><b>Mod+Shift+1-9</b></span> → Move app/window to Workspace
<span color="#81A1C1"><b>Mod+arrows</b></span> → Alt Window
<span color="#81A1C1"><b>Mod+Shift+arrows</b></span> → Move Window
<span color="#81A1C1"><b>Mod+f</b></span> → full screen/exit full screen
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
