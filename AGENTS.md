# config.fish — agent notes

This repo is a Git submodule (`github.com/elvisoliveira/config.fish`) installed
into `~/.config/fish`. It is the **personal**, machine-agnostic fish
configuration. It loads through fish's **native** mechanisms — no runtime
path-resolve hacks.

```
config.fish/
├── config.fish                 # intentionally minimal (real config is in conf.d/)
├── conf.d/
│   ├── 00-env.fish             # env, PATH, aliases, key bindings
│   └── 50-interactive.fish     # interactive-session init (pyenv/node/phpbrew/wal/colors)
├── functions/                  # autoloaded functions, one per file
│   ├── gbr.fish copy.fish c.fish gv.fish
│   └── fish_prompt.fish fish_right_prompt.fish
├── install.fish                # idempotent symlink installer
├── AGENTS.md
└── README.md
```

## How it loads (native fish)

`install.fish` creates one symlink per file into `~/.config/fish`:

```
~/.config/fish/config.fish               -> config.fish/config.fish
~/.config/fish/functions/<name>.fish     -> config.fish/functions/<name>.fish
~/.config/fish/conf.d/<name>.fish        -> config.fish/conf.d/<name>.fish
```

Then fish loads everything on its own: `functions/` autoload lazily on first
use, `conf.d/` run at startup. There is **no** `fish_function_path` manipulation
and **no** `source` loop — do not reintroduce them.

## Rules

- **Run `fish install.fish` after adding or removing any file** so the symlink
  set matches the repo. It is idempotent and only touches this module's files.
- One function per `functions/<name>.fish`; filename must equal the function
  name (fish autoload requirement).
- `conf.d/` runs **before** `config.fish` and in **filename order**. Use the
  numeric prefix to order: `00-env.fish` sets PATH first so `50-interactive.fish`
  finds pyenv/node/etc. Keep new startup snippets in this scheme.
- `config.fish` stays minimal. Nothing portable belongs there — fish sources
  `conf.d/` before it.

## Git

- **Never commit this `AGENTS.md`.** It is local agent guidance only; leave it
  untracked (never `git add` it, never use `git add -A`/`.` without excluding it).
- **Never add co-author trailers** (`Co-Authored-By:` or similar) to commit
  messages. Commits are authored by the user alone.

## toolstation/ — do NOT merge here

`~/.config/fish/toolstation/` holds **work-specific** functions (Toolstation:
`gcpssh`, `gcpdb`, `office`, and related GCP/DNS helpers). It lives in the
parent `~/.env` repo, NOT in this submodule, and is loaded separately by
`~/.config/fish/conf.d/toolstation.fish`.

Keep it separate on purpose:
- It is employer-specific and must not leak into this public, personal repo.
- It has a different lifecycle and audience.

`install.fish` never touches `toolstation/` or its loader. When refactoring the
fish config, leave them alone unless explicitly asked.
