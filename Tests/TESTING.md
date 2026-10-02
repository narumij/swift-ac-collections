# テストメンテナンス・ダッシュボード

現在情報だけを保持する。作業規則は `Tests/CLAUDE.md`、CodexからClaudeへの依頼は
`Maintanance/CLAUDE_TASK.md`、2026-10-03以前の詳細は `Tests/TESTING_REFERENCE.md` にある。
参照資料は必要な箇所だけ検索し、通常は通読しない。

## 目的

- テストを継続的に整理し、公開APIの仕様不足や実装不具合を発見する。
- テスト成功だけで完了とせず、公開API一覧と実装に対する不足を確認する。

## 優先事項

現在のユーザー依頼と `CLAUDE_TASK.md` が最優先。現在、追加の優先事項はない。

## 現在地

- RedBlackTree 4型の空コレクション用シングルトン(`_emptyTreeStorage`、型消去済み
  capacity 0)の生存条件を4型すべてで確認し、
  `RedBlackTreeInternal_EmptySingletonTests.swift`へ記録済み。通常初期化・
  `minimumCapacity: 0`・空コレクションのコピーはシングルトンを維持し、
  `reserveCapacity`(0含む)・正のminimumCapacity指定・最初の挿入でdetachする。
  最後の要素削除後もシングルトンへは戻らず確保済みバッファを保持し、
  `removeAll(keepingCapacity: false)`のみシングルトンへ復帰する。通常/
  `COMPATIBLE_ATCODER_2025`の両方で同一挙動。production codeの変更なし。
- RedBlackTree 4型の `_98_FuzzTests.swift`: 参照モデル比較と操作ごとの
  `___tree_invariant_for_fuzz()` チェックを同一の操作列・状態に対して行うよう
  統合済み。MultiSet/MultiMapは「選択キーのみ」の部分比較だった箇所を全要素
  比較に強化した。production codeの変更なし、不具合は未検出。

- OptionalArrayModule: Release実行、Death Test、参照型寿命、公開API化漏れを対応済み。
- BareArrayModule: Debug/Release、境界Death Test、参照型寿命をレビュー済み。
  3D cloneのcapacity不足による参照解放漏れを修正済み。
- AcCollections: 通常時の4型と互換時のPermutationModule再公開テストを追加済み。
  別テストターゲットでもRedBlackTreeのDebug寿命カウンタを各テスト後に検査・初期化する。
- PermutationModule: `CLAUDE_TASK.md` Task 1(Codex依頼)でフェーズ1の仕様ドラフト
  `Sources/PermutationModule/Documentation/Specification.md`とテストファースト実装計画
  `Maintanance/PermutationModule/ImplementationPlan.md`を作成済み(コード・テスト変更なし)。
- RedBlackTree: 4型、共有View、BoundExpressionの連番Test as Specification整理済み。
- Index世代、KeyOnly/KeyValue Range ViewのCoW後Index寿命、および4型とRange Viewの
  `elementsEqual(_:)` / `lexicographicallyPrecedes(_:)` は横展開済み。
- `__tree`: 専用ターゲット化、独立レビュー、通常到達可能行のcoverage確認済み。

## 判断待ち

- PermutationModule: `unsafe`接頭辞のままとするか命名を見直すか、
  `Permutations.All.init(safe:)`(安全な全列挙の対になるAPI)を結線するか、
  `Tests/PermutationTests/NextPermutation.swift`の旧世代実装を削除するか参考実装として
  残すかがユーザー判断待ち(`ImplementationPlan.md`参照)。
- `erase(where:)`がRedBlackTreeSet/MultiSet/Dictionary/MultiMapの4型すべてで
  無条件に`ensureUnique()`を呼ぶため、空コレクションに対しても無駄にシングルトン
  からdetachする(要素が無い/削除されなくてもCoW発生)。`remove(_:)`/
  `removeValue(forKey:)`/`removeAll(keepingCapacity: true)`/`popFirst`/
  `popLast`等は`count > 0`等で既に手当て済みだが、`erase(where:)`は未対応。
  production codeの修正は今回のタスク範囲外のため、
  `testEraseWhereOnEmptyCollectionDetachesFromSingleton`で現状を再現する
  テストのみ追加した。修正するかどうかユーザー判断待ち。
- 内部テスト層の区分、および生木テストと変更コストの均衡。
- UnsafeNode/RawBufferクロスチェックと既存単層テストの統合方法。前者には独立した
  計算経路間の一致確認という固有の役割がある。
- `unranged()`の廃止可否。廃止時は4型の関連テストも対象となる。
- RedBlackTreeTestSupportとDebugAdditionalsの役割整理。
- 未結線コードを削除するかテストするか: `_Reverse4`関連、`swap_key`/
  `swap_mapped_value`、`outOfRange`/`keyMismatch`、`payloadLayout`/`__root_ptr()`、
  RawRangeの`contains(range:pointer:)`、`_TrackingTag.retire`。

## 直近の引き継ぎ

- BareArrayの公開テストをReleaseでも実行する構成にし、境界Death Testと多次元配列の
  参照型寿命を追加。3D cloneの参照解放漏れを再現テスト付きで修正した。
- 4型の`customMirror`はCodex/Claudeの独立レビューとユーザー確認が完了。
- RedBlackTree 4型のFuzzテストを参照モデル比較+不変条件チェックの組に統合
  (`CLAUDE_TASK.md`はCompletedへ更新済み)。
- RedBlackTree 4型の空コレクション用シングルトンの生存・detach・復帰条件を確認し
  `RedBlackTreeInternal_EmptySingletonTests.swift`へ記録。`erase(where:)`の
  無駄なdetachを未解決事項として判断待ちへ記録(`CLAUDE_TASK.md`はCompletedへ
  更新済み)。
- `CLAUDE_TASK.md` Task 1(PermutationModule再設計フェーズ1: 仕様ドラフト+実装計画)と
  Task 2(REFACTORING_FROM_ATCODER_2025拡充、モジュール改名・内部層分離・Fixture/原木
  ターゲット化の3段階を追加し、Test as Specificationが移行の産物ではない点を補記)を完了
  (`CLAUDE_TASK.md`はCompletedへ更新済み、コード・テスト変更なし)。

最終更新: 2026-10-03 08:10 JST / Claude (Sonnet 5)

このファイルは現在地を上書きして保つ。長文報告や年代順ログは追加せず、引き継ぎは
最大5項目とする。ユーザー方針の変更・削除はユーザーへ確認する。
