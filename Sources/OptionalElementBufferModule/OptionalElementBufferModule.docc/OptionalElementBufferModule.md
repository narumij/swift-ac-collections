# ``OptionalElementBufferModule``

Store one- to four-dimensional optional elements in reusable contiguous buffers.

## Overview

Optional element buffers represent each position as either unset or as an owned `Element`. They
support coordinate-based access without requiring callers to choose a sentinel value and are
intended primarily for competitive-programming memoization workloads.

The package exposes these APIs from `AcCollections` only when the
`ENABLE_OPTIONAL_ELEMENT_BUFFER` package trait is enabled:

```swift
import AcCollections
```

The module provides ``OptionalElementBuffer``, ``OptionalElementBuffer2D``,
``OptionalElementBuffer3D``, and ``OptionalElementBuffer4D``. Consult each type's documentation
for its axis order, unset-state behavior, and preconditions.
