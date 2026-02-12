#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func reversed() -> Tree._KeyValues.Reversed {
      _reversed()
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// 特殊なforEach
    @inlinable
    @inline(__always)
    public func forEach(_ body: (Index, Element) throws -> Void) rethrows {
      try _forEach(body)
    }
  }

  extension RedBlackTreeDictionary {

    @inlinable
    @inline(__always)
    public func forEach(_ body: (Element) throws -> Void) rethrows {
      try _forEach(body)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// - Important:
    ///  要素及びノードが削除された場合、インデックスは無効になります。
    /// 無効なインデックスを使用するとランタイムエラーや不正な参照が発生する可能性があるため注意してください。
    public typealias Index = Tree.Index
  }

  // MARK: Finding Elements

  extension RedBlackTreeDictionary {

    /// - Complexity: O(log *n*)
    @inlinable
    public func lowerBound(_ p: Key) -> Index {
      ___index_lower_bound(p)
    }

    /// - Complexity: O(log *n*)
    @inlinable
    public func upperBound(_ p: Key) -> Index {
      ___index_upper_bound(p)
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(log *n*)
    @inlinable
    public func equalRange(_ key: Key) -> (lower: Index, upper: Index) {
      ___index_equal_range(key)
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(log *n*)
    @inlinable
    public func firstIndex(of key: Key) -> Index? {
      ___first_index(of: key)
    }

    /// - Complexity: O(*n*)
    @inlinable
    public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
      try ___first_index(where: predicate)
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(*d* + log *n*)
    @inlinable
    //  @inline(__always)
    public func distance(from start: Index, to end: Index) -> Int {
      _distance(from: start, to: end)
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var startIndex: Index { _startIndex }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var endIndex: Index { _endIndex }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func index(after i: Index) -> Index {
      _index(after: i)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func index(before i: Index) -> Index {
      _index(before: i)
    }

    /// - Complexity: O(*d*)
    @inlinable
    //  @inline(__always)
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
      _index(i, offsetBy: distance)
    }

    /// - Complexity: O(*d*)
    @inlinable
    //  @inline(__always)
    public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
      _index(i, offsetBy: distance, limitedBy: limit)
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func formIndex(after i: inout Index) {
      _formIndex(after: &i)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func formIndex(before i: inout Index) {
      _formIndex(before: &i)
    }

    /// - Complexity: O(*d*)
    @inlinable
    //  @inline(__always)
    public func formIndex(_ i: inout Index, offsetBy distance: Int) {
      _formIndex(&i, offsetBy: distance)
    }

    /// - Complexity: O(*d*)
    @inlinable
    //  @inline(__always)
    public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
      -> Bool
    {
      _formIndex(&i, offsetBy: distance, limitedBy: limit)
    }
  }

  extension RedBlackTreeDictionary {

    /*
     しばらく苦しめられていたテストコードのコンパイルエラーについて。
    
     typecheckでクラッシュしてることはクラッシュログから読み取れる。
     推論に失敗するバグを踏んでいると想定し、型をちゃんと書くことで様子を見ることにした。
    
     型推論のバグなんて直せる気がまったくせず、ごくごく一部の天才のミラクルムーブ期待なので、
     これでクラッシュが落ち着くようならElementを返すメンバー全てで型をちゃんと書くのが安全かもしれない
    
     type packは型を書けないケースなので、この迂回策が使えず、バグ修正を待つばかり
     */

    /// - Complexity: O(1)
    @inlinable
    //  public subscript(position: Index) -> Element {
    public subscript(position: Index) -> (key: Key, value: Value) {
      //    @inline(__always) get { ___element(self[_checked: position]) }
      // コンパイラがクラッシュする
      //    @inline(__always) _read { yield self[_checked: position] }
      // コンパイラがクラッシュする場合もある
      @inline(__always) get { self[_checked: position] }
    }

    /// Indexがsubscriptやremoveで利用可能か判別します
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func isValid(index: Index) -> Bool {
      _isValid(index: index)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {
    /// RangeExpressionがsubscriptやremoveで利用可能か判別します
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func isValid<R: RangeExpression>(_ bounds: R) -> Bool
    where R.Bound == Index {
      _isValid(bounds)
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var indices: Indices {
      _indices
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  // MARK: - SubSequence

  extension RedBlackTreeDictionary {

    public typealias SubSequence = RedBlackTreeSliceV2<Self>.KeyValue
  }

  // MARK: - Index Range

  extension RedBlackTreeDictionary {

    public typealias Indices = Tree.Indices
  }
#endif

#if COMPATIBLE_ATCODER_2025

  extension RedBlackTreeDictionary {
    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.__purified_(bounds.lowerBound),
        end: __tree_.__purified_(bounds.upperBound))
    }
  }

  extension RedBlackTreeDictionary {
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func keys() -> Keys {
      _keys()
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func values() -> Values {
      _values()
    }
  }

  // Rangeの使い方としておかしいので、便利だが将来的に削除することにした
  extension RedBlackTreeDictionary {

    // setやmultisetと比べて、驚き最小違反とはいいにくいので、deprecatedには一旦しない
    /// 範囲 `[lower, upper)` に含まれる要素を返します。
    /// - Complexity: O(log *n*)
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeDictionary {
    ///   public func sequence(from start: Key, to end: Key) -> SubSequence {
    ///     self[lowerBound(start)..<lowerBound(end)]
    ///   }
    /// }
    /// ```
    @available(*, deprecated)
    public subscript(bounds: Range<Key>) -> SubSequence {
      elements(in: bounds)
    }

    // setやmultisetと比べて、驚き最小違反とはいいにくいので、deprecatedには一旦しない
    /// 範囲 `[lower, upper]` に含まれる要素を返します。
    /// - Complexity: O(log *n*)
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeDictionary {
    ///   public func sequence(from start: Key, through end: Key) -> SubSequence {
    ///     self[lowerBound(start)..<upperBound(end)]
    ///   }
    /// }
    /// ```
    @available(*, deprecated)
    public subscript(bounds: ClosedRange<Key>) -> SubSequence {
      elements(in: bounds)
    }
  }

  extension RedBlackTreeDictionary {
    /// キーレンジ `[lower, upper)` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeDictionary {
    ///   public func sequence(from start: Key, to end: Key) -> SubSequence {
    ///     self[lowerBound(start)..<lowerBound(end)]
    ///   }
    /// }
    /// ```
    @available(*, deprecated)
    public func elements(in range: Range<Key>) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.lower_bound(range.lowerBound).sealed,
        end: __tree_.lower_bound(range.upperBound).sealed)
    }

    /// キーレンジ `[lower, upper]` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    ///
    /// **Deprecated – 以下の代替コードをご利用ください。**
    ///
    /// ```swift
    /// extension RedBlackTreeDictionary {
    ///   public func sequence(from start: Key, through end: Key) -> SubSequence {
    ///     self[lowerBound(start)..<upperBound(end)]
    ///   }
    /// }
    /// ```
    @available(*, deprecated)
    public func elements(in range: ClosedRange<Key>) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.lower_bound(range.lowerBound).sealed,
        end: __tree_.upper_bound(range.upperBound).sealed)
    }
  }

  extension RedBlackTreeDictionary {

    /// - Important: 削除したメンバーを指すインデックスが無効になります。
    /// - Complexity: O(log *n* + *k*)
    @inlinable
    @inline(__always)
    public mutating func remove(contentsOf keyRange: Range<Key>) {
      __tree_._strongEnsureUnique()
      let lower = __tree_.lower_bound(keyRange.lowerBound)
      let upper = __tree_.lower_bound(keyRange.upperBound)
      ___remove(from: lower, to: upper)
    }

    /// - Important: 削除したメンバーを指すインデックスが無効になります。
    /// - Complexity: O(log *n* + *k*)
    @inlinable
    @inline(__always)
    public mutating func remove(contentsOf keyRange: ClosedRange<Key>) {
      __tree_._strongEnsureUnique()
      let lower = __tree_.lower_bound(keyRange.lowerBound)
      let upper = __tree_.upper_bound(keyRange.upperBound)
      ___remove(from: lower, to: upper)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  // 便利止まりだし、標準にならうと不自然なので、将来的に削除する
  extension RedBlackTreeDictionary where Value: Equatable {

    /// - Complexity: O(*m*), where *m* is the lesser of the length of the
    ///   sequence and the length of `other`.
    @inlinable
    @inline(__always)
    public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
    where OtherSequence: Sequence, Element == OtherSequence.Element {
      elementsEqual(other, by: ==)
    }
  }

  // 便利止まりだし、標準にならうと不自然なので、将来的に削除する
  extension RedBlackTreeDictionary where Value: Comparable {

    /// - Complexity: O(*m*), where *m* is the lesser of the length of the
    ///   sequence and the length of `other`.
    @inlinable
    @inline(__always)
    public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
    where OtherSequence: Sequence, Element == OtherSequence.Element {
      lexicographicallyPrecedes(other, by: <)
    }
  }
#endif
