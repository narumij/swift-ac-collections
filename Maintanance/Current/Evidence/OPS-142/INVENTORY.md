# OPS-142 正本候補の入口棚卸し

## TL;DR（人間向け）

現行Registryと過去のRegistry・正本対応表から、行ごとの詳細正本を抽出し、明示された旧Canonical目録と移動案内だけを補った。Historyの本文は一切読まず対象外とした。`inventory.json` の `eligible_current` と `eligible_archived` が次の説明本文翻訳候補のパス配列で、制度・本人の声・原文返却・製品向け文書などは別区分へ分けた。

曖昧な旧パス・同名ファイルの移動同一性・統合資料の原文境界は未判定で残す。Archived配下にあるだけでは正本にせず、対象外ファイルを無差別に読み進めていない。本作業は棚卸しだけで、翻訳・正本採用・状態変更・commitはしていない。

## 今回の範囲

2026-10-19 / Sol。読取基準HEAD：`372f4650cd8885e934d0b10b59790fea0fa8e87b`。未commitの現行資料も含むため、各入口はJSONのSHA-256で識別する。現在のOPS-142詳細正本と親Astraの「入口がある正本のみ、曖昧は未判定、追加深掘りしない」に従いここで区切る。

| 区分 | 件数 |
| --- | ---: |
| entry_points | 32 |
| parsed_task_rows | 1163 |
| resolved_records | 410 |
| eligible_current | 123 |
| eligible_archived | 32 |
| pending_candidates | 37 |
| unresolved_reference_occurrences | 215 |
| unresolved_raw_paths | 35 |

候補配列は「説明部分を翻訳する根拠がある入口」の抽出で、全文編集許可や翻訳の要否を確定するものではない。実行前には本文を読み、担当占有・原文保存・対象段落を確認する。日本語TL;DR・カード、Return/引用原文、リンク先・参照アンカーは保持する。`eligible_archived` はArchived・_Archived・保存品質一周分の配置を指す。現行配置のまま過去taskから参照される詳細も現行配列へ含むが、状態や効力を現行へ復活させない。

## 入口ごとの探索境界

