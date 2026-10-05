# Indexの解決と実行時検査の設計

> 状態: 現行方針(2026-10-05)。1.0リリース判定前に再審査する。
> 基礎資料:
> - `Maintanance/Archived/RUNTIME_CHECK_POLICY.md`(Swift標準ライブラリの検査モデルの調査)
> - `Implements/Index/index_stale_check.md`(構成と状態ごとのIndex解決表。ユーザー作成)

## 中心となる考え方

Swift標準ライブラリと同じ契約モデルを採る。

Indexの不正利用も事前条件違反であり、`-Ounchecked`では検出、安全停止、誤用後の
memory safetyを保証しない。現行実装の常時検査は、この契約を上回る防御として1.0前の
再審査まで維持する。

## この文書の目的

- Indexを内部nodeへ解決するとき、どの状態を受け入れ、どの状態を拒否するかを記録する。
- 各検査を、どの種類の検査として実装するかの基準を記録する。
- 特に、`-Ounchecked`で検査が外れたときに何を保証するかを定める。

個々の判断をその都度行わず、この基準から導けるようにする。

## Indexの解決

### 標準構成

標準構成は`ALLOW_CROSS_TREE_INDEX`が有効、`USE_LAZY_DETACH`が無効である。
`USE_LAZY_DETACH`はdeprecatedであり、この文書では扱わない。
`ALLOW_CROSS_TREE_INDEX`を無効にした構成も、実質deprecatedとして扱う。2026-10-05のスモークテストで、
ライブラリはビルドできるが、テスト全体はCROSS有効を前提とするテストが落ちて通らないことを確認した
(`Maintanance/Archived/CROSS_TREE_INDEX_TEST_AUDIT.md`の4節)。表の無効列は参考として残す。

`ALLOW_CROSS_TREE_INDEX`は、CoWで分岐したコレクション間でIndexを使えるようにするために用いる。
CoWで分岐した木は、Indexの解決では「別の木」として扱われる。

### 解決の手順

解決は`__purified_`で行う。

1. Indexが保持するtieと、受け取り側の木のtieが同一かを比べる。
   - これは拒否の条件ではなく、経路の選択である。
2. 同一なら、同じ木の経路に入る。Indexが保持するsealと、nodeの現在の世代を比べる。
3. 異なれば、別の木の経路に入る。
   - Indexのtagから、受け取り側の木のnodeを引き直す。
   - tagは`initializedCount`未満であることを先に確かめる。確保外のslotは引かない。
   - 引き直したnodeの世代を、Indexが保持する世代と照合する。
   - この経路はIndexが保持するtagとsealだけを読み、元の木のpointerを読まない。

### 状態ごとの結果

`o`は解決できる、`x`は拒否する、`-`は起こらないことを表す。

| Indexの状態 | 同じ木 | 別の木(標準構成) | 別の木(`ALLOW_CROSS_TREE_INDEX`無効、実質deprecated) |
| --- | :---: | :---: | :---: |
| 健全 | o | o | x |
| 世代違い | x | x | x |
| detached | - | o | x |
| detached + 世代違い | - | x | x |

- **世代違い:** 対応するnodeが削除され、そのslotが再利用されている。
  - 別の木の経路では、受け取り側の木のnodeと照合する。CoWで分岐した相手の変更は、
    このIndexの有効性に影響しない。
- **detached:** Indexの由来する木のstorageが、すでに解放されている。
  - 生存中の木のtieはdetachedにならないので、同じ木の経路では起こらない。
  - 標準構成では、detachedであること自体は拒否の理由にならない。元のpointerを読まず、
    tagで受け取り側の木から引き直すからである。
  - そのため、元の木より長生きしたIndexも、CoWで分岐した木では引き続き使える。

### CoWで分岐した木と無関係な木

- CoWで分岐した木でのIndexの利用は、標準構成で保証する。
- 無関係なコレクションから取得したIndexの利用は事前条件違反であり、検出は保証しない。
- 表で「別の木」が`o`でも、無関係なコレクションでの動作を保証するものではない。
  - tagと世代が偶然一致すれば、無関係な木の別の要素へ解決し得る。
  - ただし、その場合も確保外のslotは引かず、元の木のpointerも読まない。

## 前提: Swiftの検査プリミティブ

