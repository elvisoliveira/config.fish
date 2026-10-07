# Environment, PATH, aliases, key bindings.
# Numeric prefix 00 ensures this runs before 50-interactive.fish (and before
# lettered conf.d snippets), so PATH is ready when those need pyenv/node/etc.

# Remove greeting
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
# Node (nvm.fish) is activated at the END of 50-interactive.fish, on purpose:
# it must run AFTER the legacy virtualenv activate.fish sourced there, which
# restores a stale PATH snapshot and would otherwise clobber the node setup.
fish_add_path -gm $PYENV_ROOT/bin
fish_add_path -gm $HOME/.local/bin

# Android SDK + Go — dirs live in ~/tools (symlink-free; env points straight there)
set -gx ANDROID_HOME $HOME/tools/android/sdk
set -gx ANDROID_SDK_ROOT $HOME/tools/android/sdk
set -gx GOPATH $HOME/tools/go
fish_add_path -gm $GOPATH/bin

alias vi="nvim"
alias ls="eza --icons"
# alias grep="rg -n --glob '!{.git,node_modules,vendor,dll,build,coverage}'"
alias boldssh="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

if command -q scrcpy
    alias scrcpy="scrcpy --max-size 800 --video-bit-rate 2M --keyboard=uhid"
end

zoxide init --cmd cd fish | source

# sudo without a tty: password popup on the active tmux client (see ~/.env/.tmux.conf/bin/askpass/README.md)
set -gx SUDO_ASKPASS $HOME/.env/.tmux.conf/bin/askpass/askpass-tmux

# firefox launched from a terminal: no crashhelper process
set -gx MOZ_CRASHREPORTER_DISABLE 1
