# Remove greeding
set -U fish_greeting

# Add vim key bind
fish_vi_key_bindings

set -Ux PYENV_ROOT $HOME/.pyenv
set -Ux EDITOR nvim

alias ls="ls --color=always"
alias vi="nvim"

function c
    cat $argv ^/dev/null | tr -d '\n' | read -l input
    set -ql input; or set -l input $argv
    for i in "--primary" "--secondary" "--clipboard"
        echo $input | xsel --input $i
    end
end

# function ls -l pattern
#     ls -lhagG --color=always | sed -re 's/^[^ ]* //'
# end

function fish_prompt
    if set -q VIRTUAL_ENV
        echo -n -s (set_color -b blue white) "(" (basename "$VIRTUAL_ENV") ")" (set_color normal) " "
    end

    set_color normal
    echo -n (whoami)'@'(hostname)':'

    set_color $fish_color_cwd
    echo -n (prompt_pwd)

    # https://stackoverflow.com/questions/24581793/ps1-prompt-in-fish-friendly-interactive-shell-show-git-branch
    set -l GIT_BRANCH (git branch 2>/dev/null | sed -n '/\* /s///p')
    if test -n "$GIT_BRANCH"
        set_color normal
        echo -n '['
        set_color purple
        echo -n "$GIT_BRANCH"
        set_color normal
        echo -n ']'
    end

    set_color normal
    echo -n ' $ '
end

if [ -f ~/.phpbrew/phpbrew.fish ]
    source ~/.phpbrew/phpbrew.fish
end

if [ -f ~/.cache/wal/colors.fish ]
    source ~/.cache/wal/colors.fish
end

# if command -v pyenv 1>/dev/null 2>&1
#     pyenv init - | source
# end

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

vf activate python3
nvm use latest --silent
