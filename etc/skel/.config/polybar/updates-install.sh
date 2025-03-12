#!/bin/bash

# Script para instalar atualizações quando o usuário clica no ícone da polybar

# Definir o terminal que será usado
TERMINAL="gnome-terminal"  # Altere para seu terminal (alacritty, termite, kitty, etc.)

# Verificar qual terminal está disponível se o padrão não estiver
if ! command -v $TERMINAL &> /dev/null; then
    if command -v termite &> /dev/null; then
        TERMINAL="termite"
    elif command -v kitty &> /dev/null; then
        TERMINAL="kitty"
    elif command -v xfce4-terminal &> /dev/null; then
        TERMINAL="xfce4-terminal"
    elif command -v gnome-terminal &> /dev/null; then
        TERMINAL="gnome-terminal"
    else
        # Último recurso
        TERMINAL="x-terminal-emulator"
    fi
fi

# Verificar se há atualizações
updates=$(cat /tmp/updates-count-$USER)

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
        xfce4-terminal)
            $TERMINAL -e "bash -c 'echo \"Instalando $updates atualizações...\"; yay -Syu; echo \"Pressione ENTER para fechar...\"; read'"
            ;;
        *)
            $TERMINAL -e "bash -c 'echo \"Instalando $updates atualizações...\"; yay -Syu; echo \"Pressione ENTER para fechar...\"; read'"
            ;;
    esac
    
    # Após a instalação, verificar novamente as atualizações
    ~/.config/polybar/scripts/updates-check.sh check
else
    # Não há atualizações, apenas notificar
    notify-send "Sistema atualizado" "Seu sistema já está com as últimas atualizações" -i emblem-default
fi
