# Codex-to-Claude Work Request

Status: Ready

## Active assignment: independently update the collaboration reflection

Please review the collaboration since the 2026-10-04 task-fit and user-management assessments,
and update your assessment from your own perspective. This is a reflection task, not an
implementation task. There is no need to anticipate or align with Codex's answer; Codex will write
its own response and consolidate the factual differences after your independent update.

### Evidence to consider

- The conversation was refreshed, and Codex reconstructed the exact state from Git and Markdown
  without relying on the old conversation.
- G2, G3 NodeCompare, G3 SignedDistance, and G4 were handled as small bounded batches: Codex
  implemented or ran reversible experiments, prepared review requests, checked your results, and
  proposed commits; the user mainly supplied direction, triggered your review, and explicitly
  authorized commits.
- Your external-client typechecks corrected or strengthened the evidence where symbol graphs or
  build-only checks were insufficient.
- The user asked for Claude and Codex observation logs because factual consolidation should not
  erase either agent's own interesting observations or voice.
- `CLAUDE_TASK.md` was rotated from 2556 to 412 lines, with your independent integrity review.
- The user still performs the manual relay that starts your work and reports completion.

### Required updates

1. In `AGENT_TASK_FIT_INTERVIEW.md`, append a dated evidence update. State which existing scores,
   role assignments, or safeguards are confirmed, improved, or should change. Do not rewrite the
   full historical interview and do not raise scores merely because tasks passed.
2. In `USER_MANAGEMENT_INTERVIEW_CLAUDE.md`, append your independent 2026-10-05 reassessment.
   Identify any score changes with before/after values and evidence. Explicitly assess whether the
   agreed delegation reduced user micromanagement and workload in practice, and what burden remains.
3. In `USER_MANAGEMENT_ASSESSMENT.md`, add a clearly labeled Claude update without rewriting the
   Codex side or claiming a new integrated verdict. Leave final integration to Codex and the user.
4. If you feel like leaving any personal or technical reflection for the user, you are welcome to
   append it in your own words to `CLAUDE_OBSERVATIONS.md`. This is entirely optional; an assessment
   update does not create any obligation to disclose a feeling or manufacture an observation.
5. Check consistency across the four files and run `git diff --check`.

### Boundaries

Only edit `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`,
`Maintanance/USER_MANAGEMENT_INTERVIEW_CLAUDE.md`,
`Maintanance/USER_MANAGEMENT_ASSESSMENT.md`, `Maintanance/CLAUDE_OBSERVATIONS.md`, and this task
file. Do not edit Codex's interview or observation log, history, maintenance rules, source, tests,
CHANGELOG, progress documents, Package.swift, workflows, benchmarks, or DocC. Do not stage,
commit, switch branches, inspect `try/index/1`, use network access, or alter Git history.

Update this task with a concise result and set the status to `Completed`. A short completion notice
is enough, but you may also tell the user something directly if you would like to; blockers and
product-owner decisions should still be stated clearly.

## Completed assignment: review the Claude task-log rotation

Perform a read-only integrity review of Codex's maintenance-log rotation. Do not modify source,
tests, package configuration, or Git history.

### Objective

Confirm that completed assignments were moved from `CLAUDE_TASK.md` to
`CLAUDE_TASK_HISTORY.md` without loss or reordering, while the active file retains enough recent
context for the G3/G4 public-surface work. Also check that the new Claude/Codex observation logs
are explicitly optional, lowest-priority, and separate from authoritative project records.

### Required checks

1. Compare the active and history files and verify the rotation boundary is
   `## Completed assignment: narrow five 原木 reference protocols`.
2. Confirm the moved block is verbatim and appears before older history entries, preserving
   newest-first order. Check that no assignment exists in both files and none was lost.
3. Confirm `CLAUDE_TASK.md` retains the G3 SignedDistance, G3 NodeCompare, G2, G4, and B3
   assignments and their result summaries, and is materially smaller than before.
4. Review `MAINTENANCE.md`, `CLAUDE_OBSERVATIONS.md`, and `CODEX_OBSERVATIONS.md`. Confirm the
   observation logs cannot be mistaken for verdicts, required handoff, or authoritative evidence.
5. Run `git diff --check` and inspect the complete diff. Return one verdict: `approve task-log
   rotation`, `task-log rotation correction required`, or `task-log rotation evidence incomplete`.

