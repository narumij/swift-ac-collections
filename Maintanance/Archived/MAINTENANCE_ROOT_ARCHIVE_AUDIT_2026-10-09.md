# Maintanance直下文書の待避判断

## TL;DR（人間向け）

`Maintanance/`直下の27文書を、現在の運用に必要な正本と、完了してArchiveへ移せる証拠に分けた2026-10-09の判断記録（OPS-003〜008）。待避したのはgraph実験の完了済み2文書と旧統合評価1文書だけで、起動・運用正本や継続資料は直下に残した。日付だけでは移動しないという基準と、再確認の条件も残している。

Last updated: 2026-10-09 / Codex

<a id="目的"></a>
## Purpose

Split the Markdown directly under `Maintanance/` into canonicals needed for current startup, operation and task resumption, and completed evidence that can be moved to the Archive. Do not move a document just because it is old; decide on the grounds of the current Registry, agent startup rules, cross-references and whether it is still updated.

<a id="判断task"></a>
## Decision tasks

| ID | Kind | Target | Decision |
| --- | --- | --- | --- |
| `OPS-003` | `DISCOVERY` | inventory of the use, state and references of the 27 top-level documents | Done. 27 documents, about 618KB, classified into 4 groups |
| `OPS-004` | `DECISION` | startup and operation canonicals | Keep at top level. Includes the Registry, handoff, playbook, template, conversation reference rules and maintenance rules |
| `OPS-005` | `DECISION` | graph experiment documents | Move only the 2 documents of the completed minimal schema and in-memory fixture. Keep the canonicals of active and frozen tasks and the exchange log |
| `OPS-006` | `DECISION` | evaluation and observation documents | Move only the old integrated evaluation of 2026-10-05. Keep the per-agent interviews, observations and task-fit table as continuing materials |
| `OPS-007` | `DECISION` | technical investigation and release documents | Keep all at top level. Includes canonicals of frozen tasks, an unsettled independent review, and records waiting for a later branch merge |
| `OPS-008` | `EXECUTION` | moving the 3 adopted documents and updating references | Done |

<a id="待避"></a>
## Moved

- `AI_GRAPH_SHARED_SCHEMA.md`: completion evidence of the shared-schema minimal fixture. Referred to as input material from the later re-test canonical.
- `AI_GRAPH_IN_MEMORY_FIXTURE.md`: completion evidence of the SQLite in-memory fixture. The executables remain in `AIGraphInMemoryFixture/`.
- `USER_MANAGEMENT_ASSESSMENT.md`: the integrated evaluation as of 2026-10-05. The per-agent interviews and observations are now the continuing materials.

<a id="直下維持の基準"></a>
## Criteria for keeping at top level

- Entry points for sessions and between agents, such as `PROGRESS_OVERVIEW.md`, the Claude handoff and the numbering queue.
- Detailed canonicals referred to from `ACTIVE`, `FROZEN`, `WAITING_EXTERNAL` and `USER_ONLY` in the current Registry.
- Permanent operation materials such as the release checklist, the task operation playbook and the conversation ID rules.
- Materials that will continue to be appended to or referred to under explicit conditions, such as the per-agent evaluations, observations and the task-fit table.
- An independent performance review whose cause is not determined, and release records that still have a later branch merge pending.

<a id="再確認条件"></a>
## Conditions for re-checking

When the graph experiments complete or end, when the later branch merge of 0.5.0 completes, and when RedBlackTree's external wait is resolved, make the move decision again for the respective detailed canonicals together. Do not move individual documents by date alone.
