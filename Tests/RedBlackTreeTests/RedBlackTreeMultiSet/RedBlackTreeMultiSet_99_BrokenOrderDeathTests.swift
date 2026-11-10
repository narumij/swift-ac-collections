#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import Testing
  #if canImport(Darwin)
    import Darwin
  #elseif canImport(Glibc)
    import Glibc
  #endif

  private typealias BE = RedBlackTreeBoundExpression
  private var reversedBounds: RedBlackTreeBoundRangeExpression<BrokenOrderElement> {
    BE.lowerBound(BrokenOrderElement(1)) ..< BE.upperBound(BrokenOrderElement(2))
  }

  /// 指定した値で、推移律を満たさない要素の木を作る。既定は{0, 1, 5}。
  private func make(_ values: [Int] = [0, 1, 5]) -> RedBlackTreeMultiSet<BrokenOrderElement> {
    var t = RedBlackTreeMultiSet<BrokenOrderElement>()
    for v in values { t.insert(BrokenOrderElement(v)) }
    return t
  }

  /// 決まった種から作る、0...200の値の並び。
  private func seededValues(_ count: Int, seed: UInt64) -> [Int] {
    var g = SplitMix64(seed: seed)
    return (0 ..< count).map { _ in Int.random(in: 0 ... 200, using: &g) }
  }

  struct RedBlackTreeMultiSetBrokenOrderDeathTests {

    enum Traversal: String, CaseIterable, Codable, Sendable {
      case lazyMap, forIn, array, map, reduce, elementsEqual, indexRange, keyRange, closedKeyRange
    }

    /// 逆向きの範囲のViewを走査すると、終端ノードを要素として読む前に停止すること。
    @Test(arguments: Traversal.allCases)
    func reversedViewTraversalTraps(_ path: Traversal) async {
      switch path {
      case .lazyMap:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          for y in make()[reversedBounds].lazy.map({ x in x.s.count }) { _ = y }
        }
      case .forIn:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          for x in make()[reversedBounds] { _ = x.s.count }
        }
      case .array:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = Array(make()[reversedBounds]).count
        }
      case .map:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = make()[reversedBounds].map { x in x.s.count }
        }
      case .reduce:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = make()[reversedBounds].reduce(0) { r, x in r + x.s.count }
        }
      case .elementsEqual:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = make()[reversedBounds].elementsEqual(make()[reversedBounds])
        }
      case .indexRange:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let t = make()
          for x in t[t.lowerBound(BrokenOrderElement(1)) ..< t.upperBound(BrokenOrderElement(2))] { _ = x.s.count }
        }
      case .keyRange:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          for x in make()[BrokenOrderElement(1) ..< BrokenOrderElement(2)] { _ = x.s.count }
        }
      case .closedKeyRange:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          for x in make()[BrokenOrderElement(1) ... BrokenOrderElement(2)] { _ = x.s.count }
        }
      }
    }

    enum WholeViewOperation: String, CaseIterable, Codable, Sendable {
      case sorted, reversed, erase, removeAll, removeLast, removeLastK
    }

    /// 逆向きの範囲のViewで、全体を写す・消す操作と、末尾を必ず消す操作は停止すること。
    @Test(arguments: WholeViewOperation.allCases)
    func reversedViewWholeOperationTraps(_ path: WholeViewOperation) async {
      switch path {
      case .sorted:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = make()[reversedBounds].sorted().count
        }
      case .reversed:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = make()[reversedBounds].reversed().count
        }
      case .erase:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          var t = make()
          var v = t[reversedBounds]
          _ = v.erase()
        }
      case .removeAll:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          var t = make()
          var v = t[reversedBounds]
          v.removeAll()
        }
      case .removeLast:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          var t = make()
          var v = t[reversedBounds]
          _ = v.removeLast()
        }
      case .removeLastK:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          var t = make()
          var v = t[reversedBounds]
          v.removeLast(3)
        }
      }
    }

    enum IndexOperation: String, CaseIterable, Codable, Sendable {
      case distance, distanceBackward, offsetLimitedForward, offsetLimitedBackward, eraseIndexRange, eraseIndexRangeWhere, removeSubrange
    }

    /// 逆向きのIndex範囲での距離・移動・削除は停止すること。
    @Test(arguments: IndexOperation.allCases)
    func reversedIndexOperationTraps(_ path: IndexOperation) async {
      switch path {
      case .distance:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let t = make()
          _ = t.distance(from: t.lowerBound(BrokenOrderElement(1)), to: t.upperBound(BrokenOrderElement(2)))
        }
      case .distanceBackward:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let t = make()
          _ = t.distance(from: t.upperBound(BrokenOrderElement(2)), to: t.lowerBound(BrokenOrderElement(1)))
        }
      case .offsetLimitedForward:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let t = make()
          _ = t.index(t.lowerBound(BrokenOrderElement(1)), offsetBy: 3, limitedBy: t.upperBound(BrokenOrderElement(2)))
        }
      case .offsetLimitedBackward:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let t = make()
          _ = t.index(t.upperBound(BrokenOrderElement(2)), offsetBy: -3, limitedBy: t.lowerBound(BrokenOrderElement(1)))
        }
      case .eraseIndexRange:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          var t = make()
          let i = t.lowerBound(BrokenOrderElement(1)), j = t.upperBound(BrokenOrderElement(2))
          _ = t.erase(i ..< j)
        }
      case .eraseIndexRangeWhere:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          var t = make()
          let i = t.lowerBound(BrokenOrderElement(1)), j = t.upperBound(BrokenOrderElement(2))
          t.erase(i ..< j, where: { _ in true })
        }
      case .removeSubrange:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          var t = make()
          let i = t.lowerBound(BrokenOrderElement(1)), j = t.upperBound(BrokenOrderElement(2))
          t.removeSubrange(i ..< j)
        }
      }
    }

    enum PopFirst: String, CaseIterable, Codable, Sendable {
      case popFirstOnceThenForIn, removeFirstK
    }

    /// 逆向きの範囲のViewで、先頭を消したあとに走査する・消す数を決めて先頭から消すと、終端ノードを要素として読む前に停止すること。
    @Test(arguments: PopFirst.allCases)
    func reversedViewPopFirstTraps(_ path: PopFirst) async {
      switch path {
      case .popFirstOnceThenForIn:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          var t = make()
          var v = t[reversedBounds]
          _ = v.popFirst()
          for x in v { _ = x.s.count }
        }
      case .removeFirstK:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          var t = make()
          var v = t[reversedBounds]
          v.removeFirst(3)
        }
      }
    }

    /// NaNを含むDoubleで、範囲の外を越える`distance(from:to:)`は停止すること。
    @Test func distanceWithNaNTraps() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var ms = RedBlackTreeMultiSet<Double>()
        for x in [2.0, .nan, 2.0, 1.0] { ms.insert(x) }
        _ = ms.distance(from: ms.startIndex, to: ms.upperBound(0.5))
      }
    }


    /// NaNを含むDoubleで、位置が逆向きのIndex範囲から作ったViewを走査すると停止すること。
    /// 要素の並びは[10, nan, 1, 20]で、1は10より後ろにあるが、比較では1 < 10になる。
    @Test func nanReversedIndexRangeTraversalTraps() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var t = RedBlackTreeMultiSet<Double>()
          for x in [10.0, .nan, 20.0, 1.0] { t.insert(x) }
        let a = t.index(t.startIndex, offsetBy: 2)
        for x in t[a ..< t.startIndex] { _ = x }
      }
    }


    /// 逆向きの範囲の境界式で`distance(from:to:)`を呼ぶと、止まること（返らない場合は10秒でSIGALRMになり、失敗として記録される）。
    @Test
    func boundDistanceOverReversedRangeTraps() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        alarm(10)  // 返らない場合に子プロセスを終わらせる
        _ = make().distance(from: BE.lowerBound(BrokenOrderElement(1)), to: BE.upperBound(BrokenOrderElement(2)))
      }
    }

    /// 逆向きの範囲の境界式を入れ替えて`distance(from:to:)`を呼んでも、止まること。
    @Test
    func boundDistanceBackwardOverReversedRangeTraps() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        alarm(10)  // 返らない場合に子プロセスを終わらせる
        _ = make().distance(from: BE.upperBound(BrokenOrderElement(2)), to: BE.lowerBound(BrokenOrderElement(1)))
      }
    }

    /// NaNを含むDoubleで、範囲の外を越える境界式の`distance(from:to:)`は止まること。
    @Test
    func boundDistanceWithNaNTraps() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        alarm(10)  // 返らない場合に子プロセスを終わらせる
        var ms = RedBlackTreeMultiSet<Double>()
        for x in [2.0, .nan, 2.0, 1.0] { ms.insert(x) }
        _ = ms.distance(from: RedBlackTreeBoundExpression.start, to: .upperBound(0.5))
      }
    }
  }
#endif
