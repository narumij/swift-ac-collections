//
//  Bidirectional.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/03.
//

// CollectionやBidirectionalCollectionが
// C++のbidirectional_iteratorとミスマッチなため、
// C++のbidirectional_iterator相当と対応するコンテナ機能を定義している
//
// 平衡木の部分についても適応可能なことが望ましい
public protocol BalancedSequence: Sequence {

  var isEmpty: Bool { get }

  var first: Element? { get }
  var last: Element? { get }

  mutating func popFirst() -> Element?
  mutating func removeFirst() -> Element
  mutating func removeFirst(_: Int)

  mutating func popLast() -> Element?
  mutating func removeLast() -> Element
  mutating func removeLast(_: Int)

  func sorted() -> [Element]
  func reversed() -> [Element]

  // multimapをちゃんとつかってくれる人がいた場合、firstIndex(where:)は必要そう
}

extension BalancedSequence {

  public mutating func removeFirst(_ k: Int) {
    precondition(k >= 0)
    for _ in 0..<k { _ = removeFirst() }
  }

  public mutating func removeLast(_ k: Int) {
    precondition(k >= 0)
    for _ in 0..<k { _ = removeLast() }
  }
}

// MARK: -

public protocol BalancedCollection: BalancedSequence {

  associatedtype _Key

  associatedtype Index: Equatable
  associatedtype IndexRange = UnsafeIndexV3Range
  associatedtype IndexRangeExpression = UnsafeIndexV3RangeExpression

  associatedtype Bound = RedBlackTreeBoundExpression<_Key>
  associatedtype BoundRangeExpression = RedBlackTreeBoundRangeExpression<_Key>

  associatedtype View: BalancedView

  var count: Int { get }

  subscript(position: Index) -> Element { get }

  var startIndex: Index { get }
  var endIndex: Index { get }

  func index(after: Index) -> Index
  func index(before: Index) -> Index
  func index(_: Index, offsetBy: Int) -> Index
  func index(_: Index, offsetBy: Int, limitedBy: Index) -> Index?

  func formIndex(after: inout Index)
  func formIndex(before: inout Index)
  func formIndex(_: inout Index, offsetBy: Int)
  func formIndex(_: inout Index, offsetBy: Int, limitedBy: Index) -> Bool

  mutating func remove(at: Index) -> Element

  mutating func removeAll(keepingCapacity keepCapacity: Bool)

  // MARK: -

  func isValid(_: Index) -> Bool
  func isValid(_: IndexRange) -> Bool
  func isValid(_: IndexRangeExpression) -> Bool
  func isValid(_: Bound) -> Bool
  func isValid(_: BoundRangeExpression) -> Bool

  subscript(range: IndexRange) -> View { get }
  subscript(range: IndexRangeExpression) -> View { get }
  subscript(position: Bound) -> Element? { get }
  subscript(range: BoundRangeExpression) -> View { get }

  func lowerBound(_: _Key) -> Index
  func upperBound(_: _Key) -> Index
  
  func find(_: _Key) -> Index

  // removeSubrangeや標準Rangeとのミスマッチがどうしてもあれなので、用語としてeraseを採用

  mutating func erase(_: Index) -> Index
  mutating func erase(where: (Element) throws -> Bool) rethrows

  mutating func erase(_: IndexRange) -> Index
  mutating func erase(_: IndexRange, where: (Element) throws -> Bool) rethrows

  mutating func erase(_: IndexRangeExpression) -> Index
  mutating func erase(_: IndexRangeExpression, where: (Element) throws -> Bool) rethrows

  mutating func erase(_: Bound) -> Element?
  mutating func erase(_: BoundRangeExpression)
  mutating func erase(_: BoundRangeExpression, where: (Element) throws -> Bool) rethrows
}

public protocol BalancedMultiCollection: BalancedCollection {
  mutating func eraseUnique(_: _Key) -> Bool
  mutating func eraseMulti(_: _Key) -> Int
}

// MARK: -

public protocol BalancedView: BalancedSequence {

  associatedtype Index = UnsafeIndexV3

  // removeSubrangeや標準Rangeとのミスマッチがどうしてもあれなので、用語としてeraseを採用

  mutating func erase() -> Index
  mutating func erase(where: (Element) throws -> Bool) rethrows
}

// MARK: -

#if !COMPATIBLE_ATCODER_2025
extension RedBlackTreeSet: BalancedCollection {}
extension RedBlackTreeDictionary: BalancedCollection {}

extension RedBlackTreeMultiSet: BalancedMultiCollection {}
extension RedBlackTreeMultiMap: BalancedMultiCollection {}

extension RedBlackTreeKeyOnlyRangeView: BalancedView { }
extension RedBlackTreeKeyValueRangeView: BalancedView { }
#endif
