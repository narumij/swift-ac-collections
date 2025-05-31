// Copyright 2024 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

@usableFromInline
protocol ___SubSequenceBase: Sequence & Collection & BidirectionalCollection
where
  Tree == Base.Tree,
  Index == Base.Index,
  Indices == Tree.Indices,
  Element == Tree.Element,
  Iterator == ElementIterator<Base.Tree>,
  Self: RedBlackTreeSequenceBase,
  SubSequence == Self
{
  associatedtype Base: RedBlackTreeSubSequenceBase
  var _tree: Base.Tree { get }
  var _start: _NodePtr { get set }
  var _end: _NodePtr { get set }
  init(tree: Base.Tree, start: _NodePtr, end: _NodePtr)
}

extension ___SubSequenceBase {

  @inlinable
  public func makeIterator() -> ElementIterator<Base.Tree> {
    .init(tree: _tree, start: _start, end: _end)
  }
}

extension ___SubSequenceBase {

  @inlinable
  @inline(__always)
  internal func forEach(_ body: (Element) throws -> Void) rethrows {
    try _tree.___for_each_(__p: _start, __l: _end, body: body)
  }
}

extension ___SubSequenceBase {

  @inlinable @inline(__always)
  public var count: Int {
    _tree.___distance(from: _start, to: _end)
  }
}

extension ___SubSequenceBase {

  public var startIndex: Index {
    index(rawValue: _start)
  }

  public var endIndex: Index {
    index(rawValue: _end)
  }
}

extension ___SubSequenceBase {
  
  // 断念
  //    @inlinable
  //    public func lowerBound(_ member: Element) -> Index {
  //      base.__lower_bound(base.__key(member), base.__root(), endIndex)
  //    }
  //
  //    @inlinable
  //    public func upperBound(_ member: Element) -> Index {
  //      base.__upper_bound(base.__key(member), base.__root(), endIndex)
  //    }
}

extension ___SubSequenceBase {

  //  public typealias Index = Index

  @inlinable
  func index(rawValue: _NodePtr) -> Index {
    .init(__tree: _tree, rawValue: rawValue)
  }
}

extension ___SubSequenceBase {

  @inlinable
  @inline(__always)
  public subscript(position: Index) -> Element {

    _read {
//      guard _tree.___ptr_less_than_or_equal(_start, position.rawValue),
//        _tree.___ptr_less_than(position.rawValue, _end)
//      else {
//        fatalError(.outOfRange)
//      }
      yield _tree[position.rawValue]
    }
  }
}

extension ___SubSequenceBase {

  @inlinable
  public subscript(position: RawIndex) -> Element {
    @inline(__always)
    _read {
//      guard _tree.___ptr_less_than_or_equal(_start, position.rawValue),
//        _tree.___ptr_less_than(position.rawValue, _end)
//      else {
//        fatalError(.outOfRange)
//      }
      yield _tree[position.rawValue]
    }
  }
}

extension ___SubSequenceBase {

  @inlinable
  @inline(__always)
  public subscript(bounds: Range<Index>) -> SubSequence {
    guard _tree.___ptr_less_than_or_equal(_start, bounds.lowerBound.rawValue),
      _tree.___ptr_less_than_or_equal(bounds.upperBound.rawValue, _end)
    else {
      fatalError(.outOfRange)
    }
    return .init(
      tree: _tree,
      start: bounds.lowerBound.rawValue,
      end: bounds.upperBound.rawValue)
  }
}

extension ___SubSequenceBase {

  // この実装がないと、迷子になる?
  @inlinable @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    _tree.___distance(from: start.rawValue, to: end.rawValue)
  }
}

extension ___SubSequenceBase {

  @inlinable @inline(__always)
  public func index(before i: Index) -> Index {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    index(rawValue: _tree.___index(before: i.rawValue))
  }

  @inlinable @inline(__always)
  public func index(after i: Index) -> Index {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    index(rawValue: _tree.___index(after: i.rawValue))
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    // 標準のArrayが単純に加減算することにならい、範囲チェックをしない
    _tree.___index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
      .map { index(rawValue: $0) }
  }
}

extension ___SubSequenceBase {

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    _tree.___formIndex(after: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    // 標準のArrayが単純に減算することにならい、範囲チェックをしない
    _tree.___formIndex(before: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    // 標準のArrayが単純に加減算することにならい、範囲チェックをしない
    _tree.___formIndex(&i.rawValue, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    // 標準のArrayが単純に加減算することにならい、範囲チェックをしない
    if let ii = index(i, offsetBy: distance, limitedBy: limit) {
      i = ii
      return true
    }
    return false
  }
}

// MARK: - Raw Index Sequence

extension ___SubSequenceBase {

  /// RawIndexは赤黒木ノードへの軽量なポインタとなっていて、rawIndicesはRawIndexのシーケンスを返します。
  /// 削除時のインデックス無効対策がイテレータに施してあり、削除操作に利用することができます。
  @inlinable
  @inline(__always)
  public var rawIndices: RawIndexSequence<Self> {
    RawIndexSequence(
      tree: _tree,
      start: _start,
      end: _end)
  }
}

// MARK: - Raw Indexed Sequence

extension ___SubSequenceBase {

  @inlinable @inline(__always)
  public var rawIndexedElements: RawIndexedSequence<Self> {
    RawIndexedSequence(
      tree: _tree,
      start: _start,
      end: _end)
  }

  @available(*, deprecated, renamed: "rawIndexedElements")
  @inlinable @inline(__always)
  public func enumerated() -> RawIndexedSequence<Self> {
    rawIndexedElements
  }
}

// MARK: - Utility

extension ___SubSequenceBase {

  @inlinable
  @inline(__always)
  func ___is_valid_index(index i: _NodePtr) -> Bool {
    guard i != .nullptr, _tree.___is_valid(i) else {
      return false
    }
    return _tree.___ptr_closed_range_contains(_start, _end, i)
  }

  @inlinable
  @inline(__always)
  public func isValid(index i: Index) -> Bool {
    ___is_valid_index(index: i.___unchecked_rawValue)
  }

  @inlinable
  @inline(__always)
  public func isValid(index i: RawIndex) -> Bool {
    ___is_valid_index(index: i.rawValue)
  }
}

extension ___SubSequenceBase {
  
  @inlinable
  @inline(__always)
  public __consuming func reversed() -> ReversedElementIterator<Self.Tree> {
    .init(tree: _tree, start: _start, end: _end)
  }
}

extension ___SubSequenceBase {
  
  @inlinable
  @inline(__always)
  public var indices: Indices {
    _tree.makeIndices(start: _start, end: _end)
  }
}
