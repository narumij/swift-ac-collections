//
//  BucketAllocatorTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/21.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections

  final class BucketAllocatorTests: RedBlackTreeTestCase {

    private let guardByteCount = 64
    private let guardByte: UInt8 = 0xA5

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHeadAllocationSize() throws {
      for n in [0] + (0..<12).map({ 1 << $0 }) {
        try checkHeadAllocationSize(Int8.self, capacity: n)
        try checkHeadAllocationSize(Int16.self, capacity: n)
        try checkHeadAllocationSize(Int32.self, capacity: n)
        try checkHeadAllocationSize(Int64.self, capacity: n)
        if #available(macOS 15.0, *) {
          try checkHeadAllocationSize(Int128.self, capacity: n)
        }
        try checkHeadAllocationSize(Int.self, capacity: n)
        try checkHeadAllocationSize(SIMD2<Int>.self, capacity: n)
        try checkHeadAllocationSize(SIMD3<Int>.self, capacity: n)
        try checkHeadAllocationSize(SIMD4<Int>.self, capacity: n)
        try checkHeadAllocationSize(SIMD8<Int>.self, capacity: n)
        try checkHeadAllocationSize(SIMD16<Int>.self, capacity: n)
        try checkHeadAllocationSize(SIMD32<Int>.self, capacity: n)
      }
    }

    func checkHeadAllocationSize<_PayloadValue>(_ t: _PayloadValue.Type, capacity: Int) throws {
      let allocator = _BucketAllocator(valueType: _PayloadValue.self) { _ in }
      let (byteSize, alignment) = (
        allocator._headAllocationSize(capacity: capacity), allocator._pair.alignment
      )
      let storage = UnsafeMutableRawPointer.allocate(
        byteCount: byteSize + guardByteCount,
        alignment: alignment)
      //      let bytes = storage.bindMemory(to: UInt8.self, capacity: byteSize)
      storage.initializeMemory(as: UInt8.self, repeating: 0xE8, count: byteSize)
      storage.advanced(by: byteSize)
        .initializeMemory(as: UInt8.self, repeating: guardByte, count: guardByteCount)
      let header = storage.assumingMemoryBound(to: _Bucket.self)
      let start = header.start(
        storage: header.primaryStorage(), valueAlignment: MemoryLayout<_PayloadValue>.alignment)
      XCTAssertNotEqual(start, storage)
      XCTAssertEqual(
        Int(bitPattern: header) % MemoryLayout<_Bucket>.alignment, 0,
        "\(_PayloadValue.self): primary bucket header is misaligned")
      XCTAssertEqual(
        Int(bitPattern: header.begin_ptr)
          % MemoryLayout<UnsafeMutablePointer<UnsafeNode>>.alignment,
        0,
        "\(_PayloadValue.self): begin pointer is misaligned")
      XCTAssertEqual(
        Int(bitPattern: header.end_ptr) % MemoryLayout<UnsafeNode>.alignment, 0,
        "\(_PayloadValue.self): end node is misaligned")
      if capacity != 0 {
        XCTAssertEqual(
          Int(bitPattern: start) % MemoryLayout<UnsafeNode>.alignment, 0,
          "\(_PayloadValue.self): first node is misaligned")
        XCTAssertEqual(
          Int(bitPattern: start.__value_(as: _PayloadValue.self))
            % MemoryLayout<_PayloadValue>.alignment,
          0,
          "\(_PayloadValue.self): first payload is misaligned")
      }
      for i in 0..<MemoryLayout<_Bucket>.stride {
        UnsafeMutableRawPointer(header)
          .assumingMemoryBound(to: UInt8.self)
          .advanced(by: i)
          .pointee = 1
      }
      for i in 0..<MemoryLayout<UnsafeMutablePointer<UnsafeNode>>.stride {
        UnsafeMutableRawPointer(header.begin_ptr)
          .assumingMemoryBound(to: UInt8.self)
          .advanced(by: i)
          .pointee = 4
      }
      for i in 0..<MemoryLayout<UnsafeNode>.stride {
        UnsafeMutableRawPointer(header.end_ptr)
          .assumingMemoryBound(to: UInt8.self)
          .advanced(by: i)
          .pointee = 2
      }
      let accessor = _BucketAccessor(pointer: header, start: start, stride: allocator._pair.stride)
      for i in 0..<capacity {
        XCTAssertNotEqual(UnsafeMutableRawPointer(accessor[0]), storage)
        for j in 0..<MemoryLayout<UnsafeNode>.stride {
          UnsafeMutableRawPointer(accessor[i])
            .assumingMemoryBound(to: UInt8.self)
            .advanced(by: j)
            .pointee = 2
        }
        for k in 0..<MemoryLayout<_PayloadValue>.stride {
          UnsafeMutableRawPointer(accessor[i].__value_(as: _PayloadValue.self))
            .assumingMemoryBound(to: UInt8.self)
            .advanced(by: k)
            .pointee = 3
        }
      }
      var counts: [UInt8: Int] = [:]
      for i in 0..<byteSize {
        let byte = storage.assumingMemoryBound(to: UInt8.self).advanced(by: i).pointee
        counts[byte, default: 0] += 1
      }
      // 数が合わない場合、メモリ範囲が重なっている可能性がある
      XCTAssertEqual(counts[1], MemoryLayout<_Bucket>.stride)
      XCTAssertEqual(counts[4], MemoryLayout<UnsafeMutablePointer<UnsafeNode>>.stride)
      XCTAssertEqual(counts[2], MemoryLayout<UnsafeNode>.stride * (capacity + 1))
      XCTAssertEqual(counts[3] ?? 0, MemoryLayout<_PayloadValue>.stride * capacity)
      // 最後のpayloadの末尾が確保範囲を越えないこと
      if capacity != 0 {
        XCTAssertLessThanOrEqual(storage.distance(to: start), byteSize, "\(_PayloadValue.self)")
        let lastPayloadEnd = UnsafeMutableRawPointer(
          accessor[capacity - 1].__value_(as: _PayloadValue.self)
        ).advanced(by: MemoryLayout<_PayloadValue>.stride)
        XCTAssertLessThanOrEqual(
          storage.distance(to: lastPayloadEnd), byteSize, "\(_PayloadValue.self)")
      } else {
        // capacityが0の場合、確保サイズにアライメント調整分が含まれないため、startは範囲外を示す
        // capacity == 0の場合、ヘッダとbegin ptrとend nodeピッタリのサイズとなる
        XCTAssertLessThanOrEqual(
          byteSize,
          MemoryLayout<_Bucket>.stride
            + MemoryLayout<UnsafeMutablePointer<UnsafeNode>>.stride
            + MemoryLayout<UnsafeNode>.stride,
          "\(_PayloadValue.self)")
      }

      assertTrailingGuardIsIntact(storage: storage, allocationSize: byteSize)

      storage.deallocate()
    }

    func testOtherAllocationSize() throws {
      for n in (0..<12).map({ 1 << $0 }) {
        try checkOtherAllocationSize(Int8.self, capacity: n)
        try checkOtherAllocationSize(Int16.self, capacity: n)
        try checkOtherAllocationSize(Int32.self, capacity: n)
        try checkOtherAllocationSize(Int64.self, capacity: n)
        if #available(macOS 15.0, *) {
          try checkOtherAllocationSize(Int128.self, capacity: n)
        }
        try checkOtherAllocationSize(Int.self, capacity: n)
        try checkOtherAllocationSize(SIMD2<Int>.self, capacity: n)
        try checkOtherAllocationSize(SIMD3<Int>.self, capacity: n)
        try checkOtherAllocationSize(SIMD4<Int>.self, capacity: n)
        try checkOtherAllocationSize(SIMD8<Int>.self, capacity: n)
        try checkOtherAllocationSize(SIMD16<Int>.self, capacity: n)
        try checkOtherAllocationSize(SIMD32<Int>.self, capacity: n)
      }
    }

    func testPayloadAlignmentIsPreservedAcrossElements() throws {
      typealias Payload = SIMD4<Float>

      let allocator = _BucketAllocator(valueType: Payload.self) { _ in }
      let capacity = 4
      let byteSize = allocator._allocationSizeNonzero(capacity: capacity)
      let storage = UnsafeMutableRawPointer.allocate(
        byteCount: byteSize,
        alignment: allocator._pair.alignment)
      defer { storage.deallocate() }

      let header = storage.assumingMemoryBound(to: _Bucket.self)
      let start = header.start(
        storage: header.secondaryStorage(),
        valueAlignment: MemoryLayout<Payload>.alignment)
      let accessor = _BucketAccessor(
        pointer: header,
        start: start,
        stride: allocator._pair.stride)

      for index in 0..<capacity {
        let payload = UnsafeMutableRawPointer(accessor[index].__value_(as: Payload.self))
        XCTAssertEqual(
          Int(bitPattern: payload) % MemoryLayout<Payload>.alignment,
          0,
          "payload at index \(index) is misaligned")
      }
    }

    func testHeadAllocationEndsAtLastPayload() throws {
      for capacity in [1, 2, 3, 16] {
        checkHeadAllocationEndsAtLastPayload(Int8.self, capacity: capacity)
        checkHeadAllocationEndsAtLastPayload(Int16.self, capacity: capacity)
        checkHeadAllocationEndsAtLastPayload(Int32.self, capacity: capacity)
        checkHeadAllocationEndsAtLastPayload(Int64.self, capacity: capacity)
        checkHeadAllocationEndsAtLastPayload(SIMD4<Float>.self, capacity: capacity)
        checkHeadAllocationEndsAtLastPayload(SIMD4<Int>.self, capacity: capacity)
        checkHeadAllocationEndsAtLastPayload(SIMD8<Int>.self, capacity: capacity)
      }
    }

    func testOtherAllocationEndsAtLastPayload() throws {
      for capacity in [1, 2, 3, 16] {
        checkOtherAllocationEndsAtLastPayload(Int8.self, capacity: capacity)
        checkOtherAllocationEndsAtLastPayload(Int16.self, capacity: capacity)
        checkOtherAllocationEndsAtLastPayload(Int32.self, capacity: capacity)
        checkOtherAllocationEndsAtLastPayload(Int64.self, capacity: capacity)
        checkOtherAllocationEndsAtLastPayload(SIMD4<Float>.self, capacity: capacity)
        checkOtherAllocationEndsAtLastPayload(SIMD4<Int>.self, capacity: capacity)
        checkOtherAllocationEndsAtLastPayload(SIMD8<Int>.self, capacity: capacity)
      }
    }

    private func checkHeadAllocationEndsAtLastPayload<Payload>(
      _ payloadType: Payload.Type,
      capacity: Int,
      file: StaticString = #filePath,
      line: UInt = #line
    ) {
      let allocator = _BucketAllocator(valueType: Payload.self) { _ in }
      let byteSize = allocator._headAllocationSize(capacity: capacity)
      let storage = UnsafeMutableRawPointer.allocate(
        byteCount: byteSize,
        alignment: allocator._pair.alignment)
      defer { storage.deallocate() }

      let header = storage.assumingMemoryBound(to: _Bucket.self)
      let start = header.start(
        storage: header.primaryStorage(),
        valueAlignment: MemoryLayout<Payload>.alignment)
      let lastNode = UnsafeMutableRawPointer(start)
        .advanced(by: allocator._pair.stride * (capacity - 1))
        .assumingMemoryBound(to: UnsafeNode.self)
      let lastPayloadEnd = UnsafeMutableRawPointer(lastNode.__value_(as: Payload.self))
        .advanced(by: MemoryLayout<Payload>.stride)
      let allocationEnd = storage.advanced(by: byteSize)

      XCTAssertEqual(
        lastPayloadEnd,
        allocationEnd,
        "primary bucket has trailing unused bytes for \(Payload.self), capacity \(capacity)",
        file: file,
        line: line)
    }

    private func checkOtherAllocationEndsAtLastPayload<Payload>(
      _ payloadType: Payload.Type,
      capacity: Int,
      file: StaticString = #filePath,
      line: UInt = #line
    ) {
      let allocator = _BucketAllocator(valueType: Payload.self) { _ in }
      let byteSize = allocator._allocationSizeNonzero(capacity: capacity)
      let storage = UnsafeMutableRawPointer.allocate(
        byteCount: byteSize,
        alignment: allocator._pair.alignment)
      defer { storage.deallocate() }

      let header = storage.assumingMemoryBound(to: _Bucket.self)
      let start = header.start(
        storage: header.secondaryStorage(),
        valueAlignment: MemoryLayout<Payload>.alignment)
      let lastNode = UnsafeMutableRawPointer(start)
        .advanced(by: allocator._pair.stride * (capacity - 1))
        .assumingMemoryBound(to: UnsafeNode.self)
      let lastPayloadEnd = UnsafeMutableRawPointer(lastNode.__value_(as: Payload.self))
        .advanced(by: MemoryLayout<Payload>.stride)
      let allocationEnd = storage.advanced(by: byteSize)

      XCTAssertEqual(
        lastPayloadEnd,
        allocationEnd,
        "secondary bucket has trailing unused bytes for \(Payload.self), capacity \(capacity)",
        file: file,
        line: line)
    }

    func checkOtherAllocationSize<_PayloadValue>(_ t: _PayloadValue.Type, capacity: Int) throws {
      let allocator = _BucketAllocator(valueType: _PayloadValue.self) { _ in }
      let (byteSize, alignment) = (
        allocator._allocationSize(capacity: capacity), allocator._pair.alignment
      )
      let storage = UnsafeMutableRawPointer.allocate(
        byteCount: byteSize + guardByteCount,
        alignment: alignment)
      //      let bytes = storage.bindMemory(to: UInt8.self, capacity: byteSize)
      storage.initializeMemory(as: UInt8.self, repeating: 0xE8, count: byteSize)
      storage.advanced(by: byteSize)
        .initializeMemory(as: UInt8.self, repeating: guardByte, count: guardByteCount)
      let header = storage.assumingMemoryBound(to: _Bucket.self)
      let start =
        storage
        .assumingMemoryBound(to: _Bucket.self)
        .start(
          storage: header.secondaryStorage(), valueAlignment: MemoryLayout<_PayloadValue>.alignment)
      XCTAssertNotEqual(start, storage)
      XCTAssertEqual(
        Int(bitPattern: header) % MemoryLayout<_Bucket>.alignment, 0,
        "\(_PayloadValue.self): secondary bucket header is misaligned")
      XCTAssertEqual(
        Int(bitPattern: start) % MemoryLayout<UnsafeNode>.alignment, 0,
        "\(_PayloadValue.self): first node is misaligned")
      XCTAssertEqual(
        Int(bitPattern: start.__value_(as: _PayloadValue.self))
          % MemoryLayout<_PayloadValue>.alignment,
        0,
        "\(_PayloadValue.self): first payload is misaligned")
      for i in 0..<MemoryLayout<_Bucket>.stride {
        storage
          .assumingMemoryBound(to: UInt8.self)
          .advanced(by: i)
          .pointee = 1
      }
      let accessor = _BucketAccessor(pointer: header, start: start, stride: allocator._pair.stride)
      for i in 0..<capacity {
        XCTAssertNotEqual(UnsafeMutableRawPointer(accessor[0]), storage)
        for j in 0..<MemoryLayout<UnsafeNode>.stride {
          UnsafeMutableRawPointer(accessor[i])
            .assumingMemoryBound(to: UInt8.self)
            .advanced(by: j)
            .pointee = 2
        }
        for k in 0..<MemoryLayout<_PayloadValue>.stride {
          UnsafeMutableRawPointer(accessor[i].__value_(as: _PayloadValue.self))
            .assumingMemoryBound(to: UInt8.self)
            .advanced(by: k)
            .pointee = 3
        }
      }
      var counts: [UInt8: Int] = [:]
      for i in 0..<byteSize {
        let byte = storage.assumingMemoryBound(to: UInt8.self).advanced(by: i).pointee
        counts[byte, default: 0] += 1
      }
      // 数が合わない場合、メモリ範囲が重なっている可能性がある
      XCTAssertEqual(counts[1], MemoryLayout<_Bucket>.stride)
      XCTAssertEqual(counts[2], MemoryLayout<UnsafeNode>.stride * capacity)
      XCTAssertEqual(counts[3], MemoryLayout<_PayloadValue>.stride * capacity)
      // 最後のpayloadの末尾が確保範囲を越えないこと
      let lastPayloadEnd = UnsafeMutableRawPointer(
        accessor[capacity - 1].__value_(as: _PayloadValue.self)
      ).advanced(by: MemoryLayout<_PayloadValue>.stride)
      XCTAssertLessThanOrEqual(storage.distance(to: lastPayloadEnd), byteSize)

      // 追加分に関して容量0は許容しない仕様なので、テストしていない

      assertTrailingGuardIsIntact(storage: storage, allocationSize: byteSize)

      storage.deallocate()
    }

    private func assertTrailingGuardIsIntact(
      storage: UnsafeMutableRawPointer,
      allocationSize: Int,
      file: StaticString = #filePath,
      line: UInt = #line
    ) {
      let guardStart = storage.advanced(by: allocationSize).assumingMemoryBound(to: UInt8.self)
      for offset in 0..<guardByteCount {
        XCTAssertEqual(
          guardStart.advanced(by: offset).pointee,
          guardByte,
          "write exceeded the logical allocation by \(offset + 1) byte(s)",
          file: file,
          line: line)
      }
    }

    func testEmptyDeinitializerDoNothingSmoke() throws {
      let emptyAllocator = _BucketAllocator.create()
      let memory = UnsafeMutableRawPointer.allocate(
        byteCount: MemoryLayout<Int>.stride,
        alignment: MemoryLayout<Int>.alignment)
      let buf = memory.bindMemory(to: Int.self, capacity: 1)
      buf.initialize(to: .zero)
      emptyAllocator.deinitialize(memory)
      XCTAssertEqual(buf.pointee, .zero)
      emptyAllocator.deinitialize(memory)
      buf.deinitialize(count: 1)
      memory.deallocate()
    }
  }
#endif
