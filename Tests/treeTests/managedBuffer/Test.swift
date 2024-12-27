//
//  Test.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/12/27.
//

import Testing

@testable import RedBlackTreeModule

struct RedBlackTreeNodeStorageTests {
  
  enum VC: ScalarValueComparer {
    typealias _Key = Int
  }

  @Test func createZero() async throws {
    let storage = ___RedBlackTree.___Storage<VC,Int>.empty
    #expect(storage.capacity == 0)
    #expect(storage.count == 0)
    #expect(storage.__left_ == .nullptr)
    #expect(storage.__begin_node == .end)
  }

  @Test func create() async throws {
    let storage = ___RedBlackTree.___Storage<VC,Int>.create(withCapacity: 4)
    #expect(storage.capacity == 4)
    #expect(storage.count == 0)
    #expect(storage.__left_ == .nullptr)
    #expect(storage.__begin_node == .end)
  }

  @Test func construct() async throws {
    let storage = ___RedBlackTree.___Storage<VC,Int>.create(withCapacity: 4)
    let ptr = storage.__construct_node(100)
    #expect(storage[ptr].__value_ == 100)
    storage[ptr].__value_ = 20
    #expect(storage[ptr].__value_ == 20)
    storage[ptr].__value_ = 50
    #expect(storage[ptr].__value_ == 50)
  }

  @Test func destroy() async throws {
    let storage = ___RedBlackTree.___Storage<VC,Int>.create(withCapacity: 4)
    let ptr = storage.__construct_node(100)
    #expect(storage[ptr].__value_ == 100)
    storage.destroy(ptr)
    #expect(storage[ptr].__value_ == 100)
  }

}
