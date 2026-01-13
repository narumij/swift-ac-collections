//
//  UnsafeIndexCollection.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/13.
//

public
struct UnsafeIndexCollection<Base: ___TreeBase & ___TreeIndex> {
  
  public typealias Index = UnsafeIndexV2<Base>

  @usableFromInline
  typealias Deallocator = _UnsafeNodeFreshPoolDeallocator

  public var startIndex: Index
  public var endIndex: Index
  
  @usableFromInline
  internal var deallocator: Deallocator
  
  public typealias Element = Index
  
  // TODO: 削除対策型イテレータの実装
  // CoW抑制が効き出すと標準イテレータではクラッシュするはずなので
}

extension UnsafeIndexCollection: Sequence,Collection {
  
  public func index(after i: Index) -> Index {
    i.advanced(by: 1)
  }
  
  public subscript(position: Index) -> Index {
    position
  }
  
  public subscript(bounds: Range<Index>) -> UnsafeIndexCollection {
    .init(startIndex: bounds.lowerBound,
          endIndex: bounds.upperBound,
          deallocator: deallocator)
  }
}
