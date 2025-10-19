//
//  ___RedBlackTreeMerge.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/06/03.
//

@usableFromInline
protocol ___RedBlackTreeMerge: ValueComparer & CompareTrait & ThreeWayComparator
where
  Tree == ___Tree<Self>,
  _Value == Tree._Value
{
  associatedtype Tree
  associatedtype _Value
  var __tree_: Tree { get }
  mutating func _ensureCapacity()
  mutating func _ensureCapacity(amount: Int)
  mutating func _ensureUnique(tree: Tree)
}

// MARK: - Tree merge
// マージ元がtreeを持つケース

extension ___RedBlackTreeMerge {

  // MARK: Unique

  @inlinable
  @inline(__always)
  mutating func ___tree_merge_unique<Source>(_ __source: Source)
  where
    Source: MergeSourceProtocol,
    Source._Key == _Key,
    Source._Value == _Value
  {
    _ensureUnique(tree: .___insert_unique(tree: __tree_, __source))
  }
}

extension ___RedBlackTreeMerge where Self: KeyValueComparer {

  // MARK: Unique with Uniquing

  @inlinable
  @inline(__always)
  mutating func ___tree_merge_unique<Source>(
    _ __source: Source,
    uniquingKeysWith combine: (_MappedValue, _MappedValue) throws -> _MappedValue
  ) rethrows
  where
    Source: MergeSourceProtocol,
    Source._Key == _Key,
    Source._Value == _Value
  {
    _ensureUnique(tree: try .___insert_unique(tree: __tree_, __source, uniquingKeysWith: combine))
  }
}

extension ___RedBlackTreeMerge {

  // MARK: Multi

  @inlinable
  @inline(__always)
  mutating func ___tree_merge_multi<Source>(_ __source: Source)
  where
    Source: MergeSourceProtocol,
    Source._Key == _Key,
    Source._Value == _Value
  {
    _ensureUnique(tree: .___insert_multi(tree: __tree_, __source))
  }
}

// MARK: - Sequence merge
// マージ元がSequenceのケース

extension ___RedBlackTreeMerge {

  // MARK: Unique

  @inlinable
  @inline(__always)
  mutating func ___merge_unique<S>(_ __source: S)
  where
    S: Sequence,
    S.Element == _Value
  {
    _ensureUnique(tree: .___insert_unique(tree: __tree_, __source))
  }
}

extension ___RedBlackTreeMerge where Self: KeyValueComparer {

  // MARK: Unique with Uniquing

  @inlinable
  @inline(__always)
  mutating func ___merge_unique<S>(
    _ __source: S,
    uniquingKeysWith combine: (_MappedValue, _MappedValue) throws -> _MappedValue,
    transform __t_: (S.Element) -> _Value
  ) rethrows
  where
    S: Sequence
  {
    _ensureUnique(tree: try .___insert(tree: __tree_, __source, uniquingKeysWith: combine, transform: __t_))
  }
}

extension ___RedBlackTreeMerge {

  // MARK: Multi

  @inlinable
  @inline(__always)
  mutating func ___merge_multi<S>(_ __source: S)
  where
    S: Sequence,
    S.Element == _Value
  {
    _ensureUnique(tree: .___insert_multi(tree: __tree_, __source))
  }
}
