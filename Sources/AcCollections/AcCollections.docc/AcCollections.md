# ``AcCollections``

Import the collection modules in this package through a single facade.

## Overview

`AcCollections` re-exports the red-black-tree collections, permutation iterators, and element
buffers. Client code can use their public APIs with a single import:

```swift
import AcCollections
```

When the `ENABLE_OPTIONAL_ELEMENT_BUFFER` package trait is enabled, the facade also re-exports
optional element buffers.

The facade does not declare collection types of its own. Each API remains owned and documented by
its defining module.
