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
        --color "hl:-1:underline,hl+:-1:underline:reverse" | read stdout
    set file (echo $stdout | cut -f1 -d":")
    set line (echo $stdout | cut -f2 -d":")
    if test -n "$file"
        vim +"$line" $file -c 'normal zz' < /dev/tty
    end
end
