# RBT-049 証拠：ASan strip_env の固定版検証（2026-10-17 / Claude 姫）

すべて一時ディレクトリ（`mktemp -d -t hime-rbt049`）の中で実行し、終了後に worktree とディレクトリは削除した。共有 `.build` は使っていない。

| ファイル | 中身 |
| --- | --- |
| `environment.txt` | 日時、固定commit、macOS・arm64・Swift・Xcode、ASan runtime のパスとSHA-256、試験バイナリのASanリンク |
| `commands.sh` | 実行した正確なコマンド |
| `Probe-Package.swift` / `Probe.swift` | 最小package（2026-10-16の証拠と同一ファイルの写し） |
| `compiler-rt-excerpts.txt` | llvm/llvm-project `50b1c281` の該当箇所 |
| `logs/probe-*.log` | 最小Probe（既定 / strip_env=0） |
| `logs/repo-build.log` | 固定版のASanビルド（1回だけ。両条件で同じビルドを使う） |
| `logs/repo-deathtests-*.log` | `--filter DeathTests`（既定 / strip_env=0） |
| `logs/repo-internalcoverage-*.log` | `--filter RedBlackTreeInternalCoverageTests`（既定 / strip_env=0） |

各ログの1行目は実行コマンド、最終行は `exit=<終了status>`。
