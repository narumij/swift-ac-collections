# カード情報

## ID

`MS-QUALITY`

## 名前

1.0 品質判断

## 状態

- [ ] DONE

# 正本

[RedBlackTreeCollections.md](../../Quality/Profiles/RedBlackTreeCollections.md)

# 記録

途中のゲート。汎用基盤ライブラリとしての1.0採用品質を判断する。判断そのものは Task Registry の `QUALITY-001`（[DECISION]）で行い、このゲートはその結果を待つ。

- 2026-10-17 ユーザーがファイルを置き、姫が中身を埋めた（ユーザー「なんかうめて」）。ID は Task Registry の `QUALITY-001` と重ならないよう `MS-QUALITY` にした。
- 2026-10-17 ユーザー「タスクレジストリから削除しよう」により、Task Registry の `QUALITY-001` を削除し、その役目をこのゲートへ移した（姫）。前提の5本はこのゲートへつなぎ直した。

## Task Registry から移した原文（2026-10-17、逐語）

| `QUALITY-001` | `ACTIVE` | User / Codex | [DECISION] 汎用基盤ライブラリとしての1.0採用品質ゲート | 2026-10-16のユーザー棚卸し指示でゲートを有効化。Index契約、runtime-check再審査、品質アセスメント、環境別証拠を完了前に合流し、1.0として受け入れるかユーザーが判断する。Index待ちは並行可能な証拠整理を止めない。SPI登録・公開導線はSPI公開→人間レビューの経路で扱い、DOC-026・027からの直接依存は置かない（2026-10-16ユーザー編集）。SPI後の人間レビュー方針は文書Validation計画を参照し、実施範囲は同計画のレビュー結果で具体化する。材料未充足のまま合格・公開しない。 | `Maintanance/Quality/Profiles/RedBlackTreeCollections.md` |

| 後続 | 前提 | 流れ | 条件 |
| --- | --- | --- | --- |
| `QUALITY-001` | `RBT-001` | `PARALLEL_JOIN` | 品質調査は並行できるが、1.0品質判定を確定する前にIndex契約完了と合流する |
| `QUALITY-001` | `RBT-009` | `PARALLEL_JOIN` | 他の1.0品質作業は並行できるが、最終判定前にruntime-check実装の採否と合流する |
| `QUALITY-001` | `RBT-034` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、再現可能な証拠を備えた品質アセスメントの完成と合流する |
| `QUALITY-001` | `QUALITY-002` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、Linux代表環境の品質保証CIと再現可能な実行証拠を合流する |
| `QUALITY-001` | `QUALITY-003` | `PARALLEL_JOIN` | 1.0採用品質を判定する前に、Apple platforms 27のmanifest境界とplatform別build証拠を合流する |
