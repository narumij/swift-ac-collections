# Array module 命名レビュー補完
**第三者AI独立評価 — 2026-10-09 / GPT-6**

## 0. 総合評価

先行するClaude調査とCodex予備評価を入力として、命名の意味的妥当性を追加評価した。

今回の評価では、**既存名と衝突しないことと、既存概念との誤認を防げることを明確に区別する。**

また、BareArrayとOptionalArrayについて、表面的な統一よりも、それぞれが提供する抽象化の違いを優先する。

### 暫定結論

| 判断単位 | 第三者AIの推奨 | Claude推奨との差 |
|---|---|---|
| 1. BareArray命名体系 | `BareArray`系を維持し、Viewも維持。1D所有型は次元suffixなし | 結論は概ね一致。ただし代替接頭語とViewの検討を追加 |
| 2. OptionalArrayの1D所有型 | `OptionalArray1D`を維持 | **Claudeの`OptionalArray`推奨に反対** |
| 3. OptionalArrayの2D〜4D次元名 | 2D・3Dは`width/height/depth`、4Dは`size0...size3`を維持 | 結論は一致。ただし軸順変更を命名判断から除外 |

いずれも最終決定ではない。

特に判断2については、BareArrayとの命名統一だけを根拠に`OptionalArray1D`から`1D`を取り除くことには合理性が乏しいと評価する。

---

## 1. 一次資料の追加確認

### 1.1 swift-collectionsの現行main

2026年10月9日に公式リポジトリの`main`を確認した。

`BasicContainers`の安定したデータ構造として、以下が掲載されている。

| 型 | 主要な契約 |
|---|---|
| `UniqueArray<Element>` | 一意所有、動的容量 |
| `RigidArray<Element>` | 固定容量、非コピー可能 |
| `TrailingArray` | 特殊な連続storage配置を扱う低レベルコンテナ |

`UniqueArray`と`RigidArray`は、ownership-awareな配列として明確に位置付けられている。:chatgpt-content-reference{index="0"}

これは、今回の命名評価にとって重要である。

単に`BareArray`と同名の型が存在しないという問題ではなく、**所有形態や容量制約を表す接頭語が、公式ライブラリ側ですでに体系化されている**ためである。

したがって、`Unique`、`Rigid`、`Fixed`などを使う場合には、既存の公式APIとどのように意味を区別できるかを確認する必要がある。

### 1.2 SE-0527 — RigidArray / UniqueArray

[SE-0527](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0527-rigidarray-uniquearray.md)を確認した。

**重要な追加事実として、現在の提案ステータスは`Implemented (Swift 6.4)`である。**

単に標準ライブラリへの採用を検討している段階ではない。:chatgpt-content-reference{index="1"}

提案では、両型が連続したheap storageを持ち、部分初期化を許容する構造として説明されている。ただし初期化済み要素は先頭側に連続して配置され、配列としての`count`と最大`capacity`を区別する。:chatgpt-content-reference{index="2"}

ここはOptionalArrayとの差別化に重要である。

OptionalArrayは、与えられた説明によれば、各slotが独立して未設定状態を持てる固定容量配列である。

したがって、両者は次のように区別できる。

| 特性 | `RigidArray` | `OptionalArray` |
|---|---|---|
| 固定容量 | あり | あり |
| 連続storage | あり | あり |
| 未設定部分 | 初期化済み要素の後方 | 各slotが独立 |
| 添字の意味 | 初期化済み要素の位置 | 固定されたslotの位置 |
| 主たる抽象化 | 容量制約付き配列 | 未設定slotを保持できる配列 |

ここでいうOptionalArrayの未設定状態は、ユーザー提供の製品仕様に基づく。

**結論：OptionalArrayが担う「固定された添字空間とslotごとの設定状態」は、RigidArrayとは異なる抽象化である。**

この違いが伝わる命名を重視すべきであり、単なる所有形態や固定容量を示す名前への変更には慎重であるべきだ。

## 2. 判断1 — BareArrayの命名体系

### 2.1 接頭語の比較

