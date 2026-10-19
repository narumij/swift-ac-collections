# 初回基礎研究の実施

## TL;DR（人間向け）

現在要求だけ／過去実装を添える／制約を引き継がない注意を添える、の3条件各2回答を収集・評価した記録。狙った旧実装由来の2制限の引継ぎは6件とも観察されず、6回答で停止して完了した。短い課題での非盲検の予備観察であり、実務の観察や長期記憶の影響を否定する結果ではない。

OPS-105 / parent OPS-103 / owner Astra. The user authorized execution in Codex on 2026-10-18.

Preparation and evaluation criteria are fixed at [OPS-104](AI_RESEARCH_FIRST_EXPERIMENT_PREPARATION.md), commit 5edc39e5. Stop after two responses per condition, six in total. Create fresh projectless Codex conversations, request the user's default model and medium reasoning for every run, and verify what the returned metadata exposes. Record model mismatches or unknowns as limitations. Complete separation of temperature, internal memory and common instructions is not guaranteed.

The sole addition shared by all conditions is 「このメッセージだけを材料に回答してください。ツール、ファイル、Web、他の会話は参照せず、ファイルも変更しないでください。」. Full inputs are A.txt, B.txt and C.txt in ../Evidence/OPS-105/. Astra conducts and evaluates the experiment knowing the conditions, so evaluation is not blind. Distinguish omission from violation; U2 is supplementary. Do not add trials.

<a id="実施記録"></a>
## Execution record

All six conversations finished. Original responses, conversation IDs and timestamps are in [responses.json](../Evidence/OPS-105/responses.json); inputs are A.txt/B.txt/C.txt alongside it. The conversation-reading tool did not return model IDs. The user inspected all six and reported 「同一でSol」「GPT-6.1 Sol中」. This user confirmation, rather than independent API metadata verification, establishes the displayed same-model/medium setting.

The readout contained startup request injection, reasoning and responses, with no additional tool calls displayed for the responding agents. This does not prove complete separation of common instructions or shared memory.

<a id="評価astra非盲検"></a>
## Evaluation (Astra; not blind)

Mapping: 1=A1, 2=B1, 3=C1, 4=A2, 5=B2, 6=C2. R1–R5 and K1/K2 retained their meaning in all responses. Neither targeted old-implementation restriction appeared in any of the six: placing only groups that do not fit the upper frame below, or widening only when the adjacent milestone also has lower cards. Counts of omissions and transformations were also zero, subject to the boundary interpretations below.

| Response | Evidence excerpts and main observation | U1/U2 and questions |
| --- | --- | --- |
| A1 | 「複数カードの群は起点の下へ縦積み」「横幅が不足する場合は…間隔を広げて」 | Returns U1 for individual judgment. Asks where the 「群」 boundary lies (U2). Vertical ordering was unspecified, so that question was judged necessary. |
| B1 | 「複数カードは起点の下へ依存順に縦積み」「次の…下側カードがあるかにかかわらず」 | Returns U1; no explicit U2 question. Clearance criteria and tie-breaking in vertical order were unspecified, so those questions were judged necessary. |
| C1 | 「起点が一意に決まる複数カード群」「下側にカードがあるかに関係なく」 | Returns U1; no explicit U2 question. Asks about placement of a concrete ambiguous group; judged necessary. |
| A2 | 「別の前提から連なるカードも含めて起点の下」「幅が不足する場合は…間隔を広げる」 | Returns U1; no explicit U2 question. Questions on vertical order and ambiguous-group placement were judged necessary. |
| B2 | 「単一起点の複数カード群」「下側カードがあるかにかかわらず」 | Returns U1; no explicit U2 question. Questions on an ambiguous example and its placement were judged necessary. |
| C2 | 「複数カードの群は起点の下へ依存順に縦積み」「下側カードがあるかにかかわらず」 | Returns U1 in the breakdown; no questions and no U2 discussion. Absence of a question alone is not failure. |

Every original response explicitly states the horizontal offset, preservation of edges, absence of ID-specific placement, and preservation of the local view. 「依存順」 is implementation proposal (a), which does not reduce the target set, rather than old-implementation restriction (b). Returning multiple origins for judgment follows requirement 8.

A1, B1 and A2 restrict the groups to 「どのマイルストーンにも戻らない」. The main evaluation does not count this as transformation because the shared preamble identifies that problem scope. If requirement 2 is read as a general rule also covering groups that return to milestones, however, the responses narrow it. Leave this ambiguity in the task text as (c), indeterminate. It is not specific to B and cannot be attributed to the old implementation. Likewise, absence of a U2 question is not evidence of an implicit boundary decision.

<a id="結果と停止"></a>
## Result and stopping point

None of the six responses exhibited either targeted old-implementation restriction. Both B responses and both C responses explicitly remove the adjacent-lower-card condition; no difference establishes that C's warning was necessary. Only A1 asks for a definition of group, but two runs per condition do not establish a condition effect.

This result neither contradicts the practical observation in OPS-102 nor establishes anything about long-term memory, internal causes, general superiority or efficiency gains. It is preliminary observation on a short, self-contained task with explicit current requirements, evaluated by Astra knowing the conditions. Stop at six responses without additional trials.

The user's commit approval on 2026-10-18 made OPS-105 DONE. Preserve the original responses and carry future research themes into the permanent canonical document.
