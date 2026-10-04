# Codex-to-Claude Work Request

Status: Idle — no active assignment

## Active assignment

No work is assigned. Do not edit files, resume a previous task, or select work from
the maintenance backlog. Wait for a new bounded assignment from Codex/the user.

## Completed assignment: independently assess the user's project management

Fill only:

- `Maintanance/USER_MANAGEMENT_INTERVIEW_CLAUDE.md`

Do not read `USER_MANAGEMENT_INTERVIEW_CODEX.md` until your independent answer is
complete. Evaluate the user's management of this repository and AI collaboration, not
the user's personality. Use observed events and outcomes, and do not turn stylistic
preferences into faults.

Replace every `未回答` in the table, write the short overall assessment, and propose a
delegation boundary among user, Codex, and Claude. Distinguish necessary product-owner
involvement from avoidable micro-management caused by weak AI task handling. Explicitly
acknowledge cases where your own behavior created the need for closer supervision.

Do not change the Codex file, source, tests, another maintenance document, or reopen a
technical task. When finished, change this file's status to `Completed`, append a short
result under this assignment, and report only `完了` to the user.

Result (2026-10-04, Claude Opus 5.5): `USER_MANAGEMENT_INTERVIEW_CLAUDE.md` is filled independently, without reading the Codex file. It covers all 15 rows, the overall assessment, and the delegation boundary, and it states where Claude's own behavior required closer supervision. No other file was changed.

## Completed assignment: final agreement on the task-fit policy

Read the final applied corrections and `## Codex response to Claude review` in:

- `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`

This is a final agreement check, not another open-ended review. Confirm only whether:

1. the score changes and role labels accurately reflect your review;
2. public-contract decisions are correctly left to the user after Codex drafts and
   integrates evidence;
3. the symmetric read-only review rule is acceptably limited to high-risk or canonical
   Codex work rather than every local edit;
4. the resulting table is safe to use for future assignments.

Do not introduce new optimization ideas, residual tasks, source findings, or stylistic
preferences. Do not edit the interview table, source, tests, or another document.
If you agree, append exactly one short `### Claude final agreement` paragraph under
`## Codex response to Claude review`, stating agreement and any already-recorded
conditions that remain binding. If you disagree, list only a concrete mismatch between
your prior review and the applied text; do not reopen settled subjects.

Then change this file's status to `Completed` and append a one-sentence result under
this assignment. Report only `完了` to the user.

Result (2026-10-04, Claude Opus 5.5): I agreed to the applied task-fit policy in `AGENT_TASK_FIT_INTERVIEW.md` (`### Claude final agreement`); the per-row conditions already recorded remain binding.

## Completed assignment: adversarial review of Codex self-assessment

Perform a read-only adversarial review of the Codex side of:

- `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`

Review the newly filled `Codex自己評価・懸念`, the Codex ratings, assignment proposals,
and `## Codexヒアリング回答`. The purpose is to detect overconfidence and weak task
separation, not to be agreeable and not to re-evaluate your own column.

For each material objection:

- identify the row ID;
- state whether the Codex score should stay, decrease, or increase;
- distinguish `主担当可` from work that still requires a user decision, a Claude
  adversarial review, an external/toolchain check, or a second implementation pass;
- cite repository-specific evidence from prior tasks, diffs, maintenance records, or
  observed failure modes;
- flag places where Codex claims integration skill but may consume too much context,
  broaden scope, stop before repetitive completion, or mistake a plausible design for
  verified behavior;
- also confirm strengths where the existing assignment split has concrete evidence.

Pay special attention to rows rated Codex `5`, and to H, J, V1, V3, V4, and V5 where
performance, unsafe memory, ownership, or concurrency make self-confidence costly.
Do not lower a score merely because all engineering benefits from review; explain what
would make the proposed ownership unsafe or inefficient in this repository.

Do not edit the interview table, either self-assessment column, source, tests, or any
other maintenance document. Do not implement residual work or run tests. Append only a
compact `## Claude review of Codex self-assessment` section to
`AGENT_TASK_FIT_INTERVIEW.md`, containing:

- required rating/assignment corrections;
- recommended safeguards that do not require a rating change;
- confirmed Codex strengths;
- a verdict on whether the table is safe to use for future assignment.

Then change this file's status to `Completed` and append a one-paragraph result note
under this assignment. Report only `完了` to the user; the review belongs in the MD.

### Result (2026-10-04, Claude Opus 5.5)

I appended `## Claude review of Codex self-assessment` to `AGENT_TASK_FIT_INTERVIEW.md`. The table,
both self-assessment columns, and every other file are unchanged, and no test was run. The review
recommends lowering B, G, H, J, V1, V3, and V4 from 5 to 4, and V5 from 4 to 3 for both agents. It
recommends relabeling D, E, F, I, P1, and P2 as draft ownership with the decision going to the user,
and marking D3 as blocked on the facade re-export decision. It also proposes a symmetric rule: a
Codex-authored plan, audit, or progress index needs a Claude factual review before it becomes a work
order. The main evidence is that all three Codex planning documents reviewed today had blocking
corrections. The review also confirms Codex strengths in cross-configuration integration, contract
preservation on Linux, evidence restraint, and audit-driven bug discovery.

## Completed assignment: answer the remaining-task fit interview

Read and answer the Claude side of:

- `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`

This is a self-assessment and assignment-design interview, not an implementation task.
Evaluate your fit based on how you actually work in this repository, including both
successful long-form test expansion and the observed tendency to broaden scope or
over-report when boundaries are unclear.

For every row in the remaining-task table:

- fill `Claude自己評価・懸念` with one compact entry using
  `主担当可` / `見本またはレビュー必須` / `補助のみ`;
- name the most important risk or prerequisite in the same cell;
- challenge the existing Claude score or assignment proposal when you disagree, but
  give a concrete repository-specific reason;
- distinguish work you can implement well from work where your stronger role is
  adversarial/read-only review;
- state where you need a Codex example, design decision, stop point, or final review.

After the table, add a short `## Claudeヒアリング回答` section answering the common
questions once at the level of overall working style. Include:

- the three task shapes where you are most useful;
- the three task shapes most likely to go wrong;
- the minimum instructions needed to keep scope bounded;
- when you should stop and return the work to Codex;
- whether detailed findings should always go to the task MD while the user receives
  only `完了`.

Do not edit the Codex self-assessment column, silently rewrite Codex's ratings, alter
source/tests, change any other maintenance document, implement a residual task, run
tests, or reopen cancelled work. You may suggest score/assignment changes in your own
cell or response section; Codex will decide whether to apply them.

Keep each table response short. This is not an invitation to produce an essay for each
row. When finished, change this file's status to `Completed` and append a one-paragraph
result note immediately below this assignment. Report only `完了` to the user; the
substantive answer belongs in `AGENT_TASK_FIT_INTERVIEW.md`.

### Result (2026-10-04, Claude Opus 5.5)