BareArrayの主な契約は次のとおり。

- 固定容量の連続storageを所有する。
- 競技プログラミング向けの低レベル配列である。
- 1D〜4Dの所有型を持つ。
- 1D〜3Dの非所有Viewを持つ。
- Viewは所有者の寿命を型システムで保証しない。

`Bare`の代替候補を、これらの契約との一致度で評価する。

| 接頭語 | 伝わる特性 | 誤認させる可能性 | 評価 |
|---|---|---|---|
| `Bare` | 低レベル、余分な機能を持たない | 境界検査や安全性まで省略している印象 | **有力** |
| `Fixed` | 固定容量 | 標準の`InlineArray`などと区別しにくい。固定長・固定容量の区別も曖昧 | 次点 |
| `Rigid` | 固定容量、制約の強い所有型 | 公式`RigidArray`と重なる | 棄却 |
| `Contiguous` | 連続storage | 標準の`ContiguousArray`と混同。容量制約が伝わらない | 棄却 |
| `Raw` | 低レベルなmemory操作 | `RawSpan`などの型なしbyte storageを連想する | 棄却 |
| `Unsafe` | 安全性の保証が弱い | 所有型自体も常にunsafeな操作を要求すると誤認させる | 棄却 |
| `Dense` | 密なデータ配置 | 行列・tensorの密表現を連想し、容量制約が伝わらない | 棄却 |
| `Static` | サイズが変わらない | コンパイル時に容量が決まる印象。`InlineArray`との混同 | 棄却 |
| `Flat` | 平坦なstorage | 多次元型の構造、固定容量、所有形態が伝わらない | 棄却 |
| `Buffer` | storageを直接扱う | 配列抽象よりmemory領域を強調しすぎる | 棄却 |

#### Bareの評価

`Bare`の長所は、標準ライブラリにおいて既に意味が確立している`Raw`、`Rigid`、`Unique`などの語を流用しないことである。

反面、`Bare`だけでは何が削ぎ落とされているのか判別できない。

例えば次の性質は名前から推測できない。

- 容量は固定されるのか。
- 初期化済み要素数は変化するのか。
- 値の所有権はどう扱われるのか。
- 境界検査が存在するのか。

しかし、これは`Bare`が誤った契約を積極的に主張することとは異なる。

`Fixed`は容量制約をより明確にするが、`FixedArray`という名称は広範な固定長配列の一般名として読まれやすい。

特に、Swift標準ライブラリ側には`InlineArray`や`RigidArray`があるため、`FixedArray`がそのどちらに近いかが不明確になる。

**評価：`Bare`は情報量が少ないが、公式APIの既存概念を誤って約束しにくい。**

ただし、競技プログラミング向けの低レベル配列であるという製品文脈がなければ、`Fixed`のほうが理解しやすい可能性は残る。

### 2.2 View suffixの比較

ここはClaudeの先行調査を補強する必要がある。

Swift標準ライブラリでは、`Slice`、`Span`、`View`が同じ意味で使われているわけではない。

| suffix | Swiftでの期待 | このpackageとの違い |
|---|---|---|
| `Slice` | Collectionの部分範囲。元の添字体系を保持することが多い | 次元を一つ減らすpointer表現とは異なる |
| `Span` | 連続memoryへの非所有アクセス。寿命制約を型で扱う | packageのViewには寿命保証がない |
| `View` | 元データに対する別の表現・アクセス方法 | Collection適合や寿命保証の有無は名前だけでは明確でない |
| `Buffer` | memory領域へのアクセス | 非所有であることが明確ではない |
| `BufferView` | bufferを参照する別表現 | Collection的Viewかpointer型か判別できない |
| `Pointer` | memory addressを扱う型 | 多次元の添字アクセスを提供する抽象化を表しきれない |
| `UnsafeView` | 安全性の保証が限定されたView | 名前が長いが、寿命保証がないことを警告しやすい |
| `BorrowedView` | 借用された非所有View | Swiftの借用・寿命制約が保証される印象を与える |

