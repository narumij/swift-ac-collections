> 2026-10-16、ユーザー指示でアーカイブ。元の文書：`Maintanance/PermutationModule/DocumentationHandoffAudit.md`。全文を保存。PERM-020〜023の監査・引継ぎ判定は2026-10-08に完了。旧COW実装の証拠記録であり、現行契約や未実施依頼として扱わない。
> 現行の品質資料：[品質評価](CurrentQualityAssessment.md)、[仕様レビュー](../PERMUTATION_TEST_AS_SPEC_REVIEW.md)。本文中の旧パス・型名・指示は記録当時のもの。

# Permutation documentation handoff audit

## TL;DR（人間向け）
本書は旧COW版Permutationの公開面、test根拠、命名・契約履歴を利用者向け文書作業へ渡すための証拠監査を記録する。2026-10-08に監査と引継ぎ判定が完了し、現行runtime-check版の契約資料ではない。

この監査の当時の割当、判断基準、古いAPI名は現行の指示や未実施依頼として扱わない。現行契約と作業状態は、現行Quality ProfileおよびTask Registryを参照する。

最終更新: 2026-10-08 / Codex

This document is an evidence package from the handoff of the old COW implementation around commit `15c8f965` to user-facing documentation work; it is not a ledger for the current API. For the current public contract and verification status, see `Maintanance/Quality/Profiles/NextPermutationModule.md`, `CurrentQualityAssessment.md`, `RuntimeCheckedPermutationTestPlan.md`, and `Maintanance/Quality/0.6.0-1/PermutationModule/BorrowedPermutationTestPlan.md`.

## 目的

Before handing Permutation to Codex for user-facing documentation work, assemble the then-current public surface, specification tests, and naming/contract history into an independent evidence package. This audit does not decide document structure, example selection, public contracts, or the documentation boundary with compatibility mode.

## 共通境界

- Claude was assigned to append only the specified evidence tables to this document.
- Do not change `Sources/`, `Tests/`, user-facing documents, existing quality assessments, or the Registry.
- Do not infer a desirable contract from the current implementation; distinguish recorded facts from unverified points.
- If a defect, public-contract mismatch, or new decision point is found, record the evidence and a safe minimal reproduction, then stop.
- Do not fill gaps in another package on the spot; report them as concerns for that package.
- Codex checks each package for coverage and integrates the inputs for user-facing documentation.

## Claude assignments

### Public API and documentation ledger

The assigned source was `Sources/PermutationModule/NextPermutations.swift`. Map every `public` declaration to its type, member kind, source location, declared generic constraints, and whether it has a documentation comment. Performance attributes such as `@inlinable` may be recorded as facts, but do not assess whether they are needed. The deliverable is a table in `## Public API ledger`. Recount all declarations and stop.

### Test evidence matrix

The assigned inputs were numbered tests in `Tests/PermutationTests/NextPermutationsSequence/`. Map public declarations to existing tests for enumeration order, empty and single-element input, duplicate elements, value semantics, the `Permutation` collection, coexistence with other modules, and bounds failures. Record only facts each test actually establishes and list unverified contracts. The deliverable is a table in `## Test evidence matrix`. Do not add or rename tests.

### Naming and contract history ledger

The assigned inputs were `Permutations.swift`, the tests above, `Maintanance/Archived/PermutationImplementation_2026-10-16/ImplementationPlan.md`, `ProductReadinessAssessment.md`, `AtCoder2025CompatibilityPlan.md`, and directly related Git history. Distinguish decisions, historical facts, and unresolved matters for the names of the three current public types, removed APIs, and the boundary between normal and compatibility modes. The deliverable is a table in `## Naming and contract history`. Do not restart compatibility mode or propose a documentation boundary.

## Codex intake

After all three packages were complete, Codex was to check the following:

- Every public declaration is included in the ledger.
- Each contract promised to users has test evidence or is marked unverified.
- Current names, removed APIs, and compatibility mode are not conflated.
- When combined with the quality-assessment review, the decisions for user-facing documentation remain independent.

Even after acceptance, this document itself is not user-facing documentation.

