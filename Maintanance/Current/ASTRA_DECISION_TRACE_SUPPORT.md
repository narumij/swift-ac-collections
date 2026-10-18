# Astraの判断追跡負荷を軽くする — 限定試作

## TL;DR（人間向け）

有効な判断と原文へ辿る負担を減らす限定試作を評価した。原文リンクと判断待ち／実作業待ちの区別は役立ったが、対象別置換の誤適用と印の維持負荷があり、現行運用には組み込まない。正式UIや制度の採用ではなく、限界を明らかにした評価成果として完了した。

2026-10-16 / authored and accepted by Astra. The user's designated 「アストラさんを元気にするタスク」. Fixed ID OPS-056, under permanent OPS-048.

<a id="目的"></a>
## Purpose

Reduce the effort of rediscovering relevant decisions and resolving conflicts with old decisions. Before work or a gate, make effective decisions, waiting conditions and their originals reachable without relying on memory. More management fields or mandatory reading are not outcomes in themselves.

Preserve [Hime's original proposal](GATE_DECISION_DIGEST_PROPOSAL.md), CP-20261016-006, verbatim. Formal registration does not adopt its proposed method. This assignment requests one prototype and evaluation; formal UI or policy integration is considered after return.

<a id="astraの要望修正点"></a>
## Astra's requirements and corrections

1. Do not equate user ownership with a pending decision. Distinguish awaiting judgment, user execution, material and already settled decisions; leave unclassifiable cases unverified. DONE alone does not imply an affirmative decision.
2. Use upstream gate traversal to narrow reading, retaining the meaning of edges such as prerequisites, decision material and resumption judgment. Consider how to find applicable constraints even outside the gate's upstream set.
3. Reach decisions in canonical prose. Show quotations, file, section and input revision; the list is a generated copy. Do not relocate records or create another decision authority.
4. A newer date alone does not invalidate an older decision. Apply only explicit replacement/change scope, retaining unaffected conditions for partial changes. Return unclear relationships as possible conflicts.
5. Decision marks are candidates. Try a minimal form that can cover multiple tasks/milestones. Do not annotate every existing document, institutionalize a fixed format or scan all history.

<a id="試作範囲と受入条件"></a>
## Prototype scope and acceptance

Use one actual user decision: 「今回の0.6.0文書作業では既存スニペットを増減しない。拡充・再検討は0.8.0へ配置する」. Inputs are RELEASE_0_8_0.md, RELEASE_0_6_0.md, Registry rows and detailed canonicals for DOC-033–039, and relevant portions of the current Studio snapshot.

- Produce sample decision/condition lists for selecting MS-060 and DOC-034. Make the decision's source and effect on work traceable.
- Demonstrate candidate marks and an extractor or procedure in isolated prototype files. Do not mark current canonicals; identify parts that cannot be extracted or need manual handling.
- Check examples that distinguish user execution from unresolved judgment and preserve conditions after partial changes. Label hypothetical examples as tests, separate from real decisions.
- Compare additional recording effort with reduced tracking effort. Report candidly whether Astra could use this daily and whether a simpler method would suffice.

Adopting implementation, changing public contracts, completing tasks or newly deciding validity of decisions is outside scope. Inadequacy with reasons is a valid result. Leave new user decisions as questions rather than filling them in.

<a id="受渡し"></a>
## Handoff

The assignment is in Maintanance/CLAUDE_TASK.md, OPS-056. Claude may edit prototype/evaluation files in `Maintanance/Current/GateDecisionDigestPrototype/` and the assignment's Return. This canonical, original proposal and input materials are fixed. Astra appends verification and acceptance without rewriting the original response.

<a id="astra確認記録"></a>
## Astra's verification record

2026-10-16 / Astra inspected the original CLAUDE_TASK Return, eight prototype files and extractor implementation, and accepted the bounded prototype/evaluation. No formal method adoption or UI integration. Completed following user commit approval.

Reruns for MS-060, DOC-034 and MS-070 on the current snapshot produced output. Classification distinguishes awaiting user execution from judgment and does not infer affirmation from DONE. DOC-035 --test reproduced a defect: a hypothetical replacement scoped to DOC-034 also marks DOC-035 replaced. Registry and other inputs changed since the original return, so this does not reproduce its counts/hashes. Original saved returns and samples remain unchanged.

Acceptance permitted reporting deficiencies with reasons. The result is accepted for exposing per-target replacement limits and annotation effort, not certified as a usable tool by hiding defects. No clause-by-target repair or institutionalization of new marks was performed.

Astra's evaluation: original links and the judgment/work waiting distinction help. However, maintaining marks for each decision costs more than the current gate cache, and the scope misapplication defect remains; do not integrate it into current operation. Continue the already decided practice of summarizing relevant decisions/constraints at gates. Do not automatically create generalization or further repair work.
