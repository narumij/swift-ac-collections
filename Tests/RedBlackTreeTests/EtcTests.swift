// このファイル自体は整理整頓時に消さないこと
import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if !COMPATIBLE_ATCODER_2025 && DEBUG
  /// Test-only marker for sequences whose iteration order is ascending.
  private protocol SortedSequence: Sequence {}

  extension Range: SortedSequence where Self: Sequence {}
  extension ClosedRange: SortedSequence where Self: Sequence {}

  extension RedBlackTreeSet {
    fileprivate func union<S>(_ other: S) -> RedBlackTreeSet<Element>
    where S: SortedSequence, S.Element == Element {
      .init(__tree_: __tree_.___meld_unique(other))
    }
  }

  extension UnsafeTreeV2 {
    fileprivate mutating func ___copy_range<Iterator: IteratorProtocol>(
      _ iterator: inout Iterator,
      to parent: UnsafeMutablePointer<UnsafeNode>,
      _ child: UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
    ) where Iterator.Element == _PayloadValue {
      var (parent, child) = (parent, child)
      while let payload = iterator.next() {
        unsafeEnsureCapacity()
        (parent, child) = ___emplace_hint_right(parent, child, payload)
      }
    }

    fileprivate func ___meld_unique<S>(_ other: S) -> UnsafeTreeV2
    where S: SortedSequence, S.Element == _PayloadValue {
      var result: UnsafeTreeV2 =
        ._createWithNewBuffer(minimumCapacity: 2, nullptr: nullptr)
      var (parent, child) = result.___max_ref()
      var (first, last) = (__begin_node_, __end_node)
      var iterator = other.makeIterator()

      outer: while let payload = iterator.next() {
        while first != last {
          let value = __get_value(first)
          if value_comp(__key(payload), value) {
            result.unsafeEnsureCapacity()
            (parent, child) = result.___emplace_hint_right(parent, child, payload)
            continue outer
          }

          result.unsafeEnsureCapacity()
          (parent, child) = result.___emplace_hint_right(
            parent, child, Base.__payload_(first)
          )
          first = __tree_next_iter(first)
          if !value_comp(value, __key(payload)) {
            continue outer
          }
        }

        result.unsafeEnsureCapacity()
        (parent, child) = result.___emplace_hint_right(parent, child, payload)
        result.___copy_range(&iterator, to: parent, child)
        return result
      }

      result.___copy_range(first, last, to: parent, child)
      return result
    }
  }
#endif

/// 棚卸し用の雑多な検証置き場。
final class EtcTests: RedBlackTreeTestCase, _UnsafeNodePtrType {

  override func setUpWithError() throws {
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    try super.tearDownWithError()
  }

  #if !COMPATIBLE_ATCODER_2025
    // RBT-058: combineがthrowしても、countと実際に走査できる要素数は一致する。
    func testMergeSequenceThrowKeepsCountConsistent() {
      enum Stop: Error { case requested }
      var dictionary: RedBlackTreeDictionary<Int, Int> = [1: 10, 5: 50]

      XCTAssertThrowsError(try dictionary.merge([(1, 11), (3, 33)]) { _, _ in
        throw Stop.requested
      }) { error in
        XCTAssertTrue(error is Stop)
      }

      XCTAssertEqual(dictionary.count, dictionary.reduce(0) { count, _ in count + 1 })
      XCTAssertEqual(dictionary[1], 10)
      XCTAssertEqual(dictionary[5], 50)
    }

    func testMergeDictionaryThrowKeepsCountConsistent() {
      enum Stop: Error { case requested }
      var dictionary: RedBlackTreeDictionary<Int, Int> = [1: 10, 5: 50]
      let other: RedBlackTreeDictionary<Int, Int> = [1: 11, 3: 33]

      XCTAssertThrowsError(try dictionary.merge(other) { _, _ in
        throw Stop.requested
      }) { error in
        XCTAssertTrue(error is Stop)
      }

      XCTAssertEqual(dictionary.count, dictionary.reduce(0) { count, _ in count + 1 })
      XCTAssertEqual(dictionary[1], 10)
      XCTAssertEqual(dictionary[5], 50)
    }

