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

      static func compare(_ lhs: Int, _ rhs: Int) -> __int_compare_result {
        __default_three_way_comparator(lhs, rhs)
      }
    }

    /// `_ValueCompBridge`を経由し、インスタンス要件を`Base.value_comp`へ委譲する経路。
    private struct StaticInjectedTree: _UnsafeNodePtrType, _BaseBridge, _KeyBride,
      _ValueCompBridge, FindLeafProtocol_ptr, FindEqualInterface, FindEqualProtocol_ptr_old,
      FindProtocol_find_equal_ptr, BoundAlgorithmProtocol_legacy_ptr, CountProtocol_ptr,
      TreeAlgorithmBaseProtocol_ptr, FindHintLeafProtocol_ptr, FindHintEqualProtocol_ptr
    {
      typealias Base = StaticBase
      typealias _Key = Int
      typealias __node_value_type = Int
      typealias __compare_result = __int_compare_result

      let endNode: _NodePtr

      var nullptr: _NodePtr { .nullptr }
      var end: _NodePtr { endNode }
      var __end_node: _NodePtr { endNode }
      var __root: _NodePtr { endNode.__left_ }
      var __begin_node_: _NodePtr {
        get { __root == nullptr ? end : __tree_min(__root) }
        nonmutating set {}
      }

      func __root_ptr() -> _NodeRef {
        endNode.__left_ref
      }

      func __get_value(_ p: _NodePtr) -> Int {
        Base.__get_value(p)
      }

      func __comp(_ lhs: Int, _ rhs: Int) -> __int_compare_result {
        Base.compare(lhs, rhs)
      }

      func lower_bound(_ value: Int) -> _NodePtr {
        __lower_bound_unique(value)
      }

      func upper_bound(_ value: Int) -> _NodePtr {
        __upper_bound_unique(value)
      }
    }

    private final class ComparisonProbe {
      var callCount = 0
    }

    /// `Base`を持たず、fixtureの状態を使うインスタンス比較経路。
    private struct InstanceInjectedTree: ~Copyable, _UnsafeNodePtrType, FindLeafProtocol_ptr,
      FindEqualInterface, FindEqualProtocol_ptr_old, FindProtocol_find_equal_ptr,
      BoundAlgorithmProtocol_legacy_ptr, CountProtocol_ptr, TreeAlgorithmBaseProtocol_ptr,
      FindHintLeafProtocol_ptr, FindHintEqualProtocol_ptr
    {
      typealias _Key = Int
      typealias __node_value_type = Int
      typealias __compare_result = __int_compare_result

      let endNode: _NodePtr
      let probe: ComparisonProbe
      let descending: Bool

      var nullptr: _NodePtr { .nullptr }
      var end: _NodePtr { endNode }
      var __end_node: _NodePtr { endNode }
      var __root: _NodePtr { endNode.__left_ }
      var __begin_node_: _NodePtr {
        get { __root == nullptr ? end : __tree_min(__root) }
        nonmutating set {}
      }

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

      func __comp(_ lhs: Int, _ rhs: Int) -> __int_compare_result {
        probe.callCount += 1
        return descending
          ? __default_three_way_comparator(rhs, lhs)
          : __default_three_way_comparator(lhs, rhs)
      }

      func lower_bound(_ value: Int) -> _NodePtr {
        __lower_bound_unique(value)
      }

      func upper_bound(_ value: Int) -> _NodePtr {
        __upper_bound_unique(value)
      }
    }

    /// 三方比較で実装された現行のequal/boundアルゴリズムへstatic比較を注入する経路。
    private struct StaticThreeWayInjectedTree: _UnsafeNodePtrType, _BaseBridge, _KeyBride,
      _ValueCompBridge, TreeAlgorithmBaseProtocol_ptr, FindEqualProtocol_ptr,
      BoundAlgorithmProtocol_ptr, FindProtocol_lower_bound_ptr
    {
      typealias Base = StaticBase
      typealias _Key = Int
      typealias __node_value_type = Int
      typealias __compare_result = __int_compare_result

      let endNode: _NodePtr

      var nullptr: _NodePtr { .nullptr }
      var end: _NodePtr { endNode }
      var __end_node: _NodePtr { endNode }
      var __root: _NodePtr { endNode.__left_ }

      func __root_ptr() -> _NodeRef {
        endNode.__left_ref
      }

      func __get_value(_ p: _NodePtr) -> Int {
        Base.__get_value(p)
      }

      func __comp(_ lhs: Int, _ rhs: Int) -> __int_compare_result {
        Base.compare(lhs, rhs)
      }

      func lower_bound(_ value: Int) -> _NodePtr {
        __lower_bound_unique(value)
      }

      func upper_bound(_ value: Int) -> _NodePtr {
        __upper_bound_unique(value)
      }
    }

    /// `Base`なしの三方比較を、noncopyableなインスタンスから直接注入する経路。
    private struct InstanceThreeWayInjectedTree: ~Copyable, _UnsafeNodePtrType,
      TreeAlgorithmBaseProtocol_ptr, FindEqualProtocol_ptr, BoundAlgorithmProtocol_ptr,
      FindProtocol_lower_bound_ptr
    {
      typealias _Key = Int
      typealias __node_value_type = Int
      typealias __compare_result = __int_compare_result

      let endNode: _NodePtr
      let probe: ComparisonProbe
      let descending: Bool

      var nullptr: _NodePtr { .nullptr }
      var end: _NodePtr { endNode }
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

      func __comp(_ lhs: Int, _ rhs: Int) -> __int_compare_result {
        probe.callCount += 1
        return descending
          ? __default_three_way_comparator(rhs, lhs)
          : __default_three_way_comparator(lhs, rhs)
      }

      func lower_bound(_ value: Int) -> _NodePtr {
        __lower_bound_unique(value)
      }

      func upper_bound(_ value: Int) -> _NodePtr {
        __upper_bound_unique(value)
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

    /// 二値比較版`__find_equal`も、static Base注入とインスタンス注入で、既存ノード・
    /// 左右の未挿入位置・空木について同じparent/child参照を返すこと。
    func testFindEqual_supportsStaticBaseAndInstanceComparisonInjection() {
      var fixture = TreeNodeOnlyFixture.makeEmpty()
      let end = makeThreeNodeTree(&fixture)
      let staticTree = StaticInjectedTree(endNode: end)
      let probe = ComparisonProbe()
      let instanceTree = InstanceInjectedTree(endNode: end, probe: probe, descending: false)

      for key in [5, 10, 20, 25, 30, 35] {
        let staticResult = staticTree.__find_equal(key)
        let instanceResult = instanceTree.__find_equal(key)
        XCTAssertEqual(staticResult.__parent, instanceResult.__parent)
        XCTAssertEqual(staticResult.__child, instanceResult.__child)
      }
      XCTAssertGreaterThan(probe.callCount, 0)

      var emptyFixture = TreeNodeOnlyFixture.makeEmpty()
      let emptyEnd = emptyFixture.endPtr()
      let emptyStaticTree = StaticInjectedTree(endNode: emptyEnd)
      let emptyProbe = ComparisonProbe()
      let emptyInstanceTree = InstanceInjectedTree(
        endNode: emptyEnd,
        probe: emptyProbe,
        descending: false)

      let staticEmpty = emptyStaticTree.__find_equal(20)
      let instanceEmpty = emptyInstanceTree.__find_equal(20)
      XCTAssertEqual(staticEmpty.__parent, emptyEnd)
      XCTAssertEqual(instanceEmpty.__parent, emptyEnd)
      XCTAssertEqual(staticEmpty.__child, emptyEnd.__left_ref)
      XCTAssertEqual(instanceEmpty.__child, emptyEnd.__left_ref)
      XCTAssertEqual(emptyProbe.callCount, 0)
    }

    /// `__find_equal`を利用する`find`も両注入経路で一致し、欠落キーをendへ変換すること。
    func testFind_supportsStaticBaseAndInstanceComparisonInjection() {
      var fixture = TreeNodeOnlyFixture.makeEmpty()
      let end = makeThreeNodeTree(&fixture)
      let staticTree = StaticInjectedTree(endNode: end)
      let probe = ComparisonProbe()
      let instanceTree = InstanceInjectedTree(endNode: end, probe: probe, descending: false)

      for key in [10, 20, 30] {
        let staticResult = staticTree.find(key)
        let instanceResult = instanceTree.find(key)
        XCTAssertEqual(staticResult, instanceResult)
        XCTAssertEqual(staticResult.pointee.___tracking_tag, key)
      }

      for key in [5, 25, 35] {
        XCTAssertEqual(staticTree.find(key), end)
        XCTAssertEqual(instanceTree.find(key), end)
      }
      XCTAssertGreaterThan(probe.callCount, 0)
    }

    /// 二値比較で実装されたlower/upper boundも、static Base注入とインスタンス注入で一致し、
    /// 境界外ではendを返すこと。
    func testBounds_supportStaticBaseAndInstanceComparisonInjection() {
      var fixture = TreeNodeOnlyFixture.makeEmpty()
      let end = makeThreeNodeTree(&fixture)
      let staticTree = StaticInjectedTree(endNode: end)
      let probe = ComparisonProbe()
      let instanceTree = InstanceInjectedTree(endNode: end, probe: probe, descending: false)

      let cases: [(key: Int, lower: Int?, upper: Int?)] = [
        (5, 10, 10),
        (10, 10, 20),
        (15, 20, 20),
        (20, 20, 30),
        (25, 30, 30),
        (30, 30, nil),
        (35, nil, nil),
      ]

      for item in cases {
        let staticLower = staticTree.__lower_bound_multi(item.key)
        let instanceLower = instanceTree.__lower_bound_multi(item.key)
        let staticUpper = staticTree.__upper_bound_multi(item.key)
        let instanceUpper = instanceTree.__upper_bound_multi(item.key)

        XCTAssertEqual(staticLower, instanceLower)
        XCTAssertEqual(staticUpper, instanceUpper)
        XCTAssertEqual(staticLower == end ? nil : staticLower.pointee.___tracking_tag, item.lower)
        XCTAssertEqual(staticUpper == end ? nil : staticUpper.pointee.___tracking_tag, item.upper)

        XCTAssertEqual(staticTree.__lower_bound_unique(item.key), staticLower)
        XCTAssertEqual(instanceTree.__lower_bound_unique(item.key), instanceLower)
        XCTAssertEqual(staticTree.__upper_bound_unique(item.key), staticUpper)
        XCTAssertEqual(instanceTree.__upper_bound_unique(item.key), instanceUpper)
      }
      XCTAssertGreaterThan(probe.callCount, 0)
    }

    /// unique/multi countがstatic三方比較と状態付きインスタンス三方比較の双方で一致すること。
    func testCount_supportsStaticBaseAndInstanceComparisonInjection() {
      var fixture = TreeNodeOnlyFixture.makeEmpty()
      let end = makeThreeNodeTree(&fixture)
      let staticTree = StaticInjectedTree(endNode: end)
      let probe = ComparisonProbe()
      let instanceTree = InstanceInjectedTree(endNode: end, probe: probe, descending: false)

      for key in [5, 10, 20, 30, 35] {
        let expected = [10, 20, 30].contains(key) ? 1 : 0
        XCTAssertEqual(staticTree.__count_unique(key), expected)
        XCTAssertEqual(instanceTree.__count_unique(key), expected)
        XCTAssertEqual(staticTree.__count_multi(key), expected)
        XCTAssertEqual(instanceTree.__count_multi(key), expected)
      }
      XCTAssertGreaterThan(probe.callCount, 0)

      // in-orderが10,20,20となる重複木でmulti countの距離計算も通す。
      let duplicate = fixture.node(2)
      duplicate.pointee.___tracking_tag = 20
      XCTAssertEqual(staticTree.__count_multi(20), 2)
      XCTAssertEqual(instanceTree.__count_multi(20), 2)
      XCTAssertEqual(staticTree.__count_unique(20), 1)
      XCTAssertEqual(instanceTree.__count_unique(20), 1)
    }

    /// 三方比較版のequal・unique bound・lower-bound版findも、static/Base経路と
    /// Baseなしインスタンス経路で同じ結果を返すこと。
    func testThreeWayAlgorithms_supportStaticBaseAndInstanceComparisonInjection() {
      var fixture = TreeNodeOnlyFixture.makeEmpty()
      let end = makeThreeNodeTree(&fixture)
      let staticTree = StaticThreeWayInjectedTree(endNode: end)
      let probe = ComparisonProbe()
      let instanceTree = InstanceThreeWayInjectedTree(
        endNode: end,
        probe: probe,
        descending: false)

      let cases: [(key: Int, lower: Int?, upper: Int?)] = [
        (5, 10, 10),
        (10, 10, 20),
        (15, 20, 20),
        (20, 20, 30),
        (25, 30, 30),
        (30, 30, nil),
        (35, nil, nil),
      ]

      for item in cases {
        let staticEqual = staticTree.__find_equal(item.key)
        let instanceEqual = instanceTree.__find_equal(item.key)
        XCTAssertEqual(staticEqual.__parent, instanceEqual.__parent)
        XCTAssertEqual(staticEqual.__child, instanceEqual.__child)

        let staticLower = staticTree.__lower_bound_unique(item.key)
        let instanceLower = instanceTree.__lower_bound_unique(item.key)
        let staticUpper = staticTree.__upper_bound_unique(item.key)
        let instanceUpper = instanceTree.__upper_bound_unique(item.key)
        XCTAssertEqual(staticLower, instanceLower)
        XCTAssertEqual(staticUpper, instanceUpper)
        XCTAssertEqual(staticLower == end ? nil : staticLower.pointee.___tracking_tag, item.lower)
        XCTAssertEqual(staticUpper == end ? nil : staticUpper.pointee.___tracking_tag, item.upper)

        let expectedFind = [10, 20, 30].contains(item.key) ? item.key : nil
        let staticFound = staticTree.find(item.key)
        let instanceFound = instanceTree.find(item.key)
        XCTAssertEqual(staticFound, instanceFound)
        XCTAssertEqual(staticFound == end ? nil : staticFound.pointee.___tracking_tag, expectedFind)
      }
      XCTAssertGreaterThan(probe.callCount, 0)
    }

    /// hint付き探索でも、hint直前・直後・通常探索へのfallback・一致時dummy参照の各経路が、
    /// static/Base比較とBaseなしインスタンス比較で一致すること。
    func testHintedSearch_supportsStaticBaseAndInstanceComparisonInjection() {
      var fixture = TreeNodeOnlyFixture.makeEmpty()
      let end = makeThreeNodeTree(&fixture)
      let left = fixture.node(0)
      let root = fixture.node(1)
      let right = fixture.node(2)
      let staticTree = StaticInjectedTree(endNode: end)
      let probe = ComparisonProbe()
      let instanceTree = InstanceInjectedTree(endNode: end, probe: probe, descending: false)

      let leafCases: [(hint: UnsafeMutablePointer<UnsafeNode>, key: Int)] = [
        (end, 35),
        (left, 5),
        (root, 15),
        (root, 25),
        (right, 5),
      ]
      for item in leafCases {
        var staticParent = UnsafeMutablePointer<UnsafeNode>.nullptr
        var instanceParent = UnsafeMutablePointer<UnsafeNode>.nullptr
        let staticLeaf = staticTree.__find_leaf(item.hint, &staticParent, item.key)
        let instanceLeaf = instanceTree.__find_leaf(item.hint, &instanceParent, item.key)
        XCTAssertEqual(staticParent, instanceParent)
        XCTAssertEqual(staticLeaf, instanceLeaf)
      }

      let equalCases: [(hint: UnsafeMutablePointer<UnsafeNode>, key: Int)] = [
        (end, 35),
        (left, 10),
        (root, 15),
        (root, 20),
        (root, 25),
        (right, 5),
      ]
      for item in equalCases {
        var staticDummy = UnsafeMutablePointer<UnsafeNode>.nullptr
        var instanceDummy = UnsafeMutablePointer<UnsafeNode>.nullptr
        withUnsafeMutablePointer(to: &staticDummy) { staticDummyRef in
          withUnsafeMutablePointer(to: &instanceDummy) { instanceDummyRef in
            let staticResult = staticTree.__find_equal(item.hint, staticDummyRef, item.key)
            let instanceResult = instanceTree.__find_equal(item.hint, instanceDummyRef, item.key)
            XCTAssertEqual(staticResult.__parent, instanceResult.__parent)
            XCTAssertEqual(staticResult.__child.pointee, instanceResult.__child.pointee)
            XCTAssertEqual(
              staticResult.__child == staticDummyRef,
              instanceResult.__child == instanceDummyRef)
          }
        }
      }
      XCTAssertGreaterThan(probe.callCount, 0)
    }
  }
#endif
