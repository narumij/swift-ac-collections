# PermutationModule公開API名称候補 姫（Claude）独立提出

`PERM-067`の共通提出表（`PERMUTATION_PUBLIC_API_NAMING_CANDIDATE_FORM.md`）に従う。候補の提出であり、
順位付け・採点・採用ではない。ラベルの番号は記入順で、優先度を表さない。

## 提出情報

| 項目 | 記入欄 |
| --- | --- |
| 提出者 | 姫（Claude Opus 5.5） |
| 独立提出日時 | 2026-10-15 13:15 JST |
| 他の二者の候補を読む前か | はい。ユーザーとV3の候補・採点・意見は読んでいない。提出時点で`Maintanance/Current/`に他者の候補fileは存在しなかった。`Maintanance/Archived/PublicAPINaming/`と`Maintanance/Current/PUBLIC_API_NAMING_DECISIONS.md`は読んでいない |
| 照合したsource・test・公開文書 | `Sources/PermutationModule/NextPermutations.swift`、`BorrowedNextPermutations.swift`、`Compatibility/AtCoder2025/PermutationsAtCoder2025.swift`（宣言部のみ）、`PermutationModule.docc/PermutationModule.md`、`Maintanance/PermutationModule/UserDocumentationDraft.md`、`Tests/PermutationTests/NextPermutations/`・`BorrowedNextPermutations/`・`AtCoder2025Compatibility/`の一覧と共存test、`.build/checkouts/swift-algorithms`の`Permutations.swift`（公開名のみ） |

## 照合した現行契約

提出表の固定契約と現物は一致した。名称の比較に効く事実だけを補う。

- 入口は二つとも`Collection where Element: Comparable`の拡張で、初回に現在の並び、以後は辞書順の後続だけを返す。
  利用者向け本文は、全列挙には`sorted()`から始めるよう案内している。
- 通常版の一時viewは`RandomAccessCollection`で、失効後のaccessはprecondition failureになる。borrowed版は`Span<Element>`を返し、
  専用のview型を持たない。
- borrowed版は`#if compiler(>=6.4)`の内側にある。
- generic parameter名が両ownerで違う。`NextPermutations<Value>`と`BorrowedNextPermutations<Element>`。
- `COMPATIBLE_ATCODER_2025`では、同じ綴りの`nextPermutations()`が`Index == Int`のCollectionに対してAtCoder 2025版
  （`Permutations<Self>.Nexts`、`Sequence`）を返す。borrowed版の共存testは「互換modeでは`nextPermutations()`がAtCoder 2025版の
  APIを指す」と明記している。
- swift-algorithmsの公開名は`permutations(ofCount:)`と`uniquePermutations(ofCount:)`で、どちらも全順列を返す。
  `nextPermutation`は内部名で公開されていない。現行名はswift-algorithmsと衝突しないことが共存testで固定されている。

## A. Module名候補

| 提出者内ラベル | 候補 | 意図する意味 | 利点 | 誤読・懸念 | 互換コスト |
| --- | --- | --- | --- | --- | --- |
| A-1 | `PermutationModule`（維持） | Permutation APIを提供するmodule | `ElementBufferModule`・`OptionalElementBufferModule`と同じ`〜Module`の型で、型名と衝突しない。利用者は通常`AcCollections`からimportする | 「順列一般」を連想させ、辞書順の後続だけを扱うことは名前から分からない。ただしmodule名にそこまで載せる必要は薄い | なし |
| A-2 | `LexicographicPermutationModule` | 辞書順の順列を扱うmodule | 列挙の性質がmodule名から分かる | 長い。全辞書順列挙と誤読し得る。他moduleの命名粒度と合わない | 直接importしている利用者とDocC URLが変わる |

module名を`Permutations`にする案は出さない。互換modeに同名の型`Permutations`があり、module名と型名が衝突するため。

## B. 公開API family候補

