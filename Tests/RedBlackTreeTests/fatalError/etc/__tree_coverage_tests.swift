//
//  Test.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/30.
//

#if DEBUG && DEATH_TEST
  import Foundation
  @testable import RedBlackTreeCollections
  import Testing

  struct __tree_coverage_tests {

    @Test func `_TrackingTagSealing.sealのカバレッジ確保`() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        _ = _TrackingTagSealing.seal(raw: .min, seal: 0)
      }
    }
    
    struct _BaseNode_KeyProtocol_Fixture: _BaseNode_KeyProtocol {
      static func __key(_ i: Int) -> Int { i * 2 }
      static func __value_(_ p: Int) -> Int { p * 10 }
      typealias _NodePtr = Int
      typealias _NodeRef = Int
      typealias _Key = Int
      typealias _PayloadValue = Int
    }

    @Test func `_BaseNode_KeyProtocolのカバレッジ確保`() async throws {
      typealias Base = _BaseNode_KeyProtocol_Fixture
      #expect(Base.__get_value(0) == 0)
      #expect(Base.__get_value(1) == 20)
    }
    
    struct _PairBasePayloadValue_MappedValueProtocol_Fixture: _PairBasePayloadValue_MappedValueProtocol {
      typealias _PayloadValue = RedBlackTreePair<Int,Int>
      typealias _MappedValue = Int
      typealias _Key = Int
    }
    
    @Test func `_PairBasePayloadValue_MappedValueProtocolのカバレッジ確保`() async throws {
      typealias Base = _PairBasePayloadValue_MappedValueProtocol_Fixture
      #expect(Base.___mapped_value(.init((0,0))) == 0)
      #expect(Base.___mapped_value(.init((1,0))) == 0)
      #expect(Base.___mapped_value(.init((0,2))) == 2)
      #expect(Base.___mapped_value(.init((1,2))) == 2)
    }

    @Test func `___default_three_way_comparatorのカバレッジ確保`() async throws {
      #expect(___default_three_way_comparator(0, 1).__less() == true)
      #expect(___default_three_way_comparator(0, 0) == .equal)
      #expect(___default_three_way_comparator(1, 0).__greater() == true)
    }

    @Test func `__eager_compare_resultのカバレッジ確保`() async throws {
      #expect(__eager_compare_result(0).__less() == false)
      #expect(__eager_compare_result(0).__greater() == false)
      #expect(__eager_compare_result(1).__less() == false)
      #expect(__eager_compare_result(1).__greater() == true)
      #expect(__eager_compare_result(-1).__less() == true)
      #expect(__eager_compare_result(-1).__greater() == false)
    }

    
  }
#endif
