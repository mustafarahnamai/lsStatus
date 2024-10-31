#!/bin/bash

get_speed() {
    local interface=$1
    if [[ $(cat /sys/class/net/$interface/operstate) == "up" ]]; then
        local rx_bytes=$(cat /sys/class/net/$interface/statistics/rx_bytes)
        local tx_bytes=$(cat /sys/class/net/$interface/statistics/tx_bytes)
        sleep 1
        local new_rx_bytes=$(cat /sys/class/net/$interface/statistics/rx_bytes)
        local new_tx_bytes=$(cat /sys/class/net/$interface/statistics/tx_bytes)
        local rx_speed=$(( new_rx_bytes - rx_bytes ))
        local tx_speed=$(( new_tx_bytes - tx_bytes ))

        # Determine appropriate units for download speed
        if (( rx_speed >= 1073741824 )); then
            rx_speed=$(awk "BEGIN {printf \"%.1f GiB/s\", $rx_speed / 1073741824}")
        elif (( rx_speed >= 1048576 )); then
            rx_speed=$(awk "BEGIN {printf \"%.1f MiB/s\", $rx_speed / 1048576}")
        elif (( rx_speed >= 1024 )); then
            rx_speed=$(awk "BEGIN {printf \"%.1f KB/s\", $rx_speed / 1024}")
        else
            rx_speed=$(awk "BEGIN {printf \"%d B/s\", $rx_speed}")
        fi

        # Determine appropriate units for upload speed
        if (( tx_speed >= 1073741824 )); then
            tx_speed=$(awk "BEGIN {printf \"%.1f GiB/s\", $tx_speed / 1073741824}")
        elif (( tx_speed >= 1048576 )); then
            tx_speed=$(awk "BEGIN {printf \"%.1f MiB/s\", $tx_speed / 1048576}")
        elif (( tx_speed >= 1024 )); then
            tx_speed=$(awk "BEGIN {printf \"%.1f KB/s\", $tx_speed / 1024}")
        else
            tx_speed=$(awk "BEGIN {printf \"%d B/s\", $tx_speed}")
        fi

        echo "↑ ${tx_speed} | ↓ ${rx_speed}"
    else
        echo "No active network"
    fi
}

interfaces=$(ls /sys/class/net)
wifi_interface=""
eth_interface=""

for interface in $interfaces; do
    if [[ $interface == wl* ]]; then
        wifi_interface=$interface
    elif [[ $interface == en* || $interface == eth* ]]; then
        eth_interface=$interface
    fi
done

wifi_speed=$(get_speed $wifi_interface)
eth_speed=$(get_speed $eth_interface)

if [[ "$eth_speed" != "No active network" ]]; then
    echo "LAN: $eth_speed"
elif [[ "$wifi_speed" != "No active network" ]]; then
    echo "WLAN: $wifi_speed"
else
    echo "No active network"
fi

