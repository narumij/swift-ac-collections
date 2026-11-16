import RedBlackTreeCollections
import XCTest

/// シンプル Count ディクショナリを参照モデルとして利用(キーの多重度のみ追跡)
private struct ReferenceMultiMap {
  private var dict: [Int: Int] = [:]
  mutating func insert(_ key: Int) { dict[key, default: 0] += 1 }
  mutating func removeOne(_ key: Int) {
    if let c = dict[key], c > 1 { dict[key] = c - 1 } else { dict.removeValue(forKey: key) }
  }
  mutating func removeAll(_ key: Int) { dict.removeValue(forKey: key) }
  func count(of key: Int) -> Int { dict[key] ?? 0 }
  var sortedKeys: [Int] { dict.flatMap { Array(repeating: $0.key, count: $0.value) }.sorted() }
}

#if !COMPATIBLE_ATCODER_2025
  final class RedBlackTreeMultiMapFuzzTests: RedBlackTreeTestCase {

    func test_randomizedInsertAndEraseMatchesReferenceMultiMapAndMaintainsTreeInvariant() {
      var rng = SplitMix64(seed: 0xBADC0DE)
      let rounds = 150
      let opsPerRound = 400

      for _ in 0..<rounds {
        var mm = RedBlackTreeMultiMap<Int, Int>()
        var ref = ReferenceMultiMap()

        for _ in 0..<opsPerRound {
          let k = Int(rng.next() & 0x3F)
          switch rng.next() & 3 {
          case 0:  // insert
            mm.insert(key: k, value: k)
            ref.insert(k)
          case 1:  // remove one
            _ = mm.eraseUnique(k)
            ref.removeOne(k)
          case 2:  // removeAll
            _ = mm.eraseMulti(k)
            ref.removeAll(k)
          default:  // count check only
            break
          }
          // キーの多重度とキー・値ペアの同期検証
          // (本テストでは value == key で挿入するため、キーの多重度一致が
          // ペア全体の一致を意味する)
          XCTAssertEqual(mm.map(\.key).sorted(), ref.sortedKeys)
          XCTAssertTrue(mm.allSatisfy { $0.value == $0.key })
          XCTAssertTrue(mm.___tree_invariant_for_fuzz())
        }
      }
    }

    func test_randomInsertAndEraseMatchesReferenceAndMaintainsTreeInvariant() {
      var rng = SplitMix64(seed: 0xDEADBEEF)
      var multiMap = RedBlackTreeMultiMap<Int, Int>()
      var reference = ReferenceMultiMap()

      for _ in 0..<3 {
        for _ in 0..<1000 {
          let v = Int(rng.next() % 500)
          multiMap.insert((v, v))
          reference.insert(v)
          XCTAssertEqual(multiMap.map(\.key).sorted(), reference.sortedKeys)
          XCTAssertTrue(multiMap.allSatisfy { $0.value == $0.key })
          XCTAssertTrue(multiMap.___tree_invariant_for_fuzz())
        }
        for _ in 0..<1000 {
          let v = Int(rng.next() % 500)
          multiMap.eraseMulti(v)
          reference.removeAll(v)
          XCTAssertEqual(multiMap.map(\.key).sorted(), reference.sortedKeys)
          XCTAssertTrue(multiMap.allSatisfy { $0.value == $0.key })
          XCTAssertTrue(multiMap.___tree_invariant_for_fuzz())
        }
      }
    }
  }
#endif
