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
        let storage: Storage = .create(minimumCapacity: 0)
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

    // TODO: FIXME
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
          set._ensureUniqueAndCapacity(to: 1)
          // リファレンスが2なので、CoWが発火する
#if false
          // LV1が本体保持になっているので、結果が異なる
          XCTAssertFalse(storage.isIdentical(to: set.__tree_))
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
          set._ensureUniqueAndCapacity(to: 15)
          // リファレンスが2なので、CoWが発火する
#if false
          // LV1が本体保持になっているので、結果が異なる
          XCTAssertFalse(storage.isIdentical(to: set.__tree_))
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
        XCTAssertTrue(A.__tree_.isIdentical(to: B.__tree_))
        A.__tree_._ensureUnique()
        XCTAssertTrue(!A.__tree_.isIdentical(to: B.__tree_))
      }

      #if AC_COLLECTIONS_INTERNAL_CHECKS
        do {
          var A = RedBlackTreeSet<Int>()
          XCTAssertEqual(A._copyCount, 0)
          // treeの保持が単一ではない場合
          let C = A.__tree_
          defer { _fixLifetime(C) }
          A.__tree_._ensureUnique()
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

  //#if USE_FRESH_POOL_V1
  #if !USE_FRESH_POOL_V2
    func testCapacityGrowth() throws {
      let set = RedBlackTreeSet<Int>()
      var tree = set.__tree_
      var capacities: [Int] = [0]
      while let l = capacities.last, l < 1_000_000 {
        tree.initializedCount = l
        tree.capacity = l
        capacities.append(tree.growCapacity(to: l + 1, linearly: false))
      }
      // [0, 1, 2, 3, 4, 6, 8, 10, 12, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576]
      // [0, 1, 2, 3, 4, 6, 8, 10, 12, 25, 51, 102, 204, 409, 819, 1638, 3276, 6553, 13107, 26214, 52428, 104857, 209715, 419430, 838860, 1677721]
      // [0, 1, 2, 3, 4, 6, 8, 10, 12, 24, 49, 101, 203, 408, 817, 1637, 3275, 6552, 13105, 26213, 52427, 104856, 209713, 419429, 838859, 1677720]
      // [0, 1, 2, 3, 4, 6, 8, 10, 12, 24, 48, 96, 192, 384, 768, 1536, 3072, 6144, 12288, 24576, 49152, 98304, 196608, 393216, 786432, 1572864]
      XCTAssertNotEqual(capacities, [])
      #if !ALLOCATION_DRILL
          // 小さく確保していく方針に切り替えた
      // アロケーション改良中で未確定
      // TODO: FIXME
//          XCTAssertEqual(capacities.count, 1054)
//          XCTAssertEqual(capacities.last, 1_000_747)
      #endif
      //    XCTAssertEqual(capacities.last, 1572864)
      tree.initializedCount = 0  // これをしないと未初期化メモリに触ってクラッシュとなる
    }
  #endif
  
  func testHoge() throws {
    var a = RedBlackTreeSet<Int>()
    a.__tree_._ensureUnique()
    XCTAssertEqual(a.capacity, 0)
    a.__tree_._buffer.header.pushFreshBucket(capacity: 512)
    XCTAssertGreaterThanOrEqual(a.capacity, 512)
  }

  #endif  // DEBUG
}
