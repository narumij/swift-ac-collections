//
//  TaggedSeal.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/05.
//

/// 赤黒木用軽量インデックス
///
/// - note: for文の範囲指定に使えない
///
public typealias _SealedTag = Result<_TrackingTagSealing, SealError>

extension Result where Success == _TrackingTagSealing, Failure == SealError {

  @inlinable
  var value: _TrackingTag? {
    switch self {
    case .failure:
      return nil
    case .success(let t):
      return t.raw
    }
  }
}
