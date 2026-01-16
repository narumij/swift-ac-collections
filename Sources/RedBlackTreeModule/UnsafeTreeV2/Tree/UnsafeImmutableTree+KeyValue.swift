//
//  UnsafeImmutableTree+KeyValue.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/14.
//

extension UnsafeImmutableTree where Base: KeyValueComparer {

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
