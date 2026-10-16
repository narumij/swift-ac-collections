# ASan＋Death Testが子プロセスでSIGABRTになる原因：ASanの`strip_env`

2026-10-16夜 / Claude（姫）/ ユーザーの直接依頼（「こっそりASanの調査してて」）。Astraへの報告用。Astraの[ASan＋Death Test実行経路の調査](../../ASAN_DEATH_TEST_INVESTIGATION.md)（RBT-033）の続き。
リリース作業中だったため、リポジトリの外で調べ、リリース候補のキャンセル後にここへ移した（CP-20261016-014）。リポジトリのファイルは変更していない。製品・Tests・CIも変更していない。

## 結論

ASan runtimeには`strip_env`というオプションがあり、macOSでは既定で有効になっている。runtimeは起動時に自分のdylibを`DYLD_INSERT_LIBRARIES`から外して、子プロセスへ引き継がないようにする。

Swift Testingのexit test（death test）は、同じテストバイナリを子プロセスとして起動する。その子プロセスはASan runtimeが挿入されないまま起動し、ASanがSIGABRTで止める。

RBT-033の観察「suite初期化時のgetenvは`<unset>`」は、ASan自身が変数を消していたことで説明できる。

`ASAN_OPTIONS=strip_env=0`を付けると、子プロセスにも変数が残り、death testが成立する。このとき、ASanが本当に検出していることも確かめた（わざと起こしたheap-buffer-overflowを検出）。

## 確認した結果（macOS 27.0.1 / arm64 / Apple Swift 6.4 swiftlang-6.4.0.34.1）

| 実行 | 条件 | 結果 | ログ |
| --- | --- | --- | --- |
| 最小package（RBT-033のProbeから、復元用の`setenv`だけを外して変数を表示） | `swift test --sanitize address --build-system native` | exit 1。`cleanChild`と`trapChild`がSIGABRT。suite初期化時の変数は`<unset>`。RBT-033と同じ | `logs/probe-default.log` |
| 同上 | `ASAN_OPTIONS=strip_env=0`を追加 | exit 0。3件成功（正常終了、SIGTRAP、heap-buffer-overflowの検出）。子プロセスでも変数はASan dylibのパスのまま | `logs/probe-strip_env0.log` |
| リポジトリの写し（`.git`と`Maintanance`を除く）、`--filter DeathTests` | ASanのみ | exit 1。213件、issue 360件、うちSIGABRTが269件 | `logs/repo-deathtests-default.log` |
| 同上 | `ASAN_OPTIONS=strip_env=0`を追加 | exit 0。213件、20 suite、すべて成功 | `logs/repo-deathtests-strip_env0.log` |

使ったProbeは`Probe.swift`。Packageは`../../ASAN_DEATH_TEST_EVIDENCE_2026-10-16/Package.swift`と同じもの。

## 修正案（採否はAstra・ユーザー）

- テストのコードやfixtureで`setenv`する必要はない。実行するときの環境変数だけで済む。RBT-033の候補案にあった注意（process全体の環境変更、並列実行、runtimeパスの固定）は、この方法では発生しない。
- ローカルで実行する場合: `ASAN_OPTIONS=strip_env=0 swift test --sanitize address --build-system native`。
- CIで使う場合: `ci.yml`のaddress-sanitizer jobは、378行で既に`ASAN_OPTIONS: detect_leaks=0:symbolize=1:abort_on_error=1:log_path=asan-logs/asan`を設定している。ここに`strip_env=0`を足す形になる。ただし現行のASan jobはLinuxで、`ENABLE_DEATH_TESTS` traitを付けていない。death testをCIのASanで走らせるなら、traitの追加も必要になる。

## 確かめていないこと

- Linux。`strip_env`はmacOSでの`DYLD_INSERT_LIBRARIES`の扱いに関するオプションで、LinuxのASan＋death testが同じ原因で失敗するかは不明。
- 全体suiteをASanで実行すること。今回は`DeathTests`のfilterに絞った。RBT-032（`36f821a4`）では`DeathTests`と`RedBlackTreeInternalCoverageTests`を除いた全体が成功している。
- `RedBlackTreeInternalCoverageTests`（名前に`DeathTests`を含まない子プロセス試験）。
- `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` traitが必要かどうか。今回は付けずに成功した。
- 写しの版。2026-10-16 22:20頃の作業ツリーで、`.git`を除いて写したためcommitは記録していない。そのときのHEADは`a5a39d12`かその直前。報告時に、対象のcommitで再実行するのがよい。
- `strip_env`の働きは、オプション名と実行結果から判断した。compiler-rtのソースでは確かめていない。

## 一時物

調査は`mktemp -d -t hime-asan-probe`のディレクトリの中で行った。報告書・Probe・ログをこのフォルダへ移した後、そのディレクトリは削除した。
