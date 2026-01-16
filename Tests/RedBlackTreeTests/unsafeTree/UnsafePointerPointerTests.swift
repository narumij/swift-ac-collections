import XCTest

#if DEBUG
  @testable import RedBlackTreeModule

  final class UnsafePointerPointerTests: XCTestCase {

    func testPointerOfPointerPointsToOriginalNodes() {

      // 1. UnsafeNode を10個分確保・初期化
      let nodeCount = 10
      let nodes = UnsafeMutablePointer<UnsafeNode>.allocate(capacity: nodeCount)
      for i in 0..<nodeCount {
        (nodes + i).initialize(to: UnsafeNode.nullptr.create(id: i))
      }

      // 2. UnsafeNode へのポインタを10個保持する生メモリを確保・初期化
      let ptrArray =
        UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
        .allocate(capacity: nodeCount)

      for i in 0..<nodeCount {
        (ptrArray + i).initialize(to: nodes + i)
      }

      // 3. 各ポインタが正しく元の UnsafeNode を指しているか検証
      for i in 0..<nodeCount {
        let p = (ptrArray + i).pointee
        XCTAssertEqual(p.pointee.___node_id_, i)
        XCTAssertTrue(p == nodes + i)
      }

      // 後始末
      for i in 0..<nodeCount {
        (ptrArray + i).deinitialize(count: 1)
      }
      ptrArray.deallocate()

      for i in 0..<nodeCount {
        (nodes + i).deinitialize(count: 1)
      }
      nodes.deallocate()
    }
  }
#endif
