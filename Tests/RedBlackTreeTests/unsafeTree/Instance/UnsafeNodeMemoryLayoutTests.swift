#if DEBUG
@testable import RedBlackTreeCollections
import XCTest

final class UnsafeNodeMemoryLayoutTests: XCTestCase {

    /*
    |
    ^ max(node.alignment, payload.alignment)
    |
    +---------+---------------------+--+---------------------+--+---------------------+--+---------------------+--+
    |         |      UnsafeNode     |  |       Payload       |  |      UnsafeNode     |  |       Payload       |  |
    +---------+---------------------+--+---------------------+--+---------------------+--+---------------------+--+
              ^                     ^  ^                        ^
              |                     |  |                        |
              |                     |  payload                  |
              |                     |  = node + nodeStride      |
              |                     |                           |
              |<---- nodeSize ----->|                           |
              |<------ nodeStride ----->|                       |
              |                                                 |
              |<--------------- pairStride -------------------->|
              |<--------------- nodeAdvance ------------------->|

              ^ node aligned            ^ payload aligned       ^ next node aligned
                to node.alignment         to payload.alignment    to node.alignment
    */

    func testNodeAndPayloadMemoryLayout() throws {
        checkMemoryLayout(Int16.self)
        checkMemoryLayout(Int32.self)
        checkMemoryLayout(Int64.self)
        checkMemoryLayout(SIMD4<Float>.self)
    }

    private func checkMemoryLayout<Payload>(
        _ payloadType: Payload.Type,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let nodeAlignment = MemoryLayout<UnsafeNode>.alignment
        let nodeStride = MemoryLayout<UnsafeNode>.stride
        let payloadAlignment = MemoryLayout<Payload>.alignment

        // node / payload の両方が正しく alignment できる領域を確保する
        let storage = UnsafeMutableRawPointer.allocate(
            byteCount: 1024,
            alignment: max(nodeAlignment, payloadAlignment)
        )
        defer { storage.deallocate() }

        // まず、1個目の payload が正しく align される位置を作る
        let firstPayload =
            storage
            .advanced(by: nodeStride)
            .alignedUp(toMultipleOf: payloadAlignment)

        // payload の直前に UnsafeNode がある、というレイアウト
        let firstNode =
            firstPayload
            .advanced(by: -nodeStride)
            .assumingMemoryBound(to: UnsafeNode.self)

        // 1個進める
        let secondNode =
            firstNode._advanced(with: Payload.self, count: 1)

        let nodeAdvance = UnsafeMutableRawPointer(firstNode).distance(
            to: UnsafeMutableRawPointer(secondNode)
        )
        let pairSize = nodeStride + MemoryLayout<Payload>.stride
        let pairAlignment = max(nodeAlignment, payloadAlignment)

        // 必要なサイズ以上で、末尾の padding は alignment 未満である
        XCTAssertGreaterThanOrEqual(nodeAdvance, pairSize, file: file, line: line)
        XCTAssertLessThan(nodeAdvance - pairSize, pairAlignment, file: file, line: line)
        XCTAssertEqual(nodeAdvance % pairAlignment, 0, file: file, line: line)

        // 負方向にも同じ stride で移動する
        XCTAssertEqual(
            secondNode._advanced(with: Payload.self, count: -1),
            firstNode,
            "\(Payload.self): reverse node advance is wrong",
            file: file,
            line: line
        )

        // UnsafeNode 自体が align されている
        XCTAssertEqual(
            Int(bitPattern: firstNode) % nodeAlignment,
            0,
            "\(Payload.self): firstNode is not aligned",
            file: file,
            line: line
        )

        XCTAssertEqual(
            Int(bitPattern: secondNode) % nodeAlignment,
            0,
            "\(Payload.self): secondNode is not aligned",
            file: file,
            line: line
        )

        // Payload も align されている
        XCTAssertEqual(
            Int(bitPattern: firstNode.__value_(as: Payload.self)) % payloadAlignment,
            0,
            "\(Payload.self): firstPayload is not aligned",
            file: file,
            line: line
        )

        XCTAssertEqual(
            Int(bitPattern: secondNode.__value_(as: Payload.self)) % payloadAlignment,
            0,
            "\(Payload.self): secondPayload is not aligned",
            file: file,
            line: line
        )

        // Payload は常に node + nodeStride の位置にある
        XCTAssertEqual(
            UnsafeMutableRawPointer(firstNode.__value_(as: Payload.self)),
            UnsafeMutableRawPointer(firstNode).advanced(by: nodeStride),
            "\(Payload.self): first payload offset is wrong",
            file: file,
            line: line
        )

        XCTAssertEqual(
            UnsafeMutableRawPointer(secondNode.__value_(as: Payload.self)),
            UnsafeMutableRawPointer(secondNode).advanced(by: nodeStride),
            "\(Payload.self): second payload offset is wrong",
            file: file,
            line: line
        )
    }
}
#endif
