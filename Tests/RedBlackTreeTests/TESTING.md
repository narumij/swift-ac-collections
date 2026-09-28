<!-- CodexによるCodexのためのメモ -->
# RedBlackTreeTests maintenance notes

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

- `RedBlackTreeSet` の連番テストは Test as Spec として整理済み。
- `RedBlackTreeMultiSet` は initialization、sequence、bidirectional collection、index、search、insertion、removal、utility、range view、protocol conformance、set algebra、element range を連番化済み。
- `RedBlackTreeDictionary` は initialization、sequence、index、search、insertion、removal、utility、range view、protocol conformance、Codable を連番化済み。
- `RedBlackTreeMultiMap` は initialization、sequence、index、search、insertion、removal、utility、range view、protocol conformance、Codable を連番化済み。
- 次回は `multimap` 以下の旧テストを監査し、連番側に無い現行公開仕様だけを追加する。compatibility、内部実装、性能、負荷、ファズは用途を保ち、連番と重複する旧ケースだけを整理する。
- Set、MultiSet、Dictionary、MultiMap の既存 Death Test は各型の `_99_DeathTests.swift` に移管済み。
- `multiset` 以下には compatibility、内部実装、性能、負荷、ファズ、および未仕分けの旧テストが残っている。削除前に公開仕様の取りこぼしがないか確認すること。
- `MultisetAtCoder2025CompatibilityTests.swift` は互換モード廃止時の一括削除対象。
