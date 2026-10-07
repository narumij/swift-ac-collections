//
//  PermutationRemovedAPITests.swift
//  swift-ac-collections
//

// 2026-10-03に通常版から削除した公開API(`release/AtCoder/2025`にだけ存在する表面)が
// 復活していないことを、コンパイル時に固定する。
//
// このファイルは削除済みメソッドと同名の宣言をテスト側に置き、型注釈なしで呼び出す。
// ライブラリ側に同名のメソッドが復活すると`ambiguous use of ...`でコンパイルが失敗する。
// 型注釈を付けるとテスト側の宣言が黙って選ばれ、検出できない。
//
// 旧型名(`Permutations`名前空間と、その下の`All`・`IteratorA`・`SubSequenceA`・`Nexts`等)は
// この方法では守れない。トップレベルの名前はテスト側の宣言が優先され、黙って通るためである
// (2026-10-07確認)。互換版のソースが通常ビルドへ漏れた場合は、同じファイルにある
// 下の2メソッドも一緒に漏れるので、これを漏れの警報として扱う。
//
// 互換mode(`COMPATIBLE_ATCODER_2025`)では基準版の表面が意図的に存在するため対象外とする。
#if !COMPATIBLE_ATCODER_2025
  import PermutationModule
  import XCTest

  private struct RemovedAPIMarker {}

  extension Collection where Index == Int {
    fileprivate func unsafePermutations() -> RemovedAPIMarker { .init() }
    fileprivate func unsafeNextPermutations() -> RemovedAPIMarker { .init() }
  }

  final class PermutationRemovedAPITests: XCTestCase {

    func testRemovedPublicSurfaceIsNotExposed() {
      let a = [1, 2, 3]
      // 1項目ずつ別の文にして、復活したAPIごとに個別のコンパイルエラーが出るようにする。
      let unsafePermutations = a.unsafePermutations()
      let unsafeNextPermutations = a.unsafeNextPermutations()

      XCTAssertTrue(type(of: unsafePermutations) == RemovedAPIMarker.self)
      XCTAssertTrue(type(of: unsafeNextPermutations) == RemovedAPIMarker.self)
    }
  }
#endif
