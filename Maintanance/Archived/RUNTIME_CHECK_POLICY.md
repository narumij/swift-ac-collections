# `-Ounchecked` における Red-Black Tree のメモリ安全性と失敗処理

> Discussion draft for `swift-ac-collections`
>
> 目的: `precondition` / `fatalError` / `assert` の使い分けを、Swift 標準ライブラリの実際の設計に合わせて整理し、Red-Black Tree 実装における `-Ounchecked` 時のメモリ安全性ポリシーを決めるための議論材料とする。
>
> 確認日: 2026-10-05

## 1. 問題意識

`swift-ac-collections` の Red-Black Tree は内部で `UnsafePointer` / `UnsafeMutablePointer` 系の操作を多用する。

そのため、通常の Swift コードよりも次の区別が重要になる。

1. **API の契約違反**
   - 無効な `Index`
   - 別の tree に属する `Index`
   - `endIndex` に対する要素アクセス
   - 要求されたキーと index の位置が一致しない
2. **ライブラリ内部 invariant の破壊**
   - parent / child 関係の不整合
   - node pool / free list の不整合
   - size / capacity / node count の不整合
   - Red-Black Tree の構造的不変条件の破壊
3. **そのまま進むと unsafe memory access に直結する状態**
   - 範囲外 node slot
   - 解放済み node の参照
   - 不正な raw pointer / offset
   - buffer capacity を越えたアクセス

問題は、これらを一律に `precondition` にするべきか、それとも一部を `fatalError` にして `-Ounchecked` でも停止させるべきか、という点である。

---

## 2. Swift 自身はどうしているか

### 2.1 `assert`

Swift の `assert` は次のモデル。

| Build | 動作 |
|---|---|
| `-Onone` | condition を評価し、false なら停止 |
| `-O` | condition を評価しない |
| `-Ounchecked` | condition を評価せず、optimizer は **true と仮定してよい** |

つまり `assert` は debugging / internal consistency 用。

`-Ounchecked` では単に「チェックが消える」だけではなく、条件が成立すると仮定した最適化が許される。

Source:

- `swift/stdlib/public/core/Assert.swift`
- `assert` implementation and documentation

https://github.com/swiftlang/swift/blob/main/stdlib/public/core/Assert.swift

---

### 2.2 `precondition`

Swift の public `precondition` は次のモデル。

| Build | 動作 |
|---|---|
| `-Onone` | condition を評価し、false なら停止 |
| `-O` | condition を評価し、false なら trap |
| `-Ounchecked` | condition を評価せず、optimizer は **true と仮定してよい** |

Swift の公式ドキュメントにも、

> In `-Ounchecked` builds, `condition` is not evaluated, but the optimizer may assume that it always evaluates to `true`.

という設計が明記されている。

したがって、

```swift
precondition(isValid(index))
return unsafe nodes[index.slot]
```

のようなコードでは、`-Ounchecked` 時に `isValid(index)` はメモリアクセスを防御しない。

これは `precondition` の誤用ではなく、Swift が意図している `-Ounchecked` の意味そのもの。

Source:

https://docs.swift.org/swift-book/documentation/the-swift-programming-language/thebasics/#Preconditions

https://github.com/swiftlang/swift/blob/main/stdlib/public/core/Assert.swift

---

### 2.3 `preconditionFailure`

`preconditionFailure` も同じカテゴリ。

`-Onone` / `-O` では停止するが、`-Ounchecked` では optimizer が「ここには到達しない」と仮定できる。

したがって、

```swift
guard condition else {
    preconditionFailure()
}
```

は `-Ounchecked` で必ず停止する安全柵にはならない。

---

### 2.4 `fatalError`

`fatalError` は意味が異なる。

```swift
fatalError("...")
```

は optimization level にかかわらず停止する。

Swift 標準ライブラリの実装でも `fatalError` は無条件の program termination point として実装されている。

つまり、**`-Ounchecked` でも絶対に先へ進ませたくない条件**を表すなら、public Swift API では `fatalError` が対応する。

Source:

https://github.com/swiftlang/swift/blob/main/stdlib/public/core/Assert.swift

