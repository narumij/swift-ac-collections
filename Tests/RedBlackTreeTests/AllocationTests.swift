import XCTest

#if DEBUG
@testable import RedBlackTreeModule
#else
import RedBlackTreeModule
#endif

final class AllocationTests: XCTestCase {

#if DEBUG
  typealias Tree = RedBlackTreeSet<Int>.Tree
  typealias Storage = RedBlackTreeSet<Int>.Storage
  typealias Header = RedBlackTreeSet<Int>.Tree.Header
  typealias Node = RedBlackTreeSet<Int>.Tree.Node

  func test0() throws {
    do {
      let storage: Storage = .create(withCapacity: 0)
      XCTAssertEqual(storage.capacity, 0)
      XCTAssertEqual(storage.tree.capacity, 0)
    }
    do {
      let storage: Storage = .create(withCapacity: 1)
      XCTAssertEqual(storage.capacity, 1)
      XCTAssertEqual(storage.tree.capacity, 1)
    }
    do {
      let storage: Storage = .create(withCapacity: 2)
      XCTAssertEqual(storage.capacity, 2)
      XCTAssertEqual(storage.tree.capacity, 2)
    }
  }

  func test1() throws {
    do {
      // countがゼロになった場合、一旦リセットしてもいい気はするが、しばらく保留
      
      let storage: Storage = .create(withCapacity: 5)
      XCTAssertGreaterThanOrEqual(storage.capacity, 5)
      let actualCapacity = storage.capacity // ManagedBufferの挙動が変わった
      for i in 0..<5 {
        XCTAssertEqual(storage.tree.__construct_node(-1), i)
      }
      XCTAssertEqual(storage.capacity, actualCapacity) // capacityが変動しないこと
      XCTAssertEqual(storage.tree.header.initializedCount, 5)
      XCTAssertEqual(storage.tree.count, 5)
      XCTAssertEqual(storage.tree.header.destroyCount, 0)
      for i in (0..<5).reversed() {
        storage.tree.destroy(i)
      }
      XCTAssertEqual(storage.capacity, actualCapacity)
      XCTAssertEqual(storage.tree.header.initializedCount, 5)
      XCTAssertEqual(storage.tree.count, 0)
      XCTAssertEqual(storage.tree.header.destroyCount, 5)

      do {
        let initializedCount = storage.tree.header.initializedCount
        // ストレージのリファレンスが2になる
        var set = RedBlackTreeSet(_storage: storage)
        XCTAssertEqual(set._storage.capacity, actualCapacity)
        XCTAssertEqual(set._storage.tree.header.initializedCount, 5)
        XCTAssertEqual(set._storage.tree.count, 0)
        XCTAssertEqual(set._storage.tree.header.destroyCount, 5)
        set._ensureUniqueAndCapacity(to: 1)
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
        XCTAssertEqual(set._storage.capacity, actualCapacity)
        XCTAssertEqual(set._storage.tree.header.initializedCount, 5)
        XCTAssertEqual(set._storage.tree.count, 0)
        XCTAssertEqual(set._storage.tree.header.destroyCount, 5)
        set._ensureUniqueAndCapacity(to: 15)
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
    throw XCTSkip("copyの挙動を変更したため")
//    for i in 0..<1000 {
//      let src = RedBlackTreeSet<Int>.Tree.create(minimumCapacity: i)
//      for _ in 0 ..< 100 {
//        let dst = src.copy()
//        XCTAssertEqual(src.capacity, dst.capacity)
//      }
//    }
  }
  
  func testCapacityGrowth() throws {
    let set = RedBlackTreeSet<Int>()
    let tree = set._storage.tree
    var capacities: [Int] = [0]
    while let l = capacities.last, l < 1_000_000 {
      tree._header.initializedCount = l
      tree._header.capacity = l
      capacities.append(tree.growCapacity(to: l + 1, linearly: false))
    }
    // [0, 1, 2, 3, 4, 6, 8, 10, 12, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576]
    // [0, 1, 2, 3, 4, 6, 8, 10, 12, 25, 51, 102, 204, 409, 819, 1638, 3276, 6553, 13107, 26214, 52428, 104857, 209715, 419430, 838860, 1677721]
    // [0, 1, 2, 3, 4, 6, 8, 10, 12, 24, 49, 101, 203, 408, 817, 1637, 3275, 6552, 13105, 26213, 52427, 104856, 209713, 419429, 838859, 1677720]
    // [0, 1, 2, 3, 4, 6, 8, 10, 12, 24, 48, 96, 192, 384, 768, 1536, 3072, 6144, 12288, 24576, 49152, 98304, 196608, 393216, 786432, 1572864]
    XCTAssertNotEqual(capacities, [])
    XCTAssertEqual(capacities.count, 26)
    XCTAssertEqual(capacities.last, 1677720)
//    XCTAssertEqual(capacities.last, 1572864)
  }

#endif // DEBUG
}
