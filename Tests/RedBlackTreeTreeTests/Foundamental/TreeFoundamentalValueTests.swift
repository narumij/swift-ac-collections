import Foundation
import RedBlackTreeFixture
import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

@available(anyAppleOS 26.0, *)
final class TreeFoundamentalValueTests: TreeTestCase {

  private struct LazyIntComparator: IntThreeWayComparator {
    typealias _Key = Int
    typealias __compare_result = __int_compare_result
  }

  private enum ScalarBase: _ScalarBase_ElementProtocol,
    _ScalarBasePayloadValue_KeyProtocol
  {
    typealias _PayloadValue = Int
    typealias _Key = Int
    typealias Element = Int
  }

  private enum PairBase: _PairBase_ElementProtocol,
    _PairBasePayloadValue_KeyProtocol,
    _PairBasePayloadValue_MappedValueProtocol
  {
    typealias _PayloadValue = RedBlackTreePair<String, Int>
    typealias _Key = String
    typealias _MappedValue = Int
    typealias Element = (key: String, value: Int)
  }

#if DEBUG
  private enum NodeKeyBase: _UnsafeNodePtrType, _BaseNode_KeyProtocol {
    typealias _PayloadValue = RedBlackTreePair<String, Int>
    typealias _Key = String

    static func __value_(_ p: _NodePtr) -> _PayloadValue {
      p.__value_(as: _PayloadValue.self).pointee
    }

    static func __key(_ value: _PayloadValue) -> _Key {
      value.tuple.key
    }
  }

  private struct TreeNodeKeyFixture: _UnsafeNodePtrType, _TreeNode_KeyProtocol {
    typealias _PayloadValue = RedBlackTreePair<String, Int>
    typealias _Key = String

    var nullptr: _NodePtr { .nullptr }

    func __value_(_ p: _NodePtr) -> _PayloadValue {
      p.__value_(as: _PayloadValue.self).pointee
    }

    func __key(_ value: _PayloadValue) -> _Key {
      value.tuple.key
    }
  }
#endif

  /// 特殊なtracking tagが通常ノード用の非負値と衝突しないこと。
  func testTrackingTag_specialValuesAreStableAndDistinct() {
    XCTAssertEqual(_TrackingTag.nullptr, -2)
    XCTAssertEqual(_TrackingTag.end, -1)
    XCTAssertEqual(_TrackingTag.debug, -999)
    XCTAssertEqual(_TrackingTag.retire, .min)

    let tags: Set<_TrackingTag> = [.nullptr, .end, .debug, .retire]
    XCTAssertEqual(tags.count, 4)
    XCTAssertTrue(tags.allSatisfy { $0 < 0 })
  }

  /// scalar baseの既定変換がpayload・key・elementを同一値として扱うこと。
  func testScalarBase_defaultConversionsAreIdentity() {
    XCTAssertEqual(ScalarBase.__key(42), 42)
    XCTAssertEqual(ScalarBase.__element_(42), 42)
  }

  /// pair baseの既定変換がtupleとの往復でkey/valueを保持すること。
  func testPairBase_defaultConversionsRoundTripTuple() {
    let element = (key: "answer", value: 42)
    let payload = PairBase.__payload_(element)

    XCTAssertEqual(PairBase.__key(payload), element.key)
    XCTAssertEqual(PairBase.___mapped_value(payload), element.value)
    XCTAssertEqual(PairBase.__element_(payload).key, element.key)
    XCTAssertEqual(PairBase.__element_(payload).value, element.value)
  }

#if DEBUG
  /// staticな`_BaseNode_KeyProtocol`とinstanceの`_TreeNode_KeyProtocol`の既定実装が、
  /// ともにNode→payload→keyの順で値を取り出すこと。
  func testNodeKeyBase_defaultGetValueReadsAdjacentPayload() {
    let fixture = UnsafeNodeReferenceFixture<RedBlackTreePair<String, Int>>(capacity: 1)
    fixture.firstNode.initialize(to: .create(tag: 0, nullptr: .nullptr))
    fixture.payload(at: 0).initialize(to: .init(tuple: (key: "key", value: 42)))
    defer {
      fixture.payload(at: 0).deinitialize(count: 1)
      fixture.firstNode.deinitialize(count: 1)
    }

    XCTAssertEqual(NodeKeyBase.__get_value(fixture.firstNode), "key")
    XCTAssertEqual(TreeNodeKeyFixture().__get_value(fixture.firstNode), "key")
  }
#endif

