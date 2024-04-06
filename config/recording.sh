#! /bin/bash

scr-rec() {
	A="alsa_output.usb-Focusrite_Scarlett_2i2_USB-00.analog-stereo.monitor"
	F="$(date +%F-%H-%M).mkv"
	ffmpeg -f x11grab -i :0.0 -f pulse -i "$A" -f pulse -i default "$F"
}

a-rec() {
	A="alsa_output.usb-Focusrite_Scarlett_2i2_USB-00.analog-stereo.monitor"
	F="$(date +%F-%H-%M).mp3"
	ffmpeg -f pulse -i "$A" -f pulse -i default "$F"
}

