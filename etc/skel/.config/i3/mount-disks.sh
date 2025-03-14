#!/bin/bash

# Script para montar automaticamente discos adicionais para o i3wm
# Salve em ~/.config/i3/mount-disks.sh

# Criar diretórios de montagem se não existirem
mkdir -p /mnt/discos/{interno,externo,nvme}
chown $USER:$USER /mnt/discos/{interno,externo,nvme} 2>/dev/null || sudo chown $USER:$USER /mnt/discos/{interno,externo,nvme}

# Detectar discos extras (excluindo o disco do sistema)
ROOT_DISK=$(findmnt / -no SOURCE | sed 's/\[.*\]//' | sed 's/[0-9]*$//')
DISKS=$(lsblk -dpno NAME | grep -v "$ROOT_DISK" | grep -E '/dev/sd|/dev/nvme')

# Notificar sobre o início da operação
notify-send "Automontagem" "Verificando discos adicionais..." -i drive-harddisk

# Função para adicionar ao fstab e montar
mount_disk() {
    local device=$1
    local fs_type=$2
    local uuid=$3
    local mount_point=$4
    
    # Verificar se já está no fstab
    if ! grep -q "$uuid" /etc/fstab; then
        # Criar ponto de montagem
        mkdir -p "$mount_point"
        
        # Adicionar ao fstab
        echo "UUID=$uuid $mount_point $fs_type defaults,user,uid=$(id -u),gid=$(id -g) 0 0" | sudo tee -a /etc/fstab >/dev/null
        
        # Montar
        sudo mount "$mount_point"
        
        notify-send "Disco configurado" "Disco $device montado em $mount_point" -i drive-harddisk
    elif ! mountpoint -q "$mount_point"; then
        # Se está no fstab mas não montado
        sudo mount "$mount_point"
        notify-send "Disco montado" "Disco $device montado em $mount_point" -i drive-harddisk
    else
        notify-send "Disco já montado" "Disco $device já configurado em $mount_point" -i drive-harddisk-symbolic
    fi
}

# Processar dispositivos
MOUNT_POINT_INDEX=1
for DISK in $DISKS; do
    # Verificar partições
    PARTS=$(lsblk -pno NAME,TYPE "$DISK" | grep part | awk '{print $1}')
    
    if [ -z "$PARTS" ]; then
        # Disco inteiro sem partições
        FS_TYPE=$(sudo blkid -s TYPE -o value "$DISK")
        UUID=$(sudo blkid -s UUID -o value "$DISK")
        
        if [ -n "$UUID" ] && [ "$FS_TYPE" != "swap" ]; then
            # Nome do dispositivo para o ponto de montagem
            DISK_NAME=$(basename "$DISK")
            MOUNT_POINT="/mnt/discos/$DISK_NAME"
            
            mount_disk "$DISK" "$FS_TYPE" "$UUID" "$MOUNT_POINT"
        fi
    else
        # Processar partições
        for PART in $PARTS; do
            FS_TYPE=$(sudo blkid -s TYPE -o value "$PART")
            UUID=$(sudo blkid -s UUID -o value "$PART")
            
            if [ -n "$UUID" ] && [ "$FS_TYPE" != "swap" ]; then
                # Nome da partição para o ponto de montagem
                PART_NAME=$(basename "$PART")
                MOUNT_POINT="/mnt/discos/$PART_NAME"
                
                mount_disk "$PART" "$FS_TYPE" "$UUID" "$MOUNT_POINT"
            fi
        done
    fi
done

# Criar atalhos simbólicos na pasta home
mkdir -p ~/Discos
for dir in /mnt/discos/*; do
    if [ -d "$dir" ]; then
        base_name=$(basename "$dir")
        if [ ! -L "$HOME/Discos/$base_name" ]; then
            ln -sf "$dir" "$HOME/Discos/$base_name"
        fi
    fi
done

notify-send "Automontagem concluída" "Todos os discos adicionais estão configurados" -i emblem-default
