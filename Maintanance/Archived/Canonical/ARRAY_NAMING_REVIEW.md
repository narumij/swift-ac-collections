# Array module naming review

最終更新: 2026-10-09 / Codex

## TL;DR（人間向け）
この記録はBareArrayとOptionalArrayの公開名・次元名を検討し、公開前にユーザー判断へ渡すための調査と評価を保存する。初期のClaude調査、追加調査要求、第三者AIの補足、およびCodexの統合評価を含む。

ここにある候補、調査依頼、停止条件は当時の記録であり、現行の指示や未完了の依頼ではない。名称判断と実装を再開する根拠として使わず、現在の状態はTask Registryと現在の公開API資料で確認する。

## 目的

Before BareArray and OptionalArray were formally released, this review examined whether their public type names and dimension naming systems conflicted with the Swift standard library or `swift-collections` and could be maintained over the long term. The review was intended to provide material for the user's decisions.

AI does not decide names. Claude investigates candidates and counterarguments; Codex independently evaluates and integrates the same evidence. The user decides each final public name from the organized options.

## 判断へ渡す単位

1. One naming system for BareArray, including its owning types, View types, and dimension names.
2. The name of the one-dimensional owning type in OptionalArray.
3. The two- through four-dimensional naming system in OptionalArray.

Do not ask for all three decisions at once. Consolidate shared collision research and mapping tables, while keeping recommendations and impacts separate for each decision.

## 必須条件

- Avoid conflict with public type names, key terminology, and naming conventions in the Swift standard library.
- Avoid conflict with public type names, key terminology, and naming conventions in `swift-collections`.
- Make it unlikely that users will mistake a type for one provided by the standard library or `swift-collections`.
- Make the relationship between BareArray and OptionalArray explainable, with a usage-based reason for any difference.
- Because this was before formal release, prioritize long-term maintainability, readability, searchability, and predictability over source compatibility with existing names. Still record the migration impact on existing examples and Git users.

## Claude調査

Submit the following, distinguishing facts, assessments, recommendations, and counterarguments.

1. A mapping of the current public types, initializer labels, subscript axes, and `indices` axes in both modules.
2. Collision checks that identify the Swift toolchain in use and the `swift-collections` version resolved by the package.
3. If needed, confirmation of current public names using the official Swift standard-library interface and primary `swift-collections` sources. Record the investigation date, version or commit, and scope checked.
4. Candidates including retaining current names, partially aligning them, and making a source-breaking alignment before formal release. For each, show advantages, disadvantages, possible user confusion, affected declarations, and migration scope across tests, documents, and examples.
5. One recommendation for each decision unit, with its strongest counterargument.

Do not conclude that a name is conflict-free merely because it was newly proposed. Check semantic similarity to existing collection concepts and consistency with the Swift API Design Guidelines, as well as exact string matches.

## 境界と停止条件

- Do not change source, tests, examples, documentation comments, or the Registry.
- Do not implement renames, type aliases, deprecated aliases, or a migration period.
- Do not decide public names.
- Do not broaden the discussion to performance, View lifetime, storage design, or strict memory safety.
- If primary sources needed for collision checking are unavailable, report the unverified scope instead of assuming safety.

The historical assignment asked Claude to append `Claude調査結果` to this document, set the state in `Maintanance/CLAUDE_TASK.md` to awaiting return, and stage the result. Codex was then to append an independent assessment and decide whether the three user decisions could be initiated in sequence. This describes the former workflow and grants no current authority to update the Registry or Git state.

## Claude調査結果

2026-10-09 12:06 JST / Claude Opus 5.5（`claude-opus-5-5`）。HEAD `63de2e4f`。source・test・利用例・コメントドック・Registryは
変更していない。名称は決定しない。区分: **事**=事実、**評**=評価、**推**=推奨、**反**=反証。

### 1. 現行surface対応表（要約）

詳細な行番号付きの表は`OptionalElementBufferModule/OptionalElementBufferAudit.md`の`OPT-028`にあり、その後source変更は無い（**事**）。ここでは
判断に効く行だけを抜く。

| 項目 | BareArray | OptionalArray | 一致 |
| --- | --- | --- | --- |
| 1D所有型 | `BareArray` | `OptionalArray1D` | 不揃い |
| 2D〜4D所有型 | `BareArray2D`〜`4D` | `OptionalArray2D`〜`4D` | 一致 |
| View型 | `BareArray1DView`〜`3DView` | `OptionalArray1DView`〜`3DView` | 一致（1D Viewは両方とも`1D`付き） |
| 2D・3Dの次元label | `width:height:` / `width:height:depth:` | 同じ | 一致 |
| 4Dの次元label | `size0:size1:size2:size3:` | 同じ | 一致（2D・3Dと体系が違う点も同じ） |
| subscriptが選ぶ軸 | 2D `height`、3D `depth`、4D `size3`（外側から） | 同じ | 一致 |
| `indices`の軸 | 外側の軸 | 同じ | 一致 |
| 最も内側（連続する）軸 | 2D・3D `width`、4D `size0` | 同じ | 一致 |