---

## 3. Swift Standard Library の `_precondition`

重要なのは、Swift stdlib 自身が public `precondition` とは別に `_precondition` を使っていること。

現行 `Assert.swift` の `_precondition` は概ね次の構造になっている。

```swift
if _isDebugAssertConfiguration() {
    // check and report
} else if _isReleaseAssertConfiguration() {
    // check and trap
}
```

Fast configuration (`-Ounchecked`) の branch はない。

つまり `_precondition` も実質、

- `-Onone`: check
- `-O`: check
- `-Ounchecked`: no check

というモデル。

### Array

`Array` / `ContiguousArrayBuffer` の subscript validation は `_precondition` を使っている。

例:

```swift
internal func _checkValidSubscript(_ index: Int) {
    _precondition(
        (index >= 0) && (index < immutableCount),
        "Index out of range"
    )
}
```

したがって Swift の `Array` 自身も、`-Ounchecked` では通常の bounds check を保証していない。

Source:

https://github.com/swiftlang/swift/blob/main/stdlib/public/core/Array.swift

https://github.com/swiftlang/swift/blob/main/stdlib/public/core/ContiguousArrayBuffer.swift

### Collection / String

Collection の range check や String の index check にも `_precondition` が広く使われている。

これは、

> 「正しいプログラムでは API precondition は成立している。`-Ounchecked` を選択した利用者はそれを保証したものとして扱う」

という Swift の基本設計と整合する。

---

## 4. UnsafeBufferPointer はさらに弱い

`UnsafeBufferPointer` の subscript は `_debugPrecondition` を使っている。

現在の stdlib source にも明示的に、

> Bounds checks for `i` are performed only in debug mode.

と記載されている。

つまり unsafe API について Swift は、

- Release ですら bounds check を省略し得る
- caller が validity を保証する

という方針を取る。

Source:

https://github.com/swiftlang/swift/blob/main/stdlib/public/core/UnsafeBufferPointer.swift.gyb

これは Red-Black Tree の内部実装を考える上で重要。

内部で Unsafe API を使っていること自体は、

> public API のすべての条件を `fatalError` で防御しなければならない

ことを意味しない。

標準ライブラリ自身も safe abstraction の内部に unsafe operation を持ちながら、API contract は `_precondition` で表現している。

---

## 5. ここから導ける基本方針

### Proposal A: Swift と同じ契約モデルを採る

Red-Black Tree の **public API misuse** は原則 `precondition` とする。

例:

```swift
precondition(isValid(index))
precondition(index != endIndex)
precondition(index belongsTo: self)
precondition(keyMatchesPosition)
```

`-Ounchecked` を指定した利用者は、これらの条件が成立していることを caller 側で保証する責任を持つ。

この場合、

> `swift-ac-collections` は `-Ounchecked` 時にも不正な API 利用からメモリ安全性を保証する

とは主張しない。

これは Swift Standard Library と同じ方向の設計である。

---

## 6. `fatalError` を使うべき候補

一方、すべてを `precondition` にする必要もない。

次のような条件は `fatalError` を検討する価値がある。

### 6.1 Caller が満たすべき precondition ではない状態

例えば、

```swift
switch internalState {
case .valid:
    ...
case .impossible:
    fatalError("corrupted tree state")
}
```

ここで `.impossible` が public API misuse ではなく、ライブラリ自身のバグ・内部破損を意味するなら、意味論上 `preconditionFailure` より `fatalError` の方が自然な可能性がある。

### 6.2 正しい public input でも到達可能性を完全には排除できない corruption barrier

例えば、

```swift
guard slot < capacity else {
    fatalError("node pool corruption")
}
```

このチェックを残すことで、

```text
internal corruption
        ↓
invalid pointer arithmetic
        ↓
arbitrary memory access
```

を、

```text
internal corruption
        ↓
fatal termination
```

に変えられるなら、memory-safety barrier として意味がある。

ただし hot path に置けば runtime cost があるため、無制限に採用すべきではない。

---

## 7. `fatalError` にしない方がよい候補

### Public Index validity

```swift
tree[index]
```

に別 tree の index や invalidated index を渡したケース。

