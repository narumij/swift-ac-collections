import RedBlackTreeCollections
import XCTest

#if AC_COLLECTIONS_INTERNAL_CHECKS
  /// RBT-047（index指定更新の失敗時CoW調査）の専用テスト。
  ///
  /// `copyCount`はCoW複製でコピー先のheaderだけが1増える内部カウンタで、公開契約ではない。
  /// 共有中にnilで終わる更新が複製を起こすかを観察する。
  ///
  /// 通常suiteには現行で通るものだけを置く。「nilで終わる更新は複製しない」という期待は
  /// `RBT047_EXPECT_NO_COPY_ON_FAILURE`を定義したときだけ有効になり、現行コードでは失敗する。
  /// 再現手順は`Maintanance/Current/Evidence/RBT-047/`を参照。
  final class IndexUpdateFailureCoWInvestigationTests: RedBlackTreeTestCase {

    #if !COMPATIBLE_ATCODER_2025

      // MARK: - MultiSet.update(_:at:)

      func test_multiSetUpdate_sharedSuccess_copiesAndKeepsOriginal() {
        var a: RedBlackTreeMultiSet<Int> = [1, 2, 3]
        let b = a
        let before = a.__tree_.copyCount

        XCTAssertEqual(a.update(1, at: a.startIndex), 1)

        XCTAssertEqual(a.__tree_.copyCount, before + 1, "共有中の成功更新は1回複製する")
        XCTAssertEqual(b.__tree_.copyCount, before, "共有元は複製されない")
        XCTAssertEqual(Array(a), [1, 2, 3])
        XCTAssertEqual(Array(b), [1, 2, 3])
      }

      func test_multiSetUpdate_unsharedFailure_doesNotCopy() {
        var a: RedBlackTreeMultiSet<Int> = [1, 2, 3]
        let before = a.__tree_.copyCount

        XCTAssertNil(a.update(99, at: a.startIndex), "有効indexでも==不一致ならnil")
        XCTAssertNil(a.update(1, at: a.endIndex), "endIndexは契約上nil")

        XCTAssertEqual(a.__tree_.copyCount, before, "非共有ならnilでも複製しない")
        XCTAssertEqual(Array(a), [1, 2, 3])
      }

      #if RBT047_EXPECT_NO_COPY_ON_FAILURE
        func test_multiSetUpdate_sharedMismatch_doesNotCopy() {
          var a: RedBlackTreeMultiSet<Int> = [1, 2, 3]
          let b = a
          let before = a.__tree_.copyCount

          XCTAssertNil(a.update(99, at: a.startIndex))

          XCTAssertEqual(a.__tree_.copyCount, before, "==不一致でnilなら複製しないはず")
          XCTAssertEqual(Array(a), [1, 2, 3])
          XCTAssertEqual(Array(b), [1, 2, 3])
        }

        func test_multiSetUpdate_sharedEndIndex_doesNotCopy() {
          var a: RedBlackTreeMultiSet<Int> = [1, 2, 3]
          let b = a
          let before = a.__tree_.copyCount

          XCTAssertNil(a.update(1, at: a.endIndex))

          XCTAssertEqual(a.__tree_.copyCount, before, "endIndexでnilなら複製しないはず")
          XCTAssertEqual(Array(b), [1, 2, 3])
        }

        func test_multiSetUpdate_sharedRemovedIndex_doesNotCopy() {
          var a: RedBlackTreeMultiSet<Int> = [1, 1, 1]
          let removed = a.index(after: a.startIndex)
          a.remove(at: removed)
          let b = a
          let before = a.__tree_.copyCount

          XCTAssertNil(a.update(1, at: removed))

          XCTAssertEqual(a.__tree_.copyCount, before, "削除済みindexでnilなら複製しないはず")
          XCTAssertEqual(Array(a), [1, 1])
          XCTAssertEqual(Array(b), [1, 1])
        }
      #endif

      // MARK: - MultiMap.updateValue(_:at:) -> Value?

      func test_multiMapUpdateValue_sharedSuccess_copiesAndKeepsOriginal() {
        var a: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (1, "b")]
        let b = a
        let before = a.__tree_.copyCount

        XCTAssertEqual(a.updateValue("x", at: a.startIndex), "a")

        XCTAssertEqual(a.__tree_.copyCount, before + 1, "共有中の成功更新は1回複製する")
        XCTAssertEqual(a.map(\.value), ["x", "b"])
        XCTAssertEqual(b.map(\.value), ["a", "b"])
      }

      func test_multiMapUpdateValue_unsharedFailure_doesNotCopy() {
        var a: RedBlackTreeMultiMap<Int, String> = [(1, "a")]
        let before = a.__tree_.copyCount

        XCTAssertNil(a.updateValue("x", at: a.endIndex))

        XCTAssertEqual(a.__tree_.copyCount, before)
        XCTAssertEqual(a.map(\.value), ["a"])
      }

      #if RBT047_EXPECT_NO_COPY_ON_FAILURE
        func test_multiMapUpdateValue_sharedEndIndex_doesNotCopy() {
          var a: RedBlackTreeMultiMap<Int, String> = [(1, "a")]
          let b = a
          let before = a.__tree_.copyCount

          XCTAssertNil(a.updateValue("x", at: a.endIndex))

          XCTAssertEqual(a.__tree_.copyCount, before, "endIndexでnilなら複製しないはず")
          XCTAssertEqual(b.map(\.value), ["a"])
        }

        func test_multiMapUpdateValue_sharedRemovedIndex_doesNotCopy() {
          var a: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (1, "b")]
          let removed = a.startIndex
          a.remove(at: removed)
          let b = a
          let before = a.__tree_.copyCount

          XCTAssertNil(a.updateValue("x", at: removed))

          XCTAssertEqual(a.__tree_.copyCount, before, "削除済みindexでnilなら複製しないはず")
          XCTAssertEqual(b.map(\.value), ["b"])
        }
      #endif

    #else

      // MARK: - MultiMap.updateValue(_:at:) -> Element?（COMPATIBLE_ATCODER_2025）

      func test_compatMultiMapUpdateValue_sharedSuccess_copiesAndKeepsOriginal() {
        var a: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (1, "b")]
        let b = a
        let before = a.__tree_.copyCount

        XCTAssertEqual(a.updateValue("x", at: a.startIndex)?.value, "a")

        XCTAssertEqual(a.__tree_.copyCount, before + 1, "共有中の成功更新は1回複製する")
        XCTAssertEqual(a.map(\.value), ["x", "b"])
        XCTAssertEqual(b.map(\.value), ["a", "b"])
      }

      func test_compatMultiMapUpdateValue_unsharedFailure_doesNotCopy() {
        var a: RedBlackTreeMultiMap<Int, String> = [(1, "a")]
        let before = a.__tree_.copyCount

        XCTAssertNil(a.updateValue("x", at: a.endIndex))

        XCTAssertEqual(a.__tree_.copyCount, before)
      }

      #if RBT047_EXPECT_NO_COPY_ON_FAILURE
        func test_compatMultiMapUpdateValue_sharedEndIndex_doesNotCopy() {
          var a: RedBlackTreeMultiMap<Int, String> = [(1, "a")]
          let b = a
          let before = a.__tree_.copyCount

          XCTAssertNil(a.updateValue("x", at: a.endIndex))

          XCTAssertEqual(a.__tree_.copyCount, before, "endIndexでnilなら複製しないはず")
          XCTAssertEqual(b.map(\.value), ["a"])
        }
      #endif

    #endif
  }
#endif
