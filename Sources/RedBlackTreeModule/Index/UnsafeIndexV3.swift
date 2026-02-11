//
//  UnsafeIndexV3.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/11.
//

public typealias _TiedPtr = Result<_TieWrap<_NodePtrSealing>, SealError>

extension Result where Success == _TieWrap<_NodePtrSealing>, Failure == SealError {

  /// ポインタを利用する際に用いる
  @inlinable @inline(__always)
  var purified: Result { flatMap { $0.purified } }
}

public typealias UnsafeIndexV3 = _TiedPtr

extension Result where Success == _TieWrap<_NodePtrSealing>, Failure == SealError {
  @inlinable
  package var isValid: Bool {
    switch purified {
    case .success: true
    default: false
    }
  }

  @inlinable
  package var sealed: _SealedPtr {
    get { map(\.rawValue) }
    set { self = newValue.band(tied!) }
  }
}

extension Result where Success == _TieWrap<_NodePtrSealing>, Failure == SealError {
  @usableFromInline package var value: _TrackingTag? { try? map(\.rawValue.tag.value).get() }
}

#if DEBUG
  extension Result where Success == _TieWrap<_NodePtrSealing>, Failure == SealError {

    internal static func unsafe<Base: ___TreeBase>(tree: UnsafeTreeV2<Base>, rawTag: _TrackingTag)
      -> Self
    {
      if rawTag == .nullptr {
        return .failure(.null)
      }
      return tree[__retrieve_: rawTag].flatMap(\.sealed).flatMap { $0.band(tree.tied) }
    }
  }
#endif
