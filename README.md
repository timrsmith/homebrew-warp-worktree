# warp-worktree

Open [Warp](https://warp.dev) terminal tabs that drop straight into
[Claude Code](https://claude.com/claude-code) sessions in your git worktrees.

Commands:

| Command                 | What it does                                                                                                                                                                                        |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `warp-here [dir]`       | Open a **classic** Warp terminal tab at `dir` (default `$PWD`) running `claude --continue \|\| claude` — resume that directory's most recent Claude session, or start a fresh one.                  |
| `cw <name>`             | Open a tab **in** `.claude/worktrees/<name>` running Claude in that worktree (creates it first if needed). When you exit Claude, you're prompted to remove the worktree **if it's clean + pushed**. |
| `cwa [name]`            | Same as `cw`, for **every** `.claude/worktrees/*` (or just `<name>`).                                                                                                                               |
| `cwrm [--force] <name>` | Remove a worktree + its branch. Refuses if it has uncommitted or unpushed changes unless `--force`.                                                                                                 |
| `cwsweep [-n]`          | Remove **every** worktree that's clean + pushed (skips dirty/unpushed). Bulk tidy-up. `-n` = dry run.                                                                                               |

Why this exists: a child process can't move its parent shell, so a Claude
session can't drag your Warp tab into a worktree, and the `warp://…/new_tab` URI
can't run a command (and may open Warp's Agent input). So `warp-here` writes a
one-off Warp **Tab Config** (`type = "terminal"`, with `directory` + `commands`)
and opens it via `warp://tab_config/<name>` — a real shell tab, already **in**
the worktree, running Claude.

`cw` deliberately creates the worktree with `git worktree add` (not
`claude --worktree`) so it exists _before_ the tab opens and the tab can sit in
it — that's what makes the Warp tab follow. The tradeoff: Claude doesn't own the
worktree, so cleanup is handled here — on Claude exit, zsh's `{ … } always { … }`
runs `cwrm --on-exit`, which prompts to remove the worktree if it's clean +
pushed (and `cwsweep` mops up the rest).

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
cwrm my-feature           # remove that worktree + branch (if clean + pushed)
cwsweep -n                # preview which worktrees would be swept
cwsweep                   # remove all clean + pushed worktrees
```

Every command accepts `-h` / `--help`.

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
