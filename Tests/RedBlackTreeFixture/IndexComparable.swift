// IndexのComparable準備実装。製品APIには適合を公開しない。
#if DEBUG
@testable import RedBlackTreeCollections

// 本体を経由しないとメモリ安全な比較ができず、それを不要にすると性能が落ちるので、本実装ではインデックスのComparableは提供できない
//
// O(log N)を許容できるならpath bitmap方式で可能だが、遅いので嫌です。
//
// どうしても順序が知りたかったらdistance(from:to:)をつかえばいい
  extension _LazyTie {

    package static func < (lhs: _LazyTie, rhs: _LazyTie) -> Bool {
      ObjectIdentifier(lhs) < ObjectIdentifier(rhs)
    }
  }

  extension _NodePtrSealing {

    // 思い浮かんだので予備的に書いてみた
    // slowとはいえ、計算量はO(log n)で大差ない
    package func lessThanSlow(_ rhs: Self) -> Bool {
      let end = pointer.__slow_end()
      let rhs_end = rhs.pointer.__slow_end()
      if end != rhs_end {
        return Int(bitPattern: end) < Int(bitPattern: rhs_end)
      }
      return ___ptr_comp_bitmap(pointer, rhs.pointer)
    }
  }

  extension _NodePtrSealing: Comparable {

    // swift-collections 1.7.0でContainerのIndexにComparable要求がある
    // 平衡木だから比較がO(log n)で済むけれど、雑な木や普通のリンクリストだと無理なんじゃないかと
    // O(1)期待があるので、値比較を主とし、このポインタ比較実装はフォールバックとしての利用が望ましい
    public static func < (lhs: _NodePtrSealing, rhs: _NodePtrSealing) -> Bool {
      ___ptr_comp_bitmap(lhs.pointer, rhs.pointer)
    }
  }

// 本体を経由しないとメモリ安全な比較ができず、それを不要にすると性能が落ちるので、本実装ではインデックスのComparableは提供できない
//
// O(log N)を許容できるならpath bitmap方式で可能だが、遅いので嫌です。
//
// どうしても順序が知りたかったらdistance(from:to:)をつかえばいい
extension _LazyTieWrapV2: Comparable {

  // swift-collections 1.7.0でContainerのIndexにComparable要求がある
  // 平衡木だから比較がO(log n)で済むけれど、雑な木や普通のリンクリストだと無理なんじゃないかと
  //
  // 値の利用まで考慮すると、unique系ではO(1)比較が可能。mult系では最悪O(log n)となる。
  //
  public static func < (lhs: _LazyTieWrapV2, rhs: _LazyTieWrapV2) -> Bool {
    if lhs.lazyDetach !== rhs.lazyDetach {
      return lhs.lazyDetach < rhs.lazyDetach
    }
    precondition(!lhs.lazyDetach.isDetached, .invalidIndex)
    return lhs.rawValue < rhs.rawValue
  }
}

#endif
