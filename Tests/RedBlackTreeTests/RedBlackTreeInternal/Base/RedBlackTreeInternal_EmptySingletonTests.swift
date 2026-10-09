import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if DEBUG
  /// `RedBlackTreeSet`/`MultiSet`/`Dictionary`/`MultiMap`の4型が共有する、空コレクション用の
  /// シングルトンバッファ(`_emptyTreeStorage`、型消去済みで容量0)の生成・コピー・detach・復帰条件
  /// をまとめて検証する。これらはpublicな保証ではなく内部のアロケーション契約であり、ポインタ同一性
  /// 自体を外部仕様として扱わない。詳細は`Design-CopyOnWrite.md`/`Design-NodeStorage.md`、
  /// 要約は`Tests/TESTING.md`を参照。
  final class RedBlackTreeInternal_EmptySingletonTests: RedBlackTreeTestCase {

    private func assertIsSingleton<Base: ___TreeBase>(
      _ tree: UnsafeTreeV2<Base>, _ message: String = "",
      file: StaticString = #filePath, line: UInt = #line
    ) {
      XCTAssertTrue(tree.isReadOnly, message, file: file, line: line)
    }

    private func assertNotSingleton<Base: ___TreeBase>(
      _ tree: UnsafeTreeV2<Base>, _ message: String = "",
      file: StaticString = #filePath, line: UInt = #line
    ) {
      XCTAssertFalse(tree.isReadOnly, message, file: file, line: line)
    }

    // MARK: - Set

    func testSetEmptySingletonLifecycle() throws {
      let a = RedBlackTreeSet<Int>()
      assertIsSingleton(a.__tree_, "通常の空初期化はシングルトンを使うはず")

      let b = a
      assertIsSingleton(b.__tree_, "空コレクションのコピーもシングルトンを保つはず")
      XCTAssertTrue(a.__tree_.isIdentical(to: b.__tree_), "コピー後も同一バッファを指すはず")

      assertIsSingleton(
        RedBlackTreeSet<Int>(minimumCapacity: 0).__tree_, "容量0の明示初期化もシングルトンのはず")
      assertNotSingleton(
        RedBlackTreeSet<Int>(minimumCapacity: 1).__tree_, "正の最小容量指定は専用バッファを確保するはず")

      var c = RedBlackTreeSet<Int>()
      c.reserveCapacity(0)
      assertNotSingleton(c.__tree_, "reserveCapacity(0)も一意化のためdetachするはず")

      var d = RedBlackTreeSet<Int>()
      d.insert(1)
      assertNotSingleton(d.__tree_, "最初の挿入はシングルトンから専用バッファへdetachするはず")

      d.remove(at: d.startIndex)
      XCTAssertEqual(d.count, 0)
      assertNotSingleton(d.__tree_, "最後の要素を削除してもシングルトンへは戻らず、確保済みバッファを保持するはず")

      d.removeAll(keepingCapacity: true)
      XCTAssertEqual(d.count, 0)
      assertNotSingleton(d.__tree_, "removeAll(keepingCapacity: true)は既存バッファを保持するはず")

      d.removeAll(keepingCapacity: false)
      assertIsSingleton(d.__tree_, "removeAll(keepingCapacity: false)はシングルトンへ戻すはず")
    }

    // MARK: - MultiSet

    func testMultiSetEmptySingletonLifecycle() throws {
      let a = RedBlackTreeMultiSet<Int>()
      assertIsSingleton(a.__tree_, "通常の空初期化はシングルトンを使うはず")

      let b = a
      assertIsSingleton(b.__tree_, "空コレクションのコピーもシングルトンを保つはず")
      XCTAssertTrue(a.__tree_.isIdentical(to: b.__tree_), "コピー後も同一バッファを指すはず")

      assertIsSingleton(
        RedBlackTreeMultiSet<Int>(minimumCapacity: 0).__tree_, "容量0の明示初期化もシングルトンのはず")
      assertNotSingleton(
        RedBlackTreeMultiSet<Int>(minimumCapacity: 1).__tree_, "正の最小容量指定は専用バッファを確保するはず")

      var c = RedBlackTreeMultiSet<Int>()
      c.reserveCapacity(0)
      assertNotSingleton(c.__tree_, "reserveCapacity(0)も一意化のためdetachするはず")

      var d = RedBlackTreeMultiSet<Int>()
      d.insert(1)
      assertNotSingleton(d.__tree_, "最初の挿入はシングルトンから専用バッファへdetachするはず")

      d.remove(at: d.startIndex)
      XCTAssertEqual(d.count, 0)
      assertNotSingleton(d.__tree_, "最後の要素を削除してもシングルトンへは戻らず、確保済みバッファを保持するはず")

      d.removeAll(keepingCapacity: true)
      XCTAssertEqual(d.count, 0)
      assertNotSingleton(d.__tree_, "removeAll(keepingCapacity: true)は既存バッファを保持するはず")

      d.removeAll(keepingCapacity: false)
      assertIsSingleton(d.__tree_, "removeAll(keepingCapacity: false)はシングルトンへ戻すはず")
    }

    // MARK: - Dictionary

    func testDictionaryEmptySingletonLifecycle() throws {
      let a = RedBlackTreeDictionary<Int, String>()
      assertIsSingleton(a.__tree_, "通常の空初期化はシングルトンを使うはず")

      let b = a
      assertIsSingleton(b.__tree_, "空コレクションのコピーもシングルトンを保つはず")
      XCTAssertTrue(a.__tree_.isIdentical(to: b.__tree_), "コピー後も同一バッファを指すはず")

      assertIsSingleton(
        RedBlackTreeDictionary<Int, String>(minimumCapacity: 0).__tree_, "容量0の明示初期化もシングルトンのはず")
      assertNotSingleton(
        RedBlackTreeDictionary<Int, String>(minimumCapacity: 1).__tree_,
        "正の最小容量指定は専用バッファを確保するはず")

      var c = RedBlackTreeDictionary<Int, String>()
      c.reserveCapacity(0)
      assertNotSingleton(c.__tree_, "reserveCapacity(0)も一意化のためdetachするはず")

      var d = RedBlackTreeDictionary<Int, String>()
      d.insert(key: 1, value: "a")
      assertNotSingleton(d.__tree_, "最初の挿入はシングルトンから専用バッファへdetachするはず")

      d.remove(at: d.startIndex)
      XCTAssertEqual(d.count, 0)
      assertNotSingleton(d.__tree_, "最後の要素を削除してもシングルトンへは戻らず、確保済みバッファを保持するはず")

      d.removeAll(keepingCapacity: true)
      XCTAssertEqual(d.count, 0)
      assertNotSingleton(d.__tree_, "removeAll(keepingCapacity: true)は既存バッファを保持するはず")

      d.removeAll(keepingCapacity: false)
      assertIsSingleton(d.__tree_, "removeAll(keepingCapacity: false)はシングルトンへ戻すはず")
    }

    // MARK: - MultiMap

    func testMultiMapEmptySingletonLifecycle() throws {
      let a = RedBlackTreeMultiMap<Int, String>()
      assertIsSingleton(a.__tree_, "通常の空初期化はシングルトンを使うはず")

      let b = a
      assertIsSingleton(b.__tree_, "空コレクションのコピーもシングルトンを保つはず")
      XCTAssertTrue(a.__tree_.isIdentical(to: b.__tree_), "コピー後も同一バッファを指すはず")

      assertIsSingleton(
        RedBlackTreeMultiMap<Int, String>(minimumCapacity: 0).__tree_, "容量0の明示初期化もシングルトンのはず")
      assertNotSingleton(
        RedBlackTreeMultiMap<Int, String>(minimumCapacity: 1).__tree_,
        "正の最小容量指定は専用バッファを確保するはず")

      var c = RedBlackTreeMultiMap<Int, String>()
      c.reserveCapacity(0)
      assertNotSingleton(c.__tree_, "reserveCapacity(0)も一意化のためdetachするはず")

      var d = RedBlackTreeMultiMap<Int, String>()
      _ = d.insert(key: 1, value: "a")
      assertNotSingleton(d.__tree_, "最初の挿入はシングルトンから専用バッファへdetachするはず")

      d.remove(at: d.startIndex)
      XCTAssertEqual(d.count, 0)
      assertNotSingleton(d.__tree_, "最後の要素を削除してもシングルトンへは戻らず、確保済みバッファを保持するはず")

      d.removeAll(keepingCapacity: true)
      XCTAssertEqual(d.count, 0)
      assertNotSingleton(d.__tree_, "removeAll(keepingCapacity: true)は既存バッファを保持するはず")

      d.removeAll(keepingCapacity: false)
      assertIsSingleton(d.__tree_, "removeAll(keepingCapacity: false)はシングルトンへ戻すはず")
    }

    // MARK: - erase(where:)

      /// 空コレクションへの`erase(where:)`は`ensureUnique()`の前に早期returnするため、
      /// 4型すべてでシングルトンからdetachしない(2026-10-03修正、以前はdetachしていた)。
      func testEraseWhereOnEmptyCollectionKeepsSingleton() throws {
        var set = RedBlackTreeSet<Int>()
        set.erase(where: { _ in true })
        assertIsSingleton(set.__tree_, "空集合へのerase(where:)はdetachしないはず")

        var multiSet = RedBlackTreeMultiSet<Int>()
        multiSet.erase(where: { _ in true })
        assertIsSingleton(multiSet.__tree_, "空集合へのerase(where:)はdetachしないはず")

        var dict = RedBlackTreeDictionary<Int, String>()
        dict.erase(where: { _ in true })
        assertIsSingleton(dict.__tree_, "空辞書へのerase(where:)はdetachしないはず")

        var multiMap = RedBlackTreeMultiMap<Int, String>()
        multiMap.erase(where: { _ in true })
        assertIsSingleton(multiMap.__tree_, "空多重連想配列へのerase(where:)はdetachしないはず")
      }
  }
#endif
