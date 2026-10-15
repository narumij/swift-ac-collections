# Permutation Test as Spec — Claude request

Author: Astra / 2026-10-15. Task: PERM-078. Status: ACTIVE, issued through CLAUDE_TASK.md on 2026-10-15.

The user authorized dispatch before closing OPT-074 acceptance records. Claude has returned OPT-074 and released its scope; the current Registry was checked before issuing this request. CLAUDE_TASK.md now assigns PERM-078 to Claude. ACTIVE records the issued assignment, not confirmation that execution has started.

## Objective and inputs

Address findings B–D in `Maintanance/Quality/PERMUTATION_TEST_AS_SPEC_REVIEW.md` against the current NextPermutationModule implementation. Preserve the existing public contract. Finding A belongs to frozen PERM-051 and is excluded.

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

List changed files and group changes by purpose. No commit or push authorization is included in this assignment. State remaining concerns, completion, and release of the assigned scope explicitly. A successful test run alone does not release ownership or complete acceptance.

## Return — reserved for Claude after dispatch

Returned 2026-10-15 22:55 JST by Claude (Opus 5.5, `claude-opus-5-5`). Baseline HEAD `c98a0908`; changes are uncommitted in the working tree. Toolchain: Apple Swift 6.4 (swiftlang-6.4.0.34.1), macOS arm64.

### Changed files by purpose

- B — `Tests/PermutationTests/NextPermutations/NextPermutations_99_ViewInvalidationDeathTests.swift`: the two terminal-nil cases no longer use `precondition`/`next()!` for setup inside the child process. Setup is a `guard` that calls `exit(setupFailedExitStatus)` (86, a normal exit) when the first `next()` is nil or the terminal `next()` is not nil, so only the access to the invalidated view can produce the expected signal. The expected signal stays `.signal(expectedSwiftTrapSignal)`. Added `terminalNextReturnsNilForTheSetupsBelow`, which checks the same setups' terminal nil as ordinary expectations outside a child process. Imports Darwin/Glibc for `exit`.
- C — `Tests/PermutationTests/BorrowedNextPermutations/BorrowedNextPermutations_98_InternalTests.swift`: `testDestroyingNeverStartedIteratorReleasesEachElementOnce`. The source array is a temporary inside the expression, so no reference outlives the owner; it checks 0 releases before destruction and 3 after `consume`. File header updated.
- D — `Tests/PermutationTests/BorrowedNextPermutations/BorrowedNextPermutations_1_EnumerationTests.swift`: `testLaterSourceChangesDoNotAlterTheEnumeration`. After construction it replaces `source[0]` and appends an element; the enumeration is still `[[2,1,3],[2,3,1],[3,1,2],[3,2,1]]` (first span = construction order, then its successors), and the source shows the change. Int elements only; no deep-copy demand. File header updated.
- Handoff — `Tests/TESTING.md`: one handoff item and timestamp.

### Validation

| Command | Result |
| --- | --- |
| `swift test --filter 'TerminalNext\|NeverStarted\|LaterSourceChanges'` | exit 0; XCTest 4 (new C, D and the two normal-version counterparts), Swift Testing 2 terminal Death Tests passed |
| `swift test --filter 'terminalNextReturnsNilForTheSetupsBelow\|NextPermutations_99_ViewInvalidation'` | exit 0; 11 tests in the suite, including the new positive control |
| `swift test -c debug --filter PermutationTests` | exit 0; XCTest 63 + 7, Swift Testing 18 tests in 3 suites, 0 failures |
| `swift test -c release --filter PermutationTests` | exit 0; same counts, 0 failures |
| Compatibility: temporary copy of the repository under `mktemp -d` (no `.build`/`.git`), `COMPATIBLE_ATCODER_2025` uncommented only in the copy's `Package.swift`, `swift test --filter 'BorrowedNextPermutations\|AtCoder2025'` | exit 0; Borrowed_1 13 tests and Borrowed_98 5 tests (both including the new cases), 31 XCTest total, 0 failures. Copy removed |

Negative control for B (temporary, restored by copying the saved original back; the diff afterwards matched the pre-control diff):

1. New form, setup broken by changing `[7]` to `[1, 7]` in `subscriptTrapsAfterTerminalNextReturnsNil` so the terminal `next()` returns a view: the test **failed** with `expected exit status ".signal(SIGTRAP)", but ".exitCode(86)" was reported instead`.
2. Old form (`next()!` + `precondition(terminal == nil)`) with the same broken setup: the test **passed**, reproducing the false positive described in finding B.

### Not executed

Linux (SIGILL path and opt-in Death Tests), Swift 6.2, ASan, full-suite `swift test`, and compatibility-mode Release. In compatibility mode the normal-version Death Test file is excluded by `!COMPATIBLE_ATCODER_2025`, so B has no compatibility-mode run by design.

### Concerns, completion, release

- No production defect or unresolved contract was found. Finding A / PERM-051 was not touched.
- One process note: during validation I briefly redirected build output to a stray file in the system temporary directory outside a `mktemp -d` directory; it was deleted immediately and contained only build progress.
- B–D complete. I release the assigned scope (the three test files, the `Tests/TESTING.md` handoff item, and this Return section). No commit or push was made.