| 入口 | 扱った範囲 | task行数 |
| --- | --- | ---: |
| `Maintanance/ProgressV2/TASK_REGISTRY_V2.md` | task row detailed-canonical column only | 125 |
| `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-07.md` | task row detailed-canonical column only | 39 |
| `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-09.md` | task row detailed-canonical column only | 162 |
| `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-11.md` | task row detailed-canonical column only | 80 |
| `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-12.md` | task row detailed-canonical column only | 40 |
| `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-13.md` | task row detailed-canonical column only | 70 |
| `Maintanance/Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-14.md` | task row detailed-canonical column only | 10 |
| `Maintanance/Archived/PROGRESS_OVERVIEW_RETIRED_2026-10-15.md` | task row detailed-canonical column only | 51 |
| `Maintanance/Archived/TASK_REGISTRY_AFTER_USER_RECLASSIFICATION_2026-10-16.md` | task row detailed-canonical column only | 6 |
| `Maintanance/Archived/TASK_REGISTRY_ARCHIVED_2026-10-15.md` | task row detailed-canonical column only | 20 |
| `Maintanance/Archived/TASK_REGISTRY_ARCHIVED_2026-10-15_2.md` | task row detailed-canonical column only | 12 |
| `Maintanance/Archived/TASK_REGISTRY_ARCHIVED_2026-10-16.md` | task row detailed-canonical column only | 8 |
| `Maintanance/Archived/TASK_REGISTRY_ARCHIVED_2026-10-16_QUALITY_ROUND.md` | task row detailed-canonical column only | 6 |
| `Maintanance/Archived/TASK_REGISTRY_BEFORE_RECOVERY_CLEANUP_2026-10-16.md` | task row detailed-canonical column only | 56 |
| `Maintanance/Archived/TASK_REGISTRY_BEFORE_RELEASE_CLEANUP_2026-10-16.md` | task row detailed-canonical column only | 55 |
| `Maintanance/Archived/TASK_REGISTRY_COMPLETED_AFTER_RECONCILIATION_2026-10-16.md` | task row detailed-canonical column only | 10 |
| `Maintanance/Archived/TASK_REGISTRY_COMPLETED_DOCUMENT_GATES_2026-10-16.md` | task row detailed-canonical column only | 54 |
| `Maintanance/Archived/TASK_REGISTRY_COMPLETED_VIEWER_2026-10-16.md` | task row detailed-canonical column only | 6 |
| `Maintanance/Archived/FROZEN_TASKS_BEFORE_RECONCILIATION_2026-10-16.md` | task row detailed-canonical column only | 27 |
| `Maintanance/Archived/TaskInventory/TASK_CANONICAL_DOCUMENT_MAP.md` | observed detailed canonical column only | 326 |
| `Maintanance/Current/README.md` | one-level catalogue links; not transitive prose links | — |
| `Maintanance/Quality/README.md` | one-level catalogue links; not transitive prose links | — |
| `Maintanance/Archived/PermutationMigration_2026-10-16/README.md` | one-level catalogue links; not transitive prose links | — |
| `Maintanance/Milestones/_Archived/README.md` | one-level catalogue links; not transitive prose links | — |
| `Maintanance/Milestones/_Archived/RELEASE_0_5_4_HISTORY.md` | source filename markers only; historical originals retained | — |
| `Maintanance/Milestones/_Archived/DOCUMENT_MIGRATION_HISTORY.md` | source filename markers only; historical originals retained | — |
| `Maintanance/Milestones/_Archived/FUTURE_PLAN_HISTORY.md` | source filename markers only; historical originals retained | — |
| `Maintanance/Current/Evidence/OPS-140/current.json` | previous summary rollout manifest; not automatic editing permission | — |
| `Maintanance/Current/Evidence/OPS-140/existing.json` | previous summary rollout manifest; not automatic editing permission | — |
| `Maintanance/Current/Evidence/OPS-140/reserved.json` | previous summary rollout manifest; not automatic editing permission | — |
| `Maintanance/Archived/README.md` | Canonical節が旧正本と明示する直下17Markdownのみ。全Archivedの正本宣言には使わない | — |
| `Maintanance/Archived/Reviews/README.md` | 明記されたBARE-046のレビュー正本1件 | — |

Registryはtask行の詳細正本列だけを抽出し、本文中のリンクを再帰追跡していない。文書マップはsnapshot当時の表記であり、正本採用・移動の正当性は証明しない。旧パスは実在パス、目録で明示された保存先、一意同名候補を分け、一意同名だけの候補は翻訳配列へ入れていない。Git全履歴は探索していない。

## 役割による別区分

| 区分 | 件数 |
| --- | ---: |
| 実装等の非Markdown (`non_markdown_reference`) | 19 |
| ユーザー所有・上位保護 (`protected_user_document`) | 11 |
| 本人感想・インタビュー・個別回答 (`personal_or_attributed_record`) | 47 |
| 詳細説明の正本候補 (`canonical_prose_candidate`) | 189 |
| 原文返却・固定入力・証拠 (`preserved_return_or_evidence`) | 43 |
| 制度・手順・Registry (`governing_or_workflow_document`) | 59 |
| 目録・旧手順候補 (`catalogue_or_governance_review`) | 16 |
| 担当キャッシュ・依頼票 (`owner_or_handoff_document`) | 3 |
| 占有待ち (`occupied_wait`) | 2 |
| History対象外 (`history_excluded`) | 4 |
| 統合旧正本・原文境界未分割 (`mixed_canonical_original_boundary`) | 3 |
| 製品向け文書 (`product_facing_document`) | 14 |