## Public API ledger

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。`PERM-020`。`L<n>`は`Sources/PermutationModule/NextPermutations.swift`の行
（`15c8f965`時点）。属性列は事実だけを記録し、要否は評価しない。

| # | 宣言 | 種別 | 位置 | 宣言上のgeneric制約 | 属性 | ドキュメントコメント |
| ---: | --- | --- | --- | --- | --- | --- |
| 1 | `Collection.nextPermutations() -> NextPermutationsSequence<Self>` | method（`extension Collection`） | L20 | `where Element: Comparable` | `@inlinable` | あり L3-18 |
| 2 | `NextPermutationsSequence<Base>: Sequence` | struct | L27 | `Base: Collection, Base.Element: Comparable` | — | あり L26（1行） |
| 3 | `makeIterator() -> Iterator` | method | L38 | 型から継承 | `@inlinable` | なし |
| 4 | `NextPermutationsSequence.Iterator: IteratorProtocol` | nested struct | L46-47（`public`が改行で分かれる） | 型から継承 | — | あり L45（1行） |
| 5 | `Iterator.next() -> Permutation?` | mutating method | L86 | 型から継承 | `@inlinable` | なし |
| 6 | `NextPermutationsSequence.Permutation` | nested struct | L156-157（同上） | 型から継承 | — | あり L154-155 |
| 7 | `Permutation.startIndex: Int` | property | L177 | 型から継承 | `@inlinable` | なし |
| 8 | `Permutation.endIndex: Int` | property | L179 | 型から継承 | `@inlinable` | なし |
| 9 | `Permutation.Index = Int` | typealias | L180 | — | — | なし |
| 10 | `Permutation.Element = Base.Element` | typealias | L181 | — | — | なし |
| 11 | `Permutation.subscript(position: Int) -> Base.Element`（getのみ） | subscript | L187 | 型から継承 | `@inlinable` | あり L182-185（Precondition、Debug / Release / `-Ounchecked`の記述あり） |
| 12 | `Permutation.==` | static func（無条件の`Equatable`） | L199 | 型から継承 | `@inlinable` | なし（L196は`//`コメント） |
| 13 | `Permutation.hash(into:)` | method | L206 | `where Base.Element: Hashable`（extension） | `@inlinable` | なし |
| 14 | `Permutation.description: String` | property | L215 | 型から継承 | なし（`@inlinable`ではない） | なし |

再集計: `public`キーワードは14か所（`grep`、L46とL156の改行分割を含む）で、型3、member 11、計14宣言。

宣言に数えない公開適合は9件: `Sequence`（L27）、`IteratorProtocol`（L47）、`NextPermutationsSequence: Sendable where Base: Sendable`
（L103）、`Iterator: @unchecked Sendable where Base.Element: Sendable`（L107）、`Permutation: @unchecked Sendable where
Base.Element: Sendable`（L173）、`RandomAccessCollection`（L175）、`Equatable`（L197）、`Hashable where Base.Element: Hashable`（L204）、
`CustomStringConvertible`（L214）。L105-106、L171-172、L196の`Sendable`・等値の根拠は`//`コメントで、ドキュメントコメントではない。

公開外の補足: `package`は`#if DEBUG`限定の3件（`NextPermutationsHeaderProbe` L131、`deinitCount` L132、`Permutation._copyCount` L192）。
`NextPermutationsSequence.init(_:)`は`internal`（L33）。この1ファイルに`#if COMPATIBLE_ATCODER_2025`の分岐は無い。

## Test evidence matrix

2026-10-08 / Claude Opus 5.5。`PERM-021`。略記: `F<n>:<行>`は`Tests/PermutationTests/NextPermutationsSequence/NextPermutationsSequence_<n>_*.swift`。
`_98_`（`#if DEBUG`の実装確認）は仕様testではないので参考欄に分けた。test追加・改名はしていない。

