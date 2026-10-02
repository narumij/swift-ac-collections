# PermutationModule 仕様ドラフト(フェーズ1・改訂版)

本書は `PermutationModule` の再設計に向けた**仕様の土台**で、調査結果に基づく
ドラフトである。コード・テストへの変更は伴わない。公開APIの最終形はユーザーの
判断を待つ。

**改訂の方向性**: 前回のドラフトは、安全版(CoWあり)と無CoW版を「2つの正当な戦略」として
並記する前提で書かれていたが、これはユーザーの意図ではなかった。ユーザーが求めているのは
**実装・APIバリアントの削減**である。本書は以後、次の前提で書き直す。

- モジュール独自の価値は「現在の並びに対して辞書順で後続する並びだけを1つずつ求める」
  操作(`nextPermutations()`)にある。
- 位置の全順列を列挙する `Permutations.All`(および`IteratorA`/`SubSequenceA`/
  `unsafePermutations()`)は、`swift-algorithms`の`permutations()`と重複する領域であり、
  機能拡張の対象ではなく**削除候補**である。
- 公開APIは`nextPermutations()`へ収束させるべきで、実装戦略(CoWの有無)をsafe/unsafeの
  API対として利用者に選ばせる現状の形は見直し対象である。

調査所見は `Maintanance/PermutationModule/ProductReadinessAssessment.md` に、
段階的な削減計画は `Maintanance/PermutationModule/ImplementationPlan.md` にある。

## 由来(観測可能な背景として記録)

`remotes/origin/release/AtCoder/2025` の `README.md` に由来の記述がある。
ABC328Eの解説コードを読んだ際、「全探索で間に合っている」ように見えたが、
実際は `next_permutation` が辞書順の変化だけを行うために列挙数が抑えられていた、
という誤解を追いかける過程で生まれたモジュールである。この経緯から見ても、
モジュールの本来の存在理由は「辞書順で次を1つ求める」操作であり、「全順列を列挙する」
操作は、その過程で派生的に実装されたものと捉えるのが妥当である。

## 公開APIの現状(事実)

主な入口は `Collection where Index == Int` への3つの拡張メソッドである。

| API | 戻り値の型 | 下位イテレータ | CoW | 位置付け |
| --- | --- | --- | --- | --- |
| `nextPermutations()` | `Permutations<Self>.Nexts` | `IteratorN(_unsafe: false)` | あり | モジュール独自の価値。維持する方向 |
| `unsafeNextPermutations()` | `Permutations<Self>.Nexts` | `IteratorN(_unsafe: true)` | なし | 公開APIとして維持するか、内部実装へ格下げするかは削減計画の論点 |
| `unsafePermutations()` | `Permutations<Self>.All` | `IteratorA(_unsafe: true)` | なし | `swift-algorithms`の`permutations()`と重複。削除候補 |

ただし、この3メソッドの一覧は**公開APIの全体像ではない**。`Permutations<C>`列挙体の下に
ネストした次の型・初期化子もすべてpublicであり、利用者が直接参照・初期化できる。

| 型/メンバー | 公開範囲 | 役割 | 削減計画上の扱い |
| --- | --- | --- | --- |
| `Permutations<C>`(列挙体そのもの) | public | 名前空間 | `All`系を削除すれば名前空間としての必要性も再検討 |
| `Permutations.All` | public struct | 位置の全順列を列挙するSequence | 削除候補 |
| `Permutations.All.init(unsafe:)` | public init | 無CoW版`All`の直接初期化 | 削除候補 |
| `Permutations.All.init(safe:)` | public init | CoWあり版`All`の直接初期化(対応する便利メソッドなし) | 削除候補。新規に便利メソッドを追加して救済する対象ではない |
| `Permutations.Nexts` | public struct | 辞書順後続列挙のSequence | 維持 |
| `Permutations.Nexts.init(unsafe:)` | public init | 無CoW版`Nexts`の直接初期化 | 公開を続けるか、`unsafeNextPermutations()`経由に限定するかは論点 |
| `Permutations.Nexts.init(safe:)` | public init | CoWあり版`Nexts`の直接初期化 | `nextPermutations()`と同等。維持 |
| `Permutations.IteratorA` | public struct(`IteratorProtocol`) | `All`のイテレータ | 削除候補(`All`に従属) |
| `Permutations.IteratorN` | public struct(`IteratorProtocol`) | `Nexts`のイテレータ | 維持対象だが、無CoW経路を公開型として残すかは論点 |
| `Permutations.SubSequenceA` | public struct(`RandomAccessCollection`) | `All`がyieldする要素 | 削除候補(`All`に従属) |
| `Permutations.SubSequenceN` | public struct(`RandomAccessCollection`) | `Nexts`がyieldする要素 | 維持 |

`Permutations.Buffer`(`ManagedBuffer`継承)と`Permutations.Header`は`@usableFromInline`
止まりで非公開であり、ソース互換性の計画対象には含まれない。