各パスの根拠はJSON `records[].provenance` に、元入口・行番号・task ID・原表記を保存した。除外・別扱いの理由は `excluded_or_separate` と各recordのreasonにある。元task行の状態は履歴としての出典であり、現在の着手許可には使わない。

## 翻訳候補

### 現行配置にある入口付き説明本文候補


- `Maintanance/Current/AI_COLLABORATION_BASIC_RESEARCH.md`
- `Maintanance/Current/AI_RESEARCH_FIRST_EXPERIMENT.md`
- `Maintanance/Current/AI_RESEARCH_FIRST_EXPERIMENT_PREPARATION.md`
- `Maintanance/Current/APPROVAL_PROBE.md`
- `Maintanance/Current/ASAN_DEATH_TEST_INVESTIGATION.md`
- `Maintanance/Current/ASAN_STRIP_ENV_FIXED_REVISION_VALIDATION.md`
- `Maintanance/Current/ASTRA_DECISION_TRACE_SUPPORT.md`
- `Maintanance/Current/BRANCH_NAMING_DISCUSSION.md`
- `Maintanance/Current/CACHE_REFERENCE_OBSERVATION_PILOT.md`
- `Maintanance/Current/CACHE_SECOND_ITEM_PILOT.md`
- `Maintanance/Current/CANONICAL_CONFIRMED_SCOPE_SUMMARY.md`
- `Maintanance/Current/CANONICAL_EVIDENCE_ROLLOUT.md`
- `Maintanance/Current/CANONICAL_HUMAN_SUMMARY_ROLLOUT.md`
- `Maintanance/Current/CANONICAL_INVENTORY_APPEND.md`
- `Maintanance/Current/CANONICAL_LANGUAGE_MIGRATION.md`
- `Maintanance/Current/CLAUDE_ACTIVITY_RULE_REVIEW.md`
- `Maintanance/Current/CLAUDE_QUEUE_RECONCILIATION_2026-10-16.md`
- `Maintanance/Current/CLAUDE_STARTUP_DOCUMENT_REVIEW.md`
- `Maintanance/Current/COORDINATOR_AUTHORITY_CONSOLIDATION_DECISION.md`
- `Maintanance/Current/DECISION_ARCHIVE_PILOT.md`
- `Maintanance/Current/DECISION_ARCHIVE_PROPOSAL.md`
- `Maintanance/Current/Frozen/LAZY_INITIALIZATION_FREEZE_DECISION.md`
- `Maintanance/Current/HEADLESS_BROWSER_AVAILABILITY.md`
- `Maintanance/Current/HIME_TRADE_NAME_DECISION.md`
- `Maintanance/Current/HIST_002_EXPLORATION.md`
- `Maintanance/Current/HUMAN_CANONICAL_SUMMARIES.md`
- `Maintanance/Current/INDEX_UPDATE_FAILURE_COW_INVESTIGATION.md`
- `Maintanance/Current/INDEX_UPDATE_FAILURE_COW_USER_DECISION.md`
- `Maintanance/Current/JUDGMENT_CACHE_LRU_ADVICE.md`
- `Maintanance/Current/JUDGMENT_CACHE_LRU_PROPOSAL.md`
- `Maintanance/Current/JUDGMENT_COORDINATES_REVISION_RECEIPT.md`
- `Maintanance/Current/JUDGMENT_ORIGIN_CLASSIFICATION_PILOT.md`
- `Maintanance/Current/MAINTENANCE_HEALTH_CHECK_2026-10-16.md`
- `Maintanance/Current/MAINTENANCE_STABILITY_USER_DECISION.md`
- `Maintanance/Current/MAPPED_VALUES_VIEW_CONTRACT_DECISION.md`
- `Maintanance/Current/MEMOIZE_DEPENDENCY_INVESTIGATION.md`
- `Maintanance/Current/MILESTONE_HEALTH_AUDIT_2026-10-17.md`
- `Maintanance/Current/MILESTONE_MIGRATION_ACCEPTANCE_2026-10-17.md`
- `Maintanance/Current/OPS_072_ACCEPTANCE.md`
- `Maintanance/Current/PERMUTATION_BENCHMARK_TITLE_MIGRATION.md`
- `Maintanance/Current/PERMUTATION_MODULE_MIGRATION_PLAN.md`
- `Maintanance/Current/PERMUTATION_PERFORMANCE_GAP_REVIEW.md`
- `Maintanance/Current/PERMUTATION_SEQUENCE_ADAPTER_DECISION.md`
- `Maintanance/Current/PERMUTATION_SEQUENCE_INVALID_VIEW_ISSUE.md`
- `Maintanance/Current/PLACEMENT_EXCEPTION_SIMPLIFICATION_REVIEW.md`
- `Maintanance/Current/PROVISIONAL_AGREEMENT_JUDGMENT_INVENTORY_PILOT.md`
- `Maintanance/Current/PROVISIONAL_JUDGMENT_STUDY.md`
- `Maintanance/Current/PROVISIONAL_TASK_AGREEMENT_STUDY.md`
- `Maintanance/Current/PUBLIC_DOCUMENTATION_INITIAL_EDITION_CHECK.md`
- `Maintanance/Current/RECORD_LIFETIME_STUDY.md`
- `Maintanance/Current/RED_BLACK_TREE_DOCC_PREVIEW_REVIEW.md`
- `Maintanance/Current/RED_BLACK_TREE_DOCUMENT_COMPLETION.md`
- `Maintanance/Current/RED_BLACK_TREE_DOCUMENT_REVIEW_ACCEPTANCE.md`
- `Maintanance/Current/RED_BLACK_TREE_DOCUMENT_REVIEW_REQUEST.md`
- `Maintanance/Current/RED_BLACK_TREE_TUNING_RESEARCH_DECISION.md`
- `Maintanance/Current/REGISTRY_STUDIO_ACTIVITY_TIMELINE.md`
- `Maintanance/Current/REGISTRY_STUDIO_CARD_LIST.md`
- `Maintanance/Current/REGISTRY_STUDIO_COMPACT_ACTIVITY.md`
- `Maintanance/Current/REGISTRY_STUDIO_DISPLAY_PARTITION_TEST.md`
- `Maintanance/Current/REGISTRY_STUDIO_JUDGMENT_CACHE_REFRESH.md`
- `Maintanance/Current/REGISTRY_STUDIO_LAYOUT_CACHE_REFRESH.md`
- `Maintanance/Current/REGISTRY_STUDIO_LAYOUT_FALLBACK_REPAIR.md`
- `Maintanance/Current/REGISTRY_STUDIO_MILESTONE_BRANCH_LAYOUT.md`
- `Maintanance/Current/REGISTRY_STUDIO_MILESTONE_CONNECT.md`
- `Maintanance/Current/REGISTRY_STUDIO_MILESTONE_DIRECTION_UI.md`
- `Maintanance/Current/REGISTRY_STUDIO_MILESTONE_EDITOR.md`
- `Maintanance/Current/REGISTRY_STUDIO_MULTIPLE_MILESTONES.md`
- `Maintanance/Current/REGISTRY_STUDIO_NEIGHBOR_CARDS.md`
- `Maintanance/Current/REGISTRY_STUDIO_NEIGHBOR_SELECTION_FIX.md`
- `Maintanance/Current/REGISTRY_STUDIO_NEW_TASK_PROPOSALS.md`
- `Maintanance/Current/REGISTRY_STUDIO_NODE_NEIGHBORHOOD.md`
- `Maintanance/Current/REGISTRY_STUDIO_SAVE_CONTRACT.md`
- `Maintanance/Current/REGISTRY_STUDIO_SAVE_USABILITY.md`
- `Maintanance/Current/REGISTRY_STUDIO_SERVER_SAVE.md`
- `Maintanance/Current/REGISTRY_STUDIO_SINGLE_LINE_KIND.md`
- `Maintanance/Current/REGISTRY_STUDIO_SYNC.md`
- `Maintanance/Current/REGISTRY_STUDIO_TASK_PLACEMENT_FIX.md`
- `Maintanance/Current/REGISTRY_STUDIO_TERMINAL_BRANCH_LAYOUT.md`
- `Maintanance/Current/REGISTRY_STUDIO_UNNUMBERED_CARDS.md`
- `Maintanance/Current/REGISTRY_STUDIO_USABILITY_DECISION.md`
- `Maintanance/Current/REGISTRY_STUDIO_VERIFY_FIXTURE_COUPLING.md`
- `Maintanance/Current/REGISTRY_STUDIO_VERSION_START.md`
- `Maintanance/Current/REGISTRY_STUDIO_WORK_PROGRESS.md`
- `Maintanance/Current/RELEASE_CANDIDATE_BASELINE_FIX.md`
- `Maintanance/Current/RELEASE_CANDIDATE_BASELINE_INVESTIGATION.md`
- `Maintanance/Current/RELEASE_CANDIDATE_COMMENT_CI.md`
- `Maintanance/Current/RELEASE_CI_RECOVERY.md`
- `Maintanance/Current/RESEARCH_STATUS_DOCUMENT_CORRECTION.md`
- `Maintanance/Current/SOL_OJT_DOCUMENT_CORRECTION.md`
- `Maintanance/Current/SOL_OJT_PILOT_USER_DECISION.md`
- `Maintanance/Current/SOL_OJT_WARMUP.md`
- `Maintanance/Current/SPI_REGISTRATION_GATE.md`
- `Maintanance/Current/STUDIO_ACTIVITY_OWNER.md`
- `Maintanance/Current/STUDIO_APPROVAL_SIGNALS.md`
- `Maintanance/Current/STUDIO_CONSIDERATION_EVENT.md`
- `Maintanance/Current/STUDIO_CONTINUITY_STATUS.md`
- `Maintanance/Current/STUDIO_HANDOFF_SIGNALS.md`
- `Maintanance/Current/STUDIO_HEADER_APPROVAL.md`
- `Maintanance/Current/STUDIO_HEADER_MENU.md`
- `Maintanance/Current/STUDIO_OPERATION_REVIEW.md`
- `Maintanance/Current/STUDIO_READING_SMALL_FIXES.md`
- `Maintanance/Current/STUDIO_RECENT_WORK_LANE.md`
- `Maintanance/Current/STUDIO_SERVER_REFACTOR.md`
- `Maintanance/Current/STUDIO_UI_ROUND2.md`
- `Maintanance/Current/STUDIO_USABILITY_ROLLOUT.md`
- `Maintanance/Current/STUDIO_WORK_CONTROLS.md`
- `Maintanance/Current/STUDIO_WORK_LANE_PROPOSAL.md`
- `Maintanance/Current/TASK_REGISTRY_APP.md`
- `Maintanance/Current/TASK_REGISTRY_APP_DISCOVERY.md`
- `Maintanance/Current/TASK_REGISTRY_APP_PROTOTYPE.md`
- `Maintanance/Current/TASK_REGISTRY_LAYOUT_ADVICE.md`
- `Maintanance/Graph/AI_GRAPH_IN_MEMORY_FIXTURE.md`
- `Maintanance/Graph/AI_GRAPH_RETROSPECTIVE_REPLAY.md`
- `Maintanance/Graph/AI_GRAPH_SHARED_SCHEMA.md`
- `Maintanance/Graph/TASK_GRAPH_DB_EXPERIMENT.md`
- `Maintanance/Graph/TASK_GRAPH_LINT.md`
- `Maintanance/MILESTONES.md`
- `Maintanance/Milestones/0.6.1/10_SPI.md`
- `Maintanance/Milestones/0.6.1/GATE-0.7.0.md`
- `Maintanance/Milestones/0.7.0/10_VALIDATION_REVIEW.md`
- `Maintanance/Milestones/0.7.0/GATE-0.8.0.md`
- `Maintanance/Quality/Profiles/RedBlackTreeCollections.md`
- `Maintanance/Testing/Fixtures.md`

