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

/*
 MARK: - UnsafeNode Binary Layout Assumptions

 This type is designed to be embedded in a low-level allocator with the
 following binary memory layout per element:

   | padding | UnsafeNode | Value |

 Layout assumptions:

 1. Padding before the node
    - Padding may exist *before* this `UnsafeNode` instance.
    - The padding is used to satisfy the alignment requirements of `Value`.
    - `UnsafeNode` itself does NOT account for this padding.

 2. Node position
    - `UnsafeNode` is placed at an address such that the memory immediately
      following it is correctly aligned for `Value`.
    - This invariant is enforced by the allocator, not by `UnsafeNode`.

 3. Value position (external invariant)
    - The associated `Value` is stored immediately after this node.
    - Given a pointer `p: UnsafeMutablePointer<UnsafeNode>`,
      the corresponding value is located at:
          p.advanced(by: 1)

 4. Responsibility boundary
    - `UnsafeNode` assumes the above layout invariant is already satisfied.
    - It performs no alignment checks and no pointer arithmetic by itself.
    - Breaking this invariant results in undefined behavior.

 5. Memory management flag
    - `___needs_deinitialize` indicates whether the associated `Value`
      requires deinitialization.
    - This flag is managed by higher-level allocators / pools.

 ⚠️ IMPORTANT:
    - Do NOT change the size or field order of `UnsafeNode`
      without updating the allocator that enforces this layout.
*/
public struct UnsafeNode {

  public typealias Pointer = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  public init(
    index: Int,
    __left_: Pointer? = nil,
    __right_: Pointer? = nil,
    __parent_: Pointer? = nil,
    __is_black_: Bool = false
  ) {
    self.___node_id_ = index
    self.__left_ = __left_
    self.__right_ = __right_
    self.__parent_ = __parent_
    self.__is_black_ = __is_black_
    self.___needs_deinitialize = true
  }

  public var __left_: Pointer?
  public var __right_: Pointer?
  public var __parent_: Pointer?
  // IndexアクセスでCoWが発生した場合のフォローバックとなる
  // TODO: 不変性が維持されているか考慮すること
  /// Temporary node identifier used exclusively for CoW reconstruction.
  /// This is NOT a logical index and must not be relied upon outside copy paths.
  public var ___node_id_: Int  // 連番をふる
  public var __is_black_: Bool = false
  // メモリ管理をちゃんとするために隙間にねじ込んだ
  // TODO: メモリ管理に整合性があるか考慮すること
  public var ___needs_deinitialize: Bool
}

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
  static func allocationSize(capacity: Int) -> (size: Int, alignment: Int) {
    let (bytes, alignment) = _allocationSize()
    return (bytes * capacity, alignment)
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
      .alignedUp(for: UnsafeNode.self)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  @inline(__always)
  static func __value_(_ p: Pointer?) -> UnsafePointer<_Value>? {
    guard let p else { return nil }
    return UnsafeRawPointer(p.advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
  }

  @inlinable
  @inline(__always)
  static func __value_(_ p: Pointer) -> UnsafePointer<_Value> {
    UnsafeRawPointer(p.advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
  }

  @inlinable
  @inline(__always)
  static func __value_(_ p: MutablePointer?) -> UnsafeMutablePointer<_Value>? {
    guard let p else { return nil }
    return UnsafeMutableRawPointer(p.advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
  }

  @inlinable
  @inline(__always)
  static func __value_(_ p: MutablePointer) -> UnsafeMutablePointer<_Value> {
    UnsafeMutableRawPointer(p.advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
  }
}
