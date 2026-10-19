# 赤黒木4型ドキュメント独立レビュー依頼

## TL;DR（人間向け）

赤黒木本文の型別4件と横断1件を、未commit内容も含む固定入力で姫へ依頼したレビューの範囲と受入条件。既存スニペット増減禁止を保ち、実装・仕様テスト・日英本文の整合を独立に確認して指摘を返す。レビュー返却・Astra検収・ユーザー受入は別で、この依頼票だけでは本文受入や実装変更を認めない。

2026-10-16 / assignment authored/accepted by Astra. The user delegates review to Claude (Hime); assign five children of DOC-034 together. Freeze this request and inputs when the assignment is complete. Inputs include the uncommitted working tree; HEAD alone is not the reviewed revision.

<a id="仕事と順序"></a>
## Work and order

| ID | Target | Return location |
| --- | --- | --- |
| DOC-040 | RedBlackTreeSet | [DOC-040_DOCUMENT_REVIEW_RETURN.md](DOC-040_DOCUMENT_REVIEW_RETURN.md) |
| DOC-041 | RedBlackTreeDictionary | [DOC-041_DOCUMENT_REVIEW_RETURN.md](DOC-041_DOCUMENT_REVIEW_RETURN.md) |
| DOC-042 | RedBlackTreeMultiSet | [DOC-042_DOCUMENT_REVIEW_RETURN.md](DOC-042_DOCUMENT_REVIEW_RETURN.md) |
| DOC-043 | RedBlackTreeMultiMap | [DOC-043_DOCUMENT_REVIEW_RETURN.md](DOC-043_DOCUMENT_REVIEW_RETURN.md) |
| DOC-044 | All four types | [DOC-044_DOCUMENT_REVIEW_RETURN.md](DOC-044_DOCUMENT_REVIEW_RETURN.md) |

The four type reviews are independent; suggested order Set→Dictionary→MultiSet→MultiMap. Once all four returns exist, proceed to the final cross-type review without awaiting intermediate Astra/user replies. A question on one type does not block independent checks of others. Return only matters requiring public-contract decisions as unresolved. Return all five together.

<a id="固定入力と入口"></a>
## Fixed inputs and entry points

[Audit](RED_BLACK_TREE_OUTLINE_AUDIT.md), [body work record](RED_BLACK_TREE_DOCUMENT_COMPLETION.md), [SHA-256 list](Evidence/DOC-033-2026-10-16/review-inputs.sha256.json). Paths in the list are repository-relative. Compare before starting; return mismatches rather than continuing with different inputs. Registry/Rules are current state/authority checks, not fixed inputs.

Read each type's outline, Japanese/English bodies and type comments, then compare directly against necessary implementation and Test as Spec in `Tests/RedBlackTreeTests/`. No bulk archive reading. Evidence is in `Evidence/DOC-033-2026-10-16/`. Astra's explanations or passing tests are not substitutes for correctness.

<a id="確認内容"></a>
## Checks

1. All outline items are explained; no required content was lost in reorganization and no general rule is presented as a product contract.
2. Index, Bound, CoW, View, unrelated indices, post-deletion generations and range endpoints match implementation/Test as Spec. Distinguish extracting a View to another variable from direct subscript mutation.
3. Type-specific behavior: Set uniqueness/set operations; Dictionary default/duplicate initialization/merge; MultiSet update/multiplicity operations; MultiMap hint/value View/pair View/erase(exactly:).
4. Complexity assumptions and additional CoW/comparison/closure costs are accurate, without implying measured performance.
5. Japanese, English and public comments agree in meaning. Examples originally exclusive to body prose need not appear in type comments. Distinguish executable examples from declaration/constraint fragments and check context/expected results.
6. Cross-type review separates wording differences for common contracts from intentional type differences; consolidate common fixes without multiplying duplicate findings.

Run necessary targeted tests if useful; do not repeat all existing results without reason. Record artifacts under COMMONS. New tests/product-code changes are outside scope.

<a id="編集範囲と停止点"></a>
## Editing scope and stopping point

Edit only the five assigned return files; existing optional CLAUDE_OBSERVATIONS delegation remains separate. Do not edit bodies, outlines, source, Registry, Rules, this request or original evidence. Return errors with evidence and minimal proposed fixes. Preserve 0.6.0's no-add/remove snippet constraint; distinguish 0.8.0 expansion candidates. Do not independently decide public contracts, new structure policy or product repairs.

No commit under this assignment. If the user later explicitly permits one, first record its scope and the changed portion of this restriction in the return, then follow it. Execution reports, Astra's delegated review acceptance and DOC-037 user acceptance are distinct. A completed assignment sheet is not acceptance.

<a id="完了条件"></a>
## Completion conditions

Return checked scope, evidence, findings (or none), minimal fixes and unknowns for each type. Cross-type results separate publication blockers, technical corrections and optional improvements. Guarantee only checked scope, not consensus. Astra verifies returns and integrates fixes/verification into DOC-034.
