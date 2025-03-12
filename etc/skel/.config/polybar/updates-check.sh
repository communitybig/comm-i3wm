#!/bin/bash

# Script para verificar atualizações disponíveis no sistema
# Para uso com polybar no i3wm

# Ícones do Nerd Fonts
ICON_UPDATES="󰚰"  # Ícone circular com seta para cima (nf-md-arrow_up_bold_circle)
ICON_UPDATED="󰄬"  # Ícone circular com check (nf-md-check_circle)
ICON_CHECKING="󰑖" # Ícone de carregamento circular (nf-md-loading)

# Cores
COLOR_UPDATES="#f5a70a"  # Cor quando há atualizações (laranja)
COLOR_UPDATED="#98c379"  # Cor quando está tudo atualizado (verde)
COLOR_CHECKING="#61afef" # Cor durante a verificação (azul)

# Arquivo para armazenar o número de atualizações
UPDATES_FILE="/tmp/updates-count-$USER"
ICON_FILE="/tmp/updates-count-$USER.icon"

# Verificar se o arquivo existe, senão criar
if [ ! -f "$UPDATES_FILE" ]; then
    echo "0" > "$UPDATES_FILE"
fi

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
        # Mostrar ícone de verificação
        show_status 0 "$ICON_CHECKING" "$COLOR_CHECKING" > "$ICON_FILE"
        
        # Verificar atualizações (yay mostra tanto pacotes AUR quanto oficiais)
        # Adicionar timeout para evitar travamento se o espelho estiver lento
        updates=$(timeout 30 yay -Qu 2>/dev/null | wc -l || echo "0")
        
        # Salvar o número de atualizações
        echo "$updates" > "$UPDATES_FILE"
        
        # Atualizar o ícone baseado no resultado
        if [ "$updates" -gt 0 ]; then
            show_status "$updates" "$ICON_UPDATES" "$COLOR_UPDATES" > "$ICON_FILE"
            
            # Enviar notificação se houver atualizações
            notify-send "Atualizações disponíveis" "Há $updates pacotes para atualizar" -i system-software-update
        else
            show_status 0 "$ICON_UPDATED" "$COLOR_UPDATED" > "$ICON_FILE"
        fi
        ;;
    
    *)
        # Ler número de atualizações do arquivo
        count=$(cat "$UPDATES_FILE" 2>/dev/null || echo "0")
        
        # Se o arquivo de ícone existir, usar ele
        if [ -f "$ICON_FILE" ]; then
            cat "$ICON_FILE"
        else
            # Caso contrário, gerar com base no count
            if [ "$count" -gt 0 ]; then
                show_status "$count" "$ICON_UPDATES" "$COLOR_UPDATES"
            else
                show_status 0 "$ICON_UPDATED" "$COLOR_UPDATED"
            fi
        fi
        
        # Se for a primeira execução, verificar atualizações em segundo plano
        if [ ! -f "$ICON_FILE" ]; then
            ($0 check &) 
        fi
        ;;
esac
