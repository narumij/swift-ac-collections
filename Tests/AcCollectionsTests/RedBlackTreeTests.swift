import XCTest
@testable import AcCollections

extension _RedBlackTree {
    mutating func ensureCapacity(minimumCapacity: Int) {
        storage = storage.ensureCapacity(minimumCapacity: minimumCapacity)
    }
}

final class RedBlackTreeTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
    
    func testBuffer() throws {
        
        let buffer = ManagedBuffer<(Int,Int),Int>.create(minimumCapacity: 5) { (3, $0.capacity) }
        XCTAssertEqual(6, buffer.capacity)
    }
    
    typealias __tree = _RedBlackTree<Int,_red_brack_tree_comparable_compare<Int>>
    
    func testRotate0() throws {
        var handle = __tree()
        handle.ensureCapacity(minimumCapacity: 7)
        handle.storage.__update {
            $0.__root = $0.pointer(6)
            $0.__root.__left_ = $0.pointer(5) // rotate target 1
            $0.__root.__left_.__right_ = $0.pointer(4)
            $0.__root.__left_.__left_ = $0.pointer(3) // rotate target 2
            $0.__root.__left_.__left_.__right_ = $0.pointer(2) // move node
            $0.__root.__left_.__left_.__left_ = $0.pointer(1)
            
            $0.__root.__parent_ = $0.__end_node
            $0.__root.__left_.__parent_ = $0.__root
            $0.__root.__left_.__right_.__parent_ = $0.__root.__left_
            $0.__root.__left_.__left_.__parent_ = $0.__root.__left_
            $0.__root.__left_.__left_.__right_.__parent_ = $0.__root.__left_.__left_
            $0.__root.__left_.__left_.__left_.__parent_ = $0.__root.__left_.__left_
        }
        XCTAssertEqual(0, handle.storage[6].__parent_)
        XCTAssertEqual(6, handle.storage[5].__parent_)
        XCTAssertEqual(5, handle.storage[4].__parent_)
        XCTAssertEqual(5, handle.storage[3].__parent_)
        XCTAssertEqual(3, handle.storage[2].__parent_)
        XCTAssertEqual(3, handle.storage[1].__parent_)
//        XCTAssertEqual(6, handle.root)
    }

    func testRotate1() throws {
        var handle = __tree()
        handle.ensureCapacity(minimumCapacity: 7)
        handle.storage.__update {
            
            $0.__root = $0.pointer(6)
            $0.__root.__left_ = $0.pointer(5) // rotate target 1
            $0.__root.__left_.__right_ = $0.pointer(4)
            $0.__root.__left_.__left_ = $0.pointer(3) // rotate target 2
            $0.__root.__left_.__left_.__right_ = $0.pointer(2) // move node
            $0.__root.__left_.__left_.__left_ = $0.pointer(1)
            
            $0.__root.__parent_ = $0.__end_node
            $0.__root.__left_.__parent_ = $0.__root
            $0.__root.__left_.__right_.__parent_ = $0.__root.__left_
            $0.__root.__left_.__left_.__parent_ = $0.__root.__left_
            $0.__root.__left_.__left_.__right_.__parent_ = $0.__root.__left_.__left_
            $0.__root.__left_.__left_.__left_.__parent_ = $0.__root.__left_.__left_

            $0.__tree_right_rotate($0.pointer(5))
        }
        XCTAssertEqual(0, handle.storage[6].__parent_)
        XCTAssertEqual(3, handle.storage[5].__parent_)
        XCTAssertEqual(5, handle.storage[4].__parent_)
        XCTAssertEqual(6, handle.storage[3].__parent_)
        XCTAssertEqual(5, handle.storage[2].__parent_)
        XCTAssertEqual(3, handle.storage[1].__parent_)
//        XCTAssertEqual(6, handle.root)
    }
    
    func testRotate2() throws {
        var handle = __tree()
        handle.ensureCapacity(minimumCapacity: 8)
        handle.storage.__update {
            $0.__root = $0.pointer(6)
            $0.__root.__left_ = $0.pointer(5) // rotate target 1
            $0.__root.__left_.__right_ = $0.pointer(4)
            $0.__root.__left_.__left_ = $0.pointer(3) // rotate target 2
            $0.__root.__left_.__left_.__right_ = $0.pointer(2) // move node
            $0.__root.__left_.__left_.__left_ = $0.pointer(1)
            
            $0.__root.__parent_ = $0.__end_node
            $0.__root.__left_.__parent_ = $0.__root
            $0.__root.__left_.__right_.__parent_ = $0.__root.__left_
            $0.__root.__left_.__left_.__parent_ = $0.__root.__left_
            $0.__root.__left_.__left_.__right_.__parent_ = $0.__root.__left_.__left_
            $0.__root.__left_.__left_.__left_.__parent_ = $0.__root.__left_.__left_

            $0.__tree_right_rotate($0.pointer(5))
            $0.__tree_left_rotate($0.pointer(3))
        }
        XCTAssertEqual(0, handle.storage[6].__parent_)
        XCTAssertEqual(6, handle.storage[5].__parent_)
        XCTAssertEqual(5, handle.storage[4].__parent_)
        XCTAssertEqual(5, handle.storage[3].__parent_)
        XCTAssertEqual(3, handle.storage[2].__parent_)
        XCTAssertEqual(3, handle.storage[1].__parent_)
//        XCTAssertEqual(6, handle.root)
    }
    
    func testRotate3() throws {
        var handle = __tree()
        handle.ensureCapacity(minimumCapacity: 8)
        handle.storage.__update {
            $0.__root = $0.pointer(6)
            $0.__root.__left_ = $0.pointer(5) // rotate target 1
            $0.__root.__left_.__right_ = $0.pointer(4)
            $0.__root.__left_.__left_ = $0.pointer(3) // rotate target 2
            $0.__root.__left_.__left_.__right_ = $0.pointer(2) // move node
            $0.__root.__left_.__left_.__left_ = $0.pointer(1)
            
            $0.__root.__parent_ = $0.__end_node
            $0.__root.__left_.__parent_ = $0.__root
            $0.__root.__left_.__right_.__parent_ = $0.__root.__left_
            $0.__root.__left_.__left_.__parent_ = $0.__root.__left_
            $0.__root.__left_.__left_.__right_.__parent_ = $0.__root.__left_.__left_
            $0.__root.__left_.__left_.__left_.__parent_ = $0.__root.__left_.__left_

            $0.__tree_right_rotate($0.pointer(5))
            $0.__tree_left_rotate($0.pointer(3))
            $0.__tree_right_rotate($0.pointer(5))
        }
        XCTAssertEqual(0, handle.storage[6].__parent_)
        XCTAssertEqual(3, handle.storage[5].__parent_)
        XCTAssertEqual(5, handle.storage[4].__parent_)
        XCTAssertEqual(6, handle.storage[3].__parent_)
        XCTAssertEqual(5, handle.storage[2].__parent_)
        XCTAssertEqual(3, handle.storage[1].__parent_)
//        XCTAssertEqual(6, handle.root)
    }
    
    func testUsageX() throws {
        let count = 10
        var handle = __tree()
        XCTAssertEqual([__tree._Node()], handle.storage.array)
        for i in 0..<count {
            handle.insert(i)
        }
        XCTAssertEqual(count, handle.count)
        XCTAssertTrue(handle.storage.isValid())
        for i in 0..<count {
            handle.remove(i)
        }
        XCTAssertEqual(0, handle.count)
        XCTAssertTrue(handle.storage.isValid())
    }
    
    func testUsageY() throws {
        let count = 10
        var handle = __tree()
        XCTAssertEqual([__tree._Node()], handle.storage.array)
        for i in stride(from: count, to: 0, by: -1) {
            handle.insert(i)
        }
        XCTAssertEqual(count, handle.count)
        XCTAssertTrue(handle.storage.isValid())
        for i in stride(from: count, to: 0, by: -1) {
            handle.remove(i)
        }
        XCTAssertEqual(0, handle.count)
        XCTAssertTrue(handle.storage.isValid())
    }

    func testUsageZ() throws {
        let count = 10
        var handle = __tree()
        XCTAssertEqual([__tree._Node()], handle.storage.array)
        for i in 0..<count {
            handle.insert(i)
        }
        XCTAssertEqual(count, handle.count)
        XCTAssertTrue(handle.storage.isValid())
        XCTAssertEqual(10, stride(from: count, to: 0, by: -1).map{$0}.count)
        for i in (0..<count).reversed() {
            handle.remove(i)
        }
        XCTAssertEqual(0, handle.count)
        XCTAssertTrue(handle.storage.isValid())
    }

    func testUsageW() throws {
        let count = 10
        var handle = __tree()
        XCTAssertEqual([__tree._Node()], handle.storage.array)
        for i in (0..<count).reversed() {
            handle.insert(i)
        }
        XCTAssertEqual(count, handle.count)
        XCTAssertTrue(handle.storage.isValid())
        for i in 0..<count {
            handle.remove(i)
        }
        XCTAssertEqual(0, handle.count)
        XCTAssertTrue(handle.storage.isValid())
    }
    
    func runUsageX2(count: Int, range: ClosedRange<Int>) throws {
        
        let nums = (0..<count).compactMap{ _ in Int.random(in: range) }
        
        var handle = __tree()
        
        for n in nums.shuffled() {
            handle.insert(n)
        }
        XCTAssertTrue(handle.storage.isValid())

        for n in nums.shuffled() {
            handle.remove(n)
        }
        
        XCTAssertEqual(0, handle.count)
        XCTAssertTrue(handle.storage.isValid())
    }

    func testUsageX1() throws {
        try runUsageX2(count: 20, range: 0...5)
    }

    func testUsageX2() throws {
        try runUsageX2(count: 2_000, range: 0...4_000)
    }
    
    func testUsageX3() throws {
        try (0..<1000).forEach { _ in
            try runUsageX2(count: 100, range: -25...25)
        }
    }
    
}
