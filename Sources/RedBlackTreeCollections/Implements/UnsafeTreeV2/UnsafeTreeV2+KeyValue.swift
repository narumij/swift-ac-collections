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
  @inline(__always)
  func lookup(_ key: Base._Key) -> Base._MappedValue? {
    //    let __ptr = update { $0.find(key) }
    //    return __ptr.___is_end ? nil : Base.__mapped_value_(__ptr)
    let __ptr = update { $0.__find_equal(key).__child }
    return __ptr.pointee == nullptr ? nil : Base.__mapped_value_(__ptr.pointee)
  }

  @inlinable
  subscript(key: Base._Key) -> Base._MappedValue? {
    @inline(__always)
    get {
      // これはダミー実装らしい。つかっちゃだめっぽい
      return lookup(key)
    }
    
    _modify {
      ensureUnique()
      
      let (__parent, __child) = __find_equal(key)

      let found = __child.pointee != nullptr

      var value: Base._MappedValue? = found ? Base.__mapped_value_ptr(__child).move() : nil

      defer {
        if let value {
          if found {
            Base.__mapped_value_ptr(__child).initialize(to: value)
          } else {
            unsafeEnsureCapacity()
            update {
              let __h = $0.__construct_node(Base.__payload_((key, value)))
              $0.__insert_node_at(__parent, __child, __h)
            }
          }
        } else {
          if found {
            _ = update { $0.erase(__child.pointee) }
          } else {
            /* NOP */
          }
        }
      }

      yield &value
    }
  }
}

extension UnsafeTreeV2 where Base: PairValueTrait {

  @inlinable
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
      let __mapped_value = try transform(Base.__mapped_value_(__p))
      (__parent, __child) = other.___emplace_hint_right(
        __parent, __child, Other.__payload_((__get_value(__p), __mapped_value)))
      assert(other.__tree_invariant(other.__root))
    }
    return other
  }

  @inlinable
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
    var other = UnsafeTreeV2<Other>._createWithNewBuffer(minimumCapacity: 2, nullptr: nullptr)
    var (__parent, __child) = other.___max_ref()
    for __p in unsafeSequence(__first, __last) {
      guard let __mv = try transform(Base.__mapped_value_(__p)) else { continue }
      other.unsafeEnsureCapacity()
      (__parent, __child) = other.___emplace_hint_right(
        __parent, __child, Other.__payload_((__get_value(__p), __mv)))
      assert(other.__tree_invariant(other.__root))
    }
    return other
  }
}
