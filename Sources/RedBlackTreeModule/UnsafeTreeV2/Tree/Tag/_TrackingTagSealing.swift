//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
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

  @inlinable
  static func seal(raw: _TrackingTag, seal: UnsafeNode.Seal) -> Self {
    switch raw {
    case .end:
      return .end
    case 0...:
      return .tag(raw: raw, seal: seal)
    default:
      fatalError(.invalidIndex)
    }
  }
}
