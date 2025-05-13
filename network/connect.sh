#! /bin/bash


iface=$(iwconfig 2>/dev/null | grep 'ESSID' | awk '{print $1}')

# ubuntu: apt install net-tools
echo "Enabling wireless interface $iface"
sudo ifconfig $iface up

#TODO option to disconnect and shut of the if

# Use awk to parse the data

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
access_point_ESSID=$(sudo iwlist $iface scan | awk -f $SCRIPT_DIR/parse_iwlist.awk | awk -f $SCRIPT_DIR/parse_best_connections.awk | fzf | awk -F'|' '{ print $1}')

echo "Attempting to connect to $access_point_ESSID"


