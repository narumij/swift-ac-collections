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
public protocol BidirectionalSequence: Sequence {

  associatedtype Index: Equatable

  subscript(position: Index) -> Element { get }

  var startIndex: Index { get }
  var endIndex: Index { get }

  var isEmpty: Bool { get }

  var first: Element? { get }
  var last: Element? { get }

  func index(after i: Index) -> Index
  func index(before i: Index) -> Index

  func formIndex(after i: inout Index)
  func formIndex(before i: inout Index)

  mutating func popFirst() -> Element?
  mutating func removeFirst() -> Element
  mutating func removeFirst(_ k: Int)

  mutating func popLast() -> Element?
  mutating func removeLast() -> Element
  mutating func removeLast(_ k: Int)

  mutating func removeAll()
  mutating func removeAll(where: (Element) throws -> Bool) rethrows
  
  func sorted() -> [Element]
  func reversed() -> [Element]
}

extension BidirectionalSequence {

  public var isEmpty: Bool { startIndex == endIndex }

  public var first: Element? {
    isEmpty ? nil : self[startIndex]
  }

  public var last: Element? {
    guard !isEmpty else { return nil }
    return self[index(before: endIndex)]
  }
}

extension BidirectionalSequence {

  public func formIndex(after i: inout Index) {
    i = index(after: i)
  }

  public func formIndex(before i: inout Index) {
    i = index(before: i)
  }
}

extension BidirectionalSequence {

  public mutating func removeFirst(_ k: Int) {
    precondition(k >= 0)
    for _ in 0..<k { _ = removeFirst() }
  }

  public mutating func removeLast(_ k: Int) {
    precondition(k >= 0)
    for _ in 0..<k { _ = removeLast() }
  }
}
