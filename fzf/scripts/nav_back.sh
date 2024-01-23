#! /bin/bash

__cd_back__() {
    generate_directory_list() {
      local num=0
      while [[ "$PWD" != "/" ]]; do
        echo "$num: $PWD"
        num=$((num + 1))
        cd ..
      done
      echo "$num: /"
    }

    dir="$(generate_directory_list | fzf --reverse --preview 'ls {2..}' --height 14 --min-height 2 --border rounded --info hidden --pointer ⮞ --marker '*' --prompt '' --color 'hl:2,marker:white,pointer:white,spinner:2' | awk -F': ' '{print $2}' || "./")" && printf 'cd -- %q' "$dir"
}
 

