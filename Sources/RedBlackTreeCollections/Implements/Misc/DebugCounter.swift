#if _TREE_ALLOCATION_COUNTER
import Foundation

@usableFromInline
final class _DebugCounter: @unchecked Sendable {
  private let lock = NSLock()
  private var storage = 0

  @usableFromInline
  var value: Int {
    get {
      lock.lock()
      defer { lock.unlock() }
      return storage
    }
    set {
      lock.lock()
      defer { lock.unlock() }
      storage = newValue
    }
    _modify {
      lock.lock()
      defer { lock.unlock() }
      yield &storage
    }
  }
}

private let _allocatedCount = _DebugCounter()
@usableFromInline
var allocatedCount: Int {
  get { _allocatedCount.value }
  set { _allocatedCount.value = newValue }
  _modify { yield &_allocatedCount.value }
}

private let _deallocatedCount = _DebugCounter()
@usableFromInline
var deallocatedCount: Int {
  get { _deallocatedCount.value }
  set { _deallocatedCount.value = newValue }
  _modify { yield &_deallocatedCount.value }
}

private let _nodeInitializedCount = _DebugCounter()
@usableFromInline
var nodeInitializedCount: Int {
  get { _nodeInitializedCount.value }
  set { _nodeInitializedCount.value = newValue }
  _modify { yield &_nodeInitializedCount.value }
}

private let _nodeDeinitializedCount = _DebugCounter()
@usableFromInline
var nodeDeinitializedCount: Int {
  get { _nodeDeinitializedCount.value }
  set { _nodeDeinitializedCount.value = newValue }
  _modify { yield &_nodeDeinitializedCount.value }
}

private let _payloadInitializedCount = _DebugCounter()
@usableFromInline
var payloadInitializedCount: Int {
  get { _payloadInitializedCount.value }
  set { _payloadInitializedCount.value = newValue }
  _modify { yield &_payloadInitializedCount.value }
}

private let _payloadDeinitializedCount = _DebugCounter()
@usableFromInline
var payloadDeinitializedCount: Int {
  get { _payloadDeinitializedCount.value }
  set { _payloadDeinitializedCount.value = newValue }
  _modify { yield &_payloadDeinitializedCount.value }
}

#endif
