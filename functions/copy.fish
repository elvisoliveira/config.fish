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
