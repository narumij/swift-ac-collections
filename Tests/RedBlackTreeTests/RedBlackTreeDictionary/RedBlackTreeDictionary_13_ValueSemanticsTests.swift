import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryValueSemanticsTests: RedBlackTreeTestCase {

  /// コピーを変更しても元の辞書は変更されないこと
  func test_copyOnWrite_mutatingCopyPreservesOriginal() {
    let original: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]
    var copy = original

    copy[99] = "z"
    copy.removeValue(forKey: 2)

    XCTAssertEqual(Array(original.map(\.key)), [1, 2, 3])
    XCTAssertEqual(Array(copy.map(\.key)), [1, 3, 99])
  }

  /// コピーした後、元の側とコピーの側をそれぞれクロージャの中で変更しても、互いに影響しないこと
  func test_copyOnWrite_mutatingInsideClosuresKeepsCopiesIndependent() {
    var original: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]
    original[0] = "o"
    var copy = original

    // 変更はassertionの@autoclosureの中で行う。Swift 6.4の`-O`では、この形でCoWが壊れる型が
    // あった(`NextPermutationsSequence`、2026-10-07)。赤黒木では再現しなかった
    XCTAssertNil(original.updateValue("z", forKey: 99))
    XCTAssertNil(copy.updateValue("z", forKey: 99))

    XCTAssertEqual(Array(original.map(\.key)), [0, 1, 2, 3, 99])
    XCTAssertEqual(Array(copy.map(\.key)), [0, 1, 2, 3, 99])
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionaryValueSemanticsTests {
    /// dict[k]?.mutatingが値をコピーせずにその場で変更すること（コピーするとappendの繰り返しがO(n^2)になる）。
    func test_optionalChainingModify_doesNotCopyValue() {
      final class Ref {}
      struct Probe {
        var ref = Ref()
        mutating func isUnique() -> Bool { isKnownUniquelyReferenced(&ref) }
      }
      var dictionary: RedBlackTreeDictionary<Int, Probe> = [0: Probe()]
      XCTAssertEqual(dictionary[0]?.isUnique(), true)
    }

    /// 位置添字で取り出した要素は、辞書を後から変更・削除しても壊れないこと（RBT-100）。
    func test_positionSubscript_elementsOutliveMutation() {
      final class Box: Equatable {
        let id: Int
        init(_ id: Int) { self.id = id }
        static func == (lhs: Box, rhs: Box) -> Bool { lhs.id == rhs.id }
      }
      var dictionary = RedBlackTreeDictionary<String, Box>()
      for i in 0 ..< 200 { dictionary["key\(i)"] = Box(i) }

      var taken: [(key: String, value: Box)] = []
      var i = dictionary.startIndex
      while i != dictionary.endIndex {
        taken.append(dictionary[i])
        let (k, v) = dictionary[i]
        XCTAssertEqual(dictionary[k]?.id, v.id)
        i = dictionary.index(after: i)
      }

      dictionary.removeAll()
      for j in 0 ..< 200 { dictionary["other\(j)"] = Box(-j) }

      XCTAssertEqual(taken.count, 200)
      XCTAssertEqual(Set(taken.map(\.key)).count, 200)
      for (key, value) in taken {
        XCTAssertEqual(key, "key\(value.id)")
      }
    }
  }
#endif

#if !_TREE_ALLOCATION_COUNTER && !_TREE_COPY_COUNTER
  // 並行CoW: 共有した値を各タスクへコピーして同時に変更しても、互いと元の値に影響しないこと。
  // Debugのprocess-globalな寿命カウンタ自体は並行更新に対応しないため、カウンタ無効時だけ実行する。
  extension RedBlackTreeDictionaryValueSemanticsTests {
    func testDictionaryConcurrentCopies() async {
      var initial = RedBlackTreeDictionary<Int, Int>()
      for key in 0 ..< 256 { initial[key] = key }
      let original = initial
      let results = await withTaskGroup(of: (Int, [Int], [Int]).self) { group in
        for worker in 0 ..< 8 {
          group.addTask { [original] in
            var copy = original
            for key in 0 ..< 128 {
              copy.removeValue(forKey: key)
              copy[key + 128] = worker
              copy[1000 + key] = worker + 100
            }
            return (worker, copy.map { $0.key }, copy.map { $0.value })
          }
        }
        var values: [(Int, [Int], [Int])] = []
        for await value in group { values.append(value) }
        return values
      }
      XCTAssertEqual(original.map { $0.key }, Array(0 ..< 256))
      XCTAssertEqual(original.map { $0.value }, Array(0 ..< 256))
      XCTAssertEqual(results.count, 8)
      for (worker, keys, values) in results {
        XCTAssertEqual(keys, Array(128 ..< 256) + Array(1000 ..< 1128))
        XCTAssertEqual(
          values,
          Array(repeating: worker, count: 128)
            + Array(repeating: worker + 100, count: 128)
        )
      }
    }
  }
#endif
