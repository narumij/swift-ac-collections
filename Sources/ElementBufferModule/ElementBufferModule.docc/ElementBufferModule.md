# ``ElementBufferModule``

Store one- to four-dimensional elements in contiguous buffers.

## Overview

Element buffer types own their storage and provide coordinate-based value access. They are
low-level building blocks intended for workloads such as competitive-programming dynamic
programming tables; they do not conform to `Collection`.

Import the package facade to use these APIs:

```swift
import AcCollections
```

The module provides ``ElementBuffer``, ``ElementBuffer2D``, ``ElementBuffer3D``, and
``ElementBuffer4D``. Consult each type's documentation for its axis order, preconditions, and
borrowing rules.
