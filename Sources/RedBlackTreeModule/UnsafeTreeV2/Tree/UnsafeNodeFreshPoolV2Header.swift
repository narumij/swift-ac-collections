//
//  UnsafeNode+FreshPoolV2Header.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/08.
//

@frozen
@usableFromInline
struct FreshStorage {

  @inlinable
  @inline(__always)
  internal init(
    pointer: UnsafeMutablePointer<FreshStorage>?
  ) {
    self.pointer = pointer
  }
  // 過去のバッファ
  @usableFromInline let pointer: UnsafeMutablePointer<FreshStorage>?
}

@frozen
@usableFromInline
struct FreshPool<_Value> {

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @usableFromInline
  internal init(
    storage: UnsafeMutablePointer<FreshStorage>? = nil,
    array: UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>? = nil
  ) {
    self.storage = storage
    self.pointers = array
  }

  @usableFromInline var used: Int = 0
  @usableFromInline var capacity: Int = 0
  @usableFromInline var pointers: UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>?
  @usableFromInline var pointerCount: Int = 0
  @usableFromInline var storage: UnsafeMutablePointer<FreshStorage>?
}

extension FreshPool {

  @inlinable
  @inline(__always)
  mutating func reserveCapacity(minimumCapacity newCapacity: Int) {
    assert(capacity < newCapacity)
    assert(used <= capacity)
    assert(used < newCapacity)
    guard capacity < newCapacity else { return }
    let oldCapacity = capacity
    let size = newCapacity - oldCapacity
    resizeArrayIfNeeds(minimumCapacity: newCapacity)
    var p = pushStorage(size: size)
    var i = oldCapacity
    while i < newCapacity {
      (pointers! + i).initialize(to: p)
      p = UnsafeMutableRawPointer(p)
        .advanced(by: MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride)
        .assumingMemoryBound(to: UnsafeNode.self)
      i += 1
    }
    assert(used < capacity)
  }
  
  @inlinable
  func growthPointerCount(minimumCount: Int) -> Int {
    let base = 16
    // 最初にどんと増やすケースではサイズが確定してるケースが多そうなのでサイズ依頼に従う
    if pointerCount == 0, minimumCount > base {
      return minimumCount
    }
    // ノード用メモリ確保の速度でうまみが強い範囲に余計な仕事をしないための最小限を最初に確保
    // その後は1/3ずつ増加
    return max(base, minimumCount * 5 / 4)
  }

  @inlinable
  @inline(__always)
  mutating func resizeArrayIfNeeds(minimumCapacity newCapacity: Int) {
    let newRank = growthPointerCount(minimumCount: newCapacity)
    guard pointerCount != newRank || pointers == nil else { return }
    let newArray = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
      .allocate(capacity: newRank)
    if let pointers {
      newArray.moveInitialize(from: pointers, count: capacity)
      pointers.deallocate()
    }
    pointers = newArray
    pointerCount = newRank
  }

  @inlinable
  @inline(__always)
  mutating func pushStorage(size: Int) -> UnsafeMutablePointer<UnsafeNode> {
    assert(used <= capacity)
    let (newStorage, buffer, size) = createBucket(capacity: size)
    storage = newStorage
    capacity += size
    assert(used < capacity)
    return UnsafePair<_Value>.pointer(from: buffer)
  }

  @inlinable
  @inline(__always)
  func allocationSize(capacity: Int) -> (size: Int, alignment: Int) {
    let s0 = MemoryLayout<UnsafeNode>.stride
    let a0 = MemoryLayout<UnsafeNode>.alignment
    let s1 = MemoryLayout<_Value>.stride
    let a1 = MemoryLayout<_Value>.alignment
    let s2 = MemoryLayout<FreshStorage>.stride
    let s01 = s0 + s1
    let offset01 = max(0, a1 - a0)
    return (s2 + (capacity == 0 ? 0 : s01 * capacity + offset01), max(a0, a1))
  }

  @inlinable
  @inline(__always)
  func createBucket(capacity: Int) -> (
    head: UnsafeMutablePointer<FreshStorage>,
    first: UnsafeMutableRawPointer,
    capacity: Int
  ) {

    assert(capacity != 0)

    let (bytes, alignment) = allocationSize(capacity: capacity)

    let header_storage = UnsafeMutableRawPointer.allocate(
      byteCount: bytes,
      alignment: alignment)

    header_storage.bindMemory(to: FreshStorage.self, capacity: 1)

    let header = UnsafeMutableRawPointer(header_storage)
      .assumingMemoryBound(to: FreshStorage.self)

    let elements = UnsafeMutableRawPointer(header.advanced(by: 1))

    header.initialize(to: .init(pointer: self.storage))

    #if DEBUG
      do {
        var c = 0
        var p = elements
        while c < capacity {

          p.assumingMemoryBound(to: UnsafeNode.self)
            .pointee
            .___node_id_ = .nullptr

          p = UnsafePair<_Value>
            .advance(p.assumingMemoryBound(to: UnsafeNode.self))
            ._assumingUnbound()

          c += 1
        }
      }
    #endif

    return (header, elements, capacity)
  }

  @inlinable
  @inline(__always)
  var buffer: UnsafeMutableBufferPointer<UnsafeMutablePointer<UnsafeNode>> {
    guard let pointers else { fatalError() }
    return UnsafeMutableBufferPointer(
      start: UnsafeMutableRawPointer(pointers)
        .assumingMemoryBound(to: UnsafeMutablePointer<UnsafeNode>.self),
      count: capacity
    )
  }

  @inlinable
  @inline(__always)
  subscript(___node_id_: Int) -> UnsafeMutablePointer<UnsafeNode> {
    assert(0 <= ___node_id_)
    assert(___node_id_ < capacity)
    return pointers!.advanced(by: ___node_id_).pointee
  }

  @inlinable
  @inline(__always)
  mutating func _popFresh(nullptr: _NodePtr) -> _NodePtr {
    let p = self[used]
    p.initialize(to: nullptr.create(id: used))
    used += 1
    return p
  }

  @usableFromInline
  mutating func removeAllKeepingCapacity() {
    for i in 0..<used {
      let c = self[i]
      if c.pointee.___needs_deinitialize {
        UnsafeNode.deinitialize(_Value.self, c)
      }
    }
    used = 0
  }

  @inlinable
  @inline(__always)
  mutating func dispose() {
    if let pointers {
      var i = 0
      let used = used
      while i < used {
        let c = (pointers + i).pointee
        UnsafeNode.deinitialize(_Value.self, c)
        c.deinitialize(count: 1)
        i += 1
      }
      pointers.deinitialize(count: capacity)
      pointers.deallocate()
    }
    while let storage {
      self.storage = storage.pointee.pointer
      storage.deinitialize(count: 1)
      storage.deallocate()
    }
  }
}
