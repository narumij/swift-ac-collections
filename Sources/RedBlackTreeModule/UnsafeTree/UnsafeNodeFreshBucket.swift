// Copyright 2024-2026 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

// NOTE: 性能過敏なので修正する場合は必ず計測しながら行うこと
@usableFromInline
@frozen struct UnsafeNodeFreshBucket {

  public typealias Header = UnsafeNodeFreshBucket
  public typealias Node = UnsafeNode
  public typealias HeaderPointer = UnsafeMutablePointer<Header>
  public typealias NodePointer = UnsafeMutablePointer<Node>

  @inlinable
  @inline(__always)
  internal init(
    start: NodePointer,
    capacity: Int,
    strice: Int,
    alignment: Int
  ) {
    self.start = start
    self.capacity = capacity
    self.strice = strice
    self.alignment = alignment
  }

  public var count: Int = 0
  public let start: NodePointer
  public let capacity: Int
  public let strice: Int
  public let alignment: Int
  public var next: HeaderPointer? = nil

  @inlinable
  @inline(__always)
  func advance(_ p: NodePointer, _ n: Int = 1) -> NodePointer {
    UnsafeMutableRawPointer(p)
      .advanced(by: strice * n)
      .alignedUp(toMultipleOf: alignment)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  @inline(__always)
  subscript(index: Int) -> NodePointer {
    advance(start, index)
  }

  @inlinable
  @inline(__always)
  mutating func pop() -> NodePointer? {
    guard count < capacity else { return nil }
    let p = advance(start, count)
    count += 1
    return p
  }

  @inlinable
  @inline(__always)
  func _clear<T>(_ t: T.Type) {
    var i = 0
    let count = count
    var p = start
    while i < count {
      let c = p
      p = advance(p)
      if c.pointee.___needs_deinitialize {
        //        UnsafePair<_Value>.__value_ptr(c)
        UnsafeMutableRawPointer(
          UnsafeMutablePointer<UnsafeNode>(c)
            .advanced(by: 1)
        )
        .alignedUp(for: t.self)
        .assumingMemoryBound(to: t.self)
        .deinitialize(count: 1)
      }
      c.deinitialize(count: 1)
      i += 1
    }
    #if DEBUG
      do {
        var c = 0
        var p = start
        while c < capacity {
          p.pointee.___node_id_ = -2
          p = advance(p)
          c += 1
        }
      }
    #endif
  }

  @inlinable
  @inline(__always)
  mutating func clear<T>(_ t: T.Type) {
    _clear(t.self)
    count = 0
  }

  @inlinable
  @inline(__always)
  func dispose<T>(_ t: T.Type) {
    _clear(t.self)
  }

  @inlinable
  @inline(__always)
  static func create<T>(_ t: T.Type, capacity: Int) -> HeaderPointer {

    assert(capacity != 0)

    let (bytes, alignment) = Self.allocationSize(T.self,capacity: capacity)

    let header_storage = UnsafeMutableRawPointer.allocate(
      byteCount: bytes,
      alignment: alignment)

    let header = UnsafeMutableRawPointer(header_storage)
      .assumingMemoryBound(to: UnsafeNodeFreshBucket.self)

    let storage = UnsafeMutableRawPointer(header.advanced(by: 1))
      .alignedUp(toMultipleOf: alignment)

    header.initialize(
      to:
        .init(
          start: UnsafePair<T>.pointer(from: storage),
          capacity: capacity,
          strice: MemoryLayout<UnsafeNode>.stride + MemoryLayout<T>.stride,
          alignment: alignment))

    #if DEBUG
      do {
        var c = 0
        var p = header.pointee.start
        while c < capacity {
          p.pointee.___node_id_ = -2
          p = UnsafePair<T>.advance(p)
          c += 1
        }
      }
    #endif

    return header
  }

  @inlinable
  @inline(__always)
  static func allocationSize<T>(_ t: T.Type, capacity: Int) -> (size: Int, alignment: Int) {
    let (bufferSize, bufferAlignment) = UnsafePair<T>.allocationSize(capacity: capacity)
    let numBytes = MemoryLayout<Header>.stride + bufferSize
    let headerAlignment = MemoryLayout<Header>.alignment
    if bufferAlignment <= headerAlignment {
      return (numBytes, MemoryLayout<Header>.alignment)
    }
    return (
      numBytes + bufferAlignment - headerAlignment,
      bufferAlignment
    )
  }

  @inlinable
  @inline(__always)
  static func allocationSize() -> (size: Int, alignment: Int) {
    return (
      MemoryLayout<Header>.stride,
      MemoryLayout<Header>.alignment
    )
  }
}

#if false
#if DEBUG
  extension UnsafeNodeFreshBucket {

    func dump(label: String = "") {
      print("---- FreshBucket \(label) ----")
      print(" capacity:", capacity)
      print(" count:", count)

      var i = 0
      var p = start
      while i < capacity {
        let isUsed = i < count
        let marker =
          (count == i) ? "<- current" : isUsed ? "[used]" : "[free]"

        print(
          String(
            format: " [%02lld] ptr=%p id=%lld %@",
            i,
            p,
            p.pointee.___node_id_,
            marker
          )
        )

        p = UnsafePair<_Value>.advance(p)
        i += 1
      }
      print("-----------------------------")
    }
  }
#endif
#endif
