//
//  unsafe_node+pointer+sealing.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/02.
//

/// ノードに封印を施す
///
/// 転生前のノードと転生後のノードを同一として扱うことを避けるための仕組み
///
/// 封が剥がされ、解かれた場合、現世のノードではないことを表す
///
@frozen
public struct _NodePtrSealing: Equatable {
  /// ご神体の御名
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  /// ご神体
  @usableFromInline var pointer: _NodePtr
  /// 封印
  @usableFromInline var seal: UnsafeNode.Seal

  @inlinable
  @inline(__always)
  init(_ p: _NodePtr) {
    pointer = p
    seal = p.pointee.___recycle_count
  }

  /// 封印が剥がされているかどうかを返す
  ///
  /// 結果が偽で封印が有効な場合は現世ノードであることをあらわす.
  ///
  /// 封印が剥がされたものは呪物扱い
  @inlinable
  @inline(__always)
  var isUnsealed: Bool {
    // 死後と転生後を判定している
    // destroyで回収されてgarbagedになるとそれは死後の世界.
    // 再度転生するとgarbagedではなくなる.
    // recycle countが不一致となれば現世のノードを指していないことがわかる.
    pointer.___is_garbaged || pointer.pointee.___recycle_count != seal
  }

  // MARK: - Convenience

  @inlinable
  var pointee: UnsafeNode {
    _read { yield pointer.pointee }
    _modify {
      guard !isUnsealed else {
        fatalError(.invalidIndex)
      }
      yield &pointer.pointee
    }
  }
  @inlinable
  @inline(__always)
  var trackingTag: Int {
    pointer.pointee.___tracking_tag
  }
  @inlinable
  @inline(__always)
  var ___is_null: Bool {
    pointer.___is_null
  }
  @inlinable
  @inline(__always)
  var ___is_null_or_end: Bool {
    pointer.___is_null_or_end
  }
  @inlinable
  @inline(__always)
  var ___is_end: Bool {
    pointer.___is_end
  }
  @inlinable
  @inline(__always)
  var ___is_garbaged: Bool {
    pointer.___is_garbaged
  }
}
