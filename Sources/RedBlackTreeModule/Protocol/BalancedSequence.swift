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
  mutating func removeFirst(_ k: Int)

  mutating func popLast() -> Element?
  mutating func removeLast() -> Element
  mutating func removeLast(_ k: Int)

  func sorted() -> [Element]
  func reversed() -> [Element]
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

  associatedtype Key
  associatedtype Index: Equatable
  associatedtype View: BalancedView
  associatedtype Range = UnsafeIndexV3RangeExpression
  associatedtype Bound = RedBlackTreeBoundExpression<Element>
  associatedtype BoundRange = RedBlackTreeBoundRangeExpression<Element>

  var count: Int { get }

  subscript(position: Index) -> Element { get }
  subscript(range: Range) -> View { get }

  var startIndex: Index { get }
  var endIndex: Index { get }

  func index(after: Index) -> Index
  func index(before: Index) -> Index
  func index(_: Index, offsetBy distance: Int)
  func index(_: Index, offsetBy distance: Int, limitedBy limit: Index)

  func formIndex(after: inout Index)
  func formIndex(before: inout Index)
  func formIndex(_: inout Index, offsetBy distance: Int)
  func formIndex(_: inout Index, offsetBy distance: Int, limitedBy limit: Index) -> Bool

  mutating func remove(_: Key) -> Element?
  mutating func removeAll()
  mutating func removeAll(keepingCapacity keepCapacity: Bool)

  // MARK: -

  subscript(position: RedBlackTreeBoundExpression<Element>) -> Element? { get }
  subscript(range: RedBlackTreeBoundRangeExpression<Element>) -> View { get }

  func lowerBound(_: Element) -> Index
  func upperBound(_: Element) -> Index
  func find(_: Element) -> Index?

  // removeSubrangeや標準Rangeとのミスマッチがどうしてもあれなので、用語としてeraseを採用

  mutating func erase(_: Index) -> Index
  mutating func erase(_: Range)
  mutating func erase(_: Range, where: (Element) throws -> Bool) rethrows

  mutating func erase(_: Bound) -> Element?
  mutating func erase(_: BoundRange)
  mutating func erase(_: BoundRange, where: (Element) throws -> Bool) rethrows

  mutating func eraseAll(where: (Element) throws -> Bool) rethrows
  mutating func eraseAll()
}

// MARK: -

public protocol BalancedView: BalancedSequence {

  // removeSubrangeや標準Rangeとのミスマッチがどうしてもあれなので、用語としてeraseを採用

  mutating func erase()
  mutating func erase(where: (Element) throws -> Bool) rethrows
}
