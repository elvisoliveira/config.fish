#!/usr/bin/env fish
#
# Symlink this module into fish's native config tree so functions/ and conf.d/
# load natively (no runtime path-resolve hack). Idempotent: re-run after adding
# or removing files. Leaves unrelated files (toolstation, nvm, plugins) alone.
#
#   fish install.fish

set -l src (path dirname (path resolve (status --current-filename)))
set -l dest $HOME/.config/fish

mkdir -p $dest/functions $dest/conf.d

# Prune our own stale symlinks: links into this module whose source file was
# removed. Leaves unrelated files (toolstation, nvm, plugins) untouched.
for dir in $dest/functions $dest/conf.d
    for f in $dir/*
        if test -L "$f"; and string match -q "$src/*" (readlink -m "$f"); and not test -e "$f"
            rm -v "$f"
        end
    end
end

# Entry point (kept minimal; real config is in conf.d/).
ln -sfrv $src/config.fish $dest/config.fish

# Autoloaded functions and startup snippets — one symlink per file.
# -r: relative links, so the tree survives a different $HOME or user.
for f in $src/functions/*.fish
    ln -sfrv $f $dest/functions/(path basename $f)
end

for f in $src/conf.d/*.fish
    ln -sfrv $f $dest/conf.d/(path basename $f)
end

echo "config.fish installed -> $dest"
