#! /bin/bash
# This script is used to sym link the bashrc file in this directory to ~/.bashrc

if [ $# -eq 0 ]; then
    if [ ! -e $HOME/.bashrc ]; then
        echo "Linking bashrc file"
        ln -rsf bashrc $HOME/.bashrc
    else
        echo "Warning: bashrc already exists."
        read -r -p "Are you sure you want to overwrite it? [y/N] " response
        case "$response" in
            [yY][eE][sS]|[yY])
                echo "Linking bashrc file and overwriting"
        rm $HOME/.bashrc
            ln -rsf bashrc $HOME/.bashrc
                ;;
            *)
                echo "skipped."
                ;;
        esac
    fi
    else
        echo "Run this script to link bashrc from this repository to $HOME/.bashrc"
fi

if [ $# -eq 0 ]; then
    if [ ! -e $HOME/.inputrc ]; then
        echo "Linking inputrc file"
        ln -rsf inputrc $HOME/.inputrc
    else
        echo "Warning: inputrc already exists."
        read -r -p "Are you sure you want to overwrite it? [y/N] " response
        case "$response" in
            [yY][eE][sS]|[yY])
                echo "Linking inputrc file and overwriting"
        rm $HOME/.inputrc
            ln -rsf inputrc $HOME/.inputrc
                ;;
            *)
                echo "skipped."
                ;;
        esac
    fi
    else
        echo "Run this script to link inputrc from this repository to $HOME/.inputrc"
fi
