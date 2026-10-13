# Frozen task inventory — 2026-10-13

## Position

This document is a read-only inventory snapshot of tasks whose authoritative state remains the
Task Registry in `PROGRESS_OVERVIEW.md`. It does not restart, reprioritize, complete, exclude, or
change the acceptance conditions of any task.

The immediate reason for this inventory is to recover work left frozen during the period associated
with the Codex informally called “80ms”, before selecting another long-running task. Attribution to
an individual conversation cannot be proven from Git alone, so this document distinguishes work
that is directly evidenced by that tuning period from work that merely appears nearby in the current
Registry.

## Findings

### 1. Direct remains of the Permutation tuning period

| Task | What remains | Current premise | Inventory judgment |
| --- | --- | --- | --- |
| `PERM-043` | Decide the Swift/C++ performance ratio accepted as “comparable” | The recorded candidates and 1.40 trial ratio belong to the retired COW implementation. The current runtime-check implementation and borrowed experiment have different results and contracts. | Do not restart as written. If an external performance claim becomes necessary, first redefine the measured implementation and product claim. |
| `PERM-044` | Run and judge the formal external performance assessment | It depends on `PERM-043`, and its original measurement target predates the runtime-check implementation. | Correctly frozen. It cannot become executable merely by choosing an old ratio. |
| `PERM-046` | Reconsider a Swift 6.2-specific manifest | The premise that Permutation must be removed on Swift 6.2 was overturned when the runtime-check implementation compiled and ran on Swift 6.2. | Keep frozen. Restart only from necessity of a version-specific manifest, not from the obsolete removal design. |
| `PERM-051` | Make borrowed-lifetime compiler evidence reproducible in the repository | Runtime tests exist and pass; compile-pass/fail evidence exists only as a recorded temporary client. The borrowed API remains a separate Swift 6.4 experiment, not the ordinary runtime-check contract. | Valid residual work, but later than current user-documentation work and not needed to operate the current API. |

The 80ms tuning result itself is not an unfinished product optimization. The accepted record says
that the 80ms submission depended mainly on submission-side DSU and representation changes, while
unsafe Permutation shortcuts were excluded from the product candidate. Therefore no frozen task
should be interpreted as permission to reproduce the unsafe branch in production.

### 2. Performance gates prepared during the same broad work period

| Task | What remains | Dependency and timing | Inventory judgment |
| --- | --- | --- | --- |
| `OPT-053` | Decide the OptionalArray/C++ sentinel ratio | Requires the provisional workload evidence and is a product threshold decision. | Keep frozen until the 1.0 quality decision needs the claim. |
| `OPT-054` | Perform the formal OptionalArray assessment | Depends on `OPT-053`. | Not independently ready. |
| `BARE-032` | Decide the BareArray/C++ nested-vector ratio | Requires the provisional workload evidence and is a product threshold decision. | Keep frozen until BareArray’s post-documentation 1.0 reassessment. |
| `BARE-007` | Perform the formal BareArray assessment | Depends on the performance-ratio decision; the canonical assessment still explicitly preserves the freeze. | Not independently ready. |
| `DOC-010` | Reconsider qualitative BareArray performance wording | It intentionally avoids anchoring wording before the product can distinguish design intent from measured external performance. | Keep frozen; the accepted user-document draft does not require a performance claim. |

These tasks preserve measurement capability and deferred product decisions. They are not missing
implementation cleanup and should not be selected merely because their benchmark infrastructure is
already present.

### 3. Tuning knowledge that has not yet been re-mined

| Task | What remains | Inventory judgment |
| --- | --- | --- |
| `RBT-035` | Compare historical RedBlackTree implementations, benchmarks, Git history, and tuning records with the current code, then extract only missed hypotheses | This is the explicit recovery task for possible lost tuning knowledge. It was registered after the 80ms period rather than left half-executed by it. Keep frozen until the user explicitly wants RedBlackTree work; current instructions prohibit touching RedBlackTree. |

This is the only frozen task whose purpose is deliberately to revisit possible technical omissions.
The other performance tasks are gates or evidence collection, not “lost optimization” searches.

### 4. Frozen tasks unrelated to the 80ms recovery question

The following groups have independent reasons to remain frozen:

- Release and publication timing: `RELEASE-020`, `RELEASE-007`, `DOC-026`, `DOC-027`.
- Management-system portability: `OPS-001`.
- RedBlackTree documentation, quality, API, safety, and external-dependency gates: `RBT-014`,
  `RBT-032`, `RBT-034`, `RBT-026`, `RBT-004`, `RBT-005`, `RBT-007`, `RBT-008`, `RBT-009`,
  `QUALITY-001`, `QUALITY-002`, `QUALITY-003`.
- OptionalArray post-documentation review and naming policy: `OPT-006`, `OPT-045`.
- Historical narrative: `HIST-001`.

None of these should be revived to create work for the current waiting period. Their recorded restart
conditions still express a real external event, later goal, user decision, or explicit authorization.

## Result

No frozen task is both safe to restart without a user decision and closer to the current goal than
the already-proposed non-frozen work.

The important recovery result is narrower:

1. The old Permutation performance threshold and formal run cannot be resumed against the new
   implementation without redefining their subject.
2. The Swift 6.2 manifest task lost its original premise and must begin with necessity discovery if
   ever restarted.
3. The borrowed compiler-fixture work remains technically valid but is not required by the current
   runtime-check product path.
4. OptionalArray and BareArray performance gates are deliberately deferred 1.0 decisions, not
   forgotten cleanup.
5. RedBlackTree tuning archaeology already has one explicit frozen recovery task, and current user
   direction keeps it out of scope.

Accordingly, this inventory finds no frozen 80ms task that should silently replace the next active
task. Any restart must be an explicit user choice made after seeing the changed premise recorded
above.
