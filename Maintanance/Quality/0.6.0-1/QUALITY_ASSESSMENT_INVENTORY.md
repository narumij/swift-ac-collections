# 品質評価棚卸し

## TL;DR（人間向け）
本書は2026-10-15時点の四対象に関する初期品質棚卸しであり、評価の不整合、証拠不足、task対応を整理した記録である。2026-10-16のユーザー判断により継続更新は除外され、本文の一部は後発判断を反映していない。

本書内の誤りが指摘された主張や古いtask状態を、現行の製品判断・品質評価の根拠にしてはならない。特にunsafe枝についての誤った除外記述を現行判断として使わず、最新の品質正本と証拠を確認する。

At the user's request on 2026-10-15, the findings from identifying quality issues across four subjects were collected here, making this the detailed source for the quality-assessment inventory task.

## 今回の記録として保持（2026-10-16）

By user decision, the recurring work to keep this document current was retired and QUALITY-004 was marked EXCLUDED. The material below is the initial inventory and must not be used as the current task state or as a quality assessment of a newer version. A future quality review should start again from the implementation, release policy, and evidence at that time. Individual issues are handled in their respective current sources. [The pre-retirement rows and dependency edges](../../Archived/QUALITY-004_EXCLUDED_2026-10-16.md) were preserved.

Some later decisions are not reflected in this text. In particular, the statement “the fastest 80 ms unsafe branch is excluded from product candidates” was identified by the user as incorrect and must not be used as a basis for current product decisions. Do not infer the current state of the ASan investigation or retired and handed-off tasks from this initial record. This retirement did not recheck or resolve those technical issues.

## Taskと本書の役割

- Task: `QUALITY-004`
- 種別: `DISCOVERY`
- 担当: Codex
- Purpose at the time: For four subjects that had completed one assessment pass, distinguish remaining quality issues, evidence gaps, unresolved contracts, and record inconsistencies; show their relation to existing tasks and identify uncovered work.
- The [Task Registry](../../ProgressV2/TASK_REGISTRY_V2.md) is authoritative for state, delegation, and start conditions. Do not duplicate its state table here.

This document records the scope, initial findings, evidence, and completion conditions for the inventory. It does not replace the higher-level [quality requirements](../QUALITY_REQUIREMENTS.md), each module's contract or quality assessment, or existing task state. Making this document a canonical source did not decide how to resolve individual issues, the execution order, acceptable risks, or 1.0 adoption.

## 対象と基準

The initial findings were prepared on 2026-10-15 by comparing records and working artifacts at HEAD `209ebefaf5c040fc2789c81f7052ff3a65ec621f`. The latest RedBlackTree assessment was saved at `fa1f3718` and the evaluated commit was `36f821a4`. Evidence dates for the other subjects follow their respective assessment records. Assessments from different dates are not proof of conformance for all subjects at one common revision.

| Subject | Current offering class | Assessment source |
| --- | --- | --- |
| RedBlackTreeCollections | 1.0 offering | [Current quality assessment](RedBlackTreeModule/CurrentQualityAssessment.md) / [Quality Profile](../Profiles/RedBlackTreeCollections.md) |
| NextPermutationModule (with a legacy PermutationModule compatibility entry point) | 1.0 offering with Swift 6.4 or later | [Current quality assessment](PermutationModule/CurrentQualityAssessment.md) / [Quality Profile](../Profiles/NextPermutationModule.md) |
| OptionalElementBufferModule | Reserved experimental offering, explicitly enabled by a trait | [Current quality assessment](OptionalElementBufferModule/CurrentQualityAssessment.md) / [Quality Profile](../Profiles/OptionalElementBufferModule.md) |
| ElementBufferModule | 1.0 offering: Swift 6.2 for competitive use; Swift 6.4 for general use (user correction, 2026-10-15) | [Current quality assessment](ElementBufferModule/CurrentQualityAssessment.md) / [Quality Profile](../Profiles/ElementBufferModule.md) |

Completing one assessment pass is a point at which confirmed areas and gaps have been organized. It does not mean that all quality requirements are met or that publication-ready documentation is complete. Experimental and maintenance offerings still require correctness, memory safety, element lifetime, and build/test capability within their actual usage scope.

## 棚卸しの進め方と範囲

1. Confirm the target revision and release policy at the start; compare the assessments, quality profiles, implementation, tests, CI, and acceptance records as needed.
2. For QR-01 through QR-06, distinguish confirmed scope, unmet requirements, unverified areas, unresolved contracts, and inconsistent records. For counterevidence, preserve its conditions and the scope it actually demonstrates.
3. Map each issue to existing tasks and classify it as already covered, requiring record synchronization, out of scope or no longer needed, or having an unverified scope in the existing task.
4. For record inconsistencies, identify the basis for the decision and where it should be corrected. If more investigation, execution, or a user decision is needed, separate the work needed to resolve each issue.

