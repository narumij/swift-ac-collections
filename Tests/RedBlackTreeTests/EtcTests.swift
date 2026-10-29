// このファイル自体は整理整頓時に消さないこと
import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if !COMPATIBLE_ATCODER_2025 && DEBUG
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

  #if !COMPATIBLE_ATCODER_2025
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
  #endif

  #if !COMPATIBLE_ATCODER_2025 && DEBUG
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

  #if DEBUG && !COMPATIBLE_ATCODER_2025
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

#if COMPATIBLE_ATCODER_2025 && DEBUG
  // これ、整理整頓対象でいいかも
  extension EtcTests {
    /// 内部の逆順走査ヘルパー___rev_for_each_が正しい順序でノードを列挙すること
    func testRev() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      var result = [Int]()
      a.__tree_.___rev_for_each_(__p: a.startIndex.sealed, __l: a.endIndex.sealed) { p in
        result.append(p.index)
      }
      XCTAssertEqual(result, [2, 1, 0])
    }
  }
#endif

// 並行CoWの試行テスト。採用判断まで無効化して保存する。
// 再実行するときはfalseを!DEBUGへ戻し、Releaseで実行する。
#if false
// Debugのprocess-globalな検査カウンタ自体が並行更新されるため、
// 製品のCoWを検証するこの試験はReleaseで実行する。
// 同じvarの同時変更ではなく、Sendableな値を各タスクへコピーして使う。
final class EtcConcurrentCopyTests: XCTestCase {
  func testSetConcurrentCopies() async {
    let original = RedBlackTreeSet(0 ..< 256)
    let results = await withTaskGroup(of: (Int, [Int]).self) { group in
      for worker in 0 ..< 8 {
        group.addTask { [original] in
          var copy = original
          for key in 0 ..< 128 {
            copy.remove(key)
            copy.insert(1000 + worker * 128 + key)
          }
          return (worker, Array(copy))
        }
      }
      var values: [(Int, [Int])] = []
      for await value in group { values.append(value) }
      return values
    }
    XCTAssertEqual(Array(original), Array(0 ..< 256))
    XCTAssertEqual(results.count, 8)
    for (worker, values) in results {
      XCTAssertEqual(
        values,
        Array(128 ..< 256)
          + Array((1000 + worker * 128) ..< (1128 + worker * 128))
      )
    }
  }

  func testDictionaryConcurrentCopies() async {
    var initial = RedBlackTreeDictionary<Int, Int>()
    for key in 0 ..< 256 { initial[key] = key }
    let original = initial
    let results = await withTaskGroup(of: (Int, [Int], [Int]).self) { group in
      for worker in 0 ..< 8 {
        group.addTask { [original] in
          var copy = original
          for key in 0 ..< 128 {
            copy.removeValue(forKey: key)
            copy[key + 128] = worker
            copy[1000 + key] = worker + 100
          }
          return (worker, copy.map { $0.key }, copy.map { $0.value })
        }
      }
      var values: [(Int, [Int], [Int])] = []
      for await value in group { values.append(value) }
      return values
    }
    XCTAssertEqual(original.map { $0.key }, Array(0 ..< 256))
    XCTAssertEqual(original.map { $0.value }, Array(0 ..< 256))
    XCTAssertEqual(results.count, 8)
    for (worker, keys, values) in results {
      XCTAssertEqual(keys, Array(128 ..< 256) + Array(1000 ..< 1128))
      XCTAssertEqual(
        values,
        Array(repeating: worker, count: 128)
          + Array(repeating: worker + 100, count: 128)
      )
    }
  }
}
#endif