軸の順（**事**）: 2Dは`a[y][x]`（`height`→`width`）、3Dは`a[z][y][x]`、4Dは`a[i3][i2][i1][i0]`。4Dの番号は、subscriptを書く順と逆に
増える（最初に書く添字が`size3`、最後が`size0`）。

### 2. 衝突確認（一次資料）

- Swift標準ライブラリ: toolchain `Apple Swift 6.4 (swiftlang-6.4.0.34.1)`。2026-10-09に、各名前を`typealias _P = 名前`として
  `swiftc -typecheck`し、存在を判定した（toolchainのファイルは読んでいない。compilerの名前解決だけを使った）。
  - 存在しない（衝突なし）: `BareArray`、`BareArray1D`〜`4D`、`BareArray1DView`〜`3DView`、`OptionalArray`、`OptionalArray1D`〜`4D`、
    `OptionalArray1DView`〜`3DView`。参考に`Array2D`、`Grid`、`Grid2D`、`Matrix`、`FixedArray`、`RawArray`、`HeapArray`、`DenseArray`も無い。
  - 存在する（意味が近い既存型）: `InlineArray`、`Span`、`MutableSpan`、`RawSpan`、`ContiguousArray`、`ArraySlice`、`Slice`。**事**
- `swift-collections`: root packageは依存していない。`Benchmarks`が`1.7.0`（`a66de878`）を解決している。そのcheckoutの`Sources`
  全体から`public struct|enum|class|protocol|typealias`の型名を抽出した。**事**
  - 現行名・`OptionalArray`系との完全一致: なし。
  - 意味が近い型: `RigidArray`、`UniqueArray`（`BasicContainers`、所有を一意にできる配列）、`TrailingArray`、`BitArray`、
    `UTF8View` / `UTF16View` / `UnicodeScalarView` / `UnorderedView`、`Heap`。
- 未確認範囲: `swift-collections` 1.7.0より新しい版、Foundationなど標準以外のApple framework。

### 3. 意味上の近さとAPI Design Guidelines（評価）

- `BareArray`: `~Copyable`でheapに連続確保する点は、`swift-collections`の`RigidArray` / `UniqueArray`と用途が近い。名前は重ならないが、
  「同じ系統の部品か」と思われる余地はある。**評**
- `Bare`: 標準・`swift-collections`のどちらにも使われていない語で、検索で埋もれにくい。一方、何を省いたのか（境界検査は残っている）は
  名前から読めない。`Raw`は`UnsafeRawPointer`・`RawSpan`の「型なしbyte」の意味と衝突するので、置き換え候補として不適。`Heap`は
  `swift-collections`の`Heap`（優先度queue）と衝突する。**評**
- `View`: 標準の`String.UTF8View`などは、元の値を別のCollectionとして見るvalue型で、Collectionに適合する。BareArray・OptionalArrayの
  Viewは、Collectionに適合せず、所有者を指す非所有のpointerで、逃がせる。用語の意味がずれている。ただし`*Slice`からの改名（`1b461564`）は、
  標準の`Slice` / `ArraySlice`（同じ次元の部分範囲）との衝突を避けた点で妥当。`Span`は概念が最も近いが、標準の`Span`は寿命を型で保証する
  （`~Escapable`）ため、保証の無いこのViewに付けると誤認を招く。**評**
- `OptionalArray`: 「`Optional`の配列」とも「`Array`の`Optional`」とも読める。`1D`の有無はこの曖昧さを解かない。**評**
- 次元名: 2D・3Dの`width` / `height` / `depth`は空間の語で読みやすい。4Dに対応する空間の語は定まっておらず、`size0`〜`size3`は
  それを避けた結果と読める（選んだ理由の記録は無い、`OPT-027`）。番号がsubscriptの順と逆なのは推測しにくい。**評**

### 4. 移行範囲（`git grep -w`、2026-10-09）

| 名前 | 出現 | file数 |
| --- | ---: | ---: |
| `BareArray` | 34 | 9 |
| `BareArray2D` / `3D` / `4D` | 20 / 18 / 20 | 4 / 4 / 4 |
| `OptionalArray1D` | 24 | 10 |
| `OptionalArray2D` / `3D` / `4D` | 26 / 24 / 30 | 10 / 9 / 8 |