    #if false
      // 以下、2026-11-07〜08のバグ探しで再現した不具合。各テストは正しい挙動を期待するので、修正前は失敗する。
      // 停止しない・解放済みメモリを読むものは、その旨を各テストに書いた。

      // merge失敗後、走査が存在しない要素を返し、等値比較も崩れる（RBT-058の続き）。
      func testMergeThrowLeavesNoPhantomElement() {
        enum Stop: Error { case requested }
        var dictionary: RedBlackTreeDictionary<Int, Int> = [1: 1, 2: 2, 3: 3]
        XCTAssertThrowsError(try dictionary.merge([(1, 10), (0, 0)]) { _, _ in
          throw Stop.requested
        })
        XCTAssertEqual(dictionary.sorted { $0.key < $1.key }.map(\.key), [1, 2, 3])
        XCTAssertEqual(dictionary, [1: 1, 2: 2, 3: 3])
      }

    #endif

      // 範囲ビューのerase(where:)でビューの先頭要素を消すと、残りがあってもビューが空になる。
      func testViewEraseWhereFirstElementKeepsRest() {
        let set = RedBlackTreeSet(0..<10)
        var view = set[set.lowerBound(3)..<set.lowerBound(8)]
        view.erase(where: { $0 == 3 })
        XCTAssertEqual(Array(view), [4, 5, 6, 7])
        XCTAssertEqual(view.count, 4)

        let dictionary = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
        var keyValue = dictionary[dictionary.lowerBound(3)..<dictionary.lowerBound(8)]
        keyValue.erase(where: { $0.key == 3 })
        XCTAssertEqual(keyValue.map(\.key), [4, 5, 6, 7])

        var values = dictionary[dictionary.lowerBound(3)..<dictionary.lowerBound(8)].values
        values.erase(where: { $0 == 30 })
        XCTAssertEqual(Array(values), [40, 50, 60, 70])

        let multiSet = RedBlackTreeMultiSet(0..<10)
        var multiView = multiSet[multiSet.lowerBound(3)..<multiSet.lowerBound(8)]
        multiView.erase(where: { $0 == 3 })
        XCTAssertEqual(Array(multiView), [4, 5, 6, 7])
      }

      // 範囲ビューをerase()やpopLast()で空にすると、isEmptyなのにstartIndex != endIndexになる。
      func testViewEmptiedByEraseOrPopLastHasEqualBounds() {
        let set = RedBlackTreeSet(0..<10)
        var erased = set[set.lowerBound(3)..<set.lowerBound(8)]
        _ = erased.erase()
        XCTAssertTrue(erased.isEmpty)
        XCTAssertEqual(erased.startIndex, erased.endIndex)

        var popped = set[set.lowerBound(3)..<set.lowerBound(4)]
        _ = popped.popLast()
        XCTAssertTrue(popped.isEmpty)
        XCTAssertEqual(popped.startIndex, popped.endIndex)
      }

    #if false  // RBT-063: 意味論の検討が必要なため、対応は後で行う。
      // 多重系の.lessThanOrEqual/.greaterThanOrEqualが同値の端ではなく途中の要素を指す。
      // findを__find_equal版にしている（unsafe_tree+find.swiftで保留中）ことの影響なので、findの扱いと合わせて判断する。
      func testMultiBoundsOrEqualReachEndsOfEqualRun() {
        let multiSet: RedBlackTreeMultiSet<Int> = [1, 5, 5, 5, 7]
        XCTAssertEqual(Array(multiSet[...(.lessThanOrEqual(5))]), [1, 5, 5, 5])
        XCTAssertEqual(Array(multiSet[(.greaterThanOrEqual(5))...]), [5, 5, 5, 7])
        var erased = multiSet
        _ = erased.erase(.lessThanOrEqual(5))
        XCTAssertEqual(Array(erased), [1, 5, 5, 7])  // 最後の5を消す

        var multiMap = RedBlackTreeMultiMap<Int, String>()
        multiMap.insert(key: 5, value: "a")
        multiMap.insert(key: 5, value: "b")
        multiMap.insert(key: 5, value: "c")
        XCTAssertEqual(multiMap[.lessThanOrEqual(5)]?.value, "c")
        XCTAssertEqual(multiMap[.greaterThanOrEqual(5)]?.value, "a")
      }

