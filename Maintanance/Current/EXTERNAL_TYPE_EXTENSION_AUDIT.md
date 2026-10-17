# 外部所有型Extension監査

最終更新: 2026-10-07 / Codex

この文書は未完clusterの状態と再開条件だけを保持する。Gate A/Bの抽出、各batchの実装結果、
独立レビュー、compile実験を含む2026-10-07までの全文は
`../Archived/EXTERNAL_TYPE_EXTENSION_AUDIT_HISTORY_2026-10-07.md`へ移した。

## Current status

| cluster | 状態 | 現在地 | 再開条件 |
| --- | --- | --- | --- |
| 特殊化`Result`のpublic比較overloadとpublic `Result._NodePtr` | 完了 | 比較overloadをpackage／testへ閉じ、typealiasを`@usableFromInline package`へ縮小。性能job成功まで確認 | 完了済み。再開しない |
| Debug限定Comparable群 | 凍結 | `Result: @retroactive Comparable`は削除済み。残る`_LazyTieWrap`、`_NodePtrSealing`、`_LazyTie`を別clusterとして保持 | Indexの`Comparable`方針確定後 |
| Balanced群 | 凍結 | Debug限定protocol、適合、診断用APIの処遇が未決 | Index契約またはexecutable API Matrix方針の確定後 |
| Memoize群 | EXCLUDED（整理） | 2026-10-16ユーザー判断で非公開化・削除検討を残作業から除外。依存調査の成果は保持し、現行APIは変更しない | 待ち条件・後続必須作業として残さない |
| SignedDistance protocol cluster | 凍結 | access-only縮小は言語制約上成立しないことを実験済み | public protocol clusterまたはIndex設計を扱う明示的な再開指示 |

## Completed Result cleanup

- `_SafePtr`・`_SealedPtr`用の特殊化`Result`比較overloadをpackageへ縮小した。
- `_LazyTieWrappedPtr`用overloadと旧Result-based Index helperをtest側へ移した。
- `Result._NodePtr`を`@usableFromInline package`へ縮小した。
- 標準の`Equatable`適合により、外部利用者の比較結果は変わらない。
- Debug / Release / 互換mode / DocCを検証した。
- GitHub Actions performance job成功（run 37502938888、job 112404281751、5分34秒）を確認した。

## Remaining decisions

### Debug限定Comparable群

正式なIndex `Comparable`採否と同時に扱う。標準型へのretroactive conformanceは既に除去済みであり、
残る3宣言をこの完了済みResult cleanupへ戻さない。

### Balanced群

Debugだけに存在する抽象化とinstrumentationである。削除、TestSupport移動、仕様修正のいずれにするかを
executable API MatrixまたはIndex契約の方針と合わせて決める。

### Memoize群（整理により対象外）

2026-10-16のユーザー委任による[依存調査](MEMOIZE_DEPENDENCY_INVESTIGATION.md)で、現行LRUに実利用があることと、Memoizationの旧実験経路には既に存在しないAPIが残ることを確認した。旧記載の「外部consumer 2件の移行後」という一律の待ち条件を訂正する。repository内参照がtestだけであることを、単独で非公開化する根拠にしない。現行LRUの削除・公開縮小や外部移行は今回実施していない。

2026-10-16、調査結果を受けたユーザー判断により、非公開化・削除検討自体を`EXCLUDED`として整理した。未完の監査判断や移行ゲートとして扱わない。APIを削除したという完了記録ではない。

## Rules retained from the audit

- 外部所有型へのpublic member追加とretroactive conformanceを区別する。
- DebugとReleaseで公開protocol conformance集合を変えない。
- `@inlinable`から参照される境界はsource公開と同一ではないが、自由な実装詳細ともみなさない。
- test-only conformanceもtest process全体へ影響するため最小限にする。
- Index表現、Range/View、deprecated互換経路を同名だけで統合しない。
- 過去の監査表や「次task」は履歴であり、Task Registryなしに作業を再開しない。

## Completion conditions for the remaining audit

1. 外部所有型へ追加する公開メンバーとprotocol conformanceが現行sourceに対して再抽出されている。
2. 各項目が製品API、境界内部、完全な内部用途のいずれかに分類されている。
3. 意図しない公開メンバーとretroactive conformanceが除去されている。
4. DebugとReleaseの差が診断コードだけに限定され、公開適合の集合を変えない。

## Main sources

- `Sources/PermutationModule/NextPermutations.swift`
- `Sources/RedBlackTreeCollections/Implements/RawBuffer/`
- `Sources/RedBlackTreeCollections/Implements/__tree/`
- `Sources/RedBlackTreeCollections/Implements/Protocol/BalancedSequence.swift`
- `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md`

## 棚卸し追記（2026-10-17 / 姫・Opus 5.5 / CP-20261017-013・浅い点検）

本文は書き換えていない。追記範囲はOPS-072の立案（`PROVISIONAL_AGREEMENT_JUDGMENT_INVENTORY_PILOT.md`）に従う。

- 修正案：本文の`Sources/PermutationModule/…`は`1f87e37a`（2026-10-15）で`Sources/NextPermutationModule/…`へ移動済み（現行：`Sources/NextPermutationModule/NextPermutations.swift`）。
- 点検事実：`ls Sources/NextPermutationModule/NextPermutations.swift`。
- 中身の主張（API・手順）は今回見ていない（深い点検は後回し）。結果一覧：`Evidence/CP-20261017-013/SHALLOW_CHECK.md`。

## 棚卸し追記2（2026-10-17 / 姫・Opus 5.5 / OPS-074第2区切り）

追記時の占有確認：Registryに紐づくtaskなし。本文は変更しない。

- 更新のきっかけ：Main sourcesに挙げたパスの移動・改名、または凍結clusterの再開指示。
- 見直す範囲：Main sourcesの`Sources/PermutationModule/NextPermutations.swift`の1行（現行`Sources/NextPermutationModule/NextPermutations.swift`）。他の4パスは入力版`1bdbbd4f`で実在。
- 変更がない間：上記は存在の確認だけで、監査の中身（Debug限定Comparable等）の現状は今回見ていない。明細：`Evidence/OPS-074/README.md`の#5。
