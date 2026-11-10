#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import Testing

  private typealias BE = RedBlackTreeBoundExpression
  private var reversedBounds: RedBlackTreeBoundRangeExpression<BrokenOrderElement> {
    BE.lowerBound(BrokenOrderElement(1)) ..< BE.upperBound(BrokenOrderElement(2))
  }

  /// {0, 1, 5}に、推移律を満たさない要素を入れた木。
  private func make() -> RedBlackTreeMultiSet<BrokenOrderElement> {
    var t = RedBlackTreeMultiSet<BrokenOrderElement>()
    for v in [0, 1, 5] { t.insert(BrokenOrderElement(v)) }
    return t
  }

  struct RedBlackTreeMultiSetBrokenOrderDeathTests {

    enum Path: String, CaseIterable, Codable, Sendable {
      case forIn, array, indexRange
    }

    /// 逆向きの範囲のViewを前向きに走査すると、終端ノードを要素として読む前に停止すること。
    @Test(arguments: Path.allCases)
    func reversedViewTrapsBeforeReadingEndNode(_ path: Path) async {
      switch path {
      case .forIn:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          for x in make()[reversedBounds] { _ = x.s.count }
        }
      case .array:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = Array(make()[reversedBounds]).count
        }
      case .indexRange:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let t = make()
          let i = t.lowerBound(BrokenOrderElement(1)), j = t.upperBound(BrokenOrderElement(2))
          for x in t[i ..< j] { _ = x.s.count }
        }
      }
    }

    /// 逆向きの範囲で`distance(from:to:)`を呼ぶと停止すること。
    @Test func distanceOverReversedRangeTraps() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        let t = make()
        _ = t.distance(from: t.lowerBound(BrokenOrderElement(1)), to: t.upperBound(BrokenOrderElement(2)))
      }
    }

    @Test func distanceWithNaNTraps() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var ms = RedBlackTreeMultiSet<Double>()
        for x in [2.0, .nan, 2.0, 1.0] { ms.insert(x) }
        _ = ms.distance(from: ms.startIndex, to: ms.upperBound(0.5))
      }
    }
  }
#endif
