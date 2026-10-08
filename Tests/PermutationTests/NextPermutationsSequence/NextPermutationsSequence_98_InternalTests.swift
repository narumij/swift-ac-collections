//
//  NextPermutationsSequence_98_InternalTests.swift
//  swift-ac-collections
//

// 実装の確認(仕様ではない)。`DEBUG`のときだけ有効。

#if DEBUG
  import PermutationModule
  import XCTest

  final class NextPermutationsSequence_98_InternalTests: XCTestCase {

    func testBufferDestroysHeaderOnce() throws {
      // bufferの破棄でheaderは1回だけ破棄される。二重に破棄すると、headerが持つ参照も
      // 二重に解放される
      let before = NextPermutationsHeaderProbe.deinitCount
      do {
        var iterator = [1, 2, 3].nextPermutations().makeIterator()
        _ = iterator.next()
      }
      XCTAssertEqual(NextPermutationsHeaderProbe.deinitCount - before, 1)
    }

    func testNoCopyWhenFinishingWhileLastResultIsRetained() throws {
      // 最後の結果を保持したまま終端に達しても、終わりを知るためだけのbufferのコピーは起きない。
      // bufferが1つだけなら、破棄されるheaderも1つになる
      let before = NextPermutationsHeaderProbe.deinitCount
      do {
        var iterator = [1, 2].nextPermutations().makeIterator()
        _ = iterator.next()
        let last = iterator.next()
        withExtendedLifetime(last) {
          XCTAssertNil(iterator.next())
        }
      }
      XCTAssertEqual(NextPermutationsHeaderProbe.deinitCount - before, 1)
    }

    func testOddLengthReverseKeepsElementLifetimes() throws {
      // 奇数長の反転では真ん中の要素が自分自身と入れ替わる。参照型の要素でも、
      // 生成した数だけ破棄され、値も壊れない
      final class Box {
        nonisolated(unsafe) static var deinitCount = 0
        let value: Int
        init(_ value: Int) { self.value = value }
        deinit { Self.deinitCount += 1 }
      }
      struct Element: Comparable {
        let box: Box
        static func < (lhs: Self, rhs: Self) -> Bool { lhs.box.value < rhs.box.value }
        static func == (lhs: Self, rhs: Self) -> Bool { lhs.box.value == rhs.box.value }
      }
      let before = Box.deinitCount
      do {
        let source = (0..<5).map { Element(box: Box($0)) }
        var orders: [[Int]] = []
        for p in source.nextPermutations() {
          orders.append(p.map(\.box.value))
        }
        XCTAssertEqual(orders.count, 120)
        XCTAssertEqual(Set(orders).count, 120)
      }
      XCTAssertEqual(Box.deinitCount - before, 5)
    }

    func testNoCopyWhenResultsAreNotRetained() throws {
      // 結果を保持せずに進めるなら、bufferのコピーは起きない
      for p in (0..<4).nextPermutations() {
        XCTAssertEqual(p._copyCount, 0)
      }
    }
  }
#endif
