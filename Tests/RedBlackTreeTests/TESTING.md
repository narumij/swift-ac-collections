<!-- CodexによるCodexのためのメモ -->
# RedBlackTreeTests maintenance notes

## User requests for the next session

リセット待ち・休憩中に、次回の作業で優先してほしい内容をユーザーが書く欄。この欄に記載がある場合、Codex は `Current handoff` より先に読み、最新のユーザー要望として優先する。完了した項目を Codex が勝手に削除せず、完了したことを追記するか、ユーザー確認後に整理する。

記入例:

- 最優先で扱うフォルダまたはファイル
- 残してほしいテスト、削除してよい重複
- Swift Testing / XCTest / compatibility の配置に関する希望
- テストが通った時点で止める、残量何%で休憩する、といった停止条件
- 次回まで保留した判断や気になっている破損

<!-- ユーザー記入欄: この下へ追記 -->

### 優先事項

- 次回は `Current handoff` に記載した `SetSubSequenceTests.swift` の監査から再開する。（2026-09-28 完了）
- Package.swiftの直接編集Xcode runで構わないので、互換モードのコンパイル確認を一度はして判断を仰いで欲しい。（2026-09-28 完了。ビルド成功、全テスト 1026 成功・0 失敗・7 スキップ）

### 連絡事項

- 2026-09-28 時点で週間利用上限の残りは 9%。次のスプリントは時間上限より先に週間上限へ達する可能性があるため、早めに緑のチェックポイントと引き継ぎを残す。

- 週間利用上限残り2%でとまってほしい。
- 5時間上限または週間利用上限で止まるとき、それまでの作業の感想も教えて欲しい
- GitHub ActionのCIで7件のコンパイルエラーがありました
- 実験コードの場合DEBUG専用になってるので、そこは注意が必要です
- 互換モードのコンパイルエラーを直しました
- 互換モードデバッグビルドのMultiMapEtcTestsにバグがありそうです
- 最後に作業したモデルはモデル名とバージョンをどこかに記載すること
- 各種条件はCodex想定なので、Claudeが参加した場合、Codex向けとClaude向けで条件を分けること
- ふりかえりはしたい

### 停止条件

- 利用上限が少ないセッションでは、新しい大きなカテゴリへ着手する前に、全体テスト・文書更新・振り返りに必要な余裕を確保する。

### 保留中の判断・懸念

- こちらでヒント系APIとAPI一覧を触ってるので、Test as Spec観点でチェックしてほしい

### 完了済みの要望

- 2026-09-28: 記入欄を優先事項と連絡事項などのカテゴリに分けた。(確認済)
- 2026-09-28: `SetSubSequenceTests.swift` を現行仕様と互換仕様へ分離し、現行の要素範囲ビューを `_18_ElementRangeTests.swift` へ移管した。
- 2026-09-28: 最後に作業したモデルは Codex（GPT-5、詳細なマイナーバージョンは実行環境から確認不可）。

### Claude向け運用メモ

Codex が週末（日曜）まで週間利用上限でロングスリープに入ったため、2026-09-29 から Claude が代打として本ファイルの作業に参加する。上の「連絡事項」「停止条件」に書かれている週間利用上限・停止しきい値は Codex のプラン前提であり、Claude にそのまま適用しない。Claude 側の停止条件・利用上限は必要になった時点でここに追記する。

- 2026-09-29: 最後に作業したモデルは Claude（Sonnet 5、モデルID `claude-sonnet-5`）。
- 2026-09-29: `dictionary/DictionarySubSequenceTests.swift`(`elements(in:)` の count/first/last・双方向走査、46行)を現行仕様として棚卸し。実仕様検証のあった2ケースを `RedBlackTreeDictionary_11_ElementRangeTests.swift` へ移管し、旧ファイルは削除した。旧ファイルのクラスを互換ファイル側で `extension` していた3ケース(index offsetting、distance対称性、CoW後のindex無効化)は `RedBlackTreeDictionaryAtCoder2025CompatibilityTests.swift` 内で自己完結クラス `RedBlackTreeDictionarySubSequenceAtCoder2025LegacyTests` に付け替えた。通常モード・互換モード(`COMPATIBLE_ATCODER_2025` を一時的に有効化して確認、確認後 `Package.swift` は元に戻した)の両方で `swift test` が失敗0件であることを確認済み(互換モードは913件成功・6件既知スキップ・0失敗)。

<!-- ユーザー記入欄ここまで -->

## Test as Spec

型名のディレクトリにある連番付きテストを、公開 API の現行仕様を示す正本（Test as Spec）とする。

例:

- `RedBlackTreeSet/RedBlackTreeSet_0_InitializationTests.swift`
- `RedBlackTreeMultiSet/RedBlackTreeMultiSet_6_RemovalTests.swift`

