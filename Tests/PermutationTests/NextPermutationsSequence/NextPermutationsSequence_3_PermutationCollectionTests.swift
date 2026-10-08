//
//  NextPermutationsSequence_3_PermutationCollectionTests.swift
//  swift-ac-collections
//

// yieldされる`Permutation`(RandomAccessCollection)のTest as Specification。
// 範囲外の添字は`NextPermutationsSequence_99_DeathTests`で固定する。
// 等値・ハッシュ・表示は、要素の並びだけで決まる(2026-10-07から)。

#if !COMPATIBLE_ATCODER_2025
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

  func testIndicesStartAtZeroForAnySource() throws {
    // 結果の添字は、入力の添字型や起点に関係なく0始まりのInt(2026-10-07から契約)。
    let slice = [9, 3, 1, 2, 9][1..<4]
    let fromSlice = try XCTUnwrap(slice.nextPermutations().first { _ in true })
    XCTAssertEqual(fromSlice.startIndex, 0)
    XCTAssertEqual(fromSlice.endIndex, 3)
    let fromString = try XCTUnwrap("bac".nextPermutations().first { _ in true })
    XCTAssertEqual(fromString.startIndex, 0)
    XCTAssertEqual(fromString.endIndex, 3)
  }

  func testEquatableComparesElementOrder() throws {
    let a = Array([1, 2, 3].nextPermutations())
    let b = Array([1, 2, 3].nextPermutations())
    XCTAssertEqual(a[1], b[1])
    XCTAssertNotEqual(a[0], a[1])
  }

  func testHashableFollowsElementOrder() throws {
    let a = Array([1, 2, 3].nextPermutations())
    let b = Array([1, 2, 3].nextPermutations())
    XCTAssertEqual(Set(a + b).count, 6)
  }

  func testDescriptionLooksLikeArray() throws {
    var iterator = [1, 2, 3].nextPermutations().makeIterator()
    _ = iterator.next()
    let p = try XCTUnwrap(iterator.next())
    XCTAssertEqual(p.description, "[1, 3, 2]")
    XCTAssertEqual("\(p)", "[1, 3, 2]")
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
#endif
