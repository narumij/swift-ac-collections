import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

/// `Implements/__tree/unsafe_node/unsafe_node+pointer+safe.swift`のテスト。
/// `_SafePtr`/`_SealedPtr`(`Result<..., SealError>`)のヘルパーと、`errorMessage`を検証する。
@available(anyAppleOS 26.0, *)
final class TreeFoundamentalSafePtrTests: RedBlackTreeTestCase, _UnsafeNodePtrType {

  func makeFixture() -> TreeNodeOnlyFixture {
    .makeEmpty()
  }

  // MARK: - _SafePtr(Result<_NodePtr, SealError>)

  func testSafePtr_isEnd_isFalseForAnyFailure() {
    let failure: _SafePtr = .failure(.null)
    XCTAssertFalse(failure.___is_end)

    let failure2: _SafePtr = .failure(.limit)
    XCTAssertFalse(failure2.___is_end)
  }

  func testSafePtr_isEnd_matchesTheUnderlyingPointerWhenSuccess() {
    var fixture = makeFixture()
    let end = fixture.endPtr()
    let real = fixture.node(0)
    real.pointee.___tracking_tag = 0

    let successEnd: _SafePtr = .success(end)
    let successReal: _SafePtr = .success(real)
    XCTAssertTrue(successEnd.___is_end)
    XCTAssertFalse(successReal.___is_end)
  }

  // MARK: - _SealedPtr(Result<_NodePtrSealing, SealError>)

  func testSealedPtr_equatable_sameAndDifferentPointers() {
    var fixture = makeFixture()
    let a = fixture.node(0)
    let b = fixture.node(1)
    a.pointee.___tracking_tag = 0
    b.pointee.___tracking_tag = 1

    let sealedA1 = a.uncheckedSeal
    let sealedA2 = a.uncheckedSeal
    let sealedB = b.uncheckedSeal

    XCTAssertTrue(sealedA1 == sealedA2)
    XCTAssertFalse(sealedA1 != sealedA2)

    XCTAssertTrue(sealedA1 != sealedB)
    XCTAssertFalse(sealedA1 == sealedB)
  }

  func testSealedPtr_equatable_successNeverEqualsFailure() {
    var fixture = makeFixture()
    let a = fixture.node(0)
    a.pointee.___tracking_tag = 0
    let success = a.uncheckedSeal
    let failure: _SealedPtr = .failure(.null)

    XCTAssertFalse(success == failure)
    XCTAssertTrue(success != failure)
  }

  // MARK: - errorMessage

  private enum _OtherError: Error {
    case oops
  }

  func testErrorMessage_coversEachDocumentedSealErrorCase() {
    let cases: [(SealError, String)] = [
      (.null, "Unexpected null pointer"),
      (.garbaged, "Unexpected pointer to deallocated memory"),
      (.unknown, "Unknown error"),
      (.limit, "Reached the specified limit"),
      (.notAllowed, "The pointer is no longer valid"),
      (.unsealed, "The pointer is being used as a different node"),
      (.lowerOutOfBounds, "Operation exceeded the lower bound of the balanced tree"),
      (.upperOutOfBounds, "Operation exceeded the upper bound of the balanced tree"),
    ]
    for (error, expected) in cases {
      XCTAssertEqual(errorMessage(error), expected, "\(error)")
    }
  }

  /// ドキュメント化されていないケース(`outOfBounds`/`crossTree`/`detached`/`other`)は
  /// `default: "\(e)"`にフォールバックする。
  func testErrorMessage_undocumentedCasesFallBackToDescription() {
    XCTAssertEqual(errorMessage(SealError.outOfBounds), "\(SealError.outOfBounds)")
    XCTAssertEqual(errorMessage(SealError.crossTree), "\(SealError.crossTree)")
    XCTAssertEqual(errorMessage(SealError.detached), "\(SealError.detached)")
    XCTAssertEqual(errorMessage(SealError.other), "\(SealError.other)")
  }

  /// `SealError`以外の`Error`が渡された場合も、キャストに失敗して`default`にフォールバックする。
  func testErrorMessage_nonSealErrorFallsBackToDescription() {
    let other = _OtherError.oops
    XCTAssertEqual(errorMessage(other), "\(other)")
  }
}
