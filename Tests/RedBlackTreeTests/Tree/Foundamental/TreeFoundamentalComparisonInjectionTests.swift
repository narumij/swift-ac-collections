import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections

  @available(anyAppleOS 26.0, *)
  final class TreeFoundamentalComparisonInjectionTests: RedBlackTreeTestCase {

    /// 現行の`Base`注入経路で使うstatic比較・key取得の最小実装。
    private enum StaticBase: _UnsafeNodePtrType, ScalarValueTrait, UniqueMultiplicity,
      _ScalarBasePayload_KeyProtocol_ptr
    {
      typealias _PayloadValue = Int
      typealias _Key = Int
      typealias Element = Int

      static func __get_value(_ p: _NodePtr) -> Int {
        p.pointee.___tracking_tag
      }
    }

    /// `_ValueCompBridge`を経由し、インスタンス要件を`Base.value_comp`へ委譲する経路。
    private struct StaticInjectedTree: _UnsafeNodePtrType, _BaseBridge, _KeyBride,
      _ValueCompBridge, FindLeafProtocol_ptr
    {
      typealias Base = StaticBase
      typealias _Key = Int
      typealias __node_value_type = Int

      let endNode: _NodePtr

      var nullptr: _NodePtr { .nullptr }
      var __end_node: _NodePtr { endNode }
      var __root: _NodePtr { endNode.__left_ }

      func __root_ptr() -> _NodeRef {
        endNode.__left_ref
      }

      func __get_value(_ p: _NodePtr) -> Int {
        Base.__get_value(p)
      }
    }

    private final class ComparisonProbe {
      var callCount = 0
    }

    /// `Base`を持たず、fixtureの状態を使うインスタンス比較経路。
    private struct InstanceInjectedTree: ~Copyable, _UnsafeNodePtrType, FindLeafProtocol_ptr {
      typealias _Key = Int
      typealias __node_value_type = Int

      let endNode: _NodePtr
      let probe: ComparisonProbe
      let descending: Bool

      var nullptr: _NodePtr { .nullptr }
      var __end_node: _NodePtr { endNode }
      var __root: _NodePtr { endNode.__left_ }

      func __root_ptr() -> _NodeRef {
        endNode.__left_ref
      }

      func __get_value(_ p: _NodePtr) -> Int {
        p.pointee.___tracking_tag
      }

      func value_comp(_ lhs: Int, _ rhs: Int) -> Bool {
        probe.callCount += 1
        return descending ? lhs > rhs : lhs < rhs
      }
    }

    private func makeThreeNodeTree(
      _ fixture: inout TreeNodeOnlyFixture
    ) -> UnsafeMutablePointer<UnsafeNode> {
      let end = fixture.endPtr()
      let left = fixture.node(0)
      let root = fixture.node(1)
      let right = fixture.node(2)

      left.pointee = .create(tag: 10, nullptr: .nullptr)
      root.pointee = .create(tag: 20, nullptr: .nullptr)
      right.pointee = .create(tag: 30, nullptr: .nullptr)

      end.__left_ = root
      root.__parent_ = end
      root.__left_ = left
      root.__right_ = right
      left.__parent_ = root
      right.__parent_ = root
      return end
    }

    /// 同じ`__find_leaf_low/high`が、Baseのstatic比較注入と、状態を持つインスタンス比較注入の
    /// 双方で同じ探索結果を返すこと。インスタンス経路はcall countで実際の呼び出しも確認する。
    func testFindLeaf_supportsStaticBaseAndInstanceComparisonInjection() {
      var fixture = TreeNodeOnlyFixture.makeEmpty()
      let end = makeThreeNodeTree(&fixture)
      let staticTree = StaticInjectedTree(endNode: end)
      let probe = ComparisonProbe()
      let instanceTree = InstanceInjectedTree(endNode: end, probe: probe, descending: false)

      for key in [5, 20, 25, 35] {
        var staticLowParent = UnsafeMutablePointer<UnsafeNode>.nullptr
        var instanceLowParent = UnsafeMutablePointer<UnsafeNode>.nullptr
        let staticLow = staticTree.__find_leaf_low(&staticLowParent, key)
        let instanceLow = instanceTree.__find_leaf_low(&instanceLowParent, key)
        XCTAssertEqual(staticLowParent, instanceLowParent)
        XCTAssertEqual(staticLow, instanceLow)

        var staticHighParent = UnsafeMutablePointer<UnsafeNode>.nullptr
        var instanceHighParent = UnsafeMutablePointer<UnsafeNode>.nullptr
        let staticHigh = staticTree.__find_leaf_high(&staticHighParent, key)
        let instanceHigh = instanceTree.__find_leaf_high(&instanceHighParent, key)
        XCTAssertEqual(staticHighParent, instanceHighParent)
        XCTAssertEqual(staticHigh, instanceHigh)
      }

      XCTAssertGreaterThan(probe.callCount, 0)
    }

    /// 空木では比較器を呼ばず、static/instanceの双方がend nodeのroot参照を返すこと。
    func testFindLeaf_injectionPathsHandleEmptyTreeWithoutComparison() {
      var fixture = TreeNodeOnlyFixture.makeEmpty()
      let end = fixture.endPtr()
      let staticTree = StaticInjectedTree(endNode: end)
      let probe = ComparisonProbe()
      let instanceTree = InstanceInjectedTree(endNode: end, probe: probe, descending: false)

      var staticParent = UnsafeMutablePointer<UnsafeNode>.nullptr
      var instanceParent = UnsafeMutablePointer<UnsafeNode>.nullptr
      let staticLeaf = staticTree.__find_leaf_low(&staticParent, 20)
      let instanceLeaf = instanceTree.__find_leaf_low(&instanceParent, 20)

      XCTAssertEqual(staticParent, end)
      XCTAssertEqual(instanceParent, end)
      XCTAssertEqual(staticLeaf, end.__left_ref)
      XCTAssertEqual(instanceLeaf, end.__left_ref)
      XCTAssertEqual(probe.callCount, 0)
    }

    /// インスタンスが保持する降順設定が探索分岐へ反映され、static Baseの昇順比較から
    /// 独立した注入経路であること。
    func testFindLeaf_instanceComparisonCanCarryDescendingState() {
      var fixture = TreeNodeOnlyFixture.makeEmpty()
      let end = fixture.endPtr()
      let lower = fixture.node(0)
      let root = fixture.node(1)
      let higher = fixture.node(2)

      lower.pointee = .create(tag: 10, nullptr: .nullptr)
      root.pointee = .create(tag: 20, nullptr: .nullptr)
      higher.pointee = .create(tag: 30, nullptr: .nullptr)
      end.__left_ = root
      root.__parent_ = end
      root.__left_ = higher
      root.__right_ = lower
      higher.__parent_ = root
      lower.__parent_ = root

      let probe = ComparisonProbe()
      let tree = InstanceInjectedTree(endNode: end, probe: probe, descending: true)
      var parent = UnsafeMutablePointer<UnsafeNode>.nullptr
      let leaf = tree.__find_leaf_low(&parent, 25)

      XCTAssertEqual(parent, higher)
      XCTAssertEqual(leaf, higher.__right_ref)
      XCTAssertGreaterThan(probe.callCount, 0)
    }
  }
#endif
