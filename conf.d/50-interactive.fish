# Interactive-session startup. Runs after 00-env.fish (numeric prefix ordering),
# so PATH already has pyenv/node when the inits below need them.
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

    if test -f $WORKON_HOME/python3/bin/activate.fish
        source $WORKON_HOME/python3/bin/activate.fish
    end

    if test -f $PHPBREW_HOME/phpbrew.fish
        source $PHPBREW_HOME/phpbrew.fish
    end
    # phpbrew PHPs were compiled with ~/.phpbrew as ini path + scan dir; after the
    # move to /files/tools PHPRC/PHP_INI_SCAN_DIR must point at the relocated
    # files. Follows `phpbrew use/switch` via PHPBREW_PHP.
    function __phpbrew_phprc --on-variable PHPBREW_PHP
        set -gx PHP_INI_SCAN_DIR $PHPBREW_ROOT/php/$PHPBREW_PHP/var/db
        for f in $PHPBREW_ROOT/php/$PHPBREW_PHP/etc/cli/php.ini $PHPBREW_ROOT/php/$PHPBREW_PHP/etc/php.ini
            test -f $f; and set -gx PHPRC $f; and return
        end
    end
    set -q PHPBREW_PHP; and __phpbrew_phprc

    # Node LAST — after the inits above. nvm.fish auto-activates the default only
    # when nvm_current_version is unset; a shell spawned from an env that exports
    # it (from within claude / another node tool) inherits the marker without the
    # bin on PATH. Worse, the virtualenv activate.fish above restores a stale
    # _OLD_VIRTUAL_PATH snapshot (from when v18 was default), wiping any earlier
    # node setup. So force the default here, once everything else has touched PATH.
    if set -q nvm_default_version
        set --erase nvm_current_version
        nvm use --silent $nvm_default_version
    end
    # Sandboxed wrappers in ~/.local/bin (auggie, …) must shadow the same names in nvm's bin.
    fish_add_path -gm $HOME/.local/bin
end
