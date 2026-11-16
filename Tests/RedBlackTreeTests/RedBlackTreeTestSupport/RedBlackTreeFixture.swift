//
//  RedBlackTreeFixture.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/10/25.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

protocol RedBlackTreeFixture: Sequence {
  associatedtype Index
  associatedtype _Key
  var startIndex: Index { get }
  func distance(from start: Index, to end: Index) -> Int
  func lowerBound(_ member: _Key) -> Index
  func upperBound(_ member: _Key) -> Index
}

extension RedBlackTreeFixture {
  var elements: [Element] {
    map { $0 }
  }
}

extension RedBlackTreeFixture {
  func left(_ p: _Key) -> _TrackingTag {
    _TrackingTag(distance(from: startIndex, to: lowerBound(p)))
  }
  func right(_ p: _Key) -> _TrackingTag {
    _TrackingTag(distance(from: startIndex, to: upperBound(p)))
  }
}

extension RedBlackTreeSet: RedBlackTreeFixture {}
extension RedBlackTreeMultiSet: RedBlackTreeFixture {}
extension RedBlackTreeMultiMap: RedBlackTreeFixture {}
extension RedBlackTreeDictionary: RedBlackTreeFixture {}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeKeyOnlyRangeView
  where Base: _BaseNode_KeyInterface, Base._Key: Comparable {
    func isValid(index: Index) -> Bool {
      isElement(at: index) || isEnd(index)
    }
  }

  extension RedBlackTreeKeyValueRangeView
  where Base: _BaseNode_KeyInterface, Base._Key: Comparable {
    func isValid(index: Index) -> Bool {
      isElement(at: index) || isEnd(index)
    }
  }
#endif

func assertEquiv<Target>(
  _ lhs: Target,
  _ rhs: Target,
  file: StaticString = #file, line: UInt = #line
) where Target: RedBlackTreeFixture, Target.Element: Equatable {
  XCTAssertEqual(lhs.elements, rhs.elements, file: (file), line: line)
}

func assertEquiv<LHS: RedBlackTreeFixture>(
  _ lhs: LHS,
  _ rhs: [LHS.Element],
  file: StaticString = #file, line: UInt = #line
) where LHS.Element: Equatable {
  XCTAssertEqual(lhs.elements, rhs, file: (file), line: line)
}

func assertEquiv<LHS>(
  _ lhs: LHS,
  _ rhs: Set<LHS.Element>,
  file: StaticString = #file, line: UInt = #line
) where LHS: RedBlackTreeFixture, LHS.Element: Comparable {
  XCTAssertEqual(lhs.elements, rhs.sorted(), file: (file), line: line)
}
