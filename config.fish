# Remove greeding
set -g fish_greeting

# Add vim key bind
fish_vi_key_bindings

set -gx PYENV_ROOT $HOME/.pyenv

set -gx EDITOR nvim
set -gx VIRTUAL_ENV_DISABLE_PROMPT 1
set -gx BUN_INSTALL $HOME/.bun

# gcloud needs python; pin it to the pyenv-managed interpreter only when that
# specific install is present, otherwise leave gcloud to use its bundled one.
if test -x $PYENV_ROOT/versions/3.11.9/bin/python
    set -gx CLOUDSDK_PYTHON $PYENV_ROOT/versions/3.11.9/bin/python
end

fish_add_path -gm $HOME/.rbenv/bin
fish_add_path -gm $HOME/.rbenv/shims
fish_add_path -gm $BUN_INSTALL/bin
fish_add_path -gm $HOME/.nvm/versions/node/v24.8.0/bin
fish_add_path -gm $PYENV_ROOT/bin
fish_add_path -gm $HOME/.local/bin

# GNU coreutils ls uses --color, BSD ls (macOS) uses -G. Same intent, two
# flags, so split by platform.
if test (uname) = Darwin
    alias ls="ls -G"
else
    alias ls="ls --color=always"
end
alias vi="nvim"
alias grep="grep -n --exclude-dir={.git,node_modules,vendor,dll,build,coverage}"
alias boldssh="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

if command -q scrcpy
    alias scrcpy="scrcpy --max-size 800 --video-bit-rate 2M --keyboard=uhid"
end

if command -q ranger
    alias ranger="ranger --choosedir=\"$HOME/.rangerdir\"; cd (cat $HOME/.rangerdir)"
end

function copy
    if test (count $argv) -gt 0
        set x (string join " " -- $argv | string trim --)
    else
        read -lz a
        set x (string trim -- $a)
    end

    set x (string replace -ar '[\n\t\r]+' '' -- $x)

    # Bare TTY (no display server) inside tmux: route to the paste buffer.
    # The graphical tools below would all fail, but tmux works anywhere.
    if test -z "$DISPLAY"; and test -z "$WAYLAND_DISPLAY"; and set -q TMUX; and command -q tmux
        printf '%s' "$x" | tmux load-buffer -
        return
    end

    # Wayland (Linux). Checked before pbcopy/clip.exe in case a user has
    # those installed alongside Wayland for some reason.
    if set -q WAYLAND_DISPLAY; and command -q wl-copy
        printf '%s' "$x" | wl-copy
        printf '%s' "$x" | wl-copy --primary
        return
    end

    # macOS
    if command -q pbcopy
        printf '%s' "$x" | pbcopy
        return
    end

    # WSL
    if command -q clip.exe
        printf '%s' "$x" | clip.exe
        return
    end

    # X11 (Linux)
    if command -q xsel
        for i in --primary --secondary --clipboard
            printf '%s' "$x" | xsel --input $i
        end
        return
    end

    if command -q xclip
        printf '%s' "$x" | xclip -selection clipboard
        printf '%s' "$x" | xclip -selection primary
        return
    end

    echo "copy: no clipboard tool found (tried tmux, wl-copy, pbcopy, clip.exe, xsel, xclip)" >&2
    return 1
end

function c
    copy $argv
end

# function ls -l pattern
#     ls -lhagG --color=always | sed -re 's/^[^ ]* //'
# end

function fish_prompt
    # echo -n (whoami)'@'(hostname)':'
    echo -n (set_color $fish_color_cwd)(prompt_pwd) '$ '
end

function fish_right_prompt
    if set -q __prompt_php_version
        echo -n -s ' ' $__prompt_php_version
    end

    if set -q VIRTUAL_ENV
        if not set -q __prompt_python_env; or test "$__prompt_python_env" != "$VIRTUAL_ENV"
            set -g __prompt_python_env $VIRTUAL_ENV
            set -g __prompt_python_version (python -V 2>&1 | string replace 'Python ' '')
        end

        if set -q __prompt_python_version
            echo -n -s  '  ' $__prompt_python_version
        end
    else
        set -e __prompt_python_env __prompt_python_version
    end

    if set -q __prompt_node_version
        echo -n -s '  ' $__prompt_node_version
    end

    set -l GIT_REF (command git symbolic-ref --quiet --short HEAD 2>/dev/null)

    if test -z "$GIT_REF"
        set GIT_REF (command git rev-parse --short HEAD 2>/dev/null)
    end

    if test -n "$GIT_REF"
        echo -n -s  ' ' (set_color normal) '[' (set_color purple) $GIT_REF (set_color normal) ']'
    end
end

if status --is-interactive
    # Default autosuggestion grey is unreadable on the Linux console.
    # Inside tmux $TERM is tmux-*; ask the attached client for its real TERM.
    set -l outer_term $TERM
    if set -q TMUX
        set outer_term (command tmux display-message -p '#{client_termname}' 2>/dev/null)
    end
    if test "$outer_term" = linux
        set -g fish_color_autosuggestion cyan
    end

    if command -q pyenv
        pyenv init - fish --no-rehash | source
    end

    if test -f ~/.virtualenvs/python3/bin/activate.fish
        source ~/.virtualenvs/python3/bin/activate.fish
    end

    if test -f ~/.phpbrew/phpbrew.fish
        source ~/.phpbrew/phpbrew.fish
    end

    if test -f ~/.cache/wal/colors.fish
        source ~/.cache/wal/colors.fish
    end

    if set -q PHPBREW_PHP
        set -g __prompt_php_version (string replace 'php-' '' -- $PHPBREW_PHP)
    end

    if command -q node
        set -g __prompt_node_version (node -v 2>/dev/null)
    end
end

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

