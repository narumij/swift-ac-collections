# テストメンテナンス・ダッシュボード

現在情報だけを保持する。作業規則は `Tests/CLAUDE.md`、CodexからClaudeへの依頼は
`Maintanance/CLAUDE_TASK.md`、2026-10-03以前の詳細は `Tests/TESTING_REFERENCE.md` にある。
参照資料は必要な箇所だけ検索し、通常は通読しない。

## 目的

- テストを継続的に整理し、公開APIの仕様不足や実装不具合を発見する。
- テスト成功だけで完了とせず、公開API一覧と実装に対する不足を確認する。

## 優先事項

現在のユーザー依頼と `CLAUDE_TASK.md` が最優先。その指定がない場合は次の順とする。

1. 4型のランダム試験を、参照モデル比較と操作ごとの赤黒木不変条件確認の組にする。
2. Dictionary/MultiMapの古いIndex拒否と、KeyValue Range ViewおよびMultiSet Range Viewの
   CoW後のIndex寿命を確認する。
3. コンテナとRange Viewの `elementsEqual(_:)` / `lexicographicallyPrecedes(_:)` を
   Test as Specificationとして確認する。
4. 待ち時間にはBareArrayModuleとAcCollections公開facadeを、境界、寿命、CoW、
   Sendable/Codable、Debug/Release、Death Testの観点でレビューする。

## 現在地

- OptionalArrayModule: Release実行、Death Test、参照型寿命、公開API化漏れを対応済み。
- BareArrayModule: 体系的レビュー待ち。AcCollections: 未着手。
- PermutationModule: 構造判断が先に必要なため自発作業の対象外。
- RedBlackTree: 4型、共有View、BoundExpressionの連番Test as Specification整理済み。
- `__tree`: 専用ターゲット化、独立レビュー、通常到達可能行のcoverage確認済み。

## 判断待ち

- 内部テスト層の区分、および生木テストと変更コストの均衡。
- UnsafeNode/RawBufferクロスチェックと既存単層テストの統合方法。前者には独立した
  計算経路間の一致確認という固有の役割がある。
- `unranged()`の廃止可否。廃止時は4型の関連テストも対象となる。
- RedBlackTreeTestSupportとDebugAdditionalsの役割整理。
- 未結線コードを削除するかテストするか: `_Reverse4`関連、`swap_key`/
  `swap_mapped_value`、`outOfRange`/`keyMismatch`、`payloadLayout`/`__root_ptr()`、
  RawRangeの`contains(range:pointer:)`、`_TrackingTag.retire`。

## 直近の引き継ぎ

- MultiMap/MultiSetのhint付きinsertは同値群の順序へ影響する。テスト追加済みだが、
  公開DocCの “An incorrect hint doesn't change the result” は修正が必要。
- 4型の`customMirror`はCodex/Claudeの独立レビューとユーザー確認が完了。

最終更新: 2026-10-03 JST / Codex (GPT-5)

このファイルは現在地を上書きして保つ。長文報告や年代順ログは追加せず、引き継ぎは
最大5項目とする。ユーザー方針の変更・削除はユーザーへ確認する。