I filled only the `Claude自己評価・懸念` column for all 28 rows and added a `## Claudeヒアリング回答`
section in `AGENT_TASK_FIT_INTERVIEW.md`. The Codex column, the ratings, and every other file are
unchanged, and no test was run. Rows rated `主担当可`: A, K, L, T1, U1, D1, D2, V6, V7. Each assumes
a Codex example or boundary where noted, and Codex keeps final judgment for L. Suggested score
changes appear in my cells and only cover my role in the judgment itself: D 4→3, I 3→2,
P1/P2 3→2, V2 5→4, V5 4→3. For contract and representation rows (B, D–F, I, P1/P2) I recommend
treating me as an adversarial read-only reviewer rather than an author.

## Completed assignment: review the consolidated progress overview

Perform a read-only factual review of:

- `Maintanance/PROGRESS_OVERVIEW.md`

Check it against the current source, tests, package manifest, git-visible documentation,
and the existing maintenance records. The purpose is to make the overview trustworthy,
not to expand the project scope or restart old work.

Review all modules, not only `RedBlackTreeCollections`. In particular:

- identify completed or active work missing from the overview for
  `PermutationModule`, `BareArrayModule`, `OptionalArrayModule`, `AcCollections`, and
  `_RedBlackTreeModule`;
- verify that every `完了`, `ほぼ完了`, `部分完了`, `保留`, and `中止` judgment has
  evidence and is not overstated;
- review the new module-by-module comment-documentation table. Distinguish existing
  comments from a systematic public-API audit, and check whether each module's stated
  remaining work is accurate;
- verify that facade/re-export modules really have no independent public declarations,
  and whether module-level documentation is the right remaining unit;
- check that the LLVM libc++ normative comparison, GNU libstdc++ reference-only result,
  and explicit exclusion of MSVC are represented consistently;
- check that the current work order reflects real dependencies: public-surface audit
  and Index contract first, dead-code judgment afterward, without falsely making
  independent non-RedBlackTree documentation depend on Index;
- identify stale claims, duplicated tasks, missing evidence documents, incorrect names,
  or material completed work recorded only elsewhere;
- distinguish a missing progress entry from a new task proposal. Do not manufacture
  completion claims from raw comment counts or passing tests alone.

Do not edit `PROGRESS_OVERVIEW.md` or any source/test/documentation file. Do not implement
fixes, resume benchmarks, run the full test suite, or reopen the cancelled broad
Compatibility-document audit. Narrow read-only searches are allowed; builds are not
needed unless a specific factual claim cannot otherwise be checked.

Append a concise `### Review result` directly under this assignment containing:

- blocking factual corrections;
- missing progress items;
- non-blocking wording or ordering improvements;
- confirmed claims;
- an explicit verdict on whether the overview is safe to use as the project progress
  index.

Give file/line or maintenance-record evidence for material corrections. Then change
the status to `Completed`. Report only `完了` to the user; all details belong in this
file for Codex to read.

### Review result (2026-10-04, Claude Opus 5.5)

Read-only: grep/sed of source, manifest, tests, and maintenance records. No build or test was run.
Line numbers refer to `Maintanance/PROGRESS_OVERVIEW.md` (abbreviated `PO`) unless a file is named.

**Blocking factual corrections**

1. *PermutationModule's AtCoder 2025 compatibility mode is missing, so 「ほぼ完了」 is overstated.*
   The plan is user-requested (`MAINTENANCE.md:91-93`) and still unimplemented.
   `AtCoder2025CompatibilityPlan.md:101-110` lists every implementation step as 「今回実施しない」.
   `Sources/PermutationModule` contains neither `COMPATIBLE_ATCODER_2025` nor `Compatibility/`, and
   `COMPATIBLE_ATCODER_2025` is still a commented manual define (`Package.swift:36`), not a trait.
   PO:33 and PO:104 should list this as 未着手/保留 with the plan as evidence. PO:178 (ABC328E) is
   step 3 of that same plan (`AtCoder2025CompatibilityPlan.md:86-91`), so it is not an independent
   item. "PO:30 Permutationは完了" applies only to the current-mode comment docs.
2. *Module name.* The module/target is `RedBlackTreeModule`; `_RedBlackTreeModule` is only its
   directory (`Package.swift:226-229`, `path: "Sources/_RedBlackTreeModule"`). Fix PO:108 and PO:162.
3. *The AcCollections re-export scope is stated too broadly.* PO:107 and PO:130 say re-export works
   in normal and compat mode. Normal mode re-exports only `RedBlackTreeCollections`. Compat mode
   adds `RedBlackTreeModule` and `PermutationModule` (`Sources/AcCollections/AcCollections.swift:1-6`).
   `OptionalArrayModule` and `BareArrayModule` are dependencies of `AcCollections`
   (`Package.swift:184-196`) but are never re-exported, and the only product is `AcCollections`
   (`Package.swift:122`). The tests cover exactly RBT in normal mode and `nextPermutations()` in
   compat mode (`Tests/AcCollectionsTests/AcCollectionsTests.swift:48-79`). The overview should
   state this scope as fact. Whether it is intended is a facade-documentation question for the
   user or Codex, not something already verified.
4. *Permutation comment-doc 「完了」 does not meet the recorded stop condition.* `MAINTENANCE.md`
   (停止条件, 2026-10-02 21:08) requires independent Codex and Claude checks that include DocC
   output. Only `RedBlackTreeCollections` has a DocC catalog and a CI DocC step (single `.docc`
   under `Sources/RedBlackTreeCollections`; `.github/workflows/swift.yml` builds `--target
   RedBlackTreeCollections` only). Write PO:104 as 区切り完了 (独立確認・DocC未実施), not 完了.
   Also, public `enum Permutations` has no `///` (`Sources/PermutationModule/Permutations.swift:27-29`),
   and `SubSequenceN._copyCount` is public only under `AC_COLLECTIONS_INTERNAL_CHECKS`
   (Debug, :172-174). That is a Debug-only public member, the same class of issue as the RBT
   Debug/Release surface gate.

**Missing progress items (completed or active work recorded elsewhere)**

- Decodable bug fix for unsorted and duplicate input in all 4 RBT types (2026-10-03), with
  regression tests: `RedBlackTreeSet_13_CodableTests.swift:18`, `RedBlackTreeDictionary_10_CodableTests.swift:20`,
  `RedBlackTreeMultiSet_15_CodableTests.swift:18`, `RedBlackTreeMultiMap_10_CodableTests.swift:22`.
  It was found by the comment audit (`MAINTENANCE.md:292`). It is absent from PO:38-47, and it is
  also absent from `CHANGELOG.md` Fixed. Record that gap; do not fix it here.
- OptionalArray1D/View double-free on `nil` assignment, fixed (`CHANGELOG.md:42`). PO:123-130
  lists only the BareArray clone fix.
- Strict memory safety permanently applied to `AcCollections` and `RedBlackTreeModule` with
  0 warnings (`Package.swift:194,231`; `MAINTENANCE.md:85`). PO only mentions Permutation.
- DocC catalog plus Release `--warnings-as-errors` CI and GitHub Pages publishing (`CHANGELOG.md`
  Added; `swift.yml:49-74`). PO:90 mentions only the Topics reorganization.