| 契約の観点 | 公開宣言 | test | testが実際に固定する事実 |
| --- | --- | --- | --- |
| 公開型の名前と入れ子 | #2 / #4 / #6 | F0:29 | 型注釈つきで`nextPermutations()` → `makeIterator()` → `next()`がcompileでき、最初の結果が入力順 |
| 公開initが無い | #2 | F0:70 | 同名の`fileprivate init?`が曖昧にならずに選ばれる（通常modeだけ） |
| 削除済みAPIの非露出 | — | F0:61 | `unsafePermutations()` / `unsafeNextPermutations()`の2つだけ。旧型名は守れない（F0:16-19に理由） |
| `Sendable` | 適合3件 | F0:36 | 3型とも`Sendable`としてcompileできる（`[Int]`だけ） |
| 列挙順（後続だけ） | #1 / #5 | F1:15、F1:21、F1:27 | 2要素・昇順3要素の全6件・途中開始`[2, 1, 3]`の4件を、順序まで完全一致で固定 |
| 空・単要素 | #1 / #5 | F1:44、F1:50 | 空は`[[]]`、単要素は`[[5]]`の1件だけ |
| 降順・全同値 | #1 / #5 | F1:34、F1:39 | 1件だけ |
| 重複要素 | #1 | F1:54 | `[0, 0, 1]`は3件、`[1, 1, 2, 2]`は6件で、値の重複なし（順序も固定） |
| 非Array入力 | #1 | F1:68、F1:81 | `Range`、起点が0でないslice、`String`（非Int添字）から同じ規則で列挙 |
| 入力を変えない | #1 | F1:88 | 列挙後も元の配列が不変 |
| 取得済み結果の安定性 | #6 | F2:16、F2:26 | 進めた後も、先に取得した結果や集めた全件が列挙時の並びのまま |
| iterator copyの独立 | #4 / #5 | F2:34 | copy後に双方が独立に進む（Swift 6.4 `-O`の誤compileを避けるため、`next()`をassertionの外で呼ぶ） |
| Task越しの安定・独立 | #4 / #6 | F2:49、F2:61 | detached Taskで読む結果が不変。2つのTaskでcopyしたiteratorがそれぞれ全6件を返す |
| 添字は0始まりのInt | #7 / #8 / #9 | F3:15、F3:24 | Array・slice・`String`のどれから作っても`startIndex == 0`、`endIndex == count` |
| 等値・hash | #12 / #13 | F3:35、F3:42 | 別の列挙から得た同じ並びは等しく、違う並びは等しくない。2列挙の和集合の`Set`が6件 |
| 表示 | #14 | F3:48 | `description`と文字列補間が`"[1, 3, 2]"` |
| 添字の有効な両端 | #11 | F3:56 | `startIndex`と`endIndex - 1`で読める |
| swift-algorithmsとの共存 | #1 / #2 | F4:16、F4:23 | 両moduleを同時にimportしても修飾なしで解決できる。後続だけと全順列の違い |
| 境界停止 | #11 | F99:18、26、34、42、50 | `endIndex`、`-1`、`endIndex + 1`、`Int.min`、`Int.max`の読み取りが、正確なtrap signal（Darwinは`SIGTRAP`、Linuxは`SIGILL`）で停止 |

参考（`_98_`、DEBUGだけ、仕様ではない）: headerの破棄が1回（F98:14）、最後の結果を保持して終端まで進めてもcopyしない（F98:25）、
奇数長の反転で参照型要素の寿命が釣り合う（F98:40）、結果を保持しなければcopy 0回（F98:67）。
facade経由の利用: `Tests/AcCollectionsTests/AcCollectionsTests.swift:73`（番号付きの外）。

未検証の契約・観点:

- 終了後に`next()`を何度呼んでも`nil`が続くこと。番号付きtestでは、`map` / `for` / `while let`が最初の`nil`で止まるので確かめていない。
- 同じsequenceから`makeIterator()`を2回呼ぶと、どちらも先頭から列挙されること（再走査）。
- 空の`Permutation`の等値・`description`（`"[]"`）。
- 要素が`Hashable`でないときに`Permutation`が`Hashable`にならないこと（存在しないことのcompile test）。
- doc commentにある「1歩あたり最悪O(n)」と、`-Ounchecked`で検査が省かれうること。`5efc1a9c`の方針で、testではなくコメントに置く約束。
- Release構成でのDeath Test。`DEATH_TEST`はmacOSで構成を問わず定義されるが、Releaseで走らせた記録は今回確認していない（未確認）。
- `Sendable`の`Base`が`[Int]`以外のとき（たとえば`Base: Sendable`で`Element`が非`Sendable`の型）。適合条件の境界はcompile testで固定されていない。

