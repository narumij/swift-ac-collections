# OPS-072 試行2：「今の表面」案（3文書）

2026-10-17 / 姫（Opus 5.5）。入力版 `fec74691`（＋同日の試行1）。ユーザー「その観点であらためて…」「やれるとこまでやってみて」。

観点（ユーザー）：Test as Specは過去がgitに沈むが、メンテナンス文書は全部露出している。仮判断は動くので表面に残す。事実に裏付けられた判断は事実が変わるまで変わらないので、**点検事実**だけ表面に置けば本文はgitの過去でよい。

表面に置くもの：(1)動く仮判断 (2)契約（待ち・再開条件） (3)点検事実（これを見れば今も成り立つ、の1行） (4)糸口（`git log -- パス`と最後の版）。

**これは案。** 対象3文書は差し替えていない（占有は姫にない）。差し替えるなら、元の全文はgitの最後の版で読める。

---

## A. `ASAN_DEATH_TEST_INVESTIGATION.md`（55行 → 案13行）

```markdown
# ASan＋Death Test実行経路（RBT-033、DONE）

## 点検事実
- 常時CI（`.github/workflows/ci.yml`）のASan jobは`--traits`なし＝death testを含まない。
- 候補CI（`.github/workflows/candidate.yml`の`address-sanitizer-death-tests`）はLinuxで`--traits ENABLE_DEATH_TESTS`付き。2026-10-17に成功（ユーザー報告、run未記録）。
- macOSでASan＋death testを通すには`ASAN_OPTIONS=strip_env=0`が要る。根拠と再現：`Evidence/RBT-049/commands.sh`。
- Linuxの成功はmacOSの成功を証明しない（逆も同じ）。

## 仮判断（見張る）
- 別のSwift版・toolchainでは未検証。きっかけ：toolchain更新。
- OptionalElementBuffer/ElementBufferの品質評価にある「ASan＋Death Test成功」記載との違いは未決。きっかけ：その評価を再利用するとき。

## 経緯
`git log -- Maintanance/Current/ASAN_DEATH_TEST_INVESTIGATION.md`、最後の全文版 `221e3ae9`。最小package再現・setenv復元の候補（strip_env特定で役目終了）・追加受入はそこにある。
```

沈めたもの：最小package再現の表、負例の扱い、setenv復元という解決候補、追加受入の照合内容。いずれも事実として確定済みか、役目を終えた候補。

---

## B. `EXTERNAL_TYPE_EXTENSION_AUDIT.md`（68行 → 案28行）

```markdown
# 外部所有型Extension監査

## 点検事実（完了済みcluster）
- `grep -rn "@retroactive Comparable" Sources` が0件。
- `Result._NodePtr`は`@usableFromInline package`（`Sources/RedBlackTreeCollections/Implements/__tree/unsafe_node/unsafe_node+pointer+safe.swift`の`extension Result`）。
- `_LazyTieWrap: Comparable`（`RawBuffer/_LazyTieWrap.swift`）と`_NodePtrSealing: Comparable`（`__tree/unsafe_node/Seal/_NodePtrSealing.swift`）はどちらも`#if DEBUG`内。

## 契約（待ち・再開条件）
| cluster | 状態 | 再開条件 |
| --- | --- | --- |
| Debug限定Comparable群 | 凍結 | Indexの`Comparable`方針確定後 |
| Balanced群 | 凍結 | Index契約またはexecutable API Matrix方針の確定後 |
| SignedDistance protocol cluster | 凍結 | public protocol clusterまたはIndex設計を扱う明示的な再開指示 |
| Memoize群 | EXCLUDED（2026-10-16ユーザー判断） | 待ち条件として残さない |

## 仮判断（見張る）
- 監査メモの`_LazyTie`が何を指すか未決（`Sources`に同名なし、`_LazyTiedPtr`はある）。
- SignedDistanceの「access-only縮小は言語制約上成立しない」は当時のtoolchainでの実験結果。きっかけ：toolchain更新か再開時。

## 監査で守る決まり（長命）
- 外部所有型へのpublic member追加とretroactive conformanceを区別する。
- DebugとReleaseで公開protocol conformance集合を変えない。
- `@inlinable`から参照される境界は自由な実装詳細とみなさない。
- test-only conformanceも最小限にする。
- Index表現、Range/View、deprecated互換経路を同名だけで統合しない。

## 経緯
`git log -- Maintanance/Current/EXTERNAL_TYPE_EXTENSION_AUDIT.md`、最後の全文版 `e84f8fa9`。2026-10-07までの全文は`../Archived/EXTERNAL_TYPE_EXTENSION_AUDIT_HISTORY_2026-10-07.md`。
```

沈めたもの：Result cleanupの作業手順と検証記録（性能job run番号など）、Memoizeの経緯説明、残監査の完了条件（再開時に履歴から引ける）、Main sources一覧（うち1件は古いパスだった。表面では点検事実に必要なパスだけ持つ）。

迷ったところ：「監査で守る決まり」は寿命が長い規則で、この文書よりRules側にあるべきものかもしれない。今回は表面に残した。

---

## C. `PERMUTATION_SEQUENCE_INVALID_VIEW_ISSUE.md`（31行 → 案は現状維持＋点検事実2行）

PERM-060はACTIVE（調査担当Codex）で、中身のほとんどが動く仮判断と、これからやる調査の契約。寿命が尽きた記述がほぼ無いので縮まない。足すなら点検事実だけ：

```markdown
## 点検事実
- 通常公開型・借用公開型は`Sequence`非準拠と明記：`Sources/NextPermutationModule/NextPermutations.swift`・`BorrowedNextPermutations.swift`の型コメント。
- 実験adapter `RuntimeCheckedPermutationSequence: Sequence`はテスト内だけにある：`Tests/PermutationTests/NextPermutationsSequenceExperimentTests.swift`。
```

調査が終わって修正が確定したら、そのときが縮める番（再現結果は回帰テストに乗り、文書は点検事実と未解決の判断だけになるはず）。

---

## 行数

| 文書 | 現在 | 表面案 | 備考 |
| --- | --- | --- | --- |
| A ASan | 55 | 約13 | DONEのtask。大半が確定済みの経緯 |
| B 外部型Extension | 68 | 約28 | 契約と長命な決まりが残る |
| C PERM-060 | 31 | 31＋2 | ACTIVE。寿命が尽きていない |
