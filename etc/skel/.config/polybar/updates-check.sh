#!/bin/bash

# Script para verificar atualizações disponíveis no sistema
# Para uso com polybar no i3wm

# Ícones do Nerd Fonts
ICON_UPDATES="󰚰"  # Ícone circular com seta para cima
ICON_UPDATED="󰄬"  # Ícone circular com check
ICON_CHECKING="󰑖" # Ícone de carregamento circular

# Cores
COLOR_UPDATES="#f5a70a"  # Cor quando há atualizações (laranja)
COLOR_UPDATED="#98c379"  # Cor quando está tudo atualizado (verde)
COLOR_CHECKING="#61afef" # Cor durante a verificação (azul)

# Arquivo para armazenar o número de atualizações
UPDATES_FILE="/tmp/updates-count-$USER"
ICON_FILE="/tmp/updates-count-$USER.icon"

# Função para debug
debug_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "/tmp/polybar-updates-debug-$USER.log"
}

# Função para mostrar o status com a formatação correta para a polybar
show_status() {
    local count=$1
    local icon=$2
    local color=$3
    
    # Formatar para polybar com cor
    if [ "$count" -gt 0 ]; then
        echo "%{F$color}$icon%{F-} $count"
    else
        echo "%{F$color}$icon%{F-}"
    fi
}

# Verificar o modo: check (verifica atualizações) ou display (mostra resultado)
case "$1" in
    check)
        debug_log "Iniciando verificação de atualizações"
        
        # Mostrar ícone de verificação
        show_status 0 "$ICON_CHECKING" "$COLOR_CHECKING" > "$ICON_FILE"
        debug_log "Ícone de verificação configurado"
        
        # Verificar atualizações usando PACMAN e YAY
        # Primeiro tenta pacman (não requer sudo para verificar, apenas para instalar)
        pacman_updates=$(checkupdates 2>/dev/null | wc -l || echo "0")
        debug_log "Atualizações do pacman: $pacman_updates"
        
        # Depois tenta yay para pacotes AUR
        aur_updates=$(yay -Qua 2>/dev/null | wc -l || echo "0")
        debug_log "Atualizações do AUR: $aur_updates"
        
        # Total de atualizações
        updates=$((pacman_updates + aur_updates))
        debug_log "Total de atualizações: $updates"
        
        # Salvar o número de atualizações
        echo "$updates" > "$UPDATES_FILE"
        debug_log "Número de atualizações salvo em $UPDATES_FILE: $updates"
        
        # Atualizar o ícone baseado no resultado
        if [ "$updates" -gt 0 ]; then
            show_status "$updates" "$ICON_UPDATES" "$COLOR_UPDATES" > "$ICON_FILE"
            debug_log "Ícone de atualizações disponíveis configurado"
            
            # Enviar notificação se houver atualizações
            notify-send "Atualizações disponíveis" "Há $updates pacotes para atualizar" -i system-software-update
            debug_log "Notificação enviada"
        else
            show_status 0 "$ICON_UPDATED" "$COLOR_UPDATED" > "$ICON_FILE"
            debug_log "Ícone de sistema atualizado configurado"
        fi
        ;;
    
    *)
        # Ler número de atualizações do arquivo
        if [ -f "$UPDATES_FILE" ]; then
            count=$(cat "$UPDATES_FILE" 2>/dev/null || echo "0")
            debug_log "Leu count de $UPDATES_FILE: $count"
        else
            count=0
            echo "$count" > "$UPDATES_FILE"
            debug_log "Arquivo não encontrado, criou $UPDATES_FILE com valor 0"
        fi
        
        # Se o arquivo de ícone existir, usar ele
        if [ -f "$ICON_FILE" ]; then
            cat "$ICON_FILE"
            debug_log "Usando ícone de $ICON_FILE"
        else
            # Caso contrário, gerar com base no count
            if [ "$count" -gt 0 ]; then
                show_status "$count" "$ICON_UPDATES" "$COLOR_UPDATES"
                debug_log "Gerou ícone de atualizações baseado no count: $count"
            else
                show_status 0 "$ICON_UPDATED" "$COLOR_UPDATED"
                debug_log "Gerou ícone de sistema atualizado baseado no count: 0"
            fi
        fi
        
        # Se for a primeira execução ou se já passou muito tempo desde a última verificação
        if [ ! -f "$ICON_FILE" ] || [ ! -f "$UPDATES_FILE" ] || [ $(find "$UPDATES_FILE" -mmin +60 2>/dev/null | wc -l) -gt 0 ]; then
            debug_log "Iniciando verificação em segundo plano"
            ($0 check &) 
        fi
        ;;
esac
