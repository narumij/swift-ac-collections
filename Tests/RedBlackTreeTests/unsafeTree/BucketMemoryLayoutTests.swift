#if DEBUG
  @testable import RedBlackTreeCollections
  import XCTest

  extension _BucketQueue {

    // テストで使っている
    @inlinable
    subscript(index: Int) -> UnsafeMutablePointer<UnsafeNode> {
      UnsafeMutableRawPointer(startNode)
        .advanced(by: pairStride &* index)
        .assumingMemoryBound(to: UnsafeNode.self)
    }
  }

  extension _BucketTraverser {

    #if true
      // テストで使っている
      @inlinable
      subscript(index: Int) -> _NodePtr {
        @inline(__always) _read {
          yield
          UnsafeMutableRawPointer(startNode)
            .advanced(by: pairStride &* index)
            .assumingMemoryBound(to: UnsafeNode.self)
        }
      }
    #else
      // なんちゃってABC411Fのベンチが2.2倍も速くなって、嬉しいけど逆に不安
      // やっぱり壊れていた
      @inlinable
      subscript(index: Int) -> _NodePtr {
        @inline(__always)
        unsafeAddress {
          withUnsafePointer(
            to: UnsafeMutableRawPointer(start)
              .advanced(by: stride &* index)
              .assumingMemoryBound(to: UnsafeNode.self)
          ) {
            $0
          }
        }
      }
    #endif
  }

  final class BucketMemoryLayoutTests: XCTestCase {

    func testBucketComponentsUsePairStride() {
      typealias Payload = SIMD4<Float>

      let pairLayout = MemoryLayout<Payload>._pairLayout
      let bucket = UnsafeMutablePointer<_Bucket>.allocate(capacity: 1)
      bucket.initialize(to: .init(capacity: 2))
      defer {
        bucket.deinitialize(count: 1)
        bucket.deallocate()
      }

      let queue = bucket._queue(isPrimary: false, pairLayout: pairLayout)
      let accessor = bucket._accessor(isPrimary: false, pairLayout: pairLayout)
      let traverser = bucket._counts(
        storage: bucket.secondaryStorage(),
        nodeLayout: MemoryLayout<UnsafeNode>._memoryLayout,
        pairLayout: pairLayout
      )

      XCTAssertEqual(distance(from: queue[0], to: queue[1]), pairLayout.stride)
      XCTAssertEqual(distance(from: accessor[0], to: accessor[1]), pairLayout.stride)
      XCTAssertEqual(distance(from: traverser[0], to: traverser[1]), pairLayout.stride)
    }

    private func distance(
      from first: UnsafeMutablePointer<UnsafeNode>,
      to second: UnsafeMutablePointer<UnsafeNode>
    ) -> Int {
      UnsafeMutableRawPointer(first).distance(to: UnsafeMutableRawPointer(second))
    }
  }
#endif
