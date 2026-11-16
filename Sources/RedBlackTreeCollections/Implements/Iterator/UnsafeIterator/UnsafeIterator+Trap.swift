//
//  UnsafeIterator+Trap.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/11/10.
//

extension UnsafeIterator {

  public struct _Trap<Source>:
    _UnsafeNodePtrType,
    IteratorProtocol,
    Sequence
  where
    Source.Element == UnsafeMutablePointer<UnsafeNode>,
    Source: IteratorProtocol
  {
    public var _source: Source

    @inlinable
    public init(source: Source) {
      self._source = source
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> UnsafeMutablePointer<UnsafeNode>? {
      let __p = _source.next()
      precondition(__p?.___is_null != true && __p?.___is_end != true)
      return __p
    }
  }
}
