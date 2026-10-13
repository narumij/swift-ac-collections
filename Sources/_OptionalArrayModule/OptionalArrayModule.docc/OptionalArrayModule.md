# ``OptionalArrayModule``

Import optional element buffers through the package's legacy module name.

## Overview

`OptionalArrayModule` is a compatibility facade that re-exports `OptionalElementBufferModule`. It
does not declare optional-element-buffer APIs of its own.

New code should import `AcCollections` with the `ENABLE_OPTIONAL_ELEMENT_BUFFER` trait enabled.