- The RBT public comment audit series (Sequence/transform/protocol conformance comments,
  `MAINTENANCE.md:292` and neighbouring entries). PO:103 summarizes it, but this is evidence
  for the 「宣言コメント」 part and could be cited.
- Missing evidence documents in 正本 (PO:207-216): `CHANGELOG.md`; `CombiningAPIPerformanceEvidence.md`
  (needed by PO:177); `PermutationModule/{Specification,ImplementationPlan,ProductReadinessAssessment,
  AtCoder2025CompatibilityPlan}.md`; `REFACTORING_FROM_ATCODER_2025.md` (PO:95);
  `AdoptionReadinessAssessment*.md` (PO:31).

**Non-blocking wording / ordering improvements**

- Stale claims in documents that PO marks complete or canonical:
  - `Tests/TESTING.md:15` still says `CppBehaviorReferenceTests` 17件 (actual 35). PO:209 names
    `TESTING.md` as canonical. The update task exists only in `RED_BLACK_TREE_REMAINING_TASKS.md`.
  - `AdoptionReadinessAssessment.md:189-190,221` and `.ja.md:173-174,200` still list Linux
    validation as unmeasured or as a gate, and do not state the libc++-normative / libstdc++-reference
    split. This conflicts with PO:27 and PO:31 「完了・更新継続」.
- PO:79: the Linux Death Test run used `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` (this file, MultiMap
  Linux note). Qualify it, so that no one reads it as Linux lifetime-balance evidence. Linux
  lifetime balance relies on the normal CI Debug job; cite that run if one is claimed.
- Duplicated or misplaced tasks:
  - PO:169-170 are already main-path items in PO:136-140 and the audit's checklist.
  - PO:171-173 (`index(inserting:)`, `erase(exactly:)`, KeyValue View rejection) are now F-step
    contract decisions (`RED_BLACK_TREE_REMAINING_TASKS.md:233-234`), not open 判断待ち. Move them
    under PO §2.
  - PO §2 omits step C (confirming the existing safety/CoW/traversal contracts).
- PO:198-205 is presented as a linear sequence. Per `RED_BLACK_TREE_REMAINING_TASKS.md:124`, the
  A/B audit, C, D, and E can run in parallel, and PO:165 says non-RBT comment docs are independent.
  Mark steps 3 and 6 as parallelizable rather than "after".
  Step 2 should exclude the Debug-only Comparable group (`_NodePtrSealing`/`_LazyTieWrap`/`_LazyTie`/
  `Result`). That group is classify-only until D–I.
- PO:87 「4コンテナの英日ガイド」: the four-type set exists only under
  `Sources/RedBlackTreeCollections/Documentation/Head/`. Root `Documentation/` has Set, MultiSet,
  and MultiMap guides, with no Dictionary guide. Name the canonical location.
- Comment-doc table: the BareArray/OptionalArray rows correctly separate test evidence from a
  comment audit (PO:110). As a sanity hint only, not as completion evidence: about 6/29 and about
  10/29 public declaration lines are preceded by `///` in `BareArray.swift` / `OptinalArray.swift`.
  This matches 「体系監査未完」. The OptionalArray 「重要契約のみ更新」 claim is supported by
  `MAINTENANCE.md:303`.

**Confirmed claims**

- The C++ standard-library roles are consistent across PO:27,69-70,193,
  `CPP_BEHAVIOR_COMPARISON_MATRIX.md:9-12,91-93,100`, `RED_BLACK_TREE_REMAINING_TASKS.md:23,295`, and
  `MAINTENANCE.md:278-279`: libc++ normative with 35 tests in Debug and Release, libstdc++ reference
  with 35 tests in Debug, MSVC excluded.
- The MultiMap `find` non-guarantee is reflected in `Documentation/Compatibility/multimap.ja.md:104,112`.
- Neither facade declares anything public of its own. Their sources are only `@_exported import`s.
- The PO:142-143 claim that the topology review is reflected holds:
  `EXTERNAL_TYPE_EXTENSION_AUDIT.md:24-25,29,35,39,86,104,110-111` and
  `RED_BLACK_TREE_REMAINING_TASKS.md:77,112-115,124,225`.
- Permutation: strict memory safety is permanent (`Package.swift:318`), the API was reduced to
  `nextPermutations()` (`CHANGELOG.md` Removed; `TESTING.md:50-58`), and the Sendable rationale is
  documented (`Permutations.swift:153-155`).
- BareArray/OptionalArray strict memory safety is deferred pending storage redesign (`MAINTENANCE.md:86-89`).
- SortedCollections is 保留 after the Phase 3 pilot (`SORTED_COLLECTIONS_BENCHMARK_TASK.md:3,443-462`).
- The Compatibility-audit stop is recorded in 中止 with a no-resume rule.

**Verdict:** The overview is usable as a progress index once corrections 1–4 are applied
(Permutation compat-mode status, module name, re-export scope, Permutation doc-completion wording)
and the missing items are added. Until then it overstates Permutation and facade completeness. The
RBT main-path content and the C++ comparison representation are accurate.

## Completed assignment: review RedBlackTree remaining-task topology and public-surface audit

Perform a read-only review of these two new planning documents:

- `Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`
- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`

The purpose is to check whether the remaining work is ordered by real dependencies and
whether declarations that can affect library users are identified before dead-code
cleanup. The intended three layers are:

1. external contract;
2. implementation choices that can still affect clients, compatibility, overload
   resolution, conformances, layout, or serialized client code;
3. implementation details that are genuinely hidden from clients.

Review the documents against the actual source. In particular:

- verify the claims about `RedBlackTreeIndex`, its `Result` representation, and the
  Debug-only retroactive `Result: Comparable` conformance;
- check the external-type extension inventory for material omissions or incorrect
  visibility classifications, including `Int`, `Result`, `Range`, `ClosedRange`,
  `String`, `MemoryLayout`, pointer types, and any other standard-library-owned type;
- distinguish public members, public/retroactive conformances, package/internal
  members, `@usableFromInline`, and `@inlinable` effects precisely;
- verify which candidates are genuinely test-only by checking all source and test
  references. Pay particular attention to the `SortedSequence` experiment,
  `_LazyTieWrap`/`Result` Comparable support, and `unsafe(tree:rawTag:)`;
- review the A-to-L dependency order. Flag choices that are independent, incorrectly
  serialized, circular, or placed after work that depends on them;
- check that public-surface narrowing is correctly prioritized ahead of dead-code
  decisions without making unrelated PermutationModule API block RedBlackTree
  completion;
- identify any public `_`/`__`, `Unsafe*`, `SealError`, public typealias, or protocol
  conformance that should be included in the public-surface gate.

Do not implement fixes, move code, change access levels, run broad benchmarks, resume
the cancelled Compatibility audit, or edit either reviewed document. This assignment
is review only. Read-only searches and narrowly targeted build/typecheck checks are
allowed if needed, but do not run the full suite merely for a documentation review.

Append a concise `### Review result` under this active assignment containing:

- blocking corrections, if any;
- non-blocking improvements;
- confirmed claims;
- an explicit verdict on whether the topology is safe to use as the next work order.

