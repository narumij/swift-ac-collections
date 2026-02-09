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
public typealias TaggedSeal = Result<TagSeal_, SealError>

extension Result where Success == TagSeal_, Failure == SealError {
  // タグをsalt付きに移行する場合、タグの生成は木だけが行うよう準備する必要がある
  // 競プロ用としてはsaltなしでいい。一般用として必要かどうかの判断となっていく

  /// 失敗とendを除外する
  @inlinable
  static func taggedSealOrNil(_ t: UnsafeMutablePointer<UnsafeNode>?) -> Result? {
    t.flatMap { .sealOrNil($0) }.map { .success($0) }
  }

  @inlinable
  static func taggedSeal(_ t: UnsafeMutablePointer<UnsafeNode>) -> Result {
    .success(.seal(t))
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
