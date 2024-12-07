import Foundation

@usableFromInline
protocol RefImpl: MemberProtocol {}

extension RefImpl {

  @inlinable
  func __ref_(_ rhs: _NodeRef) -> _NodePtr {
    switch rhs {
    case .nullptr:
      return .nullptr
    case .__right_(let basePtr):
      return __right_(basePtr)
    case .__left_(let basePtr):
      return __left_(basePtr)
    }
  }

  @inlinable
  func __left_ref(_ p: _NodePtr) -> _NodeRef {
    .__left_(p)
  }

  @inlinable
  func __right_ref(_ p: _NodePtr) -> _NodeRef {
    .__right_(p)
  }
}

@usableFromInline
protocol RefSetImpl: MemberSetProtocol & RefImpl {}

extension RefSetImpl {

  @inlinable
  func __ref_(_ lhs: _NodeRef, _ rhs: _NodePtr) {
    switch lhs {
    case .nullptr:
      fatalError()
    case .__right_(let basePtr):
      return __right_(basePtr, rhs)
    case .__left_(let basePtr):
      return __left_(basePtr, rhs)
    }
  }

}

@usableFromInline
protocol RootImpl: MemberProtocol & EndNodeProtocol {}

extension RootImpl {
  @inlinable
  @inline(__always)
  func __root() -> _NodePtr { __left_(__end_node()) }
}

@usableFromInline
protocol RootPtrImpl: RefProtocol & EndNodeProtocol {}

extension RootPtrImpl {
  @inlinable
  func __root_ptr() -> _NodeRef { __left_ref(__end_node()) }
}
