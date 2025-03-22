#!/usr/bin/env bash

# Diretório para salvar as gravações
DIR="$(xdg-user-dir VIDEOS)"
[[ ! -d "$DIR" ]] && mkdir -p "$DIR"

# Arquivo para armazenar temporariamente o nome do arquivo de gravação
TEMP_FILE="/tmp/ffmpeg-recorder-filename"
STATUS_FILE="/tmp/ffmpeg-recorder-status"

# Função de limpeza para parar a gravação e converter o vídeo
stop_recording() {
    if pgrep -x "ffmpeg" > /dev/null; then
        # Mata o processo ffmpeg com SIGINT para finalizar corretamente
        pkill --signal SIGINT ffmpeg
        notify-send "📹 Gravação encerrada" "Processando o vídeo..."
        
        # Espera o ffmpeg finalizar completamente
        while pgrep -x "ffmpeg" > /dev/null; do
            sleep 0.5
        done
        
        if [[ -f "$TEMP_FILE" ]]; then
            MKV_FILE=$(cat "$TEMP_FILE")
            MP4_FILE="${MKV_FILE%.mkv}.mp4"
        else
            notify-send "❌ Erro" "Arquivo de gravação não encontrado!"
            rm -f "$STATUS_FILE"
            exit 1
        fi

        if [[ -f "$MKV_FILE" ]]; then
            notify-send "📦 Compactando vídeo..." "Aguarde..."
            
            # Converte o arquivo MKV para MP4 com melhor compressão
            ffmpeg -i "$MKV_FILE" -c:v libx264 -preset fast -crf 28 -pix_fmt yuv420p -threads "$(nproc)" -y "$MP4_FILE" && {
                notify-send "✅ Vídeo salvo!" "Arquivo: $MP4_FILE"
                echo "✔ Vídeo salvo: $MP4_FILE"
                
                # Copia o caminho do vídeo para a área de transferência
                echo -n "$MP4_FILE" | xclip -selection clipboard
                rm -f "$MKV_FILE"
            }
        else
            notify-send "❌ Erro" "Arquivo de gravação não encontrado!"
        fi
        
        # Remove arquivos temporários
        rm -f "$TEMP_FILE" "$STATUS_FILE"
    fi
}

# Verifica se já está gravando
if [[ -f "$STATUS_FILE" ]]; then
    stop_recording
    exit 0
fi

# Se não está gravando, mostra o menu de seleção do modo de gravação
SELECTION=$(echo -e "🖥️ Gravar Tela Inteira\n🎥 Gravar Janela Ativa\n🎯 Gravar Seleção\n🎙️ Gravar Tela Com Áudio" | rofi -dmenu -i -no-show-icons -l 4 -width 30 -p "📹 Escolha o modo")

# Função para iniciar gravação
start_recording() {
    local CMD="$1"
    local DESCRIPTION="$2"
    
    # Cria o arquivo de status para indicar que está gravando
    touch "$STATUS_FILE"
    
    # Executa o comando de gravação
    eval "$CMD" &
    
    # Notifica o usuário
    notify-send "📹 $DESCRIPTION" "Pressione '$mod + o' para parar."
}

case "$SELECTION" in
    "🖥️ Gravar Tela Inteira")
        # Obtém informações da tela principal
        RESOLUTION=$(xrandr --current | grep -oP '(?<=current ).*(?=,)' | awk '{print $1"x"$3}')
        
        # Define o arquivo de saída
        MKV_FILE="$DIR/recording_$(date +'%Y-%m-%d_%H-%M-%S').mkv"
        echo "$MKV_FILE" > "$TEMP_FILE"
        
        # Inicia a gravação da tela inteira
        CMD="ffmpeg -f x11grab -video_size $RESOLUTION -i :0.0 -c:v libx264 -preset ultrafast -qp 0 \"$MKV_FILE\""
        start_recording "$CMD" "Gravando Tela Inteira"
        ;;
        
    "🎥 Gravar Janela Ativa")
        # Obtém o ID da janela ativa
        WIN_ID=$(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')
        
        # Obtém geometria da janela
        GEOM=$(xwininfo -id "$WIN_ID" | awk '
            /Absolute upper-left X:/ {x=$NF}
            /Absolute upper-left Y:/ {y=$NF}
            /Width:/ {w=$NF}
            /Height:/ {h=$NF}
            END {print x "," y "," w "," h}')
        
        IFS=',' read -r X Y W H <<< "$GEOM"
        
        # Define o arquivo de saída
        MKV_FILE="$DIR/recording_$(date +'%Y-%m-%d_%H-%M-%S').mkv"
        echo "$MKV_FILE" > "$TEMP_FILE"
        
        # Inicia a gravação da janela ativa
        CMD="ffmpeg -f x11grab -video_size ${W}x${H} -i :0.0+${X},${Y} -c:v libx264 -preset ultrafast -qp 0 \"$MKV_FILE\""
        start_recording "$CMD" "Gravando Janela Ativa"
        ;;
        
    "🎯 Gravar Seleção")
        # Usa slop para permitir a seleção da área
        GEOM=$(slop -f "%x,%y,%w,%h")
        if [[ -z "$GEOM" ]]; then
            notify-send "❌ Cancelado" "Nenhuma área selecionada."
            exit 0
        fi
        
        IFS=',' read -r X Y W H <<< "$GEOM"
        
        # Define o arquivo de saída
        MKV_FILE="$DIR/recording_$(date +'%Y-%m-%d_%H-%M-%S').mkv"
        echo "$MKV_FILE" > "$TEMP_FILE"
        
        # Inicia a gravação da área selecionada
        CMD="ffmpeg -f x11grab -video_size ${W}x${H} -i :0.0+${X},${Y} -c:v libx264 -preset ultrafast -qp 0 \"$MKV_FILE\""
        start_recording "$CMD" "Gravando Área Selecionada"
        ;;
        
    "🎙️ Gravar Tela Com Áudio")
        # Obtém informações da tela principal
        RESOLUTION=$(xrandr --current | grep -oP '(?<=current ).*(?=,)' | awk '{print $1"x"$3}')
        
        # Define o arquivo de saída
        MKV_FILE="$DIR/recording_$(date +'%Y-%m-%d_%H-%M-%S').mkv"
        echo "$MKV_FILE" > "$TEMP_FILE"
        
        # Inicia a gravação da tela com áudio
        CMD="ffmpeg -f x11grab -video_size $RESOLUTION -i :0.0 -f pulse -i default -c:v libx264 -preset ultrafast -c:a aac -b:a 128k \"$MKV_FILE\""
        start_recording "$CMD" "Gravando Tela Com Áudio"
        ;;
        
    *)
        notify-send "❌ Cancelado" "Nenhuma ação foi selecionada."
        exit 0
        ;;
esac
