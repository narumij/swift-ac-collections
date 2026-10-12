# Public API naming candidates — Claude assignment and submission

Status: assigned by explicit user direction on 2026-10-12. Candidate submission not yet completed.

## Goal

0.6および1.0で公開品質としてValidation可能なAPIを三者で議論するために、Claudeが
Array系とPermutation系の公開名候補を独立に提出する。

このtaskは候補出しだけを行う。順位付け、採点、統合、採用判断、実装、test、文書反映は行わない。

## Product and quality context

この節は、製品コンセプトの正本
[`User/CONCEPT_DEFINITION.md`](User/CONCEPT_DEFINITION.md)と、製品品質要求の正本
[`User/QUALITY_REQUIREMENTS.md`](User/QUALITY_REQUIREMENTS.md)から、今回の候補出しに必要な文脈を
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

## Existing submission

Array object名については、Claudeが既に
`User/ARRAY_NAMING_CANDIDATES_CLAUDE.md`へ独立候補を提出済みである。作り直さない。

今回提出するのは次の二群である。

1. BareArray／OptionalArray familyの未提出の公開API名候補
2. Permutation通常経路とSwift 6.4 borrowed `Span`経路の公開API名候補

## Independence boundary

候補を提出し終えるまで、次の他者候補を読まない。

- `PUBLIC_API_NAMING_CANDIDATES_USER.md`
- `PUBLIC_API_NAMING_CANDIDATES_CODEX.md`
- `User/ARRAY_NAMING_CANDIDATES_USER.md`
- `User/ARRAY_NAMING_CANDIDATES_CODEX.md`
- `User/ARRAY_NAMING_RANKING_CODEX.md`

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
| _Claude fills_ |  |  |  |  |  |  |

### B. Other Array public names

initializer、`removeAll()`、`indices`、subscript、coordinate／dimension label、Viewの操作など、
Claudeが候補を提出する公開名を記録する。

| Current public name or role | Candidate | Intent | Concern |
| --- | --- | --- | --- |
| _Claude fills_ |  |  |  |

### C. Permutation public API families

通常のruntime-check View経路と、Swift 6.4のborrowed `Span`経路の関係が分かるfamilyとして記録する。

| Candidate family | Normal factory | Normal owner/iterator | Normal yielded view | Borrowed factory | Borrowed owner/iterator | Intent | Concern |
| --- | --- | --- | --- | --- | --- | --- | --- |
| _Claude fills_ |  |  |  |  |  |  |  |

### D. Other Permutation public names

`next()`その他について、候補を提出する公開名があれば記録する。

| Current public name or role | Candidate | Intent | Concern |
| --- | --- | --- | --- |
| _Claude fills_ |  |  |  |

### E. Unresolved findings

| Finding | Why candidate submission cannot resolve it | Needed next input |
| --- | --- | --- |
| _Claude fills only when needed_ |  |  |

## Completion condition

対象とした公開名について、候補、意図、懸念が順位なしで記録されていること。新しい本質的判断または
契約不明点が見つかった場合は、それを候補で隠さず`Unresolved findings`へ分離していること。