## Naming and contract history

2026-10-08 / Claude Opus 5.5。`PERM-022`。区分は、決定済み（ユーザー判断・承認の記録あり）、履歴上の事実（commit・testはあるが
決定の記録は未確認）、未決定、の3つ。互換modeの再開と文書境界の提案はしない。

| 対象 | 区分 | 内容 | 根拠 |
| --- | --- | --- | --- |
| 入口名`nextPermutations()` | 履歴上の事実 | 2025-01-02の`bab50616`から同名。命名の決定記録は見つからない | `git log -S"func nextPermutations"` |
| 現行3型名 | 決定済み | `Permutations<C>.Nexts` / `IteratorN` / `SubSequenceN`を`NextPermutationsSequence<Base>` / `.Iterator` / `.Permutation`へ改名し、`Permutations`名前空間を廃止（source-breaking、挙動は不変）。理由はcommit本文にある: `N`は削除済みの`All`系と区別するためだけ、`SubSequenceN`は`Collection.SubSequence`と紛らわしい。benchmarkの表題は結果の連続性のため旧名のまま | Registry `PERM-011`（ユーザー承認済み）、`169401a0`（2026-10-07） |
| 削除済みAPI | 決定済み | `unsafePermutations()`、`unsafeNextPermutations()`、`Permutations.All`、`init(safe:)` / `init(unsafe:)`、`IteratorA`、`SubSequenceA`、`_unsafe`フラグとaliasing経路。`Nexts`のinitを`internal`化 | `ImplementationPlan.md:3,34-42`（2026-10-03のユーザー最終決定） |
| 削除済みAPIの非露出の守り方 | 履歴上の事実 | compile時に守れるのは2メソッドだけ。旧型名は改名で外した | F0:16-19、`AtCoder2025CompatibilityPlan.md:37-40`、`169401a0` |
| 仕様の正本 | 決定済み | `Specification.md`を削除し、番号付きtestを正本にした。testで表せない約束はdoc commentへ | Registry `PERM-012`（ユーザー判断）、`5efc1a9c` |
| `Index == Int`制約の除去 | 履歴上の事実 | 任意の`Collection`を受け付ける（spec testを先に追加） | `4a75b9f8`（2026-10-07）、品質評価116行目。ユーザー判断の記録は未確認 |
| 結果の添字は0始まりの`Int` | 履歴上の事実（testに「契約」と明記） | F3:25の「2026-10-07から契約」 | `c204dd9f`。**本文と不一致:** `AtCoder2025CompatibilityPlan.md:42-43`は、sliceでの結果添字の起点を「契約として固定していない（未決）」と書いている |
| `Equatable` / `Hashable` / `CustomStringConvertible` | 履歴上の事実 | 要素の並びだけで決まる（spec testを先に追加） | `c204dd9f`、F3:8。ユーザー判断の記録は未確認 |
| `Collection.count`の契約を信じる | 決定済み | 契約違反の`Collection`へは防御しない | L287-288（2026-10-07、ユーザー判断）、`d8734a65`、品質評価28行目 |
| `Sendable` | 決定済み | Swift 6以降で必須とし、3公開型すべてに適合 | `Maintanance/Current/StrictMemorySafetyReadiness.md:252`（ユーザー決定）、`ImplementationPlan.md:72-75`。どちらの文書も旧名（`IteratorN` / `SubSequenceN`）のまま |
| swift-algorithmsとの共存・使い分け | 履歴上の事実（Registry DONE） | 全順列はswift-algorithmsの`permutations()`、とdoc comment（L17-18）とF4で固定 | Registry `PERM-018`、`0ff5fd84` |
| 互換modeの境界 | 未決定 | 互換modeは`PERM-001`がFROZEN、`PERM-014`がACTIVE（`R-1` / `R-2`が未決）。基準ref `release/AtCoder/2025`は旧名と削除済みAPIを持つ。構成案（file単位の排他`#if`、trait化）は計画だけで未実施。通常版testは`COMPATIBLE_ATCODER_2025`のときF0の非露出検査を外す（F0:44） | `AtCoder2025CompatibilityPlan.md:5-25,45-72,98-123,193-199` |
| facade（`AcCollections`）の再公開 | 履歴上の事実。方針は未決定 | 現在は`PermutationModule`を無条件に`@_exported`（`d421972b`、2026-10-05）。`ImplementationPlan.md:55-57`（2026-10-03）は「互換モードで再公開する経路」と書いており、当時の状態。再公開方針は`Archived/Orientation/AGENT_TASK_FIT_INTERVIEW_2026-10-11.md`へ退避したD3でユーザー判断待ちとされている | `Sources/AcCollections/AcCollections.swift:1-4` |

