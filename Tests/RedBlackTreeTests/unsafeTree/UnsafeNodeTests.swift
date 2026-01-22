//
//  UnsafeNodeTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/21.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule

  final class UnsafeNodeTests: PointerRedBlackTreeTestCase {

    class Fixture: InsertNodeAtProtocol_ptr {
      init(_ end: inout UnsafeNode) {
        let e_p = _ref(to: &end)
        __begin_node_ = e_p
        __end_node = e_p
      }
      var __end_node: _NodePtr
      var __begin_node_: _NodePtr
      var __size_: Int = 0
      var __root: _NodePtr { __end_node.__left_ }
      var nullptr: _NodePtr { .nullptr }
    }

    var end: UnsafeNode = .create(id: .end)
    var nodes: [UnsafeNode] = []
    let count = 10

    override func setUpWithError() throws {
      end = .create(id: .end)
      nodes = .init(repeating: .create(id: .debug), count: count)
    }

    override func tearDownWithError() throws {
    }

    func testTreeBeginToNext() throws {

      nodes.withUnsafeMutableBufferPointer { nodes in

        let fixture = Fixture(&end)

        XCTAssertEqual(fixture.__end_node.__left_, .nullptr)
        XCTAssertTrue(__tree_invariant(fixture.__end_node.__left_))

        fixture.__insert_node_at(
          fixture.__end_node, // 空の木の根の親はend
          fixture.__end_node.__left_ref, // 空の木の挿入先はendの左
          nodes.baseAddress!)
        XCTAssertTrue(__tree_invariant(fixture.__root))
        
        var it = nodes.baseAddress!
        
        for i in 1..<10 {
          fixture.__insert_node_at(it, it.__right_ref, nodes.baseAddress! + i)
          XCTAssertTrue(__tree_invariant(fixture.__root))
          it = nodes.baseAddress! + i
        }
        
        XCTAssertEqual(fixture.__begin_node_, nodes.baseAddress)
        XCTAssertEqual(__tree_min(fixture.__root), nodes.baseAddress!)
        XCTAssertEqual(__tree_max(fixture.__root), nodes.baseAddress! + count - 1)
        XCTAssertEqual(__tree_min(fixture.__root), fixture.__begin_node_)

        do {
          var it = fixture.__begin_node_
          let end = fixture.__end_node
          for i in 0..<count {
            XCTAssertNotEqual(it, end)
            XCTAssertEqual(it, nodes.baseAddress! + i)
            it = __tree_next(it)
          }
          XCTAssertEqual(it, end)
        }
      }
    }
    
    
    func testTreeEndToPrev() throws {
      
      nodes.withUnsafeMutableBufferPointer { nodes in
        
        let fixture = Fixture(&end)
        
        XCTAssertEqual(fixture.__end_node.__left_, .nullptr)
        XCTAssertTrue(__tree_invariant(fixture.__end_node.__left_))
        
        fixture.__insert_node_at(
          fixture.__end_node, // 空の木の根の親はend
          fixture.__end_node.__left_ref, // 空の木の挿入先はendの左
          nodes.baseAddress!)
        XCTAssertTrue(__tree_invariant(fixture.__root))
        
        var it = nodes.baseAddress!
        
        for i in 1..<10 {
          fixture.__insert_node_at(it, it.__left_ref, nodes.baseAddress! + i)
          XCTAssertTrue(__tree_invariant(fixture.__root))
          it = nodes.baseAddress! + i
        }
        
        XCTAssertEqual(fixture.__begin_node_, nodes.baseAddress! + count - 1)
        XCTAssertEqual(__tree_max(fixture.__root), nodes.baseAddress!)
        XCTAssertEqual(__tree_min(fixture.__root), nodes.baseAddress! + count - 1)
        
        do {
          var it = fixture.__end_node
          let begin = fixture.__begin_node_
          for i in 0..<count {
            it = __tree_prev_iter(it)
            XCTAssertEqual(it, nodes.baseAddress! + i)
          }
          XCTAssertEqual(it, begin)
        }
      }
    }

    func testPerformanceExample() throws {
      // This is an example of a performance test case.
      self.measure {
        // Put the code you want to measure the time of here.
      }
    }
  }
#endif