    #endif

      // 空の木の.lastはdocどおりpast-the-endに置き換わる。修正前はfatalErrorで止まる。
      func testEmptyLastBoundIsEnd() {
        let empty: RedBlackTreeSet<Int> = []
        XCTAssertEqual(empty.distance(from: .start, to: .last), 0)
      }

    #if false
      // LRUをmaxCount: 0で作って値を入れると、count == -1になる（ASanではheap-buffer-overflow）。
      func testLRUZeroMaxCountStaysEmpty() {
        var cache = ___LRUMemoizeStorage<Int, Int>(maxCount: 0)
        cache[1] = 1
        XCTAssertEqual(cache.count, 0)
        XCTAssertNil(cache[1])
      }

      // LRUのコピー側でgetしただけで、元の値の追い出し順が変わる。
      func testLRUGetOnCopyDoesNotAffectOriginal() {
        var original = ___LRUMemoizeStorage<Int, Int>(maxCount: 3)
        original[1] = 10
        original[2] = 20
        original[3] = 30
        var copy = original
        _ = copy[1]
        original[4] = 40  // originalだけなら1を追い出す
        original[5] = 50  // originalだけなら2を追い出す
        XCTAssertNil(original[1])
        XCTAssertNil(original[2])
        XCTAssertEqual(original[3], 30)
        XCTAssertEqual(original[4], 40)
        XCTAssertEqual(original[5], 50)
      }

    #endif

      // dict[k]?.mutatingが値をコピーしてから渡す。append を繰り返すと全体でO(n^2)になる。
      func testOptionalChainingModifyDoesNotCopyValue() {
        final class Ref {}
        struct Probe {
          var ref = Ref()
          mutating func isUnique() -> Bool { isKnownUniquelyReferenced(&ref) }
        }
        var dictionary: RedBlackTreeDictionary<Int, Probe> = [0: Probe()]
        XCTAssertEqual(dictionary[0]?.isUnique(), true)
      }