旧名・旧構成が残る記述（履歴記録として正しい可能性があり、訂正の要否はCodexが判断する）:

- `ImplementationPlan.md:67-68`は`NextPermutationProtocol.swift`経由の1経路と書いている。このprotocolは`0ef177d3`でBufferへ統合された。
- `ImplementationPlan.md:72-75`と`Maintanance/Current/StrictMemorySafetyReadiness.md` §9は`IteratorN` / `SubSequenceN`の旧名で書かれている。
- `Archived/Orientation/AGENT_TASK_FIT_INTERVIEW_2026-10-11.md`へ退避したD3（2026-10-04 review）は「互換modeでだけPermutationを再公開」と書いているが、`d421972b`以後の現状と合わない。この監査の対象外の文書なので、記録だけにする。

## Codex evidence intake（2026-10-08）

`PERM-020` through `PERM-022` were accepted as an evidence package meeting the specified deliverables, prohibitions, and stop conditions. This did not decide to turn every unverified item into a test, immediately correct old documents, or settle policy for compatibility mode or the facade.

Items left for the handoff decision:

- Use the 14 public declarations and nine public conformances as input to the public surface in user-facing documentation.
- Codex selects which unverified specification-test items are necessary for the contract; do not create tasks solely because gaps exist.
- Current tests explicitly define zero-based `Int` indices for `Permutation`, while the compatibility plan contains old text calling this undecided. Separate the current normal-mode contract from unresolved compatibility-mode matters in `PERM-017` and the handoff decision.
- Separate obsolete references to old type names, removed protocol paths, and facade reexport state into those retained as historical records and those requiring correction in current explanations. Claude does not change documents outside scope.
- This evidence audit does not decide the documentation boundary with compatibility mode, user-facing examples, or facade-reexport policy.

## Codex documentation handoff decision（2026-10-08）

After the quality-assessment R-1 through R-4 reviews were complete, the public surface, test evidence, history, and quality assessment were accepted as follows:

- The 14 public declarations and nine conformances appear exactly once in the ledger, allowing reconstruction of the normal-mode public surface.
- Major user-facing contracts are mapped to numbered Test as Specification tests or documentation comments, and unverified matters are separated.
- The three current type names, removed APIs, normal mode, and unimplemented compatibility mode are not conflated.
- Treat zero-based `Int` indices for normal-mode `Permutation` as established by current specification tests. The compatibility plan's “undecided” statement is old or records the unimplemented compatibility mode; it does not override the normal-mode contract.
- The quality assessment completed its initial review and allowed the current normal mode to move to user-facing documentation work. Known `部分` ratings, such as performance efficiency, were not blockers to starting documentation.

Decisions remaining for documentation work were document format, the boundary between normal and compatibility modes, whether to publish performance numbers, example selection, and how to explain facade reexports. None required repeating the public-surface and specification-evidence audit; handle them separately instead of bundling multiple decisions into one task.

On that basis, Permutation was judged ready for handoff to Codex's user-facing documentation work. This audit remains an internal evidence package and is not itself user-facing documentation.