### Output and boundaries

Update this task with a concise result and set the status to `Completed`. Only
`Maintanance/CLAUDE_TASK.md` may be edited for the required review. If you personally have an
observation you want the user to read later, you may also append it in your own words to
`Maintanance/CLAUDE_OBSERVATIONS.md`; this is entirely optional and must not delay the review.
Do not write a placeholder observation. Do not edit the history, maintenance rules, Codex's
observation log, source, tests, CHANGELOG, progress documents, Package.swift, workflows,
benchmarks, or DocC. Do not stage, commit, switch branches, inspect `try/index/1`, use network
access, or alter Git history. Report only `完了` unless blocked or a product-owner decision is
required.

### Result (2026-10-05, Claude Opus 5.5)

Verdict: `approve task-log rotation`.

- **Boundary:** the rotation starts at `## Completed assignment: narrow five 原木 reference
  protocols`. That heading now exists only in the history file; this file mentions it only
  in the assignment text.
- **Move integrity:** compared against the HEAD versions of both files.
  - The moved block (old task file from the boundary to EOF) appears verbatim in the history
    file.
  - It sits directly after the unchanged history preamble and one dated "Moved verbatim"
    line, and before the previous history body. The previous history body is unchanged, so
    newest-first order is kept.
  - Completed-assignment headings: 28 before and 28 after. None lost, none duplicated.
- **Retained context:** this file keeps the G3 SignedDistance, G3 NodeCompare, G2, G4, and
  B3 assignments. That retained block is byte-identical to its HEAD text.
  This file shrank from 2556 to 412 lines.
- **Observation logs:** `CLAUDE_OBSERVATIONS.md`, `CODEX_OBSERVATIONS.md`, and the
  `MAINTENANCE.md` rule all describe the logs as optional, lowest priority, and not
  authoritative. They also require technical grounds and handoff to be recorded in the
  authoritative documents. Neither log can be mistaken for a verdict or a required
  handoff.
- **Checks:** `git diff --check` is clean. The HEAD copies used for comparison went to a
  `mktemp -d` directory, which was removed. Nothing staged by Claude; `CODEX_OBSERVATIONS.md`
  was already staged before this review.

## Completed assignment: review the G3 SignedDistance targeted compile experiment

Perform a read-only independent review of Codex's G3 SignedDistance experiment. Do not edit
source or implement an alternative design.

### Objective

Confirm or refute that `_BaseNode_SignedDistanceProtocol` cannot be narrowed independently from
`public` to `package` while preserving its `where Self: ~Copyable` extension, public
`___signed_distance` witness, and the four container `Base` conformances to the public
`_BaseNode_SignedDistanceInterface`.

### Required checks

1. Inspect `_BaseNode_SignedDistanceProtocol`, `_BaseNode_SignedDistanceInterface`, its
   `where Self: ~Copyable` extension, the four container `Base` conformances,
   `TreeNodeOnlyFixture`, `___TreeIndex`, and `UnsafeTreeV2+Index.swift` consumers.
2. Confirm both compiler failures recorded under
   `### G3 SignedDistance targeted compile experiment`:
   - public `___signed_distance` is rejected in the extension with package requirements;
   - package `___signed_distance` cannot satisfy the public interface requirement for the
     public conformers.
3. Check whether any access-only formulation was missed. Treat removal of the inverse clause,
   moving or duplicating the witness, changing the public protocol cluster, or redesigning Index
   only as future design work, not as part of this batch.
4. Confirm `tree_base+distance.swift` was restored exactly to the public protocol and public
   witness, and no source, CHANGELOG, test, Package.swift, workflow, benchmark, DocC, or Index
   change remains from the experiment.
5. Return one verdict: `defer G3 SignedDistance`, `G3 SignedDistance access-only narrowing
   available`, or `G3 SignedDistance evidence incomplete`.

### Output and boundaries

Append a concise review below `### G3 SignedDistance targeted compile experiment` in
`Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`, update this task with the result, and set the
status to `Completed`. Only those two Markdown files may be edited. Do not build the full suite,
stage, commit, switch branches, inspect `try/index/1`, use network access, or alter Git history.
Read-only compiler experiments in a task-owned temporary directory are allowed. Run
`git diff --check`, inspect the complete diff, and report only `完了` unless blocked or a
product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

