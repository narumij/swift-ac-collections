import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if false
/// `<`が推移律を満たさない要素（mod 3でじゃんけんのように回る）。
/// 1 < 2 は成り立つが、{0, 1, 5}の木の中では lowerBound(1) が upperBound(2) より後ろの位置になる。
private struct NonTransitive: Comparable {
  var v: Int
  static func < (l: Self, r: Self) -> Bool {
    let a = l.v % 3, b = r.v % 3
    return (b - a + 3) % 3 == 1 || (a == b && l.v < r.v)
  }
}

final class ReversedRangeByBrokenOrderTests: XCTestCase {

  private typealias E = NonTransitive
  private typealias BE = RedBlackTreeBoundExpression

  private func makeSet() -> RedBlackTreeSet<E> {
    var s = RedBlackTreeSet<E>()
    for x in [0, 1, 5] { s.insert(E(v: x)) }
    return s
  }

  private func makeDictionary() -> RedBlackTreeDictionary<E, Int> {
    var d = RedBlackTreeDictionary<E, Int>()
    for x in [0, 1, 5] { d[E(v: x)] = x }
    return d
  }

  // release+ASan: heap-buffer-overflow in RedBlackTreeKeyOnlyRangeView.last.getter
  func testSetBoundViewLast() {
    let s = makeSet()
    XCTAssertNil(s[BE.lowerBound(E(v: 1)) ..< BE.upperBound(E(v: 2))].last)
  }

  // release+ASan: heap-buffer-overflow in UnsafeTreeV2._unchecked_remove(at:)
  func testSetBoundViewPopLast() {
    var s = makeSet()
    var v = s[BE.lowerBound(E(v: 1)) ..< BE.upperBound(E(v: 2))]
    XCTAssertNil(v.popLast())
    _ = s
  }

  // release+ASan: heap-buffer-overflow in UnsafeTreeV2._unchecked_remove(at:)（Indexの範囲から作ったビュー）
  func testSetIndexViewPopLast() {
    let s = makeSet()
    let i = s.lowerBound(E(v: 1)), j = s.upperBound(E(v: 2))
    var v = s[i ..< j]
    XCTAssertNil(v.popLast())
  }

  // release+ASan: heap-buffer-overflow in UnsafeTreeV2._unchecked_remove(at:)（キーの範囲から作ったビュー）
  func testSetKeyViewPopLast() {
    let s = makeSet()
    var v = s[E(v: 1) ..< E(v: 2)]
    XCTAssertNil(v.popLast())
  }

  // release+ASan: heap-buffer-overflow in RedBlackTreeKeyValueRangeView.last.getter
  func testDictionaryBoundViewLast() {
    let d = makeDictionary()
    XCTAssertNil(d[BE.lowerBound(E(v: 1)) ..< BE.upperBound(E(v: 2))].last)
  }

  // release+ASan: heap-buffer-overflow in UnsafeTreeV2._unchecked_remove(at:)（values経由）
  func testDictionaryBoundValuesPopLast() {
    let d = makeDictionary()
    var v = d[BE.lowerBound(E(v: 1)) ..< BE.upperBound(E(v: 2))]
    XCTAssertNil(v.values.popLast())
  }

  // メモリは壊れないが、範囲外の要素を1つ黙って消す（count 3 -> 2）
  func testSetEraseBoundDoesNotRemoveOutsideElements() {
    var s = makeSet()
    s.erase(BE.lowerBound(E(v: 1)) ..< BE.upperBound(E(v: 2)))
    XCTAssertEqual(s.count, 3)
  }
}
#endif
