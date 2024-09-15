//
//  RedBlackSetTests.swift
//  
//
//  Created by narumij on 2023/12/10.
//

import XCTest
@testable import AcCollections

final class RedBlackSetTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInit0() throws {
        let s = RedBlackSet<Int>()
        XCTAssertTrue(s.isEmpty)
        XCTAssertEqual(s.count, 0)
        XCTAssertEqual(s.capacity, 0)
    }
    
    func testInit1() throws {
        let s = RedBlackSet<Int>([0])
        XCTAssertFalse(s.isEmpty)
        XCTAssertEqual(s.count, 1)
        XCTAssertEqual(s.capacity, 1)
    }

    func testInit2() throws {
        let s = RedBlackSet<Int>(minimumCapacity: 10)
        XCTAssertTrue(s.isEmpty)
        XCTAssertEqual(s.count, 0)
        XCTAssertEqual(s.capacity, 10)
    }
    
    func testInsert() throws {
        var s = RedBlackSet<Int>([0,10,20])
        do {
            let r = s.insert(-1)
            XCTAssertTrue(r.inserted)
            XCTAssertEqual(r.memberAfterInsert, -1)
        }
        do {
            let r = s.insert(5)
            XCTAssertTrue(r.inserted)
            XCTAssertEqual(r.memberAfterInsert, 5)
        }
        do {
            let r = s.insert(15)
            XCTAssertTrue(r.inserted)
            XCTAssertEqual(r.memberAfterInsert, 15)
        }
    }
    
    func testUpdate() throws {
        var s = RedBlackSet<Int>([0,10,20])
        do {
            let r = s.update(with: -1)
            XCTAssertEqual(r, -1)
        }
        do {
            let r = s.update(with: 5)
            XCTAssertEqual(r, 5)
        }
        do {
            let r = s.update(with: 15)
            XCTAssertEqual(r, 15)
        }
    }
    
    func testReservedCapacity() throws {
        var s = RedBlackSet<Int>([0,10,20])
        s.reserveCapacity(10)
        XCTAssertTrue(s.capacity >= 10)
        s.reserveCapacity(100)
        XCTAssertTrue(s.capacity >= 100)
        s.reserveCapacity(1000)
        XCTAssertTrue(s.capacity >= 1000)
    }
    
    func testFilter() throws {
        var s = RedBlackSet<Int>([0,10,20])
        XCTAssertEqual(s.filter{ $0 != 0 }, [10,20])
        XCTAssertEqual(s.filter{ $0 != 10 }, [0,20])
        XCTAssertEqual(s.filter{ $0 != 20 }, [0,10])
    }
    
    func testRemove() throws {
        var s = RedBlackSet<Int>([0,10,20])
        XCTAssertEqual(s.remove(0), 0)
        XCTAssertEqual(s.remove(5), nil)
        XCTAssertEqual(s.remove(10), 10)
        XCTAssertEqual(s.remove(15), nil)
        XCTAssertEqual(s.remove(20), 20)
    }

    func testRemoveFirst() throws {
        var s = RedBlackSet<Int>([0,10,20])
        XCTAssertEqual(s.first, 0)
        XCTAssertEqual(s.removeFirst(), 0)
        XCTAssertEqual(s.map{ $0 }, [10,20])
        XCTAssertEqual(s.removeFirst(), 10)
        XCTAssertEqual(s.map{ $0 }, [20])
        XCTAssertEqual(s.removeFirst(), 20)
        XCTAssertEqual(s.map{ $0 }, [])
    }
    
    func testRemoveAll0() throws {
        var s = RedBlackSet<Int>([0,10,20])
        s.removeAll()
        XCTAssertTrue(s.isEmpty)
        XCTAssertEqual(s.count,0)
        XCTAssertEqual(s.capacity, 0)
    }
    
    func testRemoveAll1() throws {
        var s = RedBlackSet<Int>([0,10,20])
        let cap = s.capacity
        s.removeAll(keepingCapacity: true)
        XCTAssertTrue(s.isEmpty)
        XCTAssertEqual(s.count, 0)
        XCTAssertEqual(s.capacity, cap)
    }

    func testEqual() throws {
        XCTAssertEqual(RedBlackSet<Int>(), RedBlackSet<Int>())
        XCTAssertEqual(RedBlackSet<Int>(), RedBlackSet<Int>(minimumCapacity: 100))
        XCTAssertNotEqual(RedBlackSet<Int>(), RedBlackSet<Int>([0,1,2]))
        XCTAssertNotEqual(RedBlackSet<Int>([0,10,20]), RedBlackSet<Int>([0,1,2]))
        XCTAssertEqual(RedBlackSet<Int>([0,1,2]), RedBlackSet<Int>([0,1,2]))
    }

    func testFirst() throws {
        XCTAssertEqual(RedBlackSet<Int>().first, nil)
        XCTAssertEqual(RedBlackSet<Int>(minimumCapacity: 100).first, nil)
        var s = RedBlackSet<Int>([0,10,20])
        XCTAssertEqual(s.first, 0)
        s.removeFirst()
        XCTAssertEqual(s.first, 10)
        s.removeFirst()
        XCTAssertEqual(s.first, 20)
    }

    func testLowerBound() throws {
        var s = RedBlackSet<Int>([0,1,2,3,17,18,19,20])
        let lb = s.lower_bound(10)
        XCTAssertEqual(lb.__ptr_, 4)
        XCTAssertEqual(lb.current(), 17)
        XCTAssertEqual((lb - 1).current(), 3)
        XCTAssertEqual((lb - 1).__ptr_, 3)
        s.remove(at: lb - 1)
        XCTAssertEqual(s.map{ $0 }, [0,1,2,17,18,19,20])
        s.remove(at: lb + 1)
        XCTAssertEqual(s.map{ $0 }, [0,1,2,17,19,20])
        s.remove(at: lb)
        XCTAssertEqual(s.map{ $0 }, [0,1,2,19,20])
    }
    
    func testUpperBound() throws {
        var s = RedBlackSet<Int>([0,1,2,3,17,18,19,20])
        var lb = s.upper_bound(17)
        XCTAssertEqual(lb.__ptr_, 5)
        XCTAssertEqual(lb.current(), 18)
        XCTAssertEqual(lb.next(), 18)
        XCTAssertEqual(lb.current(), 19)
        XCTAssertEqual(lb.__ptr_, 6)
        s.remove(at: lb)
        XCTAssertEqual(s.map{ $0 }, [0,1,2,3,17,18,20])
    }

    func testMinMax() throws {
        XCTAssertEqual(RedBlackSet<Int>().min(), nil)
        XCTAssertEqual(RedBlackSet<Int>(minimumCapacity: 100).min(), nil)
        XCTAssertEqual(RedBlackSet<Int>([0,10,20]).min(), 0)
        XCTAssertEqual(RedBlackSet<Int>().max(), nil)
        XCTAssertEqual(RedBlackSet<Int>(minimumCapacity: 100).max(), nil)
        XCTAssertEqual(RedBlackSet<Int>([0,10,20]).max(), 20)
    }

    func testFind0() throws {
        let s = RedBlackSet<Int>([1,2,3,4])
        XCTAssertEqual(s.storage._update{ $0.find(-1) }.basePtr, .end)
        XCTAssertNotEqual(s.storage._update{ $0.find(0) }.basePtr, .none)
        XCTAssertNotEqual(s.storage._update{ $0.find(1) }.basePtr, .none)
        XCTAssertNotEqual(s.storage._update{ $0.find(2) }.basePtr, .none)
        XCTAssertNotEqual(s.storage._update{ $0.find(3) }.basePtr, .none)
        XCTAssertNotEqual(s.storage._update{ $0.find(4) }.basePtr, .none)
        XCTAssertEqual(s.storage._update{ $0.find(5) }.basePtr, .end)
    }

    func testFind() throws {
        var s = RedBlackSet<Int>()
        s.insert(1)
        s.insert(2)
        s.insert(3)
        s.insert(4)
        XCTAssertEqual(s.storage._update{ $0.find(-1) }.basePtr, .end)
        XCTAssertNotEqual(s.storage._update{ $0.find(0) }.basePtr, .none)
        XCTAssertNotEqual(s.storage._update{ $0.find(1) }.basePtr, .none)
        XCTAssertNotEqual(s.storage._update{ $0.find(2) }.basePtr, .none)
        XCTAssertNotEqual(s.storage._update{ $0.find(3) }.basePtr, .none)
        XCTAssertNotEqual(s.storage._update{ $0.find(4) }.basePtr, .none)
        XCTAssertEqual(s.storage._update{ $0.find(5) }.basePtr, .end)
    }
    
    func testMap() throws {
        var s = RedBlackSet<Int>()
        s.insert(1)
        s.insert(2)
        s.insert(3)
        s.insert(4)
        XCTAssertEqual(s.map{ $0 }, [1,2,3,4])
    }

    func testContains() throws {
        var s = RedBlackSet<Int>()
        s.insert(1)
        s.insert(2)
        s.insert(3)
        s.insert(4)
        XCTAssertFalse(s.contains(0))
        XCTAssertTrue(s.contains(1))
        XCTAssertTrue(s.contains(2))
        XCTAssertTrue(s.contains(3))
        XCTAssertTrue(s.contains(4))
        XCTAssertFalse(s.contains(5))
    }