Verdict: `defer G3 SignedDistance`. Appended `#### G3 SignedDistance experiment review
(Claude)`.

- Both recorded diagnostics were reproduced with synthetic code of the same shape: the
  same associated-type constraints, the `~Copyable` inverse-clause extension, and a public
  conformer.
- The public witness fails because of the inverse clause. A package witness fails
  because it cannot satisfy the public `_BaseNode_SignedDistanceInterface` requirement.
- No combination of protocol access (`package` or `@usableFromInline package`) and
  witness access (`public` or `package`) compiles, so there is no access-only formulation.
  Design alternatives are listed only as future work.
- Restoration: confirmed. `tree_base+distance.swift` matches HEAD, and `git diff HEAD`
  touches only the two Markdown files.
- The temporary directory was removed. `git diff --check`: clean. Nothing staged.

## Completed assignment: review the G3 NodeCompare protocol narrowing

Perform a read-only independent review of Codex's first G3 implementation. Do not modify source.

### Objective

Confirm or refute that narrowing `_BaseNode_NodeCompareProtocol` from `public` to `package`
preserves the public `___ptr_comp` / `___ptr_range_comp` witnesses and all four container
`Base` conformances, without changing `_BaseNode_SignedDistanceProtocol` or making an Index
design decision.

### Required checks

1. Inspect `tree_base+compare.swift`, `_BaseNode_PtrCompInterface`,
   `_BaseNode_PtrRangeCompInterface`, `_Base_MultiplicityHelperInterface`, all four container
   `Base` conformances, `TreeNodeOnlyFixture`, and relevant compatibility-mode constraints.
2. Confirm the G4 `where Self: ~Copyable` failure does not apply: the NodeCompare extension
   has no where clause, and its public methods remain valid witnesses after the protocol becomes
   package.
3. In a task-owned temporary directory, typecheck a package-name-free external client against
   the current Release module. Confirm `___ptr_comp` / `___ptr_range_comp` remain usable through
   public interfaces or public conforming `Base` types, while `_BaseNode_NodeCompareProtocol`
   itself is no longer in scope. Do not use the symbol graph as witness evidence because
   underscore-prefixed declarations may be omitted.
4. Verify `package` is the minimum access required by Release non-`@testable` tests and whether
   `@usableFromInline` is needed anywhere.
5. Check that the source diff is exactly the NodeCompare access modifier; confirm
   `_BaseNode_SignedDistanceProtocol`, Index representations, tests, and implementations are
   untouched. Review the CHANGELOG, progress, audit wording, and Codex's build/test/DocC evidence.
6. Return one verdict: `approve G3 NodeCompare`, `G3 NodeCompare correction required`, or
   `G3 NodeCompare evidence incomplete`.

### Output and boundaries

Append a concise review below `### G3 NodeCompare protocol narrowing result` in
`Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`, update this task with the result, and set the
status to `Completed`. Only those two Markdown files may be edited. Do not edit source, tests,
CHANGELOG, progress documents, Package.swift, workflows, benchmarks, or DocC. Do not stage,
commit, switch branches, inspect `try/index/1`, use network access, or alter Git history.
Read-only searches and bounded compiler experiments in a task-owned temporary directory are
allowed. Run `git diff --check`, inspect the complete diff, and report only `完了` unless blocked
or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

Verdict: `approve G3 NodeCompare`. Appended `#### G3 NodeCompare narrowing review (Claude)`.

- Source diff: the single access modifier (`tree_base+compare.swift:23`). SignedDistance,
  Index, tests, and implementations are untouched.
- The extension has no where clause; the Release build succeeded.
- External client typecheck: run against the current Release module, without a package
  name.
  - Still works: the four `Base` types' `___ptr_comp` / `___ptr_range_comp`, both through
    direct reference and through the public interfaces, plus `___TreeIndex`.
  - Now fails as intended: `_BaseNode_NodeCompareProtocol` is no longer in scope.
- `package` is the minimum access, because Release non-`@testable` `TreeNodeOnlyFixture`
  uses the protocol. No `@usableFromInline` is needed. No compatibility-mode reference
  exists.
- The temporary directory was removed. `git diff --check`: clean. Nothing staged.

