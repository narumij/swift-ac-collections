//
//  UnsafeTreeV2+Dictionary.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/13.
//

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
