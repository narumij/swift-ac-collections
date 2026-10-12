# Task IDと詳細正本の対応調査

## この文書の段階

この文書は、Task Registryのtask IDと詳細正本の対応を調べるための作業記録である。
現行taskの状態、担当、再開条件を定める正本ではない。現在の作業判断には
`PROGRESS_OVERVIEW.md`のTask Registryを使用する。

最初の表は、現行Registryと日付別の完了Registryアーカイブに残る行を機械的に照合したsnapshotである。
同じIDに複数の詳細正本表記がある場合は、一方へ正規化せず、その差異を履歴調査の入口として残す。

## 対応表

| Task ID | 観測された詳細正本 | 観測先 | 注記 |
| --- | --- | --- | --- |
| `API-001` | `PUBLIC_API_NAMING_CANDIDATES_CLAUDE.md` | 2026-10-12 |  |
| `API-002` | `PUBLIC_API_NAMING_BALLOT.md` / `PUBLIC_API_NAMING_CANDIDATES_USER.md` / `PUBLIC_API_NAMING_CANDIDATES_CODEX.md` / `PUBLIC_API_NAMING_CANDIDATES_CLAUDE.md` | 現行 |  |
| `API-003` | `PUBLIC_API_NAMING_BALLOT.md` / `ArrayObjectAndAPINamingDraft.md` | 2026-10-12 |  |
| `API-004` | `PUBLIC_API_NAMING_SCORE_USER.md` / `PUBLIC_API_NAMING_BALLOT.md` | 現行 |  |
| `API-005` | `PUBLIC_API_NAMING_SCORE_CODEX.md` / `PUBLIC_API_NAMING_BALLOT.md` | 現行 |  |
| `API-006` | `PUBLIC_API_NAMING_SCORE_CLAUDE.md` / `PUBLIC_API_NAMING_BALLOT.md` | 現行 |  |
| `API-007` | `PUBLIC_API_NAMING_SCORE_REPORT.md` / `PUBLIC_API_NAMING_DECISIONS.md` / `PUBLIC_API_NAMING_SCORE_USER.md` / `PUBLIC_API_NAMING_SCORE_CODEX.md` / `PUBLIC_API_NAMING_SCORE_CLAUDE.md` | 現行 |  |
| `ARRAY-001` | `StrictMemorySafetyReadiness.md` | 2026-10-12 |  |
| `ARRAY-002` | `PUBLIC_API_NAMING_CANDIDATES_CODEX.md` / `ArrayObjectAndAPINamingDraft.md` | 2026-10-12 |  |
| `ARRAY-003` | `PUBLIC_API_NAMING_CANDIDATES_CLAUDE.md` / `ArrayObjectAndAPINamingDraft.md` | 2026-10-12 |  |
| `ARRAY-004` | `Archived/ARRAY_NAMING_RANKING_CODEX.md` / `ArrayObjectAndAPINamingDraft.md` | 2026-10-12 | 旧ranking draftを独立採点方式で置換。 |
| `ARRAY-005` | `PUBLIC_API_NAMING_SCORE_REPORT.md` / `PUBLIC_API_NAMING_DECISIONS.md` / `ArrayObjectAndAPINamingDraft.md` | 現行 |  |
| `ARRAY-006` | `PUBLIC_API_NAMING_SCORE_REPORT.md` / `PUBLIC_API_NAMING_DECISIONS.md` / `ArrayObjectAndAPINamingDraft.md` | 現行 |  |
| `ARRAY-007` | `PUBLIC_API_NAMING_DECISIONS.md` / `ArrayObjectAndAPINamingDraft.md` | 現行 |  |
| `ARRAY-008` | `PUBLIC_API_NAMING_CANDIDATES_USER.md` / `ArrayObjectAndAPINamingDraft.md` | 2026-10-12 |  |
| `BARE-001` | `BareArrayModule/BareArrayAudit.md` | 2026-10-11 |  |
| `BARE-002` | `BareArrayModule/BareArrayAudit.md` | 2026-10-11 |  |
| `BARE-003` | `BareArrayModule/BareArrayAudit.md` | 2026-10-11 |  |
| `BARE-004` | `BareArrayModule/BareArrayAudit.md` | 2026-10-11 |  |
| `BARE-005` | `BareArrayModule/BareArrayAudit.md` | 2026-10-11 |  |
| `BARE-006` | `BareArrayModule/CurrentQualityAssessment.md` / `Tests/TESTING.md` | 2026-10-12 |  |
| `BARE-007` | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` | 現行 |  |
| `BARE-008` | `BareArrayModule/BareArrayAudit.md`<br>`Tests/TESTING.md` | 2026-10-11<br>2026-10-09 | 表記差あり。変更理由またはID再利用を履歴確認する。 |
| `BARE-009` | `BareArrayModule/BareArrayAudit.md` | 2026-10-11 |  |
| `BARE-010` | `BareArrayModule/BareArrayAudit.md` | 2026-10-11 |  |
| `BARE-011` | `BareArrayModule/BareArrayAudit.md` | 2026-10-11 |  |
| `BARE-012` | `Archived/Canonical/ARRAY_NAMING_REVIEW.md` / `Archived/Canonical/CHATGPT_ARRAY_NAMING_REVIEW_REQUEST.md` | 2026-10-11 |  |
| `BARE-013` | `BareArrayModule/BareArrayAudit.md` | 2026-10-11 |  |
| `BARE-014` | `BareArrayModule/BareArrayAudit.md` | 2026-10-11 |  |
| `BARE-015` | `BareArrayModule/BareArrayAudit.md` | 2026-10-11 |  |
| `BARE-016` | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` | 2026-10-12 |  |
| `BARE-017` | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` | 現行 |  |
| `BARE-018` | `BareArrayModule/CurrentQualityAssessment.md` | 現行 |  |
| `BARE-019` | `BareArrayModule/CurrentQualityAssessment.md` | 2026-10-12 |  |
| `BARE-020` | `BareArrayModule/CurrentQualityAssessment.md` | 現行 |  |
| `BARE-021` | `BareArrayModule/CurrentQualityAssessment.md` | 現行 |  |
| `BARE-022` | `BareArrayModule/CurrentQualityAssessment.md` | 現行 |  |
| `BARE-023` | `BareArrayModule/CurrentQualityAssessment.md` / `StrictMemorySafetyReadiness.md` | 2026-10-12 |  |
| `BARE-024` | `BareArrayModule/CurrentQualityAssessment.md` / `StrictMemorySafetyReadiness.md` | 2026-10-12 |  |
| `BARE-025` | `BareArrayModule/CurrentQualityAssessment.md` / `StrictMemorySafetyReadiness.md` | 2026-10-12 |  |
| `BARE-026` | `BareArrayModule/CurrentQualityAssessment.md` | 2026-10-12 |  |
| `BARE-027` | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` | 2026-10-12 |  |
| `BARE-028` | `BareArrayModule/CurrentQualityAssessment.md` | 現行 |  |
| `BARE-029` | `BareArrayModule/CurrentQualityAssessment.md` | 2026-10-12 |  |
| `BARE-030` | `BareArrayModule/CurrentQualityAssessment.md` | 2026-10-12 |  |
| `BARE-031` | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` | 2026-10-12 |  |
| `BARE-032` | `BareArrayModule/CurrentQualityAssessment.md` / `Sources/BareArrayModule/Documentation/Quality-Profile.md` | 現行 |  |
| `BARE-033` | `Tests/TESTING.md` / `.github/workflows/ci.yml` / `.github/workflows/candidate.yml` | 2026-10-12 |  |
| `BARE-034` | `Sources/BareArrayModule/Documentation/Quality-Profile.md` | 2026-10-12 |  |
| `BARE-035` | `Sources/BareArrayModule/Documentation/Quality-Profile.md` / `Package.swift` | 現行 |  |
| `BENCH-001` | `Archived/SORTED_COLLECTIONS_BENCHMARK_TASK.md` | 2026-10-09 |  |
| `CPP-001` | `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md` | 2026-10-09 |  |
| `CPP-002` | `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md` | 2026-10-09 |  |
| `DOC-001` | `MAINTENANCE.md` | 2026-10-09 |  |
| `DOC-002` | `Archived/Canonical/RELEASE_0_5_2.md` | 2026-10-11 |  |
| `DOC-003` | `Archived/Canonical/RELEASE_0_5_2.md` / `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-11 |  |
| `DOC-004` | `Archived/Canonical/RELEASE_0_5_2.md` / `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-11 |  |
| `DOC-005` | `Archived/Canonical/RELEASE_0_5_2.md` / `BareArrayModule/BareArrayAudit.md` | 2026-10-11 |  |
| `DOC-006` | `Archived/Canonical/RELEASE_0_5_2.md` / `Sources/RedBlackTreeCollections/Documentation/Head/DOCUMENTATION_WORKFLOW.md` | 2026-10-11 |  |
| `DOC-007` | `Archived/Canonical/RELEASE_0_5_2.md` / `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-11 |  |
| `DOC-008` | `Archived/Canonical/RELEASE_0_5_2.md` / `CLAUDE_TASK.md` | 2026-10-11 |  |
| `DOC-009` | `Archived/Canonical/RELEASE_0_5_2.md` / `BareArrayModule/BareArrayAudit.md` | 2026-10-11 |  |
| `DOC-010` | `Archived/Canonical/RELEASE_0_5_2.md` / `BareArrayModule/BareArrayAudit.md` | 現行 |  |
| `DOC-011` | `Archived/Canonical/RELEASE_0_5_2.md` / `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-11 |  |
| `DOC-012` | `Archived/Canonical/NON_RBT_COMMENT_DOC_SELF_REVIEW.md` / `RELEASE_0_6_0.md` | 2026-10-11 |  |
| `DOC-013` | `CLAUDE_TASK.md` / `Archived/Canonical/NON_RBT_COMMENT_DOC_SELF_REVIEW.md` / `Orientation/AGENT_TASK_FIT_INTERVIEW.md` | 2026-10-11 |  |
| `DOC-014` | `Archived/Canonical/NON_RBT_COMMENT_DOC_SELF_REVIEW.md` | 2026-10-11 |  |
| `DOC-015` | `Archived/Canonical/NON_RBT_COMMENT_DOC_SELF_REVIEW.md` / `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-11 |  |
| `DOC-016` | `Archived/Canonical/NON_RBT_COMMENT_DOC_SELF_REVIEW.md` | 2026-10-11 |  |
| `DOC-017` | `Archived/Canonical/NON_RBT_COMMENT_DOC_SELF_REVIEW.md` | 2026-10-11 |  |
| `DOC-018` | `Archived/Canonical/NON_RBT_COMMENT_DOC_SELF_REVIEW.md` | 2026-10-11 |  |
| `DOC-019` | `Archived/Canonical/CODE_SNIPPET_SURVEY.md` / `Archived/Canonical/CODE_SNIPPET_SURVEY_CODEX.md` / `Archived/Canonical/CODE_SNIPPET_SURVEY_CLAUDE.md` | 2026-10-11 |  |
| `DOC-020` | `Archived/Canonical/PUBLIC_API_CODE_SNIPPET_SURVEY_2.md` / `Archived/Canonical/PUBLIC_API_CODE_SNIPPET_SURVEY_2_CODEX.md` / `Archived/Canonical/PUBLIC_API_CODE_SNIPPET_SURVEY_2_CLAUDE.md` | 2026-10-11 |  |
| `DOC-021` | `Archived/Canonical/PUBLIC_API_CODE_SNIPPET_SURVEY_2.md` / `CLAUDE_PENDING_TASKS.md` | 2026-10-11 |  |
| `DOC-022` | `Tests/TESTING.md` / `Sources/OptionalArrayModule/Documentation/Quality-Profile.md` | 2026-10-11 |  |
| `EVAL-001` | `USER_MANAGEMENT_INTERVIEW_CLAUDE.md` / `CLAUDE_OBSERVATIONS.md` | 2026-10-09 |  |
| `FIT-001` | `Orientation/AGENT_TASK_FIT_INTERVIEW.md` | 2026-10-09 |  |
| `FIT-002` | `Orientation/AGENT_TASK_FIT_INTERVIEW.md` | 2026-10-09 |  |
| `FIT-003` | `Orientation/AGENT_TASK_FIT_INTERVIEW.md` | 2026-10-09 |  |
| `FIT-004` | `Orientation/AGENT_TASK_FIT_INTERVIEW.md` | 2026-10-09 |  |
| `FIT-005` | `Orientation/AGENT_TASK_FIT_INTERVIEW.md` | 2026-10-09 |  |
| `FIT-006` | `Orientation/AGENT_TASK_FIT_INTERVIEW.md` | 2026-10-09 |  |
| `FIT-007` | `Orientation/AGENT_TASK_FIT_INTERVIEW.md` | 2026-10-09 |  |
| `GRAPH-001` | `Graph/TASK_GRAPH_DB_EXPERIMENT.md` | 現行 |  |
| `GRAPH-002` | `Graph/TASK_GRAPH_DB_EXPERIMENT.md` | 2026-10-09 |  |
| `GRAPH-003` | `Graph/TASK_GRAPH_DB_EXPERIMENT.md` | 2026-10-09 |  |
| `GRAPH-004` | `Archived/AI_GRAPH_SMELL_NOTES.md` | 2026-10-09 |  |
| `GRAPH-005` | `Graph/TASK_GRAPH_DB_EXPERIMENT.md` | 2026-10-09 |  |
| `GRAPH-006` | `Graph/AI_GRAPH_SHARED_SCHEMA.md` | 2026-10-09 |  |
| `GRAPH-007` | `Graph/AI_GRAPH_IN_MEMORY_FIXTURE.md` | 2026-10-09 |  |
| `GRAPH-008` | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` | 2026-10-09 |  |
| `GRAPH-009` | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` | 2026-10-09 |  |
| `GRAPH-010` | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` | 2026-10-09 |  |
| `GRAPH-011` | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` | 2026-10-09 |  |
| `GRAPH-012` | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` | 2026-10-09 |  |
| `GRAPH-013` | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` | 2026-10-09 |  |
| `GRAPH-014` | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` | 2026-10-09 |  |
| `GRAPH-015` | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` | 2026-10-09 |  |
| `GRAPH-016` | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` | 2026-10-09 |  |
| `GRAPH-017` | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` | 2026-10-09 |  |
| `GRAPH-018` | `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md` | 2026-10-09 |  |
| `GRAPH-019` | `Graph/TASK_GRAPH_LINT.md` | 2026-10-09 |  |
| `HIST-001` | `RefactoringFromAtCoder2025/README.md` / `RefactoringFromAtCoder2025/EVIDENCE.md` | 現行 |  |
| `OPS-001` | `Archived/Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V2.md` / `Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V3.md` / `PROGRESS_OVERVIEW_TEMPLATE.md` | 現行 | V2時点で凍結。再開時に現行V3への更新要否を確認する。 |
| `OPS-002` | `Orientation/CODEX_ORIENTATION.md`<br>`Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V2.md` / `Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md`<br>`Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-11<br>2026-10-12<br>2026-10-09 | 表記差あり。変更理由またはID再利用を履歴確認する。 |
| `OPS-003` | `MAINTENANCE_ROOT_ARCHIVE_AUDIT_2026-10-09.md`<br>`Orientation/AI_TECHNICAL_ORIENTATION.md`<br>`Orientation/TASK_DEPENDENCY_RUNTIME_STOP.md` | 2026-10-09<br>2026-10-11<br>2026-10-12 | 表記差あり。変更理由またはID再利用を履歴確認する。 |
| `OPS-004` | `MAINTENANCE_ROOT_ARCHIVE_AUDIT_2026-10-09.md`<br>`Orientation/CODEX_ORIENTATION.md` / `CLAUDE_TASK.md`<br>`Orientation/TASK_DECOMPOSITION_AND_REORGANIZATION.md` | 2026-10-09<br>2026-10-11<br>2026-10-12 | 表記差あり。変更理由またはID再利用を履歴確認する。 |
| `OPS-005` | `AI_TASK_PROCESS_POSTER.png` / `Utilities/Maintenance/GenerateAITaskProcessPoster.py`<br>`MAINTENANCE_ROOT_ARCHIVE_AUDIT_2026-10-09.md`<br>`Orientation/TASK_ORIENTATION.md` / `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-12<br>2026-10-09<br>2026-10-11 | 表記差あり。変更理由またはID再利用を履歴確認する。 |
| `OPS-006` | `AGENTS.md`<br>`MAINTENANCE_ROOT_ARCHIVE_AUDIT_2026-10-09.md`<br>`Orientation/TASK_DEPENDENCY_IDENTIFICATION_DRAFT.md` | 2026-10-11<br>2026-10-09<br>2026-10-12 | 表記差あり。変更理由またはID再利用を履歴確認する。 |
| `OPS-007` | `AI_TASK_PROCESS_POSTER.png` / `Utilities/Maintenance/GenerateAITaskProcessPoster.py`<br>`MAINTENANCE_ROOT_ARCHIVE_AUDIT_2026-10-09.md` | 2026-10-12<br>2026-10-09 | 表記差あり。変更理由またはID再利用を履歴確認する。 |
| `OPS-008` | `Archived/Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V1.md` / `Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V2.md`<br>`MAINTENANCE_ROOT_ARCHIVE_AUDIT_2026-10-09.md` | 2026-10-12<br>2026-10-09 | 表記差あり。変更理由またはID再利用を履歴確認する。 |
| `OPS-009` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-09 |  |
| `OPS-010` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-09 |  |
| `OPS-011` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-09 |  |
| `OPS-012` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-09 |  |
| `OPS-013` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-09 |  |
| `OPS-014` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` / `BareArrayModule/BareArrayAudit.md` | 2026-10-09 |  |
| `OPS-015` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-09 |  |
| `OPS-016` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-09 |  |
| `OPS-017` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-09 |  |
| `OPS-018` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-09 |  |
| `OPS-019` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-09 |  |
| `OPS-020` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-09 |  |
| `OPS-021` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-09 |  |
| `OPS-022` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-09 |  |
| `OPS-023` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-09 |  |
| `OPS-024` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-09 |  |
| `OPS-025` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md` | 2026-10-09 |  |
| `OPS-026` | `Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V3.md` / `Archived/Orientation/CODEX_TASK_OPERATION_PLAYBOOK_V2.md` / `Orientation/TASK_REGISTRY_STATE_HISTORY.md` / `TASK_CANONICAL_DOCUMENT_MAP.md` | 現行 | V3を現行正本へ採用し、V2を版名付きで保存。 |
| `OPS-027` | `AI_TASK_PROCESS_POSTER.svg` / `AI_TASK_PROCESS_POSTER.png` / `Utilities/Maintenance/GenerateAITaskProcessPoster.py` / `Archived/Orientation/AI_TASK_PROCESS_POSTER_V2/` | 現行 | V3を現行ポスターへ採用。旧V2一式は版名付きで保存。 |
| `OPT-001` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-002` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-003` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-004` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-005` | `Sources/OptionalArrayModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `OPT-006` | `OptionalArrayModule/OptionalArrayAudit.md` | 現行 |  |
| `OPT-007` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-008` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-009` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-010` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-011` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-012` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-013` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-014` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-015` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-016` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-017` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-018` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-019` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-020` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-021` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-022` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-023` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-024` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-025` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-026` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-027` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-028` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-029` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-030` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-031` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-032` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-033` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-034` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-035` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-036` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-037` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-038` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-09 |  |
| `OPT-039` | `Sources/OptionalArrayModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `OPT-040` | `Sources/OptionalArrayModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `OPT-041` | `Sources/OptionalArrayModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `OPT-042` | `Sources/OptionalArrayModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `OPT-043` | `Archived/Canonical/ARRAY_NAMING_REVIEW.md` / `Archived/Canonical/CHATGPT_ARRAY_NAMING_REVIEW_REQUEST.md` | 2026-10-11 |  |
| `OPT-044` | `OptionalArrayModule/OptionalArrayAudit.md` / `RELEASE_0_6_0.md` | 現行 |  |
| `OPT-045` | `OptionalArrayModule/OptionalArrayAudit.md` / `RELEASE_0_6_0.md` | 現行 |  |
| `OPT-046` | `OptionalArrayModule/OptionalArrayAudit.md` | 2026-10-11 |  |
| `OPT-047` | `OptionalArrayModule/CurrentQualityAssessment.md` / `Sources/OptionalArrayModule/Documentation/Quality-Profile.md` | 2026-10-12 |  |
| `OPT-048` | `OptionalArrayModule/CurrentQualityAssessment.md` / `StrictMemorySafetyReadiness.md` | 現行 |  |
| `OPT-049` | `OptionalArrayModule/CurrentQualityAssessment.md` | 2026-10-12 |  |
| `OPT-050` | `OptionalArrayModule/CurrentQualityAssessment.md` | 2026-10-12 |  |
| `OPT-051` | `OptionalArrayModule/CurrentQualityAssessment.md` | 2026-10-12 |  |
| `OPT-052` | `OptionalArrayModule/CurrentQualityAssessment.md` / `Sources/OptionalArrayModule/Documentation/Quality-Profile.md` | 現行 |  |
| `OPT-053` | `OptionalArrayModule/CurrentQualityAssessment.md` / `Sources/OptionalArrayModule/Documentation/Quality-Profile.md` | 現行 |  |
| `OPT-054` | `OptionalArrayModule/CurrentQualityAssessment.md` / `Sources/OptionalArrayModule/Documentation/Quality-Profile.md` | 現行 |  |
| `PERF-001` | `Archived/Canonical/PERFORMANCE_REGRESSION_BISECTION.md`<br>`Tests/TESTING.md` / `.github/workflows/ci.yml` / `.github/workflows/candidate.yml` | 2026-10-09<br>2026-10-12 | 表記差あり。変更理由またはID再利用を履歴確認する。 |
| `PERF-002` | `Tests/TESTING.md` / `BareArrayModule/CurrentQualityAssessment.md` / `OptionalArrayModule/CurrentQualityAssessment.md` | 2026-10-12 |  |
| `PERF-003` | `Tests/TESTING.md` / `.github/workflows/ci.yml` | 2026-10-12 |  |
| `PERF-004` | `PERFORMANCE_CI_CHANGE_GUIDE.md` / `Benchmarks/Libraries/CI.json` / `.github/workflows/ci.yml` | 現行 |  |
| `PERM-001` | `PermutationModule/AtCoder2025CompatibilityPlan.md` | 2026-10-09 |  |
| `PERM-002` | `PermutationModule/ImplementationPlan.md` | 2026-10-13 |  |
| `PERM-003` | `PermutationModule/AtCoder2025CompatibilityPlan.md` | 2026-10-09 |  |
| `PERM-004` | `PermutationModule/AtCoder2025CompatibilityPlan.md` | 2026-10-09 |  |
| `PERM-005` | `PermutationModule/AtCoder2025CompatibilityPlan.md` | 2026-10-09 |  |
| `PERM-006` | `PermutationModule/AtCoder2025CompatibilityPlan.md` | 2026-10-09 |  |
| `PERM-007` | `PermutationModule/AtCoder2025CompatibilityPlan.md` | 2026-10-09 |  |
| `PERM-008` | `PermutationModule/AtCoder2025CompatibilityPlan.md` | 2026-10-09 |  |
| `PERM-009` | `PermutationModule/AtCoder2025CompatibilityPlan.md` | 2026-10-09 |  |
| `PERM-010` | `PermutationModule/AtCoder2025CompatibilityPlan.md` | 2026-10-09 |  |
| `PERM-011` | `Tests/PermutationTests/NextPermutationsSequence/` | 2026-10-09 |  |
| `PERM-012` | `Tests/PermutationTests/NextPermutationsSequence/` | 2026-10-09 |  |
| `PERM-013` | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `PERM-014` | `PermutationModule/AtCoder2025CompatibilityPlan.md` | 2026-10-09 |  |
| `PERM-015` | `PermutationModule/AtCoder2025CompatibilityPlan.md` | 2026-10-09 |  |
| `PERM-016` | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `PERM-017` | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `PERM-018` | `Tests/PermutationTests/NextPermutationsSequence/` | 2026-10-09 |  |
| `PERM-019` | `Tests/PermutationTests/NextPermutationsSequence/` | 2026-10-09 |  |
| `PERM-020` | `PermutationModule/DocumentationHandoffAudit.md` | 2026-10-09 |  |
| `PERM-021` | `PermutationModule/DocumentationHandoffAudit.md` | 2026-10-09 |  |
| `PERM-022` | `PermutationModule/DocumentationHandoffAudit.md` | 2026-10-09 |  |
| `PERM-023` | `PermutationModule/DocumentationHandoffAudit.md` | 2026-10-09 |  |
| `PERM-024` | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `PERM-025` | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `PERM-026` | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `PERM-027` | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `PERM-028` | `Sources/PermutationModule/Documentation/Quality-Profile.md` / `Package.swift` | 2026-10-11 |  |
| `PERM-029` | `PermutationModule/AtCoder2025CompatibilityPlan.md`<br>`Sources/PermutationModule/Permutations.swift` / `Tests/PermutationTests/NextPermutationsSequence/NextPermutationsSequence_2_ValueSemanticsTests.swift` / `CLAUDE_TASK.md` / `CLAUDE_PENDING_TASKS.md` | 2026-10-09<br>2026-10-11 | 表記差あり。変更理由またはID再利用を履歴確認する。 |
| `PERM-030` | `PermutationModule/AtCoder2025CompatibilityPlan.md` | 2026-10-09 |  |
| `PERM-031` | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `PERM-032` | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `PERM-033` | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `PERM-034` | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `PERM-035` | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` | 2026-10-09 |  |
| `PERM-036` | `Archived/Canonical/PERFORMANCE_REGRESSION_BISECTION.md` | 2026-10-09 |  |
| `PERM-037` | `Archived/Canonical/PERFORMANCE_REGRESSION_BISECTION.md` | 2026-10-09 |  |
| `PERM-038` | `Archived/Canonical/PERFORMANCE_REGRESSION_ASSEMBLY_ANALYSIS.md` | 2026-10-09 |  |
| `PERM-039` | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` | 2026-10-11 |  |
| `PERM-040` | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` | 2026-10-11 |  |
| `PERM-041` | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` | 現行 |  |
| `PERM-042` | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` | 2026-10-11 |  |
| `PERM-043` | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` | 現行 |  |
| `PERM-044` | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` | 現行 |  |
| `PERM-045` | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` | 2026-10-11 |  |
| `PERM-046` | `PermutationModule/CurrentQualityAssessment.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` | 現行 |  |
| `PERM-047` | `PermutationModule/BorrowedPermutationTestPlan.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` | 2026-10-12 |  |
| `PERM-048` | `PermutationModule/CurrentQualityAssessment.md` / `PermutationModule/NextPermutationsImplementationExploration.md` / `Sources/PermutationModule/NextPermutations.swift` / `Sources/PermutationModule/BorrowedNextPermutations.swift` | 2026-10-12 |  |
| `PERM-049` | `PermutationModule/HumanAITuningReport.md` / `PermutationModule/CurrentQualityAssessment.md` / `Maintanance/User/PermutationBorrowedSpanExperiment.swift` | 2026-10-12 |  |
| `PERM-050` | `Sources/PermutationModule/BorrowedNextPermutations.swift` / `PermutationModule/NextPermutationsImplementationExploration.md` | 2026-10-12 |  |
| `PERM-051` | `Sources/PermutationModule/BorrowedNextPermutations.swift` / `Tests/PermutationTests/BorrowedNextPermutations/` / `Sources/PermutationModule/Documentation/Quality-Profile.md` | 現行 |  |
| `QUALITY-001` | `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` | 現行 |  |
| `QUALITY-002` | `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` / `Sources/PermutationModule/Documentation/Quality-Profile.md` / `CLAUDE_TASK.md`<br>`User/QUALITY_REQUIREMENTS.md` / `Tests/TESTING.md` / `.github/workflows/candidate.yml` | 2026-10-11<br>現行 | 表記差あり。変更理由またはID再利用を履歴確認する。 |
| `QUALITY-003` | `PermutationModule/CurrentQualityAssessment.md` / `User/QUALITY_REQUIREMENTS.md`<br>`User/QUALITY_REQUIREMENTS.md` / `Package.swift` | 2026-10-11<br>現行 | 表記差あり。変更理由またはID再利用を履歴確認する。 |
| `RBT-001` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 現行 |  |
| `RBT-002` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-003` | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` | 2026-10-09 |  |
| `RBT-004` | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` | 現行 |  |
| `RBT-005` | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` | 現行 |  |
| `RBT-006` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-007` | `StrictMemorySafetyReadiness.md` | 現行 |  |
| `RBT-008` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 現行 |  |
| `RBT-009` | `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md` | 現行 |  |
| `RBT-010` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 現行 |  |
| `RBT-011` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 現行 |  |
| `RBT-012` | `Tests/RedBlackTreeTests/` | 2026-10-09 |  |
| `RBT-013` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-014` | `Sources/RedBlackTreeCollections/Documentation/Head/DOCUMENTATION_WORKFLOW.md` | 現行 |  |
| `RBT-015` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-016` | `Tests/RedBlackTreeTests/` | 2026-10-09 |  |
| `RBT-017` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-018` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-019` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-020` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-021` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-022` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-023` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-024` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-025` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-026` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 現行 |  |
| `RBT-027` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-028` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-029` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-030` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-031` | `Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md` | 2026-10-09 |  |
| `RBT-032` | `RedBlackTreeModule/CurrentQualityAssessment.md` | 現行 |  |
| `RBT-033` | `RedBlackTreeModule/CurrentQualityAssessment.md` / `Package.swift` | 現行 |  |
| `RBT-034` | `RedBlackTreeModule/CurrentQualityAssessment.md` / `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md` | 現行 |  |
| `RELEASE-001` | `Archived/Canonical/RELEASE_0_5_0.md` | 2026-10-09 |  |
| `RELEASE-002` | `Archived/Canonical/RELEASE_0_5_0.md` | 2026-10-09 |  |
| `RELEASE-003` | `Archived/Canonical/RELEASE_0_5_0.md` | 2026-10-09 |  |
| `RELEASE-004` | `Archived/Canonical/RELEASE_0_5_0.md` | 2026-10-09 |  |
| `RELEASE-005` | `Archived/Canonical/RELEASE_0_5_1.md` | 2026-10-11 |  |
| `RELEASE-006` | `Archived/Canonical/RELEASE_0_5_2.md` | 2026-10-11 |  |
| `RELEASE-007` | `RELEASE_0_6_0.md` | 現行 |  |
| `RELEASE-008` | `Archived/Canonical/RELEASE_0_5_1.md` / `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-009` | `Archived/RELEASE_CHECKLIST.md` / `Archived/Canonical/RELEASE_0_5_1.md` / `User/RELEASE_PROCESS.md` | 2026-10-13 |  |
| `RELEASE-010` | `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-011` | `Archived/RELEASE_TEMPLATE_BRANCH_DESIGN.md` / `Archived/RELEASE_CHECKLIST.md` | 2026-10-13 |  |
| `RELEASE-012` | `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-013` | `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-014` | `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-015` | `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-016` | `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-017` | `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-018` | `Archived/RELEASE_TEMPLATE_BRANCH_DESIGN.md` | 2026-10-11 |  |
| `RELEASE-019` | `Archived/RELEASE_TEMPLATE_BRANCH_DESIGN.md` | 2026-10-11 |  |
| `RELEASE-020` | `RELEASE_0_6_0.md` | 現行 |  |
| `RELEASE-021` | `Archived/Canonical/RELEASE_0_5_2.md` / `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-022` | `Archived/Canonical/RELEASE_0_5_2.md` / `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-023` | `Archived/Canonical/RELEASE_0_5_2.md` / `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-024` | `Archived/Canonical/RELEASE_0_5_2.md` / `Archived/Canonical/RELEASE_0_5_1.md` | 2026-10-11 |  |
| `RELEASE-025` | `Archived/Canonical/RELEASE_0_5_2.md` / `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-026` | `Archived/Canonical/RELEASE_0_5_2.md` / `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-027` | `Archived/Canonical/RELEASE_0_5_2.md` / `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-028` | `Archived/Canonical/RELEASE_0_5_2.md` / `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-029` | `Archived/Canonical/RELEASE_0_5_2.md` / `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-030` | `Archived/Canonical/RELEASE_0_5_2.md` / `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-031` | `Archived/RELEASE_TASK_REGISTRY_DESIGN.md` / `Archived/RELEASE_TASK_REGISTRY_TEMPLATE.md` / `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-032` | `Archived/Canonical/RELEASE_0_5_2.md` / `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-033` | `Archived/Canonical/RELEASE_0_5_2.md` / `Archived/RELEASE_CHECKLIST.md` | 2026-10-11 |  |
| `RELEASE-034` | `Archived/Canonical/RELEASE_0_5_3.md` | 2026-10-11 |  |
| `RELEASE-035` | `Archived/RELEASE_TASK_REGISTRY_TEMPLATE.md` / `Archived/RELEASE_TASK_REGISTRY_DESIGN.md` / `Archived/RELEASE_CHECKLIST.md` | 2026-10-13 |  |
| `RELEASE-036` | `Archived/RELEASE_TASK_REGISTRY_DESIGN.md` / `Archived/RELEASE_TASK_REGISTRY_TEMPLATE.md` | 2026-10-13 |  |
| `RELEASE-069` | `README.ja.md` | 2026-10-11 |  |
| `RELEASE-070` | `Archived/Canonical/RELEASE_0_5_3.md` | 2026-10-11 |  |
| `RELEASE-071` | `Archived/RELEASE_TASK_REGISTRY_TEMPLATE.md` / `Archived/RELEASE_TASK_REGISTRY_REHEARSAL_TEMPLATE.md` / `Archived/RELEASE_TASK_REGISTRY_DESIGN.md` / `Archived/Canonical/RELEASE_0_5_3.md` | 2026-10-11 |  |
| `RELEASE-072` | `User/RELEASE_PROCESS.md` | 現行 |  |
| `RELEASE-073` | `User/CONCEPT_DEFINITION.md` | 2026-10-11 |  |
| `RELEASE-074` | `User/CONCEPT_DEFINITION.md` / `User/Archived/QUALITY_REQUIREMENTS_CODEX_V2.md` / `User/Archived/QUALITY_REQUIREMENTS_CLAUDE_V2.md` | 2026-10-11 |  |
| `RELEASE-075` | `User/RELEASE_PROCESS.md` | 現行 |  |
| `RELEASE-076` | `User/RELEASE_PROCESS.md` | 現行 |  |
| `RELEASE-077` | `User/QUALITY_REQUIREMENTS.md` / `User/QUALITY_REQUIREMENTS_REFERENCE.md` / `User/Archived/QUALITY_REQUIREMENTS_CLAUDE_V2.md` / `CLAUDE_TASK.md` | 2026-10-11 |  |
| `TEST-001` | `Tests/TESTING.md` | 2026-10-09 |  |
| `TEST-002` | `Tests/TESTING.md` | 2026-10-09 |  |
| `TEST-003` | `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md` | 2026-10-09 |  |
| `TEST-004` | `Tests/TESTING.md` | 2026-10-09 |  |

## この表から分かること

- Registryまたは完了アーカイブに残るtask IDと、そこで指定された詳細正本。
- 同じtask IDについて、保存先ごとに詳細正本表記が一致しているか。
- 正本の移動、分割、統合、またはID再利用の可能性を追加調査すべき箇所。

## この表だけでは分からないこと

- Registryから削除され、完了アーカイブにも残らなかったtask。
- Git履歴上の初出時に指定されていた正本。
- 表記変更が正当な移動・分割だったか、誤更新だったか。
- 指定されたファイルが各snapshot時点で存在し、taskの受入境界を実際に保持していたか。

これらは`TASK_REGISTRY_STATE_HISTORY.md`と同じ基準commitまでGit履歴を追い、初出commit、
正本表記の変更commit、基準点の表記を追加して確認する。
