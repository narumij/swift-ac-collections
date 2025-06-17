//
//  TupleMapTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/06/16.
//

import XCTest

#if DEBUG
@testable import RedBlackTreeModule
#else
import RedBlackTreeModule
#endif

@usableFromInline
struct Parameter<each T> {
  
  public
    typealias Tuple = (repeat each T)

  @usableFromInline
  var tuple: Tuple
  
  @inlinable @inline(__always)
  public init(values: (repeat each T)) {
    self.tuple = (repeat each values)
  }
  
  @inlinable @inline(__always)
  public init(_ values: repeat each T) {
    self.tuple = (repeat each values)
  }
}

extension Parameter: Equatable where repeat each T: Equatable {
  
  @inlinable
  static func == (lhs: Parameter<repeat each T>, rhs: Parameter<repeat each T>) -> Bool {
    for (l, r) in repeat (each lhs.tuple, each rhs.tuple) {
      if l != r {
        return false
      }
    }
    return true
  }
}

extension Parameter: Comparable where repeat each T: Comparable {
  
  @inlinable
  static func < (lhs: Parameter<repeat each T>, rhs: Parameter<repeat each T>) -> Bool {
    for (l, r) in repeat (each lhs.tuple, each rhs.tuple) {
      if l != r {
        return l < r
      }
    }
    return false
  }
}

extension Parameter: _KeyCustomProtocol where repeat each T: Comparable {

  @inlinable
  static func value_comp(_ lhs: Parameter<repeat each T>, _ rhs: Parameter<repeat each T>) -> Bool {
    for (l, r) in repeat (each lhs.tuple, each rhs.tuple) {
      if l != r {
        return l < r
      }
    }
    return false
  }
}

extension Parameter: Hashable where repeat each T: Hashable {
  
  @inlinable
  func hash(into hasher: inout Hasher) {
    for l in repeat (each tuple) {
      hasher.combine(l)
    }
  }
}

#if DEBUG
final class TupleMapTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testInit() throws {
    let a: RedBlackTreeTupleMap<Int, Int> = [1: 1]
    let b: RedBlackTreeTupleMap<Int, Int, Int> = [(1, 1): 1]
    let c: RedBlackTreeTupleMap<Int, Int, Int, Int> = [(1, 1, 1): 1]
    let d: RedBlackTreeTupleMap<Int, Int, Int, Int, Int> = [(1, 1, 1, 1): 1]
    XCTAssertEqual(a[1], 1)
    XCTAssertEqual(b[(1, 1)], 1)
    XCTAssertEqual(c[(1, 1, 1)], 1)
    XCTAssertEqual(d[(1, 1, 1, 1)], 1)
    let e: RedBlackTreeTupleMap<Int, UInt, String, Int, Int> = [(1, 1, "", 1): 1]
  }
  
  func testInit2() throws {
    let a: [Parameter<Int>: Int] = [.init(1): 1]
    let b: [Parameter<Int,Int>: Int] = [.init(1, 1): 1]
    let c: [Parameter<Int,Int,Int>: Int] = [.init(1, 1, 1): 1]
    let d: [Parameter<Int,Int,Int,Int>: Int] = [.init(1, 1, 1, 1): 1]
    XCTAssertEqual(a[.init(1)], 1)
    XCTAssertEqual(b[.init(1, 1)], 1)
    XCTAssertEqual(c[.init(1, 1, 1)], 1)
    XCTAssertEqual(d[.init(1, 1, 1, 1)], 1)
    let e: [Parameter<Int, UInt, String, Int>: Int] = [.init(1, 1, "", 1): 1]
  }

  func test2() throws {
    var b: RedBlackTreeTupleMap<Int, Int, Int> = [:]
    b.set(1, forKey: (1, 2))
    b.set(2, forKey: (3, 4))
    b.set(3, forKey: (5, 6))
    XCTAssertEqual(b[(1, 2)], 1)
    XCTAssertEqual(b[(3, 4)], 2)
    XCTAssertEqual(b[(5, 6)], 3)
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}
#endif
