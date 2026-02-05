import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class AllocationTests: RedBlackTreeTestCase {

  #if DEBUG
    typealias Tree = RedBlackTreeSet<Int>.Tree
    typealias Storage = RedBlackTreeSet<Int>.Tree
    typealias Header = RedBlackTreeSet<Int>.Tree.Header

    func test0() throws {
      do {
        let storage: Storage = .create()
        XCTAssertEqual(storage.capacity, 0)
      }
      do {
        let storage: Storage = .create(minimumCapacity: 1)
        XCTAssertGreaterThanOrEqual(storage.capacity, 1)
      }
      do {
        let storage: Storage = .create(minimumCapacity: 2)
        XCTAssertGreaterThanOrEqual(storage.capacity, 2)
      }
    }

    func test1() throws {
      do {
        // countがゼロになった場合、一旦リセットしてもいい気はするが、しばらく保留

        let storage: Storage = .create(minimumCapacity: 5)
        XCTAssertGreaterThanOrEqual(storage.capacity, 5)
        let actualCapacity = storage.capacity  // ManagedBufferの挙動が変わった
        for i in 0..<5 {
          XCTAssertEqual(storage.__construct_node(-1).index, i)
        }
        XCTAssertEqual(storage.capacity, actualCapacity)  // capacityが変動しないこと
        XCTAssertEqual(storage.initializedCount, 5)
        XCTAssertEqual(storage.count, 5)
        XCTAssertEqual(storage._buffer.header.recycleCount, 0)
        for i in (0..<5).reversed() {
          storage.destroy(i)
        }
        XCTAssertEqual(storage.capacity, actualCapacity)
        XCTAssertEqual(storage.initializedCount, 5)
        XCTAssertEqual(storage.count, 0)
        XCTAssertEqual(storage._buffer.header.recycleCount, 5)

        do {
          let initializedCount = storage.initializedCount
          // ストレージのリファレンスが2になる
          var set = RedBlackTreeSet(__tree_: storage)
          XCTAssertEqual(set.__tree_.capacity, actualCapacity)
          XCTAssertEqual(set.__tree_.initializedCount, 5)
          XCTAssertEqual(set.__tree_.count, 0)
          XCTAssertEqual(set.__tree_._buffer.header.recycleCount, 5)
          set.__tree_.ensureUniqueAndCapacity(to: 1)
          // リファレンスが2なので、CoWが発火する
          #if false
            // LV1が本体保持になっているので、結果が異なる
            XCTAssertFalse(storage.isTriviallyIdentical(to: set.__tree_))
          #endif
          // ノードの配置はバラバラになりうるので、初期化されたサイズを下回ると、壊れる
          XCTAssertGreaterThanOrEqual(set.__tree_.capacity, initializedCount)
          XCTAssertGreaterThanOrEqual(set.__tree_.capacity, 1)
          XCTAssertEqual(set.__tree_.count, 0)
        }

        do {
          let initializedCount = storage.initializedCount
          // ストレージのリファレンスが2になる
          var set = RedBlackTreeSet(__tree_: storage)
          XCTAssertEqual(set.__tree_.capacity, actualCapacity)
          XCTAssertEqual(set.__tree_.initializedCount, 5)
          XCTAssertEqual(set.__tree_.count, 0)
          XCTAssertEqual(set.__tree_._buffer.header.recycleCount, 5)
          set.__tree_.ensureUniqueAndCapacity(to: 15)
          // リファレンスが2なので、CoWが発火する
          #if false
            // LV1が本体保持になっているので、結果が異なる
            XCTAssertFalse(storage.isTriviallyIdentical(to: set.__tree_))
          #endif
          // ノードの配置はバラバラになりうるので、初期化されたサイズを下回ると、壊れる
          XCTAssertGreaterThanOrEqual(set.__tree_.capacity, initializedCount)
          XCTAssertGreaterThanOrEqual(set.__tree_.capacity, 15)
          XCTAssertEqual(set.__tree_.count, 0)
        }
      }
    }

    func test2() throws {
      do {
        var A = RedBlackTreeSet<Int>()
        let B = A
        XCTAssertTrue(A.__tree_.isTriviallyIdentical(to: B.__tree_))
        A.__tree_.ensureUnique()
        XCTAssertTrue(!A.__tree_.isTriviallyIdentical(to: B.__tree_))
      }

      #if AC_COLLECTIONS_INTERNAL_CHECKS
        do {
          var A = RedBlackTreeSet<Int>()
          XCTAssertEqual(A._copyCount, 0)
          // treeの保持が単一ではない場合
          let C = A.__tree_
          defer { _fixLifetime(C) }
          A.__tree_.ensureUnique()
          #if false
            // シングルトンバッファを使っているので、コピーが発生するようになった
            // 弱ユニーク化は発火しないが
            XCTAssertEqual(A._copyCount, 0)
          #endif
          A.__tree_._strongEnsureUnique()
          // 強ユニーク化は発火すること
          XCTAssertEqual(A._copyCount, 1)
        }
      #endif
    }

    func test3() throws {
      for i in 0..<1000 {
        let src = RedBlackTreeSet<Int>.Tree.create(minimumCapacity: i)
        for _ in 0..<100 {
          let dst = src.copy(minimumCapacity: src.capacity)
          XCTAssertEqual(src.capacity, dst.capacity)
        }
      }
    }

    func testHoge() throws {
      var a = RedBlackTreeSet<Int>()
      a.__tree_.ensureUnique()
      XCTAssertEqual(a.capacity, 0)
      a.__tree_._buffer.header.pushFreshBucket(capacity: 512)
      XCTAssertGreaterThanOrEqual(a.capacity, 512)
    }
  
  func testEmptyIsNonUnique() throws {
    var a = RedBlackTreeSet<Int>()
    XCTAssertFalse(a.__tree_.isUnique())
    XCTAssertTrue(a.__tree_.isReadOnly)
  }

  #endif  // DEBUG
}