### 旧正本・保存済み正本の説明本文候補


- `Maintanance/Archived/Canonical/ARRAY_NAMING_REVIEW.md`
- `Maintanance/Archived/Canonical/CHATGPT_ARRAY_NAMING_REVIEW_REQUEST.md`
- `Maintanance/Archived/Canonical/CODE_SNIPPET_SURVEY.md`
- `Maintanance/Archived/Canonical/NON_RBT_COMMENT_DOC_SELF_REVIEW.md`
- `Maintanance/Archived/Canonical/PERFORMANCE_REGRESSION_ASSEMBLY_ANALYSIS.md`
- `Maintanance/Archived/Canonical/PERFORMANCE_REGRESSION_BISECTION.md`
- `Maintanance/Archived/Canonical/PUBLIC_API_CODE_SNIPPET_SURVEY_2.md`
- `Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md`
- `Maintanance/Archived/Canonical/RELEASE_0_5_0.md`
- `Maintanance/Archived/Canonical/RELEASE_0_5_1.md`
- `Maintanance/Archived/Canonical/RELEASE_0_5_2.md`
- `Maintanance/Archived/Canonical/RELEASE_0_5_3.md`
- `Maintanance/Archived/PERMUTATION_PUBLIC_API_NAMING_REVIEW_2026-10-16.md`
- `Maintanance/Archived/PublicAPINaming/PUBLIC_API_NAMING_ROUND2_REPORT.md`
- `Maintanance/Archived/PublicAPINaming/PUBLIC_API_NAMING_ROUND3_REPORT.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_FINAL_PROPOSAL.md`
- `Maintanance/Archived/QUALITY-004_EXCLUDED_2026-10-16.md`
- `Maintanance/Archived/Reviews/ELEMENTBUFFER_TEST_AS_SPEC_REVIEW.md`
- `Maintanance/Archived/SORTED_COLLECTIONS_BENCHMARK_TASK.md`
- `Maintanance/Quality/0.6.0-1/ElementBufferModule/CurrentQualityAssessment.md`
- `Maintanance/Quality/0.6.0-1/ElementBufferModule/ElementBufferAudit.md`
- `Maintanance/Quality/0.6.0-1/ElementBufferModule/GeneralSwiftValidationScenario.md`
- `Maintanance/Quality/0.6.0-1/OptionalElementBufferModule/CurrentQualityAssessment.md`
- `Maintanance/Quality/0.6.0-1/OptionalElementBufferModule/GeneralSwiftValidationScenario.md`
- `Maintanance/Quality/0.6.0-1/OptionalElementBufferModule/OptionalElementBufferAudit.md`
- `Maintanance/Quality/0.6.0-1/PermutationModule/BorrowedPermutationTestPlan.md`
- `Maintanance/Quality/0.6.0-1/PermutationModule/CurrentQualityAssessment.md`
- `Maintanance/Quality/0.6.0-1/PermutationModule/DocumentationHandoffAudit.md`
- `Maintanance/Quality/0.6.0-1/PermutationModule/GeneralSwiftValidationScenario.md`
- `Maintanance/Quality/0.6.0-1/PermutationModule/RuntimeCheckedPermutationTestPlan.md`
- `Maintanance/Quality/0.6.0-1/QUALITY_ASSESSMENT_INVENTORY.md`
- `Maintanance/Quality/0.6.0-1/RedBlackTreeModule/CurrentQualityAssessment.md`