| プリミティブ | `-Onone` | `-O` | `-Ounchecked` |
| --- | --- | --- | --- |
| `assert` | 検査する | 検査しない | 検査せず、成立を仮定してよい |
| `precondition` / `preconditionFailure` | 検査する | 検査する | 検査せず、成立を仮定してよい |
| `fatalError` | 停止する | 停止する | 停止する |

標準ライブラリも、`Array`の範囲検査や`Collection`のIndex検査を`-Ounchecked`では保証しない。
出典と詳細は基礎資料にある。

## 保証の範囲

- **事前条件を満たす利用:** 文書化された事前条件を満たす利用について、`-Ounchecked`でも、
  ライブラリ内部のunsafe実装がout-of-bounds accessやuse-after-free等のmemory-unsafeな
  動作を引き起こさないことを、設計上の保証対象とする。
- **事前条件を破る利用:** 原則として、`-Ounchecked`での安全性は保証しない。
  標準ライブラリと同じ契約モデルである。
- **現行実装の上乗せ:** Index解決は現在`fatalError`で停止するため、実装上は
  `-Ounchecked`でも検出される。ただし、この挙動を公開契約としては保証しない。

## 分類と使い分け

表の「検査の種類」は方針であり、括弧内は現在の実装手段である。将来、専用のhelperへ
置き換えても方針は変わらない。

| 分類 | 検査の種類 | `-Ounchecked`で | 現行コードの例 |
| --- | --- | --- | --- |
| 呼び出し側の契約 | 契約検査(`precondition`) | 外れる | 空での`removeFirst` / `removeLast`、`endIndex`の参照、範囲初期化の型制約 |
| Indexの契約 | 契約検査(現行実装は`fatalError`) | 契約上は外れてよい | 「状態ごとの結果」で`x`となるIndexの拒否、IndexRangeによる削除の範囲検証 |
| 無関係な木のIndex | 事前条件違反。検出は保証しない | — | 「CoWで分岐した木と無関係な木」 |
| 内部の不変条件 | 開発時検査(`assert`、DEBUG専用の検証) | 外れる | 赤黒木の構造検査、`isUnique()`の確認 |
| 内部破損の防壁 | 常時検査(現在は`fatalError`) | 残る | 範囲削除中のpayload有無の確認 |
| 資源の上限・到達不能 | 常時検査(現在は`fatalError`) | 残る | アラインメント異常、compact metadataの上限 |

### 呼び出し側の契約

呼び出し側が公開APIで確かめられる条件は、契約検査にする。
空かどうかは`isEmpty`で、`endIndex`かどうかは比較で確かめられる。

`-Ounchecked`でこの検査が外れるのは、そのモードの目的どおりである。
常時検査へ変えてはならない(2026-10-05ユーザー決定)。

### Indexの契約と現行実装

IndexがAPI上で意味的に正しいことは、呼び出し側が満たす事前条件である。
`-Ounchecked`では、拒否すべきhandleの検出、安全停止、誤用後のmemory safetyを保証しない。

そのため、次の扱いは互いに矛盾しない。

- `endIndex`の参照: 呼び出し側の契約
- 無関係な木のIndex: 事前条件違反で、検出は保証しない
- CoWで分岐した木のIndex: 正式に解決する

「状態ごとの結果」で`x`となる場合、現行実装は常時検査で停止する。ただしこれは
公開契約を上回る防御であり、1.0前の再審査までは実装変更を行わない。

`precondition`の後の強制アンラップを、安全性の防壁として扱ってはならない。
`-Ounchecked`では、nilに対する強制アンラップが安全な停止を提供することを前提にできない。

実装上の注記は`UnsafeTreeV2+Subscript.swift`の`_unsafeMutableAddress`にある。

### 内部の不変条件

赤黒木の構造的な不変条件は、毎操作で検証すると性能特性を壊す。
開発時検査にとどめる。

### 内部破損の防壁

内部破損があれば直ちに確保外アクセスへ進む境界では、安価な検査を常時検査として
残してよい。採用はホットパスの費用と照らして個別に判断する。

防壁として採用する検査は、次をどちらも満たすものに限る。

- 検査そのものが、確保外のメモリへのアクセスを必要としない。
- 危険なpointer解決やdereferenceより前に実行できる。

unsafeなdereferenceの後に結果を確かめても、防壁にはならない。
別の木の経路で、tagを引く前に`initializedCount`と比べるのは、この規則に沿った例である。

