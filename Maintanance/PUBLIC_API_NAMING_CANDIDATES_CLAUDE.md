# Public API naming candidates — Claude assignment and submission

Status: assigned by explicit user direction on 2026-10-12. Claude candidate submission completed 2026-10-13 (other submissions not read).

## Goal

0.6および1.0で公開品質としてValidation可能なAPIを三者で議論するために、Claudeが
Array系とPermutation系の公開名候補を独立に提出する。

このtaskは候補出しだけを行う。順位付け、採点、統合、採用判断、実装、test、文書反映は行わない。

## Product and quality context

この節は、製品コンセプトの正本
[`User/CONCEPT_DEFINITION.md`](User/CONCEPT_DEFINITION.md)と、製品品質要求の正本
[`QUALITY_REQUIREMENTS.md`](QUALITY_REQUIREMENTS.md)から、今回の候補出しに必要な文脈を
作業用に展開したものである。新しい品質要求を追加せず、両正本を置き換えない。

製品コンセプトは、CやC++標準に匹敵する性能を持ち、競技プログラミングで利用可能なデータ構造を、
一般のSwift開発にも提供することである。正確性、性能、競技利用、一般Swift利用は別々の目標ではなく、
同時に成立させる。特に、低レベル実装による性能と、Swift利用者が期待する言語特性・安全性の両立を
必要とする。

1.0に向けた現時点の位置づけは次のとおりである。

| Module | Position toward 1.0 |
| --- | --- |
| `PermutationModule` | Swift 6.4以降の提供対象として品質成立を目指す。 |
| `OptionalArrayModule` | 明示的なpackage traitで有効化する実験的データ構造として、留保付きで対象に残す。 |
| `BareArrayModule` | 提供対象から除外するが、source、仕様、test、benchmark、安全性、既存利用への影響を保守する。 |

留保付きまたは提供対象外でも、正確性、メモリ安全性、要素寿命、初期化・破棄、build・test可能性は
自動的に軽減されない。現在の位置づけも品質達成済みを意味しない。

公開名の候補では、特に次の品質要求との接続を見る。

- **理解可能性:** C++経験者とSwift開発者の双方が、公開APIの意味、操作、制約、失敗条件を理解でき、
  誤った期待を抱かず適切な操作を選べること。
- **利用可能性:** 競技用途と一般Swift用途の双方で導入・共存・利用でき、片方への対応がもう片方を
  不必要に損なわないこと。
- **持続可能性:** 公開APIやtoolchainが変化しても、機能、性能、安全性を意図せず失わず、変更の影響を
  分析できること。

Verificationは、具体化した要求を実装やTest as Specification等が満たすかを確認する。Validationは、
要求の組合せによって製品コンセプトが実際に成立するかを確認する。Verificationの成功だけを理由に、
競技利用、C/C++級性能、一般Swift利用、および性能・安全性・利用可能性の両立をValidation済みとしない。

名前は、実装が成立させていないCollection semantics、所有・借用、安全性、寿命、性能、計算、cache policy、
または完全列挙等を利用者へ約束しないこと。同時に、実際に提供する価値と利用方法を不必要に隠さないこと。

ユーザー、Codex、Claudeは候補と反証を持ち寄る。公開APIを通じて利用者へ何を約束するかの最終判断と
責任はユーザーが持つ。Claudeは候補提出によって公開契約を決定せず、他者との合意を証拠または採用と
みなさない。

## Previously submitted Array object names

次の候補は2026-10-12、Claude（Opus 5.5）が他者候補と過去の命名レビューを読まずに独立提出した。
後続の公開名候補を同じ正本へ集約するため、内容を失わず本書へ統合した。並び順に順位の意味はない。

### C-1 現行名を維持: `BareArray` / `OptionalArray`

- 1D〜4D: 現行のまま。ただし、両方suffixなし、または両方`1D`付きへ揃える案を含む。
- View: 現行の`BareArray1DView`〜`3DView` / `OptionalArray1DView`〜`3DView`。
- Intent: 移行費用を抑え、現在の語彙を維持する。
- Concern: `Bare`が何を省いたのか読めず、`OptionalArray`は`Array<Optional<Element>>`と誤読されうる。

