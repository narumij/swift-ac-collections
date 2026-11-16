#if COMPATIBLE_ATCODER_2025
import NextPermutationModule
import XCTest

// `release/AtCoder/2025`で公開していたPermutation APIのTest as Specification。
// 通常版の`NextPermutationsSequence`契約とは混ぜず、互換defineでだけ実行する。
final class AtCoder2025Compatibility_0_SpecificationTests: XCTestCase {

  // 異なる要素の順列は、各結果の要素一致・重複なし・n!件で全件の網羅を確認できる。
  func testEnumeratesEveryPermutationExactlyOnce() {
    let factorials = [1, 1, 2, 6, 24, 120, 720, 5040]
    for n in 0..<factorials.count {
      let source = Array(0..<n)
      let elements = Set(source)
      var seen: Set<[Int]> = []
      var count = 0
      var permutations = source.nextPermutations().makeIterator()
      while let permutation = permutations.next() {
        let order = Array(permutation)
        XCTAssertEqual(order.count, source.count, "n=\(n)")
        XCTAssertEqual(Set(order), elements, "n=\(n), order=\(order)")
        XCTAssertTrue(seen.insert(order).inserted, "重複: n=\(n), order=\(order)")
        count += 1
      }
      XCTAssertEqual(count, factorials[n], "n=\(n)")
      XCTAssertEqual(seen.count, factorials[n], "n=\(n)")
    }
  }

  func testUnsafePermutationsEnumeratesEveryPositionOrder() {
    XCTAssertEqual(
      [1, 2, 3].unsafePermutations().map { Array($0) },
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])

    // 同値要素も位置が異なる順列として列挙する。
    XCTAssertEqual(
      [0, 0, 1].unsafePermutations().map { Array($0) },
      [[0, 0, 1], [0, 1, 0], [0, 0, 1], [0, 1, 0], [1, 0, 0], [1, 0, 0]])
  }

  func testNextPermutationsEnumeratesLexicographicSuccessors() {
    XCTAssertEqual(
      [1, 2, 3].nextPermutations().map { Array($0) },
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
    XCTAssertEqual(
      [2, 1, 3].nextPermutations().map { Array($0) },
      [[2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])

    // 辞書順のnext-permutationなので、同値要素の位置だけによる重複は返さない。
    XCTAssertEqual(
      [0, 0, 1].nextPermutations().map { Array($0) },
      [[0, 0, 1], [0, 1, 0], [1, 0, 0]])
  }

  func testSafeResultsRemainStableAfterAdvancing() throws {
    var iterator = [1, 2, 3].nextPermutations().makeIterator()
    let first = try XCTUnwrap(iterator.next())
    let second = try XCTUnwrap(iterator.next())
    let third = try XCTUnwrap(iterator.next())

    XCTAssertEqual(Array(first), [1, 2, 3])
    XCTAssertEqual(Array(second), [1, 3, 2])
    XCTAssertEqual(Array(third), [2, 1, 3])
  }

  func testUnsafeResultsAliasIteratorStorage() {
    let retained = [1, 2].unsafeNextPermutations().map { $0 }

    // 各結果は同じbufferを共有し、列挙終了時の内容を後から観測する。
    XCTAssertEqual(retained.map { Array($0) }, [[1, 2], [1, 2]])
    XCTAssertNotEqual(retained.map { Array($0) }, [[1, 2], [2, 1]])

    // 列挙中に値へコピーすれば、その時点の順序を保持できる。
    XCTAssertEqual(
      [1, 2].unsafeNextPermutations().map { Array($0) },
      [[1, 2], [2, 1]])
  }

  func testBoundaryInputsYieldTheInitialOrderOnce() {
    XCTAssertEqual([Int]().nextPermutations().map { Array($0) }, [[]])
    XCTAssertEqual([5].nextPermutations().map { Array($0) }, [[5]])
    XCTAssertEqual([0, 0].nextPermutations().map { Array($0) }, [[0, 0]])
    XCTAssertEqual(
      [4, 3, 2, 1].nextPermutations().map { Array($0) },
      [[4, 3, 2, 1]])

    XCTAssertEqual([Int]().unsafeNextPermutations().map { Array($0) }, [[]])
    XCTAssertEqual([5].unsafeNextPermutations().map { Array($0) }, [[5]])
    XCTAssertEqual([0, 0].unsafeNextPermutations().map { Array($0) }, [[0, 0]])
    XCTAssertEqual(
      [4, 3, 2, 1].unsafeNextPermutations().map { Array($0) },
      [[4, 3, 2, 1]])
  }
}
#endif
