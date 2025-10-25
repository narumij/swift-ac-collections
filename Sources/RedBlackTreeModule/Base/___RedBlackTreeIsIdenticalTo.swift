//
//  ___RedBlackTreeIsIdenticalTo.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/10/22.
//

@usableFromInline
protocol ___RedBlackTreeIsIdenticalTo {
  associatedtype Base: ___TreeBase
  var __tree_: ___Tree<Base> { get }
  var _start: _NodePtr { get }
  var _end: _NodePtr { get }
}

// MARK: - Is Identical To

extension ___RedBlackTreeIsIdenticalTo {

  /// Returns a boolean value indicating whether this set is identical to
  /// `other`.
  ///
  /// Two set values are identical if there is no way to distinguish between
  /// them.
  ///
  /// For any values `a`, `b`, and `c`:
  ///
  /// - `a.isIdentical(to: a)` is always `true`. (Reflexivity)
  /// - `a.isIdentical(to: b)` implies `b.isIdentical(to: a)`. (Symmetry)
  /// - If `a.isIdentical(to: b)` and `b.isIdentical(to: c)` are both `true`,
  ///   then `a.isIdentical(to: c)` is also `true`. (Transitivity)
  /// - `a.isIdentical(b)` implies `a == b`
  ///   - `a == b` does not imply `a.isIdentical(b)`
  ///
  /// Values produced by copying the same value, with no intervening mutations,
  /// will compare identical:
  ///
  /// ```swift
  /// let d = c
  /// print(c.isIdentical(to: d))
  /// // Prints true
  /// ```
  ///
  /// Comparing sets this way includes comparing (normally) hidden
  /// implementation details such as the memory location of any underlying set
  /// storage object. Therefore, identical sets are guaranteed to compare equal
  /// with `==`, but not all equal sets are considered identical.
  ///
  /// - Performance: O(1)
  @inlinable
  @inline(__always)
  public func isIdentical(to other: Self) -> Bool {
    __tree_.isIdentical(to: other.__tree_) && _start == other._start && _end == other._end
  }
}