### 2.3 Sliceは不適切

標準の`ArraySlice`は元の配列とstorageを共有し、Collectionとして振る舞う。

元の配列変数が寿命を終えたからといって、直ちにstorageが解放されるわけではない。`ArraySlice`自身によるstorage保持がある。:chatgpt-content-reference{index="3"}

これに対して、BareArrayのViewは所有者のpointerを共有する非所有型である。

さらに、

```swift
let row = array[y]
```

という表現では、2Dから1Dへ次元を減らしている。

これは同じ次元の要素範囲を切り出す操作とは意味が違う。

**結論：`Slice`へ戻すことは推奨しない。**

### 2.4 Spanはさらに不適切

Swiftの`Span`は非所有かつ非escapingなmemory viewとして設計されている。

標準ライブラリの説明では、所有元の寿命と結び付いた安全性が主要な特徴である。:chatgpt-content-reference{index="4"}

したがって、

```swift
BareArray2DSpan
```

という命名は、packageが実際には提供していない寿命保証を利用者に期待させる可能性が高い。

これは単なる語感の問題ではない。

**`Span`が示唆する保証を欠くことは、API契約に関する実質的な誤認につながる。**

よって棄却する。

### 2.5 UnsafeViewはどうか

`UnsafeView`には合理性がある。

```swift
BareArray1DUnsafeView
BareArray2DUnsafeView
BareArray3DUnsafeView
```

とすれば、標準の安全な非所有Viewと誤認される可能性を減らせる。

一方、Swiftの`UnsafeBufferPointer`などの名称からは、pointer操作が主要APIであるとの期待が生じる。

BareArrayのViewが添字による多次元アクセスを主目的とするなら、`Unsafe`が抽象化の中心に出すぎる。

この点で、`UnsafeView`は安全性の警告としては優秀だが、型の役割を表す名前としては`View`より劣る。

ただし、寿命保証の誤認防止を最優先する場合、`UnsafeView`は最後まで残すべき対抗候補である。

### 2.6 所有型の1D suffix

| 候補 | 利点 | 欠点 |
|---|---|---|
| `BareArray` | 短い。Swiftの`Array`と同様に1Dを基本形と扱える | View側の`1D`と不揃い |
| `BareArray1D` | すべての所有型が同じ命名規則 | 基本形に冗長な次元を追加する |

SwiftのAPI Design Guidelinesでは、使用箇所での明瞭さを重視する一方、不要な語の追加も避けるよう求めている。:chatgpt-content-reference{index="5"}

今回、所有型は`BareArray`自体が基本形であり、`2D`以降が拡張形だと解釈できる。

一方、Viewは所有型とは異なる型系列であり、対象の次元数をsuffixで示すことに意味がある。

そのため、次の非対称性は許容できる。

```swift
BareArray

BareArray2D
BareArray3D
BareArray4D

BareArray1DView
BareArray2DView
BareArray3DView
```

### 判断1の推奨

**推奨：現行のBareArray命名体系を維持する。**

| 要素 | 推奨 |
|---|---|
| 接頭語 | `Bare` |
| 1D所有型 | `BareArray` |
| 2D〜4D所有型 | `BareArray2D`〜`BareArray4D` |
| 非所有型 | `BareArray1DView`〜`BareArray3DView` |

理由は、一般的な固定容量配列と違う低レベル用途を表しつつ、標準の`RigidArray`や`Span`の具体的な契約を誤って主張しないためである。

#### 最も強い反証

**`Bare`という接頭語から固定容量という重要な製品契約を推測できない。**

したがって、名前だけを見た利用者に対しては、`FixedArray`のほうが説明的である。

さらに、`View`はSwiftの標準的なCollection Viewと異なり、所有者の寿命を保証しない。

安全性の契約を名前に反映すべきだという立場なら、`BareArray1DUnsafeView`などのほうが適切になる。

この二点は、現行名維持に対する実質的な反証である。

#### 未確認範囲

