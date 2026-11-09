import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryRemovalTests: RedBlackTreeTestCase {

  func test_removeValueForKey_returnsRemovedValue() {
    var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]

    XCTAssertNil(dictionary.removeValue(forKey: 0))
    XCTAssertEqual(dictionary.removeValue(forKey: 2), "b")
    XCTAssertEqual(dictionary.map(\.key), [1, 3])
  }

  func test_removeAt_removesSelectedEntry() {
    var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
    let index = dictionary.firstIndex(of: 2)!

    let removed = dictionary.remove(at: index)

    XCTAssertEqual(removed.key, 2)
    XCTAssertEqual(removed.value, "b")
    XCTAssertEqual(dictionary.map(\.key), [1, 3])
  }

  #if !COMPATIBLE_ATCODER_2025
    /// 共有状態で削除しても元を保ち、削除位置の次のIndexを返すこと（RBT-056）。
    func test_eraseIndex_preservesSharedOriginalAndReturnsSuccessor() {
      let expected = ["a", "b", "c"]
      for offset in expected.indices {
        let original = RedBlackTreeDictionary<Int, String>(keysWithValues: [(1, "a"), (2, "b"), (3, "c")])
        var copy = original
        let index = copy.index(copy.startIndex, offsetBy: offset)

        let next = copy.erase(index)

        var remaining = expected
        remaining.remove(at: offset)
        XCTAssertEqual(original.map(\.value), expected)
        XCTAssertEqual(copy.map(\.value), remaining)
        if offset == remaining.count {
          XCTAssertEqual(next, copy.endIndex)
        } else {
          XCTAssertEqual(copy[next].value, remaining[offset])
        }
      }
    }

    func test_erase_returnsTheFollowingIndex() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      let removed = dictionary.firstIndex(of: 2)!

      let next = dictionary.erase(removed)

      XCTAssertEqual(dictionary[next].key, 3)
      XCTAssertEqual(dictionary.map(\.key), [1, 3])
    }

    func test_eraseWhere_removesEveryMatchingEntry() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [
        1: "keep",
        2: "remove",
        3: "keep",
        4: "remove",
      ]

      dictionary.erase { $0.key.isMultiple(of: 2) }

      XCTAssertEqual(dictionary.map(\.key), [1, 3])
    }

    /// erase(where:)は述語のエラーをそのまま投げ、投げた後は述語を呼ばないこと。
    /// 共有していた元の辞書のkey/valueは変わらないこと。変更側の途中状態は、元の要素だけを
    /// キー順に持つことだけを確かめる（RBT-044 D2）
    func test_eraseWhere_rethrowsPredicateErrorAndKeepsSharedOriginal() {
      struct StopError: Error, Equatable {}
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d"]
      var dictionary = original
      var visited: [Int] = []

      XCTAssertThrowsError(
        try dictionary.erase { element in
          visited.append(element.key)
          if element.key == 3 { throw StopError() }
          return element.key == 2
        }
      ) { error in
        XCTAssertEqual(error as? StopError, StopError())
      }
      XCTAssertEqual(visited, [1, 2, 3])
      XCTAssertEqual(original.map(\.key), [1, 2, 3, 4])
      XCTAssertEqual(original.map(\.value), ["a", "b", "c", "d"])
      XCTAssertEqual(dictionary.map(\.key), dictionary.map(\.key).sorted())
      XCTAssertTrue(dictionary.allSatisfy { original[$0.key] == $0.value })
    }
  #endif

  /// 共有コピーを残して参照Valueを置換・削除しても、共有元は元の参照を保ち、
  /// 戻り値として取り出した旧値は保持している間は生存し、最後の保持を解いたときに解放されること（RBT-044 D4）
  func test_sharedReferenceValuesSurviveReplacementAndRemovalUntilTheLastOwner() {
    final class Box { let id: Int; init(_ id: Int) { self.id = id } }
    weak var weakFirst: Box?
    weak var weakSecond: Box?
    var dictionary: RedBlackTreeDictionary<Int, Box>
    do {
      let first = Box(1)
      let second = Box(2)
      weakFirst = first
      weakSecond = second
      dictionary = [1: first, 2: second]
    }
    var shared = dictionary

    var oldFirst = dictionary.updateValue(Box(10), forKey: 1)
    var oldSecond = dictionary.removeValue(forKey: 2)
    XCTAssertTrue(oldFirst === weakFirst)
    XCTAssertTrue(oldSecond === weakSecond)
    XCTAssertEqual(dictionary.map(\.key), [1])
    XCTAssertEqual(dictionary[1]?.id, 10)
    XCTAssertEqual(shared.map(\.key), [1, 2])
    XCTAssertTrue(shared[1] === weakFirst, "共有元は元の参照を保つこと")
    XCTAssertTrue(shared[2] === weakSecond)

    shared = [:]
    XCTAssertNotNil(weakFirst, "取り出した旧値を保持している間は生存すること")
    XCTAssertNotNil(weakSecond)

    oldFirst = nil
    XCTAssertNil(weakFirst, "最後の保持を解いたときに解放されること")
    XCTAssertNotNil(weakSecond)
    oldSecond = nil
    XCTAssertNil(weakSecond)
  }

  func test_popFirst_returnsNilOrRemovesLowestKey() {
    var empty = RedBlackTreeDictionary<Int, String>()
    var dictionary: RedBlackTreeDictionary<Int, String> = [3: "c", 1: "a", 2: "b"]

    XCTAssertNil(empty.popFirst())
    XCTAssertEqual(dictionary.popFirst()?.key, 1)
    XCTAssertEqual(dictionary.map(\.key), [2, 3])
  }

  /// 空の辞書への削除操作はトラップしない以上、無駄なCoW(共有される空シングルトン
  /// バッファからの退避)も発生させないこと。
  func test_removalMethods_onEmptyDictionary_doNotTriggerCopyOnWrite() {
    #if _TREE_COPY_COUNTER
      var empty = RedBlackTreeDictionary<Int, String>()
      XCTAssertEqual(empty._copyCount, 0)

      XCTAssertNil(empty.popFirst())
      XCTAssertEqual(empty._copyCount, 0)

      #if !COMPATIBLE_ATCODER_2025
        XCTAssertNil(empty.popLast())
        XCTAssertEqual(empty._copyCount, 0)
      #endif

      XCTAssertNil(empty.removeValue(forKey: 1))
      XCTAssertEqual(empty._copyCount, 0)

      empty.removeAll(keepingCapacity: true)
      XCTAssertEqual(empty._copyCount, 0, "空の辞書へのremoveAll(keepingCapacity: true)は退避コピーを発生させないはず")

      #if !COMPATIBLE_ATCODER_2025
        var predicateCalled = false
        empty.erase(where: { _ in
          predicateCalled = true
          return true
        })
        XCTAssertFalse(predicateCalled, "空の辞書へのerase(where:)は述語を呼ばないはず")
        XCTAssertEqual(empty._copyCount, 0, "空の辞書へのerase(where:)は退避コピーを発生させないはず")
      #endif
    #endif
  }

  func test_removeFirstAndRemoveLast_followKeyOrder() {
    var dictionary: RedBlackTreeDictionary<Int, String> = [3: "c", 1: "a", 2: "b"]

    XCTAssertEqual(dictionary.removeFirst().key, 1)
    XCTAssertEqual(dictionary.removeLast().key, 3)
    XCTAssertEqual(dictionary.first?.key, 2)
    XCTAssertEqual(dictionary.last?.key, 2)
  }

  func test_removeAll_clearsEntriesAndHonorsCapacityChoice() {
    var keepingCapacity = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0) })
    let originalCapacity = keepingCapacity.capacity

    keepingCapacity.removeAll(keepingCapacity: true)
    XCTAssertTrue(keepingCapacity.isEmpty)
    XCTAssertEqual(keepingCapacity.capacity, originalCapacity)

    var releasingCapacity = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0) })
    releasingCapacity.removeAll()
    XCTAssertTrue(releasingCapacity.isEmpty)
  }

  /// popFirst/popLast/removeValue(forKey:)/removeAllが、保持していた参照型の値を
  /// 正しく解放すること(二重解放やリークがないこと)
  func test_variousRemovalMethods_releaseRetainedReferenceValuesExactlyOnce() {
    final class DeinitializeCounter {
      nonisolated(unsafe) static var count = 0
      init() { Self.count += 1 }
      deinit { Self.count -= 1 }
    }

    var dictionary = RedBlackTreeDictionary<Int, DeinitializeCounter>(
      uniqueKeysWithValues: (0..<4).map { ($0, DeinitializeCounter()) })
    XCTAssertEqual(DeinitializeCounter.count, 4)

    _ = dictionary.popFirst()
    XCTAssertEqual(DeinitializeCounter.count, 3)

    #if !COMPATIBLE_ATCODER_2025
      _ = dictionary.popLast()
      XCTAssertEqual(DeinitializeCounter.count, 2)
    #endif

    _ = dictionary.removeValue(forKey: 1)
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(DeinitializeCounter.count, 2)
    #else
      XCTAssertEqual(DeinitializeCounter.count, 1)
    #endif

    dictionary.removeAll()
    XCTAssertEqual(DeinitializeCounter.count, 0)
  }

  /// `subscript(key:)`へのnil代入(キー削除)が、参照型Valueを二重解放せずに
  /// ちょうど1回だけ解放すること(2026-10-03発見・修正済みの回帰防止テスト)
  func test_subscriptAssignNil_releasesRetainedReferenceValueExactlyOnce() {
    final class DeinitializeCounter {
      nonisolated(unsafe) static var count = 0
      init() { Self.count += 1 }
      deinit { Self.count -= 1 }
    }

    var dictionary = RedBlackTreeDictionary<Int, DeinitializeCounter>(
      uniqueKeysWithValues: (0..<3).map { ($0, DeinitializeCounter()) })
    XCTAssertEqual(DeinitializeCounter.count, 3)

    dictionary[1] = nil

    XCTAssertEqual(DeinitializeCounter.count, 2)
  }

  /// `subscript(key:)`へ既存キーの新しい値を代入したとき、古い参照型Valueが
  /// リークせずちょうど1回だけ解放されること(`.move()`廃止に伴う回帰防止テスト)
  func test_subscriptOverwriteExistingKey_releasesOldReferenceValueExactlyOnce() {
    final class DeinitializeCounter {
      nonisolated(unsafe) static var count = 0
      init() { Self.count += 1 }
      deinit { Self.count -= 1 }
    }

    var dictionary = RedBlackTreeDictionary<Int, DeinitializeCounter>(
      uniqueKeysWithValues: (0..<3).map { ($0, DeinitializeCounter()) })
    XCTAssertEqual(DeinitializeCounter.count, 3)

    dictionary[1] = DeinitializeCounter()
    XCTAssertEqual(DeinitializeCounter.count, 3, "古い値が解放され、新しい値が1つ増えるので差し引き変化なし")

    dictionary.removeAll()
    XCTAssertEqual(DeinitializeCounter.count, 0)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionaryRemovalTests {
    /// 何も消さない削除や空での削除は、共有中のストレージをコピーしないこと（Swift.Dictionaryと同じ）。
    func test_noOpRemoval_keepsSharedStorage() {
      let dictionary = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<100).map { ($0, $0) })
      var copy = dictionary
      _ = copy.removeValue(forKey: -1)
      XCTAssertTrue(dictionary.isTriviallyIdentical(to: copy))

      let empty = RedBlackTreeDictionary<Int, Int>()
      var emptyCopy = empty
      _ = emptyCopy.removeValue(forKey: 0)
      XCTAssertTrue(empty.isTriviallyIdentical(to: emptyCopy))
    }

    /// 空でない共有中の木から空のIndex範囲（`i ..< i`）を消しても、ストレージをコピーしないこと（RBT-081）。
    func test_eraseEmptyIndexRange_keepsSharedStorage() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      var shared = original
      let i = shared.index(after: shared.startIndex)

      shared.erase(i ..< i)

      XCTAssertEqual(shared.map(\.value), ["a", "b", "c"])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "空のIndex範囲のeraseで木がコピーされた")
    }

    /// 共有中の空でない木に、何も消さない述語で`erase(where:)`しても、木をコピーしないこと。述語は各要素に1回ずつ順に呼ばれること（RBT-081/RBT-088）。
    func test_eraseWhere_nothingMatches_keepsSharedStorage() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      var shared = original
      var visited: [Int] = []

      shared.erase { visited.append($0.key); return false }

      XCTAssertEqual(visited, [1, 2, 3])
      XCTAssertEqual(shared.map(\.key), [1, 2, 3])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "何も消さないerase(where:)で木がコピーされた")
    }

    /// 共有中の木で`erase(where:)`が要素を消すときも、述語は各要素に1回ずつ順に呼ばれ、共有元は変わらないこと（RBT-088）。
    func test_eraseWhere_someMatch_callsPredicateOncePerElement() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d"]
      var shared = original
      var visited: [Int] = []

      shared.erase { visited.append($0.key); return $0.key % 2 == 0 }

      XCTAssertEqual(visited, [1, 2, 3, 4])
      XCTAssertEqual(shared.map(\.key), [1, 3])
      XCTAssertEqual(original.map(\.key), [1, 2, 3, 4])
    }

    /// 共有中の空でない木で、範囲内に何も一致しない述語の`erase(_:where:)`（IndexRange）をしても、木をコピーしないこと。述語は範囲内の各要素に1回ずつ順に呼ばれること（RBT-081）。
    func test_eraseIndexRangeWhere_nothingMatches_keepsSharedStorage() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      var shared = original
      let lo = shared.index(after: shared.startIndex)
      let hi = shared.index(lo, offsetBy: 3)
      var visited: [Int] = []

      shared.erase(lo ..< hi) { visited.append($0.key); return false }

      XCTAssertEqual(visited, [2, 3, 4])
      XCTAssertEqual(shared.map(\.key), [1, 2, 3, 4, 5])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "何も消さないerase(_:where:)で木がコピーされた")
    }

    /// 共有中の空でない木で、範囲内に何も一致しない述語の`erase(_:where:)`（IndexRangeExpression）をしても、木をコピーしないこと。述語は範囲内の各要素に1回ずつ順に呼ばれること（RBT-081）。
    func test_eraseIndexRangeExpressionWhere_nothingMatches_keepsSharedStorage() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      var shared = original
      let lo = shared.index(after: shared.startIndex)
      var visited: [Int] = []

      shared.erase(lo...) { visited.append($0.key); return false }

      XCTAssertEqual(visited, [2, 3, 4, 5])
      XCTAssertEqual(shared.map(\.key), [1, 2, 3, 4, 5])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "何も消さないerase(_:where:)で木がコピーされた")
    }

    /// `erase(where:)`が最初の一致より前で投げても、エラーをそのまま呼出元へ投げ、投げた後は述語を呼ばないこと。
    /// 共有していた元の辞書のkey/valueは変わらないこと。変更側の途中状態は、元の要素だけをキー順に持つことだけを確かめる（RBT-094）。
    func test_eraseWhere_throwsBeforeFirstMatch_keepsSharedOriginal() {
      struct StopError: Error, Equatable {}
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d"]
      var dictionary = original
      var visited: [Int] = []

      XCTAssertThrowsError(
        try dictionary.erase { element in
          visited.append(element.key)
          if element.key == 2 { throw StopError() }
          return false
        }
      ) { error in
        XCTAssertEqual(error as? StopError, StopError())
      }
      XCTAssertEqual(visited, [1, 2])
      XCTAssertEqual(original.map(\.key), [1, 2, 3, 4])
      XCTAssertEqual(original.map(\.value), ["a", "b", "c", "d"])
      XCTAssertEqual(dictionary.map(\.key), dictionary.map(\.key).sorted())
      XCTAssertTrue(dictionary.allSatisfy { original[$0.key] == $0.value })
    }

    /// 共有中の木で`erase(where:)`の述語がすべての要素に一致するとき、述語は各要素に1回ずつ順に呼ばれ、
    /// 辞書は空になり、共有元は変わらないこと（RBT-094）。
    func test_eraseWhere_allMatch_emptiesDictionaryAndKeepsSharedOriginal() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d"]
      var dictionary = original
      var visited: [Int] = []

      dictionary.erase { visited.append($0.key); return true }

      XCTAssertEqual(visited, [1, 2, 3, 4])
      XCTAssertTrue(dictionary.isEmpty)
      XCTAssertEqual(dictionary.startIndex, dictionary.endIndex)
      XCTAssertEqual(original.map(\.value), ["a", "b", "c", "d"])
    }

    /// `erase(_:where:)`（IndexRange）は述語のエラーをそのまま呼出元へ投げ、投げた後は述語を呼ばず、範囲外のkey/valueに触れないこと。
    /// 共有していた元の辞書は変わらないこと。変更側の途中状態は契約がないため、範囲外のエントリが残り、元のエントリだけをkey順に持つことだけを確かめる（RBT-094）。
    func test_eraseIndexRangeWhere_rethrowsPredicateErrorAndKeepsSharedOriginal() {
      struct StopError: Error, Equatable {}
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e", 6: "f"]
      var dictionary = original
      let lo = dictionary.index(after: dictionary.startIndex)
      let hi = dictionary.index(dictionary.startIndex, offsetBy: 5)
      var visited: [Int] = []

      XCTAssertThrowsError(
        try dictionary.erase(lo ..< hi) { element in
          visited.append(element.key)
          if element.key == 4 { throw StopError() }
          return element.key == 2
        }
      ) { error in
        XCTAssertEqual(error as? StopError, StopError())
      }
      XCTAssertEqual(visited, [2, 3, 4])
      XCTAssertEqual(original.map(\.value), ["a", "b", "c", "d", "e", "f"])
      XCTAssertEqual(dictionary[1], "a")
      XCTAssertEqual(dictionary[6], "f")
      XCTAssertEqual(dictionary.map(\.key), dictionary.map(\.key).sorted())
      XCTAssertTrue(dictionary.allSatisfy { original[$0.key] == $0.value })
    }

    /// 共有中の木で`erase(_:where:)`（IndexRange）の述語が範囲内のすべての要素に一致するとき、範囲だけが消え、共有元は変わらないこと（RBT-094）。
    func test_eraseIndexRangeWhere_allMatch_removesOnlyTheRange() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      var dictionary = original
      let lo = dictionary.index(after: dictionary.startIndex)
      let hi = dictionary.index(lo, offsetBy: 3)
      var visited: [Int] = []

      dictionary.erase(lo ..< hi) { visited.append($0.key); return true }

      XCTAssertEqual(visited, [2, 3, 4])
      XCTAssertEqual(dictionary.map(\.key), [1, 5])
      XCTAssertEqual(original.map(\.value), ["a", "b", "c", "d", "e"])
    }

    /// `erase(_:where:)`（IndexRangeExpression）は述語のエラーをそのまま呼出元へ投げ、投げた後は述語を呼ばず、範囲外のkey/valueに触れないこと。
    /// 共有していた元の辞書は変わらないこと。変更側の途中状態は契約がないため、範囲外のエントリが残り、元のエントリだけをkey順に持つことだけを確かめる（RBT-094）。
    func test_eraseIndexRangeExpressionWhere_rethrowsPredicateErrorAndKeepsSharedOriginal() {
      struct StopError: Error, Equatable {}
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      var dictionary = original
      let lo = dictionary.index(after: dictionary.startIndex)
      var visited: [Int] = []

      XCTAssertThrowsError(
        try dictionary.erase(lo...) { element in
          visited.append(element.key)
          if element.key == 4 { throw StopError() }
          return element.key == 2
        }
      ) { error in
        XCTAssertEqual(error as? StopError, StopError())
      }
      XCTAssertEqual(visited, [2, 3, 4])
      XCTAssertEqual(original.map(\.value), ["a", "b", "c", "d", "e"])
      XCTAssertEqual(dictionary[1], "a")
      XCTAssertEqual(dictionary.map(\.key), dictionary.map(\.key).sorted())
      XCTAssertTrue(dictionary.allSatisfy { original[$0.key] == $0.value })
    }

    /// 共有中の木で`erase(_:where:)`（IndexRangeExpression）の述語が範囲内のすべての要素に一致するとき、範囲だけが消え、共有元は変わらないこと（RBT-094）。
    func test_eraseIndexRangeExpressionWhere_allMatch_removesOnlyTheRange() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      var dictionary = original
      let lo = dictionary.index(after: dictionary.startIndex)
      var visited: [Int] = []

      dictionary.erase(lo...) { visited.append($0.key); return true }

      XCTAssertEqual(visited, [2, 3, 4, 5])
      XCTAssertEqual(dictionary.map(\.key), [1])
      XCTAssertEqual(original.map(\.value), ["a", "b", "c", "d", "e"])
    }

    #if _TREE_COPY_COUNTER
      /// 共有中の空でない木に`removeAll(keepingCapacity: true)`しても、木を全コピーせず、容量を保って空になり、共有元は変わらないこと（RBT-081 B2）。
      func test_removeAllKeepingCapacity_fromSharedTree_doesNotCopy() {
        let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
        var shared = original

        shared.removeAll(keepingCapacity: true)

        XCTAssertTrue(shared.isEmpty)
        XCTAssertGreaterThanOrEqual(shared.capacity, original.count)
        XCTAssertEqual(original.map(\.key), [1, 2, 3, 4, 5])
        XCTAssertEqual(shared._copyCount, 0, "removeAll(keepingCapacity: true)で木が全コピーされた")
      }
    #endif
  }
#endif
