//
//  NextPermutationsSequence_0_PublicSurfaceTests.swift
//  swift-ac-collections
//

// 公開表面のTest as Specification。
// - 公開型の名前と入れ子の形
// - `Sendable`適合
// - 利用者が直接初期化できないこと
// - 2026-10-03に削除した公開API(`release/AtCoder/2025`にだけ存在する表面)が復活していないこと
//
// 「存在しないこと」は、同名の宣言をテスト側に置き、型注釈なしで呼び出して固定する。
// ライブラリ側に同名の宣言が公開されると`ambiguous use of ...`でコンパイルが失敗する。
// 型注釈を付けるとテスト側の宣言が黙って選ばれ、検出できない。
//
// 旧型名(`Permutations`名前空間と、その下の`All`・`IteratorA`・`SubSequenceA`・`Nexts`等)は
// この方法では守れない。トップレベルの名前はテスト側の宣言が優先され、黙って通るためである
// (2026-10-07確認)。互換版のソースが通常ビルドへ漏れた場合は、同じファイルにある
// `unsafePermutations()`・`unsafeNextPermutations()`も一緒に漏れるので、これを漏れの警報とする。

import PermutationModule
import XCTest

final class NextPermutationsSequence_0_PublicSurfaceTests: XCTestCase {

  private func requireSendable<T: Sendable>(_: T) {}
  private func requireSendableType<T: Sendable>(_: T.Type) {}

  func testPublicTypeNames() throws {
    let sequence: NextPermutationsSequence<[Int]> = [1, 2].nextPermutations()
    var iterator: NextPermutationsSequence<[Int]>.Iterator = sequence.makeIterator()
    let first: NextPermutationsSequence<[Int]>.Permutation? = iterator.next()
    XCTAssertEqual(first.map { Array($0) }, [1, 2])
  }

  func testSendableConformances() throws {
    requireSendableType(NextPermutationsSequence<[Int]>.self)
    requireSendableType(NextPermutationsSequence<[Int]>.Iterator.self)
    requireSendableType(NextPermutationsSequence<[Int]>.Permutation.self)
    requireSendable([1, 2, 3].nextPermutations())
  }
}

  // 互換mode(`COMPATIBLE_ATCODER_2025`)では基準版の表面が意図的に存在するため対象外とする。

  private struct AbsentAPIMarker {}

  extension Collection where Index == Int {
    fileprivate func unsafePermutations() -> AbsentAPIMarker { .init() }
    fileprivate func unsafeNextPermutations() -> AbsentAPIMarker { .init() }
  }

  extension NextPermutationsSequence {
    // 公開initが追加されると、`NextPermutationsSequence<[Int]>([1])`が曖昧になる。
    fileprivate init?(_ base: Base) { return nil }
  }

  final class NextPermutationsSequence_0_AbsentAPITests: XCTestCase {

    func testRemovedMethodsAreNotExposed() {
      let a = [1, 2, 3]
      // 1項目ずつ別の文にして、復活したAPIごとに個別のコンパイルエラーが出るようにする。
      let unsafePermutations = a.unsafePermutations()
      let unsafeNextPermutations = a.unsafeNextPermutations()
      XCTAssertTrue(type(of: unsafePermutations) == AbsentAPIMarker.self)
      XCTAssertTrue(type(of: unsafeNextPermutations) == AbsentAPIMarker.self)
    }

    func testSequenceIsNotPubliclyInitializable() {
      // 入口は`nextPermutations()`だけ。
      let sequence = NextPermutationsSequence<[Int]>([1])
      XCTAssertNil(sequence)
    }
  }
