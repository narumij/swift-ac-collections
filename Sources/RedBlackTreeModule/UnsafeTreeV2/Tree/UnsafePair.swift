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

// 最初に作ったヘルパー
// 他にもinstantiateを避ける工夫をしていたが迷子になったので途中だが止めている
public enum UnsafePair<_Value> {

  public typealias Pointer = UnsafePointer<UnsafeNode>
  public typealias MutablePointer = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  static func _allocationSize() -> (size: Int, alignment: Int) {
    let numBytes = MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride

    let nodeAlignment = MemoryLayout<UnsafeNode>.alignment
    let valueAlignment = MemoryLayout<_Value>.alignment

    if valueAlignment <= nodeAlignment {
      return (numBytes, MemoryLayout<UnsafeNode>.alignment)
    }

    return (
      numBytes + valueAlignment - nodeAlignment,
      MemoryLayout<_Value>.alignment
    )
  }

  @inlinable
  @inline(__always)
  package static func allocationSize(capacity: Int) -> (size: Int, alignment: Int) {
    let numBytes = MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride

    let nodeAlignment = MemoryLayout<UnsafeNode>.alignment
    let valueAlignment = MemoryLayout<_Value>.alignment
    
    if capacity == 0 {
      return (0, max(nodeAlignment, valueAlignment))
    }

    if valueAlignment <= nodeAlignment {
      return (numBytes * capacity, MemoryLayout<UnsafeNode>.alignment)
    }

    return (
      numBytes * capacity + valueAlignment - nodeAlignment,
      MemoryLayout<_Value>.alignment
    )
  }

  @inlinable
  @inline(__always)
  static func pointer(from storage: UnsafeMutableRawPointer) -> MutablePointer {
    let headerAlignment = MemoryLayout<UnsafeNode>.alignment
    let elementAlignment = MemoryLayout<_Value>.alignment

    if elementAlignment <= headerAlignment {
      return storage.assumingMemoryBound(to: UnsafeNode.self)
    }

    return storage.advanced(by: MemoryLayout<UnsafeNode>.stride)
      .alignedUp(for: _Value.self)
      .advanced(by: -MemoryLayout<UnsafeNode>.stride)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  @inline(__always)
  static func advance(_ p: MutablePointer, _ n: Int = 1) -> MutablePointer {
    UnsafeMutableRawPointer(p)
      .advanced(by: (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride) * n)
//      .alignedUp(for: UnsafeNode.self)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  @inline(__always)
  static func valuePointer(_ p: MutablePointer?) -> UnsafeMutablePointer<_Value>? {
    guard let p else { return nil }
    return valuePointer(p)
  }

  @inlinable
  @inline(__always)
  static func valuePointer(_ p: MutablePointer) -> UnsafeMutablePointer<_Value> {
    UnsafeMutableRawPointer(p.advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
  }
}
