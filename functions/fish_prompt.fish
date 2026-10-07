function fish_prompt
    set_color $fish_color_cwd
    echo -n (prompt_pwd)
    set_color normal

    # Git ref: branch name, falling back to the short commit hash (detached).
    set -l git_ref (command git symbolic-ref --quiet --short HEAD 2>/dev/null)
    if test -z "$git_ref"
        set git_ref (command git rev-parse --short HEAD 2>/dev/null)
    end
    if test -n "$git_ref"
        echo -n -s ' [' (set_color purple) $git_ref (set_color normal) ']'
    end

    echo -n ' $ '
end