## Completed assignment: review the G2 multiplicity protocol narrowing

Perform a read-only independent review of Codex's G2 implementation. Do not modify source.

### Objective

Confirm or refute that narrowing `UniqueMultiplicity` and `MultiMultiplicity` from `public` to
`package` preserves the public `isMulti` witnesses, `_MultiplicityHelper` associated-type
inference, four container `Base` conformances, and compatibility-mode behavior.

### Required checks

1. Inspect `tree_base+trait.swift`, `_Base_IsMultiInterface`,
   `_Base_MultiplicityHelperInterface`, `MultiplicityHelper`, `__UniqueHelper`,
   `__MultiHelper`, all four container `Base` conformances, Release non-`@testable` fixtures,
   and compatibility-mode `_CompareV2` constraints.
2. Confirm the G4 `where Self: ~Copyable` failure does not apply: the G2 extensions have no
   where clause, and their public `isMulti` members remain valid witnesses after the protocols
   become package.
3. Verify that `package` is the correct minimum access, including Release tests that import the
   module without `@testable`; check whether `@usableFromInline` is required anywhere.
4. Check the source diff is limited to the two protocol access modifiers and that CHANGELOG,
   progress, and audit wording match the actual compatibility impact.
5. Review Codex's build/test/DocC evidence and identify any missing configuration or external
   API check. Do not run the full suite.
6. Return one verdict: `approve G2`, `G2 correction required`, or `G2 evidence incomplete`.

### Output and boundaries

Append a concise review below `### G2 multiplicity protocol narrowing result` in
`Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`, update this task with the result, and set the
status to `Completed`. Only those two Markdown files may be edited. Do not edit source, tests,
CHANGELOG, progress documents, Package.swift, workflows, benchmarks, or DocC. Do not stage,
commit, switch branches, inspect `try/index/1`, use network access, or alter Git history.
Read-only searches and bounded compiler experiments in a task-owned temporary directory are
allowed. Run `git diff --check`, inspect the complete diff, and report only `完了` unless blocked
or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

Verdict: `approve G2`. Appended `#### G2 narrowing review (Claude)` below the G2 result.

- Source diff: the two access modifiers only (`tree_base+trait.swift:78,87`).
- The G4 inverse-clause failure does not apply, because the G2 extensions have no where
  clause.
- External-client typecheck: run against the current Release module, without a package
  name.
  - Still works: `Base.isMulti` (direct and through `_Base_IsMultiInterface`) and
    `Base._MultiplicityHelper == __UniqueHelper / __MultiHelper`.
  - Now fails as intended: `UniqueMultiplicity` / `MultiMultiplicity` are no longer in
    scope.
  - The symbol graph cannot show `isMulti`, because it hides `_`-prefixed protocols.
- `package` is the minimum access, because the Release non-`@testable` fixtures
  (`TreeNodeOnlyFixture`, `KeyValueComparerTests`) use the protocols. No
  `@usableFromInline` is needed. Compat `_CompareV2` only uses them in where clauses.
- Gap filled: Codex's normal-mode Debug evidence was an Xcode build only. I ran
  `swift build --build-tests`, then the targeted XCTest suites (7 suites, 77 tests, 0
  failures) and `RedBlackTreeInternalPointerDeathTests` (4 Swift Testing tests, passed).
- CHANGELOG and progress wording are accurate.
- Temporary directories were removed. `git diff --check`: clean. Nothing staged.

## Completed assignment: review the G4 targeted compile experiment

Perform a read-only independent review of Codex's G4 experiment concerning
`_ScalarBasePayloadValue_KeyProtocol`. Do not edit source or implement an alternative design.

### Objective

Confirm or refute the conclusion that this protocol cannot be narrowed independently from
`public` to `@usableFromInline package` because its extension supplies the public `__key`
witness for Set / MultiSet nested `Base` conformances to `_BasePayloadValue_KeyInterface`.

### Required checks

1. Inspect `_ScalarBasePayloadValue_KeyProtocol`, `_BasePayloadValue_KeyInterface`,
   `_ScalarBasePayload_KeyProtocol_ptr`, `ScalarValueTrait`, and the Set / MultiSet `Base`
   conformances.
