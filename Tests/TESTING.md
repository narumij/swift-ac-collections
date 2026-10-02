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
- PermutationModule: `CLAUDE_TASK.md`の修正依頼を受け、方向性を「バリアント削減」へ
  書き直し済み。`nextPermutations()`を維持する核とし、`Permutations.All`/`IteratorA`/
  `SubSequenceA`/`unsafePermutations()`を`swift-algorithms`の`permutations()`と重複する
  削除候補として扱う段階的削除計画(`Maintanance/PermutationModule/ImplementationPlan.md`)
  と仕様ドラフト(`Sources/PermutationModule/Documentation/Specification.md`)、所見
  (`ProductReadinessAssessment.md`)を改訂済み(コード・テスト変更なし)。
- REFACTORING_FROM_ATCODER_2025.md: keystoneテストの由来を再調査し、「release原本の単純な
  改名」ではなく「2026-01-03に分岐したコピーが並行運用の後、原本削除(2026-09-29)の翌日に
  大幅書き換えされた派生版」であることを`git`証跡付きで訂正済み。ソース側/テスト側の時系列を
  分離し、`[事実]`/`[証言]`/`[解釈]`のラベルを導入(コード・テスト変更なし)。
- RedBlackTree: 4型、共有View、BoundExpressionの連番Test as Specification整理済み。
- Index世代、KeyOnly/KeyValue Range ViewのCoW後Index寿命、および4型とRange Viewの
  `elementsEqual(_:)` / `lexicographicallyPrecedes(_:)` は横展開済み。
- `__tree`: 専用ターゲット化、独立レビュー、通常到達可能行のcoverage確認済み。

## 判断待ち

- PermutationModule: `Permutations.All`系(`unsafePermutations()`/`IteratorA`/
  `SubSequenceA`等、`swift-algorithms`の`permutations()`と重複)を削除するか
  deprecationに留めるか、`unsafeNextPermutations()`系を公開のまま残すか内部実装専用に
  するか、`Tests/PermutationTests/NextPermutation.swift`の旧世代実装を削除するか参考実装
  として残すかがユーザー判断待ち(段階的削除計画は`ImplementationPlan.md`参照)。
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

- RedBlackTree 4型のFuzzテストを参照モデル比較+不変条件チェックの組に統合
  (`CLAUDE_TASK.md`はCompletedへ更新済み)。
- RedBlackTree 4型の空コレクション用シングルトンの生存・detach・復帰条件を確認し
  `RedBlackTreeInternal_EmptySingletonTests.swift`へ記録。`erase(where:)`の
  無駄なdetachを未解決事項として判断待ちへ記録(`CLAUDE_TASK.md`はCompletedへ
  更新済み)。
- `CLAUDE_TASK.md` Task 1(PermutationModule再設計フェーズ1: 仕様ドラフト+実装計画)と
  Task 2(REFACTORING_FROM_ATCODER_2025拡充)を完了(その後、Codexの修正依頼により
  下記の訂正パスを実施)。
- PermutationModule関連3文書(`Specification.md`/`ImplementationPlan.md`/
  `ProductReadinessAssessment.md`)を、ユーザーの意図(バリアント削減)に沿って
  `All`系削除候補・段階的削除計画へ書き直し。ABC328Eの制約(`N<=8`,`M<=28`)と
  自己完結ファイルでの提出検証も明記。
- `REFACTORING_FROM_ATCODER_2025.md`のkeystoneテスト由来を`git`証跡で再調査し、
  「単純な改名」ではなく「分岐コピーの並行運用→原本削除→大幅書き換え」という
  実態へ訂正。ソース/テストの時系列分離と`[事実]`/`[証言]`/`[解釈]`ラベルを導入
  (`CLAUDE_TASK.md`はCompletedへ更新済み、コード・テスト変更なし)。

最終更新: 2026-10-03 09:30 JST / Claude Sonnet 5

このファイルは現在地を上書きして保つ。長文報告や年代順ログは追加せず、引き継ぎは
最大5項目とする。ユーザー方針の変更・削除はユーザーへ確認する。
