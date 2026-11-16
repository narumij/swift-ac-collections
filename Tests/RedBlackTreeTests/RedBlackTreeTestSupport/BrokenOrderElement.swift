// 順序崩れのテストの前提
// - 赤黒木の形は回転と色の付け替えだけで決まり、キーの比較を使わない。そのため、比較が全順序でなくても、
//   木は正しい赤黒木のままで、範囲を使わない木全体の走査は安全に動く。
// - 問題になるのは、比較の結果を位置の前後として使う場所（Viewの範囲、distance、範囲のerase）だけである。
//   そこは、位置で決め直すか、端を越える前に止めることで、メモリ安全性を守る。
// - 保証するのはメモリ安全性だけで、結果の正しさは保証しない。
//
// Premise of the broken-order tests
// - The shape of a red-black tree is decided only by rotations and recoloring, which do not use key
//   comparison. So even when the comparison is not a total order, the tree stays a valid red-black tree,
//   and whole-tree traversal that uses no range runs safely.
// - The problems arise only where a comparison result is used as the order of positions (view ranges,
//   distance, range erase). Those places keep memory safety by deciding again from positions, or by
//   stopping before passing an end.
// - Only memory safety is guaranteed; the correctness of results is not.

// MARK: ── 推移律を満たさない要素 ──────────────────────────────────────────

/// `<`が推移律を満たさない要素（mod 3でじゃんけんのように回る）。
///
/// 1 < 2 は成り立つが、{0, 1, 5}の木では lowerBound(1) が upperBound(2) より後ろの位置になり、
/// 範囲が逆向きになる。
/// Stringを持たせているのは、終端ノードのペイロードを読んだ場合にtrapではなく
/// SIGSEGV等で落ちるようにして、読む前に止まったことをsignalで区別するため。
struct BrokenOrderElement: Comparable, Hashable {
  var v: Int
  var s: String
  init(_ v: Int) { self.v = v; self.s = String(repeating: "\(v)", count: 40) }
  static func == (l: Self, r: Self) -> Bool { l.v == r.v }
  func hash(into hasher: inout Hasher) { hasher.combine(v) }
  static func < (l: Self, r: Self) -> Bool {
    let a = l.v % 3, b = r.v % 3
    return (b - a + 3) % 3 == 1 || (a == b && l.v < r.v)
  }
}
