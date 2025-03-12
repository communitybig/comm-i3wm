#!/bin/bash

# Script para instalar atualizações quando o usuário clica no ícone da polybar

# Caminho absoluto para o script de verificação
UPDATE_CHECK_SCRIPT="$HOME/.config/polybar/updates-check.sh"

# Definir o terminal que será usado (por ordem de preferência)
TERMINALS=("alacritty" "termite" "kitty" "xfce4-terminal" "gnome-terminal" "konsole" "x-terminal-emulator")

# Procurar por um terminal disponível
for term in "${TERMINALS[@]}"; do
    if command -v "$term" &>/dev/null; then
        TERMINAL="$term"
        break
    fi
done

# Se nenhum terminal for encontrado, usar o padrão
if [ -z "$TERMINAL" ]; then
    TERMINAL="x-terminal-emulator"
fi

# Verificar se há atualizações
updates=$(cat /tmp/updates-count-$USER 2>/dev/null || echo "0")

if [ "$updates" -gt 0 ]; then
    # Há atualizações, abrir o terminal para instalar
    case $TERMINAL in
        alacritty)
            $TERMINAL -e bash -c "echo 'Instalando $updates atualizações...' && yay -Syu && echo 'Pressione ENTER para fechar...' && read"
            ;;
        termite)
            $TERMINAL -e "bash -c 'echo \"Instalando $updates atualizações...\"; yay -Syu; echo \"Pressione ENTER para fechar...\"; read'"
            ;;
        kitty)
            $TERMINAL -e bash -c "echo 'Instalando $updates atualizações...' && yay -Syu && echo 'Pressione ENTER para fechar...' && read"
            ;;
        gnome-terminal)
            $TERMINAL -- bash -c "echo 'Instalando $updates atualizações...' && yay -Syu && echo 'Pressione ENTER para fechar...' && read"
            ;;
        konsole)
            $TERMINAL -e bash -c "echo 'Instalando $updates atualizações...' && yay -Syu && echo 'Pressione ENTER para fechar...' && read"
            ;;
        xfce4-terminal)
            $TERMINAL -e "bash -c 'echo \"Instalando $updates atualizações...\"; yay -Syu; echo \"Pressione ENTER para fechar...\"; read'"
            ;;
        *)
            $TERMINAL -e "bash -c 'echo \"Instalando $updates atualizações...\"; yay -Syu; echo \"Pressione ENTER para fechar...\"; read'"
            ;;
    esac
    
    # Após a instalação, verificar novamente as atualizações
    "$UPDATE_CHECK_SCRIPT" check
else
    # Não há atualizações, apenas notificar
    notify-send "Sistema atualizado" "Seu sistema já está com as últimas atualizações" -i emblem-default
fi
