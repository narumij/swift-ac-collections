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