### C-2 固定長を前面に: `FixedArray` / `FixedOptionalArray`

- 1Dはsuffixなし、2D〜4Dは次元suffixを付ける。Viewは`1DView`〜`3DView`。
- Intent: 作成時に要素数が決まり、伸縮しない所有配列であることを示す。
- Concern: 型レベル固定長やinline storageと混同され、`FixedOptionalArray`も長い。

### C-3 storage位置を前面に: `HeapArray` / `HeapOptionalArray`

- 1Dはsuffixなし、2D〜4Dは次元suffixを付ける。Viewは`1DView`〜`3DView`。
- Intent: heap上の連続storageを所有することを示し、`InlineArray`と区別する。
- Concern: allocation場所は役割を十分に説明せず、Swift `Array`との差も伝わりにくい。

### C-4 Optional側をslotとして区別: `BareArray` / `SlotArray`

- 1Dはsuffixなし、2D〜4Dは次元suffixを付ける。Viewは`1DView`〜`3DView`。
- Intent: Optional側の各位置が空または1要素を持つslotであることを表す。
- Concern: `slot`はhash tableやobject pool、疎なstorageを連想させうる。

### C-5 用途を前面に: `BareArray` / `MemoTable`

- `MemoTable`は1Dをsuffixなし、2D〜4Dは次元suffix、Viewは`1DView`〜`3DView`とする。
- Intent: Optional側の主要用途である配列ベースのメモ化を表す。
- Concern: 自動計算やevictionなどのcache policyを連想させ、メモ化以外の用途を狭く見せうる。

### Array object familyに共通する観察

- 1D所有型のsuffixは現行で非対称であり、どの候補でも別途判断が必要。
- Viewは非所有性を示すが、ownerより先に使い終える寿命条件までは名前から伝わらない。
- `Span`系の名前はcompilerによる寿命検査を連想させるため、寿命検査のないViewには用いない。
- `Rigid` / `Unique`は`swift-collections`の型との混同可能性が未確認だったため候補から外した。
- 座標引数は最内軸から、連鎖subscriptは最外軸から並び、object名とは別の誤読点が残る。

## Independence boundary

候補を提出し終えるまで、次の他者候補を読まない。

- `PUBLIC_API_NAMING_CANDIDATES_USER.md`
- `PUBLIC_API_NAMING_CANDIDATES_CODEX.md`

上記のArray object候補は、この独立性境界を保った既提出内容として本書内に固定する。

事実確認には、次のproduction sourceを使う。

- `Sources/BareArrayModule/BareArray.swift`
- `Sources/OptionalArrayModule/OptinalArray.swift`
- `Sources/PermutationModule/NextPermutations.swift`
- `Sources/PermutationModule/BorrowedNextPermutations.swift`

必要なら、公開契約を理解するために各moduleのQuality ProfileとCurrent Quality Assessmentを読める。
他者の候補を推測して避けたり、現行名を採用済みとみなしたりしない。

## Scope

- 対象は`public`な型、関数、メソッド、property、subscript、typealias、initializerとargument labelだけ。
- internal、package、`@usableFromInline`、privateな実装名は対象外。
- 現行名の維持も一つの候補として提出できる。
- 複数の名前が一つのcall-site体系を作る場合は、ばらばらの単語でなくfamilyとして提出する。
- 候補ごとに、意図する意味と明らかな誤読・品質上の懸念を短く書く。
- 公開提供の採否、deprecation、互換性方針、品質受入、最終名称は決定しない。

## Stop conditions

次を見つけた場合は推測で埋めず、`Unresolved findings`へ記録して停止する。

- sourceだけでは公開契約を識別できない。
- 候補出しより前に製品判断が必要である。
- 対象となる公開surfaceが資料の想定と異なる。
- 同じ名前が異なる意味を持ち、候補表へ安全に統合できない。

## Submission form

以下をClaude本人が記入する。候補数は固定しない。候補が不要だと考える公開名も、省略せず
「現行名を候補として維持」と記録する。

### A. Array access API families

