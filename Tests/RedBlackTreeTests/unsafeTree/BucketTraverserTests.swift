//
//  BucketTraverserTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/09/23.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections

  final class BucketTraverserTests: RedBlackTreeTestCase {

    func testHeadAlignment() throws {
      for n in (0..<12).map({ 1 << $0 }) {
        try checkAlignment(Int8.self, capacity: n, isHead: true)
        try checkAlignment(Int16.self, capacity: n, isHead: true)
        try checkAlignment(Int32.self, capacity: n, isHead: true)
        try checkAlignment(Int64.self, capacity: n, isHead: true)
        if #available(macOS 15.0, *) {
          try checkAlignment(Int128.self, capacity: n, isHead: true)
        }
        try checkAlignment(Int.self, capacity: n, isHead: true)
        try checkAlignment(SIMD2<Int>.self, capacity: n, isHead: true)
        try checkAlignment(SIMD3<Int>.self, capacity: n, isHead: true)
        try checkAlignment(SIMD4<Int>.self, capacity: n, isHead: true)
        try checkAlignment(SIMD8<Int>.self, capacity: n, isHead: true)
        try checkAlignment(SIMD16<Int>.self, capacity: n, isHead: true)
        try checkAlignment(SIMD32<Int>.self, capacity: n, isHead: true)
        try checkAlignment(
          RedBlackTreePair<Int32, Int32>.self, capacity: n, isHead: true)
        try checkAlignment(
          RedBlackTreePair<Int32, Int>.self, capacity: n, isHead: true)
        try checkAlignment(
          RedBlackTreePair<Int, Int32>.self, capacity: n, isHead: true)
        try checkAlignment(
          RedBlackTreePair<Int, Int>.self, capacity: n, isHead: true)
        try checkAlignment(
          RedBlackTreePair<Int32, SIMD4<Float>>.self, capacity: n, isHead: true)
        try checkAlignment(
          RedBlackTreePair<SIMD4<Float>, Int32>.self, capacity: n, isHead: true)
        try checkAlignment(
          RedBlackTreePair<Int, SIMD4<Int>>.self, capacity: n, isHead: true)
        try checkAlignment(
          RedBlackTreePair<SIMD4<Int>, Int>.self, capacity: n, isHead: true)
      }
    }

    func testOtherAlignment() throws {
      for n in (0..<12).map({ 1 << $0 }) {
        try checkAlignment(Int8.self, capacity: n, isHead: false)
        try checkAlignment(Int16.self, capacity: n, isHead: false)
        try checkAlignment(Int32.self, capacity: n, isHead: false)
        try checkAlignment(Int64.self, capacity: n, isHead: false)
        if #available(macOS 15.0, *) {
          try checkAlignment(Int128.self, capacity: n, isHead: false)
        }
        try checkAlignment(Int.self, capacity: n, isHead: false)
        try checkAlignment(SIMD2<Int>.self, capacity: n, isHead: false)
        try checkAlignment(SIMD3<Int>.self, capacity: n, isHead: false)
        try checkAlignment(SIMD4<Int>.self, capacity: n, isHead: false)
        try checkAlignment(SIMD8<Int>.self, capacity: n, isHead: false)
        try checkAlignment(SIMD16<Int>.self, capacity: n, isHead: false)
        try checkAlignment(SIMD32<Int>.self, capacity: n, isHead: false)
        try checkAlignment(
          RedBlackTreePair<Int32, Int32>.self, capacity: n, isHead: false)
        try checkAlignment(
          RedBlackTreePair<Int32, Int>.self, capacity: n, isHead: false)
        try checkAlignment(
          RedBlackTreePair<Int, Int32>.self, capacity: n, isHead: false)
        try checkAlignment(
          RedBlackTreePair<Int, Int>.self, capacity: n, isHead: false)
        try checkAlignment(
          RedBlackTreePair<Int32, SIMD4<Float>>.self, capacity: n, isHead: false)
        try checkAlignment(
          RedBlackTreePair<SIMD4<Float>, Int32>.self, capacity: n, isHead: false)
        try checkAlignment(
          RedBlackTreePair<Int, SIMD4<Int>>.self, capacity: n, isHead: false)
        try checkAlignment(
          RedBlackTreePair<SIMD4<Int>, Int>.self, capacity: n, isHead: false)
      }
    }

    private func checkAlignment<Payload>(
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
        alignment: allocator._pair.alignment)

      let header = storage.assumingMemoryBound(to: _Bucket.self)
      header.initialize(to: _Bucket(capacity: capacity))

      defer {
        header.deinitialize(count: 1)
        storage.deallocate()
      }

      header.pointee.count = capacity

      let bucketStorage =
        isHead
        ? header.primaryStorage()
        : header.secondaryStorage()

      var counts = header._counts(
        storage: bucketStorage,
        pairLayout: MemoryLayout<Payload>._pairLayout)

      for index in 0..<capacity {
        let node = try XCTUnwrap(
          counts.pop(),
          "\(Payload.self): counts unexpectedly ended at \(index)",
          file: file,
          line: line)

        checkAlignment(
          node,
          payloadType,
          index: index,
          kind: "counts",
          file: file,
          line: line)
      }

      XCTAssertNil(
        counts.pop(),
        "\(Payload.self): counts exceeded count",
        file: file,
        line: line)

      var capacities = header._capacities(
        storage: bucketStorage,
        payload: MemoryLayout<Payload>._pairLayout)

      for index in 0..<capacity {
        let node = try XCTUnwrap(
          capacities.pop(),
          "\(Payload.self): capacities unexpectedly ended at \(index)",
          file: file,
          line: line)

        checkAlignment(
          node,
          payloadType,
          index: index,
          kind: "capacities",
          file: file,
          line: line)
      }

      XCTAssertNil(
        capacities.pop(),
        "\(Payload.self): capacities exceeded capacity",
        file: file,
        line: line)
    }

    private func checkAlignment<Payload>(
      _ node: UnsafeMutablePointer<UnsafeNode>,
      _ payloadType: Payload.Type,
      index: Int,
      kind: String,
      file: StaticString,
      line: UInt
    ) {
      XCTAssertEqual(
        Int(bitPattern: node) % MemoryLayout<UnsafeNode>.alignment,
        0,
        "\(Payload.self): \(kind) node \(index) is misaligned",
        file: file,
        line: line)

      XCTAssertEqual(
        Int(bitPattern: node.__value_(as: Payload.self))
          % MemoryLayout<Payload>.alignment,
        0,
        "\(Payload.self): \(kind) payload \(index) is misaligned",
        file: file,
        line: line)
    }
  }
#endif
