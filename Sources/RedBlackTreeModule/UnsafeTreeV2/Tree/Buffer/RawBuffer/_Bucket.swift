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
@frozen
@usableFromInline
package struct _Bucket {

  public typealias _NextBucket = UnsafeMutablePointer<_Bucket>

  public init(capacity: Int) {
    self.capacity = capacity
  }

  public var next: _NextBucket? = nil
  public let capacity: Int
  public var count: Int = 0
}

extension UnsafeMutablePointer where Pointee == _Bucket {

  @inlinable
  @inline(__always)
  var next: UnsafeMutablePointer? { pointee.next }
  @inlinable
  @inline(__always)
  var capacity: Int { pointee.capacity }
  @inlinable
  @inline(__always)
  var count: Int { pointee.count }

  @inlinable
  @inline(__always)
  var begin_ptr: UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>> {
    UnsafeMutableRawPointer(advanced(by: 1))
      .assumingMemoryBound(to: UnsafeMutablePointer<UnsafeNode>.self)
  }
  
  @inlinable
  @inline(__always)
  var end_ptr: UnsafeMutablePointer<UnsafeNode> {
    UnsafeMutableRawPointer(begin_ptr.advanced(by: 1))
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  func storage(isHead: Bool) -> UnsafeMutableRawPointer {
    if isHead {
      UnsafeMutableRawPointer(end_ptr.advanced(by: 1))
    } else {
      UnsafeMutableRawPointer(advanced(by: 1))
    }
  }

  @inlinable
  @inline(__always)
  package func start(isHead: Bool, valueAlignment: Int) -> UnsafeMutablePointer<UnsafeNode> {
    let headerAlignment = MemoryLayout<UnsafeNode>.alignment
    if valueAlignment <= headerAlignment {
      return storage(isHead: isHead)
        .assumingMemoryBound(to: UnsafeNode.self)
    }
    return storage(isHead: isHead)
      .advanced(by: MemoryLayout<UnsafeNode>.stride)
      .alignedUp(toMultipleOf: valueAlignment)
      .advanced(by: -MemoryLayout<UnsafeNode>.stride)
      .assumingMemoryBound(to: UnsafeNode.self)
  }
}

#if DEBUG && false
  extension _UnsafeNodeFreshBucket {

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
            p.pointee.___raw_index,
            marker
          )
        )

        p = advance(p)
        i += 1
      }
      print("-----------------------------")
    }
  }
#endif
