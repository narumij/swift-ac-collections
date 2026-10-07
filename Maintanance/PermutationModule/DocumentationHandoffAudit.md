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

## Public API ledger

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。`PERM-020`。`L<n>`は`Sources/PermutationModule/Permutations.swift`の行
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
| `Sendable` | 決定済み | Swift 6以降で必須とし、3公開型すべてに適合 | `StrictMemorySafetyReadiness.md:252`（ユーザー決定）、`ImplementationPlan.md:72-75`。どちらの文書も旧名（`IteratorN` / `SubSequenceN`）のまま |
| swift-algorithmsとの共存・使い分け | 履歴上の事実（Registry DONE） | 全順列はswift-algorithmsの`permutations()`、とdoc comment（L17-18）とF4で固定 | Registry `PERM-018`、`0ff5fd84` |
| 互換modeの境界 | 未決定 | 互換modeは`PERM-001`がFROZEN、`PERM-014`がACTIVE（`R-1` / `R-2`が未決）。基準ref `release/AtCoder/2025`は旧名と削除済みAPIを持つ。構成案（file単位の排他`#if`、trait化）は計画だけで未実施。通常版testは`COMPATIBLE_ATCODER_2025`のときF0の非露出検査を外す（F0:44） | `AtCoder2025CompatibilityPlan.md:5-25,45-72,98-123,193-199` |
| facade（`AcCollections`）の再公開 | 履歴上の事実。方針は未決定 | 現在は`PermutationModule`を無条件に`@_exported`（`d421972b`、2026-10-05）。`ImplementationPlan.md:55-57`（2026-10-03）は「互換モードで再公開する経路」と書いており、当時の状態。再公開方針は`AGENT_TASK_FIT_INTERVIEW.md`のD3でユーザー判断待ちとされている | `Sources/AcCollections/AcCollections.swift:1-4` |

旧名・旧構成が残る記述（履歴記録として正しい可能性があり、訂正の要否はCodexが判断する）:

- `ImplementationPlan.md:67-68`は`NextPermutationProtocol.swift`経由の1経路と書いている。このprotocolは`0ef177d3`でBufferへ統合された。
- `ImplementationPlan.md:72-75`と`StrictMemorySafetyReadiness.md` §9は`IteratorN` / `SubSequenceN`の旧名で書かれている。
- `AGENT_TASK_FIT_INTERVIEW.md`のD3（2026-10-04 review）は「互換modeでだけPermutationを再公開」と書いているが、`d421972b`以後の現状と合わない。この監査の対象外の文書なので、記録だけにする。

## Codex evidence intake（2026-10-08）

`PERM-020`〜`PERM-022`は、指定された成果物、禁止事項、停止条件を満たす証拠packageとして受け入れる。
これは未検証事項をすべてtestへ追加する判断、古い文書を直ちに修正する判断、互換modeやfacadeの方針を
確定する判断ではない。

引き渡し判定へ残す事項:

- 公開宣言14件と公開適合9件を、利用者向け文書の公開面入力として使う。
- 仕様testの未検証一覧は契約との必要性をCodexが選別し、不足という理由だけでtask化しない。
- `Permutation`の0始まり`Int`添字は現行testで契約と明記される一方、互換計画には未決定という旧記述が
  ある。通常版の現行契約と互換modeの未決定事項を分けて`PERM-017`と引き渡し判定で整理する。
- 旧型名、削除済みprotocol経路、facade再公開状態の古い記述は、履歴資料として残すものと現行説明を
  訂正するものに分ける。Claudeは対象外文書を変更しない。
- 互換modeとの文書境界、利用者向け使用例、facade再公開方針はこの証拠監査では決めない。

`PERM-023`は品質評価reviewの完了も前提とするため、現時点では凍結を維持する。
