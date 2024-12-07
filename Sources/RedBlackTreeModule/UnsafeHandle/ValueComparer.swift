import Foundation

@usableFromInline
protocol ValueComparer {
  associatedtype _Key
  associatedtype Element
  static func __key(_: Element) -> _Key
  static func value_comp(_: _Key, _: _Key) -> Bool
}

@usableFromInline
protocol _UnsafeHandleCommon {
  associatedtype VC: ValueComparer
}

extension _UnsafeHandleCommon {

  @usableFromInline
  typealias _Key = VC._Key

  @usableFromInline
  typealias Element = VC.Element

  @inlinable func __value_(_ e: VC.Element) -> _Key {
    VC.__key(e)
  }

  @inlinable func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    VC.value_comp(a, b)
  }
}

