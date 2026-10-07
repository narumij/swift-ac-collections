# Permutation documentation handoff audit

最終更新: 2026-10-08 / Codex

## 目的

PermutationをCodexの利用者向け文書作業へ渡す前に、現在の公開面、仕様test、名称・契約の履歴を
独立した証拠packageとして揃える。文書の構成、使用例の選定、公開契約、互換modeとの文書境界は
この監査では決めない。

## 共通境界

- Claudeは指定された証拠表だけをこの文書へ追記する。
- `Sources/`、`Tests/`、利用者向け文書、既存の品質評価、Registryは変更しない。
- 現行実装から望ましい契約を推測せず、記録された事実と未確認を分ける。
- defect、公開契約の不一致、新しい判断点を見つけた場合は、根拠と安全な最小再現を記録して停止する。
- 別packageの不足をその場で埋めない。該当packageへの疑義として報告する。
- Codexが各packageの網羅性を検収し、利用者向け文書への入力を統合する。

## Claude assignments

### Public API and documentation ledger

対象は`Sources/PermutationModule/Permutations.swift`。`public`宣言を一件ずつ、型、member種別、source位置、
宣言上のgeneric制約、ドキュメントコメントの有無へ対応付ける。`@inlinable`など性能属性は事実列として
記録してよいが、要否を評価しない。成果物は`## Public API ledger`節の表。全宣言の件数を再集計して停止する。

### Test evidence matrix

対象は`Tests/PermutationTests/NextPermutationsSequence/`の番号付きtest。公開宣言と、列挙順、空・単要素、
重複要素、値セマンティクス、`Permutation` collection、他moduleとの共存、境界停止の既存testを対応付ける。
各testが実際に固定する事実だけを書き、未検証契約を列挙する。成果物は`## Test evidence matrix`節の表。
test追加や改名は行わない。

### Naming and contract history ledger

対象は`Permutations.swift`、上記test、`Maintanance/PermutationModule/ImplementationPlan.md`、
`ProductReadinessAssessment.md`、`AtCoder2025CompatibilityPlan.md`と、それらに直接関係するgit履歴。
現行3公開型の名称、削除済みAPI、通常版と互換modeの境界について、決定済み、履歴上の事実、未決定を
区別する。成果物は`## Naming and contract history`節の表。互換modeを再開せず、文書境界を提案しない。

## Codex intake

3 packageの完了後、Codexは次を確認する。

- 公開宣言が全件ledgerへ含まれること。
- 利用者へ約束する各契約について、test根拠または未検証の表示があること。
- 現行名称、削除済みAPI、互換modeが混同されていないこと。
- 品質評価reviewと合わせ、利用者向け文書作業で決める事項が独立していること。

検収後も、この文書自体は利用者向け文書にはしない。
