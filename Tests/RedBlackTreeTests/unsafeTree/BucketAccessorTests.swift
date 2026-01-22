//
//  BucketAccessorTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/21.
//

import RedBlackTreeModule
import XCTest

final class BucketAccessorTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  #if !DEBUG
  func testPerformanceExample() throws {
    
    typealias _Value = Int
    
    let capacity = 1_000_000
    let allocator = _BucketAllocator(valueType: _Value.self) { _ in }
    let (byteSize, alignment) = allocator.otherCapacity(capacity: capacity)
    let storage = UnsafeMutableRawPointer.allocate(byteCount: byteSize, alignment: alignment)
    let header = storage.assumingMemoryBound(to: _UnsafeNodeFreshBucket.self)
    let accessor = _BucketAccessor(
      pointer: header,
      start: header.start(isHead: false, valueAlignment: MemoryLayout<_Value>.alignment),
      stride: allocator._pair.stride)
    for i in 0..<capacity {
      accessor[i].initialize(to: .create(id: .zero))
      accessor[i].__value_(as: _Value.self).initialize(to: .zero)
    }
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
      var sum = 0
      for _ in 0..<1_000_000 {
        for j in 0..<capacity {
          sum += accessor[j].pointee.___raw_index
        }
      }
    }
    
    storage.deallocate()
  }
  #endif
}