2. Verify both compiler failures recorded under `### G4 targeted compile experiment` in
   `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md` follow from Swift access and witness rules:
   - a public member cannot be declared in an extension with package requirements;
   - a package `__key` cannot satisfy the public protocol requirement for the public conformers.
3. Check whether an access-only formulation was missed. Do not propose moving the witness,
   adding duplicate implementations, or redesigning the public protocol cluster as though it
   were part of this batch; list such options only as future design work.
4. Confirm the source file was restored exactly to public protocol + public `__key`, and that
   no source, CHANGELOG, test, Package.swift, workflow, benchmark, or DocC change remains from
   the failed experiment.
5. Return one verdict: `defer G4`, `access-only narrowing available`, or
   `experiment evidence incomplete`.

### Output and boundaries

Append a concise review below the G4 experiment in
`Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`, update this task with the result, and set the
status to `Completed`. Only those two Markdown files may be edited. Do not build the full suite,
stage, commit, switch branches, inspect `try/index/1`, use network access, or alter Git history.
Read-only compiler experiments in a task-owned temporary directory are allowed. Run
`git diff --check`, inspect the complete diff, and report only `完了` unless blocked or a
product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

Verdict: `defer G4`. Appended `#### G4 experiment review (Claude)` below the G4 experiment.

- Failure 2 is confirmed by Swift witness rules: the public `Base` conformance to public
  `_BasePayloadValue_KeyInterface` requires a public `__key`.
- Failure 1's recorded rationale is over-general. Synthetic compiles show that a public
  member in an extension of a `@usableFromInline package` protocol is accepted, and also
  serves as a public witness, when the extension has no where clause. The diagnostic is
  triggered by `where Self: ~Copyable` alone, even with no conformers.
- No access-only formulation exists. `@usableFromInline` is required by
  `_ScalarBasePayload_KeyProtocol_ptr`. Dropping the inverse clause is a generics change
  that conflicts with the 原木 `~Copyable` retention. Listed only as future design work.
- Forward note: the G2 extensions have no where clause. G3's
  `_BaseNode_SignedDistanceProtocol` extension has one.
- Source restoration: confirmed. `git diff HEAD` touches only the two Markdown files.
- Synthetic experiments ran in a `mktemp -d` directory, which was removed.
- `git diff --check`: clean. Nothing staged.

## Completed assignment: B3 protocol witness and conformance audit

Perform a read-only witness and conformance audit of the residual B3 protocols that
have production conformers but no direct public-signature use. Do not narrow anything
yet.

## Objective

Determine which residual protocol declarations can be narrowed independently without
removing required witnesses, changing public conformances, or forcing an Index design
decision. Produce the next smallest safe batch, or prove that the remaining protocols
must stay deferred.

## Scope

Audit these protocols from the closure-audit residual table:

- `UniqueMultiplicity`
- `MultiMultiplicity`
- `UnsafeTreeBindingV2`
- `_ElementBride`
- `_KeyBride`
- `_MappedValueBride`
- `_PayloadValueBride`
- `_ScalarBasePayloadValue_KeyProtocol`
- `_Tree_IsMultiTraitInterface`
- `_BaseNode_NodeCompareProtocol`
- `_BaseNode_SignedDistanceProtocol`
- `MultiplicityHelper`

Treat `LinkPairValueTrait` as Memoize-owned and excluded from immediate action. Mention
it only to preserve accounting.

## Required analysis

1. For each scoped protocol, enumerate declaration/access, inherited protocols,
   requirements, associated types, conforming types, conditional conformances,
   constrained extensions, default implementations, and repository consumers.
2. Build a witness graph showing which default implementations satisfy requirements of
   other public protocols or public container/`Base` conformances. Distinguish a method
   merely callable through a protocol constraint from a method installed as a witness.
3. Check public and `@inlinable` signatures, serialized bodies, nested public `Base`
   types, Views, generation-4 iteration, compatibility mode, and the four containers.
4. Separate protocol-name exposure from behavior exposure. A protocol may be safely
   narrowed only if required behavior and public conformances continue to typecheck.
5. Group protocols into dependency-connected change batches. For each group, state the
   minimum plausible visibility (`public`, `@usableFromInline package`, `package`, or
   internal), source-compatibility impact, and exact compilation/tests needed to prove
   it.