このライブラリのnodeは、個別に解放されずrecycle poolへ戻る。木が存続している間、pool内の
nodeのheaderは確保済みの領域にある。範囲削除中のpayload有無の確認が防壁として成立するのは、
この前提で読むheaderが確保内にあるからである。この前提が変わる場合は、防壁を見直す。

## 現行実装が強い検査を維持する理由

Swift標準ライブラリの`Array`のIndexは、offsetである。

```text
Array:  Index ──> offset
RBT:    Index ──> identity / generation ──> 再利用されるslot ──> node
```

このライブラリのIndexはnodeの同一性を指し、そのslotは削除後に再利用される。検査が外れると、
古いIndexが別の要素を黙って読む。利用者が気づきにくい失敗である。

有効性の検査はseal比較とtie同一性の比較であり、O(1)で済む。検査が誤用を止めれば、
確保外slot、payloadの二重破棄、木やrecycle poolの破損を封じ込められる。

これは案E(標準ライブラリより強い保証)を採用する正当な根拠である。現時点では案Sを
公開契約とする一方、実装変更による利益が未計測なので、現行の強い検査を残す。

## `-Ounchecked`での挙動とテスト

- 空の削除のDeath Testは、`_O_UNCHECKED`では停止せずに終わる。これは仕様どおりである。
- Index解決のDeath Testは現行実装の上乗せ防御を記録する。公開契約上の必須要件とはしない。
- CIは`_O_UNCHECKED` traitを使わない。この構成の確認は、必要時に範囲を絞って行う。
  そのため、`_O_UNCHECKED`で全件を流すと、空の削除のDeath Testは失敗として報告される。

空の削除の確認結果(2026-10-05):

- 対象は16件である。
  - 4型の`removeFirst()` / `removeLast()`(各`_99_DeathTests.swift`)
  - 共有View 3種(KeyOnly / KeyValue Range View、MappedValues View)の空Viewでの同じ操作。
    空でない木の空範囲も含む(`RedBlackTreeView_99_DeathTests.swift`)
- 通常のRelease: 16件とも停止する。
  - `swift test -c release --filter 'removing(First|Last)FromEmpty'`: 8件
  - `swift test -c release --filter 'RedBlackTreeViewDeathTests'`: 8件
- Release + `_O_UNCHECKED`: 同じ16件とも`EXIT_SUCCESS`で終わる。
  - 停止の原因が、外される契約検査そのものであることも、これで確かめられる。

## 決定: 契約は標準に揃え、実装変更は1.0前に再審査する

> 2026-10-05、ユーザー承認。CodexとClaudeによる独立レビューおよび再レビューを経て決定。

### 2つの案

- **案S(標準に揃える):** Index解決の失敗も契約検査にする。`-Ounchecked`では外れる。
- **案E(強い保証にする、現行実装):** Index解決の失敗は常時検査で停止する。

### 検査が外れたときに起こること

案Sで、`-Ounchecked`のまま事前条件を破ってIndexを使った場合の推論である。
検査を実際に外して試したものではない。

- **解放済み領域へのアクセス:** 標準構成では起こらない。別の木の経路は元のpointerを読まず、
  tagで受け取り側の木から引き直す。これは検査ではなく、解決の仕組みが防いでいる。
- **確保外のslot:** 起こり得る(再レビューで訂正)。失敗側を契約検査にすると、`-Ounchecked`では
  最適化が「失敗しない」と仮定してよい。`initializedCount`との比較は失敗を作るためだけの
  比較なので、消されることがあり得る。
- **要素の二重破棄:** 起こり得る(再レビューで追加)。世代違いのIndexで、payloadを破棄済みの
  nodeを削除すると、payloadを二重に破棄する。要素が参照型なら二重解放となり、木の外のヒープを壊す。
- **別の要素への解決:** 起こり得る。同じ木の経路で世代違いのIndexを使うと、再利用された
  slotのnodeを指す。そのnodeは同じ木のpool内にあり、確保内である。
- **木の構造の破壊:** 起こり得る。世代違いのIndexで削除や書き換えをすると、別の要素や
  recycle pool内のnodeを操作する。リンクや空きリストが壊れ、以後の無関係な操作に波及し得る。

### 比較

