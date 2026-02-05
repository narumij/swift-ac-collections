//
//  TaggedSeal.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/05.
//

public enum TagSeal_: Equatable {
  case end
  case tag(raw: _RawTrackingTag, seal: UnsafeNode.Seal)
}

#if DEBUG
  extension TagSeal_ {

    @usableFromInline
    internal var _rawTag: _RawTrackingTag {
      switch self {
      case .end: .end
      case .tag(raw: let rag, seal: _): rag
      }
    }
  }
#endif

extension TagSeal_ {

  @inlinable
  static func create(raw: _RawTrackingTag, seal: UnsafeNode.Seal) -> Self {
    switch raw {
    case .end: return .end
    case 0...: return .tag(raw: raw, seal: seal)
    default:
      fatalError(.invalidIndex)
    }
  }
}

extension TagSeal_: RawRepresentable {

  @inlinable
  public init?(rawValue value: (raw: _RawTrackingTag, seal: UnsafeNode.Seal)) {
    switch value {
    case (.end, _):
      self = .end
    case (0..., _):
      self = .tag(raw: value.raw, seal: value.seal)
    default:
      return nil
    }
  }

  @inlinable
  public var rawValue: (raw: _RawTrackingTag, seal: UnsafeNode.Seal) {
    switch self {
    case .end:
      (.end, 0)
    case .tag(let _TrackingTag, let gen):
      (_TrackingTag, gen)
    }
  }
}

public typealias TaggedSeal = Result<TagSeal_, SealError>

extension Result where Success == TagSeal_, Failure == SealError {
  // タグをsalt付きに移行する場合、タグの生成は木だけが行うよう準備する必要がある
  // 競プロ用としてはsaltなしでいい。一般用として必要かどうかの判断となっていく

  /// 失敗とendを除外する
  @inlinable
  static func create_as_optional(_ t: UnsafeMutablePointer<UnsafeNode>?) -> Result? {
    t.flatMap { TagSeal_(rawValue: ($0.trackingTag, $0.pointee.___recycle_count)) }
      .flatMap {
        switch $0 {
        case .end:
          return nil
        case .tag:
          return .success($0)
        }
      }
  }

  @inlinable
  static func create(_ t: UnsafeMutablePointer<UnsafeNode>?) -> Result {
    t.flatMap { TagSeal_(rawValue: ($0.trackingTag, $0.pointee.___recycle_count)) }
      .map { .success($0) }
      ?? .failure(.null)
  }

  @inlinable
  static func create(_ t: _NodePtrSealing?) -> Result {
    t.flatMap { TagSeal_(rawValue: ($0.pointer.trackingTag, $0.seal)) }
      .map { .success($0) }
      ?? .failure(.null)
  }

  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>) -> _SealedPtr
  where Base: ___TreeBase {
    __tree_.resolve(self)
  }
}

#if DEBUG
  extension Result where Success == TagSeal_, Failure == SealError {

    public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

    @usableFromInline
    internal var _rawTag: _RawTrackingTag {
      guard let tag = try? get() else {
        return .nullptr
      }
      return tag._rawTag
    }

    @usableFromInline
    package var rawValue: (raw: _RawTrackingTag, seal: UnsafeNode.Seal)? {
      guard let tag = try? get() else {
        return nil
      }
      return tag.rawValue
    }

    internal static func unsafe<Base>(tree: UnsafeTreeV2<Base>, rawTag: _RawTrackingTag) -> Self {
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

extension TagSeal_ {
  @usableFromInline
  var __is_null_or_end: Bool {
    switch self {
    case .end: true
    case .tag(raw: let r, seal: _): ___is_null_or_end(r)
    }
  }
  @usableFromInline
  var __is_null: Bool {
    switch self {
    case .end: true
    case .tag(raw: let r, seal: _): r == .nullptr
    }
  }
  @usableFromInline
  var __is_end: Bool {
    switch self {
    case .end: true
    case .tag(raw: let r, seal: _): r == .end
    }
  }
}

extension Result where Success == TagSeal_, Failure == SealError {

  @usableFromInline
  var __is_null_or_end: Bool {
    switch self {
    case .failure: true
    case .success(let t): t.__is_null_or_end
    }
  }

  @usableFromInline
  var __is_null: Bool {
    switch self {
    case .failure: true
    case .success(let t): t.__is_null
    }
  }

  @usableFromInline
  var __is_end: Bool {
    switch self {
    case .failure: true
    case .success(let t): t.__is_end
    }
  }
}
