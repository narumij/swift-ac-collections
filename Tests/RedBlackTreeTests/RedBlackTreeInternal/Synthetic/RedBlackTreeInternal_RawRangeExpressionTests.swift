//
//  RedBlackTreeInternal_RawRangeExpressionTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/09/30.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

/// `Implements/RawRange/_RawRangeExpression.swift`のテスト。
/// `Bound`に単純な`Int`を使い、実木(`UnsafeTreeV2`)なしで純粋な変換ロジック
/// (`==`/`!=`/`map`/`relative`/`sequence`/`traverse`)を検証する。
/// `_start`/`_end<Base>(_:)`は実木の`__begin_node_`/`__end_node`をそのまま返すだけの
/// 一行実装で、既存の各4型のrange系APIから常時経由しているため対象外とする。
final class RedBlackTreeInternal_RawRangeExpressionTests: RedBlackTreeTestCase {

  typealias Expr = _RawRangeExpression<Int>

  private enum TestError: Error, Equatable {
    case a
    case b
  }

  /// `Result`は標準で`Equatable`に適合しないため、失敗ケースの比較用ヘルパーを用意する。
  private func assertFailure<T>(
    _ result: Result<T, TestError>, _ expected: TestError, file: StaticString = #filePath,
    line: UInt = #line
  ) {
    switch result {
    case .failure(let e): XCTAssertEqual(e, expected, file: file, line: line)
    case .success: XCTFail("failureを期待したがsuccessだった", file: file, line: line)
    }
  }

  // MARK: - Equatable

  func testEquatable_sameCaseSameValues_isEqual() {
    XCTAssertEqual(Expr.range(from: 1, to: 2), .range(from: 1, to: 2))
    XCTAssertEqual(Expr.closedRange(from: 1, through: 2), .closedRange(from: 1, through: 2))
    XCTAssertEqual(Expr.partialRangeTo(2), .partialRangeTo(2))
    XCTAssertEqual(Expr.partialRangeThrough(2), .partialRangeThrough(2))
    XCTAssertEqual(Expr.partialRangeFrom(1), .partialRangeFrom(1))
    XCTAssertEqual(Expr.unboundedRange, .unboundedRange)
  }

  func testEquatable_sameCaseDifferentValues_isNotEqual() {
    XCTAssertNotEqual(Expr.range(from: 1, to: 2), .range(from: 1, to: 3))
    XCTAssertNotEqual(Expr.closedRange(from: 1, through: 2), .closedRange(from: 0, through: 2))
    XCTAssertNotEqual(Expr.partialRangeTo(2), .partialRangeTo(3))
    XCTAssertNotEqual(Expr.partialRangeThrough(2), .partialRangeThrough(3))
    XCTAssertNotEqual(Expr.partialRangeFrom(1), .partialRangeFrom(2))
  }

  func testEquatable_differentCase_isNotEqual() {
    let all: [Expr] = [
      .range(from: 1, to: 2),
      .closedRange(from: 1, through: 2),
      .partialRangeTo(2),
      .partialRangeThrough(2),
      .partialRangeFrom(1),
      .unboundedRange,
    ]
    for i in all.indices {
      for j in all.indices where i != j {
        XCTAssertNotEqual(all[i], all[j], "\(all[i]) と \(all[j]) は別ケースなので不一致のはず")
      }
    }
  }

  // MARK: - map

  func testMap_transformsBoundOnEachCase() {
    XCTAssertEqual(Expr.range(from: 1, to: 2).map { $0 * 10 }, .range(from: 10, to: 20))
    XCTAssertEqual(
      Expr.closedRange(from: 1, through: 2).map { $0 * 10 }, .closedRange(from: 10, through: 20))
    XCTAssertEqual(Expr.partialRangeTo(2).map { $0 * 10 }, .partialRangeTo(20))
    XCTAssertEqual(Expr.partialRangeThrough(2).map { $0 * 10 }, .partialRangeThrough(20))
    XCTAssertEqual(Expr.partialRangeFrom(1).map { $0 * 10 }, .partialRangeFrom(10))
    XCTAssertEqual(Expr.unboundedRange.map { $0 * 10 }, .unboundedRange)
  }

  // MARK: - relative(start:end:bound:through:)

  func testRelative_range_usesBoundForBothEnds() {
    let r = Expr.range(from: 3, to: 7).relative(
      start: -1, end: 100, bound: { $0 }, through: { $0 + 1 })
    XCTAssertEqual(r.lowerBound, 3)
    XCTAssertEqual(r.upperBound, 7)
  }

