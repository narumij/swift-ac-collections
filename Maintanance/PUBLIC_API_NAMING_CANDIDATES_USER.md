# Public API naming candidates — User

Status: submitted candidates. This document does not rank or adopt a public API name.

この文書は、0.6および1.0で公開品質としてValidation可能なAPIを三者で議論するために、
ユーザーが明示した名前候補だけを記録する。候補から契約、提供範囲、または採用判断を補わない。

目的と品質上の位置づけは、製品コンセプトの正本
[`User/CONCEPT_DEFINITION.md`](User/CONCEPT_DEFINITION.md)と、製品品質要求の正本
[`User/QUALITY_REQUIREMENTS.md`](User/QUALITY_REQUIREMENTS.md)に従う。この候補記録は両正本を
再定義しない。

## Array object names

| Current family | Candidate base name |
| --- | --- |
| `BareArray` | `BareElements` |
| `OptionalArray` | `OptionalCache` |

次元suffixおよび派生View名は、この提出から推測して確定しない。

## Array access API

ユーザーの候補は現行familyのみである。

| Role | Candidate |
| --- | --- |
| Read | `element(at: ...)` |
| Write | `setElement(_:at: ...)` |
| Mutable reference | `reference(at: ...)` |
| Mutable reference type | `Reference` |

initializer、`removeAll()`、`indices`、subscript、argument label、およびViewの公開名は、
この提出では候補未提出である。

## Permutation API

通常経路と借用経路を含め、ユーザーの名前候補はまだ提出されていない。現行の
`nextPermutations()`、`NextPermutations`、`borrowedNextPermutations()`、
`BorrowedNextPermutations`を、ユーザーが採用候補として提出したとは扱わない。
