import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

/// `Implements/__tree/unsafe_node/unsafe_node+pointer+safe.swift`のテスト。
/// `_SafePtr`/`_SealedPtr`(`Result<..., SealError>`)のヘルパーと、`errorMessage`を検証する。
@available(anyAppleOS 26.0, *)
final class TreeFoundamentalSafePtrTests: TreeTestCase, _UnsafeNodePtrType {

  func makeFixture() -> TreeNodeOnlyFixture {
    .makeEmpty()
  }

  // MARK: - _SafePtr(Result<_NodePtr, SealError>)

  /// `_SafePtr`が`.failure`の場合、`___is_end`は常にfalseになること。
  func testSafePtr_isEnd_isFalseForAnyFailure() {
    let failure: _SafePtr = .failure(.null)
    XCTAssertFalse(failure.___is_end)

    let failure2: _SafePtr = .failure(.limit)
    XCTAssertFalse(failure2.___is_end)
  }

  /// `_SafePtr`が`.success`の場合、`___is_end`は実際のポインタがendかどうかと一致すること。
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

  /// `_SafePtr`の`==`/`!=`が、`.success`同士は実ポインタの一致、`.failure`同士は
  /// エラーの一致で判定し、`.success`と`.failure`は常に不一致と判定すること。
  func testSafePtr_equatable_successFailureAndMixedCases() {
    var fixture = makeFixture()
    let a = fixture.node(0)
    let b = fixture.node(1)

    let successA: _SafePtr = .success(a)
    let successA2: _SafePtr = .success(a)
    let successB: _SafePtr = .success(b)
    let failureNull: _SafePtr = .failure(.null)
    let failureNull2: _SafePtr = .failure(.null)
    let failureLimit: _SafePtr = .failure(.limit)

    XCTAssertTrue(successA == successA2)
    XCTAssertFalse(successA == successB)
    XCTAssertTrue(failureNull == failureNull2)
    XCTAssertFalse(failureNull == failureLimit)
    XCTAssertFalse(successA == failureNull)
    XCTAssertTrue(successA != failureNull)
  }

  /// `UnsafeMutablePointer<UnsafeNode>.unchecked`が常に`.success(self)`を返すこと。
  func testPointer_unchecked_alwaysSucceeds() {
    var fixture = makeFixture()
    let node = fixture.node(0)
    node.pointee.___tracking_tag = 0
    let safe: _SafePtr = node.unchecked
    XCTAssertTrue(safe == .success(node))
  }

  /// `_SafePtr.pointer`が、`.success`ならそのポインタを、`.failure`なら`nil`を返すこと。
  func testSafePtr_pointer_unwrapsSuccessOrNilOnFailure() {
    var fixture = makeFixture()
    let node = fixture.node(0)
    let success: _SafePtr = .success(node)
    let failure: _SafePtr = .failure(.garbaged)

    XCTAssertEqual(success.pointer, node)
    XCTAssertNil(failure.pointer)
  }

  /// `_SafePtr.___has_payload_content`が、`.success`なら実ポインタのpayload有無を
  /// 反映し、`.failure`なら常に`false`になること。
  func testSafePtr_hasPayloadContent_reflectsUnderlyingNodeOrFalseOnFailure() {
    var fixture = makeFixture()
    let withPayload = fixture.node(0)
    withPayload.pointee.___has_payload_content = true
    let withoutPayload = fixture.node(1)
    withoutPayload.pointee.___has_payload_content = false

    XCTAssertTrue((_SafePtr.success(withPayload)).___has_payload_content)
    XCTAssertFalse((_SafePtr.success(withoutPayload)).___has_payload_content)
    XCTAssertFalse((_SafePtr.failure(.garbaged)).___has_payload_content)
  }

  /// `_SafePtr.accessible`が、payloadを持つ`.success`はそのまま通し、payloadを
  /// 持たない`.success`は`.failure(.garbaged)`に変換すること。`___has_payload_content`は
  /// `.failure`では常に`false`になるため、`.failure`も(元のエラー種別に関わらず)
  /// `.failure(.garbaged)`へ正規化される。
  func testSafePtr_accessible_convertsMissingPayloadOrAnyFailureToGarbaged() {
    var fixture = makeFixture()
    let withPayload = fixture.node(0)
    withPayload.pointee.___has_payload_content = true
    let withoutPayload = fixture.node(1)
    withoutPayload.pointee.___has_payload_content = false

    let a: _SafePtr = .success(withPayload)
    let b: _SafePtr = .success(withoutPayload)
    let c: _SafePtr = .failure(.null)

    XCTAssertTrue(a.accessible == a)
    XCTAssertTrue(b.accessible == .failure(.garbaged))
    XCTAssertTrue(c.accessible == .failure(.garbaged))
  }

