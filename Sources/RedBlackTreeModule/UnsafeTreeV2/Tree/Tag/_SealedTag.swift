//
//  TaggedSeal.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/05.
//

// SealedTagが適切な気がしてきている
/// 赤黒木用軽量インデックス
///
/// - note: for文の範囲指定に使えない
///
public typealias _SealedTag = Result<_TrackingTagSealing, SealError>

extension Result where Success == _TrackingTagSealing, Failure == SealError {
  // タグをsalt付きに移行する場合、タグの生成は木だけが行うよう準備する必要がある
  // 競プロ用としてはsaltなしでいい。一般用として必要かどうかの判断となっていく

  /// 失敗とendを除外する
  @inlinable
  static func sealedTagOrNil(_ t: UnsafeMutablePointer<UnsafeNode>?) -> Result? {
    t.flatMap { .sealOrNil($0) }.map { .success($0) }
  }

  @inlinable
  static func sealedTag(_ t: UnsafeMutablePointer<UnsafeNode>) -> Result {
    .success(.seal(t))
  }
}

#if DEBUG
  extension Result where Success == _TrackingTagSealing, Failure == SealError {

    @inlinable
    var __is_null_or_end: Bool? {
      switch self {
      case .failure: nil
      case .success(let t): t.__is_null_or_end
      }
    }

    @inlinable
    var __is_null: Bool? {
      switch self {
      case .failure: nil
      case .success(let t): t.__is_null
      }
    }

    @inlinable
    var __is_end: Bool? {
      switch self {
      case .failure: nil
      case .success(let t): t.__is_end
      }
    }
  }
#endif

#if DEBUG
  extension Result where Success == _TrackingTagSealing, Failure == SealError {

    @inlinable
    var value: _TrackingTag? {
      switch self {
      case .failure: nil
      case .success(let t): t.raw
      }
    }
  }
#endif

#if DEBUG
  extension Result where Success == _TrackingTagSealing, Failure == SealError {

    public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

    @usableFromInline
    package var rawValue: (raw: _TrackingTag, seal: UnsafeNode.Seal)? {
      guard let tag = try? get() else {
        return nil
      }
      return tag.rawValue
    }

    package static func unsafe<Base>(tree: UnsafeTreeV2<Base>, rawTag: _TrackingTag) -> Self {
      if rawTag == .nullptr {
        return .failure(.null)
      }
      if rawTag == .end {
        return .success(.end)
      }
      return .success(.tag(raw: rawTag, seal: 0))
    }

  }
#endif
