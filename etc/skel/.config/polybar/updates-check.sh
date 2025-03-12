#!/bin/bash

# Script para verificar atualizações disponíveis no sistema
# Para uso com polybar no i3wm

# Ícones (você pode ajustar para outros ícones que tenha instalado)
ICON_UPDATES="󰚰" # Ícone circular com seta para cima (nf-md-arrow_up_bold_circle) 
ICON_UPDATED="󰄬" # Ícone circular com check (nf-md-check_circle) 
ICON_CHECKING="󰑖" # Ícone de carregamento circular (nf-md-loading)


# Cores
COLOR_UPDATES="#f5a70a"  # Cor quando há atualizações (laranja)
COLOR_UPDATED="#98c379"  # Cor quando está tudo atualizado (verde)
COLOR_CHECKING="#61afef" # Cor durante a verificação (azul)

# Arquivo para armazenar o número de atualizações
UPDATES_FILE="/tmp/updates-count-$USER"

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
        show_status 0 "$ICON_CHECKING" "$COLOR_CHECKING" > "$UPDATES_FILE.icon"
        
        # Verificar atualizações (yay mostra tanto pacotes AUR quanto oficiais)
        updates=$(yay -Qu | wc -l)
        
        # Salvar o número de atualizações
        echo "$updates" > "$UPDATES_FILE"
        
        # Atualizar o ícone baseado no resultado
        if [ "$updates" -gt 0 ]; then
            show_status "$updates" "$ICON_UPDATES" "$COLOR_UPDATES" > "$UPDATES_FILE.icon"
        else
            show_status 0 "$ICON_UPDATED" "$COLOR_UPDATED" > "$UPDATES_FILE.icon"
        fi
        
        # Enviar notificação se houver atualizações
        if [ "$updates" -gt 0 ]; then
            notify-send "Atualizações disponíveis" "Há $updates pacotes para atualizar" -i system-software-update
        fi
        ;;
    
    *)
        # Ler número de atualizações do arquivo
        count=$(cat "$UPDATES_FILE")
        
        # Se o arquivo de ícone existir, usar ele
        if [ -f "$UPDATES_FILE.icon" ]; then
            cat "$UPDATES_FILE.icon"
        else
            # Caso contrário, gerar com base no count
            if [ "$count" -gt 0 ]; then
                show_status "$count" "$ICON_UPDATES" "$COLOR_UPDATES"
            else
                show_status 0 "$ICON_UPDATED" "$COLOR_UPDATED"
            fi
        fi
        ;;
esac