  /// `_SafePtr.uncheckedSeal`が、`.success`は`_SealedPtr.success`へ変換し、
  /// `.failure`はエラーをそのまま伝播すること。
  func testSafePtr_uncheckedSeal_wrapsSuccessOrPropagatesFailure() {
    var fixture = makeFixture()
    let node = fixture.node(0)
    node.pointee.___tracking_tag = 0

    let success: _SafePtr = .success(node)
    let failure: _SafePtr = .failure(.null)

    guard case .success(let sealing) = success.uncheckedSeal else {
      XCTFail("successはuncheckedSealで.successになるはず")
      return
    }
    XCTAssertEqual(sealing.pointer, node)

    guard case .failure(let error) = failure.uncheckedSeal else {
      XCTFail("failureはuncheckedSealでもfailureのまま")
      return
    }
    XCTAssertEqual(error, .null)
  }

  // MARK: - _SealedPtr(Result<_NodePtrSealing, SealError>)

  /// `_SealedPtr`の`==`/`!=`が、同一ポインタのシールなら等しく、
  /// 異なるポインタのシールなら等しくないと判定すること。
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

  /// `_SealedPtr`の`==`/`!=`が、`.success`と`.failure`を常に等しくないと判定すること。
  func testSealedPtr_equatable_successNeverEqualsFailure() {
    var fixture = makeFixture()
    let a = fixture.node(0)
    a.pointee.___tracking_tag = 0
    let success = a.uncheckedSeal
    let failure: _SealedPtr = .failure(.null)

    XCTAssertFalse(success == failure)
    XCTAssertTrue(success != failure)
  }

  /// `_SealedPtr.purified`/`.tag`/`.pointer`/`.accessible`/`.error`が、`.failure`の
  /// 場合はクロージャを呼ばずエラーをそのまま伝播すること。
  func testSealedPtr_derivedProperties_propagateFailureWithoutInvokingClosure() {
    let failure: _SealedPtr = .failure(.notAllowed)

    guard case .failure(let purifiedError) = failure.purified else {
      XCTFail()
      return
    }
    XCTAssertEqual(purifiedError, .notAllowed)

    guard case .failure(let tagError) = failure.tag else {
      XCTFail()
      return
    }
    XCTAssertEqual(tagError, .notAllowed)

    XCTAssertNil(failure.pointer)

    guard case .failure(let accessibleError) = failure.accessible else {
      XCTFail()
      return
    }
    XCTAssertEqual(accessibleError, .notAllowed)

    XCTAssertEqual(failure.error, .notAllowed)
  }

  /// `_SealedPtr.purified`/`.tag`/`.pointer`/`.accessible`/`.error`が、`.success`の
  /// 場合は内部の`_NodePtrSealing`へ処理を委譲すること。
  func testSealedPtr_derivedProperties_delegateToNodePtrSealingOnSuccess() {
    var fixture = makeFixture()
    let node = fixture.node(0)
    node.pointee.___tracking_tag = 0
    node.pointee.___has_payload_content = true

    let sealed: _SealedPtr = node.uncheckedSeal

    XCTAssertTrue(sealed.purified == sealed)
    XCTAssertNil(sealed.tag.error)
    XCTAssertEqual(sealed.pointer, node)
    XCTAssertTrue(sealed.accessible == sealed)
    XCTAssertNil(sealed.error)
  }

  /// `_SealedPtr.accessible`が、seal自体は有効でもpayloadを持たないノードを
  /// `.failure(.garbaged)`へ変換すること。
  func testSealedPtr_accessible_rejectsNodeWithoutPayload() {
    var fixture = makeFixture()
    let node = fixture.node(0)
    node.pointee.___tracking_tag = 0
    node.pointee.___has_payload_content = false

    XCTAssertTrue(node.uncheckedSeal.accessible == .failure(.garbaged))
  }

  /// `_SealedPtr.deepPurified`(`ALLOW_CROSS_TREE_INDEX`)が、`.success`の場合は
  /// 内部の`_NodePtrSealing.deepPurified`へ処理を委譲すること。
  #if ALLOW_CROSS_TREE_INDEX
    func testSealedPtr_deepPurified_delegatesToNodePtrSealingOnSuccess() {
      var fixture = makeFixture()
      let node = fixture.node(0)
      node.pointee.___tracking_tag = 0
      node.pointee.___has_payload_content = true
      let sealed: _SealedPtr = node.uncheckedSeal
      XCTAssertTrue(sealed.deepPurified == sealed)
    }
  #endif

  // MARK: - errorMessage

  private enum _OtherError: Error {
    case oops
  }

  /// `errorMessage`が、ドキュメント化された8種類の`SealError`それぞれに対して
  /// 期待される人間向けメッセージを返すこと。
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
    #if !ALLOW_CROSS_TREE_INDEX
      XCTAssertEqual(errorMessage(SealError.crossTree), "\(SealError.crossTree)")
    #endif
    XCTAssertEqual(errorMessage(SealError.detached), "\(SealError.detached)")
    XCTAssertEqual(errorMessage(SealError.other), "\(SealError.other)")
  }

  /// `SealError`以外の`Error`が渡された場合も、キャストに失敗して`default`にフォールバックする。
  func testErrorMessage_nonSealErrorFallsBackToDescription() {
    let other = _OtherError.oops
    XCTAssertEqual(errorMessage(other), "\(other)")
  }
}
