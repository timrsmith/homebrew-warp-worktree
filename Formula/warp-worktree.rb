class WarpWorktree < Formula
  desc "Open Warp terminal tabs in Claude Code git worktrees (warp-here, cw, cwa)"
  homepage "https://github.com/timrsmith/homebrew-warp-worktree"
  # For a tagged release: point url at the tag tarball and fill in its sha256
  # (see "Cutting a release" in the README). Until then, install with --HEAD.
  url "https://github.com/timrsmith/homebrew-warp-worktree/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "REPLACE_WITH_TARBALL_SHA256"
  license "MIT"
  head "https://github.com/timrsmith/homebrew-warp-worktree.git", branch: "main"

  depends_on :macos

  def install
    bin.install "bin/warp-here", "bin/cw", "bin/cwa", "bin/cwrm", "bin/cwsweep"
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
        cw <name>         open a tab IN .claude/worktrees/<name> running Claude
                          (creates it if needed); on exit, prompts to remove it
                          if it's clean + pushed
        cwa [name]        same, for every (or one) .claude/worktrees/*
        cwrm [--force] <name>   remove a worktree + branch (refuses if dirty/unpushed)
        cwsweep [-n]      remove all clean + pushed worktrees (bulk tidy-up)

      Override what runs in the tab:  WARP_HERE_CMD='claude --resume' warp-here
    EOS
  end

  test do
    assert_match "usage: cw", shell_output("#{bin}/cw 2>&1", 1)
  end
end