      // 何も消さない削除や空での削除でも、共有中のストレージを丸ごとコピーする（Swift.Setはコピーしない）。
      func testNoOpRemovalKeepsSharedStorage() {
        let set = RedBlackTreeSet(0..<100)
        var copy = set
        _ = copy.remove(-1)
        XCTAssertTrue(set.isTriviallyIdentical(to: copy))

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


      // 範囲ビューの.values経由の変更が、毎回木全体をコピーする（Dictionary/MultiMapのvaluesはself = Self()で回避している）。
      #if DEBUG  // バッファの同一性を@testableで見る
        func testRangeViewValuesModifyDoesNotCopyEachTime() {
          let dictionary = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<100).map { ($0, 0) })
          let indices = (0..<100).map { dictionary.index(forKey: $0)! }
          var view = dictionary[dictionary.startIndex..<dictionary.endIndex]
          view.values[indices[0]] += 1  // 1回目は共有を外すためのコピーが起きてよい
          // _copyCountは新しいヘッダで0から数え直すため、毎回のコピーを数えられない。バッファの同一性で見る。
          // ObjectIdentifierは参照を保持しないので、一意性を妨げない。
          var copies = 0
          for index in indices.dropFirst() {
            let before = ObjectIdentifier(view.__tree_._buffer.buffer)
            view.values[index] += 1
            if ObjectIdentifier(view.__tree_._buffer.buffer) != before { copies += 1 }
          }
          XCTAssertEqual(copies, 0, "一意になった後はコピーしないこと")
          XCTAssertEqual(Array(view.values), Array(repeating: 1, count: 100))
        }
      #endif

    #if false
      // removeAll(keepingCapacity: true)の前に取ったIndexが有効と判定され、解放済みの要素を読む（ASanでheap-use-after-free）。
      func testIndexBeforeRemoveAllKeepingCapacityIsInvalid() {
        var set: RedBlackTreeSet<Int> = [1]
        let index = set.startIndex
        set.removeAll(keepingCapacity: true)
        XCTAssertFalse(set.isElement(at: index))
      }

      // 空にした木をコピーしてから挿入すると、削除前のIndexが新しい要素に解決する。
      func testIndexOfRemovedElementStaysInvalidAfterCopyingEmptyTree() {
        var set: RedBlackTreeSet<Int> = [1]
        let index = set.startIndex
        set.remove(1)
        var copy = set
        copy.insert(2)
        XCTAssertFalse(copy.isElement(at: index))
      }

      // コピーして両方に挿入すると、片方のIndexがもう片方の別の要素に解決する。
      func testIndexFromDivergedCopyIsNotElementOfOther() {
        var a: RedBlackTreeSet<Int> = [1]
        var b = a
        a.insert(5)
        b.insert(7)
        let index = a.firstIndex(of: 5)!
        XCTAssertFalse(b.isElement(at: index))
      }

      // form系で木を作り直すと、前のIndexが同じ番号の新しいノードに解決する。
      func testIndexIsInvalidAfterFormUnionRebuild() {
        var set = RedBlackTreeSet([0, 2, 4])
        let index = set.firstIndex(of: 4)!
        set.formUnion(RedBlackTreeSet([1, 3]))
        if set.isElement(at: index) {
          XCTAssertEqual(set[index], 4)
        }
      }

      // init(minimumCapacity:)に負の値を渡すと、確保領域の外に書き込む（ASanでheap-buffer-overflow）。
      // Int.maxを渡すと確保サイズが桁あふれし、capacity == Int.maxのまま数十バイトしか確保しない（同じくASanで検出）。
      func testExtremeMinimumCapacity() {
        var negative = RedBlackTreeSet<Int>(minimumCapacity: -1)
        for value in 0..<20 { negative.insert(value) }
        XCTAssertEqual(Array(negative), Array(0..<20))

        var huge = RedBlackTreeDictionary<Int, Int>(minimumCapacity: Int.max)
        for key in 0..<100 { huge[key] = key }
        XCTAssertEqual(huge.count, 100)
      }

      // index(_:offsetBy:)に巨大な距離を渡すと、範囲の外に出たあとも|distance|回ループを続けて終わらない。
      func testIndexOffsetByHugeDistanceTerminates() {
        let set: RedBlackTreeSet<Int> = [1, 2, 3]
        XCTAssertNil(set.index(set.startIndex, offsetBy: Int.max, limitedBy: set.endIndex))
        XCTAssertNil(set.index(set.endIndex, offsetBy: Int.min, limitedBy: set.startIndex))
      }

      // .start.advanced(by: Int.max)をsubscriptに渡すと、nilを返さずに終わらない。
      func testBoundAdvancedByHugeOffsetTerminates() {
        let set: RedBlackTreeSet<Int> = [1, 2, 3]
        XCTAssertNil(set[.start.advanced(by: 4)])
        XCTAssertNil(set[.start.advanced(by: Int.max)])
      }

      // 解放済みの木のIndexをprintすると、ノードからtagを読む（ASanでheap-use-after-free。releaseでも読む）。
      func testDescribingIndexOfFreedTreeDoesNotReadFreedMemory() {
        func make() -> RedBlackTreeSet<Int>.Index {
          let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
          return set.firstIndex(of: 2)!
        }
        let index = make()
        XCTAssertFalse(String(describing: index).isEmpty)
      }

      // letで共有した木から複数スレッドが同時に最初のIndexを作ると、_lazyDetachの遅延生成が競合する。
      // releaseで同じ位置のIndex同士が一致しないことがある。TSanではdata raceとして報告される。
      func testConcurrentFirstIndexCreationAgrees() {
        nonisolated(unsafe) let indices = UnsafeMutablePointer<RedBlackTreeSet<Int>.Index?>
          .allocate(capacity: 2)
        indices.initialize(repeating: nil, count: 2)
        defer { indices.deinitialize(count: 2); indices.deallocate() }
        var mismatches = 0
        for trial in 0..<20_000 {
          var set = RedBlackTreeSet<Int>()
          set.insert(trial)
          let shared = set
          DispatchQueue.concurrentPerform(iterations: 2) { thread in
            indices[thread] = shared.startIndex
          }
          if indices[0]! != indices[1]! || indices[0]! != shared.startIndex { mismatches += 1 }
        }
        XCTAssertEqual(mismatches, 0)
      }
    #endif

    /// Zero movement succeeds even at the limit, including an empty collection's endIndex.
    func testIndexLimitedByZeroMovement() {
      func check<I: Equatable>(
        _ indices: [I],
        index offset: (I, Int, I) -> I?,
        formIndex: (inout I, Int, I) -> Bool
      ) {
        for index in indices {
          XCTAssertEqual(offset(index, 0, index), index)
          var current = index
          XCTAssertTrue(formIndex(&current, 0, index))
          XCTAssertEqual(current, index)
          XCTAssertNil(offset(index, 1, index))
          XCTAssertNil(offset(index, -1, index))
        }
      }
      for values in [[], [0, 1, 2]] {
        let set = RedBlackTreeSet(values)
        check([set.startIndex, set.endIndex],
          index: set.index(_:offsetBy:limitedBy:),
          formIndex: set.formIndex(_:offsetBy:limitedBy:))
        let multiSet = RedBlackTreeMultiSet(values)
        check([multiSet.startIndex, multiSet.endIndex],
          index: multiSet.index(_:offsetBy:limitedBy:),
          formIndex: multiSet.formIndex(_:offsetBy:limitedBy:))
        let dictionary = RedBlackTreeDictionary(keysWithValues: values.map { ($0, $0) })
        check([dictionary.startIndex, dictionary.endIndex],
          index: dictionary.index(_:offsetBy:limitedBy:),
          formIndex: dictionary.formIndex(_:offsetBy:limitedBy:))
        let multiMap = RedBlackTreeMultiMap(keysWithValues: values.map { ($0, $0) })
        check([multiMap.startIndex, multiMap.endIndex],
          index: multiMap.index(_:offsetBy:limitedBy:),
          formIndex: multiMap.formIndex(_:offsetBy:limitedBy:))
      }
    }

    /// `formIndex(_:offsetBy:limitedBy:)`が、現在の基準である`String`と同じく、
    /// limit到達時は成功し、超過時はlimitまで移動して失敗を返すこと。
    func testFormIndexLimitedByMatchesString() {
      let string = "abcd"
      let stringLimit = string.index(after: string.startIndex)

      var stringExact = string.startIndex
      XCTAssertTrue(string.formIndex(&stringExact, offsetBy: 1, limitedBy: stringLimit))
      XCTAssertEqual(stringExact, stringLimit)

      var stringOver = string.startIndex
      XCTAssertFalse(string.formIndex(&stringOver, offsetBy: 2, limitedBy: stringLimit))
      XCTAssertEqual(stringOver, stringLimit)

      let set = RedBlackTreeSet([0, 1, 2, 3])
      let setLimit = set.index(after: set.startIndex)

      var setExact = set.startIndex
      XCTAssertTrue(set.formIndex(&setExact, offsetBy: 1, limitedBy: setLimit))
      XCTAssertEqual(setExact, setLimit)

      var setOver = set.startIndex
      XCTAssertFalse(set.formIndex(&setOver, offsetBy: 2, limitedBy: setLimit))
      XCTAssertEqual(setOver, setLimit)
    }
  #endif

  #if !COMPATIBLE_ATCODER_2025 && DEBUG
    func testAPICheck() throws {

      do {
        let result = RedBlackTreeSet([1, 2]).union(0..<10)
        XCTAssertTrue(result.elementsEqual(0..<10), "\(result)")
      }

      do {
        let result = RedBlackTreeSet([1, 2]).union(0...10)
        XCTAssertTrue(result.elementsEqual(0...10), "\(result)")
      }
    }
  #endif

  #if DEBUG && !COMPATIBLE_ATCODER_2025
    /// 空配列をdecodeした場合、生木が共有の読み取り専用シングルトンになっていること
    /// (無駄なバッファ確保をしない。2026-10-03、Decodable非ソート・重複入力バグ修正の副次確認)
    func testDecodeEmptyArrayUsesReadOnlySingleton() throws {
      let decoder = JSONDecoder()
      let emptyJSON = "[]".data(using: .utf8)!

      let emptySet = try decoder.decode(RedBlackTreeSet<Int>.self, from: emptyJSON)
      XCTAssertTrue(emptySet.__tree_.isReadOnly)

      let emptyDict = try decoder.decode(RedBlackTreeDictionary<Int, String>.self, from: emptyJSON)
      XCTAssertTrue(emptyDict.__tree_.isReadOnly)

      let emptyMultiSet = try decoder.decode(RedBlackTreeMultiSet<Int>.self, from: emptyJSON)
      XCTAssertTrue(emptyMultiSet.__tree_.isReadOnly)

      let emptyMultiMap = try decoder.decode(RedBlackTreeMultiMap<Int, String>.self, from: emptyJSON)
      XCTAssertTrue(emptyMultiMap.__tree_.isReadOnly)
    }
  #endif

}

