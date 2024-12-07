import Foundation

extension RedBlackTree {

  public struct Node {

    @usableFromInline
    var __right_: _NodePtr
    @usableFromInline
    var __left_: _NodePtr
    @usableFromInline
    var __parent_: _NodePtr
    @usableFromInline
    var __is_black_: Bool

    @inlinable
    mutating func clear() {
      __right_ = .nullptr
      __left_ = .nullptr
      __parent_ = .nullptr
      __is_black_ = false
    }

    @inlinable
    init(
      __is_black_: Bool,
      __left_: _NodePtr = .nullptr,
      __right_: _NodePtr = .nullptr,
      __parent_: _NodePtr = .nullptr
    ) {
      self.__right_ = __right_
      self.__left_ = __left_
      self.__parent_ = __parent_
      self.__is_black_ = __is_black_
    }

    @usableFromInline
    static let zero: Self = .init(__is_black_: false, __left_: 0, __right_: 0, __parent_: 0)
  }
}

extension RedBlackTree.Node: Equatable {}