これは Collection API の precondition と考えるのが自然。

Swift の `Array` や `String` の index validity と同じカテゴリなら、基本的には `precondition` でよい。

### `endIndex` dereference

これも Collection contract。

```swift
collection[collection.endIndex]
```

と同じなので `precondition` が自然。

### key mismatch

例えば、

```swift
update(newMember, at: index)
```

で index の既存 key と `newMember` の key が異なるケース。

これが API contract として明示されるなら `precondition` が自然。

以前の `fatalError(.keyMismatch)` が本当に必要かは再検討余地がある。

---

## 8. 内部 invariant

Red-Black Tree 固有の invariant:

- root is black
- red node has no red child
- black height equality
- parent / child consistency
- ordering
- subtree metadata consistency

これらを常時 `fatalError` で検証するのは現実的ではない。

通常は、

```swift
assert(...)
```

あるいは DEBUG-only validation が自然。

つまり、

> 「`-Ounchecked` でも tree invariant を毎操作検証する」

ことを memory safety の定義に含めるべきではない。

内部 invariant の完全検査まで要求すると、Red-Black Tree の性能特性そのものを壊す。

---

## 9. 「`-Ounchecked` でも memory safe」の意味を分解する必要がある

この表現はそのままだと強すぎる。

少なくとも次の二つは別。

### A. Correctly used API

> API contract をすべて満たしたプログラムは、`-Ounchecked` でもライブラリ内部の unsafe implementation に起因してメモリ破壊を起こさない。

これはライブラリとして目標にすべき。

### B. Incorrectly used API

> invalid index や key mismatch 等、documented precondition を caller が破っても、`-Ounchecked` で memory safe である。

Swift Standard Library はこの保証をしていない。

`Array` の bounds checking すらこの保証から外れる。

したがって `swift-ac-collections` が B まで保証すると、Swift Standard Library より強い契約を独自に背負うことになる。

現時点では **A を保証対象、B を非保証** とするのが自然に見える。

---

## 10. 暫定ルール案

| 状況 | 推奨 |
|---|---|
| public API の documented precondition | `precondition` |
| Collection / Index の misuse | `precondition` |
| `endIndex` dereference | `precondition` |
| cross-tree Index | `precondition` |
| caller が守る key constraint | `precondition` |
| debug 用 internal invariant | `assert` |
| expensive structural validation | DEBUG-only |
| library 自身の corrupted / impossible state | `fatalError` を検討 |
| そのまま進むと直ちに unsafe memory access し、caller contract では説明できない内部破損 | `fatalError` を検討 |
| 未実装 / 到達自体がプログラム上の致命的欠陥 | `fatalError` |

---

## 11. 重要な判断基準

各チェックについて、単に

> 「false なら危険か？」

ではなく、以下を見る。

### Q1. 誰の責任か

- caller が守る条件か
- library implementation が守る invariant か

### Q2. Swift Standard Library で対応するケースは何か

- Array bounds → precondition
- invalid Collection index → precondition
- UnsafeBuffer bounds → debug-only
- unconditional impossible state → fatal

### Q3. `-Ounchecked` でチェックを消すことが契約上許されるか

caller contract なら基本的に Yes。

library implementation bug に対する corruption barrier なら No を検討。

### Q4. hot path cost はどの程度か

memory-safety barrier を増やしても、Red-Black Tree の性能優位を潰しては本末転倒。

---

## 12. Claude Code にレビューしてほしいこと

以下をコードベース全体で調査してほしい。

### 12.1 failure primitive の inventory

Red-Black Tree 関連について、

- `precondition`
- `preconditionFailure`
- `assert`
- `assertionFailure`
- `fatalError`
- 独自 failure helper

を列挙する。

### 12.2 各チェックを分類

各 site を次に分類する。

1. caller contract
2. Collection / Index contract
3. internal invariant
4. memory-safety barrier
5. unreachable / impossible state
6. 単なる defensive check

### 12.3 `-Ounchecked` で消えた場合の unsafe path を追跡

特に、

```text
failed condition
  ↓
unchecked pointer arithmetic
  ↓
load / store / initialize / deinitialize / move
```

