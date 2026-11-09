// MARK: ── 一度しか走査できないSequence ──────────────────────────────────────

/// 中身を共有して消費する、一度しか走査できないSequence。
///
/// どのイテレータも共有の位置から続きを消費するため、
/// 2回目以降の走査では、それまでに取り出されなかった要素しか出てこない。
/// `makeIteratorCount`で`makeIterator()`が呼ばれた回数を、`isExhausted`で中身を使い切ったかを確かめられる。
final class SinglePassSequence<Element>: Sequence {
  private var remaining: [Element]
  private var position = 0
  private(set) var makeIteratorCount = 0

  init(_ elements: [Element]) { self.remaining = elements }

  var isExhausted: Bool { position >= remaining.count }

  struct Iterator: IteratorProtocol {
    let base: SinglePassSequence
    mutating func next() -> Element? {
      guard base.position < base.remaining.count else { return nil }
      defer { base.position += 1 }
      return base.remaining[base.position]
    }
  }

  func makeIterator() -> Iterator {
    makeIteratorCount += 1
    return Iterator(base: self)
  }
}
