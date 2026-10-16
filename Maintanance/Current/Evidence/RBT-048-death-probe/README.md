# RBT-048 追加確認：death testで修正案のfatalErrorに届くか

2026-10-16夜 / Claude（姫）/ 未採番 `CP-20261016-012`。ユーザーの明示依頼「デスセスとの追加調査やって」による。RBT-048の判断材料を足すための補助で、判断・製品修正はしていない。

入力: HEAD `8a0c8769`、対象3実装のhashはRBT-047返却時と同じ（`465e345f`・`10edbcd3`・`531a69f6`）、修正案は`../RBT-047/fix-draft.diff`。

## 問い

修正案は「元のstorageで検査 → `ensureUnique()` → 複製後の木でindexを解決し直す」。解決し直しに失敗したら`fatalError(.invalidIndex)`にした。この分岐に、実際の使い方で届く入力があるか。現行コードではnilだった入力が、修正案でtrapに変わらないか。

## 方法

`RBT048DeathProbeTests.swift`（Swift Testingのexit test）を、一時コピー2つ（現行・修正案適用）に置いて`swift test --filter RBT048DeathProbeTests`で実行した。各probeは子プロセスで動く。trapすれば失敗、戻り値が違えば`exit(3)`で失敗になる。

共有中に呼ぶ、次の入力を試した（MultiSet 7件、MultiMap 6件）。

| probe | 入力 | 期待 |
| --- | --- | --- |
| P1 | `endIndex` | nil |
| P2 | 削除済みindex | nil |
| P3 | 有効indexで`==`不一致（MultiSetのみ） | nil |
| P4 | 共有相手`b`から取ったindexを`a`に使う | 成功 |
| P5 | 前に起きた別の複製より前に作ったindex | 成功 |
| P6 | 削除した後、同じ値を挿入（slot再利用の可能性） | nil |
| P7 | 無関係な木のindex（契約外。trapが増えないかだけ見る） | trapしない |

## 結果

| ログ | 内容 | 結果 |
| --- | --- | --- |
| `current.log` | 現行、probe 13件 | すべてpass |
| `draft.log` | 修正案、probe 13件 | すべてpass |
| `current-all-death.log` | 現行、既存の`DeathTests`全体（filter `DeathTests`） | 213件pass（9+123+18+25+38） |
| `draft-all-death.log` | 修正案、同上 | 213件pass |

- 試した入力では、修正案の`fatalError`に届いたものはない。現行でnilだった入力が、修正案でtrapに変わったものもない。
- 既存のdeath testは、現行・修正案とも全件通った。
- 一時コピー（`mktemp -d -t rbt048-death-probe`）は削除済み。

## 言えないこと

- 「届かない」の証明ではない。試した入力で届かなかった、というだけである。複製でtagが保たれる前提は、コードを読んで確かめたものではない。
- 互換構成（`COMPATIBLE_ATCODER_2025`）は対象外。death testがこの構成では無効になっている（`#if DEATH_TEST && !COMPATIBLE_ATCODER_2025`）。
- Linux、全体suiteは未確認。

## RBT-047返却の訂正

RBT-047のReturn 5で「death testは環境上skipされるものがある」と書いたのは誤り。macOSでは`DEATH_TEST`が既定で定義されている（`Package.swift` 86行）。当時の修正案検証でも、MultiSet・MultiMapのdeath test 56件が実行され、passしていた（`../RBT-047/fix-draft-normal.log`）。ログにあった`XCTSkip`は、別ファイルのコンパイル時の表示である。原Returnは固定なので、ここに訂正を置く。