対象は`Sources`、`Tests`、`Benchmarks/Sources`、`Utilities`、`README.md`、`Documentation`。README・`Documentation`・DocCには両moduleの型名が
出てこない（**事**）。`AcCollections`は両moduleを`@_exported import`しているので、名前は`AcCollections`利用者にもそのまま見える（**事**）。
次元labelは両moduleのsourceとtestに広く出る（`width:`系・`size0:`系とも、testの大半のfile）。

### 5. 判断単位ごとの候補・推奨・反証

#### 判断1: BareArrayの命名体系

| 候補 | 内容 | 利点 | 欠点 |
| --- | --- | --- | --- |
| 1-A 現行維持 | 1Dは`BareArray`、多次元は`BareArray2D`〜`4D`、Viewは現行 | 最も使う1Dが短い。標準の`Array`（1Dに次元名を付けない）と同じ形。移行なし | 1D所有型だけsuffixが無く、`BareArray1DView`と並ぶと推測しにくい |
| 1-B 1Dにsuffix | `BareArray` → `BareArray1D` | 全次元が同じ形になり、推測・検索しやすい | 最頻出の型が長くなる。34箇所・9 fileの移行 |
| 1-C 接頭語の変更 | `Bare`を別の語へ | — | 衝突が見つかっていないので、変える根拠が無い。代わりの語（`Raw`・`Heap`）はむしろ衝突する |

推奨（**推**）: 1-A。次元名は判断3に従い、OptionalArrayと同じ体系にそろえる。
最も強い反証（**反**）: OptionalArrayが1Dに`1D`を付けたままなら（判断2で維持なら）、2つのmoduleの1D型名がそろわない。そのときは1-Bのほうが
「対応関係を説明できる」という必須条件に合う。判断1と判断2は、そろえる向きを1つに決めないと両立しない（1-Aと2-B、または1-Bと2-A）。

#### 判断2: OptionalArrayの1D所有型名

| 候補 | 内容 | 利点 | 欠点 |
| --- | --- | --- | --- |
| 2-A 現行維持 | `OptionalArray1D` | 全次元が同じ形。移行なし | BareArray（1-A）とそろわない |
| 2-B suffixを外す | `OptionalArray1D` → `OptionalArray` | BareArray・標準の`Array`と同じ形 | `OptionalArray`単独だと「`Array`の`Optional`」と読まれやすくなる。24箇所・10 fileの移行 |

推奨（**推**）: 2-B（判断1の1-Aとそろえる）。
最も強い反証（**反**）: `OptionalArray`という1語は型の性質（要素が`Optional`）を誤読させる。`1D`が付いていると「次元を持つ配列の一種」と
読めるので、誤読が少し弱まる。また、移行の量はBareArrayより多い。

#### 判断3: OptionalArrayの2D〜4D次元名体系（BareArrayも同じ体系にそろえる前提）

| 候補 | 内容 | 利点 | 欠点 |
| --- | --- | --- | --- |
| 3-A 現行維持 | 2D・3D `width`/`height`/`depth`、4D `size0`〜`size3` | 2D・3Dは読みやすい。移行なし | 2つの体系が混ざる。4Dの番号がsubscriptの順と逆 |
| 3-B 全次元を`sizeN` | 2Dも`size0:size1:`など。`size0`が最も内側 | 体系が1つになる | 2D・3Dの読みやすさを失う。番号が逆な問題は残る |
| 3-C 番号をsubscript順に | 4Dで`size0`を最も外側にする | subscriptを書く順と番号が一致 | 「`size0`が最も内側（`width`の位置）」という現行の対応が逆転し、既存利用者が最も間違えやすい変更になる |

推奨（**推**）: 3-A。両moduleで同じ体系を保ち、「4Dは`a[size3の添字]…[size0の添字]`の順に書く」ことをユーザードキュメントで明示する。
最も強い反証（**反**）: 推測可能性が必須条件の1つで、番号がsubscriptと逆な体系は、公開後に長く維持するほど誤用を生む。公開前のいまなら
3-Cの移行費用は最も小さい。

### 6. 停止事項

なし。renameや互換aliasは実装していない。

## Codex予備評価 — 追加調査要求（2026-10-09）

The current surface, local toolchain, `swift-collections` 1.7.0, migration scope, and counterarguments to retaining current names were useful decision inputs. However, the review was not yet accepted as a complete inter-AI evaluation because of these gaps:

