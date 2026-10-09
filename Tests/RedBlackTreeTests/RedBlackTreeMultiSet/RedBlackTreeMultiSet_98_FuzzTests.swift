import RedBlackTreeCollections
import XCTest

/// シンプル Count ディクショナリを Swift 標準 Multiset 代わりに利用
private struct ReferenceMultiset {
  private var dict: [Int: Int] = [:]
  mutating func insert(_ x: Int) { dict[x, default: 0] += 1 }
  mutating func removeOne(_ x: Int) {
    if let c = dict[x], c > 1 { dict[x] = c - 1 } else { dict.removeValue(forKey: x) }
  }
  mutating func removeAll(_ x: Int) { dict.removeValue(forKey: x) }
  func count(of x: Int) -> Int { dict[x] ?? 0 }
  var sorted: [Int] { dict.flatMap { Array(repeating: $0.key, count: $0.value) }.sorted() }
}

  final class RedBlackTreeMultiSetFuzzTests: RedBlackTreeTestCase {

    func test_randomizedInsertAndEraseMatchesReferenceMultisetAndMaintainsTreeInvariant() {
      var rng = SplitMix64(seed: 0xBADC0DE)
      let rounds = 150
      let opsPerRound = 400

      for _ in 0..<rounds {
        var ms = RedBlackTreeMultiSet<Int>()
        var ref = ReferenceMultiset()

        for _ in 0..<opsPerRound {
          let v = Int(rng.next() & 0x3F)  // 0…63
          switch rng.next() & 3 {
          case 0:  // insert
            ms.insert(v)
            ref.insert(v)
          case 1:  // remove one
            _ = ms.eraseUnique(v)
            ref.removeOne(v)
          case 2:  // removeAll
            _ = ms.eraseMulti(v)
            ref.removeAll(v)
          default:  // count check only
            break
          }
          // 全要素(多重度込み)の同期検証
          XCTAssertEqual(ms.sorted(), ref.sorted)
          XCTAssertTrue(ms.___tree_invariant_for_fuzz())
        }
      }
    }

    func test_randomInsertAndEraseMatchesReferenceAndMaintainsTreeInvariant() {
      var rng = SplitMix64(seed: 0xDEADBEEF)
      var multiset = RedBlackTreeMultiSet<Int>()
      var reference = ReferenceMultiset()

      for _ in 0..<3 {
        for _ in 0..<1000 {
          let v = Int(rng.next() % 500)
          multiset.insert(v)
          reference.insert(v)
          XCTAssertEqual(multiset.sorted(), reference.sorted)
          XCTAssertTrue(multiset.___tree_invariant_for_fuzz())
        }
        for _ in 0..<1000 {
          let v = Int(rng.next() % 500)
          multiset.eraseMulti(v)
          reference.removeAll(v)
          XCTAssertEqual(multiset.sorted(), reference.sorted)
          XCTAssertTrue(multiset.___tree_invariant_for_fuzz())
        }
      }
    }
  }
