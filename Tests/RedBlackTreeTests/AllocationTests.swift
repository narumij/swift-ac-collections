import XCTest

#if DEBUG
@testable import RedBlackTreeModule
#else
import RedBlackTreeModule
#endif

final class AllocationTests: XCTestCase {

#if DEBUG
  typealias Tree = RedBlackTreeSet<Int>.Tree
  typealias Storage = RedBlackTreeSet<Int>.Tree.Storage
  typealias Header = RedBlackTreeSet<Int>.Tree.Header
  typealias Node = RedBlackTreeSet<Int>.Tree.Node

  func test0() throws {
    do {
      let storage: Storage = .create(withCapacity: 0)
      XCTAssertEqual(storage.capacity, 0)
      XCTAssertEqual(storage.tree.header.capacity, 0)
      XCTAssertEqual(storage.tree.capacity, 0)
    }
    do {
      let storage: Storage = .create(withCapacity: 1)
      XCTAssertEqual(storage.capacity, 1)
      XCTAssertEqual(storage.tree.header.capacity, 1)
      XCTAssertEqual(storage.tree.capacity, 1)
    }
    do {
      let storage: Storage = .create(withCapacity: 2)
      XCTAssertEqual(storage.capacity, 2)
      XCTAssertEqual(storage.tree.header.capacity, 2)
      XCTAssertEqual(storage.tree.capacity, 2)
    }
  }

  func test1() throws {
    do {
      // countがゼロになった場合、一旦リセットしてもいい気はするが、しばらく保留
      
      let storage: Storage = .create(withCapacity: 5)
      for i in 0..<5 {
        XCTAssertEqual(storage.tree.__construct_node(-1), i)
      }
      XCTAssertEqual(storage.capacity, 5)
      XCTAssertEqual(storage.tree.header.initializedCount, 5)
      XCTAssertEqual(storage.tree.count, 5)
      XCTAssertEqual(storage.tree.header.destroyCount, 0)
      for i in (0..<5).reversed() {
        storage.tree.destroy(i)
      }
      XCTAssertEqual(storage.capacity, 5)
      XCTAssertEqual(storage.tree.header.initializedCount, 5)
      XCTAssertEqual(storage.tree.count, 0)
      XCTAssertEqual(storage.tree.header.destroyCount, 5)

      do {
        let initializedCount = storage.tree.header.initializedCount
        // ストレージのリファレンスが2になる
        var set = RedBlackTreeSet(_storage: storage)
        XCTAssertEqual(set._storage.capacity, 5)
        XCTAssertEqual(set._storage.tree.header.initializedCount, 5)
        XCTAssertEqual(set._storage.tree.count, 0)
        XCTAssertEqual(set._storage.tree.header.destroyCount, 5)
        set._ensureUniqueAndCapacity(minimumCapacity: 1)
        // リファレンスが2なので、CoWが発火する
        XCTAssertFalse(storage === set._storage)
        // ノードの配置はバラバラになりうるので、初期化されたサイズを下回ると、壊れる
        XCTAssertGreaterThanOrEqual(set._storage.capacity, initializedCount)
        XCTAssertGreaterThanOrEqual(set._storage.capacity, 1)
        XCTAssertEqual(set._storage.count, 0)
      }

      do {
        let initializedCount = storage.tree.header.initializedCount
        // ストレージのリファレンスが2になる
        var set = RedBlackTreeSet(_storage: storage)
        XCTAssertEqual(set._storage.capacity, 5)
        XCTAssertEqual(set._storage.tree.header.initializedCount, 5)
        XCTAssertEqual(set._storage.tree.count, 0)
        XCTAssertEqual(set._storage.tree.header.destroyCount, 5)
        set._ensureUniqueAndCapacity(minimumCapacity: 15)
        // リファレンスが2なので、CoWが発火する
        XCTAssertFalse(storage === set._storage)
        // ノードの配置はバラバラになりうるので、初期化されたサイズを下回ると、壊れる
        XCTAssertGreaterThanOrEqual(set._storage.capacity, initializedCount)
        XCTAssertGreaterThanOrEqual(set._storage.capacity, 15)
        XCTAssertEqual(set._storage.count, 0)
      }
    }
  }

  func test2() throws {
    do {
      var A = RedBlackTreeSet<Int>()
      let B = A
      XCTAssertTrue(A._storage === B._storage)
      A._ensureUnique()
      XCTAssertTrue(A._storage !== B._storage)
    }

#if AC_COLLECTIONS_INTERNAL_CHECKS
    do {
      var A = RedBlackTreeSet<Int>()
      XCTAssertEqual(A._copyCount, 0)
      // treeの保持が単一ではない場合
      let C = A._storage.tree
      defer { _fixLifetime(C) }
      A._ensureUnique()
      // 弱ユニーク化は発火しないが
      XCTAssertEqual(A._copyCount, 0)
      A._strongEnsureUnique()
      // 強ユニーク化は発火すること
      XCTAssertEqual(A._copyCount, 1)
    }
#endif
  }
  
  func test3() throws {
    for i in 0..<1000 {
      let src = RedBlackTreeSet<Int>.Tree.create(minimumCapacity: i)
      for _ in 0 ..< 100 {
        let dst = src.copy()
        XCTAssertEqual(src.capacity, dst.capacity)
      }
    }
  }
  
#endif // DEBUG
}