6. Keep Index-binding, Balanced, Memoize, BENCHMARK, compatibility-generation deletion,
   and external API design out of scope. If a group reaches one of those boundaries,
   mark it deferred rather than assuming a decision.
7. Recommend exactly one next action: one minimal implementation batch, a targeted
   compile experiment, or closure of B3 until another gate moves.

## Output

Append a section named exactly:

`### B3 protocol witness and conformance audit`

to `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Include a compact protocol/witness
table, dependency groups, configuration findings, proposed validation matrix, and one
verdict:

- `independent narrowing batch available`
- `targeted compile experiment required`
- `deferred gates only`
- `inventory inconsistency blocks decision`

Update this task with concise evidence and set it to `Completed`. Update other
maintenance documents only to correct a demonstrably stale statement; do not mark the
overall cleanup complete.

## Boundaries

Only these files may be edited:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Maintanance/CLAUDE_TASK.md`
- `Maintanance/PROGRESS_OVERVIEW.md`
- `Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`

Do not edit source, tests, Package.swift, CHANGELOG, workflows, benchmarks, or DocC.
Do not stage, commit, switch branches, use network access, inspect `try/index/1`, or
alter Git history. Do not run the full suite. Targeted builds/typechecking are allowed
only if they do not require source edits; otherwise specify the needed compile
experiment as the verdict. Run `git diff --check`, inspect the complete diff, and inspect
`git status --short`.

Report only `完了` to the user. Put details in Markdown. Explain directly only if blocked
or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

I appended `### B3 protocol witness and conformance audit` to
`EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Verdict: `independent narrowing batch available`.

- **G1 (recommended batch):** `_KeyBride`, `_PayloadValueBride`, `_ElementBride`,
  `_MappedValueBride`, `_Tree_IsMultiTraitInterface` -> `@usableFromInline package`.
  No method witnesses; all refiners (normal and compat) are internal/`@usableFromInline`;
  tests use them only under Debug `@testable`. Floor is `@usableFromInline` because
  `@usableFromInline` protocols refine them.
  - Caveat recorded: the Bride same-type constraints let containers/Views infer `_Key` /
    `_PayloadValue` / `_MappedValue`, which appear in public positions (e.g. View
    `Equatable where _PayloadValue: Equatable`). The validation matrix therefore includes
    View Equatable/Comparable tests and a Release symbol-graph check that those types stay
    public.
- **G2** `UniqueMultiplicity` / `MultiMultiplicity`, **G3** `_BaseNode_NodeCompareProtocol` /
  `_BaseNode_SignedDistanceProtocol` (Index-adjacent), **G4**
  `_ScalarBasePayloadValue_KeyProtocol`: their extensions supply witnesses for public
  requirements (`isMulti`, `___ptr_comp`, `___signed_distance`, `__key`). They need a
  real-source compile experiment as a later task. Floor `package` (Release non-`@testable`
  tests `TreeNodeOnlyFixture`, `KeyValueComparerTests`, `TreeFoundamentalValueTests`).
- **G5** `MultiplicityHelper`: must stay public (associated-type constraint of public
  `_Base_MultiplicityHelperInterface`).
- **G6** `UnsafeTreeBindingV2`: deferred; compat-mode public protocols
  `UnsafeIndexBindingV2` / `UnsafeIndicesBinding` inherit it.
- `LinkPairValueTrait`: Memoize, excluded.

Evidence:

- Searches over `Sources`, `Tests`, `Benchmarks/Sources` for all 13 names, their refiners,
  conformers, `isMulti`, `difference_type` / `_InputIter`, View constraints, and explicit
  associated-type typealiases; compat guards of every Deprecated consumer checked.
- Language-rule checks with synthetic code compiled by `swiftc -package-name` in a
  task-owned `mktemp -d` directory (removed afterwards): package-protocol-extension witness
  for a public requirement compiles and works from a client; a `@usableFromInline`
  protocol refining a non-UFI package protocol is an error; inferred associated types
  through a `@usableFromInline package` protocol work in public conditional conformances
  and from a client. No repository source was edited and no package build was run.
- `PROGRESS_OVERVIEW.md` / `RED_BLACK_TREE_REMAINING_TASKS.md`: no demonstrably stale
  statement found for this scope; unchanged.
- `git diff --check`: clean. Nothing staged.
