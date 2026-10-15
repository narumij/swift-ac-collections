# ``NextPermutationModule``

Generate the current order and its lexicographic successor permutations one at a time.

## Overview

Call ``Swift/Collection/nextPermutations()`` on a collection whose elements are `Comparable`, then
advance the returned iterator manually. Each result is a temporary view into one owned buffer, so
finish using it before calling `next()` again. Copy a result into an `Array` if it must outlive that
call.

```swift
import AcCollections

var permutations = [2, 1, 3].nextPermutations()

while let permutation = permutations.next() {
    print(Array(permutation))
}
// [2, 1, 3]
// [2, 3, 1]
// [3, 1, 2]
// [3, 2, 1]
```

The starting order is included, followed only by its lexicographic successors. To enumerate every
distinct value ordering, start from a sorted collection.

### Choosing an iterator

- ``NextPermutations`` returns a collection view and checks at runtime that it is still valid.
  Advancing the iterator, even with a call that returns `nil`, invalidates its previous views.
- ``BorrowedNextPermutations`` returns a `Span`. The compiler enforces that the borrowed result
  doesn't escape the iterator or overlap its next mutating access. Create it with
  ``Swift/Collection/borrowedNextPermutations()``.

Both variants own one copied element buffer and mutate it in place. Neither is a `Sequence`; use
their `next()` methods directly. See the
[package README](https://github.com/narumij/swift-ac-collections#usage) for package and toolchain
setup.

## Topics

### Runtime-checked iteration

- ``Swift/Collection/nextPermutations()``
- ``NextPermutations``

### Borrowed iteration

- ``Swift/Collection/borrowedNextPermutations()``
- ``BorrowedNextPermutations``