#if false
    func testPrev() throws {
        var s = RedBlackSet<Int>()
        s.insert(1)
        s.insert(2)
        s.insert(3)
        s.insert(4)
        XCTAssertEqual(nil, s.prev(1))
        XCTAssertEqual(1, s.prev(2))
        XCTAssertEqual(2, s.prev(3))
        XCTAssertEqual(3, s.prev(4))
//        XCTAssertEqual(4, s.prev(5))
    }
    
    func testPrevNext() throws {
        var s = RedBlackSet<Int>()
        s.insert(0)
        s.insert(2)
        XCTAssertEqual(0, s.prev(1))
        XCTAssertEqual(2, s.next(1))
    }
    
    func testPrevNext2() throws {
        var s = RedBlackSet<Int>()
        s.insert(0)
        s.insert(2)
        s.insert(7)
        s.insert(9)
        s.insert(10)
        XCTAssertEqual(2, s.prev(3))
    }

    func testNext() throws {
        var s = RedBlackSet<Int>()
        s.insert(1)
        s.insert(2)
        s.insert(3)
        s.insert(4)
        XCTAssertEqual(1, s.next(0))
        XCTAssertEqual(2, s.next(1))
        XCTAssertEqual(3, s.next(2))
        XCTAssertEqual(4, s.next(3))
        XCTAssertEqual(nil, s.next(4))
    }
#endif

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
