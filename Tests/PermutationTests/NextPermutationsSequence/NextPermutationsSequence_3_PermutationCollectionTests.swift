//
//  NextPermutationsSequence_3_PermutationCollectionTests.swift
//  swift-ac-collections
//

// yieldされる`Permutation`(RandomAccessCollection)のTest as Specification。
// 範囲外の添字は`NextPermutationsSequence_99_DeathTests`で固定する。

import PermutationModule
import XCTest

final class NextPermutationsSequence_3_PermutationCollectionTests: XCTestCase {

  func testIndicesStartAtZeroForArraySource() throws {
    var iterator = [1, 2, 3].nextPermutations().makeIterator()
    _ = iterator.next()
    let p = try XCTUnwrap(iterator.next())
    XCTAssertEqual(p.startIndex, 0)
    XCTAssertEqual(p.endIndex, 3)
    XCTAssertEqual(p.count, 3)
  }

  func testSubscriptAtValidBoundaries() throws {
    // 有効範囲の両端(startIndex と endIndex - 1)は添字でアクセスできる。
    var iterator = [1, 2, 3].nextPermutations().makeIterator()
    _ = iterator.next()
    let p = try XCTUnwrap(iterator.next())
    XCTAssertEqual(p[p.startIndex], 1)
    XCTAssertEqual(p[p.endIndex - 1], 2)
  }
}
