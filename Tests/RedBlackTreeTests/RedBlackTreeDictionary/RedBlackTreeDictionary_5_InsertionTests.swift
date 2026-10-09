import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryInsertionTests: RedBlackTreeTestCase {

  func test_keySubscript_insertsUpdatesAndRemovesValues() {
    var dictionary = RedBlackTreeDictionary<Int, String>()

    dictionary[2] = "two"
    dictionary[2] = "updated"
    XCTAssertEqual(dictionary[2], "updated")

    dictionary[2] = nil
    XCTAssertNil(dictionary[2])
    XCTAssertTrue(dictionary.isEmpty)
  }

  func test_keySubscript_assigningNilToMissingKeyIsANoOp() {
    var dictionary: RedBlackTreeDictionary<Int, String> = [1: "one"]

    dictionary[999] = nil

    XCTAssertNil(dictionary[999])
    XCTAssertEqual(dictionary.count, 1)
    XCTAssertEqual(dictionary[1], "one")
  }

  func test_defaultSubscript_doesNotInsertUntilMutated() {
    var dictionary = RedBlackTreeDictionary<Int, [String]>()

    XCTAssertEqual(dictionary[1, default: []], [])
    XCTAssertNil(dictionary[1])

    dictionary[1, default: []].append("one")
    dictionary[1, default: []].append("another")
    XCTAssertEqual(dictionary[1], ["one", "another"])
  }

  /// デフォルト値付きsubscriptの`_modify`が、挿入に伴う二重ローテーション後も
  /// 新しく挿入したノードの値をyieldすることを確認する。
  ///
  /// キー3、1の順で作った木へキー2を挿入すると、挿入直前の形は次のようになる。
  ///
  /// ```
  ///     3
  ///    /
  ///   1
  ///    \
  ///     2  <- 挿入ノード
  /// ```
  ///
  /// キー2を探索した`__find_equal`が返す`__child`は、ノード1が所有する右子の
  /// ポインタを指している。挿入直後にはその`pointee`がノード2になるものの、
  /// 赤黒木を修復するためにノード1で左回転、続いてノード3で右回転が行われる。
  /// 修復後の木は次の形になる。
  ///
  /// ```
  ///     2
  ///    / \
  ///   1   3
  /// ```
  ///
  /// このとき、探索時に保存した`__child`自体は引き続き「ノード1の右子」を指すが、
  /// ローテーションによってそのスロットの`pointee`はnullへ書き換えられている。
  /// したがって挿入後に`__child.pointee`からmapped valueを取得すると、ノード2では
  /// ない場所をyieldしてしまい、`+= 1`が挿入済みの値へ反映されない。
  ///
  /// 挿入ノードのポインタはローテーション前に退避し、修復後もそのポインタを使って
  /// mapped valueをyieldする必要がある。
  func test_defaultSubscript_returnsInsertedValueAfterDoubleRotation() {
    var dictionary: RedBlackTreeDictionary<Int, Int> = [3: 30, 1: 10]

    dictionary[2, default: 0] += 1

    XCTAssertEqual(dictionary[2], 1)
    XCTAssertEqual(dictionary.map(\.key), [1, 2, 3])
  }

  /// 上の再現ケースを左右反転したケース。キー2の探索で得た`__child`はノード3の
  /// 左子スロットを指すが、ノード3での右回転とノード1での左回転によって、その
  /// スロットもnullへ書き換えられる。片側の回転だけを考慮した修正を検出する。
  func test_defaultSubscript_noHitModify_yieldsInsertedValueAfterRightLeftDoubleRotation() {
    var dictionary: RedBlackTreeDictionary<Int, Int> = [1: 10, 3: 30]

    dictionary[2, default: 0] += 1

    XCTAssertEqual(dictionary[2], 1)
    XCTAssertEqual(dictionary.map(\.key), [1, 2, 3])
  }

  /// 未登録キーを左外側へ挿入して右単回転が発生するケース。二重回転だけに特化せず、
  /// no-hitから構築したノードを`_modify`が一貫してyieldすることを確認する。
  func test_defaultSubscript_noHitModify_yieldsInsertedValueAfterRightRotation() {
    var dictionary: RedBlackTreeDictionary<Int, Int> = [3: 30, 2: 20]

    dictionary[1, default: 0] += 1

    XCTAssertEqual(dictionary[1], 1)
    XCTAssertEqual(dictionary.map(\.key), [1, 2, 3])
  }

  /// 右単回転の左右対称となる左単回転のケース。左右どちらの挿入経路でも、探索時の
  /// childスロットではなく、実際に構築したノードを更新していることを保証する。
  func test_defaultSubscript_noHitModify_yieldsInsertedValueAfterLeftRotation() {
    var dictionary: RedBlackTreeDictionary<Int, Int> = [1: 10, 2: 20]

    dictionary[3, default: 0] += 1

    XCTAssertEqual(dictionary[3], 1)
    XCTAssertEqual(dictionary.map(\.key), [1, 2, 3])
  }

  func test_insert_returnsInsertedFlagAndExistingMemberOnDuplicate() {
    var dictionary = RedBlackTreeDictionary<Int, Int>()

    let first = dictionary.insert((3, 10))
    XCTAssertTrue(first.inserted)
    XCTAssertEqual(first.memberAfterInsert.key, 3)
    XCTAssertEqual(first.memberAfterInsert.value, 10)
    XCTAssertEqual(dictionary[3], 10)

    let duplicate = dictionary.insert((3, 20))
    XCTAssertFalse(duplicate.inserted)
    XCTAssertEqual(duplicate.memberAfterInsert.value, 10)
    XCTAssertEqual(dictionary[3], 10)
  }

  func test_insertKeyValue_returnsInsertedFlagAndExistingMemberOnDuplicate() {
    var dictionary = RedBlackTreeDictionary<Int, Int>()

    let first = dictionary.insert(key: 3, value: 10)
    XCTAssertTrue(first.inserted)
    XCTAssertEqual(first.memberAfterInsert.value, 10)

    let duplicate = dictionary.insert(key: 3, value: 20)
    XCTAssertFalse(duplicate.inserted)
    XCTAssertEqual(duplicate.memberAfterInsert.value, 10)
    XCTAssertEqual(dictionary[3], 10)
  }

    func test_insertWithHint_insertsRegardlessOfHintAccuracyAndRejectsDuplicateKey() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "one", 3: "three"]

      let goodHint = dictionary.firstIndex(of: 3)!
      let insertedWithGoodHint = dictionary.insert((2, "two"), hint: goodHint)
      XCTAssertTrue(insertedWithGoodHint.inserted)
      XCTAssertEqual(dictionary[insertedWithGoodHint.indexAfterInsert].key, 2)

      let insertedWithBadHint = dictionary.insert((4, "four"), hint: dictionary.startIndex)
      XCTAssertTrue(insertedWithBadHint.inserted)
      XCTAssertEqual(dictionary[insertedWithBadHint.indexAfterInsert].key, 4)

      let duplicate = dictionary.insert((2, "replacement"), hint: dictionary.endIndex)
      XCTAssertFalse(duplicate.inserted)
      XCTAssertEqual(dictionary[2], "two")
      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3, 4])
    }

    /// ヒント付きupdateが新規キーではnilを返し、既存キーでは旧エントリを返して値を置き換えること
    func test_updateWithHint_returnsNilForNewKeyAndOldEntryForExistingKey() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "one", 3: "three"]

      let insertedWithGoodHint = dictionary.update((2, "two"), hint: dictionary.firstIndex(of: 3)!)
      XCTAssertNil(insertedWithGoodHint)
      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3])

      let insertedWithBadHint = dictionary.update((4, "four"), hint: dictionary.startIndex)
      XCTAssertNil(insertedWithBadHint)
      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3, 4])

      let replaced = dictionary.update((2, "replacement"), hint: dictionary.endIndex)
      XCTAssertEqual(replaced?.key, 2)
      XCTAssertEqual(replaced?.value, "two")
      XCTAssertEqual(dictionary[2], "replacement")
      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3, 4])
    }

    /// `insert(key:value:hint:)`が、`insert(_:hint:)`(タプル版)と同じ結果
    /// (新規キーでの挿入成功・重複キーでの拒否)になること
    func test_insertWithKeyValueHint_matchesTupleHintBehavior() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "one", 3: "three"]

      let insertedWithGoodHint = dictionary.insert(
        key: 2, value: "two", hint: dictionary.firstIndex(of: 3)!)
      XCTAssertTrue(insertedWithGoodHint.inserted)
      XCTAssertEqual(dictionary[insertedWithGoodHint.indexAfterInsert].key, 2)

      let insertedWithBadHint = dictionary.insert(
        key: 4, value: "four", hint: dictionary.startIndex)
      XCTAssertTrue(insertedWithBadHint.inserted)
      XCTAssertEqual(dictionary[insertedWithBadHint.indexAfterInsert].key, 4)

      let duplicate = dictionary.insert(
        key: 2, value: "replacement", hint: dictionary.endIndex)
      XCTAssertFalse(duplicate.inserted)
      XCTAssertEqual(dictionary[2], "two")
      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3, 4])
    }

    /// `updateValue(_:forKey:hint:)`が、新規キーでは`nil`を返し、既存キーでは
    /// 旧値を返して値を置き換えること
    func test_updateValueWithHint_returnsNilForNewKeyAndOldValueForExistingKey() {
      var dictionary: RedBlackTreeDictionary<Int, String> = [1: "one", 3: "three"]

      let insertedWithGoodHint = dictionary.updateValue(
        "two", forKey: 2, hint: dictionary.firstIndex(of: 3)!)
      XCTAssertNil(insertedWithGoodHint)
      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3])

      let insertedWithBadHint = dictionary.updateValue(
        "four", forKey: 4, hint: dictionary.startIndex)
      XCTAssertNil(insertedWithBadHint)
      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3, 4])

      let replaced = dictionary.updateValue(
        "replacement", forKey: 2, hint: dictionary.endIndex)
      XCTAssertEqual(replaced, "two")
      XCTAssertEqual(dictionary[2], "replacement")
      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3, 4])
    }

  func test_updateValue_returnsTheReplacedValue() {
    var dictionary: RedBlackTreeDictionary<Int, String> = [1: "old"]

    XCTAssertEqual(dictionary.updateValue("new", forKey: 1), "old")
    XCTAssertNil(dictionary.updateValue("two", forKey: 2))

    XCTAssertEqual(dictionary[1], "new")
    XCTAssertEqual(dictionary[2], "two")
  }

  func test_merge_combinesDuplicateKeysAndInsertsNewKeys() {
    var dictionary: RedBlackTreeDictionary<String, Int> = ["a": 1, "b": 2]

    dictionary.merge([("b", 10), ("c", 3)]) { old, new in old + new }

    XCTAssertEqual(dictionary["a"], 1)
    XCTAssertEqual(dictionary["b"], 12)
    XCTAssertEqual(dictionary["c"], 3)
  }

  func test_merge_fromAnotherDictionary_combinesDuplicateKeysAndInsertsNewKeys() {
    var dictionary: RedBlackTreeDictionary<String, Int> = ["a": 1, "b": 2]
    let other: RedBlackTreeDictionary<String, Int> = ["b": 10, "c": 3]

    dictionary.merge(other) { old, new in old + new }

    XCTAssertEqual(dictionary["a"], 1)
    XCTAssertEqual(dictionary["b"], 12)
    XCTAssertEqual(dictionary["c"], 3)
    XCTAssertEqual(other["b"], 10)
  }

  func test_merging_returnsChangedCopyAndPreservesOriginal() {
    let original: RedBlackTreeDictionary<String, Int> = ["a": 1, "b": 2]

    let result = original.merging([("b", 10), ("c", 3)]) { _, new in new }

    XCTAssertEqual(original["b"], 2)
    XCTAssertNil(original["c"])
    XCTAssertEqual(result["b"], 10)
    XCTAssertEqual(result["c"], 3)
  }

  #if ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH
    /// 新しいキーへの`index(inserting:)`は挿入し、`inserted`は`true`、`index`は
    /// 挿入した要素を指すこと。
    func test_indexInserting_insertsNewKey() {
      var dictionary: RedBlackTreeDictionary = ["a": 1]

      let result = dictionary.index(inserting: ("b", 2))

      XCTAssertTrue(result.inserted)
      XCTAssertEqual(dictionary[result.index].key, "b")
      XCTAssertEqual(dictionary[result.index].value, 2)
      XCTAssertEqual(dictionary.count, 2)
    }

    /// 既存キーへの`index(inserting:)`は既存の値を置き換えず、`inserted`は`false`、
    /// `index`は既存の要素を指すこと。
    func test_indexInserting_existingKeyKeepsValueAndReturnsExistingIndex() {
      var dictionary: RedBlackTreeDictionary = ["a": 1, "b": 2]
      let existing = dictionary.index(forKey: "b")!

      let result = dictionary.index(inserting: ("b", 20))

      XCTAssertFalse(result.inserted)
      XCTAssertEqual(result.index, existing)
      XCTAssertEqual(dictionary["b"], 2, "既存の値は置き換えないはず")
      XCTAssertEqual(dictionary.count, 2)
    }

    /// `erase(exactly:)`は、Indexが指す要素を削除し、後続のIndexを返すこと。
    func test_eraseExactly_removesIndexedElementAndReturnsSuccessor() {
      var dictionary: RedBlackTreeDictionary = ["a": 1, "b": 2, "c": 3]
      let index = dictionary.index(forKey: "b")!

      let successor = dictionary.erase(exactly: index)

      XCTAssertEqual(successor, dictionary.index(forKey: "c"))
      XCTAssertNil(dictionary["b"])
      XCTAssertEqual(dictionary.map(\.key), ["a", "c"])
    }

    /// 削除済みのIndexや`endIndex`に対する`erase(exactly:)`は、何も削除せず`nil`を返すこと。
    func test_eraseExactly_returnsNilForStaleOrEndIndex() {
      var dictionary: RedBlackTreeDictionary = ["a": 1, "b": 2, "c": 3]
      let index = dictionary.index(forKey: "b")!
      XCTAssertNotNil(dictionary.erase(exactly: index))

      XCTAssertNil(dictionary.erase(exactly: index))
      XCTAssertNil(dictionary.erase(exactly: dictionary.endIndex))
      XCTAssertEqual(dictionary.map(\.key), ["a", "c"])
    }

    /// 空のDictionaryに対して`erase(exactly:)`を呼んでもトラップせず、`nil`を返すこと。
    /// トラップしない以上、無駄なCoW(共有される空シングルトンバッファからの退避)も
    /// 発生しないこと。
    func test_eraseExactly_onEmptyDictionaryReturnsNilWithoutCopy() {
      var dictionary = RedBlackTreeDictionary<String, Int>()

      #if AC_COLLECTIONS_INTERNAL_CHECKS
        XCTAssertEqual(dictionary._copyCount, 0)
      #endif
      XCTAssertNil(dictionary.erase(exactly: dictionary.startIndex))
      #if AC_COLLECTIONS_INTERNAL_CHECKS
        XCTAssertEqual(dictionary._copyCount, 0, "空の削除はnilを返すだけで、バッファのコピーを発生させないはず")
      #endif
      XCTAssertNil(dictionary.erase(exactly: dictionary.endIndex))
    }
  #endif
}

  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeDictionaryMergingTests: RedBlackTreeTestCase {

    /// `merging(_:uniquingKeysWith:)`は重複キーを`combine`でまとめた新しい辞書を返し、入力を変えないこと。
    func testMergingCombinesDuplicateKeys() {
      let a: RedBlackTreeDictionary = [1: "a", 2: "b"]
      let b: RedBlackTreeDictionary = [2: "x", 3: "c"]
      let merged = a.merging(b) { $0 + $1 }
      XCTAssertEqual(merged.map(\.key), [1, 2, 3])
      XCTAssertEqual(merged.map(\.value), ["a", "bx", "c"])
      XCTAssertEqual(a.map(\.value), ["a", "b"])
      XCTAssertEqual(b.map(\.value), ["x", "c"])
    }
  }
