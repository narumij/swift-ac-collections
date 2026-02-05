//
//  TaggedSeal.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/05.
//

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
}

extension Result where Success == TagSeal_, Failure == SealError {

  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>) -> _SealedPtr
  where Base: ___TreeBase {
    __tree_.resolve(self)
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
