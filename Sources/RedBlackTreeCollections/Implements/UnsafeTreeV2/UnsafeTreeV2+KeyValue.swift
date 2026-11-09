//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
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
      var (__parent, __child) = __find_equal(key)
      let __e = __end_node

      if __child.pointee == nullptr {
        
        var value: Base._MappedValue? = nil
        
        defer {
          if let value {
            ensureUniqueAndCapacity()
            if __e != __end_node {
              (__parent, __child) = __simple_retrieve(__parent, __child)
            }
            
            update {
              let __h = $0.__construct_node(Base.__payload_((key, value)))
              $0.__insert_node_at(__parent, __child, __h)
            }
          }
        }
        
        yield &value
      } else {
        
        var __node = __child.pointee
        ensureUnique()
        if __e != __end_node {
          __node = __simple_retrieve(__node)
        }
        
        var value: Base._MappedValue? = Base.__mapped_value_ptr(__node).move()
        
        defer {
          if let value {
            Base.__mapped_value_ptr(__node).initialize(to: value)
          } else {
            _ = update {
              let next = $0.__remove_node_pointer(__node)
              Base.__key_ptr(__node).deinitialize(count: 1)
              $0.header.pointee.___pushRecycleWithoutDeinitialize(__node)
              return next
            }
          }
        }
        
        yield &value
      }
    }
  }

  @inlinable
  public subscript(key: Base._Key, default defaultValue: () -> Base._MappedValue)
    -> Base._MappedValue
  {

    @inline(__always)
    get { lookup(key) ?? defaultValue() }

    _modify {

      ensureUnique()

      let (__parent, __child) = __find_equal(key)

      var __node = __child.pointee

      if __node == nullptr {
        unsafeEnsureCapacity()
        _UNSAFE_TREE_ASSERT_INTERNAL(capacity > count)
        update {
          __node = $0.__construct_node(Base.__payload_((key, defaultValue())))
          $0.__insert_node_at(__parent, __child, __node)
        }
      }

      defer { _fixLifetime(self) }

      yield &Base.__mapped_value_ptr(__node).pointee
    }
  }

  @inlinable
  mutating func mappedValuePtr(
    for key: Base._Key,
    default defaultValue: () -> Base._MappedValue
  ) -> Base._MappedValuePtr {
    ensureUnique()

    let (__parent, __child) = __find_equal(key)

    var __node = __child.pointee

    if __node == nullptr {
      unsafeEnsureCapacity()
      _UNSAFE_TREE_ASSERT_INTERNAL(capacity > count)
      update {
        __node = $0.__construct_node(Base.__payload_((key, defaultValue())))
        $0.__insert_node_at(__parent, __child, __node)
      }
    }

    //    defer { _fixLifetime(self) }

    return Base.__mapped_value_ptr(__node)
  }
}

extension UnsafeTreeV2 where Base: PairValueTrait {

  @inlinable
  internal func ___mapValues<Other>(
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    _ transform: (Base._MappedValue) throws -> Other._MappedValue
  ) rethrows -> UnsafeTreeV2<Other>
  where Other: PairValueTrait, Other._Key == Base._Key {
    let other = UnsafeTreeV2<Other>.create(minimumCapacity: count)
    var (__parent, __child) = other.___max_ref()
    for __p in unsafeSequence(__first, __last) {
      let __mapped_value = try transform(Base.__mapped_value_(__p))
      (__parent, __child) = other.___emplace_hint_right(
        __parent,
        __child,
        Other.__payload_((__get_value(__p), __mapped_value))
      )
      _TREE_ASSERT_INTERNAL(other.__tree_invariant(other.__root))
    }
    return other
  }

  @inlinable
  internal func ___compactMapValues<Other>(
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    _ transform: (Base._MappedValue) throws -> Other._MappedValue?
  ) rethrows -> UnsafeTreeV2<Other>
  where Other: PairValueTrait, Other._Key == Base._Key {
    var other = UnsafeTreeV2<Other>
      ._createWithNewBuffer(minimumCapacity: 2, nullptr: nullptr)
    var (__parent, __child) = other.___max_ref()
    for __p in unsafeSequence(__first, __last) {
      guard let __mv = try transform(Base.__mapped_value_(__p)) else {
        continue
      }
      other.unsafeEnsureCapacity()
      (__parent, __child) = other.___emplace_hint_right(
        __parent,
        __child,
        Other.__payload_((__get_value(__p), __mv))
      )
      _TREE_ASSERT_INTERNAL(other.__tree_invariant(other.__root))
    }
    return other
  }
}
