extension UnsafeTree where Base: KeyValueComparer {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___mapped_value(_ __p: _NodePtr) -> Base._MappedValue {
    Base.___mapped_value(UnsafePair<_Value>.__value_(__p)!.pointee)
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___with_mapped_value<T>(
    _ __p: _NodePtr, _ f: (inout Base._MappedValue) throws -> T
  )
    rethrows -> T
  {
    try Base.___with_mapped_value(&UnsafePair<_Value>.__value_(__p)!.pointee, f)
  }
}

extension UnsafeTree where Base: KeyValueComparer {

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___mapValues<Other>(
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    _ transform: (Base._MappedValue) throws -> Other._MappedValue
  )
    rethrows -> UnsafeTree<Other>
  where
    Other: KeyValueComparer & ___UnsafeKeyValueSequence,
    Other._Key == Base._Key
  {
    let other = UnsafeTree<Other>.create(minimumCapacity: count)
    var (__parent, __child) = other.___max_ref()
    for __p in unsafeSequence(__first, __last) {
      let __mapped_value = try transform(___mapped_value(__p))
      (__parent, __child) = other.___emplace_hint_right(
        __parent, __child, Other.___tree_value((__get_value(__p), __mapped_value)))
      assert(other.__tree_invariant(other.__root))
    }
    return other
  }

  @nonobjc
  @inlinable
  @inline(__always)
  internal func ___compactMapValues<Other>(
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    _ transform: (Base._MappedValue) throws -> Other._MappedValue?
  )
    rethrows -> UnsafeTree<Other>
  where
    Other: KeyValueComparer & ___UnsafeKeyValueSequence,
    Other._Key == Base._Key
  {
    var other = UnsafeTree<Other>.create(minimumCapacity: count)
    var (__parent, __child) = other.___max_ref()
    for __p in unsafeSequence(__first, __last) {
      guard let __mv = try transform(___mapped_value(__p)) else { continue }
      UnsafeTree<Other>.ensureCapacity(tree: &other)
      (__parent, __child) = other.___emplace_hint_right(
        __parent, __child, Other.___tree_value((__get_value(__p), __mv)))
      assert(other.__tree_invariant(other.__root))
    }
    return other
  }
}
