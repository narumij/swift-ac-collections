import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetRemovalTests: RedBlackTreeTestCase {

  func test_popFirstAndPopLast_removeOneExtremeMember() {
    var multiset = RedBlackTreeMultiSet([1, 1, 2, 3, 3])

    XCTAssertEqual(multiset.popFirst(), 1)
    #if !COMPATIBLE_ATCODER_2025
      XCTAssertEqual(multiset.popLast(), 3)
      XCTAssertEqual(Array(multiset), [1, 2, 3])
    #endif

    var empty = RedBlackTreeMultiSet<Int>()
    XCTAssertNil(empty.popFirst())
    #if !COMPATIBLE_ATCODER_2025
      XCTAssertNil(empty.popLast())
    #endif
  }

  /// 空集合への削除操作はトラップしない以上、無駄なCoW(共有される空シングルトン
  /// バッファからの退避)も発生させないこと。
  func test_popFirstAndPopLast_onEmptyMultiSet_doNotTriggerCopyOnWrite() {
    #if _TREE_COPY_COUNTER
      var empty = RedBlackTreeMultiSet<Int>()
      XCTAssertEqual(empty._copyCount, 0)

      XCTAssertNil(empty.popFirst())
      XCTAssertEqual(empty._copyCount, 0)

      #if !COMPATIBLE_ATCODER_2025
        XCTAssertNil(empty.popLast())
        XCTAssertEqual(empty._copyCount, 0)
      #endif

      empty.removeAll(keepingCapacity: true)
      XCTAssertEqual(empty._copyCount, 0, "空集合へのremoveAll(keepingCapacity: true)は退避コピーを発生させないはず")

      #if !COMPATIBLE_ATCODER_2025
        var predicateCalled = false
        empty.erase(where: { _ in
          predicateCalled = true
          return true
        })
        XCTAssertFalse(predicateCalled, "空のMultiSetへのerase(where:)は述語を呼ばないはず")
        XCTAssertEqual(empty._copyCount, 0, "空のMultiSetへのerase(where:)は退避コピーを発生させないはず")
      #endif
    #endif
  }

  func test_removeFirstAndRemoveLast_removeOneExtremeMember() {
    var multiset = RedBlackTreeMultiSet([1, 1, 2, 3, 3])

    XCTAssertEqual(multiset.removeFirst(), 1)
    XCTAssertEqual(multiset.removeLast(), 3)
    XCTAssertEqual(Array(multiset), [1, 2, 3])
  }

  #if !COMPATIBLE_ATCODER_2025
    func test_removeAt_removesOnlyTheSelectedDuplicate() {
      var multiset = RedBlackTreeMultiSet([1, 2, 2, 2, 3])
      let middleDuplicate = multiset.index(after: multiset.lowerBound(2))

      XCTAssertEqual(multiset.remove(at: middleDuplicate), 2)
      XCTAssertEqual(Array(multiset), [1, 2, 2, 3])
    }

    /// 共有状態で削除しても元を保ち、削除位置の次のIndexを返すこと（RBT-056）。
    func test_eraseIndex_preservesSharedOriginalAndReturnsSuccessor() {
      let expected = [1, 2, 2, 3]
      for offset in expected.indices {
        let original = RedBlackTreeMultiSet([1, 2, 2, 3])
        var copy = original
        let index = copy.index(copy.startIndex, offsetBy: offset)

        let next = copy.erase(index)

        var remaining = expected
        remaining.remove(at: offset)
        XCTAssertEqual(Array(original), expected)
        XCTAssertEqual(Array(copy), remaining)
        if offset == remaining.count {
          XCTAssertEqual(next, copy.endIndex)
        } else {
          XCTAssertEqual(copy[next], remaining[offset])
        }
      }
    }

    func test_erase_returnsTheFollowingIndex() {
      var multiset = RedBlackTreeMultiSet([1, 2, 2, 3])

      let next = multiset.erase(multiset.lowerBound(2))

      XCTAssertEqual(Array(multiset), [1, 2, 3])
      XCTAssertEqual(multiset[next], 2)
    }

    /// 同値だが別個体の参照が並ぶとき、remove(at:)は指定位置の個体そのものを取り除いて返し、
    /// erase(_:)は指定位置の個体を取り除いて直後の個体のIndexを返すこと。ほかの個体は残ること（RBT-043 M2）
    func test_removeAtAndErase_removeTheSelectedEquivalentInstance() {
      final class Member: Comparable {
        let key: Int
        init(_ key: Int) { self.key = key }
        static func == (lhs: Member, rhs: Member) -> Bool { lhs.key == rhs.key }
        static func < (lhs: Member, rhs: Member) -> Bool { lhs.key < rhs.key }
      }
      let first = Member(2)
      let middle = Member(2)
      let last = Member(2)

      var removing = RedBlackTreeMultiSet([first, middle, last])
      let removed = removing.remove(at: removing.index(after: removing.startIndex))
      XCTAssertTrue(removed === middle)
      let afterRemove = Array(removing)
      XCTAssertEqual(afterRemove.count, 2)
      XCTAssertTrue(afterRemove[0] === first)
      XCTAssertTrue(afterRemove[1] === last)

      var erasing = RedBlackTreeMultiSet([first, middle, last])
      let next = erasing.erase(erasing.index(after: erasing.startIndex))
      XCTAssertTrue(erasing[next] === last, "返されたIndexは削除した個体の直後の個体を指すこと")
      let afterErase = Array(erasing)
      XCTAssertEqual(afterErase.count, 2)
      XCTAssertTrue(afterErase[0] === first)
      XCTAssertTrue(afterErase[1] === last)
    }

    /// erase(where:) は述語のエラーをそのまま呼出元へ投げ、投げた後は述語を呼ばないこと。
    /// 等価な別個体を含む共有元は変わらないこと。変更側の途中状態は契約がないため、
    /// 元の個体だけを順序どおりに持つことだけを確かめる（RBT-043 M4）
    func test_eraseWhere_rethrowsPredicateErrorAndKeepsSharedOriginal() {
      final class Member: Comparable {
        let key: Int
        init(_ key: Int) { self.key = key }
        static func == (lhs: Member, rhs: Member) -> Bool { lhs.key == rhs.key }
        static func < (lhs: Member, rhs: Member) -> Bool { lhs.key < rhs.key }
      }
      struct StopError: Error, Equatable {}
      let members = [Member(1), Member(2), Member(2), Member(3)]
      let original = RedBlackTreeMultiSet(members)
      var multiset = original
      var visited: [Member] = []

      XCTAssertThrowsError(
        try multiset.erase { member in
          visited.append(member)
          if member === members[2] { throw StopError() }
          return member.key == 2
        }
      ) { error in
        XCTAssertEqual(error as? StopError, StopError())
      }
      XCTAssertEqual(visited.count, 3, "エラーの後は述語を呼ばないこと")
      XCTAssertTrue(zip(visited, members).allSatisfy { $0 === $1 })
      let preserved = Array(original)
      XCTAssertEqual(preserved.count, 4)
      XCTAssertTrue(zip(preserved, members).allSatisfy { $0 === $1 }, "共有元は同じ個体を同じ順序で保持すること")
      let remaining = Array(multiset)
      XCTAssertEqual(remaining.map(\.key), remaining.map(\.key).sorted())
      XCTAssertTrue(remaining.allSatisfy { member in members.contains { $0 === member } })
    }

    func test_eraseUnique_removesOneMatchingMember() {
      var multiset = RedBlackTreeMultiSet([1, 2, 2, 2, 3])

      XCTAssertTrue(multiset.eraseUnique(2))
      XCTAssertEqual(multiset.count(of: 2), 2)
      XCTAssertFalse(multiset.eraseUnique(4))
    }

    func test_eraseMulti_removesAllMatchingMembers() {
      var multiset = RedBlackTreeMultiSet([1, 2, 2, 2, 3])

      XCTAssertEqual(multiset.eraseMulti(2), 3)
      XCTAssertEqual(Array(multiset), [1, 3])
      XCTAssertEqual(multiset.eraseMulti(4), 0)
    }

    func test_eraseWhere_removesEveryMatchingMember() {
      var multiset = RedBlackTreeMultiSet([1, 2, 2, 3, 4, 4])

      multiset.erase { $0.isMultiple(of: 2) }

      XCTAssertEqual(Array(multiset), [1, 3])
    }

    func test_eraseMulti_handlesFullWidthIntValues() {
      var members: RedBlackTreeMultiSet = [Int.min, Int.min, Int.max, Int.max]

      XCTAssertEqual(members.count, 4)
      XCTAssertEqual(members.eraseMulti(Int.min), 2)
      XCTAssertEqual(members.count, 2)
      XCTAssertEqual(members.eraseMulti(Int.max), 2)
      XCTAssertEqual(members.count, 0)
    }

    func test_eraseUsingLowerAndUpperBound_removesOnlyThatDuplicateValue() {
      var multiset = RedBlackTreeMultiSet([0, 1, 2, 2, 3, 4])
      let lower = multiset.lowerBound(2)
      let upper = multiset.upperBound(2)

      _ = multiset.erase(lower..<upper)

      XCTAssertEqual(Array(multiset), [0, 1, 3, 4])
    }
  #endif

  func test_removeAll_clearsElementsAndHonorsCapacityChoice() {
    var keepingCapacity = RedBlackTreeMultiSet(0..<10)
    let originalCapacity = keepingCapacity.capacity
    keepingCapacity.removeAll(keepingCapacity: true)

    XCTAssertTrue(keepingCapacity.isEmpty)
    XCTAssertEqual(keepingCapacity.capacity, originalCapacity)

    var releasingCapacity = RedBlackTreeMultiSet(0..<10)
    releasingCapacity.removeAll()
    XCTAssertTrue(releasingCapacity.isEmpty)
  }

  /// popFirst/popLast/eraseMulti/removeAllが、保持していた参照型要素(重複を含む)を
  /// 正しく解放すること(二重解放やリークがないこと)
  func test_variousRemovalMethods_releaseRetainedReferenceElementsExactlyOnce() {
    final class DeinitializeCounter: Comparable {
      static func < (lhs: DeinitializeCounter, rhs: DeinitializeCounter) -> Bool {
        lhs.num < rhs.num
      }
      static func == (lhs: DeinitializeCounter, rhs: DeinitializeCounter) -> Bool {
        lhs.num == rhs.num
      }
      nonisolated(unsafe) static var count = 0
      let num: Int
      init(num: Int) {
        self.num = num
        Self.count += 1
      }
      deinit { Self.count -= 1 }
    }

    var multiset = RedBlackTreeMultiSet<DeinitializeCounter>(
      [1, 1, 2, 3, 3].map { DeinitializeCounter(num: $0) })
    XCTAssertEqual(DeinitializeCounter.count, 5)

    _ = multiset.popFirst()
    XCTAssertEqual(DeinitializeCounter.count, 4)

    #if !COMPATIBLE_ATCODER_2025
      _ = multiset.popLast()
      XCTAssertEqual(DeinitializeCounter.count, 3)
    #endif

    #if !COMPATIBLE_ATCODER_2025
      let erasedCount = multiset.eraseMulti(DeinitializeCounter(num: 3))
      XCTAssertEqual(erasedCount, 1)
      XCTAssertEqual(DeinitializeCounter.count, 2, "検索キー・削除された重複要素とも解放されること(残りは1,2の2個)")
    #endif

    multiset.removeAll()
    XCTAssertEqual(DeinitializeCounter.count, 0)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSetRemovalTests {
    /// 何も消さない削除や空での削除は、共有中のストレージをコピーしないこと（Swift.Setと同じ）。
    func test_noOpRemoval_keepsSharedStorage() {
      let multiSet = RedBlackTreeMultiSet(0..<100)
      var multiCopy = multiSet
      _ = multiCopy.eraseUnique(-1)
      _ = multiCopy.eraseMulti(-1)
      XCTAssertTrue(multiSet.isTriviallyIdentical(to: multiCopy))

      let empty = RedBlackTreeMultiSet<Int>()
      var emptyCopy = empty
      _ = emptyCopy.eraseUnique(0)
      _ = emptyCopy.eraseMulti(0)
      XCTAssertTrue(empty.isTriviallyIdentical(to: emptyCopy))
    }

    /// 空でない共有中の木から空のIndex範囲（`i ..< i`）を消しても、ストレージをコピーしないこと（RBT-081）。
    func test_eraseEmptyIndexRange_keepsSharedStorage() {
      let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3]
      var shared = original
      let i = shared.index(after: shared.startIndex)

      shared.erase(i ..< i)

      XCTAssertEqual(Array(shared), [1, 2, 2, 3])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "空のIndex範囲のeraseで木がコピーされた")
    }

    /// 共有中の空でない木に、何も消さない述語で`erase(where:)`しても、木をコピーしないこと。述語は各要素に1回ずつ順に呼ばれること（RBT-081/RBT-088）。
    func test_eraseWhere_nothingMatches_keepsSharedStorage() {
      let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3]
      var shared = original
      var visited: [Int] = []

      shared.erase { visited.append($0); return false }

      XCTAssertEqual(visited, [1, 2, 2, 3])
      XCTAssertEqual(Array(shared), [1, 2, 2, 3])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "何も消さないerase(where:)で木がコピーされた")
    }

    /// 共有中の木で`erase(where:)`が要素を消すときも、述語は各要素に1回ずつ順に呼ばれ、共有元は変わらないこと（RBT-088）。
    func test_eraseWhere_someMatch_callsPredicateOncePerElement() {
      let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3, 4]
      var shared = original
      var visited: [Int] = []

      shared.erase { visited.append($0); return $0 % 2 == 0 }

      XCTAssertEqual(visited, [1, 2, 2, 3, 4])
      XCTAssertEqual(Array(shared), [1, 3])
      XCTAssertEqual(Array(original), [1, 2, 2, 3, 4])
    }

    /// 共有中の空でない木で、範囲内に何も一致しない述語の`erase(_:where:)`（IndexRange）をしても、木をコピーしないこと。述語は範囲内の各要素に1回ずつ順に呼ばれること（RBT-081）。
    func test_eraseIndexRangeWhere_nothingMatches_keepsSharedStorage() {
      let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3, 4]
      var shared = original
      let lo = shared.index(after: shared.startIndex)
      let hi = shared.index(lo, offsetBy: 3)
      var visited: [Int] = []

      shared.erase(lo ..< hi) { visited.append($0); return false }

      XCTAssertEqual(visited, [2, 2, 3])
      XCTAssertEqual(Array(shared), [1, 2, 2, 3, 4])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "何も消さないerase(_:where:)で木がコピーされた")
    }

    /// 共有中の空でない木で、範囲内に何も一致しない述語の`erase(_:where:)`（IndexRangeExpression）をしても、木をコピーしないこと。述語は範囲内の各要素に1回ずつ順に呼ばれること（RBT-081）。
    func test_eraseIndexRangeExpressionWhere_nothingMatches_keepsSharedStorage() {
      let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3, 4]
      var shared = original
      let lo = shared.index(after: shared.startIndex)
      var visited: [Int] = []

      shared.erase(lo...) { visited.append($0); return false }

      XCTAssertEqual(visited, [2, 2, 3, 4])
      XCTAssertEqual(Array(shared), [1, 2, 2, 3, 4])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "何も消さないerase(_:where:)で木がコピーされた")
    }

    /// `erase(where:)`が最初の一致より前で投げても、エラーをそのまま呼出元へ投げ、投げた後は述語を呼ばないこと。
    /// 共有していた元のMultiSetは変わらないこと。変更側の途中状態は契約がないため、元の要素だけを昇順で持つことだけを確かめる（RBT-094）。
    func test_eraseWhere_throwsBeforeFirstMatch_keepsSharedOriginal() {
      struct StopError: Error, Equatable {}
      let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3]
      var multiset = original
      var visited: [Int] = []

      XCTAssertThrowsError(
        try multiset.erase { element in
          visited.append(element)
          if element == 2 { throw StopError() }
          return false
        }
      ) { error in
        XCTAssertEqual(error as? StopError, StopError())
      }
      XCTAssertEqual(visited, [1, 2])
      XCTAssertEqual(Array(original), [1, 2, 2, 3])
      XCTAssertEqual(Array(multiset), Array(multiset).sorted())
      XCTAssertTrue(multiset.allSatisfy { original.contains($0) })
    }

    /// 共有中の木で`erase(where:)`の述語がすべての要素に一致するとき、述語は各要素に1回ずつ順に呼ばれ、
    /// MultiSetは空になり、共有元は変わらないこと（RBT-094）。
    func test_eraseWhere_allMatch_emptiesMultiSetAndKeepsSharedOriginal() {
      let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3]
      var multiset = original
      var visited: [Int] = []

      multiset.erase { visited.append($0); return true }

      XCTAssertEqual(visited, [1, 2, 2, 3])
      XCTAssertTrue(multiset.isEmpty)
      XCTAssertEqual(multiset.startIndex, multiset.endIndex)
      XCTAssertEqual(Array(original), [1, 2, 2, 3])
    }

    /// `erase(_:where:)`（IndexRange）は述語のエラーをそのまま呼出元へ投げ、投げた後は述語を呼ばず、範囲外の要素に触れないこと。
    /// 共有していた元のMultiSetは変わらないこと。変更側の途中状態は契約がないため、範囲外の要素が残り、元の要素だけを昇順で持つことだけを確かめる（RBT-094）。
    func test_eraseIndexRangeWhere_rethrowsPredicateErrorAndKeepsSharedOriginal() {
      struct StopError: Error, Equatable {}
      let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3, 4, 5]
      var multiset = original
      let lo = multiset.index(after: multiset.startIndex)
      let hi = multiset.index(multiset.startIndex, offsetBy: 5)
      var visited: [Int] = []

      XCTAssertThrowsError(
        try multiset.erase(lo ..< hi) { element in
          visited.append(element)
          if element == 3 { throw StopError() }
          return element == 2
        }
      ) { error in
        XCTAssertEqual(error as? StopError, StopError())
      }
      XCTAssertEqual(visited, [2, 2, 3])
      XCTAssertEqual(Array(original), [1, 2, 2, 3, 4, 5])
      XCTAssertTrue(multiset.contains(1))
      XCTAssertTrue(multiset.contains(5))
      XCTAssertEqual(Array(multiset), Array(multiset).sorted())
      XCTAssertTrue(multiset.allSatisfy { original.contains($0) })
    }

    /// 共有中の木で`erase(_:where:)`（IndexRange）の述語が範囲内のすべての要素に一致するとき、範囲だけが消え、共有元は変わらないこと（RBT-094）。
    func test_eraseIndexRangeWhere_allMatch_removesOnlyTheRange() {
      let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3, 4]
      var multiset = original
      let lo = multiset.index(after: multiset.startIndex)
      let hi = multiset.index(lo, offsetBy: 3)
      var visited: [Int] = []

      multiset.erase(lo ..< hi) { visited.append($0); return true }

      XCTAssertEqual(visited, [2, 2, 3])
      XCTAssertEqual(Array(multiset), [1, 4])
      XCTAssertEqual(Array(original), [1, 2, 2, 3, 4])
    }

    /// `erase(_:where:)`（IndexRangeExpression）は述語のエラーをそのまま呼出元へ投げ、投げた後は述語を呼ばず、範囲外の要素に触れないこと。
    /// 共有していた元のMultiSetは変わらないこと。変更側の途中状態は契約がないため、範囲外の要素が残り、元の要素だけを昇順で持つことだけを確かめる（RBT-094）。
    func test_eraseIndexRangeExpressionWhere_rethrowsPredicateErrorAndKeepsSharedOriginal() {
      struct StopError: Error, Equatable {}
      let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3, 4]
      var multiset = original
      let lo = multiset.index(after: multiset.startIndex)
      var visited: [Int] = []

      XCTAssertThrowsError(
        try multiset.erase(lo...) { element in
          visited.append(element)
          if element == 3 { throw StopError() }
          return element == 2
        }
      ) { error in
        XCTAssertEqual(error as? StopError, StopError())
      }
      XCTAssertEqual(visited, [2, 2, 3])
      XCTAssertEqual(Array(original), [1, 2, 2, 3, 4])
      XCTAssertTrue(multiset.contains(1))
      XCTAssertEqual(Array(multiset), Array(multiset).sorted())
      XCTAssertTrue(multiset.allSatisfy { original.contains($0) })
    }

    /// 共有中の木で`erase(_:where:)`（IndexRangeExpression）の述語が範囲内のすべての要素に一致するとき、範囲だけが消え、共有元は変わらないこと（RBT-094）。
    func test_eraseIndexRangeExpressionWhere_allMatch_removesOnlyTheRange() {
      let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3, 4]
      var multiset = original
      let lo = multiset.index(after: multiset.startIndex)
      var visited: [Int] = []

      multiset.erase(lo...) { visited.append($0); return true }

      XCTAssertEqual(visited, [2, 2, 3, 4])
      XCTAssertEqual(Array(multiset), [1])
      XCTAssertEqual(Array(original), [1, 2, 2, 3, 4])
    }

    #if _TREE_COPY_COUNTER
      /// 共有中の空でない木に`removeAll(keepingCapacity: true)`しても、木を全コピーせず、容量を保って空になり、共有元は変わらないこと（RBT-081 B2）。
      func test_removeAllKeepingCapacity_fromSharedTree_doesNotCopy() {
        let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3, 4]
        var shared = original

        shared.removeAll(keepingCapacity: true)

        XCTAssertTrue(shared.isEmpty)
        XCTAssertGreaterThanOrEqual(shared.capacity, original.count)
        XCTAssertEqual(Array(original), [1, 2, 2, 3, 4])
        XCTAssertEqual(shared._copyCount, 0, "removeAll(keepingCapacity: true)で木が全コピーされた")
      }
    #endif

    /// 容量の確認に使う木の形。予約した木・挿入で育った木・削除で疎になった木を、呼ぶたびに新しく作る。
    private func removeAllKeepingCapacityShapes() -> [(String, () -> RedBlackTreeMultiSet<Int>)] {
      [
        ("reserved", {
          var multiset = RedBlackTreeMultiSet<Int>(minimumCapacity: 100)
          for i in 0 ..< 5 { multiset.insert(i) }
          return multiset
        }),
        ("grown", {
          var multiset = RedBlackTreeMultiSet<Int>()
          for i in 0 ..< 1000 { multiset.insert(i / 2) }
          return multiset
        }),
        ("sparse", {
          var multiset = RedBlackTreeMultiSet<Int>(0 ..< 1000)
          multiset.erase { $0 % 10 != 0 }
          return multiset
        }),
      ]
    }

    /// 共有中の木に`removeAll(keepingCapacity: true)`すると、空になり、容量は変更前を下回らないこと。
    /// 共有元の中身と容量は変わらないこと（RBT-095/RBT-096）。
    func test_removeAllKeepingCapacity_onSharedTree_keepsCapacityAndOriginal() {
      for (name, make) in removeAllKeepingCapacityShapes() {
        let original = make()
        let contents = Array(original)
        let capacity = original.capacity
        var shared = original

        shared.removeAll(keepingCapacity: true)

        XCTAssertTrue(shared.isEmpty, name)
        XCTAssertGreaterThanOrEqual(shared.capacity, capacity, name)
        XCTAssertEqual(Array(original), contents, name)
        XCTAssertEqual(original.capacity, capacity, name)
      }
    }

    /// 他に参照のない木に`removeAll(keepingCapacity: true)`すると、空になり、容量は変更前と同じであること。
    /// 一意性は、作った値をそのまま変数に受ける構成で担保する（RBT-095/RBT-096）。
    func test_removeAllKeepingCapacity_onUniqueTree_keepsCapacity() {
      for (name, make) in removeAllKeepingCapacityShapes() {
        var unique = make()
        let capacity = unique.capacity

        unique.removeAll(keepingCapacity: true)

        XCTAssertTrue(unique.isEmpty, name)
        XCTAssertEqual(unique.capacity, capacity, name)
      }
    }
  }
#endif
