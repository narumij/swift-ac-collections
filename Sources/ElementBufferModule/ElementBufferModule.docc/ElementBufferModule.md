# ``ElementBufferModule``

Store one- to four-dimensional elements in contiguous buffers.

## Overview

Element buffer types own their storage and provide coordinate-based value access. They are
low-level building blocks intended for workloads such as competitive-programming dynamic
programming tables; they do not conform to `Collection`. Each buffer is noncopyable, so you
cannot implicitly duplicate a buffer or its storage.

With Swift 6.2, these buffers are intended exclusively for competitive programming, using
`element` and `setElement` for value access. With Swift 6.4, they also support general-purpose
use through borrowed references. The current package requires Swift 6.4; the Swift 6.2 usage
applies to the buffer source rather than installation of the current package.

Import the package facade to use these APIs:

```swift
import AcCollections

let table = ElementBuffer2D(repeating: 0, width: 4, height: 3)
table.setElement(42, at: 2, 1)
let value = table.element(at: 2, 1) // 42
```

`setElement(_:at:_:)` is nonmutating. A buffer bound with `let`, as in the example above, can
still replace its stored elements; `let` does not make the buffer contents read-only.
This value-access API avoids a mutating access to the buffer for competitive workloads.
It does not synchronize concurrent access: callers must prevent overlapping reads and writes
to the same element. This also applies when using the value-access API with Swift 6.4.

For general-purpose use with Swift 6.4 and supported platforms, use `reference(at:_:)` to read
and write an element within an exclusive borrowing scope. On Apple platforms, this API requires
OS version 27 or later. It returns Swift's
[`MutableRef`](https://developer.apple.com/documentation/swift/mutableref):

```swift
if #available(macOS 27.0, iOS 27.0, tvOS 27.0, watchOS 27.0, visionOS 27.0, *) {
  var table = ElementBuffer2D(repeating: 0, width: 4, height: 3)

  do {
    var cell = table.reference(at: 2, 1)
    cell.value += 1
    cell.value += 2
  }

  let value = table.element(at: 2, 1) // 3
}
```

Finish using the reference before accessing `table` independently again. The reference does not
own the storage and cannot outlive the buffer borrow.

The module provides ``ElementBuffer``, ``ElementBuffer2D``, ``ElementBuffer3D``, and
``ElementBuffer4D``. Consult each type's documentation for its axis order and initializer
preconditions.
