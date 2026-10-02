// このファイル自体は整理整頓時に消さないこと
import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
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