この一覧が示す通り、「3つの便利メソッド」だけを公開APIとして扱うと、`All`/`Nexts`双方の
`init(safe:)`/`init(unsafe:)`や、戻り値型・イテレータ型・要素型を直接名指しして使う
既存コードとのソース互換性を見落とす。削減計画ではこれら全てを対象として扱う
(`ImplementationPlan.md`の段階的削除計画を参照)。

## 観測可能な公開契約(ユーザー向けの振る舞い)

この節は「何が保証されるか」であり、実装の都合(`ManagedBuffer`か否か等)は含めない。
`All`と`Nexts`は同じ契約を共有しない。削減計画の検討のためにも、この違いを以後も
正確に区別して記述する。

1. **`nextPermutations()` / `unsafeNextPermutations()`(`Nexts`系)**: 現在の要素並びを
   最初に返し、要素値の比較に基づいて辞書順で後続する並びだけを列挙する。既に降順の場合や
   全要素が比較上等しい場合は、現在の並びを1回返して終了する。比較上等しい要素は
   `next_permutation`と同様に扱われるため、同じ値並びを位置の違いだけで重複列挙しない。
2. **`unsafePermutations()`(`All`)**: 要素値ではなく元コレクションの位置
   (`0..<count`)を辞書順に並べ替え、常に位置の全順列を列挙する。入力値が降順でも
   全順列を列挙し、比較上等しい要素が複数の位置にあれば、見た目が同一の値並びも
   複数回現れる。例えば `[0, 0, 1]` からは6個の位置順列が生成される。`Nexts`系とは
   列挙数・停止条件・重複有無のいずれも異なり、同一の契約を共有しているとは言えない。
3. **CoWの有無による違い(実装選択であり優劣ではない)**:
   - CoWありのイテレータは、イテレータを先へ進めた後も、それ以前に取り出した各
     `SubSequence` の値を保持する。
   - `unsafeNextPermutations()` / `unsafePermutations()` は、内部バッファへの参照を
     共有したまま返す。列挙結果を**即座に消費せず保持・再利用**すると、全ての結果が
     同じイテレータの直近の内部状態へ収束して見える、という非直感的な挙動が生じる。
     最後まで走査した場合、終了判定の `nextPermutation()` がバッファを最小順へ戻すため、
     保持した結果も最後にyieldされた降順ではなく、その最小順を指す。
     この挙動は不具合ではなく、使い捨てコンテキスト(1回走査してすぐ使う、AtCoder提出コードのような
     用途)でのオーバーヘッド最小化という設計判断に基づく。利用者が結果を保持・再利用したい場合は
     `map { Array($0) }` 等で即座に値へ変換する必要がある。
   - **削減後の方向性**: この無CoW経路自体はABC328Eのような性能要求に応える実装として有用だが、
     「safe/unsafeの2つの公開APIを使い分けてもらう」という形で利用者に露出する必要はないはずで
     ある。内部実装としてこの低オーバーヘッド経路を保持しつつ、利用者には単一の
     `nextPermutations()`だけを見せ、エイリアシングを2つめの公開契約として提示しない方法を
     検討する(具体案は`ImplementationPlan.md`の段階3を参照)。
4. **計算量**: `next_permutation` 相当の1ステップは最悪O(n)で、全位置順列の列挙は
   `n!` 回のyieldを行う。各結果の全要素を消費する場合、出力量自体がO(n × n!)になる。

## この文書がまだ扱っていないもの

- `All`系(`Permutations.All`/`IteratorA`/`SubSequenceA`/`unsafePermutations()`)の
  削除を実施するか、`Deprecated`化を経由するかの最終決定(ユーザー判断待ち)。
- `unsafeNextPermutations()`と`Nexts`の`init(safe:)`/`init(unsafe:)`を公開したまま
  残すか、内部実装専用にするかの最終決定(ユーザー判断待ち)。
- `Sendable` 適合の要否。
- 計算量・CoW契約・事前条件を説明する `///` コメントドックの文面。
- `Tests/PermutationTests/NextPermutation.swift` にある別世代の実装の扱い。

これらは `Maintanance/PermutationModule/ImplementationPlan.md` の段階的削除計画、および
`ProductReadinessAssessment.md` の「製品化にあたって要ると思われる検討項目」として
ユーザー判断待ちのまま残っている。

## ABC328E 性能検証についての注意(訂正)

`release/AtCoder/2025`の存在理由となったABC328Eの制約は `N <= 8`, `M <= 28` である
(全探索的に見えたコードが実際は辺の組み合わせ選択を含む問題であり、単純な`N`の階乗
オーダーだけでは計算量を説明できない)。また、AtCoderの実行環境は本パッケージの
`import AcCollections`に依存できないため、性能検証はpackage内のテストに加えて、
**外部依存のない単一のSwiftファイルへ解法をまとめてコピー&ペースト提出する**ことで
検証する必要がある。この実務計画は`ImplementationPlan.md`の「ABC328E 実提出による
性能検証の実務計画」に記載している。
