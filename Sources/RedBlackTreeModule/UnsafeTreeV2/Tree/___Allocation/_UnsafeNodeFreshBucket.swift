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
package struct _UnsafeNodeFreshBucket {

  public typealias Bucket = _UnsafeNodeFreshBucket
  public typealias BucketPointer = UnsafeMutablePointer<Bucket>
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  internal init(
    start: _NodePtr,
    capacity: Int,
    strice: Int
  ) {
    self.start = start
    self.capacity = capacity
    self.stride = strice
  }
  
  // 総量が64B以内となること
  /// 利用数
  public var count: Int = 0
  /// 保持数
  public let capacity: Int
  /// 先頭ポインタ
  public let start: _NodePtr
  /// UnsafeNodeと`_Value`のストライドの合算値
  ///
  /// 定数であるMemoryLayout.strideからとるのが常識的には速いが、
  /// このケースではポインタ経由でのアクセスのためか、これをするとinstantiateが多発する
  /// これを迂回するためにこちらで保持している
  public let stride: Int
  /// 次のバケットへのポインタ
  public var next: BucketPointer? = nil

  @inlinable
  @inline(__always)
  func advance(_ p: _NodePtr, offset n: Int = 1) -> _NodePtr {
    UnsafeMutableRawPointer(p)
      .advanced(by: stride * n)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  @inline(__always)
  subscript(index: Int) -> _NodePtr {
    advance(start, offset: index)
  }

  @inlinable
  @inline(__always)
  mutating func pop() -> _NodePtr? {
    guard count < capacity else { return nil }
    let p = advance(start, offset: count)
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
#if false
      UnsafeNode.deinitialize(T.self, c)
#else
      if c.pointee.___needs_deinitialize {
        UnsafeMutableRawPointer(
          UnsafeMutablePointer<UnsafeNode>(c)
            .advanced(by: 1)
        )
        .assumingMemoryBound(to: t.self)
        .deinitialize(count: 1)
      }
#endif
      c.deinitialize(count: 1)
      i += 1
    }
    #if DEBUG
      do {
        var c = 0
        var p = start
        while c < capacity {
          p.pointee.___node_id_ = .debug
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
}

#if DEBUG
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
            p.pointee.___node_id_,
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
