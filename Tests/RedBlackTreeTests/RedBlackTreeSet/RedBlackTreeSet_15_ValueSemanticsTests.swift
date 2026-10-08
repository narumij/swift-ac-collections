import RedBlackTreeCollections
import XCTest

final class RedBlackTreeSetValueSemanticsTests: RedBlackTreeTestCase {

  /// コピーを変更しても元の集合は変更されないこと
  func test_copyOnWrite_mutatingCopyPreservesOriginal() {
    let original: RedBlackTreeSet = [1, 2, 3]
    var copy = original

    XCTAssertTrue(copy.insert(99).inserted)
    XCTAssertEqual(copy.remove(2), 2)

    XCTAssertEqual(Array(original), [1, 2, 3])
    XCTAssertEqual(Array(copy), [1, 3, 99])
  }

  /// コピー後の片方を変異させてCoWが発生しても、共有されていた参照型要素が
  /// 両バッファから参照され続ける間は解放されず、両方が破棄された後にちょうど
  /// 1回ずつ解放されること(二重解放・リークいずれも無いこと)
  func test_copyOnWrite_sharedReferenceElementsReleaseExactlyOnceAfterBothCopiesDeinit() {
    final class DeinitializeCounter: Comparable {
      static func < (lhs: DeinitializeCounter, rhs: DeinitializeCounter) -> Bool {
        lhs.num < rhs.num
      }
      static func == (lhs: DeinitializeCounter, rhs: DeinitializeCounter) -> Bool {
        lhs.num == rhs.num
      }
      nonisolated(unsafe) static var count = 0
      let num: Int
      init(num: Int) {
        self.num = num
        Self.count += 1
      }
      deinit { Self.count -= 1 }
    }

    func scenario() {
      var original = RedBlackTreeSet<DeinitializeCounter>((0..<4).map { DeinitializeCounter(num: $0) })
      XCTAssertEqual(DeinitializeCounter.count, 4)

      var copy = original
      XCTAssertEqual(DeinitializeCounter.count, 4, "コピー直後はバッファ共有のみで要素数は変わらないこと")

      // 片方だけ変異させ、CoWでバッファが分岐する。共有されていた既存要素(0...3)は
      // 新バッファへ引き継がれ、この時点でもインスタンス数自体は変わらないこと。
      _ = copy.insert(DeinitializeCounter(num: 99))
      XCTAssertEqual(DeinitializeCounter.count, 5, "新規追加分の1個だけ増えること")
      XCTAssertEqual(original.count, 4, "元のoriginalはCoWの影響を受けないこと")

      // originalから要素0を削除しても、CoW分岐後の`copy`が依然として同じ
      // インスタンスを参照し続けているため、この時点ではまだ解放されないこと。
      // (検索キー用の一時インスタンスだけは解放されるので、+1-1で差し引き変化なし)
      func removeFromOriginal() {
        _ = original.remove(DeinitializeCounter(num: 0))
      }
      removeFromOriginal()
      XCTAssertEqual(
        DeinitializeCounter.count, 5,
        "copyがまだ要素0を参照しているため、originalから消しても解放されないこと")
      XCTAssertEqual(original.sorted(by: { $0.num < $1.num }).map(\.num), [1, 2, 3])
      XCTAssertEqual(copy.sorted(by: { $0.num < $1.num }).map(\.num), [0, 1, 2, 3, 99])
    }

    scenario()

    XCTAssertEqual(
      DeinitializeCounter.count, 0,
      "両コピーが破棄された後、共有されていた要素(削除済みの0を含む)も全て解放されていること")
  }

  /// コピーした後、元の側とコピーの側をそれぞれクロージャの中で変更しても、互いに影響しないこと
  func test_copyOnWrite_mutatingInsideClosuresKeepsCopiesIndependent() {
    var original: RedBlackTreeSet = [1, 2, 3]
    _ = original.insert(0)
    var copy = original

    // 変更はassertionの@autoclosureの中で行う。Swift 6.4の`-O`では、この形でCoWが壊れる型が
    // あった(`NextPermutationsSequence`、2026-10-07)。赤黒木では再現しなかった
    XCTAssertTrue(original.insert(99).inserted)
    XCTAssertTrue(copy.insert(99).inserted)

    XCTAssertEqual(Array(original), [0, 1, 2, 3, 99])
    XCTAssertEqual(Array(copy), [0, 1, 2, 3, 99])
  }
}
