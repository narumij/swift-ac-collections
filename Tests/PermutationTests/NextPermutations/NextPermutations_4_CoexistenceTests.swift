//
//  NextPermutations_4_CoexistenceTests.swift
//  swift-ac-collections
//

// 共存のTest as Specification（runtime-check版`NextPermutations`、PERM-056 G5）。
// - `NextPermutationModule`とswift-algorithmsを同時にimportしても、修飾なしの呼び出しが曖昧にならない
// - `nextPermutations()`は現在の並びと辞書順の後続だけを返し、`permutations()`は位置の並びを全て返す
// 衝突すれば、このfileはcompileできない。
// `AcCollections`からの再公開は`Tests/AcCollectionsTests/AcCollections_NextPermutationsReexportTests.swift`で扱う。

#if !COMPATIBLE_ATCODER_2025
import Algorithms
import NextPermutationModule
import XCTest

final class NextPermutations_4_CoexistenceTests: XCTestCase {

  func testBothPermutationAPIsResolveWithoutQualification() throws {
    var nexts: NextPermutations<Int> = [1, 2, 3].nextPermutations()
    var count = 0
    while nexts.next() != nil {
      count += 1
    }
    let all: PermutationsSequence<[Int]> = [1, 2, 3].permutations()
    XCTAssertEqual(count, 6)
    XCTAssertEqual(all.count, 6)
  }

  func testNextPermutationsYieldsOnlySuccessorsWhileAlgorithmsYieldsEveryOrder() throws {
    let start = [2, 1, 3]
    var nexts = start.nextPermutations()
    var successors: [[Int]] = []
    while let permutation = nexts.next() {
      successors.append(Array(permutation))
    }
    let every = start.permutations().map { Array($0) }
    XCTAssertEqual(successors, [[2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
    XCTAssertEqual(every.count, 6)
    XCTAssertFalse(successors.contains([1, 2, 3]))
    XCTAssertTrue(every.contains([1, 2, 3]))
  }
}

#endif
