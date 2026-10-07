//
//  PermutationRemovedAPITests.swift
//  swift-ac-collections
//

// 2026-10-03に通常版から削除した公開API(`release/AtCoder/2025`にだけ存在する表面)が
// 復活していないことを、コンパイル時に固定する。
//
// このファイルは削除済みAPIと同名の宣言をテスト側に置き、それを参照する。
// - メソッドとイニシャライザは、ライブラリ側に同名のものが復活すると
//   `ambiguous use of ...`でコンパイルが失敗する。
// - ネスト型(`All`等)は同名のstatic varで代用する。ライブラリ側に同名の型が復活すると、
//   型の方が優先されて`Marker`への代入が型不一致となり、コンパイルが失敗する。
//
// 互換mode(`COMPATIBLE_ATCODER_2025`)では基準版の表面が意図的に存在するため対象外とする。
#if !COMPATIBLE_ATCODER_2025
  import PermutationModule
  import XCTest

  private enum RemovedAPIMarker {}

  extension Collection where Index == Int {
    fileprivate func unsafePermutations() -> RemovedAPIMarker? { nil }
    fileprivate func unsafeNextPermutations() -> RemovedAPIMarker? { nil }
  }

  extension Permutations {
    fileprivate static var All: RemovedAPIMarker? { nil }
    fileprivate static var IteratorA: RemovedAPIMarker? { nil }
    fileprivate static var SubSequenceA: RemovedAPIMarker? { nil }
  }

  extension Permutations.Nexts {
    fileprivate init?(safe source: C) { return nil }
    fileprivate init?(unsafe source: C) { return nil }
  }

  final class PermutationRemovedAPITests: XCTestCase {

    func testRemovedPublicSurfaceIsNotExposed() {
      let a = [1, 2, 3]
      // 1項目ずつ別の文にして、復活したAPIごとに個別のコンパイルエラーが出るようにする。
      // メソッドとinitには型注釈を付けない。付けるとテスト側の宣言が黙って選ばれ、検出できない。
      let unsafePermutations = a.unsafePermutations()
      let unsafeNextPermutations = a.unsafeNextPermutations()
      let all: RemovedAPIMarker? = Permutations<[Int]>.All
      let iteratorA: RemovedAPIMarker? = Permutations<[Int]>.IteratorA
      let subSequenceA: RemovedAPIMarker? = Permutations<[Int]>.SubSequenceA
      let nextsSafe = Permutations<[Int]>.Nexts(safe: a)
      let nextsUnsafe = Permutations<[Int]>.Nexts(unsafe: a)

      XCTAssertNil(unsafePermutations)
      XCTAssertNil(unsafeNextPermutations)
      XCTAssertNil(all)
      XCTAssertNil(iteratorA)
      XCTAssertNil(subSequenceA)
      XCTAssertNil(nextsSafe)
      XCTAssertNil(nextsUnsafe)
    }
  }
#endif
