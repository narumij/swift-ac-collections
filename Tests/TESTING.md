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
  3D cloneのcapacity不足による参照解放漏れを修正済み。strict memory safetyの第1バッチとして
  4つの所有型の`deinit`、初期化済み要素への書き込み、cloneをscoped `unsafe`化し、
  一意な診断を約64→54→38へ削減した。
  strict設定の恒久適用はまだ行っていない。
- AcCollections: 通常時の4型と互換時のPermutationModule再公開テストを追加済み。
  別テストターゲットでもRedBlackTreeのDebug寿命カウンタを各テスト後に検査・初期化する。
- PermutationModule: `swift-algorithms`の`permutations()`と重複する全順列列挙系
  (`unsafePermutations()`/`Permutations.All`/`IteratorA`/`SubSequenceA`)と、
  `unsafe`系の公開初期化経路(`unsafeNextPermutations()`、`Nexts.init(safe:)`/
  `init(unsafe:)`)を削除済み(Phase 1A: swift-algorithmsとの等価性PoCで7ケース
  完全一致を確認し削除ゲート通過→Phase 1B: `nextPermutations()`の保持契約テストを
  先に追加してから削除)。公開APIは`nextPermutations()`のみに収束。関連3文書
  (`Specification.md`/`ImplementationPlan.md`/`ProductReadinessAssessment.md`)を
  実装済みAPIへ合わせて書き直し済み。通常/`COMPATIBLE_ATCODER_2025`両方で
  `swift test`成功、`Package.swift`は元の状態へ復元済み。
- REFACTORING_FROM_ATCODER_2025.md: `CLAUDE_TASK.md`の8項目の訂正要件を`git`で
  再検証(全コミットのハッシュ・日付・`-M`判定・`diff`行数・`merge-base`を再確認)し、
  いずれも既に正確であることを確認済み(今回の文書自体への追加修正なし)。
- RedBlackTree: 4型、共有View、BoundExpressionの連番Test as Specification整理済み。
- Index世代、KeyOnly/KeyValue Range ViewのCoW後Index寿命、および4型とRange Viewの
  `elementsEqual(_:)` / `lexicographicallyPrecedes(_:)` は横展開済み。
- `__tree`: 専用ターゲット化、独立レビュー、通常到達可能行のcoverage確認済み。
- `unranged()`およびその専用プロトコル(`ScalarBaseInit`/`KeyValueBaseInit`、
  `_create(_:)`、4型への適合)を削除済み。4型の専用テスト4件も削除し、
  `API-Matrix.md`/`API-Matrix-View.md`/`MAINTENANCE.md`のユーザー要望欄も
  更新済み。通常/`COMPATIBLE_ATCODER_2025`両方で`swift test`成功
  (削除対象は元々`#if !COMPATIBLE_ATCODER_2025`配下のみ)。

## 判断待ち

- PermutationModule: `Sendable`はSwift 6以降で対応する方針で確定済み。第1バッチ
  (`Permutations`と`Nexts where C: Sendable`、コンパイル時テスト)は実装・検証済み。
  共有CoW bufferを持つ`IteratorN`/`SubSequenceN`も、Bufferの`final`化、変更前detachの
  根拠コメント、Taskを跨ぐ回帰テストとともに対応済み(`Maintanance/StrictMemorySafetyReadiness.md`
  §9)。ABC328E実提出による性能検証
  (外部AtCoder提出、ユーザー実施)が判断待ち(詳細は`Maintanance/PermutationModule/
  ImplementationPlan.md`の「保留中の判断」参照)。`All`系・`unsafe`系の削除、
  `Tests/PermutationTests/NextPermutation.swift`(未参照の旧世代実装)の削除、
  `nextPermutations()`と公開戻り値型への`///`コメントドック整備は完了済み。
  `.strictMemorySafety()`も恒久適用済みで、対象モジュールの警告0件を確認した。
- 内部テスト層の区分、および生木テストと変更コストの均衡。
- UnsafeNode/RawBufferクロスチェックと既存単層テストの統合方法。前者には独立した
  計算経路間の一致確認という固有の役割がある。
- RedBlackTreeTestSupportとDebugAdditionalsの役割整理。
- 未結線コードを削除するかテストするか: `_Reverse4`関連、`swap_key`/
  `swap_mapped_value`、`outOfRange`/`keyMismatch`、`payloadLayout`/`__root_ptr()`、
  RawRangeの`contains(range:pointer:)`、`_TrackingTag.retire`。

## 直近の引き継ぎ

- `CLAUDE_TASK.md`の4タスク(Permutation境界チェックの検証・end-to-end計測・単一比較PoC・
  `erase(where:)`の空CoW回避)を完了しCompletedへ更新。前回分は`CLAUDE_TASK_HISTORY.md`へ移動。
- Permutation: 初回ベンチマークの手法の問題(キャプチャ変数のbox化、タイマー分解能)を補正した
  `(batched)`版とend-to-end版を追加。実利用ではチェックが最適化で消え、end-to-endの約20%差は
  コード配置によるものと特定した。2比較の`precondition`を維持(単一比較は不採用)。
  詳細は`ProductReadinessAssessment.md`。
- `PermutationDeathTests.swift`に`Int.min`/`Int.max`を追加(計5件、Debug/Releaseとも成功)。
- `erase(where:)`: 4型で`ensureUnique()`の前に空チェックを追加。4型の空削除CoWテストを
  先に拡張して失敗を確認してから修正した。旧既知挙動テストは
  `testEraseWhereOnEmptyCollectionKeepsSingleton`へ改めた。
- 検証: 通常/互換モードの対象スイート、フルの`swift test`、通常ビルド、`git diff --check`が成功。
  `Package.swift`と一時的な本体変更は復元済み。

最終更新: 2026-10-03 19:46 JST / Codex

このファイルは現在地を上書きして保つ。長文報告や年代順ログは追加せず、引き継ぎは
最大5項目とする。ユーザー方針の変更・削除はユーザーへ確認する。
