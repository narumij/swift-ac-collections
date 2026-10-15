# ``ElementBufferModule``

Store one- to four-dimensional elements in contiguous buffers.

## Overview

Element buffer types own their storage and provide coordinate-based value access. They are
low-level building blocks intended for workloads such as competitive-programming dynamic
programming tables; they do not conform to `Collection`. Each buffer is noncopyable, so you
cannot implicitly duplicate a buffer or its storage.

Import the package facade to use these APIs:

```swift
import AcCollections

let table = ElementBuffer2D(repeating: 0, width: 4, height: 3)
table.setElement(42, at: 2, 1)
let value = table.element(at: 2, 1) // 42
```

`setElement(_:at:_:)` is nonmutating. A buffer bound with `let`, as in the example above, can
still replace its stored elements; `let` does not make the buffer contents read-only.

On Swift 6.4 and supported Apple platforms, use `reference(at:_:)` when you need to read and
write the same element repeatedly within one exclusive borrowing scope. It returns Swift's
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
