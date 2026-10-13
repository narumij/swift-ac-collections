//
//  NextPermutations_3_PermutationCollectionTests.swift
//  swift-ac-collections
//

// `NextPermutations.Permutation`のCollectionとしての振る舞いのTest as Specification（PERM-053 G3）。
// - 添字は0始まりの`Int`で、元のCollectionの添字型や開始位置に依存しない
// - `startIndex == 0`、`endIndex == count`で、通常の反復で現在の並びを読める
// - 先頭と末尾の有効な位置を読める
// - 空のViewでも`RandomAccessCollection`として矛盾しない
// 範囲外の添字の拒否は`NextPermutations_99_DeathTests`で扱う。
// Viewは次の`next()`まで有効なので、各testは`next()`の後にViewを使わない。

#if !COMPATIBLE_ATCODER_2025
import PermutationModule
import XCTest

final class NextPermutations_3_PermutationCollectionTests: XCTestCase {

  func testIndicesStartAtZeroForArraySource() throws {
    var permutations = [3, 1, 2].nextPermutations()
    let p = try XCTUnwrap(permutations.next())
    XCTAssertEqual(p.startIndex, 0)
    XCTAssertEqual(p.endIndex, 3)
    XCTAssertEqual(p.count, 3)
    XCTAssertEqual(Array(p.indices), [0, 1, 2])
  }

  func testIndicesStartAtZeroForSliceSource() throws {
    let slice = [9, 3, 1, 2, 9][1..<4]
    XCTAssertEqual(slice.startIndex, 1)
    var permutations = slice.nextPermutations()
    let p = try XCTUnwrap(permutations.next())
    XCTAssertEqual(p.startIndex, 0)
    XCTAssertEqual(p.endIndex, 3)
    XCTAssertEqual(p[0], 3)
    XCTAssertEqual(p[2], 2)
  }

  func testIndicesStartAtZeroForNonIntIndexedSource() throws {
    var permutations = "ba".nextPermutations()
    let p = try XCTUnwrap(permutations.next())
    XCTAssertEqual(p.startIndex, 0)
    XCTAssertEqual(p.endIndex, 2)
    XCTAssertEqual(p[0], "b")
    XCTAssertEqual(p[1], "a")
  }

  func testIterationExposesTheCurrentOrder() throws {
    var permutations = [1, 2, 3].nextPermutations()
    let first = try XCTUnwrap(permutations.next())
    var iterated: [Int] = []
    for element in first {
      iterated.append(element)
    }
    XCTAssertEqual(iterated, [1, 2, 3])
    let second = try XCTUnwrap(permutations.next())
    XCTAssertEqual(Array(second), [1, 3, 2])
  }

  func testSubscriptAtValidBoundaries() throws {
    var permutations = [4, 5, 6].nextPermutations()
    let p = try XCTUnwrap(permutations.next())
    XCTAssertEqual(p[p.startIndex], 4)
    XCTAssertEqual(p[p.endIndex - 1], 6)
    XCTAssertEqual(p.first, 4)
    XCTAssertEqual(p.last, 6)
  }

  func testEmptyViewIsConsistent() throws {
    var permutations = [Int]().nextPermutations()
    let p = try XCTUnwrap(permutations.next())
    XCTAssertEqual(p.startIndex, 0)
    XCTAssertEqual(p.endIndex, 0)
    XCTAssertEqual(p.count, 0)
    XCTAssertTrue(p.isEmpty)
    XCTAssertTrue(p.indices.isEmpty)
    XCTAssertNil(p.first)
    var iterationCount = 0
    for _ in p { iterationCount += 1 }
    XCTAssertEqual(iterationCount, 0)
  }
}

#endif
