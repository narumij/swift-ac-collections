import Foundation

public
  typealias _NodePtr = Int

extension _NodePtr {
  @inlinable
  static var nullptr: Self { -2 }
  @inlinable
  static var end: Self { -1 }
  @inlinable
  static func node(_ p: Int) -> Self { p }
}

public
  enum _NodeRef: Equatable
{
  case nullptr
  case __right_(_NodePtr)
  case __left_(_NodePtr)
}

@usableFromInline
protocol MemberProtocol {
  func __parent_(_: _NodePtr) -> _NodePtr
  func __left_(_: _NodePtr) -> _NodePtr
  func __right_(_: _NodePtr) -> _NodePtr
  func __is_black_(_: _NodePtr) -> Bool
  func __parent_unsafe(_: _NodePtr) -> _NodePtr
}

@usableFromInline
protocol MemberSetProtocol: MemberProtocol {
  func __is_black_(_ lhs: _NodePtr, _ rhs: Bool)
  func __parent_(_ lhs: _NodePtr, _ rhs: _NodePtr)
  func __left_(_ lhs: _NodePtr, _ rhs: _NodePtr)
  func __right_(_ lhs: _NodePtr, _ rhs: _NodePtr)
}

@usableFromInline
protocol RefProtocol: MemberProtocol {
  func __left_ref(_: _NodePtr) -> _NodeRef
  func __right_ref(_: _NodePtr) -> _NodeRef
  func __ref_(_ rhs: _NodeRef) -> _NodePtr
}

@usableFromInline
protocol RefSetProtocol: RefProtocol {
  func __ref_(_ lhs: _NodeRef, _ rhs: _NodePtr)
}

@usableFromInline
protocol ValueProtocol: MemberProtocol {

  associatedtype _Key
  func __value_(_: _NodePtr) -> _Key
  func value_comp(_: _Key, _: _Key) -> Bool
}

@usableFromInline
protocol BeginNodeProtocol {
  var __begin_node: _NodePtr { get nonmutating set }
}

@usableFromInline
protocol RootProtocol {
  func __root() -> _NodePtr
}

@usableFromInline
protocol RootPtrProrototol {
  func __root_ptr() -> _NodeRef
}

@usableFromInline
protocol EndNodeProtocol {
  func __end_node() -> _NodePtr
}

extension EndNodeProtocol {
  @inlinable
  @inline(__always)
  func __end_node() -> _NodePtr { .end }
}

@usableFromInline
protocol EndProtocol {
  func end() -> _NodePtr
}

extension EndProtocol {
  @inlinable
  @inline(__always)
  func end() -> _NodePtr { .end }
}

@usableFromInline
protocol SizeProtocol {
  var size: Int { get nonmutating set }
}

@usableFromInline
protocol EqualProtocol: ValueProtocol, RootProtocol, EndNodeProtocol { }
