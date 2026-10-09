# Array module naming review

最終更新: 2026-10-09 / Codex

## 目的

BareArrayとOptionalArrayの正式公開前に、公開型名と次元名体系がSwift標準ライブラリおよび
`swift-collections`と衝突せず、公開後も長く維持できるかをAI間で検討し、ユーザー判断へ渡す。

AIは名称を決定しない。Claudeが候補と反証を調査し、Codexが同じ証拠を独立評価して統合する。最終的な
公開名は、整理済みの選択肢からユーザーが一件ずつ判断する。

## 判断へ渡す単位

1. BareArrayの所有型、View型、次元名を含む一つの命名体系。
2. OptionalArrayの1D所有型名。
3. OptionalArrayの2D〜4D次元名体系。

上の三判断を一度に要求しない。共有できる衝突調査と対応表は一つにまとめ、推奨と影響は判断単位ごとに
分ける。

## 必須条件

- Swift標準ライブラリの公開型名、主要用語、命名規則と衝突しない。
- `swift-collections`の公開型名、主要用語、命名規則と衝突しない。
- 標準または`swift-collections`由来の型だと利用者が誤認しにくい。
- BareArrayとOptionalArrayの対応関係を説明でき、差異には用途上の理由がある。
- 正式公開前なので、既存名とのsource compatibilityより、公開後の持続性、可読性、検索性、推測可能性を
  優先する。ただし既存利用例とGit利用者への移行影響は記録する。

## Claude調査

次を事実、評価、推奨、反証に分けて提出する。

1. 両moduleの現行公開型、initializer label、subscript軸、`indices`軸の対応表。
2. 使用中のSwift toolchainとpackageが解決している`swift-collections`版を特定した衝突確認。
3. 必要なら、公式のSwift標準ライブラリinterfaceと`swift-collections`一次資料を使った現行公開名の確認。
   調査日、versionまたはcommit、確認範囲を記録する。
4. 現行維持、部分整合、正式公開前の破壊的整合を含む候補。各候補について、利点、欠点、誤認可能性、
   影響する宣言、test・文書・利用例の移行範囲を示す。
5. 三つの判断単位ごとに推奨を一つ示し、その最も強い反証も併記する。

名称候補を考案しただけで衝突なしとみなさない。文字列の完全一致だけでなく、既存collection概念との
意味上の近さ、Swift API Design Guidelinesとの整合も確認する。

## 境界と停止条件

- source、test、利用例、コメントドック、Registryを変更しない。
- rename、typealias、deprecated alias、移行期間を実装しない。
- 公開名を決定しない。
- 性能、View寿命、storage設計、strict memory safetyへ議論を広げない。
- 衝突確認に必要な一次資料へ到達できない場合は、推測で安全とせず未確認範囲として返す。

Claudeはこの文書へ`Claude調査結果`を追記し、`Maintanance/CLAUDE_TASK.md`の状態を返却待ちへ更新して
git addまで行う。Codexはその後に独立評価を追記し、三つのユーザー判断を順次起動できるか判定する。

## Claude調査結果

2026-10-09 12:06 JST / Claude Opus 5.5（`claude-opus-5-5`）。HEAD `63de2e4f`。source・test・利用例・コメントドック・Registryは
変更していない。名称は決定しない。区分: **事**=事実、**評**=評価、**推**=推奨、**反**=反証。

### 1. 現行surface対応表（要約）

詳細な行番号付きの表は`OptionalArrayModule/OptionalArrayAudit.md`の`OPT-028`にあり、その後source変更は無い（**事**）。ここでは
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

現行surface、local toolchain、`swift-collections` 1.7.0、移行範囲、現行維持案の反証は判断材料として
有効である。ただし次の不足があるため、AI間検討としてはまだ受け入れない。

1. 完全一致がないことは必須条件を満たすための必要条件であって、現行名が適切という十分条件ではない。
   `Bare`と`Optional`の意味が実際の所有、固定容量、未初期化slot、非所有Viewの契約をどう表すかを評価する。
2. 接頭語の候補が`Raw`と`Heap`にほぼ限られ、意味上の代替案を探索し切っていない。現行名を上回る候補が
   無いとの結論にする場合も、複数の実質的な候補と棄却理由を示す。
3. `View`の意味ずれを指摘した一方、維持案と代替suffixの比較がない。標準の`Slice`、`Span`、`View`が
   与える寿命・Collection・範囲の期待を比較し、誤認を最小化する案を示す。
4. 判断3-Cは4Dの名前変更と軸契約の反転を混ぜている。storage順と連鎖subscriptの意味を維持した名称変更、
   軸契約自体を変える変更を分離し、後者が別判断なら命名候補へ混ぜない。
5. 公式`swift-collections`の現行`main`は1.7系の安定APIとして`RigidArray`と`UniqueArray`を掲げ、これらを
   Swift標準ライブラリへ加えるSwift Evolution提案SE-0527も公開されている。現在の完全一致だけでなく、
   ownership-aware arrayの命名領域が標準へ移る方向を反証へ含める。

一次資料:

- [`apple/swift-collections` README](https://github.com/apple/swift-collections)
- [SE-0527: RigidArray and UniqueArray](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0527-rigidarray-uniquearray.md)

第三者AIは上の不足だけを補い、既存の事実表と移行件数を作り直さない。追加結果では、各判断単位について
「衝突しない候補」ではなく「契約を最も誤認させにくい候補」を比較し、最強の反証を添える。名称決定、
source変更、軸契約変更は行わない。

Claudeへの補完依頼は開始前に取り止めた。2026-10-09のユーザー指示により、追加調査は
[`CHATGPT_ARRAY_NAMING_REVIEW_REQUEST.md`](CHATGPT_ARRAY_NAMING_REVIEW_REQUEST.md)を使って第三者AIへ
依頼する。Codexはその回答を受け入れた後に独立評価を完成し、ユーザー判断へ渡す。
