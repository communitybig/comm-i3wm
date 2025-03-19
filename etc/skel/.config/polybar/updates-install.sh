#!/bin/bash

# Script para instalar atualizações quando o usuário clica no ícone da polybar

# Caminho absoluto para o script de verificação
UPDATE_CHECK_SCRIPT="$HOME/.config/polybar/updates-check.sh"

# Debug log
debug_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "/tmp/polybar-updates-install-debug-$USER.log"
}

debug_log "Script de instalação iniciado"

# Definir o terminal que será usado (por ordem de preferência)
TERMINALS=("alacritty" "termite" "kitty" "xfce4-terminal" "gnome-terminal" "konsole" "x-terminal-emulator")

# Procurar por um terminal disponível
TERMINAL=""
for term in "${TERMINALS[@]}"; do
    if command -v "$term" &>/dev/null; then
        TERMINAL="$term"
        debug_log "Terminal encontrado: $TERMINAL"
        break
    fi
done

# Se nenhum terminal for encontrado, usar o padrão
if [ -z "$TERMINAL" ]; then
    TERMINAL="x-terminal-emulator"
    debug_log "Nenhum terminal específico encontrado, usando: $TERMINAL"
fi

# Verificar se há atualizações
if [ -f "/tmp/updates-count-$USER" ]; then
    updates=$(cat "/tmp/updates-count-$USER" 2>/dev/null || echo "0")
    debug_log "Leu número de atualizações: $updates"
else
    updates=0
    debug_log "Arquivo de contagem de atualizações não encontrado"
fi

# Forçar verificação em tempo real
debug_log "Verificando atualizações em tempo real com checkupdates"
realtime_updates=$(checkupdates 2>/dev/null | wc -l || echo "0")
debug_log "Atualizações em tempo real (pacman): $realtime_updates"

aur_updates=$(yay -Qua 2>/dev/null | wc -l || echo "0")
debug_log "Atualizações em tempo real (AUR): $aur_updates"

total_updates=$((realtime_updates + aur_updates))
debug_log "Total de atualizações em tempo real: $total_updates"

# Usar o valor mais recente
if [ $total_updates -gt $updates ]; then
    updates=$total_updates
    echo "$updates" > "/tmp/updates-count-$USER"
    debug_log "Atualizou o contador para: $updates"
fi

if [ "$updates" -gt 0 ]; then
    debug_log "Há atualizações, abrindo terminal: $TERMINAL"
    
    # Há atualizações, abrir o terminal para instalar
    case $TERMINAL in
        alacritty)
            $TERMINAL -e bash -c "echo 'Instalando $updates atualizações...' && sudo pacman -Syu && yay -Sua && echo 'Pressione ENTER para fechar...' && read"
            ;;
        termite)
            $TERMINAL -e "bash -c 'echo \"Instalando $updates atualizações...\"; sudo pacman -Syu && yay -Sua; echo \"Pressione ENTER para fechar...\"; read'"
            ;;
        kitty)
            $TERMINAL -e bash -c "echo 'Instalando $updates atualizações...' && sudo pacman -Syu && yay -Sua && echo 'Pressione ENTER para fechar...' && read"
            ;;
        gnome-terminal)
            $TERMINAL -- bash -c "echo 'Instalando $updates atualizações...' && sudo pacman -Syu && yay -Sua && echo 'Pressione ENTER para fechar...' && read"
            ;;
        konsole)
            $TERMINAL -e bash -c "echo 'Instalando $updates atualizações...' && sudo pacman -Syu && yay -Sua && echo 'Pressione ENTER para fechar...' && read"
            ;;
        xfce4-terminal)
            $TERMINAL -e "bash -c 'echo \"Instalando $updates atualizações...\"; sudo pacman -Syu && yay -Sua; echo \"Pressione ENTER para fechar...\"; read'"
            ;;
        *)
            $TERMINAL -e "bash -c 'echo \"Instalando $updates atualizações...\"; sudo pacman -Syu && yay -Sua; echo \"Pressione ENTER para fechar...\"; read'"
            ;;
    esac
    
    debug_log "Execução do terminal concluída"
    
    # Após a instalação, verificar novamente as atualizações
    debug_log "Verificando atualizações após instalação"
    "$UPDATE_CHECK_SCRIPT" check
else
    # Não há atualizações, apenas notificar
    debug_log "Não há atualizações, enviando notificação"
    notify-send "Sistema atualizado" "Seu sistema já está com as últimas atualizações" -i emblem-default
fi

debug_log "Script de instalação concluído"
