# Remove greeding
set -U fish_greeting

# Add vim key bind
fish_vi_key_bindings

set -Ux PYENV_ROOT $HOME/.pyenv
set -Ux EDITOR nvim
set -Ux VIRTUAL_ENV_DISABLE_PROMPT 1

alias ls="ls --color=always"
alias vi="nvim"
alias grep="grep -n --exclude-dir={node_modules,vendor,.git,dll,tests}"
alias scrcpy="scrcpy --stay-awake --turn-screen-off --max-size 800 --video-bit-rate 2M --hid-keyboard --serial ZF5236LMZK --no-audio"

function c
    read -l a
    set x (string trim -- $a)
    for i in "--primary" "--secondary" "--clipboard"
        echo $x |tr -d '\n\t\r' | xsel --input $i
    end
end

# function ls -l pattern
#     ls -lhagG --color=always | sed -re 's/^[^ ]* //'
# end

function fish_prompt
    # echo -n (whoami)'@'(hostname)':'
    echo -n (set_color $fish_color_cwd)(prompt_pwd) '$ '
end

function fish_right_prompt
    echo -n -s ' ' (php -r 'echo PHP_VERSION;')

    if set -q VIRTUAL_ENV
        echo -n -s  '  ' (echo -e "import platform\nprint(platform.python_version())" | python)
    end

    echo -n -s '  ' (node -v)

    # https://stackoverflow.com/questions/24581793/ps1-prompt-in-fish-friendly-interactive-shell-show-git-branch
    set -l GIT_BRANCH (git branch 2>/dev/null | sed -n '/\* /s///p')

    if test -n "$GIT_BRANCH"
        echo -n -s  ' ' (set_color normal) '[' (set_color purple) $GIT_BRANCH (set_color normal) ']'
    end
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

vf activate python3
nvm use v18.11.0 --silent
