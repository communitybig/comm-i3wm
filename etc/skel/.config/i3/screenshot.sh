#!/bin/sh

# Certifique-se de que o diretório existe
mkdir -p $HOME/Pictures

# Define o local onde salvar a captura de tela
Location=$HOME/Pictures/Screenshot_`date +%Y-%m-%d_%H-%M-%S`.png

case "$1" in
    full)
        scrot "$Location"
        ;;
    current)
        scrot -u "$Location"
        ;;
    partial)
        scrot -s "$Location"
        ;;
    *)
        echo "Usage: $0 {full|current|partial} {clipboard}"
        exit 2
esac

# Reproduzir som usando Pipewire
if [ -f "/usr/share/sounds/freedesktop/stereo/screen-capture.oga" ]; then
    # Verificar quais ferramentas de reprodução estão disponíveis
    if command -v pw-play >/dev/null 2>&1; then
        pw-play /usr/share/sounds/freedesktop/stereo/screen-capture.oga &
    elif command -v pw-cat >/dev/null 2>&1; then
        pw-cat -p /usr/share/sounds/freedesktop/stereo/screen-capture.oga &
    elif command -v paplay >/dev/null 2>&1; then
        # Pipewire fornece compatibilidade com paplay
        paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga &
    elif command -v play >/dev/null 2>&1; then
        # Se tiver sox instalado
        play /usr/share/sounds/freedesktop/stereo/screen-capture.oga &
    fi
fi

case "$2" in
    clipboard)
        # Verifica se xclip está instalado
        if command -v xclip >/dev/null 2>&1; then
            xclip -selection clipboard -t "image/png" < "$Location"
        else
            echo "xclip não está instalado. Não foi possível copiar para a área de transferência."
            exit 1
        fi
        ;;
esac

# Notifica o usuário (se o notificador estiver disponível)
if command -v notify-send >/dev/null 2>&1; then
    notify-send "Screenshot" "Salvo em $Location" -i "$Location"
fi

exit 0