- BareArrayのinitializerが初期化状態に対して提供する具体的な保証。
- Viewのpublic APIがpointer操作をどの程度直接公開しているか。
- `BareArray`とその代替候補に関する、公式`main`以外のサードパーティライブラリとの意味的競合。
- 提案した新名称すべてについての完全なコンパイラ名前解決検査。

---

## 3. 判断2 — OptionalArrayの1D所有型

### 3.1 まずOptionalの意味を整理する

この判断では、BareArrayとの表面的な対応よりも重要な問題がある。

Swiftでは`Optional<T>`が明確な意味を持つ。

```swift
Int?
```

は、値が存在するかどうかを表す。

これに対してOptionalArrayが提供するのは、**配列全体の有無ではなく、各slotに値が存在するかどうか**という性質である。

つまり、

```swift
OptionalArray<Int>
```

という名前には、二つの解釈が成立しうる。

1. OptionalなArray。
2. 各要素がOptionalなArray。

この曖昧さは、`OptionalArray1D`という名前でも完全には解消されない。

### 3.2 実質的な代替接頭語

| 接頭語 | 伝わる特性 | 誤認可能性 | 評価 |
|---|---|---|---|
| `Optional` | slotに値が存在しない状態 | 配列全体がOptionalとも読める | 有力 |
| `Sparse` | 全位置に値があるわけではない | 疎行列や非連続storageを連想する | 棄却 |
| `Slot` | 固定された位置に値を入れる | 未設定状態の存在が伝わりにくい | **対抗候補** |
| `Nullable` | nil相当の状態を保持できる | Swiftでは`Optional`のほうが自然 | 棄却 |
| `Partial` | 一部の位置だけ設定済み | 未初期化の途中状態と誤認する | 棄却 |
| `Maybe` | 値の存在が不確定 | Swift標準の用語体系と一致しない | 棄却 |
| `SparseSlot` | 未設定slotと固定位置を連想できる | 長く、疎なstorage実装と誤認する | 棄却 |
| `Fixed` | 固定容量 | OptionalArray固有の設定状態が消える | 棄却 |
| `Rigid` | 固定容量 | 公式`RigidArray`との意味的衝突 | 棄却 |

### 3.3 SparseArrayを棄却する理由

`SparseArray`は、一見するとOptionalArrayの性質をよく説明する。

例えば、

```text
[12, nil, nil, 47, nil]
```

のような状態を表すには適切に思える。

しかし、一般的な疎配列や疎行列では、値の存在しない位置にstorageを割り当てない実装が広く使われる。

OptionalArrayは、固定容量の連続storageと未設定slotを持つ配列である。

つまり、**疎なのは値の存在状態であり、storage配置ではない。**

`SparseArray`はこの区別を曖昧にするため、推奨しない。

### 3.4 SlotArrayをどう評価するか

`SlotArray`は有力な対抗候補である。

```swift
SlotArray1D
SlotArray2D
SlotArray3D
SlotArray4D
```

という命名では、固定された位置を持つ配列という性質が比較的自然に伝わる。

特に競技プログラミングでは、あらかじめ確保した位置に後から値を書き込むという用途に合っている。

ただし、`Slot`そのものは値の不在を意味しない。

すべてのslotに必ず値が存在する配列も`SlotArray`と呼べてしまう。

その意味では、OptionalArrayの中心的な特徴を名前から取り除いてしまう。

**評価：`SlotArray`は配置の抽象化として優れているが、未設定状態を表す契約では`OptionalArray`に劣る。**

### 3.5 1D suffixの比較

| 候補 | 利点 | 欠点 |
|---|---|---|
| `OptionalArray1D` | 多次元型との対応関係が明確 | 1Dが冗長。Optional自体の曖昧さは残る |
| `OptionalArray` | 短く、SwiftのArrayと同じ基本形 | Optional<Array>との意味的な曖昧さが強くなる |
| `SlotArray1D` | 固定slotの概念が伝わる | 未設定状態の表現が弱い |
| `PartialArray1D` | 一部だけ値が存在することを示唆 | 中途半端な初期化状態にも読める |

