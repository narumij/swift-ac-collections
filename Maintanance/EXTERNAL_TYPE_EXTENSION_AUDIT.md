# 外部所有型Extension監査

最終更新: 2026-10-07 / Codex

この文書は未完clusterの状態と再開条件だけを保持する。Gate A/Bの抽出、各batchの実装結果、
独立レビュー、compile実験を含む2026-10-07までの全文は
`Archived/EXTERNAL_TYPE_EXTENSION_AUDIT_HISTORY_2026-10-07.md`へ移した。

## Current status

| cluster | 状態 | 現在地 | 再開条件 |
| --- | --- | --- | --- |
| 特殊化`Result`のpublic比較overloadとpublic `Result._NodePtr` | 完了 | 比較overloadをpackage／testへ閉じ、typealiasを`@usableFromInline package`へ縮小。性能job成功まで確認 | 完了済み。再開しない |
| Debug限定Comparable群 | 凍結 | `Result: @retroactive Comparable`は削除済み。残る`_LazyTieWrap`、`_NodePtrSealing`、`_LazyTie`を別clusterとして保持 | Indexの`Comparable`方針確定後 |
| Balanced群 | 凍結 | Debug限定protocol、適合、診断用APIの処遇が未決 | Index契約またはexecutable API Matrix方針の確定後 |
| Memoize群 | 凍結 | repository内部のproduction利用はないが外部consumerが存在 | 外部consumer 2件の移行後 |
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

### Memoize群

`swift-ac-memoize`と`Memoization`の移行が終わるまで互換維持対象とする。repository内参照がtestだけで
あることを、単独で非公開化する根拠にしない。

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

- `Sources/PermutationModule/Permutations.swift`
- `Sources/RedBlackTreeCollections/Implements/RawBuffer/`
- `Sources/RedBlackTreeCollections/Implements/__tree/`
- `Sources/RedBlackTreeCollections/Implements/Protocol/BalancedSequence.swift`
- `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md`