## 未判定と止めた範囲

### パスまたは正本の役割・原文境界を確定していない候補


- `Maintanance/Archived/ArrayModuleMigration/ARRAY_MODULE_COMPATIBILITY_TARGET_RETIREMENT.md`
- `Maintanance/Archived/ArrayModuleMigration/ARRAY_MODULE_TARGET_MIGRATION.md`
- `Maintanance/Archived/ArrayModuleMigration/ARRAY_MODULE_TARGET_MIGRATION_EXECUTION.md`
- `Maintanance/Archived/ArrayModuleMigration/ArrayObjectAndAPINamingDraft.md`
- `Maintanance/Archived/MAINTENANCE_ROOT_ARCHIVE_AUDIT_2026-10-09.md`
- `Maintanance/Archived/PermutationImplementation_2026-10-16/ImplementationPlan.md`
- `Maintanance/Archived/PermutationMigration_2026-10-16/PERMUTATION_MIGRATION_INVESTIGATION_ACCEPTANCE.md`
- `Maintanance/Archived/PermutationMigration_2026-10-16/PERMUTATION_MODULE_MIGRATION_ACCEPTANCE.md`
- `Maintanance/Archived/PermutationMigration_2026-10-16/PERMUTATION_MODULE_MIGRATION_IMPLEMENTATION.md`
- `Maintanance/Current/AI_TECHNICAL_ORIENTATION.md`
- `Maintanance/Current/AtCoder2025CompatibilityPlan.md`
- `Maintanance/Current/BENCHMARK_TASK_NAME_MIGRATION.md`
- `Maintanance/Current/BENCHMARK_USAGE_GUIDE.md`
- `Maintanance/Current/DOCUMENTATION_CI_PLAN.md`
- `Maintanance/Current/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Maintanance/Current/PERFORMANCE_CI_CHANGE_GUIDE.md`
- `Maintanance/Current/PUBLIC_API_NAMING_DECISIONS.md`
- `Maintanance/Current/RED_BLACK_TREE_BALANCED_DESIGN_INTENT.md`
- `Maintanance/Current/RED_BLACK_TREE_COMPARISON_DECLARATIONS_CONTEXT.md`
- `Maintanance/Current/StrictMemorySafetyReadiness.md`
- `Maintanance/Milestones/HEAD.md`
- `Maintanance/Milestones/_Archived/DOCUMENT_MIGRATION_HISTORY.md`
- `Maintanance/Milestones/_Archived/FUTURE_PLAN_HISTORY.md`
- `Maintanance/Milestones/_Archived/RELEASE_0_5_4_HISTORY.md`
- `Maintanance/Quality/0.6.0-1/OPTIONAL_ELEMENTBUFFER_TEST_AS_SPEC_REVIEW.md`
- `Maintanance/Quality/0.6.0-1/PERMUTATION_TEST_AS_SPEC_CLAUDE_DRAFT.md`
- `Maintanance/Quality/0.6.0-1/PERMUTATION_TEST_AS_SPEC_REVIEW.md`
- `Maintanance/Quality/0.6.0-1/PermutationModule/ProductReadinessAssessment.md`
- `Maintanance/Quality/0.6.0-1/RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md`
- `Maintanance/Quality/Profiles/ElementBufferModule.md`
- `Maintanance/Quality/Profiles/NextPermutationModule.md`
- `Maintanance/Quality/Profiles/OptionalElementBufferModule.md`
- `Maintanance/Quality/QUALITY_REQUIREMENTS.md`
- `Maintanance/Quality/QUALITY_REQUIREMENTS_REFERENCE.md`
- `Maintanance/Technical/HumanAITuningReport.md`
- `Maintanance/Technical/NextPermutationsImplementationExploration.md`
- `Maintanance/Technical/NextPermutationsSequenceExperiment.md`