Include source file and line evidence for every material correction. Then change the
status to `Completed`. Report only `完了` to the user; all detail belongs in this file
for Codex to read.

Cancelled context remains binding: the broad Compatibility-document audit was
force-stopped by the user and must not be resumed.

### Review result (2026-10-04, Claude Opus 5.5)

Read-only: source/test grep only. No build, test, or edit other than this section and the status line.
Paths are relative to `Sources/RedBlackTreeCollections/` unless they start with `Tests/`.

**Blocking corrections**

1. *`Int: ThreeWayCompareResult` is a public conformance, not an internal one.* The
   protocol is `public` (`Implements/__tree/interfaces/tree_interface+three_way.swift:28-34`,
   split-line `public` / `protocol`, only `@_documentation(visibility: internal)`).
   `Int.__less()` / `__greater()` (`.../three_way_compare/three_way_compare_result.swift:28-33`)
   are its requirement witnesses, so they cannot become non-public while the protocol
   and the conformance stay public. The decision unit is the protocol's visibility. Its
   only uses are the package protocol `_ThreeWayResultType` (`tree_interface+three_way.swift:38-41`)
   and `__eager_compare_result` (`three_way_compare_result.swift:36-37`), so
   `@usableFromInline package` looks feasible. That remains to be verified. Also
   inventory `public typealias __int_compare_result = Int` (`three_way_compare_result.swift:24`).
2. *Material omissions in the external-type inventory:*
   - Public global operators on the `Result` specialization: `..<`, `...`, prefix `..<`/`...`,
     postfix `...` taking `RedBlackTreeIndex` (`Implements/Index/UnsafeIndexV3RangeExpression.swift:44-70`).
     In Debug, `Result` is also `Comparable`, so the stdlib `Comparable` range operators become
     candidates too. Code such as `let r: Range<RedBlackTreeIndex> = a..<b` therefore
     type-checks only in Debug. This is a client-visible difference in overload
     resolution between Debug and Release.
   - `UnsafeMutablePointer<UnsafeNode>._NodeRef` public typealias (`Implements/__tree/unsafe_node/unsafe_node+pointer.swift:26`),
     next to the listed `_NodePtr` (:25).
   - `extension _TrackingTag` is an extension of `Int`, or `Int32` under `USE_COMPACT_NODE_METADATA`
     (`Implements/__tree/_types/tree_basic+tag.swift:46-79`). It adds `package @inlinable`
     statics `nullptr`/`end`/`retire`/`debug` to the whole integer type. The `Int` rows miss it.
   - A compat-only public member on `Result<_NodePtrSealing, SealError>`: `exists`
     (`Implements/Deprecated/unsafe_node/unsafe_node+pointer+safe+deprecated.swift:66-70`, under
     `COMPATIBLE_ATCODER_2025`). List it as a compat-only exception. Do not open the cancelled compat audit.
   - The Debug-only `Comparable` group has more than two members: public `_NodePtrSealing: Comparable`
     (`Implements/__tree/unsafe_node/Seal/_NodePtrSealing.swift:144-170`), public conditional
     `_LazyTieWrap: Comparable` (`Implements/RawBuffer/_LazyTieWrap.swift:51-67`), package
     `_LazyTie.<` (`Implements/RawBuffer/_LazyTie.swift:84-92`), and retroactive `Result: Comparable`
     (`Implements/RawBuffer/_LazyTieWrap+Result.swift:107-124`). All four must be moved or deleted
     together. Completion condition 4 should name all of them.
3. *Topology: B cannot narrow the declarations that make up the Index type.*
   `public typealias RedBlackTreeIndex = UnsafeIndexV3 = _LazyTieWrappedPtr =
   Result<_LazyTieWrap<_NodePtrSealing>, SealError>` (`Implements/Index/UnsafeIndexV3.swift:27,30`,
   `_LazyTieWrap+Result.swift:33`). This forces `_LazyTieWrap`, `_NodePtrSealing`, `SealError`, the
   intermediate aliases, the Index `==`/`!=` (`_LazyTieWrap+Result.swift:35-53`), and the Index range
   operators above to stay public. B therefore needs an explicit fourth class:
   "Index-representation-bound — classify in A/B, act in G–K". Without it, B either fails to
   compile or quietly decides the representation before F. That would contradict
   「境界内部の表現は、外部契約より先に固定しない」. The class must cover the whole
   declaration group, not only `Result: Comparable`.

**Non-blocking improvements**

- Ordering: C, D, and E do not depend on B, so they can run in parallel with A/B. D and E are
  independent of each other and both feed F. Keep "narrow before dead-code" as stated. It is correct.
- Three items in "Kで処理するIndex依存タスク" are contract decisions, not implementation:
  `index(inserting:)`, `erase(exactly:)`, and KeyValue Range View out-of-range rejection.
  Decide them in F, or in a step between F and G, so that K only implements them.
- `_SealedPtr` leaks into the public surface regardless of the Index design, through the public
  `init(_:_start:_end:)`/`_sealed_start`/`_sealed_end` of `UnsafeIterator` types
  (`Implements/Iterator/UnsafeIterator/UnsafeIterator+Payload.swift:37-52`, `+Key.swift:38-53`).
  Narrowing the `Result` aliases requires narrowing those iterator members as well.
- The specialized `==`/`!=` on `_SafePtr` (`Implements/__tree/unsafe_node/unsafe_node+pointer+safe.swift:86-104`),
  `_SealedPtr` (:172-190), and Index duplicate stdlib's conditional `Result: Equatable`. Every
  payload type is Equatable, so generic contexts already use the stdlib `==`, which has the same
  semantics. The overloads only affect concrete-context resolution. The `_SafePtr`/`_SealedPtr`
  overloads do not depend on the Index and can be decided in B.
- Add these to the A gate list. `SealError` is a public non-`@frozen` enum. Its case set depends on
  a define: `crossTree` exists only when `!ALLOW_CROSS_TREE_INDEX` (`unsafe_node+pointer+safe.swift:260-263`).
  It has public `Equatable`/`Comparable`/`Hashable` (:272-274). The public typealiases are `_SafePtr` (:84),
  `_SealedPtr` (:170), `_SafeRange` (`Implements/RawRange/_RawRange.swift:104`),
  `_SafeRangeExpression` (`Implements/RawRange/_RawRangeExpression.swift:207`), `_LazyTiedPtr`
  (`_LazyTieWrap.swift:41`), and `UnsafeNode.Seal`, which is trait-dependent `UInt32`/`UInt16`
  (`Implements/__tree/unsafe_node/unsafe_node.swift:167-171`). The A list should also cover public
  global functions/operators: `start`/`last`/`end`/`lowerBound`/`upperBound`/`find`
  (`Implements/BoundsExpression/RedBlackTreeBoundExpression+TopLevel.swift:31-79`) and
  `equalRange` plus the bound operators (`RedBlackTreeBoundRangeExpression.swift:83-122`).
  They are probably the intended DSL; confirm that rather than assume it.
