set fish_key_bindings fish_vi_key_bindings

# gv stands for grep view
function gv
    # usage: grep -rn "regex" | gv
    # requires:
    # https://github.com/junegunn/fzf
    # https://github.com/sharkdp/bat
    fzf --preview='bat --theme=Dracula --color=always {1} --highlight-line {2}' \
        --delimiter=':' \
        --ansi \
        --color "hl:-1:underline,hl+:-1:underline:reverse" \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
end
