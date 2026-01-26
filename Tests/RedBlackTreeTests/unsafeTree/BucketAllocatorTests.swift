//
//  BucketAllocatorTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/21.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule

  final class BucketAllocatorTests: RedBlackTreeTestCase {

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
        try checkHeadAllocationSize(Int128.self, capacity: n)
        try checkHeadAllocationSize(Int.self, capacity: n)
        try checkHeadAllocationSize(SIMD2<Int>.self, capacity: n)
        try checkHeadAllocationSize(SIMD3<Int>.self, capacity: n)
        try checkHeadAllocationSize(SIMD4<Int>.self, capacity: n)
        try checkHeadAllocationSize(SIMD8<Int>.self, capacity: n)
        try checkHeadAllocationSize(SIMD16<Int>.self, capacity: n)
        try checkHeadAllocationSize(SIMD32<Int>.self, capacity: n)
      }
    }

    func checkHeadAllocationSize<_RawValue>(_ t: _RawValue.Type, capacity: Int) throws {
      let allocator = _BucketAllocator(valueType: _RawValue.self) { _ in }
      var (byteSize, alignment) = (allocator.otherCapacity(capacity: capacity), allocator._pair.alignment)
      byteSize += MemoryLayout<UnsafeMutablePointer<UnsafeNode>>.stride
      byteSize += MemoryLayout<UnsafeNode>.stride
      let storage = UnsafeMutableRawPointer.allocate(byteCount: byteSize, alignment: alignment)
      //      let bytes = storage.bindMemory(to: UInt8.self, capacity: byteSize)
      storage.initializeMemory(as: UInt8.self, repeating: 0xE8, count: byteSize)
      let header = storage.assumingMemoryBound(to: _Bucket.self)
      let start = header.start(isHead: true, valueAlignment: MemoryLayout<_RawValue>.alignment)
      XCTAssertNotEqual(start, storage)
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
        for k in 0..<MemoryLayout<_RawValue>.stride {
          UnsafeMutableRawPointer(accessor[i].__value_(as: _RawValue.self))
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
      XCTAssertEqual(counts[3] ?? 0, MemoryLayout<_RawValue>.stride * capacity)
      // capacity番目の開始アドレスとは、確保メモリの末尾の次
      // 数が多い場合、確保範囲を越えて書いている可能性がある
      // アライメント調整は確保アドレスに応じて変動する
      if capacity != 0 {
        XCTAssertLessThanOrEqual(storage.distance(to: start), byteSize, "\(_RawValue.self)")
        XCTAssertLessThanOrEqual(
          storage.distance(to: accessor[capacity]), byteSize, "\(_RawValue.self)")
      } else {
        // capacityが0の場合、確保サイズにアライメント調整分が含まれないため、startは範囲外を示す
        // capacity == 0の場合、ヘッダとbegin ptrとend nodeピッタリのサイズとなる
        XCTAssertLessThanOrEqual(
          byteSize,
          MemoryLayout<_Bucket>.stride
            + MemoryLayout<UnsafeMutablePointer<UnsafeNode>>.stride
            + MemoryLayout<UnsafeNode>.stride,
          "\(_RawValue.self)")
      }

      storage.deallocate()
    }

    func testOtherAllocationSize() throws {
      for n in (0..<12).map({ 1 << $0 }) {
        try checkOtherAllocationSize(Int8.self, capacity: n)
        try checkOtherAllocationSize(Int16.self, capacity: n)
        try checkOtherAllocationSize(Int32.self, capacity: n)
        try checkOtherAllocationSize(Int64.self, capacity: n)
        try checkOtherAllocationSize(Int128.self, capacity: n)
        try checkOtherAllocationSize(Int.self, capacity: n)
        try checkOtherAllocationSize(SIMD2<Int>.self, capacity: n)
        try checkOtherAllocationSize(SIMD3<Int>.self, capacity: n)
        try checkOtherAllocationSize(SIMD4<Int>.self, capacity: n)
        try checkOtherAllocationSize(SIMD8<Int>.self, capacity: n)
        try checkOtherAllocationSize(SIMD16<Int>.self, capacity: n)
        try checkOtherAllocationSize(SIMD32<Int>.self, capacity: n)
      }
    }

    func checkOtherAllocationSize<_RawValue>(_ t: _RawValue.Type, capacity: Int) throws {
      let allocator = _BucketAllocator(valueType: _RawValue.self) { _ in }
      let (byteSize, alignment) = (allocator.otherCapacity(capacity: capacity), allocator._pair.alignment)
      let storage = UnsafeMutableRawPointer.allocate(byteCount: byteSize, alignment: alignment)
      //      let bytes = storage.bindMemory(to: UInt8.self, capacity: byteSize)
      storage.initializeMemory(as: UInt8.self, repeating: 0xE8, count: byteSize)
      let header = storage.assumingMemoryBound(to: _Bucket.self)
      let start =
        storage
        .assumingMemoryBound(to: _Bucket.self)
        .start(isHead: false, valueAlignment: MemoryLayout<_RawValue>.alignment)
      XCTAssertNotEqual(start, storage)
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
        for k in 0..<MemoryLayout<_RawValue>.stride {
          UnsafeMutableRawPointer(accessor[i].__value_(as: _RawValue.self))
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
      XCTAssertEqual(counts[3], MemoryLayout<_RawValue>.stride * capacity)
      // capacity番目の開始アドレスとは、確保メモリの末尾の次
      // 数が多い場合、確保範囲を越えて書いている可能性がある
      // アライメント調整は確保アドレスに応じて変動する？
      // 最大アライメントに合わせたメモリ確保をしているので、ぴったりに出来そうなきもする
      XCTAssertLessThanOrEqual(storage.distance(to: accessor[capacity]), byteSize)

      // 追加分に関して容量0は許容しない仕様なので、テストしていない

      storage.deallocate()
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
