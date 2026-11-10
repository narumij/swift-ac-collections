// MARK: ── 推移律を満たさない要素 ──────────────────────────────────────────

/// `<`が推移律を満たさない要素（mod 3でじゃんけんのように回る）。
///
/// 1 < 2 は成り立つが、{0, 1, 5}の木では lowerBound(1) が upperBound(2) より後ろの位置になり、
/// 範囲が逆向きになる。
/// Stringを持たせているのは、終端ノードのペイロードを読んだ場合にtrapではなく
/// SIGSEGV等で落ちるようにして、読む前に止まったことをsignalで区別するため。
struct BrokenOrderElement: Comparable {
  var v: Int
  var s: String
  init(_ v: Int) { self.v = v; self.s = String(repeating: "\(v)", count: 40) }
  static func == (l: Self, r: Self) -> Bool { l.v == r.v }
  static func < (l: Self, r: Self) -> Bool {
    let a = l.v % 3, b = r.v % 3
    return (b - a + 3) % 3 == 1 || (a == b && l.v < r.v)
  }
}