1. Lack of an exact match is necessary to meet the requirements but is not sufficient to show that current names are suitable. Assess how `Bare` and `Optional` communicate actual ownership, fixed capacity, uninitialized slots, and non-owning View contracts.
2. Prefix alternatives were nearly limited to `Raw` and `Heap`, leaving semantic alternatives unexplored. Even if no candidate is better than the current name, provide several substantive options and explain why each is rejected.
3. The review noted a semantic mismatch in `View` but did not compare retaining it with alternative suffixes. Compare the lifetime, Collection, and range expectations conveyed by standard `Slice`, `Span`, and `View`, and identify the choice least likely to mislead users.
4. Option 3-C combines a four-dimensional naming change with reversal of the axis contract. Separate a naming change that preserves storage order and chained-subscript semantics from a change to the axis contract itself. Do not mix the latter into naming candidates if it requires a separate decision.
5. The official `swift-collections` `main` advertises `RigidArray` and `UniqueArray` as stable APIs in the 1.7 series, and Swift Evolution proposal SE-0527 proposes adding them to the standard library. Include this movement of ownership-aware array terminology toward the standard library as a counterargument, beyond checking current exact matches.

一次資料:

- [`apple/swift-collections` README](https://github.com/apple/swift-collections)
- [SE-0527: RigidArray and UniqueArray](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0527-rigidarray-uniquearray.md)

The third-party AI was to address only the gaps above without recreating existing fact tables or migration counts. For each decision unit, compare names least likely to misrepresent the contract rather than merely names without collisions, and include the strongest counterargument. Do not decide names or change source or axis contracts.

The planned supplemental assignment to Claude was cancelled before it began. Under the user's 2026-10-09 instruction, supplemental research was instead requested from a third-party AI using [`CHATGPT_ARRAY_NAMING_REVIEW_REQUEST.md`](CHATGPT_ARRAY_NAMING_REVIEW_REQUEST.md). Codex would complete its independent assessment after accepting that response and then return the material for the user's decisions.

## Codex独立評価 — 第三者AI補完調査の受入（2026-10-09）

The third-party response was received as [`CHATGPT_ARRAY_NAMING_REVIEW_COMPLEMENT.md`](CHATGPT_ARRAY_NAMING_REVIEW_COMPLEMENT.md). Codex compared the full response with primary sources and accepted it as supplemental evidence for `BARE-012` and `OPT-043` because it filled these gaps in Claude's initial review:

 - It compared `Fixed`, `Rigid`, `Contiguous`, `Raw`, `Unsafe`, `Dense`, `Static`, `Flat`, and `Buffer` as alternatives to `Bare`, rejecting names that overpromise the current contract or strongly invite confusion with existing concepts.
 - It compared `View` with `Slice`, `Span`, and `UnsafeView`, distinguishing the expectations each term creates about range retention, lifetime guarantees, and pointer APIs.
 - It separated changing names without changing four-dimensional storage axes from reversing the axis contract itself.
 - It considered the current official `swift-collections` series and SE-0527 to assess semantic proximity as an ownership-aware array, not only exact matches. Codex independently reconfirmed from primary sources that SE-0527 was implemented in Swift 6.4.

Codex's integrated conclusions were:

1. Retain the BareArray owning types `BareArray` / `BareArray2D` through `4D` and the non-owning types `BareArray1DView` through `3DView`. `Bare` does not directly express fixed capacity, but it avoids incorrectly promising a variable-count container like `RigidArray`, lifetime guarantees like standard `Span`, or untyped bytes like `Raw`. `UnsafeView` is a strong counterargument, but it foregrounds risk rather than role and can imply a pointer API, so it is not better than the existing `View`. State lifetime obligations in the public contract rather than the name.
2. The arguments for retaining `OptionalArray1D` and renaming it to `OptionalArray` are balanced. Do not decide solely to match BareArray's appearance; leave to the user whether slot arrays should be treated as an independent type family.
3. Retain `width` / `height` / `depth` for dimensions two and three and `size0` through `size3` for dimension four. Prefer clarity in common two- and three-dimensional uses over mechanical uniformity, and document that four-dimensional numbering is opposite to chained-subscript order. Do not include reversing the axis contract in the naming decision.

The response's `:chatgpt-content-reference` markers are source-specific and cannot be resolved in the repository. Preserve the source response as input evidence; the integrated conclusions above rely only on primary sources that can be resolved. Not every candidate name received an exhaustive collision check. However, all recommendations retain current names, and the combination of Claude's exact-match checks for current names and the third party's semantic comparisons was considered sufficient material for the user's three sequential decisions.
