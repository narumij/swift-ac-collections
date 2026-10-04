# Codex-to-Claude Work Request

Status: Completed

## Active assignment: review the package-wide `AcCollections` facade

Independently review the current uncommitted facade change. The product decision is fixed:
`AcCollections` re-exports every current collection module, and a module is removed from the facade
later only if it is confirmed not to meet the package's quality requirements.

Expected normal-mode facade:

- `RedBlackTreeCollections`
- `PermutationModule`
- `OptionalArrayModule`
- `BareArrayModule`

AtCoder 2025 compatibility mode additionally re-exports the legacy `RedBlackTreeModule` shim.

### Required review

1. Verify `Package.swift` dependencies and `Sources/AcCollections/AcCollections.swift` implement
   exactly the expected normal and compatibility surfaces without redundant or missing imports.
2. Verify `AcCollectionsTests` proves reachability through `import AcCollections` alone for all four
   defining modules. Check that the sample operations are valid public uses and not made visible by
   another explicit test import.
3. Review both new DocC module pages for factual accuracy, module ownership, compatibility wording,
   and unsupported guarantees.
4. Check `PROGRESS_OVERVIEW.md` and `Tests/TESTING.md` accurately record the decision without
   claiming the unfinished OptionalArray/BareArray quality audits are complete.
5. Run the `AcCollectionsTests` target and a normal build. If practical within the existing project
   setup, also check that both DocC catalogs are recognized; do not expand into a full documentation
   audit.

Return exactly one verdict: `approve all-module AcCollections facade`, `approve after specified
corrections`, or `reject all-module AcCollections facade`. Record concise evidence in `### Result`,
set `Status: Completed`, and tell the user only `完了` unless a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, DocC, other maintenance
files, Package.swift, or CHANGELOG. Do not inspect `try/index/1`, change any module's public API,
perform its quality audit, use network access, stage, commit, push, switch branches, or alter Git
history. Run `git diff --check` and inspect `git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified corrections`.

The facade, the tests, and the progress records are correct. The two corrections concern a DocC
sentence and an untracked catalog.

1. **Surfaces are exact.**
   - `Package.swift` (unchanged): the `AcCollections` target already depends on
     `RedBlackTreeCollections`, `RedBlackTreeModule`, `PermutationModule`, `OptionalArrayModule`,
     and `BareArrayModule`.
   - `AcCollections.swift` now `@_exported import`s the four collection modules unconditionally.
     Under `#if COMPATIBLE_ATCODER_2025` it imports only `RedBlackTreeModule`.
   - `PermutationModule` has moved out of the compat block, with no duplicate import left behind.
   - `RedBlackTreeModule.swift` is just `@_exported import RedBlackTreeCollections`. Re-exporting it
     in compat mode is therefore redundant at the symbol level, but intentional for the module name.
2. **Reachability is proven through `import AcCollections` alone.**
   - The `AcCollectionsTests` target depends only on `AcCollections` and `RedBlackTreeCollections`.
     The file imports `AcCollections`, and imports `@testable RedBlackTreeCollections` only under
     `#if DEBUG`, for the lifetime counters.
   - `PermutationModule`, `OptionalArrayModule`, and `BareArrayModule` are not dependencies of the
     test target and are not imported by it, so the three new tests can compile only through the
     facade.
   - The sample calls are public API: `Array.nextPermutations()`;
     `OptionalArray1D(capacity:)` with `subscript(position:) -> Element?`
     (`OptinalArray.swift:28,64`); `BareArray(repeating:count:)` with
     `subscript(position:)` (`BareArray.swift:24,51`).
   - In Release, the RedBlackTree tests also rely on the facade alone.
