class WarpWorktree < Formula
  desc "Open Warp tabs into Claude Code git worktrees, with cleanup helpers"
  homepage "https://github.com/timrsmith/homebrew-warp-worktree"
  url "https://github.com/timrsmith/homebrew-warp-worktree/archive/refs/tags/v0.1.6.tar.gz"
  sha256 "5ce5793f0db6795d0efe14e1999afb92a374dd0e6e2543a9a67ec4e7f0ea84ec"
  license "MIT"
  head "https://github.com/timrsmith/homebrew-warp-worktree.git", branch: "main"

  depends_on "gum" # interactive picker + confirm TUIs
  depends_on "jq"  # read worktree.baseRef from settings
  depends_on :macos

  def install
    bin.install "bin/warp-here", "bin/cw", "bin/cwa", "bin/cwrm", "bin/cwsweep", "bin/cw-run"
  end

  def caveats
    <<~EOS
      warp-worktree needs these on your system (not installed by this formula):
        • Warp terminal   https://warp.dev
        • Claude Code     the `claude` CLI on your PATH
        • git

      Commands:
        warp-here [dir]   open a classic Warp tab at dir (default: $PWD) running
                          `claude --continue || claude`
        cw [name]         open a tab IN .claude/worktrees/<name> running Claude
                          (creates it if needed); no name → interactive picker.
                          On exit, prompts to remove it if clean + pushed
        cwa [name]        same, for every (or one) .claude/worktrees/*
        cwrm [--force] <name>   remove a worktree + branch (refuses if dirty/unpushed)
        cwsweep [-n]      remove all clean + pushed worktrees (bulk tidy-up)

      Override what runs in the tab:  WARP_HERE_CMD='claude --resume' warp-here
    EOS
  end

  test do
    assert_match "usage: cw", shell_output("#{bin}/cw --help")
    assert_match "usage: cwrm", shell_output("#{bin}/cwrm 2>&1", 1)
  end
end
