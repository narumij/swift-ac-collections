//
//  NextPermutationsSequence_98_InternalTests.swift
//  swift-ac-collections
//

// 実装の確認(仕様ではない)。`AC_COLLECTIONS_INTERNAL_CHECKS`のときだけ有効。

#if AC_COLLECTIONS_INTERNAL_CHECKS
  @testable import PermutationModule
  import XCTest

  final class NextPermutationsSequence_98_InternalTests: XCTestCase {

    func testBufferDestroysHeaderOnce() throws {
      // bufferの破棄でheaderは1回だけ破棄される。二重に破棄すると、headerが持つ参照も
      // 二重に解放される
      let before = NextPermutationsHeaderProbe.deinitCount
      do {
        var iterator = [1, 2, 3].nextPermutations().makeIterator()
        _ = iterator.next()
      }
      XCTAssertEqual(NextPermutationsHeaderProbe.deinitCount - before, 1)
    }

    func testNoCopyWhenFinishingWhileLastResultIsRetained() throws {
      // 最後の結果を保持したまま終端に達しても、終わりを知るためだけのbufferのコピーは起きない。
      // bufferが1つだけなら、破棄されるheaderも1つになる
      let before = NextPermutationsHeaderProbe.deinitCount
      do {
        var iterator = [1, 2].nextPermutations().makeIterator()
        _ = iterator.next()
        let last = iterator.next()
        withExtendedLifetime(last) {
          XCTAssertNil(iterator.next())
        }
      }
      XCTAssertEqual(NextPermutationsHeaderProbe.deinitCount - before, 1)
    }

    func testNoCopyWhenResultsAreNotRetained() throws {
      // 結果を保持せずに進めるなら、bufferのコピーは起きない
      for p in (0..<4).nextPermutations() {
        XCTAssertEqual(p._copyCount, 0)
      }
    }
  }
#endif