### 3.6 BareArrayと統一すべきか

ここでClaudeの推奨と判断が分かれる。

Claudeは、

```swift
BareArray
OptionalArray
```

という統一を支持した。

しかし、両者の用途には違いがある。

BareArrayは、一次元の連続配列を基本として多次元型に拡張したものと解釈できる。

一方、OptionalArrayは、位置ごとに設定状態を持つ固定された添字空間を提供する。

つまり、

- BareArrayでは、基本の配列を中心に考える。
- OptionalArrayでは、次元を持つslot集合を中心に考える。

という製品上の区別が可能である。

この区別を採用するなら、次の非対称性は説明できる。

```swift
BareArray
BareArray2D

OptionalArray1D
OptionalArray2D
```

重要なのは、**命名上の非対称性をなくすためだけに、意味的に異なる抽象化を同じ形式へ押し込まないこと**である。

ただし、`1D`があるからといってOptionalArrayの未設定状態がより明確になるわけではない。この点では、Claudeの反証は妥当である。

### 判断2の推奨

**推奨：`OptionalArray1D`を維持する。**

主な理由は、1D〜4Dを固定された次元付きslot集合の一系列として理解できるためである。

`OptionalArray`も合理的な候補だが、BareArrayとの統一以外に明確な優位性を見出せない。

現行維持を支持する理由は移行費用ではない。

OptionalArrayの用途を踏まえると、`1D`は必ずしも冗長ではなく、多次元のslot集合の一種であることを表している。

#### 最も強い反証

**`1D`はOptionalArrayの中心的な契約である未設定slotを何も説明しない。**

Swift標準の`Array`が1Dを基本形とする以上、`OptionalArray1D`は不必要に長いという見方も十分成立する。

実際、`OptionalArray`の意味的曖昧さを解決する必要があるなら、次元suffixより接頭語そのものを変更すべきである。

したがって、`OptionalArray1D`の優位性は決定的ではない。

#### 未確認範囲

- 未設定slotを読み出した際の具体的なAPI契約。
- 各slotの状態が`Element?`として表現されるか、別の状態管理を使うか。
- `SlotArray`などの代替候補についての網羅的な外部ライブラリ衝突調査。
- 1D所有型を利用する既存ユーザーが、次元suffixにどの程度意味を見出しているか。

---

## 4. 判断3 — OptionalArrayの2D〜4D次元名体系

この判断で重要なのは、次の二つを分離することである。

**A. 次元を表す名前の変更**

**B. storage順・添字順・軸契約の変更**

Bは命名レビューの範囲外である。

### 4.1 現行の軸契約

Claudeの調査結果を前提とする。

| 次元 | initializer label | 連鎖subscript | 最も内側の軸 |
|---|---|---|---|
| 2D | `width:height:` | `a[y][x]` | width |
| 3D | `width:height:depth:` | `a[z][y][x]` | width |
| 4D | `size0:size1:size2:size3:` | `a[i3][i2][i1][i0]` | size0 |

この対応を維持したまま、名称だけを変更する候補を比較する。

### 4.2 軸契約を変えない名称候補

| 候補 | 2D | 3D | 4D | 評価 |
|---|---|---|---|---|
| A. 現行 | width/height | width/height/depth | size0〜size3 | 有力 |
| B. 全次元をsize番号 | size0/size1 | size0〜size2 | size0〜size3 | 統一性が高い |
| C. 全次元をdimension番号 | dimension0/1 | dimension0〜2 | dimension0〜3 | 意味は明確だが長い |
| D. 全次元をextent番号 | extent0/1 | extent0〜2 | extent0〜3 | tensor系の用語に近い |
| E. 4Dだけaxis番号 | 現行 | 現行 | axis0〜axis3 | 4Dだけ別体系になる |

すべて、番号0を最も内側の軸と定義すれば、既存のstorage順と連鎖subscriptの意味を維持できる。

### 4.3 `sizeN`と`dimensionN`の違い

ここには意外と重要な違いがある。

`dimension`は軸そのものを表す。

