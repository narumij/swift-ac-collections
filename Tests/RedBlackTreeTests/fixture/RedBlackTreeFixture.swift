//
//  RedBlackTreeFixture.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/10/25.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

#if DEBUG
  protocol RedBlackTreeDebugFixture: ___TreeBase {
    associatedtype Base: ___TreeBase
    var __tree_: UnsafeTreeV2<Base> { get set }
  }

  extension RedBlackTreeDebugFixture {

    func __left_(_ p: _NodePtr) -> _NodePtr {
      __tree_.__left_(p)
    }
    func __right_(_ p: _NodePtr) -> _NodePtr {
      __tree_.__right_(p)
    }
    var __root: _NodePtr {
      get { __tree_.__root }
      set { __tree_.__root = newValue }
    }
    mutating func __root(_ p: _NodePtr) {
      __tree_.__left_(__tree_.end, p)
    }
    func
      __tree_min(_ __x: _NodePtr) -> _NodePtr
    {
      __tree_.__tree_min(__x)
    }
    func
      __tree_max(_ __x: _NodePtr) -> _NodePtr
    {
      __tree_.__tree_max(__x)
    }
    mutating func
      __tree_left_rotate(_ __x: _NodePtr)
    {
      __tree_.__tree_left_rotate(__x)
    }
    mutating func
      __tree_right_rotate(_ __x: _NodePtr)
    {
      __tree_.__tree_right_rotate(__x)
    }
    mutating func
      __tree_balance_after_insert(_ __root: _NodePtr, _ __x: _NodePtr)
    {
      __tree_._std__tree_balance_after_insert(__root, __x)
    }
  }

  extension RedBlackTreeSet: RedBlackTreeDebugFixture {}
  extension RedBlackTreeMultiSet: RedBlackTreeDebugFixture {}
  extension RedBlackTreeMultiMap: RedBlackTreeDebugFixture {}
  extension RedBlackTreeDictionary: RedBlackTreeDebugFixture {}
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
  func left(_ p: _Key) -> Int {
    distance(from: startIndex, to: lowerBound(p))
  }
  func right(_ p: _Key) -> Int {
    distance(from: startIndex, to: upperBound(p))
  }
}

extension RedBlackTreeSet: RedBlackTreeFixture {}
extension RedBlackTreeMultiSet: RedBlackTreeFixture {}
extension RedBlackTreeMultiMap: RedBlackTreeFixture {}
extension RedBlackTreeDictionary: RedBlackTreeFixture {}

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
