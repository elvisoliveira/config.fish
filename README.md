# config.fish
My fish shell setup.

```
fish install.fish   # one symlink per file into ~/.config/fish (idempotent)
```

Re-run it after adding or removing a file. Edit the files here, not the
symlinks: `sed -i` on a link replaces it with a plain file and forks it.
