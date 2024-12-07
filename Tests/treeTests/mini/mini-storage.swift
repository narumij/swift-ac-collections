import Foundation
@testable import RedBlackTreeModule

// 書いてみたけれども、
// よくよく考えるとサイズが小さいと
// アルゴリムのメリットが消えてしまうので、
// 保留に
#if false
@usableFromInline
struct RedBlackTree4<Element>
where Element: Comparable, Element: SIMDScalar {

  @usableFromInline
  var __header: RedBlackTree.Header

  @usableFromInline
  var __end_left: _NodePtr

  @usableFromInline
  var __nodes: (RedBlackTree.Node, RedBlackTree.Node, RedBlackTree.Node, RedBlackTree.Node)

  @usableFromInline
  var __values: SIMD4<Element>
}

extension RedBlackTree4 {

  init() where Element: FixedWidthInteger {
    __header = .zero
    __end_left = .nullptr
    __nodes = (.zero, .zero, .zero, .zero)
    __values = .zero
  }
}

extension RedBlackTree4 {

  @inlinable
  public var count: Int { __header.size }

  @inlinable
  public var isEmpty: Bool { count == 0 }
}

extension RedBlackTree4 {

  @inlinable
  @inline(__always)
  func _read<R>(_ body: (_UnsafeReadHandle<Element>) throws -> R) rethrows -> R {
    return try withUnsafePointer(to: __header) { header in
      try withUnsafePointer(to: __nodes.0) { nodes in
        try withUnsafePointer(to: __values[0]) { values in
          try body(
            _UnsafeReadHandle<Element>(
              __header_ptr: header,
              __node_ptr: nodes,
              __value_ptr: values))
        }
      }
    }
  }

  @inlinable
  @inline(__always)
  mutating func _update<R>(_ body: (_UnsafeUpdateHandle<Element>) throws -> R) rethrows -> R {
    return try withUnsafeMutablePointer(to: &__header) { header in
      try withUnsafeMutablePointer(to: &__nodes.0) { nodes in
        try withUnsafeMutablePointer(to: &__values[0]) { values in
          try body(
            _UnsafeUpdateHandle<Element>(
              __header_ptr: header,
              __node_ptr: nodes,
              __value_ptr: values))
        }
      }
    }
  }
}
#endif