  /// multiplicity traitがuniqueとmultiを逆に報告しないこと。
  func testMultiplicityTraits_reportTheirStaticKind() {
    XCTAssertFalse(TreeNodeOnlyFixture.UniqueSealKey.isMulti)
    XCTAssertTrue(TreeNodeOnlyFixture.MultiSealKey.isMulti)
  }

  /// `RedBlackTreePair`の同値性・hash・辞書順比較がtupleの両成分に従うこと。
  func testRedBlackTreePair_valueSemanticsFollowTuple() {
    let a = PairBase.__payload_((key: "a", value: 2))
    let same = PairBase.__payload_((key: "a", value: 2))
    let keyAfter = PairBase.__payload_((key: "b", value: 0))
    let valueAfter = PairBase.__payload_((key: "a", value: 3))

    XCTAssertEqual(a, same)
    XCTAssertFalse(a != same)
    XCTAssertEqual(a.hashValue, same.hashValue)
    XCTAssertLessThan(a, keyAfter)
    XCTAssertLessThan(a, valueAfter)
  }

  /// pairのCodable表現が[key, value]順のunkeyed containerで往復すること。
  func testRedBlackTreePair_codableUsesKeyThenValue() throws {
    let pair = PairBase.__payload_((key: "key", value: 7))
    let data = try JSONEncoder().encode(pair)

    XCTAssertEqual(String(decoding: data, as: UTF8.self), "[\"key\",7]")
    XCTAssertEqual(try JSONDecoder().decode(RedBlackTreePair<String, Int>.self, from: data), pair)
  }

  /// 標準three-way comparatorが小・等・大をそれぞれ-1・0・1へ正規化すること。
  func testDefaultThreeWayComparator_normalizesAllRelations() {
    XCTAssertEqual(__default_three_way_comparator(1, 2), -1)
    XCTAssertEqual(__default_three_way_comparator(2, 2), 0)
    XCTAssertEqual(__default_three_way_comparator(3, 2), 1)
  }

  /// 原木用lazy three-way comparatorの既定実装が全ての大小関係を正規化すること。
  func testLazyIntThreeWayComparator_normalizesAllRelations() {
    let comparator = LazyIntComparator()
    XCTAssertTrue(comparator.__lazy_synth_three_way_comparator(1, 2).__less())
    XCTAssertEqual(comparator.__lazy_synth_three_way_comparator(2, 2), 0)
    XCTAssertTrue(comparator.__lazy_synth_three_way_comparator(3, 2).__greater())
  }

  /// Int compare resultの符号判定が0をless/greaterのどちらにも含めないこと。
  func testIntegerThreeWayCompareResult_classifiesSign() {
    XCTAssertTrue((-1).__less())
    XCTAssertFalse((-1).__greater())
    XCTAssertFalse(0.__less())
    XCTAssertFalse(0.__greater())
    XCTAssertFalse(1.__less())
    XCTAssertTrue(1.__greater())
  }

#if DEBUG
  /// eager compare resultもInt版と同じ符号規則を持つこと。
  func testEagerThreeWayCompareResult_classifiesSign() {
    XCTAssertTrue(__eager_compare_result(-1).__less())
    XCTAssertFalse(__eager_compare_result(-1).__greater())
    XCTAssertFalse(__eager_compare_result(0).__less())
    XCTAssertFalse(__eager_compare_result(0).__greater())
    XCTAssertFalse(__eager_compare_result(1).__less())
    XCTAssertTrue(__eager_compare_result(1).__greater())
  }
#endif
}
