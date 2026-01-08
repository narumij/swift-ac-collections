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
    capacity: Int,
    pointer: UnsafeMutablePointer<FreshStorage>? = nil
  ) {
    self.capacity = capacity
    self.pointer = pointer
  }

  // 最新の全体容量を記録する
  @usableFromInline let capacity: Int
  // 過去のバッファ
  @usableFromInline let pointer: UnsafeMutablePointer<FreshStorage>?

  @usableFromInline var count: Int {
    capacity - (pointer?.pointee.capacity ?? 0)
  }
}

@frozen
@usableFromInline
struct FreshPool<_Value> {
  @usableFromInline
  internal init(
    storage: UnsafeMutablePointer<FreshStorage>? = nil,
    array: UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>? = nil
  ) {
    self.storage = storage
    self.array = array
  }

  @usableFromInline var used: Int = 0
  @usableFromInline var storage: UnsafeMutablePointer<FreshStorage>?
  @usableFromInline var array: UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>?
}

extension FreshPool {

  @usableFromInline
  var capacity: Int {
    storage?.pointee.capacity ?? 0
  }

  @usableFromInline
  mutating func reserveCapacity(minimumCapacity newCapacity: Int) {
    guard capacity < newCapacity else { return }
    let oldCapacity = capacity
    let size = newCapacity - oldCapacity
    resizeArrayIfNeeds(minimumCapacity: newCapacity)
    var p = pushStorage(size: size)
    var i = oldCapacity
    while i < newCapacity {
      (array! + i).initialize(to: p)
      p = UnsafeMutableRawPointer(p)
        .advanced(by: MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride)
        .assumingMemoryBound(to: UnsafeNode.self)
      i += 1
    }
  }

  @inlinable
  @inline(__always)
  mutating func resizeArrayIfNeeds(minimumCapacity newCapacity: Int) {
    let oldRank = 1 << (Int.bitWidth - capacity.leadingZeroBitCount)
    let newRank = 1 << (Int.bitWidth - newCapacity.leadingZeroBitCount)
    guard oldRank != newRank || array == nil else { return }
    let newArray = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
      .allocate(capacity: newRank)
    if let array {
      newArray.moveInitialize(from: array, count: capacity)
    }
    array = newArray
  }

  @inlinable
  @inline(__always)
  mutating func pushStorage(size: Int) -> UnsafeMutablePointer<UnsafeNode> {
    //    let newStorage = UnsafeMutablePointer<FreshStorage>.allocate(capacity: 1)
    //    newStorage.initialize(to: .init(capacity: capacity + size,
    //                           buffer: UnsafeMutableRawPointer.allocate(
    //                            byteCount: (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride) * size,
    //                            alignment: max(MemoryLayout<UnsafeNode>.alignment, MemoryLayout<_Value>.alignment)),
    //                           pointer: storage))
    let (newStorage, buffer, _) = createBucket(capacity: size)
    storage = newStorage
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

    let header = UnsafeMutableRawPointer(header_storage)
      .assumingMemoryBound(to: FreshStorage.self)

    let elements = UnsafeMutableRawPointer(header.advanced(by: 1))

    header.initialize(
      to:
        .init(
          capacity: capacity,
          pointer: self.storage))

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

  var buffer: UnsafeMutableBufferPointer<UnsafeMutablePointer<UnsafeNode>> {
    UnsafeMutableBufferPointer(
      start: UnsafeMutableRawPointer(array!)
        .assumingMemoryBound(to: UnsafeMutablePointer<UnsafeNode>.self),
      count: capacity
    )
  }

  @usableFromInline
  subscript(___node_id_: Int) -> UnsafeMutablePointer<UnsafeNode> {
    buffer[___node_id_]
  }

  @usableFromInline
  mutating func dispose() {
    for i in 0..<used {
      let c = self[i]
      if c.pointee.___needs_deinitialize {
        UnsafeNode.deinitialize(_Value.self, c)
      }
      c.deinitialize(count: 1)
    }
    while let storage {
      self.storage = storage.pointee.pointer
      storage.deallocate()
    }
    if let array {
      array.deinitialize(count: capacity)
      array.deallocate()
    }
  }
}

