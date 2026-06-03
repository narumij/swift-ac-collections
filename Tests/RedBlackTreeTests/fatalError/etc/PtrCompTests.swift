//
//  Test 4.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/08.
//

import Testing
import Foundation

#if DEBUG && DEATH_TEST
@testable import RedBlackTreeCollections

nonisolated(unsafe)
fileprivate var start = UnsafeNode(___tracking_tag: 0, __left_: .nullptr, __right_: .nullptr, __parent_: .nullptr)

nonisolated(unsafe)
fileprivate var end = UnsafeNode(___tracking_tag: .end, __left_: .nullptr, __right_: .nullptr, __parent_: .nullptr)

nonisolated
fileprivate var _start: UnsafeMutablePointer<UnsafeNode> {
  get {
    withUnsafeMutablePointer(to: &start) { $0 }
  }
}

nonisolated
fileprivate var _end: UnsafeMutablePointer<UnsafeNode> {
  get {
    withUnsafeMutablePointer(to: &end) { $0 }
  }
}

nonisolated
struct PtrCompTests {
  
  enum SUT: UniqueMultiplicity {
    static func value_comp(_: Int, _: Int) -> Bool {
      fatalError()
    }
    
    static func __get_value(_: UnsafeMutablePointer<RedBlackTreeCollections.UnsafeNode>) -> Int {
      fatalError()
    }
    
    typealias _Key = Int
  }

  @Test mutating func `___ptr_comp_uniqueのassertその1`() async throws {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      #expect(SUT._MultiplicityHelper.___ptr_comp_unique(.nullptr, _start) == true)
    }
  }

  @Test mutating func `___ptr_comp_uniqueのassertその2`() async throws {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      #expect(SUT._MultiplicityHelper.___ptr_comp_unique(_end, _start) == true)
    }
  }

  @Test mutating func `___ptr_comp_uniqueのassertその3`() async throws {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      #expect(SUT._MultiplicityHelper.___ptr_comp_unique(_start, .nullptr) == true)
    }
  }

  @Test mutating func `___ptr_comp_uniqueのassertその4`() async throws {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      #expect(SUT._MultiplicityHelper.___ptr_comp_unique(_start, _end) == true)
    }
  }
}
#endif
