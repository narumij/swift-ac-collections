# Permutation Test as Spec — prepared Claude request

Author: Astra / 2026-10-15. Task: PERM-078. Status: PROPOSED, NOT DISPATCHED.

This is a prepared request, not the current assignment. Do not start from this file alone. OPT-074 must first be returned by Claude and accepted by Astra; the coordinator must then check the current Registry and issue this bounded request through CLAUDE_TASK.md. Do not modify that active assignment while preparing this work.

## Objective and inputs

Address findings B–D in `Maintanance/Current/PERMUTATION_TEST_AS_SPEC_REVIEW.md` against the current NextPermutationModule implementation. Preserve the existing public contract. Finding A belongs to frozen PERM-051 and is excluded.

Read the relevant current source comments, Tests/CLAUDE.md and task-relevant Tests/TESTING.md sections before editing. Recheck baseline and concurrent changes at dispatch; this draft was prepared at 4f8c9aef.

## Bounded work

1. In NextPermutations_99_ViewInvalidationDeathTests.swift, make setup failure in the two terminal-nil invalidation cases distinguishable from the expected Swift trap. A broken terminal result must not make the invalidation test pass. Keep the exact platform-specific trap signal contract.
2. In BorrowedNextPermutations_98_InternalTests.swift, test destruction of a nonempty owner before its first next(), using local reference-lifetime counters and no retained source references.
3. Add a borrowed-owner test showing that changing the source Int array after construction does not change the copied initial order or its next lexicographic successor. Do not demand deep-copy semantics for reference elements.

## Allowed changes and stops

Only the existing numbered files under Tests/PermutationTests/NextPermutations/ and Tests/PermutationTests/BorrowedNextPermutations/ needed for these three items, the assigned Return section below, and the task-relevant handoff in Tests/TESTING.md may be edited. Do not modify production sources, manifests, CI, naming, compiler fixtures, Registry, or existing returned answers. Preserve unrelated changes.

If a test exposes a production defect or an unresolved contract, retain the evidence and stop that item for review rather than changing the contract or implementation. Do not start PERM-051, performance work, or Sequence experiments.

## Validation and handback

Run the narrow affected tests first, then the affected PermutationTests target in Debug and Release, including the relevant Death Tests. Confirm actual selected cases and distinguish failures from skipped or unavailable configurations. The borrowed files also compile in COMPATIBLE_ATCODER_2025 mode; verify the affected borrowed tests there using an isolated configuration, without changing the normal contract. Record exact commands, toolchain, counts, outcomes, and any unexecuted checks. Never suppress a failure solely to obtain green.

For finding B, demonstrate that setup failure is not accepted as the expected trap, with a temporary test-only negative control if needed; restore it before handback. Record the mechanism and result.

List changed files and group changes by purpose. No commit or push authorization is included in this draft; obtain explicit authorization at dispatch if worker commits are desired. State remaining concerns, completion, and release of the assigned scope explicitly. A successful test run alone does not release ownership or complete acceptance.

## Return — reserved for Claude after dispatch

Not started. Not returned.
