//
//  NextPermutationsSequence_98_InternalTests.swift
//  swift-ac-collections
//

// 実装の確認(仕様ではない)。`AC_COLLECTIONS_INTERNAL_CHECKS`のときだけ有効。

#if AC_COLLECTIONS_INTERNAL_CHECKS
  import PermutationModule
  import XCTest

  final class NextPermutationsSequence_98_InternalTests: XCTestCase {

    func testNoCopyWhenResultsAreNotRetained() throws {
      // 結果を保持せずに進めるなら、bufferのコピーは起きない
      for p in (0..<4).nextPermutations() {
        XCTAssertEqual(p._copyCount, 0)
      }
    }
  }
#endif
