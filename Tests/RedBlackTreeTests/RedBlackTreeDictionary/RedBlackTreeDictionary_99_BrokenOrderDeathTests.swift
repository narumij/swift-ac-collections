#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import Testing

  private typealias BE = RedBlackTreeBoundExpression
  private var reversedBounds: RedBlackTreeBoundRangeExpression<BrokenOrderElement> {
    BE.lowerBound(BrokenOrderElement(1)) ..< BE.upperBound(BrokenOrderElement(2))
  }

  /// 指定した値で、推移律を満たさない要素の木を作る。既定は{0, 1, 5}。
  private func make(_ values: [Int] = [0, 1, 5]) -> RedBlackTreeDictionary<BrokenOrderElement, String> {
    var t = RedBlackTreeDictionary<BrokenOrderElement, String>()
    for v in values { t[BrokenOrderElement(v)] = String(repeating: "x", count: 40) }
    return t
  }

  /// 決まった種から作る、0...200の値の並び。
  private func seededValues(_ count: Int, seed: UInt64) -> [Int] {
    var g = SplitMix64(seed: seed)
    return (0 ..< count).map { _ in Int.random(in: 0 ... 200, using: &g) }
  }

  struct RedBlackTreeDictionaryBrokenOrderDeathTests {

    enum Traversal: String, CaseIterable, Codable, Sendable {
      case lazyMap, forIn, array, map, reduce, elementsEqual, indexRange, keys, values
    }

    /// 逆向きの範囲のViewを走査すると、終端ノードを要素として読む前に停止すること。
    @Test(arguments: Traversal.allCases)
    func reversedViewTraversalTraps(_ path: Traversal) async {
      switch path {
      case .lazyMap:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          for y in make()[reversedBounds].lazy.map({ x in x.key.s.count + x.value.count }) { _ = y }
        }
      case .forIn:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          for x in make()[reversedBounds] { _ = x.key.s.count + x.value.count }
        }
      case .array:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = Array(make()[reversedBounds]).count
        }
      case .map:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = make()[reversedBounds].map { x in x.key.s.count + x.value.count }
        }
      case .reduce:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = make()[reversedBounds].reduce(0) { r, x in r + x.key.s.count + x.value.count }
        }
      case .elementsEqual:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = make()[reversedBounds].elementsEqual(make()[reversedBounds]) { $0.key == $1.key }
        }
      case .indexRange:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let t = make()
          for x in t[t.lowerBound(BrokenOrderElement(1)) ..< t.upperBound(BrokenOrderElement(2))] { _ = x.key.s.count + x.value.count }
        }
      case .keys:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          for k in make()[reversedBounds].keys { _ = k.s.count }
        }
      case .values:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          for v in make()[reversedBounds].values { _ = v.count }
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
          let t = make()
          var v = t[reversedBounds]
          _ = v.erase()
        }
      case .removeAll:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let t = make()
          var v = t[reversedBounds]
          v.removeAll()
        }
      case .removeLast:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let t = make()
          var v = t[reversedBounds]
          _ = v.removeLast()
        }
      case .removeLastK:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let t = make()
          var v = t[reversedBounds]
          v.removeLast(3)
        }
      }
    }

    enum IndexOperation: String, CaseIterable, Codable, Sendable {
      case offsetLimitedForward, offsetLimitedBackward, eraseIndexRange, eraseIndexRangeWhere
    }

    /// 逆向きのIndex範囲での移動・削除は停止すること。
    @Test(arguments: IndexOperation.allCases)
    func reversedIndexOperationTraps(_ path: IndexOperation) async {
      switch path {
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
          let t = make()
          var v = t[reversedBounds]
          _ = v.popFirst()
          for x in v { _ = x.key.s.count + x.value.count }
        }
      case .removeFirstK:
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let t = make()
          var v = t[reversedBounds]
          v.removeFirst(3)
        }
      }
    }

  }
#endif
