//
//  unsafe_tree+three_way.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/06/01.
//

// MARK: -

#if DEBUG
  @testable import RedBlackTreeCollections

  @usableFromInline
  package
    protocol LazySynthThreeWayComparator: _TreeKey_LazyThreeWayCompInterface
  where
    Self: _BaseKey_LessThanInterface, __compare_result == __lazy_compare_result<Self>
  {}

  extension LazySynthThreeWayComparator {

    @inlinable
    public func
      __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
      -> __lazy_compare_result<Self>
    {
      __lazy_compare_result(__lhs, __rhs)
    }
  }

  @usableFromInline
  package
    protocol ComparableThreeWayComparator: _TreeKey_LazyThreeWayCompInterface
  where _Key: Comparable, __compare_result == __comparable_compare_result<_Key> {}

  extension ComparableThreeWayComparator {

    @inlinable
    public func
      __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
      -> __comparable_compare_result<
        _Key
      >
    {
      __comparable_compare_result(__lhs, __rhs)
    }
  }
#endif
