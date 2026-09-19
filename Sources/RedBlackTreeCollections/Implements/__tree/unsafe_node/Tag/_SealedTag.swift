//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

@usableFromInline
package typealias _SealedTag = Result<_TrackingTagSealing, SealError>

/// トラッキング番号解決の補助データ構造
@frozen
@usableFromInline
package enum _TrackingTagSealing: Equatable {
  case end
  case tag(raw: _TrackingTag, seal: UnsafeNode.Seal)
}

extension _TrackingTagSealing {

  /// - Parameter raw
  /// `_TrackingTag`はIntのエイリアス
  @inlinable
  static func seal(raw: _TrackingTag, seal: UnsafeNode.Seal) -> Self {
    switch raw {
    case .end:
      return .end
    case 0...:
      return .tag(raw: raw, seal: seal)
    default:
      // raw値が負のケース
      // TODO: fix message
      fatalError("Attempting to access RedBlackTree elements using an invalid index")
    }
  }
}
