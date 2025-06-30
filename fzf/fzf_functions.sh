#! /bin/bash

if [[ $(type -P fzf) ]]; then

    conda-activate-env () {
        conda activate "$(conda env list | grep -v '^#' | fzf | awk '{print $1}')"
    }

fi

