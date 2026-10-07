# gv stands for grep view
# bat --theme=Dracula --color=always --highlight-line $2 $1
function gv
    # usage: grep -rn "regex" | gv
    # requires:
    # https://github.com/junegunn/fzf
    # https://github.com/sharkdp/bat
    fzf --preview='fzf-bat-preview {1} {2}' \
        --delimiter=':' \
        --no-mouse \
        --ansi \
        --color "hl:-1:underline,hl+:-1:underline:reverse" | read stdout
    set file (echo $stdout | cut -f1 -d":")
    set line (echo $stdout | cut -f2 -d":")
    if test -n "$file"
        vi +"$line" $file -c 'normal zz' < /dev/tty
    end
end
