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
  // タグをsalt付きに移行する場合、タグの生成は木だけが行うよう準備する必要がある
  // 競プロ用としてはsaltなしでいい。一般用として必要かどうかの判断となっていく

  @inlinable
  static func sealedTag(_ t: UnsafeMutablePointer<UnsafeNode>) -> Result {
    .success(.seal(t))
  }
}
