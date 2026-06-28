# warp-worktree

Open [Warp](https://warp.dev) terminal tabs that drop straight into
[Claude Code](https://claude.com/claude-code) sessions in your git worktrees.

Three commands:

| Command           | What it does                                                                                                                                                                                                                                                     |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `warp-here [dir]` | Open a **classic** Warp terminal tab at `dir` (default `$PWD`) running `claude --continue \|\| claude` — i.e. resume that directory's most recent Claude session, or start a fresh one.                                                                          |
| `cw <name>`       | **New** `<name>` → open a tab at the repo root running `claude --worktree <name>`, so Claude creates the worktree and **cleans it up on exit** (keep/remove prompt; clean ones auto-prune). **Existing** → reopen it (tab in the worktree, `claude --continue`). |
| `cwa [name]`      | Open a tab in **every** `.claude/worktrees/*` of the current repo — or just `<name>`. Each tab resumes its own worktree's Claude session.                                                                                                                        |

Why this exists: a child process can't move its parent shell, so when Claude
works in a worktree your Warp tab doesn't follow. And the `warp://…/new_tab`
URI can't run a command (and may open Warp's Agent input). `warp-here` writes a
one-off Warp **Tab Config** (`type = "terminal"`, with `directory` and
`commands`) and opens it via `warp://tab_config/<name>` — a real shell tab, in
the worktree, already running Claude.

## Requirements (macOS)

Not installed by the formula — bring your own:

- **Warp** terminal — <https://warp.dev>
- **Claude Code** — the `claude` CLI on your `PATH`
- **git**

## Install

```sh
brew tap timrsmith/warp-worktree
brew install warp-worktree
```

Before a tagged release exists, install from the default branch:

```sh
brew install --HEAD timrsmith/warp-worktree/warp-worktree
```

## Usage

```sh
warp-here                 # tab here, resume-or-fresh Claude
warp-here /path/to/dir    # tab at a specific dir
cw my-feature             # new worktree .claude/worktrees/my-feature + tab
cwa                       # a tab for every worktree
cwa my-feature            # a tab for just that worktree
```

Overrides (env var read by `warp-here`, honored by `cw`/`cwa` too):

```sh
WARP_HERE_CMD='claude --resume'  warp-here   # interactive session picker
WARP_HERE_CMD=':'                warp-here   # just a shell, no Claude
WARP_HERE_DRY=1                  warp-here   # print the tab-config, don't open
```

`cw`/`cwa` must be run from inside the git repo; they resolve the **main**
working tree via `git rev-parse --git-common-dir`, so they work even when run
from inside a worktree.

## Cutting a release

The formula installs from a tagged tarball of this repo. To publish `vX.Y.Z`:

```sh
git tag vX.Y.Z && git push origin vX.Y.Z
# compute the tarball sha256 and paste it into Formula/warp-worktree.rb:
curl -sL "https://github.com/timrsmith/homebrew-warp-worktree/archive/refs/tags/vX.Y.Z.tar.gz" | shasum -a 256
# update `url` (vX.Y.Z) and `sha256` in the formula, then commit + push.
```

## Hacking locally

```sh
ln -sf "$PWD/bin/"* ~/.local/bin/    # symlink the three scripts onto your PATH
# or: brew install --HEAD ./Formula/warp-worktree.rb
```

## License

MIT — see [LICENSE](LICENSE).