| 提出者内ラベル | 通常版入口 | 通常版owner | 通常版一時view | borrowed版入口 | borrowed版owner | 意図する意味 |
| --- | --- | --- | --- | --- | --- | --- |
| B-1 | `nextPermutations()` | `NextPermutations` | `NextPermutations.Permutation` | `borrowedNextPermutations()` | `BorrowedNextPermutations` | 現行維持。C++の`next_permutation`由来の「次の順列を順に出す」を共通語幹にし、borrowed版は寿命検査の方式を接頭辞で示す |
| B-2 | `nextPermutations()` | `NextPermutations` | `NextPermutations.View` | `borrowedNextPermutations()` | `BorrowedNextPermutations` | viewだけを改名し、結果が所有値ではなく一時的な窓であることを型名で示す |
| B-3 | `nextPermutations()` | `NextPermutations` | `NextPermutations.Permutation` | `nextPermutationSpans()` | `NextPermutationSpans` | borrowed版を方式（borrowed）ではなく結果の型（`Span`）で名付け、通常版と語幹の順序をそろえる |
| B-4 | `nextPermutations()` | `NextPermutationCursor` | `NextPermutationCursor.View` | `borrowedNextPermutations()` | `BorrowedNextPermutationCursor` | ownerを「一つの位置を進めるカーソル」と名付け、`Sequence`でも値の集まりでもないことを示す。入口は維持する |

| 提出者内ラベル | 代表call site | familyとしての予測可能性 | 誤読・懸念 | 互換コスト |
| --- | --- | --- | --- | --- |
| B-1 | `var p = xs.nextPermutations(); while let v = p.next() { use(Array(v)) }` / `var p = xs.borrowedNextPermutations(); while let s = p.next() { use(s) }` | 高い。入口とownerが同じ語幹で、borrowed版は接頭辞を足すだけ | (1) 初回に現在の並びを返すのに`next`と読める。(2) 複数形`Permutations`がCollection・`Sequence`を連想させ、`for-in`や`map`を試させる。(3) `Permutation`が所有値に見え、保存できると誤読させ得る。(4) 互換modeでは同じ`nextPermutations()`がAtCoder 2025版（`Sequence`）を指し、build設定で同じcall siteの型と寿命契約が変わる | なし |
| B-2 | `while let view = p.next() { use(Array(view)) }`（型を書く場面は`NextPermutations<Int>.View`） | 中〜高。入口とownerは維持。`View`はRedBlackTreeの共有View等、本package内で「元を参照する一時的な窓」の語として既に使われている | 型名を書く利用者は少なく、効果は主にDocCと診断の読みやすさに限られる。`View`だけでは順列であることが型名から消える | 型名`NextPermutations.Permutation`を明示している利用者のsourceが壊れる（推論で受けている利用者は影響なし）。typealiasで移行期間を置ける |
| B-3 | `var p = xs.nextPermutationSpans(); while let s = p.next() { use(s) }` | 中。通常版と語幹の先頭がそろい、補完で両方が並ぶ。結果の型が名前に出るので、通常版との違いを「何が返るか」で選べる | 寿命をcompilerが検査するという、borrowed版を選ぶ主な理由が名前から消える。`Spans`の複数形がspanの集まりを所有するように読める | borrowed版の入口と型の両方が変わる。`#if compiler(>=6.4)`の範囲なので利用者は少ないと見込むが、未確認 |
| B-4 | `var cursor = xs.nextPermutations(); while let view = cursor.next() { ... }`（型は`NextPermutationCursor<Int>`） | 中。入口は変えず、ownerとviewの役割（位置・窓）が型名から分かる | `Cursor`はSwift標準の語ではなく、DB等のcursorを知らない利用者には説明が要る。入口`nextPermutations()`と型`NextPermutationCursor`の語幹がずれる | owner型名を明示している利用者のsourceが壊れる。DocCの記事・URLも変わる。typealiasで移行期間を置ける |

## C. Surface単位の補足候補

