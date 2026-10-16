# Intentionally minimal.
#
# All configuration lives in this module's conf.d/ and functions/, which are
# symlinked into ~/.config/fish by install.fish and loaded natively by fish:
#   conf.d/00-env.fish         env, PATH, aliases, key bindings
#   conf.d/50-interactive.fish interactive-session init (pyenv/node/phpbrew/...)
#   functions/*.fish           lazily autoloaded functions
#
# Machine/OS-specific paths go in ~/.config/fish/conf.d/10-local.fish, a plain
# file (not versioned) that fish loads natively between 00-env and 50-interactive.
#
# fish sources conf.d/ before config.fish, so nothing portable belongs here.
# See AGENTS.md. Run `fish install.fish` after adding/removing files.