連番テストには、利用者が観測できる振る舞いを API の役割ごとに配置する。テスト名は、入力だけでなく保証される結果が読める名前にする。現行実装に存在しない API のために連番を埋める必要はない。

旧フォルダのテストを整理するときは、単純に削除しない。現行の公開 API を検証しているケースが連番側に無ければ、現在の API と期待値に合わせて修正コピーしてから旧ケースを削除する。

次のテストは連番へ無理に混ぜなくてよい。

- `@testable` や `___`、内部 pointer などに依存する実装テスト
- 性能、負荷、ファズ、回帰専用テスト
- 互換モードだけに存在する API のテスト

公開 API の precondition や不正 index を専用プロセスで検証する Death Test は、各型の連番 `_99_DeathTests.swift` に配置する。`DEATH_TEST` 条件は維持し、通常仕様と同じ場所から発見できるようにする。

内部実装・coverage テストは `_98_*.swift` に分ける。まだ公開仕様・内部仕様・互換仕様の分類が済んでいない Swift Testing ベースのテストは、一時的に `_97_*.swift` へ置く。分類済みの公開 Death Test は `_99_DeathTests.swift` とする。通常の XCTest による Test as Spec と同じファイルへ混ぜず、GitHub Actions で問題が起きたときに Swift Testing 使用箇所をファイル名から絞り込めるようにする。

## Swift Testing isolation

Swift Testing は GitHub Actions 上で test discovery や exit test に問題が起きることがあるため、通常の XCTest ベースの Test as Spec から隔離し続ける。

- `_97_*.swift`: 未分類の Swift Testing。内容を確認後、`_98`、`_99`、または compatibility file へ移す一時置き場。
- `_98_*.swift`: 内部実装・coverage。Swift Testing を使う場合も公開仕様の連番テストへ混ぜない。
- `_99_DeathTests.swift`: 公開 API の exit test。Swift Testing の `#expect(processExitsWith:)` が必要な範囲に限定する。
- `*AtCoder2025CompatibilityTests.swift`: 互換モード専用の XCTest。`import Testing` や `@Test` を同居させない。
- `*AtCoder2025CompatibilitySwiftTests.swift`: 互換モード専用の Swift Testing。exit test など Swift Testing が必要なケースだけを配置する。

通常の成功系テストは XCTest で書く。Swift Testing を新たに通常連番へ追加しない。GitHub Actions で問題が起きた場合に `_97`、`_98`、`_99`、compatibility を個別に特定・除外できる配置を維持する。

互換テストでも XCTest と Swift Testing を同じソースへ混在させない。ファイル名の `CompatibilityTests` と `CompatibilitySwiftTests` で test framework を判別できる状態を保つ。

## AtCoder 2025 compatibility tests

`COMPATIBLE_ATCODER_2025` 専用テストは、`*AtCoder2025CompatibilityTests.swift` に集約する。これらは互換モードを廃止するとき、検索して一括削除できることを目的としている。

互換モードだけに存在する API を連番テストへ戻さない。現行と互換モードの両方にある API でも期待する挙動が異なる場合は、現行仕様を連番側、旧仕様を compatibility file 側に分ける。

互換テストから連番側の test class を extension している場合がある。連番ファイルの移動や改名時は、`*AtCoder2025CompatibilityTests.swift` 内の extension 参照も確認する。

## Safe migration workflow

長時間の整理を壊れた状態で残さないため、次の単位を守る。

1. 旧テストと現行 API を比較する。
2. API の一カテゴリだけ連番側へ移す。
3. Xcode のファイル診断でコンパイルエラーを確認する。
4. 全テストを実行し、失敗が 0 であることを確認する。
5. コミット可能な状態になってから次のカテゴリへ進む。

テスト数は、重複ケースの統合や旧ファイル削除で減ることがある。件数ではなく、公開仕様の欠落がないことと全テスト失敗 0 を基準にする。

長時間のセッションでは、残量 10% 付近で新しいカテゴリへの着手を止める。最後の 5% は、全体テスト、`Current handoff` の更新、次回の開始地点の明記、コミット可能な状態の確認に使う。作業量を増やすためにこの振り返り時間を使い切らないこと。

## Current handoff