| 提出者内ラベル | 対象surface | 候補 | 意図する意味 | 利点 | 誤読・懸念 | 互換コスト |
| --- | --- | --- | --- | --- | --- | --- |
| C-1 | 通常版入口 | `permutationsFromCurrentOrder()` | 現在の並びから始まる順列 | 初回に現在の並びを含むこと、全列挙ではないことが名前から分かる。互換modeの同名APIと綴りが分かれ、build設定による意味の切り替わりがなくなる | 長い。辞書順の後続であることは名前に出ない。swift-algorithmsの`permutations(ofCount:)`と同じ語頭なので、補完で並び、全列挙と取り違える余地が残る | 入口の利用者全員のsourceが壊れる。borrowed版との対応名も別途必要になる |
| C-2 | 通常版一時view | `NextPermutations.CurrentPermutation` | owner上の「今の」順列 | 一時性（次の`next()`で変わる）が名前から分かり、順列であることも残る | 長い。B-2の`View`よりpackage内の語彙との一貫性は低い | B-2と同じ |
| C-3 | 両owner（generic parameter名） | `NextPermutations<Element>`にそろえる | 両ownerで同じ要素型名を使う | DocCと診断で両ownerの対応が読み取りやすくなる | 通常版の`Permutation`は`Element = Value`のtypealiasを持つため、内部の名前が`Element`と衝突しないよう調整が要る | generic parameter名の変更は通常のsource利用を壊さない見込みだが、未確認 |
| C-4 | borrowed版入口・owner | 候補なし（B-1・B-3以外） | — | — | — | — |

## D. 未解決事項・契約変更案

| 提出者内ラベル | 発見・案 | 名称候補と分離する理由 | 必要な確認またはユーザー判断 |
| --- | --- | --- | --- |
| D-1 | 互換mode（`COMPATIBLE_ATCODER_2025`）では、同じ`nextPermutations()`がAtCoder 2025版の`Sequence`を返す。同じcall siteが、build設定によって所有・寿命・`Sequence`適合の異なる型になる | 解消するには、どちらかの綴りを変えるか互換modeの提供範囲を変える必要があり、互換modeの契約に触れる | 互換modeで現行版の`nextPermutations()`をどう解決させるか（現行版は互換modeでもcompileされる）、および互換modeの名前を固定したまま現行版だけ改名する案（C-1等）を許すか |
| D-2 | 初回に現在の並びを返すことは`next`と食い違って読める。名前で解くと長くなり（C-1）、短い名前のままでは文書に頼ることになる | 列挙範囲（現在の並びを含む）を変える案は契約変更になる | 列挙範囲は固定のまま、名前で伝えるか文書で伝えるか |
| D-3 | 通常版とborrowed版の対応は名前（接頭辞`borrowed`）だけで、borrowed版はSwift 6.4以上でしか存在しない。名前のfamilyと提供toolchainの範囲がずれる | toolchain境界は名称では変えられない | 6.4未満の利用者に対し、DocCの`Choosing an iterator`の記述だけで足りるか |
| D-4 | 複数形`NextPermutations`は、`Sequence`ではないのに`for-in`を誘う。名前を単数（cursor等）にすれば和らぐが、`Sequence`適合を求める声そのものは名前では消えない | `Sequence`適合は`PERM-060`（凍結）の範囲で、名称検討では再開しない | 名称検討の結論が`PERM-060`の判断材料になるかどうかを、ユーザーが決める |

## E. レビュー後補足

| 追記日時 | 発端となった情報 | 候補または訂正 | 独立提出と区別して扱う理由 |
| --- | --- | --- | --- |
|  |  |  |  |

## 提出完了確認

- 六つの現行surfaceすべてについて、維持案・変更案・候補なしのいずれかを記録した（module: A-1・A-2、通常版入口: B-1〜B-4・C-1、
  通常版owner: B-1〜B-4・C-3、通常版一時view: B-1〜B-4・C-2、borrowed版入口・owner: B-1〜B-4・C-3、それ以外は候補なし）。
- 名前だけの案（A〜C）と契約変更・未解決事項（D）を分けた。
- 候補を順位付け、採点、採用していない。
- 他者案を読んでおらず、独立提出を上書きしていない。
