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

extension UnsafeTreeV2 where Base: KeyValueComparer {

  @inlinable
  @inline(__always)
  internal func ___mapped_value(_ __p: _NodePtr) -> Base._MappedValue {
    Base.___mapped_value(UnsafePair<_Value>.valuePointer(__p)!.pointee)
  }

  @inlinable
  @inline(__always)
  internal func ___with_mapped_value<T>(
    _ __p: _NodePtr, _ f: (inout Base._MappedValue) throws -> T
  )
    rethrows -> T
  {
    try Base.___with_mapped_value(&UnsafePair<_Value>.valuePointer(__p)!.pointee, f)
  }
}

extension UnsafeTreeV2 where Base: KeyValueComparer {

  @inlinable
  @inline(__always)
  internal func ___mapValues<Other>(
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    _ transform: (Base._MappedValue) throws -> Other._MappedValue
  )
    rethrows -> OtherTree<Other>
  where
    Other: KeyValueComparer & ___UnsafeKeyValueSequenceV2,
    Other._Key == _Key
  {
    let other = OtherTree<Other>.create(minimumCapacity: count)
    var (__parent, __child) = other.___max_ref()
    for __p in unsafeSequence(__first, __last) {
      let __mapped_value = try transform(___mapped_value(__p))
      (__parent, __child) = other.___emplace_hint_right(
        __parent, __child, Other.___tree_value((__get_value(__p), __mapped_value)))
      assert(other.__tree_invariant(other.__root))
    }
    return other
  }

  @inlinable
  @inline(__always)
  internal func ___compactMapValues<Other>(
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    _ transform: (Base._MappedValue) throws -> Other._MappedValue?
  )
    rethrows -> OtherTree<Other>
  where
    Other: KeyValueComparer & ___UnsafeKeyValueSequenceV2,
    Other._Key == _Key
  {
    var other = OtherTree<Other>.create(minimumCapacity: count)
    var (__parent, __child) = other.___max_ref()
    for __p in unsafeSequence(__first, __last) {
      guard let __mv = try transform(___mapped_value(__p)) else { continue }
      OtherTree<Other>.ensureCapacity(tree: &other)
      (__parent, __child) = other.___emplace_hint_right(
        __parent, __child, Other.___tree_value((__get_value(__p), __mv)))
      assert(other.__tree_invariant(other.__root))
    }
    return other
  }
}
