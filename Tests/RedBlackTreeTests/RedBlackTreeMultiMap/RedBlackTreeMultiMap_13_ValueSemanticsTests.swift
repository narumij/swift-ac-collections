import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapValueSemanticsTests: RedBlackTreeTestCase {

  /// コピーを変更しても元のマルチマップは変更されないこと
  func test_copyOnWrite_mutatingCopyPreservesOriginal() {
    let original: RedBlackTreeMultiMap = [1: "a", 2: "b", 2: "b2", 3: "c"]
    var copy = original

    copy.insert(key: 99, value: "z")
    #if COMPATIBLE_ATCODER_2025
      copy.removeAll(forKey: 2)
    #else
      copy.eraseMulti(2)
    #endif

    XCTAssertEqual(Array(original.map(\.key)), [1, 2, 2, 3])
    XCTAssertEqual(Array(copy.map(\.key)), [1, 3, 99])
  }

  /// コピーした後、元の側とコピーの側をそれぞれクロージャの中で変更しても、互いに影響しないこと
  func test_copyOnWrite_mutatingInsideClosuresKeepsCopiesIndependent() {
    var original: RedBlackTreeMultiMap = [1: "a", 2: "b", 2: "b2", 3: "c"]
    original.insert(key: 0, value: "o")
    var copy = original

    // 変更はassertionの@autoclosureの中で行う。Swift 6.4の`-O`では、この形でCoWが壊れる型が
    // あった(`NextPermutationsSequence`、2026-10-07)。赤黒木では再現しなかった
    XCTAssertTrue(original.insert(key: 99, value: "z").inserted)
    XCTAssertTrue(copy.insert(key: 99, value: "z").inserted)

    XCTAssertEqual(Array(original.map(\.key)), [0, 1, 2, 2, 3, 99])
    XCTAssertEqual(Array(copy.map(\.key)), [0, 1, 2, 2, 3, 99])
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMapValueSemanticsTests {
    /// 位置添字で、同値キーの要素を挿入順どおりに読めること（RBT-102）。
    func test_positionSubscript_readsEquivalentKeysInOrder() {
      var map = RedBlackTreeMultiMap<String, String>()
      map.insert(key: "b", value: "b0")
      map.insert(key: "a", value: "a0")
      map.insert(key: "b", value: "b1")
      map.insert(key: "a", value: "a1")
      map.insert(key: "b", value: "b2")

      var pairs: [String] = []
      var i = map.startIndex
      while i != map.endIndex {
        pairs.append("\(map[i].key):\(map[i].value)")
        i = map.index(after: i)
      }
      XCTAssertEqual(pairs, ["a:a0", "a:a1", "b:b0", "b:b1", "b:b2"])
    }

    /// 位置添字で取り出した要素は、マルチマップを後から変更・削除しても壊れないこと（RBT-102）。
    func test_positionSubscript_elementsOutliveMutation() {
      final class Box {
        let id: Int
        init(_ id: Int) { self.id = id }
      }
      var map = RedBlackTreeMultiMap<String, Box>()
      for i in 0 ..< 200 { map.insert(key: "key\(i / 2)", value: Box(i)) }

      var taken: [(key: String, value: Box)] = []
      var i = map.startIndex
      while i != map.endIndex {
        taken.append(map[i])
        i = map.index(after: i)
      }

      map.removeAll()
      for j in 0 ..< 200 { map.insert(key: "other\(j)", value: Box(-j)) }

      XCTAssertEqual(taken.count, 200)
      for (key, value) in taken {
        XCTAssertEqual(key, "key\(value.id / 2)")
      }
    }

    /// 共有中のマルチマップから位置添字で読んでも共有を保ち、読んだ値は元の側の変更に影響されないこと（RBT-102）。
    func test_positionSubscript_onSharedTreeKeepsSharedStorage() {
      var original = RedBlackTreeMultiMap<String, [Int]>()
      original.insert(key: "a", value: [1])
      original.insert(key: "a", value: [2])
      let shared = original

      let element = shared[shared.index(after: shared.startIndex)]

      XCTAssertEqual(element.key, "a")
      XCTAssertEqual(element.value, [2])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original))
      original.insert(key: "a", value: [3])
      XCTAssertEqual(element.value, [2])
      XCTAssertEqual(shared.map(\.value), [[1], [2]])
    }
  }
#endif