一方、`size`はその軸の長さを表す。

例えば、

```swift
init(size0: 10, size1: 20)
```

なら、二つの整数が容量・長さを示すことが自然に読める。

これに対して、

```swift
init(dimension0: 10, dimension1: 20)
```

は理解できるものの、厳密には軸とその長さを混同している。

数学的には、

- dimension：次元または軸
- extent：各軸の長さ
- size：大きさ

という区別ができる。

この意味で、`extentN`は正確性が高い。

ただし、Swiftの一般的な開発者や競技プログラミング利用者にとって、`extent`は`size`ほど直感的ではない。

Swift API Design Guidelinesも、特殊な専門用語は、それが必要な意味を正確に表す場合に使用するよう求めている。:chatgpt-content-reference{index="6"}

このpackageの用途では、`sizeN`のほうが妥当と評価する。

### 4.4 番号順の問題

現行4Dは、

```swift
init(size0: A, size1: B, size2: C, size3: D)
```

と初期化した場合、

```swift
array[i3][i2][i1][i0]
```

という順序でアクセスする。

これには一貫した意味がある。

`size0`が最も内側の連続する軸を表すからである。

したがって、

```text
size0 = 最内側
size1 = 内側から2番目
size2 = 内側から3番目
size3 = 最外側
```

という体系は、storage構造を基準にすれば自然である。

逆に、連鎖subscriptの読み順を基準にすると不自然になる。

**この二つの視点のどちらを優先するかは、命名だけでは完全に解消できない。**

### 4.5 4Dの名称だけを変更できるか

可能である。

例えば、

```swift
init(
    innerSize: A,
    middleInnerSize: B,
    middleOuterSize: C,
    outerSize: D
)
```

のように、軸の位置を言葉で明示する案がある。

しかし、これを推奨しない。

理由は、軸の増加に応じて一般化できないためである。

5D以降を追加する場合に、命名体系がさらに複雑になる。

同様に、4Dだけ`axis0`〜`axis3`へ変更しても、2D・3Dとの不統一は残る。

よって、4Dの命名のみを変更することには十分な効果が認められない。

### 4.6 3-Cを命名候補から除外

Claudeが挙げた3-Cについては、二つの解釈がある。

第一に、名前と既存の軸の対応関係だけを変更する場合。

例えば現行の、

```swift
size0 = 最内側
size3 = 最外側
```

を、

```swift
size0 = 最外側
size3 = 最内側
```

とし、それぞれが受け取る値を入れ替えても、内部storage順とsubscriptの意味を保つことは可能である。

これは**軸契約の変更ではなく、軸へのラベル割り当ての変更**として扱える。

ただし、その場合はinitializerの呼び出し側が渡す引数の意味が変わる。

第二に、storageの軸順やsubscriptが選ぶ軸そのものを反転させる場合。

これは明確に製品契約の変更であり、今回の命名レビューには含めない。

両者は別判断である。

### 判断3の推奨

**推奨：現行の次元名体系を維持する。**

具体的には、

```swift
width:height:
width:height:depth:
size0:size1:size2:size3:
```

を継続する。

理由は次のとおり。

- 2D・3Dでは空間的な名前が読みやすい。
- 4D以上では一般化できる番号体系が適している。
- `size0`を最内側の軸とする対応にはstorage配置上の一貫性がある。
- 命名だけを統一するために、2D・3Dの可読性を犠牲にする必要はない。

#### 最も強い反証

**4Dで番号の増加方向とsubscriptの記述順が逆になるため、初見で推測しにくい。**

これは現行体系の明確な弱点である。

とくに、2D・3Dの`width`・`height`・`depth`から4Dの`sizeN`へ切り替わる際、利用者には新しい軸対応の知識が必要になる。

全次元を`sizeN`または`extentN`に統一するほうが、軸とstorageの対応を一般化しやすいという反論には十分な合理性がある。

#### 未確認範囲