- A concrete layout example for the "@frozen layout" item: the stored property `trackingTag` of the
  `@frozen public _NodePtrSealing` exists only when `!USE_LAZY_DETACH` (`_NodePtrSealing.swift:29-42`).
- SortedSequence move: the production overload `___meld_unique(_ other: UnsafeTreeV2)`
  (`Implements/UnsafeTreeV2/UnsafeTreeV2+SetAlgebra.swift:42`) is used by the public `union`/`formUnion`
  (`RedBlackTreeSet/RedBlackTreeSet+SetAlgebra.swift:35,70`). Only the
  `#if !COMPATIBLE_ATCODER_2025 && DEBUG` blocks are experimental: `UnsafeTreeV2+SetAlgebra.swift:210-278`
  (generic `___meld_unique<S: SortedSequence>`, iterator `___copy_range`) and
  `RedBlackTreeSet+SetAlgebra.swift:122-144`. Reword 「`___meld_unique`等」 so the production overload
  is not moved. `testAPICheck` (`Tests/RedBlackTreeTests/EtcTests.swift:49-62`) resolves to the
  package `union<S: SortedSequence>`, because no public generic `union` exists (only
  `union(RedBlackTreeSet)` at :32). The move must bring that overload along, or retire the test.
- `Result.unsafe(tree:rawTag:)` is `package` and `DEBUG`-only, so clients cannot see it. Moving it is
  test-support cleanup, not a public-surface gate item. A same-named internal fixture from a different
  era exists on the compat `UnsafeIndexV2` (`Implements/Deprecated/Index/UnsafeIndexV2.swift:204-208`,
  used by `Tests/.../RedblacktreemultimapAtCoder2025CompatibilityTests.swift:66`). Do not merge the two.
- The Debug-only Index `Comparable` is asserted by a numbered Test-as-Specification case,
  `test_index_comparable` (`Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_9_ProtocolConformanceTests.swift:66-71`).
  Handle it at D/F under the gate rule 「Debugだけで成立する適合…根拠にしない」.
- Other omitted rows: the unconstrained internal `Result.flatMapThrowing` (`UnsafeTreeV2+Erase.swift:143-156`),
  the unconstrained `extension Result where Failure == SealError { package var error }`
  (`unsafe_node+pointer+safe.swift:327-338`), and `MemoryLayout where T: ~Copyable`, which applies to
  every `MemoryLayout` (`Implements/RawBuffer/_BucketQueue.swift:78-85`). All are internal or package.
  They are low-risk but belong in the mechanical inventory.
- The audit's completion conditions cover `PermutationModule` as well. State explicitly that only the
  RedBlackTreeCollections rows gate RedBlackTree completion. `nextPermutations()` is already "intended
  public", so nothing blocks today. `AcCollections` re-exports `RedBlackTreeCollections` (`@_exported`),
  so every leak propagates through it too.

**Confirmed claims**

- The Index alias chain and the `Result` representation (above). `_NodePtrSealing` carries a pointer,
  a seal, and a tracking tag under the current define set; `USE_LAZY_DETACH` is off.
- `Result: Comparable` is `@retroactive`, `public`, Debug-only, and conditional on
  `Success: Comparable, Failure: Comparable`. It is visible to every `Result` that meets the condition.
- The `Result._NodePtr` public typealias sits on an unconstrained `extension Result`, so it applies to
  all `Result`s (`unsafe_node+pointer+safe.swift:322-325`). `UnsafeMutablePointer._NodePtr` is public.
- `Range`/`ClosedRange: SortedSequence` is a package-protocol conformance under
  `DEBUG && !COMPATIBLE_ATCODER_2025`, referenced only by `testAPICheck`.
- `unsafe(tree:rawTag:)` has no production caller. It is referenced only by the four
  `_98_IndexValidityXCTests` files (7/7/8/11 occurrences).
- The `String` messages are internal `@usableFromInline`. `UnsafeMutableRawPointer` helpers are internal
  (some `@inlinable`) and split by `USE_C_MALLOC`. `Collection where Index == Int` exposes only
  `nextPermutations()` publicly. No other standard-library-owned type is extended in `Sources`.
- Narrowing the public surface ahead of dead-code decisions is correctly prioritized, and
  PermutationModule does not block the RedBlackTree main path.

**Not verified**

- That `test_index_comparable` is the only code depending on `Result: Comparable`. This was found by
  grep only. A typecheck with the conformance removed needs a source edit, which this review forbids.
  The 「性能実験」 usage named in the audit was not located by grep.

**Verdict:** The A–L topology can be the next work order once blocking items 1–3 are reflected in the
two documents. Item 3 needs no reordering, only the Index-bound class in B. Without that class, B is
unsafe to start, because the natural narrowing pass would hit declarations the public Index alias requires.

## Completed assignment: controllable Debug allocation/lifetime checks

Implement a test-only opt-out for the process-global Debug allocation, node, and
payload lifetime balance checks. The default must remain enabled on every platform;
do not silently weaken Linux. Provide one explicit, consistently named SwiftPM build
switch (prefer a package trait/conditional define unless the existing structure makes
another mechanism materially safer) that CI or a developer can select for hostile
test scheduling and subprocess/Death Test runs.

Add a narrower switch as well: `SKIP_DEBUG_LIFETIME_SETUP_CHECKS`. This switch skips
only the incoming-zero assertions in `setUp`, then unconditionally resets all counters;
the same test case's outgoing balance assertions in `tearDown` must remain enabled.
Keep `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` as the broader emergency switch that skips
both incoming and outgoing counter equality assertions. If both are selected, the
broader switch subsumes the setup-only switch. Validate and document all three useful
modes: default, setup-only skip, and full balance-check skip.

Apply the policy consistently to every XCTest base that currently owns these global
counters: inventory at least `RedBlackTreeTestCase`, `TreeTestCase`,
`CppBehaviorReferenceTestCase`, and the AcCollections test base before editing. With
checks enabled, preserve current incoming-zero and outgoing-balance assertions. With
checks disabled:

- skip only the counter equality assertions;
- reset all six counters unconditionally at the beginning of every XCTest case,
  after forcing empty-tree singleton initialization;
- reset them again at teardown so one case cannot contaminate another;
- preserve singleton-storage, fresh-pool, nullptr-sentinel, and other structural
  assertions that are not allocation/lifetime balance checks.

Avoid production API and runtime behavior changes. Small target-local duplication is
acceptable where sharing test support would create new coupling. Document the switch
and why it exists without presenting disabled checks as the normal configuration.

Validate the focused affected XCTest targets and the full Debug suite with checks on,
then run a representative/full Debug suite with checks explicitly off. Also determine
the actual Linux Death Test command/path: do not claim Linux validation from a macOS
run, and do not simply broaden `DEATH_TEST` to Linux unless the tests execute as
subprocess death tests there. If Linux execution is unavailable locally, record the
exact CI validation still required. Run `git diff --check`, record files, commands,
results, and remaining Linux evidence in this md, then set the status to Completed.
Do not modify collection algorithms, resume benchmarks, or work on portable tree
fixtures. Report only `完了` to the user.

### Result (2026-10-04, Claude Opus 5.5)

