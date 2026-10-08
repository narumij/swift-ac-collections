# ``AcCollections``

Import the collection modules in this package through a single facade.

## Overview

`AcCollections` re-exports the red-black-tree collections, permutation sequence,
optional-slot arrays, and bare multidimensional arrays. Client code can use their public APIs with
a single import:

```swift
import AcCollections
```

The facade does not declare collection types of its own. Each API remains owned and documented by
its defining module.

The current policy is to include every collection module shipped by the package. If a module is
later confirmed not to meet the package's quality requirements, its facade exposure is reconsidered
at that time.