The inventory compares documents, code, and saved evidence. If a new measurement or test run is needed, record the necessary target and reason. The task excludes individual product fixes, adoption of public contracts, release policy or performance levels, contacting users, competitive submissions, unfreezing tasks, and bulk edits to other canonical sources. Do not enumerate every protocol/configuration combination in advance.

Mappings to existing tasks are references; they are not all mandatory prerequisites for this task. The inventory can record why an issue remains unresolved and the supporting evidence without solving each issue. No additional mandatory dependency edge was identified at the time.

## 初期棚卸し結果

The items below are major issues identified in this pass; they are not an exhaustive list of all quality concerns and do not define units for new fixed task IDs. Consult the Registry for the current status of related tasks.

### (A) 安全性と公開契約

| Ref. | Subject / issue | Current evidence and classification | What the inventory should clarify | Related existing tasks and sources |
| --- | --- | --- | --- | --- |
| (A-1) | OptionalElementBuffer `Sendable` and consistency of concurrent mutation | There is counterevidence that the compiler does not reject code which concurrently mutates a shared borrow of the same instance. Distinguish this from evidence that an actual data race was run and observed. The basis for conformance remains unresolved. | Map the uses allowed by current opt-in release to the evidence supporting their safety, and define the boundary with issues deferred to future investigation of a general release model. | `OPT-072` investigates a general release model and may not cover every issue in the current experimental offering. [Sendable investigation and release policy](OptionalElementBufferModule/CurrentQualityAssessment.md) |
| (A-2) | RedBlackTree Index and final public API scope | The public Index representation and whether it adopts `Comparable` await external conditions. The disposition of Debug-only comparison declarations and diagnostic APIs is also unresolved. | Separate current guarantees, decisions dependent on external conditions, and differences in public surface across configurations. Do not revive the completed `Result` cleanup. | `RBT-001`, `RBT-010`, `RBT-011`, `RBT-004`. [External-type extension audit](../../Current/EXTERNAL_TYPE_EXTENSION_AUDIT.md) / [API Matrix](../../../Sources/RedBlackTreeCollections/Documentation/API-Matrix.md) |
| (A-3) | Configuration-specific safety guarantees for RedBlackTree and both buffers | Full application of strict memory safety to RedBlackTree is deferred. Concurrent use and `-Ounchecked` have unverified scope for both buffers. The RedBlackTree concurrency contract already requires external synchronization. | Distinguish operations explicitly outside existing guarantees from operations within a guarantee that lack evidence. Do not classify non-application alone as a product defect. | `RBT-007`, `RBT-008`, `RBT-009`. For both buffers, check the mapping to existing task scope. [Strict-safety application record](../../Current/StrictMemorySafetyReadiness.md) / [RedBlackTree runtime-check contract](../../../Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md) / [ElementBuffer assessment](ElementBufferModule/CurrentQualityAssessment.md) |

### (B) 検証証拠

| Ref. | Subject / issue | Current evidence and classification | What the inventory should clarify | Related existing tasks and sources |
| --- | --- | --- | --- | --- |
| (B-1) | RedBlackTree termination contract under ASan | Ordinary Death Tests and ASan excluding the two process-exit suites succeeded. The combined path fails during runtime injection into child processes, leaving that configuration unverified. | Distinguish a product defect from a failed verification path; identify the unverified contract/configuration and the necessary diagnosis. | `RBT-033`. [Assessment and counterevidence](RedBlackTreeModule/CurrentQualityAssessment.md) / [Saved evidence](RedBlackTreeModule/Evidence/RBT-032-2026-10-15/README.md) |
| (B-2) | Re-runnable evidence for lifetime checks on borrowed Permutation | Twenty-five runtime tests succeeded. Compile-pass / compile-fail results came from a temporary client; a re-runnable repository fixture is missing. | Preserve existing results while identifying which lifetime-contract checks need to become re-runnable. Do not treat this as incompletion of normal-mode G0–G5. | `PERM-051`. [Borrowed-mode plan and return](PermutationModule/BorrowedPermutationTestPlan.md) / [Current evidence classification](PermutationModule/CurrentQualityAssessment.md) |
| (B-3) | External performance claims for RedBlackTree and Permutation | Regression evidence and comparative measurements exist. Permutation measured about 1.08–1.12x C++ on one workload, but external product-performance assessment is incomplete. | Map existing evidence to operations, inputs, configurations, current contracts, comparison targets, and acceptance thresholds; identify only the gaps. Do not treat behavioral comparison with C++ as performance evidence. | Permutation: `PERM-043` and `PERM-044`. For RedBlackTree, check the relevant assessment scope. [Permutation measurements](PermutationModule/CurrentQualityAssessment.md) / [RedBlackTree performance-evidence boundary](../Profiles/RedBlackTreeCollections.md) |
| (B-4) | Environment declarations and proof for offered platforms | The provisional policy is Apple platforms 27 or later and 64-bit Linux. The current manifest declares macOS 15; reflecting the policy and producing platform-specific evidence remain separate tasks. | For each release class, separate confirmed declaration, installation, build, and execution scope from gaps. Do not reclassify existing successful Linux CI as unrun; show the difference from the required evidence. | `QUALITY-002`, `QUALITY-003`. [Offering-environment policy](../QUALITY_REQUIREMENTS.md) / [manifest](../../../Package.swift) / [candidate CI](../../../.github/workflows/candidate.yml) |

