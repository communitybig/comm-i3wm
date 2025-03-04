#!/bin/bash

eth_status=$(cat /sys/class/net/eth0/operstate 2>/dev/null)
wifi_status=$(cat /sys/class/net/wlan0/operstate 2>/dev/null)

if [ "$eth_status" = "up" ]; then
    echo ""
elif [ "$wifi_status" = "up" ]; then
    echo ""
else
    echo ""
fi

#!/bin/bash

# Interface Ethernet (usando o nome real encontrado)
eth_interface="ens3"

# Verificar status da Ethernet
eth_state=$(cat /sys/class/net/$eth_interface/operstate 2>/dev/null)
eth_carrier=$(cat /sys/class/net/$eth_interface/carrier 2>/dev/null)

# Interface Wi-Fi (caso exista)
wifi_interface=$(ls /sys/class/net | grep -E '^w')

if [[ "$eth_state" == "up" && "$eth_carrier" -eq 1 ]]; then
    echo "" Ethernet"
elif [ -n "$wifi_interface" ] && [ "$(cat /sys/class/net/$wifi_interface/operstate)" = "up" ]; then
    echo "  wi-Fi"
else
    echo "  Offline"