| Candidate family | Read | Write | Mutable reference | Reference type | Intent | Concern |
| --- | --- | --- | --- | --- | --- | --- |
| A-1 現行維持 | `element(at:)` | `setElement(_:at:)` | `reference(at:)` | `Reference = MutableRef<Element>` | 読む・書く・参照を取る、の三動詞を明示する。OptionalArrayは読み`Element?`、書き`Element?`（`nil`で未設定へ戻す） | `setElement`は`Element?`を受けるOptionalArrayで「nilを入れる＝削除」が名前から読めない。`reference`は寿命を持つ借用（`~Escapable`）であることが伝わらない |
| A-2 値と位置 | `value(at:)` | `setValue(_:at:)` | `withMutableValue(at:_:)`（closureで渡す） | （型を公開しない） | Swiftの`withUnsafe…`系に倣い、可変参照の寿命をclosureの範囲に閉じる | closure形はnoncopyable・`~Escapable`の扱いと相性を確かめていない。`value`はKVCの`value(forKey:)`を連想させうる |
| A-3 OptionalArray専用の状態動詞 | `element(at:)` | `setElement(_:at:)`＋`removeElement(at:)` | 提供しない | 提供しない | OptionalArrayだけ「未設定へ戻す」を独立の動詞にし、`nil`代入の意味を名前で示す | 二つの経路（`setElement(nil, at:)`と`removeElement(at:)`）が同じ意味になる。BareArrayとfamilyがずれる |
| A-4 subscript中心 | `array[x, y]`（多引数subscript） | `array[x, y] = v` | （BareArrayだけ`_modify`で提供） | 提供しない | 連鎖`[y][x]`をやめ、座標順を一つにする。C++の`a[y][x]`経験者にも読める | 多引数subscriptは連鎖subscriptと座標順が逆（`[x, y]`対`[y][x]`）になり、どちらを正にするかの判断が要る。現行の座標labelの順（最内軸から）を引き継ぐ |

### B. Other Array public names

initializer、`removeAll()`、`indices`、subscript、coordinate／dimension label、Viewの操作など、
Claudeが候補を提出する公開名を記録する。

| Current public name or role | Candidate | Intent | Concern |
| --- | --- | --- | --- |
| `BareArray.init(repeating:count:)` / `init(count:_:)` | 現行名を候補として維持 | `Array(repeating:count:)`と同じ形で、競技利用者もSwift利用者も推測できる | `init(count:_:)`のclosureは呼ばれる順（添字順）が名前から読めない |
| `OptionalArray1D.init(capacity:)` | `init(count:)` | 作った時点で全slotが存在し、数が変わらないことを示す | 現行の`capacity`は「予約容量（あとで伸ばせる）」と読まれうる。BareArrayの`count`とも揃っていない |
| 2D〜3Dのshape label `width:height:depth:` | 現行名を候補として維持 | 画像・grid的な読みで直感的 | 連鎖subscript`[y][x]`の順と、引数の並び（最内軸から）が逆。4Dだけ`size0`〜`size3`になり体系が切れる |
| 4Dのshape label `size0:...size3:` | `extent0:`〜`extent3:`、または2D〜3Dも含めて`size0:`系に統一 | 4D以上で日常語が尽きることを受け入れ、番号付きlabelに揃える | 番号の向き（0が最内軸）を誤読しやすい。2D〜3Dを変えると移行費用が出る |
| 座標label（`element(at: x, _ y:)`等） | 現行名を候補として維持（最内軸から並べる） | storage順と一致する | `[y][x]`の連鎖subscriptと逆順。どちらか一方を正とする判断が要る（E-2） |
| `removeAll()`（OptionalArray） | 現行名を候補として維持 | `Array.removeAll()`と同じ動詞で、全slotを未設定へ戻す | `Array.removeAll()`はcountが0になるが、こちらはslot数を保つ。`resetAll()`／`clear()`も候補 |
| `indices` | 現行名を候補として維持 | 外側の軸の有効範囲 | 多次元では「どの軸のindicesか」が読めない（外側の軸だけ）。`Collection`ではないのにCollection風の名前 |
| View型`…1DView`〜`…3DView` | 現行名を候補として維持 | 非所有であることを示す | 寿命を延ばさない借用であることは伝わらない。`Span`は寿命検査のある型を連想させるので避ける |
| `MutableRef<Element>` / `pointee` | `MutableRef`を維持、`pointee`を`value`へ | `pointee`はpointerの語で、安全な参照型の名前としてはunsafe寄りに読まれる | 標準の`Mutable…`系と名前が近いものが将来入ると衝突しうる（未確認） |

