//
//  RedBlackTreeCollection.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

#if COMPATIBLE_ATCODER_2025

  @usableFromInline
  protocol RedBlackTreeBoundResolverProtocol: Collection
  where Base: ___TreeBase {
    associatedtype _Key
    associatedtype Base
    associatedtype Index
    var startIndex: Index { get }
    var endIndex: Index { get }
    func lowerBound(_: _Key) -> Index
    func upperBound(_: _Key) -> Index
  }

  extension RedBlackTreeBoundExpression {

    @usableFromInline
    func relative<C: RedBlackTreeBoundResolverProtocol>(to collection: C)
      -> C.Index
    where _Key == C._Key {
      switch self {
      case .start:
        return collection.startIndex
      case .end:
        return collection.endIndex
      case .lower(let l):
        return collection.lowerBound(l)
      case .upper(let r):
        return collection.upperBound(r)
      case .advanced(let __self, offset: let offset, _):
        let i = __self.relative(to: collection)
        return collection.index(i, offsetBy: offset)
      case .before(let __self):
        return
          RedBlackTreeBoundExpression
          .advanced(__self, offset: -1)
          .relative(to: collection)
      case .after(let __self):
        return
          RedBlackTreeBoundExpression
          .advanced(__self, offset: 1)
          .relative(to: collection)
      default:
        fatalError("NOT IMPLEMENTED YET")
      }
    }
  }

  extension RedBlackTreeBoundResolverProtocol {

    func relative<K>(to boundsExpression: RedBlackTreeBoundRangeExpression<K>) -> (Index, Index)
    where K == _Key {
      switch boundsExpression {
      case .range(let lhs, let rhs):
        return (
          lhs.relative(to: self),
          rhs.relative(to: self)
        )
      case .closedRange(let lhs, let rhs):
        return (
          lhs.relative(to: self),
          index(after: rhs.relative(to: self))
        )
      case .partialRangeTo(let rhs):
        return (
          startIndex,
          rhs.relative(to: self)
        )
      case .partialRangeThrough(let rhs):
        return (
          startIndex,
          index(after: rhs.relative(to: self))
        )
      case .partialRangeFrom(let lhs):
        return (
          lhs.relative(to: self),
          endIndex
        )
      default:
        fatalError("NOT IMPLEMENTED YET")
      }
    }
  }

  extension RedBlackTreeSet: RedBlackTreeBoundResolverProtocol {

    public mutating func removeBounds(
      _ bounds: RedBlackTreeBoundRangeExpression<Element>,
      where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {
      reserveCapacity(capacity)
      var (lower, upper) = relative(to: bounds)
      while lower != upper, lower != endIndex {
        if try shouldBeRemoved(self[lower]) {
          lower = ___erase(lower)
        } else {
          lower = index(after: lower)
        }
      }
    }
  }

  extension RedBlackTreeMultiSet: RedBlackTreeBoundResolverProtocol {

  }

  extension RedBlackTreeDictionary: RedBlackTreeBoundResolverProtocol {

  }

  extension RedBlackTreeMultiMap: RedBlackTreeBoundResolverProtocol {

  }
#endif
