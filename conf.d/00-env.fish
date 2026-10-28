# Environment, PATH, aliases, key bindings.
# Numeric prefix 00 ensures this runs before 50-interactive.fish (and before
# lettered conf.d snippets), so PATH is ready when those need pyenv/node/etc.

# Remove greeting
set -g fish_greeting

# Add vim key bind
fish_vi_key_bindings

# Toolchains live in /files/tools (own partition). Every manager finds its dir
# through the env var set here — resolve paths via these vars, not by guessing.
set -gx PYENV_ROOT /files/tools/pyenv
set -gx WORKON_HOME /files/tools/virtualenvs
set -gx RBENV_ROOT /files/tools/rbenv
set -gx SDKMAN_DIR /files/tools/sdkman
set -gx GRADLE_USER_HOME /files/tools/gradle
set -gx NVM_DIR /files/tools/nvm            # bash nvm; fish uses nvm.fish ($nvm_data)
set -gx CARGO_HOME /files/tools/cargo
set -gx RUSTUP_HOME /files/tools/rustup
set -gx DENO_INSTALL /files/tools/deno
set -gx PHPBREW_ROOT /files/tools/phpbrew
set -gx PHPBREW_HOME /files/tools/phpbrew
set -gx CODEX_HOME /files/tools/codex
# Caches live on /files too (XDG_CACHE_HOME covers pip, composer, huggingface, fish,
# wezterm, browsers…; npm reads ~/.npmrc `cache=`; kubectl reads KUBECACHEDIR).
set -gx XDG_CACHE_HOME /files/cache
set -gx KUBECACHEDIR /files/cache/kube
set -gx YARN_GLOBAL_FOLDER /files/cache/yarn   # yarn berry global cache (was ~/.yarn/berry)

# Dotfiles pushed out of ~ into XDG dirs (2026-10-28). git reads ~/.config/git/config natively.
set -gx WGETRC $HOME/.config/wgetrc                 # sets hsts-file -> ~/.local/state/wget/hsts
set -gx W3M_DIR $HOME/.config/w3m
set -gx RANDFILE $XDG_CACHE_HOME/openssl.rnd        # openssl 1.1 tools' ~/.rnd
set -gx PASSWORD_STORE_DIR $HOME/.local/share/password-store
set -gx TMUX_PLUGIN_MANAGER_PATH $HOME/.local/share/tmux/plugins   # tpack/tpm (also set in .tmux.conf)

set -gx EDITOR nvim
set -gx VIRTUAL_ENV_DISABLE_PROMPT 1
set -gx BUN_INSTALL /files/tools/bun

# gcloud needs python; pin it to the pyenv-managed interpreter only when that
# specific install is present, otherwise leave gcloud to use its bundled one.
if test -x $PYENV_ROOT/versions/3.11.9/bin/python
    set -gx CLOUDSDK_PYTHON $PYENV_ROOT/versions/3.11.9/bin/python
end

fish_add_path -gm $RBENV_ROOT/bin
fish_add_path -gm $RBENV_ROOT/shims
fish_add_path -gm $BUN_INSTALL/bin
fish_add_path -gm $CARGO_HOME/bin
fish_add_path -ga /files/tools/maestro/bin
# Node (nvm.fish) is activated at the END of 50-interactive.fish, on purpose:
# it must run AFTER the legacy virtualenv activate.fish sourced there, which
# restores a stale PATH snapshot and would otherwise clobber the node setup.
fish_add_path -gm $PYENV_ROOT/bin
fish_add_path -gm $HOME/.local/bin

# Android SDK + Go
set -gx ANDROID_HOME /files/tools/android/sdk
set -gx ANDROID_SDK_ROOT /files/tools/android/sdk
set -gx GOPATH /files/tools/go
fish_add_path -gm $GOPATH/bin

alias vi="nvim"
if command -q eza
    alias ls="eza --icons"
end
# alias grep="rg -n --glob '!{.git,node_modules,vendor,dll,build,coverage}'"
alias boldssh="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

if command -q scrcpy
    alias scrcpy="scrcpy --max-size 800 --video-bit-rate 2M --keyboard=uhid"
    # Navegador do Android como janela de desktop: display virtual só com o IronFox
    # (Firefox hardened), sem barras do Android, janela tiled normal (SDL_APP_ID
    # foge da regra floating do sway). `env` pula o alias acima.
    alias scrcpy-desktop="env SDL_APP_ID=scrcpy-desktop scrcpy --new-display=1872x1008/160 --no-vd-system-decorations --video-codec=h265 --video-bit-rate=20M --max-fps=60 --keyboard=uhid --mouse=sdk --mouse-bind=++++ --start-app=org.ironfoxoss.ironfox"
end

if command -q zoxide
    zoxide init --cmd cd fish | source
end

# sudo without a tty: password popup on the active tmux client (see ~/.env/.tmux.conf/bin/askpass/README.md)
set -gx SUDO_ASKPASS $HOME/.env/.tmux.conf/bin/askpass/askpass-tmux

# firefox launched from a terminal: no crashhelper process
set -gx MOZ_CRASHREPORTER_DISABLE 1