  func testRelative_closedRange_advancesUpperBoundViaThrough() {
    let r = Expr.closedRange(from: 3, through: 7).relative(
      start: -1, end: 100, bound: { $0 }, through: { $0 + 1 })
    XCTAssertEqual(r.lowerBound, 3)
    XCTAssertEqual(r.upperBound, 8, "closedRangeの上端はthroughで1つ先に進むはず")
  }

  func testRelative_partialRangeTo_lowerBoundIsStart() {
    let r = Expr.partialRangeTo(7).relative(
      start: -1, end: 100, bound: { $0 }, through: { $0 + 1 })
    XCTAssertEqual(r.lowerBound, -1)
    XCTAssertEqual(r.upperBound, 7)
  }

  func testRelative_partialRangeThrough_lowerBoundIsStartUpperIsThrough() {
    let r = Expr.partialRangeThrough(7).relative(
      start: -1, end: 100, bound: { $0 }, through: { $0 + 1 })
    XCTAssertEqual(r.lowerBound, -1)
    XCTAssertEqual(r.upperBound, 8)
  }

  func testRelative_partialRangeFrom_upperBoundIsEnd() {
    let r = Expr.partialRangeFrom(3).relative(
      start: -1, end: 100, bound: { $0 }, through: { $0 + 1 })
    XCTAssertEqual(r.lowerBound, 3)
    XCTAssertEqual(r.upperBound, 100)
  }

  func testRelative_unboundedRange_usesStartAndEnd() {
    let r = Expr.unboundedRange.relative(
      start: -1, end: 100, bound: { $0 }, through: { $0 + 1 })
    XCTAssertEqual(r.lowerBound, -1)
    XCTAssertEqual(r.upperBound, 100)
  }

  // MARK: - sequence (Result-lifting)

  private typealias ResultExpr = _RawRangeExpression<Result<Int, TestError>>

  func testSequence_range_bothSuccess_isSuccess() {
    let result = sequence(ResultExpr.range(from: .success(1), to: .success(2)))
    XCTAssertEqual(try? result.get(), .range(from: 1, to: 2))
  }

  func testSequence_range_eitherFailure_isFailure() {
    assertFailure(sequence(ResultExpr.range(from: .failure(.a), to: .success(2))), .a)
    assertFailure(sequence(ResultExpr.range(from: .success(1), to: .failure(.b))), .b)
  }

  func testSequence_closedRange_bothSuccess_isSuccess() {
    let result = sequence(ResultExpr.closedRange(from: .success(1), through: .success(2)))
    XCTAssertEqual(try? result.get(), .closedRange(from: 1, through: 2))
  }

  func testSequence_closedRange_eitherFailure_isFailure() {
    assertFailure(sequence(ResultExpr.closedRange(from: .failure(.a), through: .success(2))), .a)
  }

  func testSequence_partialRangeTo_propagatesSuccessAndFailure() {
    XCTAssertEqual(
      try? sequence(ResultExpr.partialRangeTo(.success(2))).get(), .partialRangeTo(2))
    assertFailure(sequence(ResultExpr.partialRangeTo(.failure(.a))), .a)
  }

  func testSequence_partialRangeThrough_propagatesSuccessAndFailure() {
    XCTAssertEqual(
      try? sequence(ResultExpr.partialRangeThrough(.success(2))).get(), .partialRangeThrough(2))
    assertFailure(sequence(ResultExpr.partialRangeThrough(.failure(.a))), .a)
  }

  func testSequence_partialRangeFrom_propagatesSuccessAndFailure() {
    XCTAssertEqual(
      try? sequence(ResultExpr.partialRangeFrom(.success(1))).get(), .partialRangeFrom(1))
    assertFailure(sequence(ResultExpr.partialRangeFrom(.failure(.a))), .a)
  }

  func testSequence_unboundedRange_isAlwaysSuccess() {
    let result: Result<Expr, TestError> = sequence(ResultExpr.unboundedRange)
    XCTAssertEqual(try? result.get(), .unboundedRange)
  }

  // MARK: - traverse (map + sequence composition)

  func testTraverse_range_appliesFunctionThenLifts() {
    let result = traverse(Expr.range(from: 3, to: 7)) { (v: Int) -> Result<Int, TestError> in
      .success(v * 2)
    }
    XCTAssertEqual(try? result.get(), .range(from: 6, to: 14))
  }

  func testTraverse_propagatesFailureFromTransform() {
    let result = traverse(Expr.range(from: 3, to: 7)) { (v: Int) -> Result<Int, TestError> in
      v == 7 ? .failure(.b) : .success(v)
    }
    assertFailure(result, .b)
  }

  func testTraverse_unboundedRange_isAlwaysSuccess() {
    let result = traverse(Expr.unboundedRange) { (v: Int) -> Result<Int, TestError> in
      .success(v)
    }
    XCTAssertEqual(try? result.get(), .unboundedRange)
  }
}
