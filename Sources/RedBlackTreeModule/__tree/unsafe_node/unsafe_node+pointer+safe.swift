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

/// ポインタ操作でいちいちsealingしたくない場合に使う
public typealias _SafePtr = Result<UnsafeMutablePointer<UnsafeNode>, SealError>

extension Result where Success == UnsafeMutablePointer<UnsafeNode>, Failure == SealError {
  /// ポインタが変化した場合に用いる
  ///
  /// 重ねてsealしないこと
  @inlinable @inline(__always)
  var seal: _SealedPtr { flatMap { $0.sealed } }
}

public typealias _SealedPtr = Result<_NodePtrSealing, SealError>

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  /// ポインタを渡すときまたは受け取ったときに用いる
  ///
  /// 重ねてsealしないこと
  @inlinable @inline(__always)
  var sealed: _SealedPtr {
    if ___is_null {
      return .failure(.null)
    } else if ___is_garbaged {
      return .failure(.garbaged)
    } else {
      return .success(.uncheckedSeal(self))
    }
  }
}

extension Result where Success == _NodePtrSealing, Failure == SealError {
  @inlinable @inline(__always)
  var purified: Result { flatMap { $0.purified } }
}

public enum SealError: Error {
  /// nullptrが生じた
  case null
  /// 回収された
  ///
  /// ただし、unsealedにも含まれる。こちらは封印前に失敗した場合のみとなる
  case garbaged
  /// 知らない
  ///
  /// 何か変なことしてんちゃう？
  case unknown
  /// 指定された限界を越えて操作した
  ///
  /// `index(_:by:limit:)` で指定された `limit` を越える移動を試みた
  case limit
  /// 未許可
  ///
  /// 半分わすれたが、多分大本の木が解放済み
  case notAllowed
  /// 封印が剥がされた
  ///
  /// 封印を剥がして転生しちゃったみたい
  case unsealed

  /// nullptrに到達した
  ///
  /// 平衡木の下限を超えた操作を行ったことを表す
  case lowerOutOfBounds

  /// endを越えようとした
  ///
  /// 平衡木の上限を超えた操作を行ったことを表す
  case upperOutOfBounds
}

extension Result where Success == _NodePtrSealing, Failure == SealError {

  @inlinable
  var unchecked_pointer: Result<UnsafeMutablePointer<UnsafeNode>, SealError> {
    map { $0.pointer }
  }

  @inlinable
  var unchecked_trackingTag: Result<TaggedSeal, SealError> {
    map { $0.tag }
  }
}

extension Result where Success == _NodePtrSealing, Failure == SealError {

  @usableFromInline
  internal var isValid: Bool {
    switch purified {
    case .success: true
    default: false
    }
  }

  @usableFromInline
  internal var ___is_end: Bool? {
    // endは世代が変わらず、成仏もしないのでお清めお祓いが無駄
    try? map { $0.pointer.___is_end }.get()
  }

  @usableFromInline
  internal var ___is_root: Bool? {
    try? purified.map { $0.pointer.__parent_.___is_end }.get()
  }

  @usableFromInline
  internal func __is_equals(_ p: UnsafeMutablePointer<UnsafeNode>) -> Bool? {
    try? purified.map { $0.pointer == p }.get()
  }

  @usableFromInline
  func __value_<_PayloadValue>() -> UnsafeMutablePointer<_PayloadValue>? {
    try? purified.map { $0.pointer.__value_() }.get()
  }

  @inlinable
  var pointer: UnsafeMutablePointer<UnsafeNode>? {
    try? purified.map { $0.pointer }.get()
  }
  
  @inlinable
  var sealing: _NodePtrSealing? {
    try? purified.map { $0 }.get()
  }
  
  @inlinable
  var unchecked_sealing: _NodePtrSealing? {
    try? map { $0 }.get()
  }
}

extension Result where Success == UnsafeMutablePointer<UnsafeNode>, Failure == SealError {

  @usableFromInline
  internal var isValid: Bool {
    switch self {
    case .success: true
    default: false
    }
  }

  @usableFromInline
  internal var ___is_end: Bool? {
    try? map { $0.___is_end }.get()
  }
}

extension Result where Failure == SealError {
  @usableFromInline
  internal func isError(_ e: SealError) -> Bool {
    switch self {
    case .success:
      return false
    case .failure(let failure):
      return failure == e
    }
  }
}
