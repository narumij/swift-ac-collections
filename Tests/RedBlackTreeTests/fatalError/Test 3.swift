//
//  Test 3.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/08.
//

#if DEBUG && DEATH_TEST
  import Testing
  import Foundation
  @testable import RedBlackTreeModule

  struct Test_3 {

    typealias Fixture = RedBlackTreeSet<Int>
    typealias SUT = Fixture.Base

    @Test func `___ptr_comp_uniqueのassertその1`() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        let fixture = Fixture(0..<5)
        #expect(SUT.___ptr_comp_unique(fixture.nullptr, fixture._start) == true)
      }
    }

    @Test func `___ptr_comp_uniqueのassertその2`() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        let fixture = Fixture(0..<5)
        #expect(SUT.___ptr_comp_unique(fixture._end, fixture._start) == true)
      }
    }

    @Test func `___ptr_comp_uniqueのassertその3`() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        let fixture = Fixture(0..<5)
        #expect(SUT.___ptr_comp_unique(fixture._start, fixture.nullptr) == true)
      }
    }

    @Test func `___ptr_comp_uniqueのassertその4`() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        let fixture = Fixture(0..<5)
        #expect(SUT.___ptr_comp_unique(fixture._start, fixture._end) == true)
      }
    }
  }

#endif
