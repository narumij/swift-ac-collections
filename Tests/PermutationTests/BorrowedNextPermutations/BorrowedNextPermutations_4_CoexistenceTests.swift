//
//  BorrowedNextPermutations_4_CoexistenceTests.swift
//  swift-ac-collections
//

// 共存のTest as Specification（Swift 6.4以降の借用版）。
// - 借用版`borrowedNextPermutations()`と、現行のruntime-check版`nextPermutations()`は
//   同じCollectionから修飾なしで呼べ、同じ並びを同じ順に返す
// - swift-algorithmsと同時にimportしても名前が衝突しない
// 衝突すれば、このfileはcompileできない。

#if compiler(>=6.4)
import Algorithms
import PermutationModule
import XCTest

final class BorrowedNextPermutations_4_CoexistenceTests: XCTestCase {

  // 互換modeでは`nextPermutations()`がAtCoder 2025版のAPIを指すため、現行版との比較は通常版だけで行う
  #if !COMPATIBLE_ATCODER_2025
  func testBorrowedAndRuntimeCheckedVersionsYieldTheSameOrders() throws {
    let source = [2, 1, 1, 3]

    var borrowed = source.borrowedNextPermutations()
    var borrowedOrders: [[Int]] = []
    while let span = borrowed.next() {
      // `Span`はclosureへcaptureできないので、`map`ではなくloopで写す
      var order: [Int] = []
      for i in span.indices {
        order.append(span[i])
      }
      borrowedOrders.append(order)
    }

    var checked = source.nextPermutations()
    var checkedOrders: [[Int]] = []
    while let permutation = checked.next() {
      var order: [Int] = []
      for element in permutation {
        order.append(element)
      }
      checkedOrders.append(order)
    }

    XCTAssertEqual(borrowedOrders, checkedOrders)
    // {1, 1, 2, 3}の並び12通りのうち、[2, 1, 1, 3]とその後続の6通り
    XCTAssertEqual(borrowedOrders.count, 6)
    XCTAssertEqual(borrowedOrders.first, [2, 1, 1, 3])
    XCTAssertEqual(borrowedOrders.last, [3, 2, 1, 1])
  }
  #endif

  func testResolvesAlongsideSwiftAlgorithms() throws {
    var borrowed = [1, 2, 3].borrowedNextPermutations()
    var count = 0
    while borrowed.next() != nil {
      count += 1
    }
    XCTAssertEqual(count, 6)
    XCTAssertEqual([1, 2, 3].permutations().count, 6)
  }
}

#endif