### C. Permutation public API families

通常のruntime-check View経路と、Swift 6.4のborrowed `Span`経路の関係が分かるfamilyとして記録する。

| Candidate family | Normal factory | Normal owner/iterator | Normal yielded view | Borrowed factory | Borrowed owner/iterator | Intent | Concern |
| --- | --- | --- | --- | --- | --- | --- | --- |
| C-1 現行維持 | `nextPermutations()` | `NextPermutations<Value>` | `NextPermutations.Permutation` | `borrowedNextPermutations()` | `BorrowedNextPermutations<Element>` | 「現在の並びとその後続」という`next_permutation`の意味を両経路で共有し、借用版だけprefixで区別する | 通常版の`Permutation`も「次の`next()`まで」しか有効でないのに、名前には一時的な参照であることが出ない（実行時trapで守る）。generic引数名が`Value`と`Element`で揃っていない |
| C-2 寿命の差を名前に出す | `nextPermutations()` | `NextPermutations<Element>` | `NextPermutations.CurrentView` | `borrowedNextPermutations()` | `BorrowedNextPermutations<Element>` | yieldされるものが値ではなく現在状態へのviewであることを型名で示す | `CurrentView`は長い。Collection適合を持つので「View」が弱すぎるとも読める |
| C-3 「successors」を明示 | `permutationSuccessors()` | `PermutationSuccessors<Element>` | `.Permutation` | `borrowedPermutationSuccessors()` | `BorrowedPermutationSuccessors<Element>` | 全順列ではなく後続だけであることを入口の名前で示し、swift-algorithmsの`permutations()`との誤用を防ぐ | C++の`next_permutation`経験者には検索で見つけにくくなる |
| C-4 借用版を既定にする | `nextPermutations()`（6.4以降はborrowed） | `NextPermutations<Element>` | `Span<Element>` | （通常版を`checkedNextPermutations()`へ） | — | 6.4以降を提供対象とするなら、compilerが寿命を検査する経路を既定名にする | toolchainで既定の意味が変わり、持続可能性と互換性の判断が先に要る（E-1） |

### D. Other Permutation public names

`next()`その他について、候補を提出する公開名があれば記録する。

| Current public name or role | Candidate | Intent | Concern |
| --- | --- | --- | --- |
| `NextPermutations.next()` / `BorrowedNextPermutations.next()` | 現行名を候補として維持 | `IteratorProtocol`風の手動反復で、利用者が推測できる | `Sequence`ではないのに`next()`があり、`for-in`できると期待されうる（borrowed版はcompilerが拒否、通常版も`Sequence`ではない） |
| `Permutation`の`startIndex`／`endIndex`／`subscript` | 現行名を候補として維持（Collection要件） | `RandomAccessCollection`の要件名 | 無効化後のアクセスがtrapすることは名前から読めない |

### E. Unresolved findings

| Finding | Why candidate submission cannot resolve it | Needed next input |
| --- | --- | --- |
| E-1 通常版とborrowed版のどちらを1.0の既定経路にするか | 既定名（prefixなし）をどちらに与えるかで、C-1とC-4のどちらが成り立つかが変わる | ユーザーの製品判断（6.4以降の提供方針） |
| E-2 多次元arrayの座標の正の順 | 連鎖subscript`[y][x]`（外側から）と、`element(at: x, y)`（内側から）が逆順で共存している。どちらを正とするかで、labelとsubscriptの候補が変わる | ユーザーの判断 |

## Completion condition

対象とした公開名について、候補、意図、懸念が順位なしで記録されていること。新しい本質的判断または
契約不明点が見つかった場合は、それを候補で隠さず`Unresolved findings`へ分離していること。
