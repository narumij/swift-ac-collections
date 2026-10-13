# Permutation general Swift usage Validation scenario

## Position

- Task: `PERM-041`
- Type: `DISCOVERY`
- Scope: ordinary runtime-checked `NextPermutations` in Swift 6.4 or later
- Out of scope: AtCoder 2025 compatibility mode, borrowed Span experiment, performance acceptance,
  public-documentation medium, and product API changes

This document designs a Validation scenario. It does not claim that general Swift usage has already
been validated. Existing builds and tests verify selected properties of the implementation; they do
not establish that an external user can select, install, understand, and safely use the API.

## Validation question

Can a Swift developer who did not participate in this repository:

1. choose this API for a successor-permutation problem rather than mistake it for an all-permutation
   API;
2. add the package to an independent SwiftPM consumer and reach the API through its intended import;
3. process each temporary View before advancing;
4. deliberately copy elements when persistent results are required; and
5. explain the important boundary without relying on repository-internal tests or management
   documents?

The scenario is successful only for the observed participant, package revision, toolchain, platform,
and tasks. It does not prove universal usability.

## Representative users

### User A — ACL-oriented Swift developer

- Knows C++ `std::next_permutation` or AtCoder Library conventions.
- Wants successors from the current order, including sensible handling of duplicate values.
- May expect an in-place Boolean-returning operation and needs to understand the Swift owner/View
  surface instead.

### User B — general Swift Algorithms user

- Knows `Sequence`, `Collection`, `map`, and possibly swift-algorithms `permutations()`.
- May initially expect `nextPermutations()` to be a Sequence of independently retainable values.
- Needs to choose between all positional permutations and unique lexicographic successors.

These are two different comprehension risks. Success for User A must not be treated as evidence that
User B will infer the temporary-View contract, or vice versa.

## Evidence paths

### Path 1 — independent consumer Verification

Use a temporary SwiftPM executable outside this repository's package graph. Pin it to the exact
candidate revision and use a supported Swift 6.4-or-later toolchain.

The consumer must perform these checks without `@testable import` or repository test helpers:

1. Build after importing `PermutationModule` directly.
2. Build a second target or configuration importing the `AcCollections` facade.
3. Import swift-algorithms together with this package and compile calls to both APIs without
   qualification conflicts.
4. Execute the following successor task from `[0, 0, 1]` and obtain exactly three value orders:
   `[0,0,1]`, `[0,1,0]`, `[1,0,0]`.
5. Start from `[2, 1, 3]` and confirm that earlier lexicographic orders are not produced.
6. Save all results by copying each current View with `Array(permutation)` before calling `next()`
   again, then read the saved arrays after owner destruction.

Record the package revision, consumer source, resolved dependencies, Swift version, platform,
architecture, build configuration, commands, stdout, and exit status. This is installation and
external-use Verification, not yet human comprehension Validation.

### Path 2 — task-based comprehension Validation

Give a participant only the candidate user-facing Permutation text and the public package surface.
Do not provide `Tests/`, the Quality Profile, this scenario, or verbal corrections before the tasks.

Ask the participant to complete four small tasks:

1. **Choose an API.** Given `[0, 0, 1]`, request each distinct value order at or after the current
   order. Ask whether this API or swift-algorithms `permutations()` fits and why.
2. **Consume immediately.** Compute one checksum for every yielded order without retaining Views.
3. **Retain results.** Return `[[Int]]` containing all yielded orders and explain where the element
   copy occurs.
4. **Explain a failure.** Show code that retains a `Permutation`, calls `next()` again, and then reads
   the old View. Ask what happens and how to correct the program.

The observer records:

- whether the participant selected the intended API without prompting;
- whether they used manual mutating `next()` rather than assuming Sequence conformance;
- whether each View was fully consumed before advancing;
- whether persistent results were copied as elements, not merely by copying the View value;
- whether they distinguished the next `next()` call and owner destruction as invalidation points;
- where the user-facing text caused hesitation, a wrong prediction, or a need for clarification;
- elapsed time and requests for help as contextual observations, not automatic pass/fail thresholds.

Do not teach the answer during the attempt. After the observation is recorded, corrections may be
given and the participant may explain which wording would have prevented the error.

### Path 3 — misuse probe prompted by the Sequence experiment

The public type currently does not conform to `Sequence`, so `Array(owner)` does not compile. Ask the
participant what they expect the following two conceptual operations to copy:

- copying one `Permutation` View value;
- creating `Array(permutation)` while the View is valid.

The required distinction is that the first copies the View handle and does not create independent
element storage, while the second reads the elements into owned Array storage. The tests-only
Sequence experiment showed that this distinction is not safely recoverable from `Array(...)` syntax
alone. This probe evaluates whether the documentation explains the current API; it does not reopen
the frozen Sequence-adoption decision.

## Result classification

Record each observation separately rather than reducing the trial to one score.

| Area | Confirmed for this trial | Needs revision | Not observed |
| --- | --- | --- | --- |
| Package installation and direct import | Independent consumer builds and runs | Consumer cannot resolve, build, or reach the API | Path not run |
| Facade reachability | `AcCollections` consumer builds and runs | Reexport is unavailable or unclear | Path not run |
| Similar-API selection | Participant selects successor semantics for the stated task and explains the duplicate/current-order difference | Participant selects by name alone or confuses positional all-permutations with successors | Task not attempted |
| Immediate View use | Participant completes processing before the next mutation | Participant retains and later reads a stale View | Task not attempted |
| Persistent results | Participant copies elements with `Array(permutation)` while valid | Participant expects a copied View to own elements | Task not attempted |
| Failure understanding | Participant predicts runtime rejection after advance or owner destruction and can correct the code | Participant predicts stable value semantics or an unexplained memory failure | Task not attempted |

One failure does not automatically prescribe an API change. First distinguish missing documentation,
misleading naming, an unsafe or surprising contract, package integration failure, and observer/task
bias. Preserve the original attempt as evidence before revising the task or text.

## Boundaries against existing evidence

- G0–G5 and compiler fixtures remain Verification of the current contract.
- The accepted user-document draft is the candidate explanation used by the participant; its
  existence is not proof that it communicates successfully.
- Coexistence and facade tests establish compile-time paths inside this repository, not independent
  consumer installation.
- The Sequence experiment is evidence about one rejected-or-deferred wrapper shape, not proof that
  ordinary users understand the current manual API.
- An actual AtCoder submission answers a different competitive-use Validation question and remains
  user-only work.

## Proposed execution units

### Consumer fixture execution

Create an ephemeral or deliberately retained external SwiftPM consumer, pin an exact candidate
revision, execute Path 1, and return the complete reproducibility record. This is decision-free once
the candidate revision and supported environment are named. Whether the fixture becomes permanent
repository infrastructure is a separate decision.

### Comprehension trial execution

Select a participant who was not involved in designing the API, provide only the allowed material,
run Paths 2 and 3 without coaching, and preserve their first answers. Participant selection and the
authority to contact or involve another person remain with the user. An AI proxy may be used as a
pre-publication heuristic only if it is identified as an AI proxy rather than a representative human
Validation result.

## Completion of this design task

This scenario identifies representative users, independent installation paths, bounded usage tasks,
misuse probes, observations, result categories, and the boundary between automated Verification and
human comprehension Validation. It does not start either execution unit and makes no product-policy
decision.
