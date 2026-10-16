# ``OptionalElementBufferModule``

Store one- to four-dimensional optional elements in reusable contiguous buffers.

## Overview

Optional element buffers represent each position as either unset or as an owned `Element`. They
support coordinate-based access without requiring callers to choose a sentinel value and are
intended primarily for competitive-programming memoization workloads. This module is experimental;
its API does not carry stable compatibility guarantees.

The package exposes these APIs from `AcCollections` only when the
`ENABLE_OPTIONAL_ELEMENT_BUFFER` package trait is enabled. After enabling the trait as described in
the package README, import the package facade:

```swift
import AcCollections

let memo = OptionalElementBuffer2D<Int>(width: 4, height: 3)

if memo.element(at: 2, 1) == nil {
    memo.setElement(42, at: 2, 1)
}

let value = memo.element(at: 2, 1) // 42
memo.setElement(nil, at: 2, 1)     // Unset this position again.
```

The four buffer types are noncopyable. Their `setElement` and `removeAll()` methods are
nonmutating, however, so a buffer stored in a `let` binding can still change its contents. A `let`
binding does not make the stored elements read-only. These operations do not synchronize access;
callers must prevent overlapping reads and writes, including clearing the buffer with `removeAll()`.

Coordinates are ordered from the innermost axis to the outermost axis. In the example above,
`x` comes before `y`; `width` is the innermost axis and `height` is the outermost one. A buffer's
`indices` property covers only its outermost axis.

All positions are initially unset. Setting a value owns that value until it is replaced, unset by
passing `nil`, cleared by `removeAll()`, or destroyed with the buffer.

Every coordinate passed to `element` or `setElement` must be within its corresponding axis. An
out-of-range coordinate violates a precondition; it is not treated as an unset position and does
not return `nil`.

The module provides ``OptionalElementBuffer``, ``OptionalElementBuffer2D``,
``OptionalElementBuffer3D``, and ``OptionalElementBuffer4D``. Consult each type's documentation
for its axis order, unset-state behavior, and preconditions.
