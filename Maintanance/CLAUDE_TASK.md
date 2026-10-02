# Codex-to-Claude Work Request

Status: Ready

## Objective

Strengthen the randomized tests for all four RedBlackTree public collection
types so that each randomized operation sequence checks both:

1. observable behavior against an independent reference model; and
2. the red-black tree invariant after each mutation.

The two checks must exercise the same collection state and the same operation
sequence. Separate reference-only and invariant-only random tests do not by
themselves satisfy this task.

## Start With

- `Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_98_FuzzTests.swift`
- `Tests/RedBlackTreeTests/RedBlackTreeMultiSet/RedBlackTreeMultiSet_98_FuzzTests.swift`
- `Tests/RedBlackTreeTests/RedBlackTreeDictionary/RedBlackTreeDictionary_98_FuzzTests.swift`
- `Tests/RedBlackTreeTests/RedBlackTreeMultiMap/RedBlackTreeMultiMap_98_FuzzTests.swift`
- The `___tree_invariant_for_fuzz()` helpers in
  `Tests/RedBlackTreeTests/RedBlackTreeTestSupport/`

## Required Work

1. Audit the four existing fuzz-test files before editing them.
2. For each collection type, make the reference-model randomized test assert
   `___tree_invariant_for_fuzz()` after every mutation.
3. Ensure that the observable state is compared with the reference model after
   every operation, not only at the end of a round or only for the most recently
   selected key. The comparison must reflect each type's semantics, including
   duplicate multiplicity for MultiSet and key-value pairs for MultiMap.
4. Keep the tests deterministic by using fixed seeds. Preserve useful operation
   coverage already present in the tests.
5. Remove or consolidate an invariant-only randomized test only when the merged
   test covers all of its operations and assertions. Do not reduce coverage just
   to shorten the files.

## Scope and Constraints

- The intended scope is the four `_98_FuzzTests.swift` files and test-support
  code only if a genuinely shared helper is needed.
- Do not modify production code merely to make the tests pass. If a test exposes
  a production bug or an unclear semantic requirement, stop that part, record
  the smallest reproducible case, and ask the user in Japanese.
- Do not change public API or reorganize unrelated tests.
- Follow `Tests/CLAUDE.md`. Consult `Tests/TESTING_REFERENCE.md` only for a
  specific missing detail; do not read it end to end.

## Validation

1. Run the narrowest relevant fuzz tests while iterating.
2. Run the complete `RedBlackTreeTests` target after the edits.
3. Run `swift test` from the repository root and confirm that the intended fuzz
   tests actually executed.
4. Perform additional configuration checks only if the changed conditional
   compilation or behavior requires them.

## Completion Criteria

- Set, MultiSet, Dictionary, and MultiMap each perform reference-model and tree
  invariant checks on the same deterministic randomized mutation sequence.
- Every operation checks the complete observable reference state appropriate to
  that collection type.
- Relevant tests and the authoritative full suite pass, or any failure is
  reported with a minimal reproduction and no speculative production fix.
- Update `Tests/TESTING.md` concisely: remove or revise the completed priority,
  update the current state, and add at most one short handoff item.
- Change this file's status to `Completed` and append a short result summary.
- Report the result to the user in Japanese, including changed files and test
  commands/results.
