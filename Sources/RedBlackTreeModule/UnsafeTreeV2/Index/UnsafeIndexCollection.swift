//
//  UnsafeIndexCollection.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/13.
//

public
  struct UnsafeIndexCollection<Base: ___TreeBase & ___TreeIndex>: UnsafeTreePointer
{

  internal init(tree: UnsafeTreeV2<Base>, start: _NodePtr, end: _NodePtr) {

    self.startIndex = .init(tree: tree, rawValue: start)
    self.endIndex = .init(tree: tree, rawValue: end)
    self.deallocator = tree.deallocator
  }

  internal init(
    startIndex: Index,
    endIndex: Index,
    deallocator: Deallocator
  ) {

    self.startIndex = startIndex
    self.endIndex = endIndex
    self.deallocator = deallocator
  }

  public typealias Index = UnsafeIndexV2<Base>

  @usableFromInline
  typealias Deallocator = _UnsafeNodeFreshPoolDeallocator

  public var startIndex: Index
  public var endIndex: Index

  @usableFromInline
  internal var deallocator: Deallocator

  public typealias Element = Index
}

extension UnsafeIndexCollection {

  @inlinable
  @inline(__always)
  internal func ___index(_ p: _NodePtr) -> Index {
    .init(
      __tree_: endIndex.__tree_,
      rawValue: p,
      deallocator: endIndex.deallocator)
  }

  public struct Iterator: IteratorProtocol {
    internal init(
      startIndex: UnsafeIndexCollection<Base>.Index,
      endIndex: UnsafeIndexCollection<Base>.Index
    ) {
      self.startIndex = startIndex
      self.endIndex = endIndex
      self.currentIndex = startIndex
      self.nextIndex = startIndex.advanced(by: 1)
    }

    public var startIndex: Index
    public var endIndex: Index
    var currentIndex: Index
    var nextIndex: Index

    public mutating func next() -> UnsafeIndexV2<Base>? {
      guard currentIndex != endIndex else { return nil }
      defer {
        currentIndex = nextIndex
        nextIndex = nextIndex == endIndex ? endIndex : nextIndex.advanced(by: 1)
      }
      return currentIndex
    }
  }
}

extension UnsafeIndexCollection: Sequence, Collection {

  public func makeIterator() -> Iterator {
    .init(startIndex: startIndex, endIndex: endIndex)
  }

  public func index(after i: Index) -> Index {
    i.advanced(by: 1)
  }

  public subscript(position: Index) -> Index {
    position
  }

  public subscript(bounds: Range<Index>) -> UnsafeIndexCollection {
    .init(
      startIndex: bounds.lowerBound,
      endIndex: bounds.upperBound,
      deallocator: deallocator)
  }
}