### (C) 利用目的と記録の現在性

| Ref. | Subject / issue | Current evidence and classification | What the inventory should clarify | Related existing tasks and sources |
| --- | --- | --- | --- | --- |
| (C-1) | User comprehension and public documentation, mainly for RedBlackTree and Permutation | Internal prose drafts for three subjects were accepted. This is distinct from completing a publication-ready first release or showing that users uninvolved in design can use them correctly. Understanding of Permutation's temporary View, invalidation, and copying when retained is unverified. | Separate the drafted text, publication readiness, consistency with contracts, and demonstrated user comprehension. Also check how RedBlackTree documentation preparation maps to Validation scope. | `PERM-062`, `RBT-014`, `RBT-026`. The latter two cover documentation preparation and contract decisions, not all Validation. [Permutation trial design](PermutationModule/GeneralSwiftValidationScenario.md) / [RedBlackTree documentation workflow](../../Current/DOCUMENTATION_WORKFLOW.md) |
| (C-2) | Fitness of OptionalElementBuffer for competitive use | There is compile evidence for an EDPC example, but user-result evidence including correctness, time, and memory is lacking. | Organize candidate trials and evidence gaps relevant to the current experimental offering. Do not substitute submission results from another module or implementation. | `OPT-065`. [User-validation design](OptionalElementBufferModule/GeneralSwiftValidationScenario.md) |
| (C-3) | Stale “not done” statements in overall assessment tables | Some assessment tables still present completed work, such as prose drafts, continuing DocC generation, or a Permutation submission, as unrun. | Map old statements to later completion/decision evidence, current applicability, and correction location. Preserve historical assessments while distinguishing them from current assessments. | Cross-cutting scope of this task. [Continuing DocC verification](../../Current/DOCUMENTATION_CI_PLAN.md) / [October 13 completion record](../../Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-13.md) / each module's current quality assessment |

## 完了済み・対象外とするもの

- The RedBlackTree 0.6.0 current quality assessment is complete, with environment, dependencies, selection conditions, and full logs saved. Do not mark that assessment task incomplete because ASan plus Death Tests remain unverified.
- Internal user-facing prose drafts for three subjects were accepted on 2026-10-13. This is distinct from a publication-ready first release.
- Continuing module-specific DocC generation has been implemented and remote run results exist. Do not revive the claim that there is no generation path. Follow the boundaries in the [current plan](../../Current/DOCUMENTATION_CI_PLAN.md) for moving from non-blocking to required and for publication quality.
- The ABC328E Permutation submission search was completed as `PERM-002`. The fastest 80 ms unsafe branch was excluded from product candidates and must not be reused as product-performance evidence for the current safety contract.
- The old task to set a fixed external performance ratio and formally assess OptionalElementBuffer was excluded because the offering was limited to experimental use. Redesign of a general offering is a separate frozen investigation.
- Do not directly count the historical performance regression caused by making OptionalElementBuffer `mutating` as a defect in the current version, which returned to nonmutating. Preserve the measurement date separately from current performance guarantees.
- The decision that ElementBuffer assessment was unnecessary because it was “not a 1.0 offering” was invalidated by the user's correction on 2026-10-15. Separate Swift 6.2 competitive use in 1.0 from Swift 6.4 general use in 1.0; track evidence and unverified scope for each. Do not automatically unfreeze or reinstate retired tasks, and do not treat the assessment as completed. See the [Quality Profile](../Profiles/ElementBufferModule.md#供用区分と設計判断) for the design rationale and qualitative-performance decision.
- Do not revive reevaluation of dimension names, audit of the old public View, or completed Test as Specification work based only on stale statements.

## 完了条件と成果

1. For all four subjects, issues and gaps are organized against current offering classes and assessment dates, and unverified inventory scope is identified.
2. Each issue can be traced to the quality claim, target configuration, evidence, counterevidence or unverified scope, and related existing tasks.
3. Resolved, unnecessary, or out-of-scope items are distinguished from current issues. Record inconsistencies identify the correction basis and destination.
4. Issues covered by existing tasks are distinguished from those whose coverage is insufficient or unverified. Necessary follow-up candidates separate research, execution, and individual user decisions; they are not numbered or started unconditionally.
5. The inventory results and key points are returned so that completed scope can be recorded in the Registry. Resolving individual issues or adopting 1.0 is not a completion condition for this inventory.

This document is the update destination for the inventory results. Corrections to other canonical sources require a clear basis and scope and must remain within delegated authority. Do not set the execution order for every issue or define all follow-up tasks before the actual gap size and impact are known.