Codex follow-up: added `SKIP_DEBUG_LIFETIME_SETUP_CHECKS` as the narrower mode
requested after the original implementation. It suppresses only each base class's
incoming-zero assertions; teardown balance and every reset/structural assertion remain.
The broader `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` continues to suppress both equality
check phases and therefore subsumes it when both traits are supplied. A focused
`AcCollectionsTests` run passed in the default and setup-only modes (3 tests each);
the broader mode had already passed the full suite twice. `git diff --check` is clean.

- **Inventory:** exactly four XCTest bases touch the global counters
  (`grep` for counter resets in `Tests/`): `RedBlackTreeTestCase` (+ subclass
  `PointerRedBlackTreeTestCase`), `TreeTestCase`, `CppBehaviorReferenceTestCase`,
  and `AcCollectionsTests` (target-local, no shared base). No other test resets them.
- **Switch:** package trait `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` plus
  `.define(…, .when(traits:))` in `_settings`, following the existing trait idiom.
  Not enabled by default on any platform. Select with
  `swift test --traits SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`.
  Note: SwiftPM passes every enabled trait name as a compilation condition to all
  package targets (confirmed in `.build/manifest.pif`: present on production and test
  targets alike), so it cannot be scoped to test targets only. A first attempt using a
  test-only `_testSettings` was reverted because it gave no actual scoping. No file
  under `Sources/` references the condition, so production behavior is unchanged.
- **Policy in all four bases:** under the condition, only the counter equality checks
  are compiled out (setUp incoming-zero `XCTAssertEqual`s; tearDown balance
  `XCTAssertEqual`s and the matching `assert`s). Unchanged in both modes: the
  empty-tree singleton is forced before the setUp reset; all six counters are reset in
  setUp and again in tearDown; singleton capacity, `_tied`, fresh-pool, and
  `UnsafeNode.nullptr` structural checks remain.