| 観点 | 案S(標準に揃える) | 案E(例外にする) |
| --- | --- | --- |
| 規則の単純さ | 例外のない1本 | 例外を1つ説明する |
| 標準ライブラリの近い前例 | `Dictionary`のIndexと同じ扱い(`_precondition`を確認済み) | 標準より強い |
| `-Ounchecked`での誤用 | 何も保証しない(`Array`・`Dictionary`と同じ) | 停止する |
| 実行速度 | 未計測。少なくとも`-Ounchecked`では検査除去の余地がある | 未計測。常時検査を維持する |
| 既存の決定 | 「全構成で維持」の契約と、`_O_UNCHECKED`のIndexテストを改める | 変更なし |

通常構成ではどちらも検査する。`-Ounchecked`でoptimizerがどこまで検査を除去するかは
未計測であり、性能差を確定事項にしない。

### 現行判断

- 案Sを公開契約として採用する。
- 現行の`fatalError`実装は、契約を上回る防御として維持する。
- 案Eは誤りとして棄却せず、安価で実装・試験済みの有力な代替として残す。
- 契約と実装の差は意図的であり、約45箇所を機械的に変換しない。

### 1.0前の再審査

1. Index解決のfailure branchについて、interleaved A/B測定とmachine code比較を行う。
2. 各failure siteを、Index契約、内部破損の防壁、allocation境界、到達不能状態へ分類する。
3. README、DocC、利用者向けguide、Adoption Readinessの安全性表明を照合する。
4. その時点のSwift標準ライブラリ、特に`Dictionary`のIndex検査を再確認する。
5. `-Ounchecked`を正式対応する構成とするか、許容するだけの構成とするかを決める。
   - 手がかり: `Package.swift`の`_O_UNCHECKED` traitには、ユーザーが2026-05-30に
     「一応用意してあるが、あまり効果が無いどころか逆効果かもしれない」とコメントしている。
   - この所感を、1.の測定で確かめる。
6. AtCoderの実際のcompile flagsと、`_O_UNCHECKED` Death Testおよび
   `Maintanance/Archived/INDEX_POC_VALIDATION.md`の位置づけを確認する。

再審査の責任者はユーザーである。1.0を宣言するとき、または`-Ounchecked`が主要な
deployment構成だと判明した時点で再開する。標準ライブラリの前例や性能測定は判断材料であり、
製品と利用者の責任分界を自動的に決めるものではない。

## 未決事項

- `Design-MemorySafety.md`は、木が解放された後のIndexを「detachedとして拒否する」と書いている。
  - これは`ALLOW_CROSS_TREE_INDEX`無効時の挙動であり、標準構成の表と食い違う。
  - Index統合後の設計文書の更新(P10)で揃える。
  - 解決済み(2026-10-06): `Design-MemorySafety.md`を標準構成の挙動に合わせた。detachedなIndexは
    別の木の経路でtracking tagから再解決され、元のraw pointerはdereferenceしない。
- `_MemoryLayout.swift`の`precondition(count <= maximumCount)`と、`unsafe_node+pointer.swift`
  の`precondition(prefix >= 0)` / `precondition(capacity >= 0)`は、確保サイズの計算に関わる。
  - 呼び出し側の契約か、内部破損の防壁かを確認する。
  - 後者なら常時検査へ変えるかを判断する。
- `UnsafeTreeV2+InsertRange.swift`の重複キーによる停止は、現在`fatalError`である。
  - 標準ライブラリの`Dictionary(uniqueKeysWithValues:)`は、文書に「Precondition: The sequence
    must not have duplicate keys.」と明記している。
  - 呼び出し側の契約に当たるので、契約検査へ寄せる根拠は強い。
  - 寄せる前に、`-Ounchecked`で重複キーが通ったとき木がmemory-unsafeにならないかを確認する。
- `UnsafeTreeV2+Erase.swift`の`fatalError(.outOfBounds)`は、エラー種別が合っていないと
  コメントされている。分類は内部破損の防壁でよいかを確認する。
- 4型の`+RangeExpression.swift`は`fatalError("\(error)")`で停止する。
  - Index解決の安全性の分類に入る。
  - メッセージを他の箇所と揃えるかは別途判断する。
- 未結線の`Message.keyMismatch` / `outOfRange`は削除待ちとして凍結中であり、この文書の対象外とする。

## 関連文書

- `Design-MemorySafety.md`: Indexの世代、storage同一性、detached検出の仕組み
- `Quality-Checklist.md`: `-Ounchecked`を通常の品質保証と区別する方針
- `Maintanance/Archived/RUNTIME_CHECK_POLICY.md`: 標準ライブラリの検査モデルの調査
- `Implements/Index/index_stale_check.md`: 構成と状態ごとのIndex解決表