に直結する site を洗い出す。

ただし、「unsafe operation が後ろにある」という理由だけで `fatalError` にしないこと。

まず caller precondition なのか internal corruption なのかを区別する。

### 12.4 Swift stdlib analogy を付ける

可能なら各カテゴリについて Swift stdlib の類似例を探す。

特に、

- `Array`
- `ContiguousArrayBuffer`
- `Collection`
- `String`
- `UnsafeBufferPointer`

を参考にする。

### 12.5 最小限の `fatalError` 集合を提案

目標は、

> 何でも `fatalError` にすること

ではない。

目標は、

> Swift の契約モデルを維持したまま、ライブラリ内部破損から直接 dangerous memory operation に落ちる箇所に、費用対効果の高い barrier があるか

を確認すること。

---

## 13. Claude Code への問い

特に次の点について意見が欲しい。

1. 現在 `fatalError` になっている API misuse のうち、Swift stdlib の慣例に合わせて `precondition` に落とせるものはどれか。
2. 逆に現在 `precondition` / `assert` になっているもののうち、library-internal corruption barrier として `fatalError` を残す価値がある箇所はあるか。
3. `UnsafeTreeV2` / node pool / raw buffer 周辺で、valid public input からでも implementation bug により out-of-bounds / use-after-free に落ちうる境界はどこか。
4. `Index` validity は Swift Collection と同様、`-Ounchecked` では caller responsibility としてよいか。
5. key mismatch (`update(_:at:)` 等) は `fatalError` ではなく `precondition` が自然ではないか。
6. `-Ounchecked` 時の保証を、次のように文書化するのは適切か。

> When compiled with `-Ounchecked`, documented preconditions are assumed to hold and may not be checked, following the Swift standard library's execution model. Memory safety is guaranteed only for programs that satisfy those preconditions.

7. 上記保証より強い保証を提供する実益があるか。そのために必要な runtime check のコストはどの程度か。

---

## 14. 現時点の仮説

現時点では以下が最も Swift らしい設計に見える。

### 原則

**public contract violation → `precondition`**

**internal impossible/corrupted state → 必要に応じて `fatalError`**

**debug invariant → `assert`**

### `-Ounchecked`

`-Ounchecked` を使う caller は documented precondition を満たす責任を負う。

したがって、

```swift
precondition(indexIsValid)
unsafeAccess(index)
```

という構造そのものは問題ではない。

これは Swift `Array` と同じ契約モデル。

一方で、

```swift
// caller cannot influence this invariant directly
guard internalSlot < allocatedCapacity else {
    fatalError("internal storage corruption")
}
unsafeAccess(internalSlot)
```

のような内部 corruption barrier は、限定的に `fatalError` を使う余地がある。

---

## 15. 参考資料

### Swift Language Guide

Preconditions / `-Ounchecked` / `fatalError`

https://docs.swift.org/swift-book/documentation/the-swift-programming-language/thebasics/#Preconditions

### Swift stdlib `Assert.swift`

`assert`, `precondition`, `preconditionFailure`, `fatalError`, `_precondition`, `_debugPrecondition`

https://github.com/swiftlang/swift/blob/main/stdlib/public/core/Assert.swift

### Array

https://github.com/swiftlang/swift/blob/main/stdlib/public/core/Array.swift

### ContiguousArrayBuffer

https://github.com/swiftlang/swift/blob/main/stdlib/public/core/ContiguousArrayBuffer.swift

### Collection

https://github.com/swiftlang/swift/blob/main/stdlib/public/core/Collection.swift

### UnsafeBufferPointer

https://github.com/swiftlang/swift/blob/main/stdlib/public/core/UnsafeBufferPointer.swift.gyb

### Swift Evolution: Memory Safety

https://github.com/swiftlang/swift-evolution/blob/main/visions/memory-safety.md

---

## 16. Discussion status

**未決定。**

この文書は方針決定ではなく、Swift 標準ライブラリとの整合性を軸に Claude Code とコード実態を監査するための discussion draft。

最終判断は、実コード上の failure site と unsafe access path を確認した上で行う。

