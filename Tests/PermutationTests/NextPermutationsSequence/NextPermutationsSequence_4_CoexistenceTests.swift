//
//  NextPermutationsSequence_4_CoexistenceTests.swift
//  swift-ac-collections
//

// swift-algorithmsと同時にimportしても、公開名が衝突しないことのTest as Specification。
// 全順列が欲しい場合はswift-algorithmsの`permutations()`を使う、という使い分けの前提を固定する。
// 衝突すれば、このfileはcompileできない。

#if !COMPATIBLE_ATCODER_2025
import Algorithms
import PermutationModule
import XCTest

final class NextPermutationsSequence_4_CoexistenceTests: XCTestCase {

  func testBothPermutationAPIsResolveWithoutQualification() throws {
    let nexts: NextPermutationsSequence<[Int]> = [1, 2, 3].nextPermutations()
    let all: PermutationsSequence<[Int]> = [1, 2, 3].permutations()
    XCTAssertEqual(nexts.map { Array($0) }.count, 6)
    XCTAssertEqual(all.map { Array($0) }.count, 6)
  }

  func testNextPermutationsYieldsOnlySuccessorsWhileAlgorithmsYieldsEveryOrder() throws {
    // 開始の並びより前の並びは、nextPermutations()には含まれず、permutations()には含まれる
    let start = [2, 1, 3]
    let successors = start.nextPermutations().map { Array($0) }
    let every = start.permutations().map { Array($0) }
    XCTAssertEqual(successors, [[2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
    XCTAssertEqual(every.count, 6)
    XCTAssertFalse(successors.contains([1, 2, 3]))
    XCTAssertTrue(every.contains([1, 2, 3]))
  }
}
#endif