- 4Dの軸順を既存利用者がどう理解しているか。
- `extentN`などの代替名が外部のtensor・matrix系Swiftライブラリと意味的に競合する程度。
- initializer label以外の次元名を伴う公開APIとの整合。
- 4Dで名前だけを変更した場合の、具体的な誤用発生率。

---

## 5. 三つの判断の相互依存

今回のレビューでは、三つを独立して判断することが求められている。

ただし、判断の独立性と命名体系の一貫性は別の問題である。

### 5.1 判断1と判断2

推奨を組み合わせると次のようになる。

| 次元 | BareArray | OptionalArray |
|---|---|---|
| 1D | `BareArray` | `OptionalArray1D` |
| 2D | `BareArray2D` | `OptionalArray2D` |
| 3D | `BareArray3D` | `OptionalArray3D` |
| 4D | `BareArray4D` | `OptionalArray4D` |

見た目は完全にはそろわない。

しかし、BareArrayは低レベルな連続配列を基本とし、OptionalArrayは固定された添字空間とslotごとの設定状態を表す。

この用途の違いが維持される限り、非対称性は許容可能である。

一方、両moduleを同じ抽象化の二つの実装と位置付けるなら、この非対称性は不自然になる。

**最終判断では、両moduleが同じ抽象化の変種なのか、異なる抽象化を提供するのかを区別する必要がある。**

### 5.2 判断3の独立性

次元名体系は、BareArrayとOptionalArrayの双方に共通する。

しかし、この共通性は所有型の名前を統一する理由にはならない。

次元labelはstorage形状と添字契約を表す。

所有型の名前は、その配列が提供する抽象化を表す。

両者は異なる判断対象である。

したがって、判断3で両moduleの次元labelを統一しても、判断1と2の名称を強制的にそろえる必要はない。

---

## 6. SE-0527による将来の命名衝突リスク

SE-0527がSwift 6.4に実装されたという事実は、今回の命名レビューの重要な追加情報である。

### 6.1 命名領域の変化

従来、Swift標準ライブラリの代表的な配列名は、

```text
Array
ContiguousArray
ArraySlice
InlineArray
```

などだった。

SE-0527により、次の領域も標準ライブラリの命名体系に含まれる。

```text
UniqueArray
RigidArray
```

`Unique`は所有の一意性、`Rigid`は容量制約を中心に表している。

この方向を踏まえると、今後のSwiftでは、所有形態や容量制約を表す修飾語と`Array`を組み合わせた型がさらに増える可能性がある。

ただし、これは命名体系からの予測であり、未発表の型が追加されることを確認したものではない。

### 6.2 BareArrayへの影響

`BareArray`は、既存の`RigidArray`と低レベルな固定容量という性質が近い。

しかし、`Bare`は`Rigid`と異なり、特定の容量制約を名称で宣言していない。

このため、**公式APIと用途が近くても、同じ契約を提供すると名前が直接示唆するわけではない。**

これは`BareArray`維持を支持する要因となる。

一方で、標準ライブラリの`RigidArray`が普及した場合、利用者が「BareArrayを選ぶ理由」を名前だけでは理解しにくくなる可能性がある。

### 6.3 OptionalArrayへの影響

`OptionalArray`は各slotの設定状態を主要な特徴としている。

少なくとも今回確認した`RigidArray`と`UniqueArray`は、この性質を名前の中心には置いていない。

その意味で、`Optional`という接頭語は、標準ライブラリのownership-aware arrayとは異なる命名領域を確保している。

ただし、`Optional`がSwift標準の`Optional<T>`を連想させる点は、引き続き注意が必要である。

### 6.4 Viewへの影響

`Span`が標準ライブラリに導入された結果、非所有のmemory viewには、従来より明確な寿命保証の期待が存在する。

そのため、今回のViewを`Span`へ変更するリスクは大きい。

逆に`View`を維持する場合にも、標準の`Span`とは異なり寿命保証がないことを利用者が理解する必要がある。

**この差異は、単なる名称衝突よりも重要な契約上の問題である。**

---

## 7. 第三者AIの総合推奨

### 判断結果

