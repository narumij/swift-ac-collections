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

/// ノードに封印を施す
///
/// 転生前のノードと転生後のノードを同一として扱うことを避けるための仕組み
///
/// 封が剥がされ、封印が解かれた場合、現世のノードではないことを表す
///
@frozen
public struct _NodePtrSealing: Equatable {
  /// ご神体の御名
  ///
  /// 八百万な方々
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  /// ご神体
  @usableFromInline var pointer: _NodePtr
  /// 封印
  @usableFromInline var seal: UnsafeNode.Seal

  // UnsafeNode.SealはUInt32となっていて、オーバーフローして一周すると、
  // かたわれどきが生じて同一判定となるが、これは仕様

  /// 現在の状態で封印する
  @inlinable @inline(__always)
  init(_p: _NodePtr) {
    self.init(_p: _p, _seal: _p.pointee.___recycle_count)
  }

  /// 過去の状態で封印する
  @inlinable @inline(__always)
  init(_p: _NodePtr, _seal: UnsafeNode.Seal) {
    pointer = _p
    seal = _seal
  }

  // 特段の意味は無い。利用箇所での可読性向上のためのフック
  /// 現在の状態で封印する
  @inlinable @inline(__always)
  static func uncheckedSeal(_ _p: _NodePtr) -> _NodePtrSealing {
    .init(_p: _p)
  }

  // 特段の意味は無い。利用箇所での可読性向上のためのフック
  /// 過去の状態で封印する
  @inlinable @inline(__always)
  static func uncheckedSeal(_ _p: _NodePtr, _ seal: UnsafeNode.Seal) -> _NodePtrSealing {
    .init(_p: _p, _seal: seal)
  }

  /// 封印が剥がされているかどうかを返す
  ///
  /// 結果が偽で封印が有効な場合は現世ノードであることをあらわす.
  ///
  /// 封印が剥がされたものは呪物扱い
  @inlinable @inline(__always)
  var isUnsealed: Bool {
    // 死後と転生後を判定している
    // destroyで回収されてgarbagedになるとそれは死後.
    // 再度転生するとgarbagedではなくなる.
    // recycle countが不一致となれば転生済みノードであることがわかる.
    pointer.___is_garbaged || pointer.pointee.___recycle_count != seal
  }

  /// お清め
  @inlinable @inline(__always)
  var purified: _SealedPtr {
    // validなpointerがendやnullに変化することはない
    isUnsealed ? .failure(.unsealed) : .success(self)
  }

  /// 引換券
  @inlinable @inline(__always)
  var tag: _SealedTag {
    .success(.seal(raw: pointer.pointee.___tracking_tag, seal: seal))
  }
}

// ふざけてるのが半分。残り半分は通常使わない言葉や概念から以外と大切な部分であることを察してもらうため。
// というか用語群として混ざらないようにするため

// shieldのスペルもしらんのかとか言うやつがいそうな予感があるが、大きなお世話

extension _NodePtrSealing: CustomStringConvertible {
  public var description: String {
    "_NodePtrSealing<\((tag: pointer.trackingTag, seal: seal, pointer))>"
  }
}

extension _NodePtrSealing: CustomDebugStringConvertible {
  public var debugDescription: String { description }
}
