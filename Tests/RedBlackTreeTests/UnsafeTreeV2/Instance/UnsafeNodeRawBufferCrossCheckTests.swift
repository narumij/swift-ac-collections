//
//  UnsafeNodeRawBufferCrossCheckTests.swift
//  swift-ac-collections
//

import XCTest
import RedBlackTreeFixture

#if DEBUG
  @testable import RedBlackTreeCollections

  /// `UnsafeNode`(原木の参照計算、`RedBlackTreeFixture/UnsafeNodeReferenceFixture.swift`)と
  /// `RawBuffer`(`_BucketAllocator`の手で最適化された実装、`RawBufferHeadFixture.swift`)が、
  /// 同じpayload型・容量に対して同じメモリ配置を導くことを確認する。
  final class UnsafeNodeRawBufferCrossCheckTests: XCTestCase {

    /// 組の歩幅(pairStride)が、参照計算側とRawBuffer側で一致すること。
    func testPairStrideMatchesAcrossLayers() throws {
      for n in [1, 2, 3, 16] {
        try checkPairStride(Int8.self, capacity: n)
        try checkPairStride(Int16.self, capacity: n)
        try checkPairStride(Int32.self, capacity: n)
        try checkPairStride(Int64.self, capacity: n)
        try checkPairStride(SIMD4<Float>.self, capacity: n)
        try checkPairStride(SIMD4<Int>.self, capacity: n)
        try checkPairStride(RedBlackTreePair<Int32, Int32>.self, capacity: n)
        try checkPairStride(RedBlackTreePair<Int32, Int>.self, capacity: n)
        try checkPairStride(RedBlackTreePair<Int, Int32>.self, capacity: n)
        try checkPairStride(RedBlackTreePair<Int, SIMD4<Int>>.self, capacity: n)
      }
    }

    private func checkPairStride<Payload>(
      _ payloadType: Payload.Type,
      capacity: Int,
      file: StaticString = #filePath,
      line: UInt = #line
    ) throws {
      let reference = UnsafeNodeReferenceFixture<Payload>(capacity: capacity)
//      defer { reference.deallocate() }
      let rawBuffer = RawBufferHeadFixture<Payload>(capacity: capacity)
//      defer { rawBuffer.deallocate() }

      XCTAssertEqual(
        reference.pairStride,
        rawBuffer.pairStride,
        "\(Payload.self): pairStride differs between UnsafeNode reference and RawBuffer",
        file: file,
        line: line)
    }

    /// 各要素のノード間隔・payloadオフセットが、参照計算側とRawBuffer側で
    /// 先頭要素からの相対距離として一致すること。
    func testPerElementOffsetsMatchAcrossLayers() throws {
      for n in [1, 2, 3, 16] {
        try checkOffsets(Int8.self, capacity: n)
        try checkOffsets(Int16.self, capacity: n)
        try checkOffsets(Int32.self, capacity: n)
        try checkOffsets(Int64.self, capacity: n)
        try checkOffsets(SIMD4<Float>.self, capacity: n)
        try checkOffsets(SIMD4<Int>.self, capacity: n)
        try checkOffsets(RedBlackTreePair<Int32, Int32>.self, capacity: n)
        try checkOffsets(RedBlackTreePair<Int32, Int>.self, capacity: n)
        try checkOffsets(RedBlackTreePair<Int, Int32>.self, capacity: n)
        try checkOffsets(RedBlackTreePair<Int, SIMD4<Int>>.self, capacity: n)
      }
    }

    private func checkOffsets<Payload>(
      _ payloadType: Payload.Type,
      capacity: Int,
      file: StaticString = #filePath,
      line: UInt = #line
    ) throws {
      let reference = UnsafeNodeReferenceFixture<Payload>(capacity: capacity)
//      defer { reference.deallocate() }
      let rawBuffer = RawBufferHeadFixture<Payload>(capacity: capacity)
//      defer { rawBuffer.deallocate() }

      for i in 0..<capacity {
        let referenceNodeOffset = UnsafeMutableRawPointer(reference.node(at: 0))
          .distance(to: UnsafeMutableRawPointer(reference.node(at: i)))
        let rawBufferNodeOffset = UnsafeMutableRawPointer(rawBuffer.node(at: 0))
          .distance(to: UnsafeMutableRawPointer(rawBuffer.node(at: i)))
        XCTAssertEqual(
          referenceNodeOffset,
          rawBufferNodeOffset,
          "\(Payload.self), capacity \(capacity): node offset at index \(i) differs",
          file: file,
          line: line)

        let referencePayloadOffset = UnsafeMutableRawPointer(reference.node(at: 0))
          .distance(to: UnsafeMutableRawPointer(reference.payload(at: i)))
        let rawBufferPayloadOffset = UnsafeMutableRawPointer(rawBuffer.node(at: 0))
          .distance(to: UnsafeMutableRawPointer(rawBuffer.payload(at: i)))
        XCTAssertEqual(
          referencePayloadOffset,
          rawBufferPayloadOffset,
          "\(Payload.self), capacity \(capacity): payload offset at index \(i) differs",
          file: file,
          line: line)
      }
    }
  }
#endif