#if COMPATIBLE_ATCODER_2025 && DEBUG
  // これ、整理整頓対象でいいかも
  extension EtcTests {
    /// 内部の逆順走査ヘルパー___rev_for_each_が正しい順序でノードを列挙すること
    func testRev() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      var result = [Int]()
      a.__tree_.___rev_for_each_(__p: a.startIndex.sealed, __l: a.endIndex.sealed) { p in
        result.append(p.index)
      }
      XCTAssertEqual(result, [2, 1, 0])
    }
  }
#endif

// 並行CoWの試行テスト。採用判断まで無効化して保存する。
// 再実行するときはfalseを!DEBUGへ戻し、Releaseで実行する。
#if false
// Debugのprocess-globalな検査カウンタ自体が並行更新されるため、
// 製品のCoWを検証するこの試験はReleaseで実行する。
// 同じvarの同時変更ではなく、Sendableな値を各タスクへコピーして使う。
final class EtcConcurrentCopyTests: XCTestCase {
  func testSetConcurrentCopies() async {
    let original = RedBlackTreeSet(0 ..< 256)
    let results = await withTaskGroup(of: (Int, [Int]).self) { group in
      for worker in 0 ..< 8 {
        group.addTask { [original] in
          var copy = original
          for key in 0 ..< 128 {
            copy.remove(key)
            copy.insert(1000 + worker * 128 + key)
          }
          return (worker, Array(copy))
        }
      }
      var values: [(Int, [Int])] = []
      for await value in group { values.append(value) }
      return values
    }
    XCTAssertEqual(Array(original), Array(0 ..< 256))
    XCTAssertEqual(results.count, 8)
    for (worker, values) in results {
      XCTAssertEqual(
        values,
        Array(128 ..< 256)
          + Array((1000 + worker * 128) ..< (1128 + worker * 128))
      )
    }
  }

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
