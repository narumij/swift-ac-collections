# NextPermutations tests-only Sequence experiment

## Position

- Task: `PERM-059`
- Type: `DISCOVERY`
- Product source and public API changes: none
- Adoption decision: not made

This experiment asks whether the runtime-checked, noncopyable `NextPermutations` owner can be
presented through Swift's ordinary `Sequence` protocols without changing its current temporary-View
contract. The adapter exists only in `Tests/PermutationTests/NextPermutationsSequenceExperimentTests.swift`.

## Experimental adapter

The tests-only `RuntimeCheckedPermutationSequence` stores an Array snapshot of the source. Each
`makeIterator()` allocates a class box that owns a fresh noncopyable `NextPermutations` value. Its
copyable `Iterator` stores a reference to that box and returns the existing
`NextPermutations.Permutation` View from `next()`.

The class box is not an incidental implementation choice. Standard `IteratorProtocol` requires the
adapter iterator to be copyable, while the current permutation owner is explicitly `~Copyable`.
Putting the owner behind reference identity is the direct way found in this experiment to satisfy
both constraints without changing product code.

## Observed behavior

### Operations that worked

- `sequence.map { Array($0) }` produced all lexicographic successors when each View was copied inside
  the transform before the next `next()` call.
- `for permutation in sequence` worked when the loop body completely consumed the View before the
  loop advanced.
- Two separately-created iterators owned independent permutation states.
- Mutating the original Array after adapter construction did not alter the adapter snapshot.

### Lifetime failure exposed by ordinary Sequence use

`Array(sequence)` successfully collects the copyable View values, but the Sequence driver must call
`next()` again to discover the end. Every `next()` closes the current generation, including the call
that returns `nil`. Consequently all Views in the completed Array are invalid. Reading an earlier
collected View produced the expected Swift trap in the test process.

This means that the adapter conforms mechanically to `Sequence`, but a common and otherwise normal
Sequence operation creates a result whose elements cannot be read. The runtime check prevents stale
pointer access; it does not make the generic operation useful.

### Iterator copy behavior

Copying the adapter Iterator copies the class reference, not the noncopyable owner. Advancing either
copy advances the same permutation state. Advancing one copy also invalidates the View most recently
returned by the other copy. Both facts were observed in passing tests, including an independent
process-exit test for invalidation.

This sharing is observable and differs from the old retired COW implementation. The experiment does
not claim that `IteratorProtocol` promises independent copies; it records the practical behavior a
product API would expose.

### Copies and allocation

- Adapter construction materializes an Array snapshot. For an Array input this can initially share
  Array storage through COW; for a general Collection it materializes owned storage.
- Every `makeIterator()` iterates that snapshot into the current `NextPermutations` owned buffer, so
  it performs one definite element copy per element and one buffer allocation.
- Every iterator also allocates one class box. Iterator copies retain the same box rather than copy
  elements or permutation state.
- `map { Array($0) }` makes a new owned Array for every yielded permutation. This is what makes its
  result safe after iteration finishes.

These are structural observations from the adapter and current owner construction. The experiment
does not claim an exact retain, release, or element-copy count after compiler optimization.

## Provisional timing observation

The test target compared ten complete enumerations of the 12,870 distinct orders of a 16-element
binary input. Both paths used the same checksum body. In the observed Xcode test configuration:

- manual `while let owner.next()`: 0.909422167 seconds
- tests-only Sequence adapter: 0.99502125 seconds
- observed adapter/manual ratio: approximately 1.094

This single test-process observation is not a benchmark result, acceptance threshold, regression
gate, or product-performance claim. It includes the test configuration and adapter structure and is
kept only to show that the wrapper was not performance-neutral in this run. The repository's
quality-assessment benchmark remains authoritative for performance claims.

## Validation

- Xcode build-for-testing: succeeded with no reported errors.
- Selected experiment tests: 8 passed, 0 failed, 0 skipped, 0 not run.
- The eight tests cover immediate `map`, immediate `for-in`, independent fresh iterators, shared
  copied iterators, source snapshot, checksum/timing equivalence, collected-View invalidation, and
  cross-copy View invalidation.
- `git diff --check`: succeeded before recording this result.
- A separate `swift test -c release --filter NextPermutationsSequenceExperiment` attempt could not
  evaluate the package manifest because this environment rejected SwiftPM's `sandbox-exec` setup
  with `sandbox_apply: Operation not permitted`. This is an environment failure before product build
  or test execution, not a failing Release result. No Release timing is claimed.

## Result and decision boundary

The experiment proves that a tests-only `Sequence<Element == Permutation>` adapter can be made to
compile and can support algorithms that consume each View synchronously. It also finds a product
hazard: generic collection of the Sequence returns only invalid Views, because the terminal
`next()` call necessarily closes the last generation. The class-box solution additionally gives
copied iterators shared progress and invalidation.

Therefore mechanical conformance is not sufficient evidence for adopting this surface. Product
source remains unchanged. The possible next choices are separated into `PERM-060`:

1. Keep the current explicit manual `next()` surface and reject a View-valued Sequence.
2. Investigate a different Sequence whose Element is an owned value such as `[Value]`, accepting
   per-permutation copies as part of that separate contract.
3. Continue investigating the View-valued Sequence despite the generic-operation and iterator-copy
   behavior, with an explicit product contract for those limitations.

No option is selected by this discovery record.