- `RedBlackTreeSet` の連番テストは Test as Spec として整理済み。旧 `set` フォルダの Swift テストは残っていない。
- 旧 `set` フォルダにあった SetAlgebra、reserve-capacity、corner-case、bidirectional、removal、extended と巨大な `SetTests.swift` は監査・整理済み。公開仕様は連番へ、SetAlgebra stress、COW、pointer、performance、固定 seed の fuzz、removal stress、removal internal、raw index validity は型別 `_98`、互換仕様は型別 compatibility file へ移管した。再現不能なランダムテストは固定 seed fuzz で置換した。index-based range view は `_17_RangeViewTests.swift`、`elements(in:)` の現行要素範囲ビュー仕様は `_18_ElementRangeTests.swift`、参照型要素の `insert` / `update` identity は `_5_InsertionTests.swift`、現行 `filter` の戻り型は `_1_SequenceTests.swift` で仕様化している。
- `COMPATIBLE_ATCODER_2025` を一時的に有効化した Debug 全体テストは 2026-09-28 に成功。`SetTests.swift` 整理後の最新結果は 968 成功・0 失敗・6 スキップ。通常モードも 1036 成功・0 失敗・1 スキップ。確認後、`Package.swift` は通常モードへ戻した。互換モードで懸念されていた `MultiMapEtcTests` に失敗は出なかった。
- 旧 `SetTests` を土台にしていた9個の互換 extension と互換専用の element-range subscript/iteration は、`RedBlackTreeSetAdditionalAtCoder2025LegacyTests` へ閉じ込め済み。旧 `SetTests.swift` は削除済み。
- ルート直下では `MergeTests.swift`、`DocumentCheckTests.swift`、`EtcTests.swift` などに Set 公開仕様が混在する。単純移動せず、他型のケースを残しながら Set ケースだけ連番側へ移植・整理する。
- `BoundExpression` は公開 DSL として4型それぞれの `_16_BoundExpressionTests.swift` へ移管済み。旧 `boundsExpression` フォルダの Swift テストは残っていない。位置式、相対移動、limit、range expression、subscript、erase の既存仕様を型別 Test as Spec として維持する。DEBUG 専用の内部 validity を追加するときは `_98_InternalTests.swift` に置く。
- `RedBlackTreeMultiSet` は initialization、sequence、bidirectional collection、index、search、insertion、removal、utility、range view、protocol conformance、set algebra、element range を連番化済み。
- `RedBlackTreeDictionary` は initialization、sequence、index、search、insertion、removal、utility、range view、protocol conformance、Codable を連番化済み。
- `RedBlackTreeMultiMap` は initialization、sequence（predicate、sorted、reversed を含む）、index、search、insertion、removal、utility、range view、protocol conformance、Codable、transforming and combining、element range を連番化済み。
- `multimap` 以下の広範な旧テスト (`MultiMapBasicTest.swift`、`MultiMapAdvancedTest.swift`、`RedBlackTreeMultiMapTests.swift` とその removal extension、`RedBlackTreeMultiMapTests_.swift`、`MultiMapEtcTests.swift`、`MultiMapRemoveTests.swift`、`MultiMapViewTests.swift`) は、連番側への不足仕様の移植後に整理済み。互換 extension が必要とする test class と fixture は compatibility file 内へ閉じ込め、互換専用の range-index removal も同ファイルへ移した。
- 次回はルート直下の `MergeTests.swift`、`DocumentCheckTests.swift`、`EtcTests.swift` に混在する Set 公開仕様を優先して監査する。その後 `MultiMapTests.swift` を少量ずつ監査する。残る `MultiMapCopyOnWriteTests.swift` と `MultiMapPointerTests.swift` は内部実装テストとして用途を保つ。compatibility、内部実装、性能、負荷、ファズは連番へ無理に移さない。
- Set、MultiSet、Dictionary、MultiMap の既存 Death Test は各型の `_99_DeathTests.swift` に移管済み。
- `fatalError/Index` に残っていた空の `startIndex` と `endIndex` の Death Test、および `fatalError/etc` の空 collection に対する `removeFirst` / `removeLast`、Set の cross-tree range、削除済み index の再削除は各型の `_99_DeathTests.swift` へ移管済み。重複していた旧 range / fatal テストも整理済み。
- 互換専用 iterator Death Test は `RedBlackTreeSetAtCoder2025CompatibilitySwiftTests.swift` へ移管済み。
- Dictionary、MultiMap、MultiSet の `*AtCoder2025CompatibilityTests.swift` は、各型の Test as Spec フォルダへ移動済み。
- `fatalError/etc` に残っていた通常成功系は XCTest の各型連番へ、内部 coverage / pointer precondition は各型または共有内部の `_98_*.swift` へ移管済み。旧 root `DeathTest.swift` の内容は Set の公開 precondition と確認できたため、`RedBlackTreeSet_99_AdditionalDeathTests.swift` へ分類済み。今後、既存 `_99_DeathTests.swift` との重複を小さい単位で統合する。
- `multiset` 以下には compatibility、内部実装、性能、負荷、ファズ、および未仕分けの旧テストが残っている。削除前に公開仕様の取りこぼしがないか確認すること。
- `MultisetAtCoder2025CompatibilityTests.swift` は互換モード廃止時の一括削除対象。
