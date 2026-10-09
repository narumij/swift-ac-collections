// このファイル自体は整理整頓時に消さないこと
import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if DEBUG
  /// Test-only marker for sequences whose iteration order is ascending.
  private protocol SortedSequence: Sequence {}

  extension Range: SortedSequence where Self: Sequence {}
  extension ClosedRange: SortedSequence where Self: Sequence {}

  extension RedBlackTreeSet {
    fileprivate func union<S>(_ other: S) -> RedBlackTreeSet<Element>
    where S: SortedSequence, S.Element == Element {
      .init(__tree_: __tree_.___meld_unique(other))
    }
  }

  extension UnsafeTreeV2 {
    fileprivate mutating func ___copy_range<Iterator: IteratorProtocol>(
      _ iterator: inout Iterator,
      to parent: UnsafeMutablePointer<UnsafeNode>,
      _ child: UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
    ) where Iterator.Element == _PayloadValue {
      var (parent, child) = (parent, child)
      while let payload = iterator.next() {
        unsafeEnsureCapacity()
        (parent, child) = ___emplace_hint_right(parent, child, payload)
      }
    }

    fileprivate func ___meld_unique<S>(_ other: S) -> UnsafeTreeV2
    where S: SortedSequence, S.Element == _PayloadValue {
      var result: UnsafeTreeV2 =
        ._createWithNewBuffer(minimumCapacity: 2, nullptr: nullptr)
      var (parent, child) = result.___max_ref()
      var (first, last) = (__begin_node_, __end_node)
      var iterator = other.makeIterator()

      outer: while let payload = iterator.next() {
        while first != last {
          let value = __get_value(first)
          if value_comp(__key(payload), value) {
            result.unsafeEnsureCapacity()
            (parent, child) = result.___emplace_hint_right(parent, child, payload)
            continue outer
          }

          result.unsafeEnsureCapacity()
          (parent, child) = result.___emplace_hint_right(
            parent, child, Base.__payload_(first)
          )
          first = __tree_next_iter(first)
          if !value_comp(value, __key(payload)) {
            continue outer
          }
        }

        result.unsafeEnsureCapacity()
        (parent, child) = result.___emplace_hint_right(parent, child, payload)
        result.___copy_range(&iterator, to: parent, child)
        return result
      }

      result.___copy_range(first, last, to: parent, child)
      return result
    }
  }
#endif

/// 棚卸し用の雑多な検証置き場。
final class EtcTests: RedBlackTreeTestCase, _UnsafeNodePtrType {

  override func setUpWithError() throws {
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    try super.tearDownWithError()
  }

    /// `formIndex(_:offsetBy:limitedBy:)`が、現在の基準である`String`と同じく、
    /// limit到達時は成功し、超過時はlimitまで移動して失敗を返すこと。
    func testFormIndexLimitedByMatchesString() {
      let string = "abcd"
      let stringLimit = string.index(after: string.startIndex)

      var stringExact = string.startIndex
      XCTAssertTrue(string.formIndex(&stringExact, offsetBy: 1, limitedBy: stringLimit))
      XCTAssertEqual(stringExact, stringLimit)

      var stringOver = string.startIndex
      XCTAssertFalse(string.formIndex(&stringOver, offsetBy: 2, limitedBy: stringLimit))
      XCTAssertEqual(stringOver, stringLimit)

      let set = RedBlackTreeSet([0, 1, 2, 3])
      let setLimit = set.index(after: set.startIndex)

      var setExact = set.startIndex
      XCTAssertTrue(set.formIndex(&setExact, offsetBy: 1, limitedBy: setLimit))
      XCTAssertEqual(setExact, setLimit)

      var setOver = set.startIndex
      XCTAssertFalse(set.formIndex(&setOver, offsetBy: 2, limitedBy: setLimit))
      XCTAssertEqual(setOver, setLimit)
    }

  #if DEBUG
    func testAPICheck() throws {

      do {
        let result = RedBlackTreeSet([1, 2]).union(0..<10)
        XCTAssertTrue(result.elementsEqual(0..<10), "\(result)")
      }

      do {
        let result = RedBlackTreeSet([1, 2]).union(0...10)
        XCTAssertTrue(result.elementsEqual(0...10), "\(result)")
      }
    }
  #endif

  #if DEBUG
    /// 空配列をdecodeした場合、生木が共有の読み取り専用シングルトンになっていること
    /// (無駄なバッファ確保をしない。2026-10-03、Decodable非ソート・重複入力バグ修正の副次確認)
    func testDecodeEmptyArrayUsesReadOnlySingleton() throws {
      let decoder = JSONDecoder()
      let emptyJSON = "[]".data(using: .utf8)!

      let emptySet = try decoder.decode(RedBlackTreeSet<Int>.self, from: emptyJSON)
      XCTAssertTrue(emptySet.__tree_.isReadOnly)

      let emptyDict = try decoder.decode(RedBlackTreeDictionary<Int, String>.self, from: emptyJSON)
      XCTAssertTrue(emptyDict.__tree_.isReadOnly)

      let emptyMultiSet = try decoder.decode(RedBlackTreeMultiSet<Int>.self, from: emptyJSON)
      XCTAssertTrue(emptyMultiSet.__tree_.isReadOnly)

      let emptyMultiMap = try decoder.decode(RedBlackTreeMultiMap<Int, String>.self, from: emptyJSON)
      XCTAssertTrue(emptyMultiMap.__tree_.isReadOnly)
    }
  #endif

}
