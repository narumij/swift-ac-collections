//
//  _NodePtrTracking.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/09/25.
//

@frozen
public struct _NodePtrTracking {
  
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  
  @usableFromInline var pointer: _NodePtrSealing
  @usableFromInline var trackingTag: _TrackingTag

  /// 現在の状態で封印する
  @inlinable
  init(_p: _NodePtr) {
    assert(!_p.___is_null)
    pointer = .init(_p: _p)
    trackingTag = _p.trackingTag
  }

  /// 過去の状態で封印する
  @inlinable
  init(_p: _NodePtr, _seal: UnsafeNode.Seal) {
    assert(!_p.___is_null)
    pointer = .init(_p: _p, _seal: _seal)
    trackingTag = _p.trackingTag
  }

  // 特段の意味は無い。利用箇所での可読性向上のためのフック
  /// 現在の状態で封印する
  @inlinable
  static func uncheckedSeal(_ _p: _NodePtr) -> _NodePtrSealing {
    .init(_p: _p)
  }

  // 特段の意味は無い。利用箇所での可読性向上のためのフック
  /// 過去の状態で封印する
  @inlinable
  static func uncheckedSeal(_ _p: _NodePtr, _ seal: UnsafeNode.Seal) -> _NodePtrSealing {
    .init(_p: _p, _seal: seal)
  }

  @inlinable
  var isUnsealed: Bool {
    pointer.isUnsealed
  }

  @inlinable
  var purified: _SealedPtr {
    return pointer.purified
  }

  #if ALLOW_CROSS_TREE_INDEX
    @inlinable
    var deepPurified: _SealedPtr {
      return pointer.deepPurified
    }
  #endif

  /// 引換券
  @inlinable
  var tag: _SealedTag {
    pointer.tag
  }
}

extension _NodePtrTracking: Equatable {}

#if DEBUG
  extension _NodePtrTracking {

    // 思い浮かんだので予備的に書いてみた
    // slowとはいえ、計算量はO(log n)で大差ない
    @inlinable
    func lessThanSlow(_ rhs: Self) -> Bool {
      return pointer.lessThanSlow(rhs.pointer)
    }
  }

  extension _NodePtrTracking: Comparable {

    // swift-collections 1.7.0でContainerのIndexにComparable要求がある
    // 平衡木だから比較がO(log n)で済むけれど、雑な木や普通のリンクリストだと無理なんじゃないかと
    // O(1)期待があるので、値比較を主とし、このポインタ比較実装はフォールバックとしての利用が望ましい
    @inlinable
    public static func < (lhs: _NodePtrTracking, rhs: _NodePtrTracking) -> Bool {
      lhs.pointer < rhs.pointer
    }
  }
#endif

extension _NodePtrTracking: Hashable {

  @inlinable
  public func hash(into hasher: inout Hasher) {
    pointer.hash(into: &hasher)
    trackingTag.hash(into: &hasher)
  }
}

extension _NodePtrTracking: CustomStringConvertible {
  public var description: String {
    "_NodePtrSealing<\((trackingTag: trackingTag, pointer))>"
  }
}

extension _NodePtrTracking: CustomDebugStringConvertible {
  public var debugDescription: String { description }
}

// MARK: -

#if DEBUG
extension _NodePtrTracking {

  @usableFromInline
  init(sealing: _NodePtrSealing) {
    pointer = sealing
    trackingTag = sealing.pointer.trackingTag
  }
}
#endif

