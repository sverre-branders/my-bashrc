#! /bin/bash

if ! ( [[ $(type -P iwconfig) ]]  && [[ $(type -P iwlist) ]] ); then
    echo "Please make sure iwconfig and iwlist are installed"
    exit 1
fi

iface=$(iwconfig 2>/dev/null | grep 'ESSID' | awk '{print $1}')

# ubuntu: apt install net-tools
# ubuntu: apt install isc-dhcp-client
echo "Enabling wireless interface $iface"
sudo ifconfig $iface up

#TODO option to disconnect and shut of the if

# Use awk to parse the data

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
access_point_ESSID=$(
    sudo iwlist $iface scan | \
    awk -f $SCRIPT_DIR/parse_iwlist.awk | \
    awk -f $SCRIPT_DIR/parse_best_connections.awk | \
    fzf \
    | awk -F'|' '{ print $1}'
)

echo "Attempting to connect to $access_point_ESSID"
read -sp "Please enter wifi password: " password

echo "$password"

wpa_passphrase "$access_point_ESSID" "$password" | sudo tee /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null || { echo "ERROR: wpa_supplicant failed"; exit 1; }

# For relatively modern wireless cards the wpa_supplicant 'driver' should be nl80211
sudo wpa_supplicant -B -D"nl80211" -i"$iface" -c/etc/wpa_supplicant/wpa_supplicant.conf

sudo dhclient

