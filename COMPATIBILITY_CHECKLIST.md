# AtCoder 2025 Compatibility Checklist

This branch preserves the API and observable behavior needed by code written
against `release/AtCoder/2025`. It is a compatibility deliverable, not the
canonical branch for current design, maintenance, or public documentation.

## Branch contract

- [ ] The integration target is `compatible/AtCoder/2025`.
- [ ] `README.md` continues to direct SwiftPM users to
      `compatible/AtCoder/2025`.
- [ ] `Package.swift` defines `COMPATIBLE_ATCODER_2025` for package targets.
- [ ] Current and compatibility implementations remain selected exclusively;
      duplicate public declarations are not compiled together.
- [ ] The compatibility surface remains based on `release/AtCoder/2025`.

## Permutation compatibility

- [ ] `nextPermutations()` preserves the AtCoder 2025 enumeration behavior.
- [ ] `unsafePermutations()` and `unsafeNextPermutations()` remain available.
- [ ] Legacy `Permutations` nested types required by existing submissions remain
      available.
- [ ] Safe iteration preserves retained values through copy-on-write.
- [ ] Unsafe iteration preserves the documented shared-buffer aliasing behavior.
- [ ] Empty, single-element, all-equal, and descending inputs satisfy the
      compatibility specification tests.
- [ ] The generated single-file implementation compiles with the ABC328E local
      validation fixture. Actual AtCoder submission remains a user check.

## Red-black-tree compatibility

- [ ] The four public collections retain their AtCoder 2025 `Collection` and
      `BidirectionalCollection` behavior.
- [ ] Legacy range and nested `SubSequence` APIs remain usable.
- [ ] Legacy lookup, insertion, update, and removal spellings used by existing
      clients compile.
- [ ] The compatibility surface does not accidentally expose current-only range
      views, mapped-value views, or current-only operation spellings.

## Verification

- [ ] `swift test --disable-sandbox -c debug` succeeds.
- [ ] `swift test --disable-sandbox -c release` succeeds.
- [ ] Compatibility-specific Permutation tests succeed.
- [ ] `AcCollections` re-exports the compatibility API.
- [ ] CI tests the compatibility branch's functional behavior.
- [ ] Strict-memory-safety warnings in the legacy implementation are treated as
      known compatibility debt, not as completion failures.

## Intentionally omitted

- Current-branch maintenance records and task registries are not copied here.
- Current-branch design documents and DocC catalogs are not maintained here.
- Documentation and performance CI jobs are not run for this compatibility
  branch because they describe or benchmark the current API surface.
- Performance equivalence with the current implementation is not a compatibility
  requirement.

