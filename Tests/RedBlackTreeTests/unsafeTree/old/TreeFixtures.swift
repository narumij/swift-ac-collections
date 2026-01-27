import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

#if DEBUG
  class TreeFixtureBase<Element>:
    RedBlackTreeTestCase,
    TreeAlgorithmBaseProtocol_std,
    TreeNodeAccessInterface, RootInterface, EndNodeProtocol,
    ___RedBlackTreeNodePoolProtocol
  {
    var nullptr: Int { .nullptr }
    var end: Int { .end }

    typealias _NodePtr = _TrackingTag
    typealias _NodeRef = _PointerIndexRef

    var __left_: _NodePtr = .nullptr
    var __begin_node_: _NodePtr = .end

    var __nodes: [___Node] = []
    var __values: [Element] = []

    var ___destroy_node: _TrackingTag = .nullptr
    var ___destroy_count: Int = 0

    func __left_(_ p: _NodePtr) -> _NodePtr { p == .end ? __left_ : __nodes[p].__left_ }
    func __left_unsafe(_ p: _NodePtr) -> _NodePtr { __nodes[p].__left_ }
    func __left_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
      if lhs == .end {
        __left_ = rhs
      } else {
        __nodes[lhs].__left_ = rhs
      }
    }
    func __right_(_ p: _NodePtr) -> _NodePtr { __nodes[p].__right_ }
    func __right_(_ lhs: _NodePtr, _ rhs: _NodePtr) { __nodes[lhs].__right_ = rhs }
    func __parent_(_ p: _NodePtr) -> _NodePtr { __nodes[p].__parent_ }
    func __parent_(_ lhs: _NodePtr, _ rhs: _NodePtr) { __nodes[lhs].__parent_ = rhs }
    func __is_black_(_ p: _NodePtr) -> Bool { __nodes[p].__is_black_ }
    func __is_black_(_ lhs: _NodePtr, _ rhs: Bool) { __nodes[lhs].__is_black_ = rhs }
    func __parent_unsafe(_ p: _NodePtr) -> _NodePtr { __nodes[p].__parent_ }
    //    func __root() -> _NodePtr { __left_ }

    func ___initialize(_ e: Element) -> _NodePtr {
      let n = __nodes.count
      __nodes.append(.node)
      __values.append(e)
      return n
    }

    func __value_(_ p: _NodePtr) -> Element {
      __values[p]
    }

    func ___element(_ p: _NodePtr, _ e: Element) {
      __values[p] = e
    }

    var __root: _NodePtr {
      get { __left_ }
      set { __left_ = newValue }
    }

    //    func __root(_ p: _NodePtr) {
    //      __left_ = p
    //    }

    func clear() {
      __left_ = .nullptr
      __begin_node_ = .end
      __nodes = []
      ___clearDestroy()
    }

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
      try super.setUpWithError()
      clear()
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      try super.tearDownWithError()
      clear()
    }
  }

  class TreeFixture<Element: Comparable>:
    TreeFixtureBase<Element>,
    FindProtocol_std,
    FindEqualInterface, FindEqualProtocol_std,
    InsertNodeAtInterface, InsertNodeAtProtocol_std,
    InsertUniqueInterface, InsertUniqueProtocol_std,
    RemoveInteface, EraseProtocol, EraseUniqueProtocol,
    CompareProtocol, CompareMultiProtocol_std,
    BoundBothProtocol, NodeBitmapProtocol_std,
    BoundAlgorithmProtocol,
    RemoveProtocol_std,
    IntThreeWayComparator
  {
    typealias _Payload = Element
    typealias __value_type = Element

    let isMulti: Bool = true

    func __key(_ e: Element) -> Element {
      e
    }

    func __get_value(_ p: _NodePtr) -> Element {
      __values[p]
    }

    typealias Element = Element

    var __size_: Int {
      get { __nodes.count - ___destroy_count }
      set {}
    }

    typealias _Key = Element

    func value_comp(_ l: Element, _ r: Element) -> Bool {
      l < r
    }

    func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
      ___ptr_comp_multi(l, r)
    }

    func __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key) -> __eager_compare_result {
      .init(__default_three_way_comparator(__lhs, __rhs))
    }

    static var isMulti: Bool { false }
  }

  class TreeFixture0_10_20: TreeFixture<Int> {

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
      try super.setUpWithError()
      __nodes = [
        .init(__is_black_: true, __left_: 1, __right_: 2, __parent_: .end),
        .init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: 0),
        .init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: 0),
      ]
      __values = [
        10,
        0,
        20,
      ]
      __root = 0
      XCTAssertTrue(__tree_invariant(__root))
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      try super.tearDownWithError()
    }
  }

  class TreeFixture0_1_2_3_4_5_6: TreeFixture<Int> {

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
      try super.setUpWithError()

      __nodes = [
        .init(__is_black_: true, __left_: 1, __right_: 4, __parent_: .end),
        .init(__is_black_: false, __left_: 2, __right_: 3, __parent_: 0),
        .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 1),
        .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 1),
        .init(__is_black_: false, __left_: 5, __right_: 6, __parent_: 0),
        .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 4),
        .init(__is_black_: true, __left_: .nullptr, __right_: .nullptr, __parent_: 4),
      ]
      __values = [
        3,
        1,
        0,
        2,
        4,
        5,
        6,
      ]
      __root = 0
      //    size = tree.nodes.count
      __begin_node_ = 2
      XCTAssertTrue(__tree_invariant(__root))
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      try super.tearDownWithError()
    }
  }
#endif
