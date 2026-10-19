# Registryアプリ：既存graph試験の知見と再利用範囲の調査

## TL;DR（人間向け）

既存graph試験の共有lint・fixture・出典管理を調べ、閲覧編集アプリへの再利用範囲と最小の読取専用試作案を返した調査。共有試験は通過したが、原文を保つ往復編集や完成アプリは確認していない。方式・製品方針は未確定で、専用DBの調査や旧試験の再開は行っていない。

2026-10-16 / recorded by Astra. OPS-049, child of permanent [OPS-048](TASK_REGISTRY_APP.md). Under the user's investigation request, inspected shared documents, implementations and fixtures. Accepted investigation; DONE following user commit instruction.

<a id="目的範囲"></a>
## Purpose and scope

Compare shared graph-trial documents/results/fixtures with current Registry representation. Identify reusable knowledge, missing representations and minimal read-only viewer prototype. DISCOVERY does not decide technology or product policy.

Entry points: [independent trials](../Graph/TASK_GRAPH_DB_EXPERIMENT.md), [Registry](../ProgressV2/TASK_REGISTRY_V2.md), [Rules](../ProgressV2/TASK_RULES_V2.md), [milestones](../MILESTONES.md). Distinguish historical state of references from current state.

<a id="返却受入条件"></a>
## Return and acceptance conditions

- Cite reusable shared results/knowledge, unusable material and unknowns.
- Describe retained/missing task attributes, dependency Flow, free-text conditions, decision owners, milestone relationships and provenance/revisions.
- Propose read-only input/display scope and original comparison; retain round-trip information-loss/conflict questions.
- Separate implementable next scope from user decisions. Investigation acceptance leads to commit wait, not automatic prototype permission.

<a id="境界"></a>
## Boundaries

Do not inspect/copy Claude-private database/schema/queries/metadata or request undisclosed designs. Evaluate only shared results within trial-sharing boundaries.

Do not resume ended Codex graph trials or withdrawn database integration. This is new investigation of a user-facing viewer/editor, not revived old policy. No database, Registry writes or app implementation. Existing materials stay unchanged except this result record.

Parentage is organizational, not a permanent-task completion dependency; GRAPH-001 completion is not required.

<a id="調査結果2026-10-16--astra"></a>
## Investigation results (2026-10-16 / Astra)

<a id="結論と再利用範囲"></a>
### Conclusion and reusable scope

Shared structural lint/fixtures and the distinction between provenance and semantic validation are reusable. Inspected shared results contain no completed viewer/editor or source-preserving write-back implementation. No basis exists for adopting the SQL schema directly as an intermediate form; a lossless Markdown-reading layer needs separate design.

| Shared result | Established | Application and limits |
| --- | --- | --- |
| [TaskGraphLint](../Graph/TASK_GRAPH_LINT.md), [implementation](../Graph/TaskGraphLint/run.sh) | Reads current Registry; detects orphan references, self-dependency, duplicate edges, invalid Flow/cycles | Reuse structural rules/valid-invalid fixtures, not semantic/execution-authority decisions. |
| [Shared schema](../Graph/AI_GRAPH_SHARED_SCHEMA.md), [DDL](../Graph/InMemoryFixture/schema.sql) | Represents nodes/edges, provenance, confidence, observation time, evidence and derivation | Retain provenance/inference and zero/unobserved distinctions; not an app schema containing task state/owner/Flow/milestones. |
| [Shared fixtures](../Graph/AI_GRAPH_IN_MEMORY_FIXTURE.md), [replay](../Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md) | Fixed historical-data checks of relationships/gaps/staleness; records START/COMPLETE→current Flow transition | Reuse regression perspectives; fixture success proves neither current source quality nor current task mapping. |
| [Independent-trial records](../Graph/TASK_GRAPH_DB_EXPERIMENT.md) | Reports stale read targets, distinctions among FROZEN/waits/permanent ACTIVE and local visualization PoC | Reuse misreading prevention/revision-comparison needs; private DB/scripts/images not inspected, portability unknown. |

<a id="今回の検証"></a>
### Verification performed

Logs/input hashes in [execution evidence](Evidence/RegistryAppDiscovery20261016/). HEAD 76c08138 plus uncommitted OPS-048/049 registration. Registry SHA-256 before acceptance-state update: c2e2e6a6f0d0827e0b3aed7039611f984ac3108f0e7662010429bda8326119f1.

- Current lint: 36 tasks, 11 edges, warnings 0/errors 0, exit 0.
- Valid/invalid lint fixtures: PASS, exit 0.
- Shared in-memory fixture: 6/6 PASS, exit 0.
- Independent table count: 36 tasks, no duplicate IDs; ACTIVE 22, DONE 4, USER_ONLY 3, PROPOSED 3, WAITING_EXTERNAL 2, FROZEN 1, WAITING_USER 1.

Existing lint splits pipes with awk, removes backticks and reads five columns only; it loses detailed-canonical column, domain and source position. Regenerating originals from it would lose information. Escaped pipes/Markdown boundaries are not validated as a dedicated parser. Fixture PASS is not round-trip editing assurance.

<a id="表現上の不足と提案"></a>
### Representation gaps and proposal

| Item | Minimum prototype handling |
| --- | --- |
| Task/owner/type/permanent category | Retain six original columns/domain/line position. Owner stays original text, not inferred personal ID. Show permanent categories with explicit Rules list/provenance. |
| Mandatory dependency | Display predecessor→successor and map original successor/prerequisite column order. Distinguish SEQUENCE/PARALLEL_JOIN. |
| Conditions/decision owner | Show unparsed original conditions in detail. ACTIVE or completed prerequisites alone do not mean 「実行可能」. Do not infer decision authority from owner. |
| Parentage/milestones | Separate from completion dependencies. Currently spread across prose/version canonicals; first show MILESTONES table/links without inferred edges. |
| Source/loaded revision | Identify path, position, original text, whole-file hash, Git HEAD/uncommitted changes. Line numbers are not persistent keys. |
| History | Current-only initially. Historical ID reuse means future history joins need document/revision, not ID alone. |

<a id="次に実装できる限定範囲提案未着手"></a>
### Next implementable scope (proposal; unstarted)

Read current Registry, Rules state/permanent definitions and MILESTONES target table; display list, eleven explicit dependency edges, selected conditions and canonical links. Exclude recursive canonical/Archived searches, automatic ready decisions, AI condition extraction and editing/write-back. Do not omit tasks unconnected to milestones.

A source-bearing JSON snapshot is a small starting intermediate form. SQLite may later be a derived search/history cache. This is a proposal, not adoption of JSON/SQLite or native/Web.

Initial checks should compare six columns/IDs/state counts/all edges including Flow/constraints, reach sources, show uninterpreted conditions and avoid silently discarding unknown states/invalid rows. Isolated fixtures cover escaping/links/backticks/unknown columns and no ready claim contrary to source.

Editing would retain original files and patch only target cells. Require byte-identical no-edit round trips, unchanged regions, post-load change detection, conflict stop and structural lint afterward. Validate every file before multifile changes, in recoverable units. Not implemented/tested yet.

<a id="残る判断と受入"></a>
### Remaining decisions and acceptance

Next decision: start Web or native prototype, together with intermediate representation, then register read-only implementation separately. Editing method/publication/distribution/history database need not be decided now.

Cited reuse scope, gaps, minimum prototype and checks with execution evidence meet investigation acceptance. OPS-049 DONE under user commit instruction. App remains unimplemented; existing databases/trial materials unchanged.
