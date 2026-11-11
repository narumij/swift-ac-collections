import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if !COMPATIBLE_ATCODER_2025
  /// `___ptr_comp_multi`（ノードの位置による前後判定）が、木を先頭から列挙した位置と一致すること。
  /// 順序が壊れた要素の`distance(from:to:)`は、この判定で向きを決めている。
  final class RedBlackTreeInternalPtrCompMultiTests: RedBlackTreeTestCase {

    private typealias P = UnsafeMutablePointer<UnsafeNode>

    /// 列挙した位置（終端は要素数）を返す。
    private func positions(_ set: RedBlackTreeSet<Int>) -> (nodes: [P], position: [P: Int]) {
      var nodes: [P] = []
      var i = set.startIndex
      while i != set.endIndex {
        nodes.append(i.rawValue.pointer)
        i = set.index(after: i)
      }
      nodes.append(set.endIndex.rawValue.pointer)
      var position: [P: Int] = [:]
      for (k, p) in nodes.enumerated() { position[p] = k }
      return (nodes, position)
    }

    /// 要素数1から64の木で、終端を含むすべての組が位置の前後と一致すること。
    func testPtrCompMulti_allPairsOfSmallTrees() {
      var g = SplitMix64(seed: 21)
      for n in 1 ... 64 {
        let set = RedBlackTreeSet<Int>((0 ..< n).shuffled(using: &g))
        let (nodes, position) = positions(set)
        for l in nodes {
          for r in nodes {
            XCTAssertEqual(___ptr_comp_multi(l, r), position[l]! < position[r]!, "n=\(n)")
          }
        }
      }
    }

    /// 削除を混ぜて形を崩した大きな木で、無作為に選んだ組が位置の前後と一致すること。
    func testPtrCompMulti_randomPairsOfLargeTreeWithRemovals() {
      var g = SplitMix64(seed: 22)
      var set = RedBlackTreeSet<Int>((0 ..< 4096).shuffled(using: &g))
      for v in (0 ..< 4096).shuffled(using: &g).prefix(1500) { set.remove(v) }
      for v in (4096 ..< 5096).shuffled(using: &g) { set.insert(v) }
      let (nodes, position) = positions(set)
      for _ in 0 ..< 20_000 {
        let l = nodes[Int.random(in: 0 ..< nodes.count, using: &g)]
        let r = nodes[Int.random(in: 0 ..< nodes.count, using: &g)]
        XCTAssertEqual(___ptr_comp_multi(l, r), position[l]! < position[r]!)
      }
      for k in 0 ..< nodes.count - 1 {
        XCTAssertTrue(___ptr_comp_multi(nodes[k], nodes[k + 1]))
        XCTAssertFalse(___ptr_comp_multi(nodes[k + 1], nodes[k]))
      }
    }
  }
#endif
