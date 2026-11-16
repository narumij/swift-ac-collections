import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryFuzzTests: RedBlackTreeTestCase {

  private func assertEqual<K: Comparable, V: Equatable>(
    _ rb: RedBlackTreeDictionary<K, V>,
    _ swift: [K: V],
    file: StaticString = #file, line: UInt = #line
  ) {
    XCTAssertEqual(rb.count, swift.count, file: (file), line: line)
    for (k, v) in swift {
      XCTAssertEqual(
        rb[k], v, "Mismatch at key: \(k)",
        file: (file), line: line)
    }
  }

  func test_randomAssignPopFirstMergeAndMapValuesMatchesSwiftDictionary() {
    var rng = SplitMix64(seed: 0x1337_C0DE)
    for _ in 0..<120 {
      var rb = RedBlackTreeDictionary<Int, Int>()
      var std = [Int: Int]()

      for _ in 0..<300 {
        let k = Int(rng.next() & 0x3F)
        switch rng.next() & 7 {
        case 0:  // 代入
          let v = Int(rng.next() & 0xFFFF)
          rb[k] = v
          std[k] = v
        case 1:  // popFirst
          _ = rb.popFirst()
          _ = std.sorted { $0.key < $1.key }.first
            .map { std.removeValue(forKey: $0.key) }
        case 2:  // merge 1 要素
          rb.merge([(k, 1)]) { $0 + $1 }
          std.merge([k: 1]) { $0 + $1 }
        case 3:  // mapValues chain
          rb = rb.mapValues { $0 + 1 }
          std = std.mapValues { $0 + 1 }
        default: break
        }
        assertEqual(rb, std)
        XCTAssertTrue(rb.___tree_invariant_for_fuzz())
      }
    }
  }

  func test_randomInsertAndEraseMatchesReferenceAndMaintainsTreeInvariant() {
    var rng = SplitMix64(seed: 0xDEADBEEF)
    var dictionary = RedBlackTreeDictionary<Int, Int>()
    var reference = [Int: Int]()

    for _ in 0..<3 {
      for _ in 0..<1000 {
        let v = Int(rng.next() % 500)
        dictionary[v] = v
        reference[v] = v
        assertEqual(dictionary, reference)
        XCTAssertTrue(dictionary.___tree_invariant_for_fuzz())
      }
      for _ in 0..<1000 {
        let v = Int(rng.next() % 500)
        dictionary.removeValue(forKey: v)
        reference.removeValue(forKey: v)
        assertEqual(dictionary, reference)
        XCTAssertTrue(dictionary.___tree_invariant_for_fuzz())
      }
    }
  }
}
