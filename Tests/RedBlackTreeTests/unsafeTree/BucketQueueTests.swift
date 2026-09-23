//
//  BucketQueueTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/09/23.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections

  final class BucketQueueTests: RedBlackTreeTestCase {

    func testHeadQueueAlignment() throws {
      for n in (0..<12).map({ 1 << $0 }) {
        try checkQueueAlignment(Int8.self, capacity: n, isHead: true)
        try checkQueueAlignment(Int16.self, capacity: n, isHead: true)
        try checkQueueAlignment(Int32.self, capacity: n, isHead: true)
        try checkQueueAlignment(Int64.self, capacity: n, isHead: true)
        if #available(macOS 15.0, *) {
          try checkQueueAlignment(Int128.self, capacity: n, isHead: true)
        }
        try checkQueueAlignment(Int.self, capacity: n, isHead: true)
        try checkQueueAlignment(SIMD2<Int>.self, capacity: n, isHead: true)
        try checkQueueAlignment(SIMD3<Int>.self, capacity: n, isHead: true)
        try checkQueueAlignment(SIMD4<Int>.self, capacity: n, isHead: true)
        try checkQueueAlignment(SIMD8<Int>.self, capacity: n, isHead: true)
        try checkQueueAlignment(SIMD16<Int>.self, capacity: n, isHead: true)
        try checkQueueAlignment(SIMD32<Int>.self, capacity: n, isHead: true)
        try checkQueueAlignment(
          RedBlackTreePair<Int32, Int32>.self, capacity: n, isHead: true)
        try checkQueueAlignment(
          RedBlackTreePair<Int32, Int>.self, capacity: n, isHead: true)
        try checkQueueAlignment(
          RedBlackTreePair<Int, Int32>.self, capacity: n, isHead: true)
        try checkQueueAlignment(
          RedBlackTreePair<Int, Int>.self, capacity: n, isHead: true)
        try checkQueueAlignment(
          RedBlackTreePair<Int32, SIMD4<Float>>.self, capacity: n, isHead: true)
        try checkQueueAlignment(
          RedBlackTreePair<SIMD4<Float>, Int32>.self, capacity: n, isHead: true)
        try checkQueueAlignment(
          RedBlackTreePair<Int, SIMD4<Int>>.self, capacity: n, isHead: true)
        try checkQueueAlignment(
          RedBlackTreePair<SIMD4<Int>, Int>.self, capacity: n, isHead: true)
      }
    }

    func testOtherQueueAlignment() throws {
      for n in (0..<12).map({ 1 << $0 }) {
        try checkQueueAlignment(Int8.self, capacity: n, isHead: false)
        try checkQueueAlignment(Int16.self, capacity: n, isHead: false)
        try checkQueueAlignment(Int32.self, capacity: n, isHead: false)
        try checkQueueAlignment(Int64.self, capacity: n, isHead: false)
        if #available(macOS 15.0, *) {
          try checkQueueAlignment(Int128.self, capacity: n, isHead: false)
        }
        try checkQueueAlignment(Int.self, capacity: n, isHead: false)
        try checkQueueAlignment(SIMD2<Int>.self, capacity: n, isHead: false)
        try checkQueueAlignment(SIMD3<Int>.self, capacity: n, isHead: false)
        try checkQueueAlignment(SIMD4<Int>.self, capacity: n, isHead: false)
        try checkQueueAlignment(SIMD8<Int>.self, capacity: n, isHead: false)
        try checkQueueAlignment(SIMD16<Int>.self, capacity: n, isHead: false)
        try checkQueueAlignment(SIMD32<Int>.self, capacity: n, isHead: false)
        try checkQueueAlignment(
          RedBlackTreePair<Int32, Int32>.self, capacity: n, isHead: false)
        try checkQueueAlignment(
          RedBlackTreePair<Int32, Int>.self, capacity: n, isHead: false)
        try checkQueueAlignment(
          RedBlackTreePair<Int, Int32>.self, capacity: n, isHead: false)
        try checkQueueAlignment(
          RedBlackTreePair<Int, Int>.self, capacity: n, isHead: false)
        try checkQueueAlignment(
          RedBlackTreePair<Int32, SIMD4<Float>>.self, capacity: n, isHead: false)
        try checkQueueAlignment(
          RedBlackTreePair<SIMD4<Float>, Int32>.self, capacity: n, isHead: false)
        try checkQueueAlignment(
          RedBlackTreePair<Int, SIMD4<Int>>.self, capacity: n, isHead: false)
        try checkQueueAlignment(
          RedBlackTreePair<SIMD4<Int>, Int>.self, capacity: n, isHead: false)
      }
    }

    private func checkQueueAlignment<Payload>(
      _ payloadType: Payload.Type,
      capacity: Int,
      isHead: Bool,
      file: StaticString = #filePath,
      line: UInt = #line
    ) throws {
      let allocator = _BucketAllocator(valueType: Payload.self) { _ in }

      let byteSize =
        isHead
        ? allocator._headAllocationSize(capacity: capacity)
        : allocator._allocationSizeNonzero(capacity: capacity)

      let storage = UnsafeMutableRawPointer.allocate(
        byteCount: byteSize,
        alignment: allocator.pairLayout.alignment)
      defer { storage.deallocate() }

      let header = storage.assumingMemoryBound(to: _Bucket.self)

      let queue = header._queue(
        isHead: isHead,
        pairLayout: MemoryLayout<Payload>._pairLayout)

      XCTAssertEqual(
        queue.pairStride,
        allocator.pairLayout.stride,
        "\(Payload.self): queue stride is wrong",
        file: file,
        line: line)

      XCTAssertEqual(
        Int(bitPattern: queue.start) % MemoryLayout<UnsafeNode>.alignment,
        0,
        "\(Payload.self): queue start node is misaligned",
        file: file,
        line: line)

      XCTAssertEqual(
        Int(bitPattern: queue.start.__value_(as: Payload.self))
          % MemoryLayout<Payload>.alignment,
        0,
        "\(Payload.self): queue start payload is misaligned",
        file: file,
        line: line)

      for index in 0..<capacity {
        let node = UnsafeMutableRawPointer(queue.start)
          .advanced(by: queue.pairStride * index)
          .assumingMemoryBound(to: UnsafeNode.self)

        XCTAssertEqual(
          Int(bitPattern: node) % MemoryLayout<UnsafeNode>.alignment,
          0,
          "\(Payload.self): queue node \(index) is misaligned",
          file: file,
          line: line)

        XCTAssertEqual(
          Int(bitPattern: node.__value_(as: Payload.self))
            % MemoryLayout<Payload>.alignment,
          0,
          "\(Payload.self): queue payload \(index) is misaligned",
          file: file,
          line: line)
      }

      if isHead {
        let headQueue = try XCTUnwrap(
          header.queue(pairLayout: MemoryLayout<Payload>._pairLayout),
          file: file,
          line: line)

        XCTAssertEqual(
          headQueue.start,
          queue.start,
          "\(Payload.self): head queue start is wrong",
          file: file,
          line: line)

        XCTAssertEqual(
          headQueue.pairStride,
          queue.pairStride,
          "\(Payload.self): head queue stride is wrong",
          file: file,
          line: line)
      }
    }
  }
#endif
