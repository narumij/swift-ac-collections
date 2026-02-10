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
  var count: Int { get }

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

public protocol BalancedView: BalancedSequence {

  mutating func erase()
  mutating func erase(where: (Element) throws -> Bool) rethrows
}

// MARK: -

public protocol BalancedCollection: Sequence {

  associatedtype Index: Equatable
  associatedtype View: BalancedView
  associatedtype RangeExpression = TaggedSealRangeExpression

  subscript(position: Index) -> Element { get }
  subscript(range: RangeExpression) -> View { get }

  var startIndex: Index { get }
  var endIndex: Index { get }

  func index(after i: Index) -> Index
  func index(before i: Index) -> Index

  func formIndex(after i: inout Index)
  func formIndex(before i: inout Index)

  mutating func remove(_: Element) -> Element?
  mutating func removeAll()
  mutating func removeAll(keepingCapacity keepCapacity: Bool)

  // MARK: -

  subscript(position: RedBlackTreeBoundExpression<Element>) -> Element? { get }
  subscript(range: RedBlackTreeBoundRangeExpression<Element>) -> View { get }

  func lowerBound(_ member: Element) -> Index
  func upperBound(_ member: Element) -> Index

  mutating func erase(_: Index) -> Index
  mutating func erase(_: RangeExpression)
  mutating func erase(_: RangeExpression, where: (Element) throws -> Bool) rethrows
  mutating func erase(_: RedBlackTreeBoundExpression<Element>) -> Element?
  mutating func erase(_: RedBlackTreeBoundRangeExpression<Element>)
  mutating func erase(_: RedBlackTreeBoundRangeExpression<Element>, where: (Element) throws -> Bool)
    rethrows
  mutating func eraseAll(where: (Element) throws -> Bool) rethrows
  mutating func eraseAll()
}
