# ``BareArrayModule``

Import element buffers through the package's legacy module name.

## Overview

`BareArrayModule` is a compatibility facade that re-exports `ElementBufferModule`. It does not
declare element-buffer APIs of its own.

New code should import `AcCollections`, the package's library product.