| 判断 | 推奨 | 最大の懸念 |
|---|---|---|
| 1. BareArray | `BareArray`と`View`を維持 | `Bare`が固定容量を表さず、`View`が寿命の制約を明示しない |
| 2. OptionalArray 1D | `OptionalArray1D`を維持 | `1D`は未設定slotの契約を説明しない |
| 3. 多次元label | 現行維持 | 4Dで番号とsubscriptの順序が逆になる |

### 推奨の強さ

判断1と判断3は、現行維持を支持する理由が比較的明確である。

判断1では、代替名が標準の既存概念を強く連想させる問題がある。

判断3では、統一性の向上と引き換えに2D・3Dの可読性を失う。

一方、**判断2は最も判断が割れやすい。**

`OptionalArray1D`と`OptionalArray`の差は、実際の配列契約よりも、どちらの型系列を基本形と考えるかに依存する。

したがって、判断2については、第三者AIの推奨に対してCodexが独立した再評価を行う価値が特に高い。

---

## 8. Codexへの引き継ぎ事項

今回の補完調査から、Codexが独立評価で重点的に判断すべき事項は三つある。

**第一に、BareArrayの`View`について、役割の命名を優先するか、安全性の警告を優先するか。**

`View`は型の役割を簡潔に表すが、寿命保証がないことは示さない。`UnsafeView`はその逆である。

**第二に、OptionalArrayをBareArrayの変種と見なすか、独立したslot配列抽象化と見なすか。**

この判断によって、`OptionalArray`と`OptionalArray1D`の優劣が変わる。

**第三に、次元番号の基準をstorage内側からの順序とするか、subscriptの記述順とするか。**

今回の調査では、既存のstorage順を維持した名称候補のみを推奨対象とした。

軸の意味そのものを変更する判断は別途必要である。

---

## 9. 調査範囲と停止条件

調査日：2026年10月9日

確認した一次資料：

1. [apple/swift-collections — main](https://github.com/apple/swift-collections)
2. [Swift Evolution SE-0527](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0527-rigidarray-uniquearray.md)
3. [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
4. [Swift Span — Apple Developer Documentation](https://developer.apple.com/documentation/swift/span)
5. [Swift ArraySlice — Apple Developer Documentation](https://developer.apple.com/documentation/swift/arrayslice)

公式`main`およびSE-0527はWeb上で確認した。`main`の正確なcommit SHAは取得していないため、特定commitに固定した監査ではない。

Swift 6.4での`RigidArray`と`UniqueArray`の実装ステータスはSE-0527の記載を確認した。ユーザー環境のtoolchainによる再コンパイル検査は実施していない。

既存のsurface対応表、local toolchainによる完全一致検査、repository内の出現件数については、提示されたClaude調査を入力として使用し、再調査していない。

また、代替候補については意味的な適合性を比較したが、全候補について網羅的な型名衝突検査を実施したものではない。したがって、採用前の最終的な衝突確認は未完了である。

source、test、文書の変更は行っていない。rename、typealias、deprecated aliasも実装していない。

性能、View寿命の解決、storage再設計、strict memory safetyは評価対象に含めていない。

---

## 最終所見

今回の調査で最も重要な発見は、**命名の統一性よりも、どの抽象化を利用者に約束するかが重要だということ**である。

`BareArray`は低レベルな配列という性質を、`OptionalArray`は各slotの設定状態を、それぞれ別の観点から表している。

両者を無理にそろえると、かえってそれぞれの抽象化の違いが見えにくくなる可能性がある。

また、SE-0527がSwift 6.4で実装済みとなったことで、所有形態や容量制約を表す配列名は、すでに標準ライブラリの正式な命名領域に入っている。

したがって、`Rigid`、`Unique`、`Span`などの既存用語との意味的な区別は、正式公開前に確認すべき重要事項である。

**現時点では、三つとも現行維持を支持する。ただし、OptionalArrayの1D所有型については、Claudeの改名案を否定できるほどの決定的な証拠はなく、最も慎重に判断すべき項目である。**

以上を第三者AIによる補完調査結果とする。
