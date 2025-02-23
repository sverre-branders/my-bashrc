#!/bin/bash

audio_output() {
    selected_device=$(pactl list short sinks | awk '{print $2}' | fzf --prompt="Select Audio Device:")

    if [[ -n "$selected_device" ]]; then
        pactl set-default-sink "$selected_device"
        echo "Connected to $selected_device"
    else
        return 1
    fi
}