### 解決しなかった旧表記

同じ旧表記の反復はJSONに全出現を残し、ここでは一つへまとめる。非MarkdownやHistory由来は翻訳対象へ追跡しない。


- `AI_GRAPH_REFACTORING_SMELL_NOTES.md`
- `CollaborationBootstrap/README.md`
- `ElementBufferModule/UserDocumentationDraft.md`
- `Maintanance/Current/RED_BLACK_TREE_COMPARISON_USER_DECISION.md`
- `Maintanance/ElementBufferModule/UserDocumentationDraft.md`
- `Maintanance/OptionalElementBufferModule/UserDocumentationDraft.md`
- `Maintanance/PermutationModule/UserDocumentationDraft.md`
- `Maintanance/User/PermutationBorrowedSpanExperiment.swift`
- `OptionalElementBufferModule/UserDocumentationDraft.md`
- `Orientation/CODEX_TASK_OPERATION_PLAYBOOK.md`
- `PermutationModule/UserDocumentationDraft.md`
- `REFACTORING_FROM_ATCODER_2025.md`
- `RefactoringFromAtCoder2025/EVIDENCE.md`
- `RefactoringFromAtCoder2025/README.md`
- `Sources/BareArrayModule/BareArray.swift`
- `Sources/BareArrayModule/Documentation/Quality-Profile.md`
- `Sources/BareArrayModule/ElementBuffer.swift`
- `Sources/ElementBufferModule/Documentation/Quality-Profile.md`
- `Sources/OptionalArrayModule/Documentation/Quality-Profile.md`
- `Sources/OptionalArrayModule/Documentation/QualityAssessment-ISO25010.md`
- `Sources/OptionalArrayModule/OptionalElementBuffer.swift`
- `Sources/OptionalElementBufferModule/Documentation/Quality-Profile.md`
- `Sources/OptionalElementBufferModule/Documentation/QualityAssessment-ISO25010.md`
- `Sources/PermutationModule/BorrowedNextPermutations.swift`
- `Sources/PermutationModule/Compatibility/AtCoder2025/PermutationsAtCoder2025.swift`
- `Sources/PermutationModule/Documentation/Quality-Profile.md`
- `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md`
- `Sources/PermutationModule/NextPermutations.swift`
- `Sources/PermutationModule/Permutations.swift`
- `Sources/RedBlackTreeCollections/Documentation/Quality-Checklist.md`
- `Sources/RedBlackTreeCollections/Documentation/Quality-Profile.md`
- `Tests/BareArrayModuleTests/BareArray_6_CoordinateValueAccessTests.swift`
- `Tests/BareArrayModuleTests/BareArray_7_BorrowedReferenceTests.swift`
- `Tests/BareArrayModuleTests/BareArray_97_CoordinateValueAccessDeathTests.swift`
- `User/PermutationBorrowedSpanExperiment.swift`

### Archivedの未接続ファイル

filenameだけの照合で、Archived Markdown 239件中、入口から解決できたものは151件、未接続は88件。未接続パス全件をJSON `archived_filename_coverage.unclassified_paths` に保持した。ポスター・旧草案・個別採点・断片snapshot等を含むが、今回の入口から詳細正本として結べないので、その存在だけでは対象に追加しない。旧正本全件の完全性をGit全履歴に対して証明したという意味ではない。追加調査をするなら、未判定の特定入口だけを次の限定範囲にする。

## 一時作業物:

作成Sol・2026-10-19：`/private/tmp/ops142-inventory.py`（入口抽出）、`/private/tmp/ops142-inventory-result.json`（中間台帳）、`/private/tmp/ops142-finalize.py`（出力）。実体はいずれも記載どおり、専用個別ファイル。状態：継続保持。用途：OPS-142読取棚卸しの再確認。保持条件：Astraがこの台帳を受け入れるまで。必要な成果・出典・除外理由は本書とinventory.jsonへ保存する。原文控えや翻訳用snapshotはまだ作っていない。
