#!/usr/bin/env bash

# Directory to save recordings
DIR="$(xdg-user-dir VIDEOS)"
[[ ! -d "$DIR" ]] && mkdir -p "$DIR"

# Files to temporarily store recording filename and status
TEMP_FILE="/tmp/ffmpeg-recorder-filename"
STATUS_FILE="/tmp/ffmpeg-recorder-status"

# Function to stop recording and convert video
stop_recording() {
    if pgrep -x "ffmpeg" > /dev/null; then
        # Kill ffmpeg process with SIGINT to properly finalize
        pkill --signal SIGINT ffmpeg
        notify-send "📹 Recording stopped" "Processing video..."
        
        # Wait for ffmpeg to completely finish
        while pgrep -x "ffmpeg" > /dev/null; do
            sleep 0.5
        done
        
        if [[ -f "$TEMP_FILE" ]]; then
            MKV_FILE=$(cat "$TEMP_FILE")
            MP4_FILE="${MKV_FILE%.mkv}.mp4"
        else
            notify-send "❌ Error" "Recording file not found!"
            rm -f "$STATUS_FILE"
            exit 1
        fi

        if [[ -f "$MKV_FILE" ]]; then
            notify-send "📦 Compressing video..." "Please wait..."
            
            # Convert MKV file to MP4 with better compression
            ffmpeg -i "$MKV_FILE" -c:v libx264 -preset fast -crf 28 -pix_fmt yuv420p -threads "$(nproc)" -y "$MP4_FILE" && {
                notify-send "✅ Video saved!" "File: $MP4_FILE"
                echo "✔ Video saved: $MP4_FILE"
                
                # Copy video path to clipboard
                echo -n "$MP4_FILE" | xclip -selection clipboard
                rm -f "$MKV_FILE"
            }
        else
            notify-send "❌ Error" "Recording file not found!"
        fi
        
        # Remove temporary files
        rm -f "$TEMP_FILE" "$STATUS_FILE"
    fi
}

# Check if already recording
if [[ -f "$STATUS_FILE" ]]; then
    stop_recording
    exit 0
fi

# If not recording, show recording mode selection menu
SELECTION=$(echo -e "🖥️ Record Full Screen\n🎥 Record Active Window\n🎯 Record Selection\n🎙️ Record Screen With Audio" | rofi -dmenu -i -no-show-icons -l 4 -width 30 -p "📹 Choose mode")

# Function to start recording
start_recording() {
    local CMD="$1"
    local DESCRIPTION="$2"
    
    # Create status file to indicate recording is in progress
    touch "$STATUS_FILE"
    
    # Execute recording command
    eval "$CMD" &
    
    # Notify user
    notify-send "📹 $DESCRIPTION" "Press '$mod + o' to stop."
}

case "$SELECTION" in
    "🖥️ Record Full Screen")
        # Get main screen information
        RESOLUTION=$(xrandr --current | grep -oP '(?<=current ).*(?=,)' | awk '{print $1"x"$3}')
        
        # Define output file
        MKV_FILE="$DIR/recording_$(date +'%Y-%m-%d_%H-%M-%S').mkv"
        echo "$MKV_FILE" > "$TEMP_FILE"
        
        # Start full screen recording
        CMD="ffmpeg -f x11grab -video_size $RESOLUTION -i :0.0 -c:v libx264 -preset ultrafast -qp 0 \"$MKV_FILE\""
        start_recording "$CMD" "Recording Full Screen"
        ;;
        
    "🎥 Record Active Window")
        # Get active window ID
        WIN_ID=$(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')
        
        # Get window geometry
        GEOM=$(xwininfo -id "$WIN_ID" | awk '
            /Absolute upper-left X:/ {x=$NF}
            /Absolute upper-left Y:/ {y=$NF}
            /Width:/ {w=$NF}
            /Height:/ {h=$NF}
            END {print x "," y "," w "," h}')
        
        IFS=',' read -r X Y W H <<< "$GEOM"
        
        # Define output file
        MKV_FILE="$DIR/recording_$(date +'%Y-%m-%d_%H-%M-%S').mkv"
        echo "$MKV_FILE" > "$TEMP_FILE"
        
        # Start active window recording
        CMD="ffmpeg -f x11grab -video_size ${W}x${H} -i :0.0+${X},${Y} -c:v libx264 -preset ultrafast -qp 0 \"$MKV_FILE\""
        start_recording "$CMD" "Recording Active Window"
        ;;
        
    "🎯 Record Selection")
        # Use slop to allow area selection
        GEOM=$(slop -f "%x,%y,%w,%h")
        if [[ -z "$GEOM" ]]; then
            notify-send "❌ Canceled" "No area selected."
            exit 0
        fi
        
        IFS=',' read -r X Y W H <<< "$GEOM"
        
        # Define output file
        MKV_FILE="$DIR/recording_$(date +'%Y-%m-%d_%H-%M-%S').mkv"
        echo "$MKV_FILE" > "$TEMP_FILE"
        
        # Start selected area recording
        CMD="ffmpeg -f x11grab -video_size ${W}x${H} -i :0.0+${X},${Y} -c:v libx264 -preset ultrafast -qp 0 \"$MKV_FILE\""
        start_recording "$CMD" "Recording Selected Area"
        ;;
        
    "🎙️ Record Screen With Audio")
        # Get main screen information
        RESOLUTION=$(xrandr --current | grep -oP '(?<=current ).*(?=,)' | awk '{print $1"x"$3}')
        
        # Define output file
        MKV_FILE="$DIR/recording_$(date +'%Y-%m-%d_%H-%M-%S').mkv"
        echo "$MKV_FILE" > "$TEMP_FILE"
        
        # Start screen recording with audio
        CMD="ffmpeg -f x11grab -video_size $RESOLUTION -i :0.0 -f pulse -i default -c:v libx264 -preset ultrafast -c:a aac -b:a 128k \"$MKV_FILE\""
        start_recording "$CMD" "Recording Screen With Audio"
        ;;
        
    *)
        notify-send "❌ Canceled" "No action was selected."
        exit 0
        ;;
esac
