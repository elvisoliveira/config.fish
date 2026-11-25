# Environment, PATH, aliases, key bindings.
# Numeric prefix 00 ensures this runs before 50-interactive.fish (and before
# lettered conf.d snippets), so PATH is ready when those need pyenv/node/etc.

# Remove greeting
set -g fish_greeting

# Add vim key bind
fish_vi_key_bindings

# Dotfiles pushed out of ~ into XDG dirs (2026-10-28). git reads ~/.config/git/config natively.
set -gx NPM_CONFIG_USERCONFIG $HOME/.config/npm/npmrc   # was ~/.npmrc
set -gx GNUPGHOME $HOME/documents/secrets/gnupg      # was ~/.gnupg (pass, gpg)
set -gx WGETRC $HOME/.config/wgetrc                 # sets hsts-file -> ~/.local/state/wget/hsts
set -gx W3M_DIR $HOME/.config/w3m
set -gx PASSWORD_STORE_DIR $HOME/.local/share/password-store
set -gx TMUX_PLUGIN_MANAGER_PATH $HOME/.local/share/tmux/plugins   # tpack/tpm (also set in .tmux.conf)

set -gx EDITOR nvim
set -gx VIRTUAL_ENV_DISABLE_PROMPT 1

# Machine-specific paths (toolchain homes, caches) come from systemd's
# environment.d, shared with bash and systemd --user. Plain KEY=VALUE lines;
# no files there (macOS) = every tool keeps its default dir.
for f in $HOME/.config/environment.d/*.conf
    for line in (string match -rv '^\s*(#|$)' <$f)
        set -l kv (string split -m1 = -- $line)
        set -gx $kv[1] $kv[2]
    end
end

# sdkman-for-fish loads sdkman without exporting; put the candidates on PATH ourselves.
# No pacman Java since 2026-10-28: 21 (default) for gradle/maven/maestro/android, 25 only for Ghidra.
if set -q SDKMAN_DIR
    set -gx JAVA_HOME $SDKMAN_DIR/candidates/java/current
    for c in java gradle maven
        test -d "$SDKMAN_DIR/candidates/$c/current/bin"; and fish_add_path -ga $SDKMAN_DIR/candidates/$c/current/bin
    end
end

# gcloud needs python; pin it to the pyenv-managed interpreter only when that
# specific install is present, otherwise leave gcloud to use its bundled one.
if test -x "$PYENV_ROOT/versions/3.11.9/bin/python"
    set -gx CLOUDSDK_PYTHON $PYENV_ROOT/versions/3.11.9/bin/python
end

set -q RBENV_ROOT; and fish_add_path -gm $RBENV_ROOT/bin $RBENV_ROOT/shims
set -q CARGO_HOME; and fish_add_path -gm $CARGO_HOME/bin
set -q PYENV_ROOT; and fish_add_path -gm $PYENV_ROOT/bin
set -q GOPATH; and fish_add_path -gm $GOPATH/bin

# sway's Xwayland needs no cookie; keeps ssh -X / xauth out of ~
test (uname) = Linux; and set -gx XAUTHORITY $XDG_RUNTIME_DIR/Xauthority

# Node (nvm.fish) is activated at the END of 50-interactive.fish, on purpose:
# it must run AFTER the legacy virtualenv activate.fish sourced there, which
# restores a stale PATH snapshot and would otherwise clobber the node setup.
fish_add_path -gm $HOME/.local/bin


alias vi="nvim"
if command -q eza
    alias ls="eza --icons"
end
alias boldssh="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

if command -q scrcpy
    # sdk keyboard + --prefer-text: uhid drops the ABNT2 /? key (HID 0x87, scrcpy#6235) and
    # SDL text input swallows dead keys, so send composed text instead of physical keys.
    alias scrcpy="scrcpy --max-size 800 --video-bit-rate 2M --keyboard=sdk --prefer-text"
    # Android browser as a desktop window: a virtual display with the browser only
    # (GeckoView renders badly on the virtual display), no Android bars, a normal tiled window (SDL_APP_ID
    # escapes the sway floating rule). `env` bypasses the alias above.
    alias scrcpy-desktop="env SDL_APP_ID=scrcpy-desktop scrcpy --new-display=1872x1008/160 --no-vd-system-decorations --video-codec=h265 --video-bit-rate=20M --max-fps=60 --keyboard=uhid --mouse=sdk --mouse-bind=++++ --start-app=io.github.jqssun.helium"
end

if command -q zoxide
    zoxide init --cmd cd fish | source
end

# sudo without a tty: password popup on the active tmux client (see ~/.env/.tmux.conf/bin/askpass/README.md)
set -gx SUDO_ASKPASS $HOME/.env/.tmux.conf/bin/askpass/askpass-tmux

# firefox launched from a terminal: no crashhelper process
set -gx MOZ_CRASHREPORTER_DISABLE 1
