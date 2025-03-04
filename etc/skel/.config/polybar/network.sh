#!/bin/bash

# Encontra interfaces Ethernet (começa com 'e', 'en' ou 'eth')
eth_interfaces=$(ls /sys/class/net | grep -E '^(e|en|eth)')

# Encontra interfaces Wi-Fi (começa com 'w' ou 'wl')
wifi_interfaces=$(ls /sys/class/net | grep -E '^(w|wl)')

# Verifica se alguma interface Ethernet está ativa
for eth in $eth_interfaces; do
    # Ignora interfaces virtuais ou não físicas (como docker)
    if [[ "$eth" == "docker"* || "$eth" == "veth"* || "$eth" == "virbr"* || "$eth" == "br-"* ]]; then
        continue
    fi
    
    eth_state=$(cat /sys/class/net/$eth/operstate 2>/dev/null)
    eth_carrier=$(cat /sys/class/net/$eth/carrier 2>/dev/null)
    
    if [[ "$eth_state" == "up" && "$eth_carrier" -eq 1 ]]; then
        echo "" Ethernet
        exit 0
    fi
done

# Verifica se alguma interface Wi-Fi está ativa
for wifi in $wifi_interfaces; do
    wifi_state=$(cat /sys/class/net/$wifi/operstate 2>/dev/null)
    
    if [[ "$wifi_state" == "up" ]]; then
        echo "  Wi-Fi"
        exit 0
    fi
done

# Se nenhuma interface estiver ativa
echo " Offline"
