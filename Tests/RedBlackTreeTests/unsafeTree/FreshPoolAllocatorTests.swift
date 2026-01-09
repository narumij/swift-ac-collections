import XCTest
@testable import RedBlackTreeModule

final class FreshPoolAllocatorTests: XCTestCase {

  func testCreateBucket_LaysOutUnsafeNodeAndValueSequentially() {

    typealias V = Int
    let capacity = 10
    var pool = FreshPool<V>()

    let (header, firstRaw, _) = pool._createBucket(capacity: capacity)

    // elements 開始位置
    var raw = firstRaw

    for i in 0..<capacity {

      // UnsafeNode の位置
      let nodePtr = raw.assumingMemoryBound(to: UnsafeNode.self)

      // Node 自体が読めること（未初期化 UB でないこと）
      _ = nodePtr.pointee.___node_id_

      // Value の位置（Node直後）
      let valuePtr =
        UnsafeMutableRawPointer(nodePtr.advanced(by: 1))
          .assumingMemoryBound(to: V.self)

      // Value を初期化して読めること
      valuePtr.initialize(to: i)
      XCTAssertEqual(valuePtr.pointee, i)

      // 次の要素へ（UnsafeNode + Value）
      raw = UnsafePair<V>
        .advance(nodePtr)
        ._assumingUnbound()
    }

    // 後始末（Value → Node）
    raw = firstRaw
    for _ in 0..<capacity {
      let nodePtr = raw.assumingMemoryBound(to: UnsafeNode.self)
      let valuePtr =
        UnsafeMutableRawPointer(nodePtr.advanced(by: 1))
          .assumingMemoryBound(to: V.self)

      valuePtr.deinitialize(count: 1)
      nodePtr.deinitialize(count: 1)

      raw = UnsafePair<V>
        .advance(nodePtr)
        ._assumingUnbound()
    }

    header.deallocate()
  }
}


import XCTest

final class FreshPoolSubscriptTests: XCTestCase {

  func testSubscriptReturnsCorrectUnsafeNodePointer() {

    typealias V = Int
    var pool = FreshPool<V>()

    // 10 個分確保
    pool.reserveCapacity(minimumCapacity: 10)

    // 各ノードに ID を書き込む
    for i in 0..<10 {
      let p = pool.pointers!.advanced(by: i).pointee
      p.initialize(to: UnsafeNode.nullptr.create(id: i))
    }

    pool.used = 10

    // subscript が array に詰めた先頭ポインタを
    // そのまま返しているか
    for i in 0..<10 {
      let pFromArray = pool.pointers!.advanced(by: i).pointee
      let pFromSubscript = pool[i]

      XCTAssertTrue(pFromArray == pFromSubscript)
      XCTAssertEqual(pFromSubscript.pointee.___node_id_, i)
    }

    // 後始末
    pool.dispose()
  }
}