- **Documentation:** comments in `Package.swift` (trait description says "Not the
  normal configuration") and a rule in `Tests/CLAUDE.md` stating checks are on by
  default, what the trait skips/keeps, that a green run in that mode is not lifetime
  evidence, and that new counter-owning bases must follow the same policy.
- **Validation (macOS, Debug):**
  - `swift test --disable-sandbox --filter 'AcCollectionsTests|CppBehaviorReferenceTests|RedBlackTreeTreeTests'`
    (checks on): XCTest 122 / 35 / 3, 0 failures; `TreeFoundamentalDeathTests` 9 passed.
  - `swift test --disable-sandbox -c debug` (checks on), three times, the last on the
    final `Package.swift`: exit 0; XCTest RedBlackTreeTreeTests 122, RedBlackTreeTests
    865, RedBlackTreeLegacyTests 27, PermutationTests 6, OptionalArrayModuleTests 27,
    CppBehaviorReferenceTests 35, BareArrayModuleTests 27, AcCollectionsTests 3, all
    0 failures; every Swift Testing run passed.
  - `swift test --disable-sandbox -c debug --traits SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`
    (checks off), twice: exit 0, identical per-bundle XCTest counts, 0 failures; all
    Swift Testing runs passed.
  - `git diff --check`: clean.
- **Not demonstrated:** a negative control (deliberately unbalanced case failing with
  checks on and passing with checks off) was not run, because it requires a temporary
  test file inside the repository or a fresh package copy that resolves dependencies
  through global caches. Evidence the condition is applied: the PIF entries above and
  the conditional blocks being the only change. Codex may request the control as a
  reviewed, retained test if wanted.
- **Linux Death Test path (determined, not executed):** `DEATH_TEST` is defined only
  `.when(platforms: [.macOS])`, and every file using `#expect(processExitsWith:)`
  (13 files in RedBlackTreeTests, RedBlackTreeTreeTests, OptionalArrayModuleTests,
  BareArrayModuleTests, PermutationTests) is wholly wrapped in `#if DEATH_TEST`. So on
  Linux CI (`swift test -c debug`, `-c release`, and the ASan job in
  `.github/workflows/swift.yml`, ubuntu-24.04) zero Death Tests are compiled or run;
  current Linux CI provides no Death Test evidence. `DEATH_TEST` was not broadened.
  Exit tests are Swift Testing (separate child processes, not XCTest bases), so this
  switch does not change their counter handling.

Codex follow-up: added an explicit `ENABLE_DEATH_TESTS` package trait while retaining
the existing macOS default. A blocking Ubuntu 24.04 Debug run executed the full suite
with `ENABLE_DEATH_TESTS,SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`, so the subprocess tests
were actually compiled and executed on Linux.

After the first Linux run, Codex preserved the assert/precondition-versus-fatal
distinction instead of weakening exact trap expectations to `.failure`. Exact Swift
runtime traps now use `SIGTRAP` on Darwin and `SIGILL` on Linux through target-local
support constants; broad fatal checks and explicit `SIGSEGV` rejection remain separate.
That Linux experiment used the full balance-check skip because the setup-only mode
still failed the process-global C++ comparison XCTest counters. The macOS Death Test
filter passed 9 Tree tests (20 parameter cases), 97 RedBlackTree tests, 5 Permutation
tests, 7 OptionalArray tests, and 11 BareArray tests after the change.

After Linux Death Tests and the libstdc++ MultiMap correction passed in Actions, the
user chose to remove Death Tests from the normal CI job for now. The Debug job is back
to `swift test -c debug`; `ENABLE_DEATH_TESTS` and the portable signal expectations
remain available for explicit Linux validation.
- **Changed files:** `Package.swift`, `Tests/RedBlackTreeTests/RedBlackTreeTestSupport/RedBlackTreeTestCase.swift`,
  `Tests/RedBlackTreeTreeTests/Fixture/TreeTestCase.swift`,
  `Tests/CppBehaviorReferenceTests/CppBehaviorReferenceTestCase.swift`,
  `Tests/AcCollectionsTests/AcCollectionsTests.swift`, `Tests/CLAUDE.md`, this file.
  No collection algorithm, production API, benchmark, or fixture change.
- **Housekeeping:** a stray verbose-build redirect briefly created `/tmp/.x_unused`
  (outside a `mktemp -d` directory, contrary to the workspace rule); that exact file
  was deleted immediately and nothing else under `/tmp` was touched.

## Completed assignment: WorldClass framing withdrawal

Withdraw the 「世界最高峰候補」framing in both language
versions. Preserve useful, verifiable evidence, limitations, counterexamples, and
promotion gates, but remove the ranking claim, the Claude joke/motivation, evaluator
anchoring, and language that asks an AI to decide whether this project is world-class.

Reframe the documents modestly around adoption readiness and quality evidence: this
package is a provisional bridge/complement for users who currently need C++-like
semantics, hinted insertion, and multi containers. It does not claim to replace or
compete with Swift Collections. Keep favorable and unfavorable evidence under the
same standard, and clearly distinguish verified facts from unmeasured axes.

Update references to the old title/name where needed. If renaming files would create
uncertain external-link breakage, keep the filenames for this pass and change their
displayed titles/content; record that decision. Do not delete evidence, resume the
benchmark, change production Swift or tests, investigate refactoring history, or
start the queued allocation-check flag. Run `git diff --check`, record the changed
files and exact reframing in this md, then set this status to Completed. Report only
`完了` to the user.

### Result (2026-10-04, Claude Opus 5.5)

- **At this stage the filenames were kept** to avoid uncertain external-link breakage;
  they were later renamed to `AdoptionReadinessAssessment.md` / `.ja.md` by user request.
- **New titles:** "Adoption Readiness and Quality Evidence" /
  「採用判断のための品質証拠」.
- **Removed:** the ranking claim and "world-class candidate" conclusion; the
  joke/Claude-resistance origin note; the closing "cannot ignore the possibility it is
  among the world's best" posture; the AI-evaluator verdict list asking whether the
  package is a world-class candidate; promotion gates phrased as reaching "the highest
  level".
- **Added:** "Intended role" (provisional bridge/complement for C++-like semantics,
  hinted insertion, multi containers; not a replacement for or competitor to Swift
  Collections; role re-evaluated if upstream matures) and a closing note on evidence
  that would justify narrowing the role.
- **Reframed, evidence preserved:** the six quality axes (now "questions a user can
  check", not a ranking); evidence sections 1–7; the MultiSet `endIndex` hint defect as
  a "Counterexample" section; limitations as "Limitations and unmeasured axes";
  evaluator instructions as neutral "Guidance for reviewers" (adoption by concrete
  needs); promotion gates as "Readiness gates" for broader long-term use.
- **Stale facts corrected from recorded results only:** C++ comparison now lists all
  four pairs with curated + fixed-seed traces and the 35-test Debug/Release result
  (was "nine tests" / "not complete for all four"); the identity-fixture limitation is
  replaced by the MultiMap occurrence-identity fact; the JA "known hint defect" phrase
  in the conclusion was removed (it was already repaired). Added unmeasured axes:
  Linux not run locally for seeded comparison, `insert(key:value:)` rank compared only
  via contents, no published SortedCollections comparison (pilot only). Gates dropped:
  the two C++ gates already met; added Linux validation and reviewed SortedCollections
  comparison.
- **Reference updates:** `Maintanance/REFACTORING_FROM_ATCODER_2025.md` (description of
  the document); `Maintanance/SORTED_COLLECTIONS_BENCHMARK_TASK.md` (lines 7, 13, 592,
  626: title note, "world-class" → adoption readiness). `MAINTENANCE.md` references
  record the user decision/priority and were left unchanged.
- **Changed files:** the two adoption-readiness assessment files, the two references above, this
  file. No production Swift, tests, or benchmark changed.
- **Validation:** `git diff --check` clean.

## Original allocation-check request (now active above)

Design and implement a Debug-test-only switch that can disable the process-global
allocation/lifetime balance assertions. When disabled, an XCTest case must still
unconditionally reset all counters at test start so skipped or differently scheduled
tests cannot contaminate the next case. The Linux death-test path must be validated
after this policy change. Scope and acceptance details will be reviewed separately.

## Completed assignment: MultiMap seeded randomized C++ comparison

Immediately perform the final MultiMap seeded-randomized expansion authorized in
`Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md`. Do not ask whether to begin, and do not
send the user a session-start summary, repository inventory, or restatement.

Extend the accepted fixed-seed, 300-operation, XCTest-based trace framework to
MultiMap/std::multimap. Use distinct evolving mapped values as occurrence identity.
Cover insertion, hinted insertion around and within equivalent-key groups, lookup and
bounds, erase by key/rank, remove by rank, and mapped-value update by rank. Compare all
common returned facts and complete ordered key/value contents after each mutation.

Preserve memory lifetime assertions and seed-scoped destruction. Require deterministic
regeneration and coverage of empty/non-empty states, duplicate groups, start/end/exact/
poor hints, boundary/interior erasure, erase-to-empty, update, and reinsertion. Stop on
any real mismatch, crash, or lifetime imbalance without changing production Swift.

Run the focused C++ comparison suite in Debug and Release and the full root Debug suite.
Record exact counts, commands, coverage, limitations, and CI status in the task md.
Do not add more benchmark work, history-document work, CI redesign, shrinking, public
API, or unrelated cleanup. This is the final feature expansion for C++ compare.

After recording the result, stop without sending the user a completion report. Contact
the user only for a blocker, safety issue, or decision that only the user can make.

### MultiMap seeded result (2026-10-04, Claude Opus 5.5)

Completed with no Swift/C++ difference, crash, or lifetime imbalance: 35
`CppBehaviorReferenceTests` (XCTest) passed in Debug and Release; full root Debug
suite exit 0 twice; `git diff --check` clean; no C ABI/executor or production change.
CI not checked (`gh` unavailable, uncommitted). Details are in
`Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under "MultiMap seeded-randomized result".

### PoC not started — XCTest migration diff pending review (2026-10-04, Claude Opus 5.5)

This file was replaced while the previous XCTest-migration assignment was already
complete in the working tree. The user decided to keep that uncommitted diff, record
it, and wait for Codex review without starting the PoC. Result, changed files, and
commands are in `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under "XCTest migration
result — uncommitted, awaiting review". 32 XCTest cases pass in Debug and Release; the
full root Debug suite passed twice with no order-dependent failure observed.

### Dictionary result (2026-10-04, Claude Opus 5.5)

Status: Completed with no Swift/C++ difference or crash: 32 `CppBehaviorReferenceTests`
passed in Debug and Release, `git diff --check` clean. Same seeds/count; no C ABI or
executor change. Coverage policy, compared facts, changed files, and remaining gaps are
in `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under "Dictionary seeded-randomized
result".

### MultiSet result (2026-10-04, Claude Opus 5.5)

Completed with no Swift/C++ difference or crash: 29 `CppBehaviorReferenceTests` passed
in Debug and Release, `git diff --check` clean. Same seeds/count as Set; PRNG and
diagnostic extracted to `SeededTraceSupport.swift` without changing Set behavior;
`CPP_MULTISET_OPERATION_FIND` added. Coverage policy, compared facts, changed files,
and remaining gaps are in `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under
"MultiSet seeded-randomized result".

### Set PoC result (2026-10-04, Claude Opus 5.5)

Completed with no Swift/C++ difference or crash: 26 `CppBehaviorReferenceTests` passed in
Debug and Release, `git diff --check` clean. Details, PRNG/seeds/count, coverage policy,
changed files, and remaining gaps (Set positional erase not in the contract, so not
generated) are in `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under
"Set seeded-randomized PoC result".

## Previous assignment objective (completed)

Complete the four-container curated C++ comparison by adding one final pair:
`RedBlackTreeMultiMap<Int64, Int64>` and `std::multimap<int64_t, int64_t>`.

The primary question is the observable placement of distinct mapped values inside an
equivalent-key group, especially under hinted insertion. Communicate with the user in
Japanese. Do not commit or push.

## Baseline

Read all committed Set/MultiSet/Dictionary comparison code, the MultiMap public
implementation and Test as Specification, and
`Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` before editing.

Run:

```sh
swift test --disable-sandbox --filter CppBehaviorReferenceTests
```

Exactly 13 tests must pass. Stop if the baseline differs.

## Authorized Scope

You may edit only:

- `Sources/CppBehaviorReference/`
- `Tests/CppBehaviorReferenceTests/`
- this file for final status/result
- `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` for verified MultiMap results

Do not edit production Swift, `Package.swift`, `Benchmarks/`, existing Set/MultiSet/
Dictionary tests, randomized tests, workflows, dashboard documents, either
`AdoptionReadinessAssessment` file, or the queued benchmark task.

## Required MultiMap Comparison

Use `Int64` keys and identity-bearing `Int64` mapped values. Keep a separate
`std::multimap<int64_t, int64_t>` executor/observation path while reusing the existing
trace architecture.

Cover at least:

1. insertion of distinct keys and duplicate keys with distinct mapped values;
2. `lowerBound`, `upperBound`, and `equalRange` at before/at/between/after keys;
3. complete ordered key/value contents after every operation;
4. erase by key, including the number removed;
5. erase by a rank selected from current ordered contents, comparing the erased entry
   and the resulting next position only where both APIs expose equivalent facts;
6. update of the mapped value at a selected rank, if it maps directly to assigning
   through a valid `std::multimap` iterator;
7. hinted insertion with:
   - an empty container (`startIndex == endIndex`);
   - exact hints before and after an equivalent-key group;
   - a hint inside an equivalent-key group;
   - deliberately poor but valid hints before and after the group;
   - `startIndex` and `endIndex`;
   - reinsertion after erasure.

For every hinted insert, compare the returned rank and full ordered key/value contents.
The mapped value is the occurrence identity: use distinct values so placement within
an equal-key group is observable. Do not collapse observations to keys only.

Transport positions only as current zero-based ranks and independently resolve them
to Swift indices and C++ iterators immediately before use.

Add a deliberate mismatch test proving the diagnostic includes the container pair,
operation number, input, and both complete observations.

## Semantic discipline

- Determine the Swift API contract from implementation/tests before selecting a C++
  operation. Do not equate APIs by name alone.
- C++ hint validity and Swift hint validity must both be checked for every trace.
- If equivalent-key placement intentionally differs, preserve the smallest trace and
  report the difference; do not sort mapped values or otherwise normalize it away.
- Do not change production Swift to force agreement in this assignment.

## Stop Conditions

- On any semantic difference or crash, minimize and preserve the trace safely, set
  `Status: Blocked`, and stop before a production fix.
- Stop if a public API or Package change is needed.
- Do not expand into random/fuzz traces, performance work, or benchmark conclusions.

## Validation

1. Run narrow new MultiMap comparison tests during development.
2. Run all `CppBehaviorReferenceTests`.
3. Run `git diff --check`.
4. Confirm the changed-file list stays within the authorized scope.

Do not run the full package suite unless the focused build reveals a wider issue.

## Completion Report

Set `Status: Completed` only if the focused suite and `git diff --check` pass. Write
the exact behaviors compared, final test count/result, changed files, and real
limitations/differences into this file for Codex to review. Do not add an
accountability diary or unrelated findings.

Do not send the user a completion report or detailed handoff. Record it in the assigned
Markdown for Codex and stop. Only surface details directly when work is blocked, a
safety issue was found, or an explicit user decision is required.

### Result (2026-10-04, Claude Opus 5.5)

- **Compared** (`RedBlackTreeMultiMap<Int64, Int64>` / `std::multimap<int64_t, int64_t>`,
  distinct mapped values as occurrence identity, full ordered key/value contents
  after every operation):
  - `insert(key:value:)` ↔ `insert({k, v})`: placement after the equivalent group,
    observed through contents (neither result exposes a rank directly).
  - `insert(_:hint:)` ↔ `insert(hint, {k, v})`: returned entry and rank for an empty
    container, exact hints before/after the group, inside the group, poor hints
    before/after, `startIndex`, `endIndex`, poor hints for existing least/greatest
    keys, reinsertion at a vacated position, and reinsertion after erasing the group.
  - `find(_:)` + `count(forKey:)` ↔ `find` + `count`.
  - `lowerBound`/`upperBound` ↔ `lower_bound`/`upper_bound`: entry and rank at
    before/at/between/after keys.
  - `multimap[equalRange(k)]` ↔ `equal_range(k)`: lower/upper rank and entries in order.
  - `eraseMulti(_:)` ↔ `erase(k)`: removed count.
  - `erase(_:)` ↔ `erase(it)`: rank of the returned next position.
  - `remove(at:)` ↔ copy `*it`, then `erase(it)`: erased entry.
  - `updateValue(_:at:)` ↔ copy `it->second`, then `it->second = v`: previous value.
  - Hint/positional ranks are validated on both sides: C++ by range, Swift by range
    plus `isElement(at:)`/`isEnd(_:)` on the resolved index.
- **Result:** 4 new MultiMap tests passed; all `CppBehaviorReferenceTests` 17
  passed (baseline 13). `git diff --check` clean.
- **Changed files:** `Sources/CppBehaviorReference/include/CppBehaviorReference.h`,
  `Sources/CppBehaviorReference/CppBehaviorReference.cpp`,
  `Tests/CppBehaviorReferenceTests/MultiMapBehaviorComparisonTests.swift` (new),
  this file, `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md`.
- **Differences/limitations:** No Swift/C++ difference or crash was found, including
  within-group placement. `remove(at:)` and `erase(_:)` each expose only one of the
  erased entry / next position, so each is compared against its C++ counterpart
  for that fact alone.

## Next assignment — credibility-first peer comparison

The next task is `Maintanance/SORTED_COLLECTIONS_BENCHMARK_TASK.md`. The project is
now prioritizing evidence that helps a user or an AI make a defensible adoption
decision over broad feature expansion.

Start with Phase 1 only: audit the existing benchmark, confirm the resolved upstream
version/trait, run the small harness smoke check, and propose a genuinely matched
Set/Dictionary workload matrix. Stop for review before the large measurement run.

Task decisions in this phase follow this order:

1. preserve or improve reproducibility and semantic comparability;
2. seek evidence capable of disproving a favorable claim;
3. record disadvantages, limitations, instability, and unmeasured axes as first-class results;
4. prefer external baselines and independently reviewable artifacts over self-rating;
5. add implementation or benchmark breadth only when it strengthens one of the above.

Do not change production code to improve a result, silently substitute a merely
similar operation, or update either AdoptionReadinessAssessment conclusion from preliminary
measurements. Treat Swift Collections as a respected upstream reference within the
same ecosystem; describe tradeoffs and suitable use cases in neutral language. Frame
this package as a provisional bridge or complement for currently unmet needs, not as
a replacement. Note evidence that would justify narrowing that role in the future.

For this and later assignments, place the detailed completion report in the assigned
Markdown file for Codex and do not send a user-facing completion message. Only a
blocker, safety concern, or decision requiring the user may be surfaced directly.

## History

Earlier assignments and result summaries:
[`CLAUDE_TASK_HISTORY.md`](CLAUDE_TASK_HISTORY.md).
