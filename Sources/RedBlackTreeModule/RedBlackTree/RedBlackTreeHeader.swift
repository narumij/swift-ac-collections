import Foundation

extension RedBlackTree {

  @frozen
  @usableFromInline
  struct Header {

    @inlinable
    @inline(__always)
    init() {}

    @usableFromInline
    var __left_: _NodePtr = .nullptr

    @usableFromInline
    var __begin_node: _NodePtr = .end

    @usableFromInline
    var size: Int = 0

    @usableFromInline
    static let zero: Self = .init()
  }
}
