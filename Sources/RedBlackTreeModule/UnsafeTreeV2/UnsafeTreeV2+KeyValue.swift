//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

extension UnsafeTreeV2 where Base: PairValueTrait {

  @inlinable
  func lookup(_ key: Base._Key) -> Base._MappedValue? {
    let __ptr = find(key)
    return __ptr.___is_null_or_end ? nil : self[_unsafe_raw: __ptr].value
  }

  @inlinable
  @inline(__always)
  mutating func setValue(_ x: Base._MappedValue, forKey key: Base._Key) {
    ensureUnique()
    let (__parent, __child) = __find_equal(key)
    if !__child.pointee.___is_null {
      __child.__ptr_.__mapped_value_ptr(of: Base.self).pointee = x
    } else {
      ensureCapacity()
      update {
        let __h = $0.__construct_node(Base.__payload_((key, x)))
        $0.__insert_node_at(__parent, __child, __h)
      }
    }
  }

  @inlinable
  subscript(key: Base._Key) -> Base._MappedValue? {
    @inline(__always)
    get {
      assert(false, "Dummy definition; don't use.")
      return lookup(key)
    }
    @inline(__always)
    _modify {
      ensureUnique()
      let (__parent, __child) = __find_equal(key)

      var value: Base._MappedValue? =
        unsafe (__child.pointee.___is_null
        ? nil : __child.pointee.__mapped_value_ptr(of: Base.self).move())

      defer {
        if !__child.pointee.___is_null {
          if let value {
            unsafe __child.pointee.__mapped_value_ptr(of: Base.self).initialize(to: value)
          } else {
            update {
              _ = $0.erase(__child.pointee)
            }
          }
        } else {
          if let value {
            ensureCapacity()
            update {
              let __h = $0.__construct_node(Base.__payload_((key, value)))
              $0.__insert_node_at(__parent, __child, __h)
            }
          }
        }
      }
      yield &value
    }
  }
}

extension UnsafeTreeV2 where Base: PairValueTrait {

  @inlinable
  @inline(__always)
  internal func ___mapped_value(_ __p: _NodePtr) -> Base._MappedValue {
    Base.___mapped_value(__p.__value_().pointee)
  }

  @inlinable
  @inline(__always)
  internal func ___with_mapped_value<T>(
    _ __p: _NodePtr, _ f: (inout Base._MappedValue) throws -> T
  )
    rethrows -> T
  {
    try Base.___with_mapped_value(&__p.__value_().pointee, f)
  }
}

extension UnsafeTreeV2 where Base: PairValueTrait {

  @inlinable
  @inline(__always)
  internal func ___mapValues<Other>(
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    _ transform: (Base._MappedValue) throws -> Other._MappedValue
  )
    rethrows -> UnsafeTreeV2<Other>
  where
    Other: PairValueTrait,
    Other._Key == Base._Key
  {
    let other = UnsafeTreeV2<Other>.create(minimumCapacity: count)
    var (__parent, __child) = other.___max_ref()
    for __p in unsafeSequence(__first, __last) {
      let __mapped_value = try transform(___mapped_value(__p))
      (__parent, __child) = other.___emplace_hint_right(
        __parent, __child, Other.__payload_((__get_value(__p), __mapped_value)))
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
    rethrows -> UnsafeTreeV2<Other>
  where
    Other: PairValueTrait,
    Other._Key == Base._Key
  {
    var other = UnsafeTreeV2<Other>.create(minimumCapacity: count)
    var (__parent, __child) = other.___max_ref()
    for __p in unsafeSequence(__first, __last) {
      guard let __mv = try transform(___mapped_value(__p)) else { continue }
      UnsafeTreeV2<Other>.ensureCapacity(tree: &other)
      (__parent, __child) = other.___emplace_hint_right(
        __parent, __child, Other.__payload_((__get_value(__p), __mv)))
      assert(other.__tree_invariant(other.__root))
    }
    return other
  }
}
