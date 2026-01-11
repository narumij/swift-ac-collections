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

/// SetやMultiset用に特殊化されたハンドル
///
/// `_Key`の取得に関して特殊化済みとなっている。
///
/// その他に比較演算の強制キャストによる特殊化も盛り込まれている。
///
@frozen
@usableFromInline
struct UnsafeTreeV2ScalarHandle<_Key: Comparable> {
  @inlinable
  internal init(
    header: UnsafeMutablePointer<UnsafeTreeV2Buffer<_Value>.Header>,
    origin: UnsafeMutablePointer<UnsafeTreeV2Origin>,
    specializeMode: SpecializeMode? = nil
  ) {
    self.header = header
    self.origin = origin
    self.isMulti = false
    // 性能上とても重要だが、コンパイラ挙動に合わせての採用でとても場当たり的
    self.specializeMode = specializeMode ?? SpecializeModeHoge<_Key>().specializeMode
  }
  @usableFromInline typealias _Key = _Key
  @usableFromInline typealias _Value = _Key
  @usableFromInline typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  @usableFromInline typealias _Pointer = _NodePtr
  @usableFromInline typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
  @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2Buffer<_Value>.Header>
  @usableFromInline let origin: UnsafeMutablePointer<UnsafeTreeV2Origin>
  @usableFromInline var isMulti: Bool
  @usableFromInline var specializeMode: SpecializeMode
}

extension UnsafeTreeV2 where _Key == _Value, _Key: Comparable {

  @usableFromInline
  typealias Handle = UnsafeTreeV2ScalarHandle<UnsafeTreeV2<Base>._Value>

  @inlinable
  @inline(__always)
  internal func read<R>(_ body: (Handle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = Handle(header: header, origin: elements)
      return try body(handle)
    }
  }

  @inlinable
  @inline(__always)
  internal func update<R>(_ body: (Handle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = Handle(header: header, origin: elements)
      return try body(handle)
    }
  }
}

extension UnsafeTreeV2ScalarHandle {

  @inlinable
  @inline(__always)
  func __key(_ __v: _Value) -> _Key { __v }

  @inlinable
  @inline(__always)
  func value_comp(_ __l: _Key, _ __r: _Key) -> Bool {
    specializeMode.value_comp(__l, __r)
  }

  @inlinable
  @inline(__always)
  func value_equiv(_ __l: _Key, _ __r: _Key) -> Bool {
    specializeMode.value_equiv(__l, __r)
  }

  @inlinable
  @inline(__always)
  func __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key) -> __int_compare_result {
    specializeMode.synth_three_way(__lhs, __rhs)
  }

  @inlinable
  @inline(__always)
  func __comp(_ __lhs: _Key, _ __rhs: _Key) -> __int_compare_result {
    specializeMode.synth_three_way(__lhs, __rhs)
  }
}

// MARK: - TreeNodeValueProtocol

extension UnsafeTreeV2ScalarHandle {
  
  @inlinable
  @inline(__always)
  func __get_value(_ p: _NodePtr) -> _Key {
    UnsafePair<_Value>.valuePointer(p)!.pointee
  }
}


extension UnsafeTreeV2ScalarHandle: UnsafeTreeHandleBase {}

extension UnsafeTreeV2ScalarHandle: BoundProtocol, BoundAlgorithmProtocol {}
extension UnsafeTreeV2ScalarHandle: FindProtocol {}
extension UnsafeTreeV2ScalarHandle: FindEqualProtocol, FindEqualProtocol_std {}
extension UnsafeTreeV2ScalarHandle: InsertNodeAtProtocol {}
extension UnsafeTreeV2ScalarHandle: InsertUniqueProtocol {}
extension UnsafeTreeV2ScalarHandle: RemoveProtocol {}
extension UnsafeTreeV2ScalarHandle: EraseProtocol {}
extension UnsafeTreeV2ScalarHandle: EraseUniqueProtocol {}

extension UnsafeTreeV2ScalarHandle {
  
#if false
  @inlinable
  @inline(__always)
  internal func
    __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
  {
    var __nd = __root
    if __nd == nullptr {
      return (__end_node, __left_ref(end))
    }
    var __nd_ptr = __root_ptr()
    let __comp = __lazy_synth_three_way_comparator

    while true {

      let __comp_res = __comp(__v, __get_value(__nd))

      if __comp_res.__less() {
        if __left_unsafe(__nd) == nullptr {
          return (__nd, __left_ref(__nd))
        }

        __nd_ptr = __left_ref(__nd)
        __nd = __left_unsafe(__nd)
      } else if __comp_res.__greater() {
        if __right_(__nd) == nullptr {
          return (__nd, __right_ref(__nd))
        }

        __nd_ptr = __right_ref(__nd)
        __nd = __right_(__nd)
      } else {
        return (__nd, __nd_ptr)
      }
    }
  }
#endif
}
