//
//  ___Storage.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/31.
//

// コンテナに対するCoW責任をカバーする
// それ以外はTree側の保持の仕方で管理する
@_fixed_layout
@usableFromInline
final class ___Storage<VC: ValueComparer & CompareTrait> {
  public typealias Tree = ___Tree<VC>
  @nonobjc
  @inlinable
  @inline(__always)
  init(tree: Tree) {
    self.tree = tree
  }
  @nonobjc
  @inlinable
  @inline(__always)
  init(minimumCapacity: Int) {
    tree = .create(minimumCapacity: minimumCapacity)
  }
  @usableFromInline
  typealias _Tree = Tree
  @nonobjc
  @usableFromInline
  final var tree: Tree
  @nonobjc
  @inlinable
  @inline(__always)
  final var count: Int { tree.count }
  @nonobjc
  @inlinable
  @inline(__always)
  final var capacity: Int { tree.header.capacity }
  @nonobjc
  @inlinable
  @inline(__always)
  internal static func create(
    withCapacity capacity: Int
  ) -> ___Storage {
    return .init(minimumCapacity: capacity)
  }
  @nonobjc
  @inlinable
  @inline(__always)
  final func copy() -> ___Storage {
    .init(tree: tree.copy())
  }
  @nonobjc
  @inlinable
  @inline(__always)
  final func copy(
    growthCapacityTo capacity: Int,
    linearly: Bool
  ) -> ___Storage {
    .init(
      tree: tree.copy(
        growthCapacityTo: capacity,
        linearly: linearly))
  }
  @nonobjc
  @inlinable
  @inline(__always)
  final func copy(
    growthCapacityTo capacity: Int,
    limit: Int,
    linearly: Bool
  ) -> ___Storage {
    .init(
      tree: tree.copy(
        growthCapacityTo: capacity,
        limit: limit,
        linearly: linearly))
  }
  @nonobjc
  @inlinable
  @inline(__always)
  final func isKnownUniquelyReferenced_tree() -> Bool {
    #if !DISABLE_COPY_ON_WRITE
      isKnownUniquelyReferenced(&tree)
    #else
      true
    #endif
  }
}