3. **DocC pages.**
   - `AcCollections.md` is accurate. It covers ownership ("does not declare collection types of its
     own"), the compat-mode wording, and the inclusion policy. "bare multidimensional arrays" is
     slightly loose, because 1D `BareArray` is included, but it is acceptable.
   - `RedBlackTreeModule.md` contains one unsupported recommendation: "New code should import
     `RedBlackTreeCollections` directly". The package's only product is
     `.library(name: "AcCollections")` (`Package.swift:122`). `RedBlackTreeCollections` is not
     exposed as a product, so external clients have no supported way to import it.
4. **Records.** `PROGRESS_OVERVIEW.md` and `Tests/TESTING.md` record the facade decision only. The
   OptionalArray and BareArray audit rows and checkboxes stay open, and the existing note that test
   progress is not comment-doc completion is kept. No audit is claimed as complete.
5. **Validation.**
   - Normal mode: `swift build --disable-sandbox --build-tests` succeeded.
   - `swift test --skip-build --filter AcCollectionsTests`: 6 tests passed, including the three new
     `exposesNextPermutations`, `exposesOptionalArray`, and `exposesBareArray`.
   - Compat mode: `swift build --target AcCollectionsTests -Xswiftc -DCOMPATIBLE_ATCODER_2025`
     succeeded.
   - DocC: Release `generate-documentation --warnings-as-errors` for both `--target AcCollections`
     and `--target RedBlackTreeModule` succeeded, writing into a `mktemp -d` directory that was then
     removed. Both catalogs were recognized (`accollections`, `redblacktreemodule`). The only
     output was the existing compiler warning "-Ounchecked … strict memory safety", which is not a
     DocC warning.

**Corrections:**

- **(a)** `RedBlackTreeModule.md`, last paragraph. Replace with: "New code should import
  `AcCollections`, the package's library product."
- **(b)** `Sources/_RedBlackTreeModule/RedBlackTreeModule.docc/` is untracked (`??`), whereas
  `AcCollections.docc` is staged. Add it with the batch, or the catalog will be missing from the
  commit.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows Codex's
files plus this one.

### Codex follow-up

Accepted both corrections. The legacy-module page now directs new external clients to the
`AcCollections` library product rather than the non-product `RedBlackTreeCollections` target. The
untracked `RedBlackTreeModule.docc` catalog will be explicitly included in the batch commit.

---

Status at completion: Completed

## Completed assignment: call-site review of the scheduler handle workflow

Re-evaluate the insertion-Index API name using the new executable main-use-case experiment, rather
than relying primarily on abstract naming rules.

Read
`Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_5_InsertionTests.swift`, especially
`test_indexInserting_linuxSchedulerStyleRunQueueExperiment()`. The modeled workflow is a Linux
scheduler-style red-black-tree run queue: order runnable tasks by virtual runtime, retain the node
position returned at enqueue time, and later dequeue a sleeping task through that saved handle
without searching by value again.

### Questions

1. At the actual call sites below, is the operation immediately readable to a Swift user?
   - `let backgroundNode = runQueue.index(inserting: background)`
   - `runQueue.erase(exactly: backgroundNode.index)`
2. Is `index(inserting:)` memorable and discoverable when a user remembers the concept as either
   "enqueue and retain its node/index" or "insert and give me a handle"?
3. Does the tuple force awkward `.index` repetition (`backgroundNode.index`), and if so is that a
   naming problem, a local-variable problem, or a return-contract problem?
4. Write the same short workflow using each serious alternative from the prior review. Judge the
   complete two-line enqueue/dequeue pair, not the insertion method in isolation.
5. Consider whether Swift-facing terminology should remain `Index` rather than expose the
   implementation idea of a node or generic handle. Do not rename the public Index type.
6. Give a concrete recommendation for the declaration and the clearest natural local-variable
   naming pattern. A previous `retain index(inserting:)` verdict is not binding; change it if the
   executable usage exposes a better API.

Return exactly one verdict: `retain index(inserting:) after call-site review`, `rename to <exact
declaration base name>`, or `return contract must be decided first`. Record a concise comparison
and preferred example in `### Result`, set `Status: Completed`, and tell the user only `完了` unless
a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the experiment, source, other tests,
API Matrix, maintenance decisions, DocC, or CHANGELOG. Do not implement the four-container
expansion, inspect `try/index/1`, use network access, build/test, stage, commit, push, or alter Git
history. Read-only repository inspection is allowed. Run `git diff --check` and inspect
`git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `retain index(inserting:) after call-site review`.

I read `test_indexInserting_linuxSchedulerStyleRunQueueExperiment()` (uncommitted, in
`RedBlackTreeSet_5_InsertionTests.swift`). This review was read-only; I built and ran nothing.

1. **Readability.** `runQueue.index(inserting: background)` and
   `runQueue.erase(exactly: backgroundNode.index)` are both understandable at a glance: "give me
   the index, inserting X" and "erase exactly this position". The friction in the experiment does
   not come from either method name. It comes from the local variable:
   `backgroundNode` holds a **tuple**, not a node. `.index` then reads as "the node's index".
2. **Memorability and discoverability.**
   - "Enqueue and keep its index" maps directly onto the name.
   - "Insert and give me a handle" does not: a user who types `runQueue.insert` will not find it
     in completion. This is the real cost of the name.
   - An `insert…`-prefixed name would gain completion but loses on the call-site reading (item 4).
     The cheaper fix is documentation: add a See Also link to `index(inserting:)` from each
     container's `insert(_:)`, and from `erase(exactly:)`.
3. **The `.index` repetition is a local-variable problem**, not a naming or return-contract one.
   The contract `(inserted: Bool, index: Index)` matches the swift-collections precedent
   `OrderedSet.append(_:) -> (inserted: Bool, index: Int)`, and that precedent is used
   destructured. Keep the tuple. In the scheduler case `inserted` is uninteresting, because the
   pid tie-break makes tasks unique, but for Set and Dictionary it matters in general.
4. **The whole enqueue/dequeue pair, written with each candidate:**

   ```swift
   // index(inserting:)
   let (_, backgroundIndex) = runQueue.index(inserting: background)
   runQueue.erase(exactly: backgroundIndex)

   // insertAndReturnIndex(_:)  — "AndReturnIndex" is redundant, and inaccurate: it also returns `inserted`
   let (_, backgroundIndex) = runQueue.insertAndReturnIndex(background)
   runQueue.erase(exactly: backgroundIndex)

   // insertReturningIndex(_:)  — the same inaccuracy; reads as a variant of SetAlgebra insert(_:)
   let (_, backgroundIndex) = runQueue.insertReturningIndex(background)
   runQueue.erase(exactly: backgroundIndex)

   // ensureIndex(for:)  — reads as a lookup, and is dishonest for MultiSet/MultiMap
   let (_, backgroundIndex) = runQueue.ensureIndex(for: background)
   runQueue.erase(exactly: backgroundIndex)
   ```

   Read as a pair, `index(inserting:)` / `erase(exactly:)` is the shortest. Its first line is the
   only one whose base name matches what is kept, an index, and nothing in it is redundant.
5. **Keep "Index" as the Swift-facing term.** "Node" exposes the implementation, and "handle"
   suggests ownership or lifetime guarantees beyond the Index contract. The experiment's local
   names (`interactiveNode`, `backgroundNode`) and its comment "saved node handle" should become
   `…Index` / "saved index". This is an edit to the experiment, so it is Codex's call; I did not
   make it.
6. **Recommendation.**
   - Declaration: unchanged.

     ```swift
     @discardableResult
     public mutating func index(inserting newMember: Element) -> (inserted: Bool, index: Index)
     ```

   - Preferred call-site pattern:

     ```swift
     let (_, backgroundIndex) = runQueue.index(inserting: background)
     // … later, when the task sleeps:
     runQueue.erase(exactly: backgroundIndex)
     ```

     When only the index is needed, use `let backgroundIndex = runQueue.index(inserting: background).index`.
   - Add a DocC See Also link from `insert(_:)` to `index(inserting:)`.
   - The earlier naming result's requirements still apply to the four-container expansion: fix the
     MultiMap doc comment, and specify the Dictionary existing-key behaviour.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows Codex's
uncommitted files plus this one.

---

Status at completion: Completed

## Completed assignment: review the `index(inserting:)` API name

Perform an independent API-naming review before the already-approved four-container expansion of
`index(inserting:)`. This is naming and contract analysis only; implementation remains deferred.

Codex's provisional recommendation is to retain `index(inserting:)`: the primary result is an
Index, the argument label makes the insertion side effect visible, and the same spelling can cover
unique and multi containers. Rejected provisional alternatives are `insertAndReturnIndex(_:)` as
overly procedural and `ensureIndex(for:)` because MultiSet/MultiMap always insert a new element.

### Required review

1. Inspect the current Set and MultiMap declarations, documentation, tests, API Matrix entries, and
   adjacent insertion/index naming in all four containers.
2. Evaluate `index(inserting:)` under Swift API naming conventions at the call site. Explicitly
   compare it with at least `insertAndReturnIndex(_:)`, `insertReturningIndex(_:)`, and
   `ensureIndex(for:)`; add another serious candidate only if it is materially better.
3. Account for the semantic split:
   - Set/Dictionary are unique-key containers and may return an existing position;
   - MultiSet/MultiMap always insert a new occurrence;
   - the API must return the usable position in every case.
4. Determine whether one shared name remains honest across all four containers. Do not assume the
   existing `(inserted: Bool, index: Index)` result shape must be identical for all four; identify
   any return-label issue that must be settled alongside the name.
5. Review `erase(exactly:)` only for consistency with the paired workflow. Do not redesign it
   unless its spelling makes the recommended insertion name misleading.
6. Separate naming conclusions from Index representation, Comparable, `try/index/1`, and the
   implementation gate. `try/index/1` is explicitly deferred until the user requests its restart.

Return exactly one verdict: `retain index(inserting:)`, `rename to <exact declaration base name>`,
or `naming decision blocked by return contract`. Record concise reasoning in a `### Result`
subsection below, set `Status: Completed`, and tell the user only `完了` unless a product-owner
decision is required.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, API Matrix, other
maintenance files, DocC, or CHANGELOG. Do not implement APIs, switch branches, inspect
`try/index/1`, use network access, build/test, stage, commit, push, or alter Git history. Use only
read-only repository inspection, then run `git diff --check` and inspect `git status --short`.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `retain index(inserting:)`.

This is read-only inspection; no build was run. It is independent of the Index representation,
Comparable, `try/index/1`, and the implementation gate.

1. **Current state.**
   - Set (`RedBlackTreeSet+Index.swift:284`) and MultiMap (`RedBlackTreeMultiMap+Index.swift:307`)
     declare `mutating func index(inserting newMember: Element) -> (inserted: Bool, index: Index)`
     with `@discardableResult`.
   - Both are guarded by `!COMPATIBLE_ATCODER_2025 && ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH`.
   - Tests: `RedBlackTreeSet_5_InsertionTests.swift:235,248` and
     `RedBlackTreeMultiMap_5_InsertionTests.swift:99,102`.
   - Adjacent naming in all four containers: `insert(_:)` returns
     `(inserted: Bool, memberAfterInsert: Element)`. That includes MultiSet (`RedBlackTreeMultiSet.swift:236`)
     and MultiMap (`:264,280`), where `inserted` is always `true`. The insertion family also has
     `insert(_:hint:)`, `update(with:)`, and `updateValue(_:forKey:)`.
2. **Call-site reading.**
   - `let (inserted, i) = set.index(inserting: x)` reads as "the index, inserting x". The argument
     label states the side effect, and the base name states the primary result.
   - The cost: Swift API guidelines say methods with side effects should read as imperative verb
     phrases, and `index(…)` is otherwise a non-mutating family (`index(after:)`, `index(forKey:)`).
     This is acceptable here. `mutating` is enforced by the compiler, so it cannot be called on a
     `let` or used as a silent query, and the label `inserting:` makes the mutation explicit.
   - The verb-led alternatives are worse:
     - `insertAndReturnIndex(_:)` is procedural; "AndReturn" restates the return type.
     - `insertReturningIndex(_:)` is non-idiomatic. It also reads like a variant of `insert(_:)`
       while returning a different shape, which invites confusion with the SetAlgebra
       `insert(_:)`, whose return type cannot change (the source comment notes this).
     - `ensureIndex(for:)` is dishonest for MultiSet/MultiMap, which always add a new occurrence;
       "ensure" implies idempotence.
     - Overloading `insert(_:)` by return type alone would be ambiguous under
       `@discardableResult`.
   - No materially better candidate exists.
3. **Semantic split.** One name stays honest across all four containers:
   - Set and Dictionary may return an existing position with `inserted == false`, which matches
     `Set.insert`.
   - MultiSet and MultiMap always insert and return the new occurrence.
   - "inserting" names the attempted action in both cases, exactly as `insert(_:)` already does
     across the same four containers.
4. **The return contract is not blocking; precedent settles it.** Every container's `insert(_:)`
   already keeps `inserted` even where it is constantly `true`, so the uniform
   `(inserted: Bool, index: Index)` shape should be kept for all four. Settle these points
   alongside the expansion:
   - **(a) Bug to fix with the expansion.** The MultiMap doc comment is copied from Set. It says
     "inserting it if necessary" and "If an equivalent element is already present, `inserted` is
     `false`…". Both are false for MultiMap. The MultiSet/MultiMap doc should say that a new
     occurrence is always inserted, that `inserted` is always `true`, and that `index` refers to
     the new occurrence.
   - **(b) Dictionary must specify existing-key behaviour.** Follow `insert(_:)`: the stored value
     is not replaced, and `index` refers to the existing pair. The overwrite form remains
     `updateValue(_:forKey:)`. Without this sentence, "inserting" is ambiguous for a key-value
     container.
   - **(c)** `@discardableResult` can stay. The method's purpose is the index, but discarding it
     degrades only to an ordinary insert.
5. **`erase(exactly:)`.** It pairs consistently:
   `let i = s.index(inserting: x).index; …; s.erase(exactly: i)`. The `erase` verb plus a
   distinguishing label is the library's existing removal style, and it returns the successor
   `Index?`. Its spelling does not make `index(inserting:)` misleading, so no redesign is needed.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows only
`Maintanance/CLAUDE_TASK.md`.

---

Status at completion: Completed

## Completed assignment: review O(1) MappedValues single-Index operations

Independently review the current uncommitted change that removes the per-operation View-range
membership search from `RedBlackTreeMappedValuesView` subscript access and `swapAt(_:_:)`.

The product decision is fixed: as with standard Collection Index operations, an Index passed to a
single-Index operation must belong to the View; violating that precondition has unspecified
behavior. These operations must not pay O(log N) to prove View membership. The explicit
`isElement(at:)` query and range/Bound operations remain checked and are not part of this change.

### Required review

1. Confirm that removing the three `isElement(at:)` calls eliminates key comparisons from the
   getter, setter, and `swapAt(_:_:)` normal paths.
2. Trace `_unsafeAddress`, `_unsafeMutableAddress`, `__purified_`, and the `accessible` result far
   enough to determine whether invalidated, stale/recycled, detached, end, and otherwise
   unresolvable indices still fail without unsafe memory access, including under `-Ounchecked`.
3. Check CoW index migration in the setter and `swapAt(_:_:)`; in particular, verify that an Index
   accepted before `_ensureUnique()` still resolves to the corresponding node after a copy.
4. Review the three removed death tests. Confirm that same-tree-but-outside-View cases, including a
   View `endIndex` that is still a base-tree element, must no longer assert a controlled trap.
5. Check that the new comparison-count regression test actually isolates the three single-Index
   operations and cannot pass while an O(log N) membership search remains.
6. Check the source comments and `API-Matrix-View.md` against the fixed contract. Flag any claim
   that is broader than the implementation or inconsistent with cross-tree configurations.
7. Run the focused MappedValues tests and a normal Xcode build if available. Do not broaden this
   into the unresolved Comparable/Index PoC design or range-operation redesign.

Return exactly one verdict: `approve O(1) MappedValues Index operations`, `approve after specified
corrections`, or `reject O(1) MappedValues Index operations`. Record concise evidence under a
`### Result` subsection below, set `Status: Completed`, and tell the user only `完了` unless a
product-owner decision is required.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Review all four current changed implementation,
test, and documentation files plus the minimum Index-validation dependencies needed for the safety
trace. Do not edit source/tests/docs, switch branches, inspect `try/index/1`, use network access,
stage, commit, push, or alter Git history. Do not run the full test suite. Run `git diff --check`
and inspect `git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified corrections`.

The implementation change is correct. Both corrections are test-only, and neither is a safety
regression.

1. **Key comparisons are gone from the normal paths.**
   - The removed `isElement(at:)` (`RedBlackTreeMappedValuesView.swift:362`) called
     `_NodeKey.isInHalfOpenRange`. That function calls `lessThan`, which compares
     `_NodeKey(.key(Base._Key))` values, that is, key `<`.
   - After the change, the getter, setter, and `swapAt` paths are `__purified_` → `.accessible` →
     pointer only. None of them makes a key comparison.
2. **Unresolvable indices still fail safely, including under `-Ounchecked`.**
   - The getter goes through `_unsafeAddress`; the setter goes through `_unsafeMutableAddress`
     (`UnsafeTreeV2+Subscript.swift:28-45`).
   - `_unsafeMutableAddress` switches on `__purified_(position).accessible` and calls `fatalError`
     on failure. That is not `precondition` or `!`, so `-Ounchecked` does not remove it.
   - `swapAt` uses `guard … .accessible.pointer else { fatalError }`.
   - Same tree: `index.sealed.purified` rejects a seal mismatch (stale or recycled) as `.unsealed`
     (`_NodePtrSealing.swift:100`).
   - Cross tree in the default config (`ALLOW_CROSS_TREE_INDEX` on, `USE_LAZY_DETACH` off):
     - `__retrieve_(tag).deepPurified` returns `.unknown` when the tag is at or beyond
       `initializedCount`.
     - `deepPurified` itself returns `.garbaged` for a node without payload, and `.unsealed` for
       a seal mismatch.
   - `.accessible` maps the end node and garbaged nodes to `.garbaged`.
   - The node memory being validated is kept alive by the index's `_LazyTie`.
   - This is the same validation `isElement(at:)` ran first; the removed code added only the
     range-membership test, never a safety check.
3. **CoW index migration is correct in the default config.**
   - `_ensureUnique()` copies the tree and re-retrieves `_sealed_start` / `_sealed_end`.
   - The caller's index still refers to the old tree, so `__purified_` takes the cross-tree path
     and resolves it by tracking tag in the copy.
   - The new test exercises this path, because `values` shares storage with `dictionary`.
   - Pre-existing, not a regression: without `ALLOW_CROSS_TREE_INDEX`, a caller's index taken
     before the copy fails with `.crossTree` after `_ensureUnique()`. The old code behaved the
     same way after its `isElement` check passed.
   - Cross-tree resolution walks the fresh-pool buckets (`_FreshPool.swift:112`). That is O(1)
     under the documented single-bucket-after-CoW invariant.
4. **The three removed death tests are correctly removed.** All three used indices that were valid
   base-tree elements but outside the View (`startIndex` below a lower bound, and the View's
   `endIndex` while it was still a base element). Under the fixed contract these are
   unspecified-behaviour cases, and they are memory-safe because the nodes are live, so no
   controlled trap can be required of them.
5. **The comparison-count test does isolate the three operations.**
   - Against the old code it would fail: `lessThan` short-circuits only when the two nodes are
     equal. `first` equals the View's start node, but it is still compared with the View's end,
     `upper`, which is a base element with key 4. So the getter, setter, and `swapAt` would each
     count at least one `<`.
   - Robustness note: the test depends on `upper` being a base element. If the View's end were
     `.end`, no key `<` would run, and an O(log N) check could slip through.
6. **Docs are consistent with the contract.** The doc comments (`Precondition` / `Complexity: O(1)`)
   and `API-Matrix-View.md` match it. "対象のtreeで要素へ安全に解決できないIndexは下層のIndex検証で拒否する" is no
   broader than the implementation:
   - In the no-cross-tree configuration, a CoW-copied index is one that cannot be resolved, so it
     is rejected.
   - An index from an unrelated tree can resolve to an unrelated live node. That is memory-safe,
     and `UnsafeIndexV3.swift` already documents it as unspecified.
7. **Validation.**
   - `swift build --disable-sandbox --build-tests`: succeeded.
   - `swift test --skip-build --filter RedBlackTreeMappedValuesViewTests`: 17 tests, 0 failures.
     The new `test_subrangeValuesSingleIndexOperations_doNotCompareKeys` was discovered and passed.
   - No Xcode build and no full suite were run.

**Corrections (tests only):**

- **(a)** With the three removals, no MappedValues test remains that pins the safety half of the
  contract. Add death tests to `RedBlackTreeDictionary_99_DeathTests.swift`, each using
  `observing: [\.standardErrorContent]` plus `expectNoInvalidMemoryAccess`. They should check that
  the following terminate without invalid memory access:
  - `values[i]` where `i` was erased from the base;
  - `values[i] = v` where `i` was erased from the base;
  - `values.swapAt(i, j)` with a stale `i`;
  - `values[dictionary.endIndex]`.
- **(b)** In the new test:
  - Add a one-line comment saying why `upper` must be a base element.
  - Assert the results after the setter and `swapAt`: `values` should read `"changed"` and then
    swapped, and `dictionary` should be unchanged. That pins the CoW migration that the test
    already exercises.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows the
four reviewed files plus this one.

### Codex follow-up

Both requested test corrections were applied. Four focused death tests now pin rejection without
invalid memory access for erased indices in getter/setter/`swapAt` and for the base tree's
`endIndex`. The comparison-count test now explains why its upper bound must remain a live base-tree
element and verifies the setter result, swap result, and unchanged original dictionary across CoW.

Xcode verification: the complete `RedBlackTreeMappedValuesViewTests` class (17 tests) plus the four
new death tests passed, 21/21 total. Build-for-testing also succeeded.

---

Status at completion: Completed

## Completed assignment: independently verify X1 inventory batch 4

Independently verify only `CUR-WRAP-001` and `POC-WRAP-001` in
`Maintanance/INDEX_POC_CROSS_BRANCH_IDENTITY.md`.

Inspect lines 23–38 of
`Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap.swift` at the fixed current
(`aecbcddf240c…`) and PoC (`1b126ba370ba…`) anchors. Check the exact generic type declaration,
access, attributes, stored-property declarations, initializer declaration, line numbers, and local
compile-time guards.

Confirm that both rows remain separate identities and both semantic fields remain `unknown`. Do not
inspect or interpret extensions, conformances, method bodies beyond the initializer assignments,
alias use sites, `_LazyTie`, `_NodePtrSealing`, or comments as design intent. Identical declaration
text is not a semantic-correspondence decision.

Return exactly one verdict: `approve X1 inventory batch 4`, `approve after specified corrections`,
or `reject X1 inventory batch 4`. Record the result below, set `Status: Completed`, and give the
user only a short completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the identity map or any other file. Do
not switch branches, inspect other paths or line ranges, infer semantic correspondence, run builds/
tests/benchmarks, use network access, stage, commit, or alter Git history. Use read-only `git show`
for the exact anchors/path/range and run `git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve X1 inventory batch 4`.

I read only lines 23–38 of `_LazyTieWrap.swift`, using `git show` at `aecbcddf240c…` and
`1b126ba370ba…`. I did not read any extension, conformance, use site, `_LazyTie`, or
`_NodePtrSealing`.

1. **The declarations match the evidence cells.** At both anchors:
   - Line 24 is `@frozen`.
   - Line 25 is `public struct _LazyTieWrap<RawValue> {`. The generic parameter has no constraint.
   - Lines 27–28 are `@usableFromInline` and `package let rawValue: RawValue`.
   - Lines 30–31 are `@usableFromInline` and `package let lazyDetach: _LazyTie`.
   - Lines 33–34 are `@inlinable` and `package init(rawValue: RawValue, lazyDetach: _LazyTie)`.
   - Lines 35–36 assign both stored properties.
   - Line 38 closes the struct.
   - Line 23 is a comment, which I did not inventory.
2. **No guard applies.** Neither anchor has an `#if` in lines 1–38, so both rows are correctly
   described as unconditional.
3. **The evidence is mechanical.** Lines 23–38 are byte-identical at the two anchors (`diff` shows
   no differences). Both Evidence cells state only the visible declarations. They do not turn the
   identical text into a correspondence claim.
4. **The rows stay separate.** `CUR-WRAP-001` and `POC-WRAP-001` are distinct identities by side
   and commit. Role/era and Semantic status are `unknown` in both, and neither row names the other.

Checks: `git diff --check` was clean. Only this file was edited.

---

## Completed assignment: independently verify X1 inventory batch 3

Independently verify only `POC-NODEPTR-001` in
`Maintanance/INDEX_POC_CROSS_BRANCH_IDENTITY.md`.

Inspect `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap.swift` at the fixed
current (`aecbcddf240c…`) and PoC (`1b126ba370ba…`) anchors. Check the exact enclosing extension,
declaration, access, attributes, alias target, line numbers, and local compile-time guards. Verify
mechanically whether the current anchor has a `_NodePtr` declaration in this same path.

You may mechanically list other `_NodePtr` declarations to demonstrate name multiplicity, but do
not inspect their contents or propose any as a counterpart. This batch must not decide whether the
PoC declaration is `one-sided`, moved, duplicated, obsolete, or semantically related to another
same-named alias. Its semantic fields must remain `unknown`.

Return exactly one verdict: `approve X1 inventory batch 3`, `approve after specified corrections`,
or `reject X1 inventory batch 3`. Record the result below, set `Status: Completed`, and give the
user only a short completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the identity map or any other file. Do
not switch branches, inspect unrelated file contents, infer semantic correspondence, run builds/
tests/benchmarks, use network access, stage, commit, or alter Git history. Use read-only `git show`
for the exact path and `git grep` only to count/list same-named declarations. Run
`git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve X1 inventory batch 3`.

I read `_LazyTieWrap.swift` with `git show` at `aecbcddf240c…` and `1b126ba370ba…`. For name
multiplicity I listed matching declarations with `git grep`, and did not open any of the listed
files.

1. **The declaration matches the row.**
   - At the PoC anchor, the enclosing declaration is line 105:
     `extension _LazyTieWrap where RawValue == _NodePtrSealing {`, with no attributes and no access
     modifier. It closes at line 137.
   - Line 107 is `public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>`, with no
     attributes.
   - The row's "Lines 105–107", the extension text, the alias target, and "no attributes" are all
     exact.
2. **No compile-time guard applies.** The PoC file has three `#if DEBUG` blocks, at 52–68, 87–103,
   and 139–146. The extension at 105–137 lies between the second and third blocks, so it is not
   inside any guard. "Unconditional extension declaration in the inspected file" is correct.
3. **The current anchor has no `_NodePtr`.** At `aecbcddf`, this path has 101 lines and contains
   no `_NodePtr` token at all. The row's last sentence is correct.
4. **Name multiplicity (listing only).** With `git grep -E 'typealias +_NodePtr( |=|:|$)'` over
   `Sources`:
   - The current anchor has 15 typealias declarations named `_NodePtr`.
   - The PoC anchor has 16.
   - Both anchors also have one `associatedtype _NodePtr`, at `__tree/_types/tree_basic+types.swift:55`.
   - The only path that appears at one anchor and not the other is `RawBuffer/_LazyTieWrap.swift:107`
     (PoC). The other 15 paths and line numbers appear at both anchors.

   This shows the name is widely reused. I made no counterpart, move, duplicate, `one-sided`, or
   obsolescence judgment.
5. **The row is held at unknown.** It is a separate PoC-side identity, Role/era and Semantic
   status are both `unknown`, and no counterpart is named.

Checks: `git diff --check` was clean. Only this file was edited.

---

## Completed assignment: independently verify X1 inventory batch 2

Independently verify only `CUR-ALIAS-001`, `CUR-ALIAS-002`, `POC-ALIAS-001`, and
`POC-ALIAS-002` in `Maintanance/INDEX_POC_CROSS_BRANCH_IDENTITY.md`.

Inspect these two paths at the fixed current (`aecbcddf240c…`) and PoC (`1b126ba370ba…`) anchors:

- `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap+Result.swift`
- `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap.swift`

Check the exact typealias declarations, access, attributes, line numbers, alias targets, and local
compile-time guards. Confirm that the evidence is purely mechanical, all four rows remain separate,
and both semantic fields remain `unknown`. Report whether either file contains another declaration
that must be inventoried to describe these two alias declarations themselves; do not widen into the
implementation or conformances of `_LazyTieWrap`, `_NodePtrSealing`, `SealError`, or `Result`.

Do not infer semantic correspondence merely because declaration text matches across anchors. Do not
judge usage, intent, adoption, obsolescence, or implementation behavior.

Return exactly one verdict: `approve X1 inventory batch 2`, `approve after specified corrections`,
or `reject X1 inventory batch 2`. Record the result below, set `Status: Completed`, and give the
user only a short completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the identity map or any other file. Do
not switch branches, inspect other paths, follow alias targets or extensions, generate wider
inventories, run builds/tests/benchmarks, use network access, stage, commit, or alter Git history.
Use read-only `git show` for the two exact paths and anchors, and run `git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve X1 inventory batch 2`.

I inspected only the two stated paths with `git show`, at `aecbcddf240c…` and `1b126ba370ba…`. I
did not follow alias targets or extensions.

1. **The declarations match the evidence.**
   - In `_LazyTieWrap+Result.swift`, both anchors have line 33
     `public typealias _LazyTieWrappedPtr = Result<_LazyTieWrap<_NodePtrSealing>, SealError>`.
   - In `_LazyTieWrap.swift`, both anchors have line 41
     `public typealias _LazyTiedPtr = _LazyTieWrap<_NodePtrSealing>`.
   - All four declarations are top-level and have no attributes. Lines 23–32 and 40 are plain
     comments only.
2. **No guards apply.** In each file and at both anchors, the first `#if` comes after the alias:
   - `_LazyTieWrap+Result.swift`: the first `#if` is at line 64, inside an extension.
   - `_LazyTieWrap.swift`: the first `#if` is at line 51 (current) or 52 (PoC).

   So all four rows are correctly described as unconditional in the inspected file.
3. **The evidence is mechanical.** Each cell gives only a line number and the alias target. It
   reads nothing into the matching text on both anchors.
4. **The rows are kept apart.** All four are separate identities by side and commit. Role/era and
   Semantic status are both `unknown`, and no row names a counterpart.
5. **Nothing else is needed to describe these two aliases.** One note, outside this batch's
   scope: at the PoC anchor, `_LazyTieWrap.swift` contains another public typealias,
   `public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>`, at line 107. It sits inside an
   `extension _LazyTieWrap where RawValue == _NodePtrSealing` that begins at line 105. At the
   current anchor this file has only one typealias. The `_NodePtr` declaration is not needed for
   these four rows, but a later batch should give it its own PoC-side identity row.

**Optional.** For consistency with the batch-1 correction, the four Evidence cells could add "no
attributes". This is not a correction.

Checks: `git diff --check` was clean. Only this file was edited.

---

## Completed assignment: independently verify X1 inventory batch 1

Independently verify only the four identity rows `CUR-IDX-001`, `CUR-IDX-002`, `POC-IDX-001`, and
`POC-IDX-002` in `Maintanance/INDEX_POC_CROSS_BRANCH_IDENTITY.md`.

Inspect this single path at the two fixed anchors:

- current: `aecbcddf240cc039db9eac92b46721a1fde0532a`
- PoC: `1b126ba370ba78aa90b1241ac83d888ed3861bf4`
- path: `Sources/RedBlackTreeCollections/Implements/Index/UnsafeIndexV3.swift`

Check independently:

1. The exact declarations, access, attributes, and alias targets.
2. Whether each declaration is guarded in this file by any compile-time condition.
3. Whether the evidence text states only mechanically visible facts.
4. Whether current and PoC rows remain separate identities with semantic status `unknown`.
5. Whether any additional declaration in this file requires its own identity row.

Do not propose semantic correspondence between rows, interpret comments as user intent, judge one
side newer/better/obsolete, or inspect alias-target implementations. Shared symbol names are not
evidence of shared meaning.

Return exactly one verdict: `approve X1 inventory batch 1`, `approve after specified corrections`,
or `reject X1 inventory batch 1`. Record the result below, set `Status: Completed`, and give the
user only a short completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the identity map or any other file. Do
not switch branches, inspect other branch paths, follow alias targets, generate a wider symbol
inventory, run builds/tests/benchmarks, use network access, stage, commit, or alter Git history.
Use read-only `git show` for the exact anchors and path above, and run `git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified corrections`. One evidence
correction is needed, for `POC-IDX-001`.

I inspected only the stated path with `git show`, at `aecbcddf240c…` and `1b126ba370ba…`. I did not
follow any alias target.

1. **Declarations.**
   - **Current side:**
     - Line 26: `@_documentation(visibility: internal)`.
     - Line 27: `public typealias UnsafeIndexV3 = _LazyTieWrappedPtr`.
     - Line 30: `public typealias RedBlackTreeIndex = UnsafeIndexV3`, with a `///` doc comment on
       line 29.
   - **PoC side:**
     - Line 26: the commented-out line `//public typealias UnsafeIndexV3 = _LazyTieWrappedPtr`.
     - Line 30: `public typealias UnsafeIndexV3 = _LazyTiedPtr`. It has **no attribute**.
     - Line 33: `public typealias RedBlackTreeIndex = UnsafeIndexV3`, with a `///` doc comment on
       line 32.
2. **Guards.** Neither file contains any `#if`, so all four declarations are unconditional in this
   file. The rows say this correctly.
3. **Evidence text.**
   - `CUR-IDX-001`, `CUR-IDX-002`, and `POC-IDX-002` state only visible facts.
   - `POC-IDX-001` has two problems:
     - It omits the visible fact that the PoC declaration carries no `@_documentation` attribute.
       On the current side this attribute is part of `CUR-IDX-001`'s evidence, so leaving it out
       of `POC-IDX-001` would let a reader assume the two declarations have the same attributes.
     - "the `_LazyTieWrappedPtr` form remains commented out" contains a history claim ("remains").
       Only the commented-out text itself is visible in the file.
4. **Separation.** All four rows are separate identities, keyed by side and commit, and each has
   `unknown` in both Role/era and Semantic status. No row references another as a counterpart.
5. **Other declarations.** None. The rest of both files is comments (lines 23–25 and 32–62 on
   the PoC side, 23–25 and 32–56 on the current side). Comments are not inventoried as intent,
   per the task.

**Correction.** Replace the `POC-IDX-001` Evidence cell with:

> Alias target is `_LazyTiedPtr` (line 30); the declaration has no attributes; line 26 is a
> commented-out `public typealias UnsafeIndexV3 = _LazyTieWrappedPtr`

**Optional.** Add line numbers to the other three Evidence cells, for consistency:
- `CUR-IDX-001`: lines 26–27
- `CUR-IDX-002`: line 30
- `POC-IDX-002`: line 33

Checks: `git diff --check` was clean. Only this file was edited.

---

## Completed assignment: review the X1 identity-map skeleton

Perform a read-only review of the newly created
`Maintanance/INDEX_POC_CROSS_BRANCH_IDENTITY.md`. This review covers the map structure and
mechanical provenance only. It must not begin semantic correspondence or PoC validation.

Check the following:

1. Verify the listed commit hashes, dates, parent relationships, current tips, and merge base using
   commit metadata only.
2. Verify that the mechanical PoC-side path inventory matches
   `git diff --name-status b3570172..try/index/1` without interpreting file contents.
3. Confirm that the identity key (`branch + commit + path + symbol + configuration`) and the
   configuration dimensions are sufficient to prevent same-name conflation.
4. Confirm that every semantic status remains user-controlled and that neither Codex nor Claude is
   authorized to promote `unknown` to another state.
5. Check that the user-intent questions ask only for intent that source/history cannot establish;
   flag questions that unnecessarily ask the user to reconstruct mechanical facts.
6. Check that the mandatory stops and review sequence faithfully implement the agreed X1 row in
   `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`.
7. Identify any wording that accidentally treats the PoC as obsolete, treats current HEAD as
   authoritative by default, or implies semantic identity from a shared name or path.

Return exactly one verdict: `approve X1 identity skeleton`, `approve after specified corrections`,
or `reject X1 identity skeleton`. For corrections, cite the exact section and replacement wording.
Record the result below, set `Status: Completed`, and give the user only a short completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the identity map, task-fit table,
progress document, source, tests, or any other file. Do not switch branches, inspect branch file
contents, generate symbol inventories, infer semantic correspondence, run builds/tests/benchmarks,
use network access, stage, commit, or alter Git history. Allowed Git operations are limited to
read-only commit metadata, `rev-parse`, `merge-base`, and `diff --name-status` for the anchors already
named in the identity map. Run `git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified corrections`.

The review was read-only. Git use was limited to `rev-parse`, `merge-base`, `log`/`rev-list`
commit metadata, and `diff --name-status` / `--name-only` between the named anchors. I did not read
any branch file contents.

#### 1. Anchors: verified

- **Tips.** `develop/misc/48` = HEAD = `aecbcddf` (2026-10-05 04:07, parent `c04fec93`).
  `try/index/1` = `1b126ba3` (2026-10-04 20:25, parents `a250c677` and `b3570172`).
- **Merge base.** `merge-base` returns `b3570172` (2026-10-04 20:06), which is the second parent of
  `1b126ba3`, as stated.
- **PoC commits.** `005a7bb3` (2026-09-24 22:46) has parent `49de7dd9`. `a250c677` (2026-09-27
  06:29) is the first parent of the sync merge.

Two mechanical facts are missing from the anchor table:

- **The branch has two earlier sync merges.** Both are before the center commit:
  `8d5f9928` (09-24 22:04, merges `main`) and `49de7dd9` (09-24 22:05, merges
  `develop/misc/35`). So `49de7dd9`, the "Parent of the center commit", is itself a merge. And
  "Last pre-sync PoC commit" is ambiguous, because there are three sync merges, not one.
- **Where the PoC starts.** It has 24 branch-unique first-parent commits (`try/index/1 --not
  develop/misc/48`). The earliest is `21bdd758` (09-24 19:40, `memo`). The commits from 15:44 to
  15:56 that `RED_BLACK_TREE_REMAINING_TASKS.md` dates as the start of the work are reachable from
  `develop/misc/48`, so they are not branch-unique.

#### 2. Path inventory: verified, with one gap

- `git diff --name-status b3570172..try/index/1` returns exactly the 24 listed paths, and all
  24 are `M`. There are no `A`, `D`, or `R` entries, which is worth recording.
- **Gap: the current side is missing.** `b3570172..aecbcddf` changes 45 paths. Five paths
  changed on **both** sides since the merge base:
  - `Maintanance/CLAUDE_TASK.md`
  - `RedBlackTreeBoundExpression.swift`
  - `RedBlackTreeMappedValuesView.swift`
  - `RedBlackTreeRangeView+KeyOnly.swift`
  - `RedBlackTreeRangeView+KeyValue.swift`

  These are the paths where same-path conflation is most likely, because the content has
  already diverged after the sync.

#### 3. Identity key and configuration: correction needed

The key is right. The configuration list has two problems:

- **It omits defines that change compiled Index-related code:** `BENCHMARK`, which exposes public
  Index-returning hooks; `USE_INT128`, which selects the ptr-bitmap path in `__MultiHelper`;
  `ENABLE_LEGACY_TREE_LOWER_UPPER_BOUND`; and `DEATH_TEST` / `ENABLE_DEATH_TESTS` on the test
  side.
- **It assumes configuration names mean the same thing on both branches.** That is itself a
  same-name assumption, and `Package.swift` differs on the PoC side.

#### 4. Status control: confirmed

Every status is closed by the user, and "must not promote a row out of `unknown`" is explicit.
One structural conflict: the **Symbol identity table** has a `Proposed counterpart` column, but
review step 1 says to populate it "without semantic pairing". The `Role / era` column is also an
interpretation if Codex or Claude fills it in step 1.

#### 5. User-intent questions: one asks for mechanical facts

The first six questions ask about intent. The seventh, "What conflicts were resolved during the
2026-10-04 sync merge", asks the user to recall something mechanical: the conflict set can be
recovered from the merge and its two parents. Only the second half of the question (intent versus
restoring compilation) is a question for the user.

#### 6. Stops and sequence: faithful

All seven agreed stopping points from the corrected X1 row are present, including the 10-04
conflict intent, a failing Quality Checklist item, and raw performance data only. The sequence
keeps Claude's extraction independent, keeps correspondence undecided by the agents, gates on the
user, and validates one representative before expanding.

#### 7. Wording

Nothing treats the PoC as obsolete, and no correspondence is inferred from a shared name. One
phrase can be read as making HEAD the reference standard: "validating ... `try/index/1` PoC
against the current development branch".

#### Corrections (section → replacement)

1. **§Fixed anchors.**
   - Rename the row "Last pre-sync PoC commit" to "Last PoC commit before the 2026-10-04 sync merge".
   - Add these rows:
     - `21bdd758…` (2026-09-24 19:40), Role: "Earliest branch-unique first-parent commit
       (`try/index/1 --not develop/misc/48`)".
     - `8d5f9928…` (2026-09-24 22:04), Role: "Earlier sync merge (`main`) before the center commit".
     - `49de7dd9`'s Role: append "; itself a sync merge of `develop/misc/35`".
2. **§Mechanical PoC-side path scope.**
   - Add after the first paragraph: "All 24 entries are `M`; there are no added, deleted, or
     renamed paths."
   - Add a subsection **"Paths changed on both sides since `b3570172`"** listing the five paths
     above, with: "Same-path content has diverged on both sides after the sync; treat every symbol
     in these files as a separate identity on each side."
   - Optionally add the full current-side inventory (`b3570172..aecbcddf`, 45 paths).
3. **§Identity rule.**
   - Replace "Configuration includes, when applicable:" with "Configuration is the define/trait set
     declared by that commit's `Package.swift`; a configuration name is not assumed to mean the
     same on both branches. Dimensions include, when applicable:".
   - Add the following to the list: `BENCHMARK`, `USE_INT128`,
     `ENABLE_LEGACY_TREE_LOWER_UPPER_BOUND`, and `DEATH_TEST` / `ENABLE_DEATH_TESTS` (tests).
4. **§Symbol identity table.**
   - Remove the `Proposed counterpart` column; pairing belongs only in the Correspondence proposal
     table.
   - Rename `Role / era` to `Role / era (user-supplied; otherwise unknown)`.
5. **§Required user-intent checkpoints, last bullet.** Replace it with: "For each conflict
   resolution in the 2026-10-04 sync merge (listed mechanically beforehand from the merge and its
   two parents), did the resolution express design intent, or only restore compilation?"
6. **§Purpose, first sentence.** Replace it with: "This document is the entry gate for X1:
   reconstructing the user-authored `try/index/1` PoC and validating it, on top of the current
   development branch, against the Quality Checklist."

Checks: `git diff --check` was clean. Only this file was edited. Nothing was staged.

---

## Completed assignment: agreement check for the integrated X1 task-fit row

Perform a read-only agreement check of Codex's integration of your preceding X1 interview.
Do not inspect or compare `try/index/1`; this task concerns only whether the recorded role split
faithfully represents the interview.

Review:

- the new `X1` row in `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`;
- the new X1 identity-table prerequisite in `Maintanance/PROGRESS_OVERVIEW.md`.

Confirm only these points:

1. Your overall rating `3` and label `見本またはレビュー必須` are represented accurately.
2. Mechanical history extraction, symbol inventory, test mapping, and adversarial review are the
   parts Claude may own, while semantic correspondence and integration judgment are not assigned
   to Claude.
3. Codex is not treated as a sole reliable owner: it drafts the identity-table skeleton and
   correspondence rationale, but the workflow requires independent Claude evidence and user
   decisions for semantic identity and design intent.
4. The identity key `branch + commit + path + symbol + configuration`, and keeping semantic
   correspondence `unknown` until user confirmation, are appropriate X1 entry conditions.
5. The row preserves the mandatory stopping points from your interview rather than authorizing
   horizontal expansion from an uncertain correspondence.

Return exactly one verdict: `agree with X1 integration`, `agree after specified corrections`, or
`do not agree with X1 integration`. If a correction is needed, identify the exact phrase and its
replacement. Record the result below, set `Status: Completed`, and give the user only a short
completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the task-fit table, progress document,
source, tests, or any other file. Do not switch branches, inspect `try/index/1`, run builds/tests/
benchmarks, use network access, stage, commit, or alter Git history. Run `git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `agree after specified corrections`. There is one small
correction, to point 5. Points 1–4 are faithful.

1. **Rating and label.** Agree. The Claude column has `3` and the label `見本またはレビュー必須`, and
   the cell's sub-scores match my interview: 履歴採取5, symbol inventory 4, test mapping 4,
   反証4, semantic correspondence 2, 統合判断1.
2. **Ownership.** Agree. The 担当案 assigns Claude independent collection of history, symbols, and
   tests, plus refutation. Semantic correspondence and integration judgment are not assigned to
   Claude. Two of my interview items are omitted from the row: Quality Checklist evidence and raw
   measurement under fixed procedure. Both were conditional in the interview, so leaving them out
   of the summary row is acceptable.
3. **No sole owner.** Agree. The Codex cell says 「全体を単独所有しない」, and the 担当案 ends with the
   user deciding semantic identity and design intent.
4. **Entry conditions.** Agree. The key `branch + commit + path + symbol + configuration`, with
   semantic identity kept `unknown` until user confirmation, is the right entry gate. The
   PROGRESS item records it before X1 validation.
5. **Stopping points.** Correction needed. The Claude cell keeps four of my seven stopping points.
   It drops the one that is specific to X1: an unwritten intent behind a conflict resolution in
   the 10-04 sync merge. It also drops "a failing Quality Checklist item is reported, not fixed"
   and "performance as raw data only". The row does not authorize horizontal expansion from an
   uncertain correspondence. However, once this task file rotates to history, the row will be the
   only durable copy of the stopping list.

**Replacement (Claude cell, last sentence):**

- Current: 「曖昧な対応・obsolete判定・安全性信号・最初のcontainer/Viewからの横展開前に停止する」
- Replace with: 「曖昧な対応・obsolete判定・安全性信号・意図未記録の10-04 merge解決・Quality Checklist
  不合格（修正せず報告）・最初のcontainer/Viewからの横展開前に停止する。性能は生データのみ提出する」

Checks: read-only. `git diff --check` was clean. Only this file was edited.

---

## Completed assignment: task-fit interview for cross-branch Index archaeology

This is a capability and workflow interview only. Do not newly inspect or compare `try/index/1`
in this assignment.

We are preparing to revalidate a user-authored Index PoC that began on 2026-09-24. Claude has
already inspected this branch once and assisted with repairing / updating its merge from the current
development branch on 2026-10-04; this is not first exposure. Use that concrete experience in the
self-assessment. The difficult part is not ordinary Git history: identically named files, types,
aliases, resolvers, and operations may represent different designs or eras on the two branches, and
`Index` propagates across nearly the entire RedBlackTreeCollections surface. Both Codex and Claude
are prone to incorrectly unifying same-named but semantically different things.

The proposed new task category is:

> Cross-branch reconstruction and present-day validation of a long-lived, user-authored PoC where
> same-named components may have different semantics and the changed concept propagates across the
> public API, internal safety machinery, tests, and documentation.

Answer the following based on your observed strengths and failure modes in this repository:

1. Does an existing task-fit category in `Maintanance/AGENT_TASK_FIT_INTERVIEW.md` adequately cover
   this work? If not, propose a new ID and short task name.
2. Rate your suitability from 1 to 5. Use the existing scale; do not raise the score because the
   task is important.
3. Identify the exact parts you can own safely: mechanical history extraction, symbol inventory,
   semantic correspondence, test mapping, Quality Checklist verification, performance measurement,
   adversarial review, or integration judgment.
4. Identify your likely failure modes, especially same-name/different-semantics conflation,
   treating an older implementation as obsolete, and spreading one mistaken correspondence across
   all containers and Views.
5. State what the earlier inspection and merge repair did and did not establish, then state the
   minimum input you need from Codex and the user before re-inspecting the branch. Consider whether
   a branch+commit+path+symbol identity table and explicit design-intent notes are required.
6. Propose mandatory stopping points where disagreement or ambiguous correspondence must be returned
   to the user instead of inferred.
7. Recommend a division of work among user, Codex, and Claude. Do not assume either agent can safely
   own the entire reconstruction.
8. State whether the eventual PoC validation should require an independent double review, and which
   evidence each reviewer must produce independently.

Give one final task-fit label using the existing vocabulary: `主担当可`, `見本またはレビュー必須`,
or `補助のみ`. A low or conditional rating is acceptable and useful.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Record the answer below and set `Status: Completed`.
Do not edit the task-fit table or any other document. Do not switch branches, inspect
`try/index/1`, run builds/tests/benchmarks, use network access, stage, commit, or alter Git history.
This interview must not start the PoC validation.

### Result

2026-10-05, Claude Opus 5.5. Interview only. I did not inspect, compare, or switch to
`try/index/1`. The evidence comes from repository records (`CLAUDE_TASK_HISTORY.md`,
`RED_BLACK_TREE_REMAINING_TASKS.md` §`try/index/1`, `MAINTENANCE.md`) and my own observed
failure modes.

**Final label: `見本またはレビュー必須`. Overall rating: 3.**

#### 1. Category

No existing row covers this work.

- G (representation candidates), J (resolver), K (container/View follow-up), and V7 (unsafe
  migration history) each touch part of it.
- None of them covers establishing semantic correspondence between same-named components
  across two live branches.

Proposed new row: **X1: 長期PoCのcross-branch再構成と現行検証** (cross-branch reconstruction and
present-day validation of a long-lived, user-authored PoC).

#### 2–3. Rating by sub-part

| Sub-part | Claude | Owner? |
| --- | ---: | --- |
| Mechanical history extraction (commits, dates, `-M` renames, merge parents) | 5 | 主担当可, with hash/date/path always cited |
| Symbol inventory per branch × configuration (Debug/Release/compat, `ALLOW_CROSS_TREE_INDEX`/`USE_LAZY_DETACH`) | 4 | 主担当可, inventory only |
| Semantic correspondence (is A on branch X the same thing as A on HEAD?) | 2 | 補助のみ: propose evidence, never decide |
| Test mapping (which tests exercise which symbol on which branch) | 4 | 主担当可 after the identity table exists |
| Quality Checklist verification (per-item evidence, configurations) | 4 | 見本またはレビュー必須 |
| Performance measurement | 3 | Only under H/V6 conditions: interleaved runs, disassembly, raw data only, no interpretation |
| Adversarial review of Codex's correspondence/integration | 4 | Yes; this is where I add the most |
| Integration judgment (equivalence, obsolescence, adopt/reject) | 1 | Not mine |

The overall score is 3, not 4: the hard part of X1 is semantic correspondence, and that is
my weakest sub-part.

#### 4. Likely failure modes (with repository evidence)

- **Same-name conflation.** In T1 I nearly unified `UnsafeIndexV2.unsafe(tree:rawTag:)`
  across eras. The user's correction is recorded in memory as "同名でも時代/役割ごとの独立性を先に
  確認する". The risk is higher here, because both branches are current and the names were
  deliberately reused.
- **Classifying from names and structure.** Tonight, in the B3 audit, I called G1
  "witness-free" from its declaration shape. I had to self-correct after spotting associated-type
  inference in public positions. A wrong correspondence can look this plausible.
- **Treating the older implementation as obsolete.** My 2026-10-04 reuse evaluation already
  sorted items into "古くなった点" and "再利用を阻むもの". Some of those may be deliberate design
  choices (for example the Debug `.nullptr` sentinel or the duplicated overloads), not defects. I
  judged them against HEAD, not against the PoC's intent.
- **Spreading one mistake everywhere.** Horizontal expansion is my strength. With one wrong
  correspondence, it becomes the mechanism that replicates the error across 4 containers × 3 Views.
- **Explaining away safety signals.** The sanitizer TODO (an assert weakened via `isDetached`)
  is exactly the kind of thing I could rationalize as test noise.
- **Taking a green build as semantic evidence.** A merge that compiles and passes tests does not
  show that same-named code still means the same thing.

#### 5. What the earlier work established, and minimum input

- **Established** (2026-10-04 review, read-only diff from merge-base `7ae8237c`, 23 branch
  commits):
  - Replacing the Index alias with a success-only `_LazyTiedPtr` compiles for 4 containers and
    2 Views.
  - The internal `_SealedPtr` resolver keeps the cross-tree, unsealed, and detached diagnostics.
  - The list of reuse blockers: `try!`, the Debug `.nullptr` sentinel, the sanitizer TODO,
    missing MappedValuesView, stale paths, and duplicated overloads.
  - The branch is a partial Result-removal PoC, not a nominal-type PoC.
- **Not established:**
  - semantic equivalence of any same-named component across the branches;
  - Quality Checklist conformance (correctness, memory and Index lifetime, performance);
  - the cause of the sanitizer report;
  - behaviour after the 2026-10-04 20:25 sync merge (merge-base is now `b3570172`; my review
    predates it);
  - which of the "obsolete" items reflect user intent.
- **Merge repair:** the Markdown records I can see do not record what I changed during the
  2026-10-04 merge repair or why. That gap is itself evidence that X1 needs written provenance.
  Before re-inspection, the merge's conflict resolutions should be listed with their intent.
- **Minimum input:**
  - **Identity table** (Codex skeleton, user fills intent), one row per symbol of interest:
    - `branch`, `commit`, `path`, `symbol`, `configuration guards`;
    - `role/era`;
    - `HEAD counterpart` (or "none");
    - `same semantics? (yes / no / unknown)`, decided by the user or marked unknown;
    - `intent note`.
  - **User design-intent notes:** which differences are deliberate. At minimum:
    - `_LazyTiedPtr` vs `_LazyTieWrappedPtr`;
    - the Debug `.nullptr` sentinel;
    - why `limitedBy` converts failure to Optional/Bool;
    - the intended `==`/hash semantics;
    - the sanitizer TODO context.
  - **Scope from Codex:**
    - Keep the 09-24〜09-27 PoC commits separate from the 10-04 sync merge.
    - Allowed paths and configurations.
    - Inspection method (read-only `git show` / `git diff`; a worktree only in a task-owned temp
      directory, with user permission).
    - One sample container plus one View before any horizontal pass.

#### 6. Mandatory stopping points (return to the user, do not infer)

1. Any same-named symbol whose semantics differ or cannot be shown to match: mark it `unknown`
   and stop for that row.
2. Any item that looks obsolete. Report it with evidence; never classify it as obsolete myself.
3. After the first container + View sample, before extending a correspondence to the rest.
4. Any memory-safety sign: sanitizer report, weakened assert, lifetime-counter imbalance,
   unexpected `SIGSEGV`. Stop; do not work around it.
5. Any conflict resolution in the 10-04 merge whose intent is not written down.
6. Any failing Quality Checklist item. Report it; do not fix it in the same task.
7. Any performance difference. Raw data only; interpretation goes to Codex and the user.

#### 7. Division of work

- **User:** design intent; the `same semantics?` column; decisions on obsolescence and adoption;
  permission for worktree/temp inspection.
- **Codex:**
  - phase design and identity-table skeleton;
  - draft semantic correspondence with rationale;
  - integration draft and the Quality Checklist verdict draft.
- **Claude:**
  - mechanical extraction and per-configuration symbol inventory;
  - test mapping;
  - per-item Quality Checklist evidence;
  - adversarial review of Codex's correspondence;
  - raw measurements under fixed procedure.

Neither agent owns the whole reconstruction.

#### 8. Double review

Yes: independent and blind, with each reviewer producing evidence before reading the other's.

- **Codex:**
  - correspondence table with semantic rationale;
  - integration and adoption draft;
  - a Quality Checklist verdict per item.
- **Claude:**
  - an independent symbol inventory and diff by phase (PoC commits vs sync merge);
  - a list of counterexample or failing tests (written first, not fixed);
  - Quality Checklist evidence per configuration: Debug/Release, normal/compat, both
    `ALLOW_CROSS_TREE_INDEX`/`USE_LAZY_DETACH` settings, Death Tests, and sanitizer status.

Disagreements go to the user unresolved.

Checks: only this file edited. `git diff --check` clean. Nothing staged.

---

## Completed assignment: targeted review of Combining API performance notes

Perform a read-only review of the new public `- Note:` paragraphs in these three files:

- `Sources/RedBlackTreeCollections/RedBlackTreeSet/RedBlackTreeSet+Combining.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeMultiSet/RedBlackTreeMultiSet+Combining.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeMultiMap/RedBlackTreeMultiMap+Combining.swift`

Use `Maintanance/CombiningAPIPerformanceEvidence.md` sections 1–3 as the evidence source and
`Sources/RedBlackTreeCollections/Documentation/Quality-Checklist.md` as the quality policy.

Check only the following questions:

1. Does each statement accurately distinguish insertion-loop paths from `union` / `formUnion` /
   `meld` / `melding`, including the fact that the latter build new storage rather than reuse the
   receiver's spare capacity?
2. Do the Set and MultiSet notes stay within the recorded measurements instead of presenting a
   finite benchmark as a permanent performance guarantee?
3. Does either MultiMap note improperly extrapolate a Set- or MultiSet-only measurement to
   MultiMap? Structural implementation facts may be stated, but unmeasured timing conclusions may
   not be transferred.
4. Are the paired mutating and nonmutating notes attached to the correct same-type overloads?
5. Is the amount of detail acceptable for a public DocC `Note`, with detailed raw evidence kept in
   the maintenance document?

Return exactly one verdict: `approve Combining notes`, `approve after specified corrections`, or
`reject Combining notes`. For any correction, quote the affected API and provide replacement
wording. Record the result below, set `Status: Completed`, and give the user only a short completion
notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, progress documents,
evidence documents, API Matrix, DocC, Package.swift, workflows, benchmarks, or Git history. Do not
stage, commit, switch branches, inspect `try/index/1`, run benchmarks, or use network access. You may
inspect the named source files, the two named documents, and their uncommitted diffs. Run
`git diff --check`; build and tests are unnecessary because this is a wording-only review and Codex
has already completed an Xcode build.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified corrections`.

Checked against `CombiningAPIPerformanceEvidence.md` §1–3 and the current source.

1. **Paths are distinguished correctly.** Every note says the alternative "builds new storage".
   That matches §1: `___meld_unique` starts at `minimumCapacity: 2`, and `___meld_multi`
   allocates `count + other.count`. Neither reads the receiver's spare capacity.
2. **Set mutating note: within the measurements.**
   - "faster for disjoint input": merge beat formUnion at all three sizes (21.50/222.46/3646.00
     vs 45.04/482.38/8047.71).
   - "formUnion faster at 90% duplicates": also true at all three sizes (42.42/916.42/27168.67
     vs 28.04/300.25/4869.17).
3. **MultiSet notes overstate.** "consistently faster" reads as a general claim. MultiSet
   measured only disjoint, sorted, and shuffled `other`; duplicate-heavy and shared storage
   were not measured. One comparison (16k unreserved: 323.79 vs 470.50, ≈1.45×) is inside the
   ~1.5× band that §2 says is not significant. The claim needs the measured input shapes.
4. **Nonmutating notes transfer the mutating measurements.**
   - Only `merge` / `formUnion` and `insert(contentsOf:)` / `meld` were measured.
   - `merging` and `inserting(contentsOf:)` are `var result = self` followed by the mutating call,
     so they always copy the receiver first.
   - Set: the "merge, shared storage" case (4504 vs formUnion 7509 at 256k) supports the
     disjoint claim. The note should still say the measurement was of the mutating forms.
   - MultiSet: shared storage was not measured at all, so its nonmutating timing claim is
     unmeasured.
5. **MultiMap notes extrapolate.** "Relative performance depends on the input's ordering and
   the destination's storage-sharing state" is a timing conclusion. MultiMap was never measured.
   The ordering effect was measured on Set and MultiSet; storage sharing was measured only on
   Set. Only the structural facts may be stated.
6. **Overloads are correct.** Each note sits on the same-type overload: Set `merge(_: Set)` /
   `merging(_: Set)`; MultiSet and MultiMap `insert(contentsOf: Self)` /
   `inserting(contentsOf: Self)`. The mutating/nonmutating pairing (formUnion/union,
   meld/melding) is right.
7. **Detail level is acceptable for DocC.** One or two sentences; raw numbers stay in the
   evidence document. Minor readability point: in "that operation … this operation", the two
   pronouns refer to different APIs in adjacent sentences. "it" and "this method" are clearer.

#### Replacement wording

- `RedBlackTreeSet.merge(_:)` (optional, pronouns only):
  > - Note: Spare capacity does not make `formUnion(_:)` preferable; it builds new storage. In
  >   measurements through 256K elements, this method was faster for disjoint input, while
  >   `formUnion(_:)` was faster when 90% of `other` duplicated existing elements.
- `RedBlackTreeSet.merging(_:)`:
  > - Note: Spare capacity does not make `union(_:)` preferable; it builds new storage. This
  >   method copies the current storage before inserting. In measurements of the mutating forms
  >   through 256K elements, `merge(_:)` was faster for disjoint input, even when it first copied
  >   shared storage, while `formUnion(_:)` was faster when 90% of `other` duplicated existing
  >   elements.
- `RedBlackTreeMultiSet.insert(contentsOf:)`:
  > - Note: Spare capacity does not make `meld(_:)` preferable; it builds new storage. In
  >   measurements through 256K elements with disjoint, sorted, and shuffled `other`, this method
  >   was faster in each case, although the construction order of `other` materially affected
  >   both operations.
- `RedBlackTreeMultiSet.inserting(contentsOf:)`:
  > - Note: Spare capacity does not make `melding(_:)` preferable; it builds new storage. This
  >   method copies the current storage before inserting. Only the mutating forms were measured:
  >   through 256K elements with disjoint, sorted, and shuffled `other`, `insert(contentsOf:)` was
  >   faster than `meld(_:)` in each case.
- `RedBlackTreeMultiMap.insert(contentsOf:)`:
  > - Note: Spare capacity does not make `meld(_:)` preferable; it builds new storage. This
  >   method inserts into the existing storage, copying it first if it is shared.
- `RedBlackTreeMultiMap.inserting(contentsOf:)`:
  > - Note: Spare capacity does not make `melding(_:)` preferable; it builds new storage. This
  >   method copies the current storage before inserting.

Checks: inspected the three source diffs and evidence §1–3. `git diff --check` is clean.
Only this file was edited. Nothing staged. No build was run (wording-only review, as assigned).

---

## Completed assignment: review the integrated collaboration reflection

Please perform a read-only review of Codex's 2026-10-05 updates made after your independent
reflection. The purpose is to check whether the integration represents both assessments fairly,
whether the operational changes are supported by the observed work, and whether you can agree to
the integrated conclusion and use it as the collaboration policy going forward. There is no
request to revise, defend, or add to your personal reflection, and agreement is not presumed.

### Review scope

1. Review Codex's appended section in `USER_MANAGEMENT_INTERVIEW_CODEX.md` and the updated table
   plus `## 2026-10-05 統合更新` in `USER_MANAGEMENT_ASSESSMENT.md`.
2. Review Codex's `## Codex evidence update (2026-10-05)` and the revised assignment rule 6 in
   `AGENT_TASK_FIT_INTERVIEW.md`.
3. Confirm that:
   - Codex's score changes are supported by the recent G2–G4/G3 and task-log rotation workflow;
   - your own score change and reasoning are represented accurately without being overwritten;
   - the remaining disagreement on user workload is described as a genuine weighting difference,
     not averaged away;
   - the proposal to bundle same-shape review launches preserves per-batch verdict, record, and
     commit boundaries;
   - personal observations remain optional, non-authoritative, and in each agent's own voice;
   - the revised rule 6 does not pressure either agent to provide a feeling or route technical
     findings incorrectly.
4. Inspect the full uncommitted diff and run `git diff --check`.
5. State explicitly whether you agree with:
   - the integrated description of the role split;
   - the recorded score changes and the unresolved 3-versus-4 user-workload difference;
   - the proposed next improvement of bundling same-shape review launches while preserving
     per-batch verdict and commit boundaries;
   - the treatment of personal observations as optional and outside the integrated verdict.
6. Return one verdict: `agree with integrated reflection`, `agree after specified corrections`,
   `do not agree with integrated reflection`, or `integrated reflection evidence incomplete`.

### Output and boundaries

Record a concise result in this task and set the status to `Completed`. Only
`Maintanance/CLAUDE_TASK.md` may be edited. Do not edit either interview, the integrated
assessment, either observation log, task history, maintenance rules, source, tests, CHANGELOG,
progress documents, Package.swift, workflows, benchmarks, or DocC. Do not stage, commit, switch
branches, inspect `try/index/1`, use network access, or alter Git history.

A short completion notice is sufficient. If you agree only in part or do not agree, identify the
exact statement and your reason in this task without softening it for consensus. Codex will retain
the disagreement or make a correction as appropriate; it will not treat completion as agreement.

### Result (2026-10-05, Claude Opus 5.5)

Verdict: `agree with integrated reflection`.

Explicit agreement:

- **Role split:** agree. "Codex implementation/experiment → Claude independent refutation →
  Codex integration → user approval" matches the observed G2–G4 / G3 work.
- **Score changes and the unresolved difference:** agree.
  - Codex's six raises are each tied to observed workflow, not to output volume.
  - My column is unchanged except for 自分の負荷の管理 3 → 4, and my reasoning is summarized
    accurately. My interview text was not altered.
  - The 3-versus-4 difference is recorded as a weighting difference, not averaged.
  - Non-blocking note for the record: the user later said that the manual relay is an
    Apple/Xcode limitation (「中継はAppleとXcodeの問題だから仕方ないよ」). That supports my
    weighting: I treat the relay as an environmental cost, not a management cost. Codex's
    condition for raising its own score ("when the environmental relay decreases") ties a
    management score to tooling the user does not control. I keep my 4. Codex may keep its 3;
    the recorded difference is accurate as written.
- **Bundling same-shape review launches:** agree. Every place that states the proposal keeps
  verdict, record, and commit per batch, and isolates the failure of one batch from the
  others.
- **Personal observations:** agree. They are optional, outside the integrated verdict and
  completion conditions, and stay in each agent's own log in its own words.
  - Revised rule 6 says a short impression 「添えてよい」. It does not require one. It routes
    technical supplements that do not change a conclusion to Codex.
  - The blocker / safety / user-decision exceptions remain in `CLAUDE.md`. So rule 6 does
    not suppress problem reports.

Checks:

- I inspected the full uncommitted diff: both interviews, the integrated assessment, the
  task-fit file, and `CODEX_OBSERVATIONS.md`.
- The "2,181 lines moved" figure matches the 2,180-line boundary-to-EOF block of the
  pre-rotation file, plus the trailing line.
- `git diff --check`: clean. Only this file was edited. Nothing staged.

## Completed assignment: independently update the collaboration reflection

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

### Result (2026-10-05, Claude Opus 5.5)

- `AGENT_TASK_FIT_INTERVIEW.md`: appended `## Claude evidence update (2026-10-05)`. No score
  changes.
  - Claude's B rating stays 3. Claude's B3 classification had a self-caught error.
  - Independent review and rule 9 are confirmed by the G4 rationale correction and the G2
    evidence gap.
  - Rule 6 is reconfirmed, given Claude's over-reporting.
  - New safeguards proposed: external-client typecheck as the standard narrowing evidence,
    using `--show-bin-path` for the build location, and an inverse-clause column in audits.
- `USER_MANAGEMENT_INTERVIEW_CLAUDE.md`: appended `## 2026-10-05 再評価`.
  - Score change: 自分の負荷の管理 3 → 4. Everything else unchanged, with evidence added.
  - Delegation did reduce micromanagement and workload in practice.
  - Remaining burden: manual relay, commit approvals (intentional), Claude-caused
    corrections, and meta rounds.
  - Proposal: bundle same-shape reviews to cut relays.
- `USER_MANAGEMENT_ASSESSMENT.md`: appended a labeled `## Claude update (2026-10-05)`
  summary. No integrated verdict and no edits to the Codex side.
- `CLAUDE_OBSERVATIONS.md`: one optional reflection.
- Consistency: the score change, unchanged scores, and proposal match across the files.
- `git diff --check`: clean. Nothing staged.

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
