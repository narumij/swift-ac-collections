# Borrowed Permutation Test as Specification Plan

## Task

- ID: `PERM-047`
- Type: `DISCOVERY`
- Owner: Claude
- Proximity to current intermediate goal: `DIRECT`

Current state, ownership, and restart conditions are controlled by the Task Registry.

## Objective

Inspect the seven disabled legacy test files under
`Tests/PermutationTests/NextPermutationsSequence/` and produce a function-level ledger that can be
used to reconstruct Test as Specification for the Swift 6.4 borrowed `NextPermutations` contract.

The ledger must distinguish behavior that remains required from behavior that belonged only to the
retired `NextPermutationsSequence` value-semantic and Copy on Write contract.

## Authoritative inputs

- `Sources/PermutationModule/Documentation/Quality-Profile.md`
- The active implementation after `#endif` in `Sources/PermutationModule/Permutations.swift`
- The seven disabled files in `Tests/PermutationTests/NextPermutationsSequence/`
- The test-specific instructions in `Tests/CLAUDE.md`

Do not treat the disabled implementation or disabled tests as the current contract.

## Classification

Record every legacy test function exactly once using one of these outcomes:

- `KEEP_RUNTIME`: observable behavior remains valid and can be tested while the borrowed `Span` is live.
- `REPLACE_RUNTIME`: the underlying requirement remains, but the setup or assertion must change for the borrowed API.
- `REPLACE_COMPILE_PASS`: the property is best demonstrated by code that must compile.
- `REPLACE_COMPILE_FAIL`: the property is a forbidden ownership or lifetime use that must be rejected by the compiler.
- `REPLACE_LIFETIME`: the property concerns initialization, ownership, destruction, or deallocation.
- `RETIRED`: the property belongs only to the removed Sequence, persistent result, iterator-copy, COW, or result-Collection contract.

For each function, record the source file and function name, classification, reason, corresponding
new-contract requirement, and proposed destination test group. Do not write replacement test code in
this task.

## Boundaries

- Do not modify production source, tests, package manifests, CI, or public documentation.
- Do not choose new public API, naming, compatibility policy, or guarantees absent from the Quality Profile.
- Do not remove the `#if false` blocks.
- If a legacy assertion exposes an ambiguity in the new public contract, record it under
  `Unresolved questions` and stop classification of only that assertion; do not resolve it.
- Do not infer runtime safety from compiler acceptance or compiler rejection from runtime behavior.

## Deliverable

Append these sections to this file:

1. `Function ledger`
2. `Proposed successor test groups`
3. `Unresolved questions`
4. `Validation performed`
5. `Handoff to Codex`

## Completion conditions

- Every legacy test function in all seven files appears exactly once in the ledger.
- Each proposed successor test group is bounded to runtime behavior, compile-pass, compile-fail, or ownership/destruction.
- Retired COW and persistent-value requirements are not silently carried into the borrowed contract.
- No product or test implementation file is changed.
