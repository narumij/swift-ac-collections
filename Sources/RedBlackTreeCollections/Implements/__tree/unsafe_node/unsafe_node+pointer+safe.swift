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

/*
 _SafePtrも、_SealedPtrも、内部利用向け。外部に渡してはいけない
 _TieWrappedPtrは依存メモリ寿命付きなので外に渡しても大丈夫
 */

// Note: ポインタを Result でくるんで使うことで、
// 失敗が（不可逆に）伝播し、不用意にポインタに触ることを防ぎやすい。
// まだ活用はしてないが、.failure 化を回収/解放の合図に利用する余地もある。

/// ポインタ操作でいちいちsealingしたくない場合に使う
public typealias _SafePtr = Result<UnsafeMutablePointer<UnsafeNode>, SealError>

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  // 無効な生ポインタを返さないようにできているので、これで足りる
  @inlinable
  package var unchecked: _SafePtr {
    assert(!___is_null)
    return .success(self)
  }

  @inlinable
  var ___has_payload_content: Bool {
    pointee.___has_payload_content
  }
}

extension Result where Success == UnsafeMutablePointer<UnsafeNode>, Failure == SealError {

  @inlinable
  package var isValid: Bool {
    switch self {
    case .success: true
    default: false
    }
  }

  @inlinable
  package var ___is_end: Bool? {
    // endは世代が変わらず、成仏もしないのでお清めお祓いが無駄
    try? map { $0.___is_end }.get()
  }

  @inlinable
  package var pointer: UnsafeMutablePointer<UnsafeNode>? {
    try? map { $0 }.get()
  }

  @inlinable
  var ___has_payload_content: Bool {
    switch self {
    case .success(let success):
      success.pointee.___has_payload_content
    case .failure:
      false
    }
  }

  @inlinable
  var accessible: _SafePtr {
    ___has_payload_content ? self : .failure(.garbaged)
  }
}

extension Result where Success == UnsafeMutablePointer<UnsafeNode>, Failure == SealError {
  /// ポインタが変化した場合に用いる
  ///
  /// 重ねてsealしないこと
  @inlinable
  var sealed: _SealedPtr { flatMap { $0.sealed } }

  @inlinable
  package var uncheckedSeal: _SealedPtr {
    map { .uncheckedSeal($0) }
  }
}

/// 世代管理付きポインタ
///
/// 外部的には、これをさらに寿命管理付きでラップして用いる
/// 内部的にはこれを用いる理由は特にない、はず
public typealias _SealedPtr = Result<_NodePtrSealing, SealError>

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  /// ポインタを渡すときまたは受け取ったときに用いる
  ///
  /// 重ねてsealしないこと
  @inlinable
  package var sealed: _SealedPtr {
    if ___is_null {
      return .failure(.null)
    } else if !___is_end, !___has_payload_content {
      // これが発生するようだと基本的にそれはバグ
      return .failure(.garbaged)
    } else {
      return .success(.uncheckedSeal(self))
    }
  }

  @inlinable
  package var uncheckedSeal: _SealedPtr {
    assert(!___is_null)
    return .success(.uncheckedSeal(self))
  }
}

extension Result where Success == _NodePtrSealing, Failure == SealError {

  /// ポインタを利用する際に用いる
  @inlinable
  package var purified: Result { flatMap { $0.purified } }

  @inlinable
  package var deepPurified: Result { flatMap { $0.deepPurified } }
}

public enum SealError: Error {

  /// nullptrが生じた
  ///
  /// 把握済みのケースは他のエラーとなるはずなので、これが生じるのは基本的にバグ
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
  ///
  /// これが発生するのは基本的にバグ
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

@usableFromInline
func errorMessage<E: Error>(_ e: E) -> String {
  switch e as? SealError {
  case .null:
    "Unexpected null pointer"
  case .garbaged:
    "Unexpected pointer to deallocated memory"
  case .unknown:
    "Unknown error"
  case .limit:
    "Reached the specified limit"
  case .notAllowed:
    "The pointer is no longer valid"
  case .unsealed:
    "The pointer is being used as a different node"
  case .lowerOutOfBounds:
    "Operation exceeded the lower bound of the balanced tree"
  case .upperOutOfBounds:
    "Operation exceeded the upper bound of the balanced tree"
  default:
    "\(e)"
  }
}

extension Result where Success == _NodePtrSealing, Failure == SealError {

  @inlinable
  package var tag: _SealedTag {
    flatMap(\.tag)
  }

  #if COMPATIBLE_ATCODER_2025
    @inlinable
    package var trackingTag: _TrackingTag {
      (try? map(\.pointer.trackingTag).get()) ?? .nullptr
    }
  
    @inlinable
    package var ___is_end: Bool? {
      // endは世代が変わらず、成仏もしないのでお清めお祓いが無駄
      try? map { $0.pointer.___is_end }.get()
    }
  #endif
}

extension Result where Success == _NodePtrSealing, Failure == SealError {

  @inlinable
  package var pointer: UnsafeMutablePointer<UnsafeNode>? {
    // TODO: 利用側でpurified十分か繰り返し確認すること
    try? map { $0.pointer }.get()
  }

  @inlinable
  package var accessible: Self {
    //    flatMap { $0.pointer.___is_null_or_end ? .failure(.end) : .success($0) }
    flatMap { $0.pointer.___has_payload_content ? .success($0) : .failure(.garbaged) }
  }

  #if COMPATIBLE_ATCODER_2025
    /// 他のケースと異なり、endも有効となる
    @inlinable
    package var isValid: Bool {
      switch purified {
      case .success: true
      default: false
      }
    }
  
    @inlinable
    package func __value_<_PayloadValue>() -> UnsafeMutablePointer<_PayloadValue>? {
      try? map { $0.pointer.__value_() }.get()
    }
  
    // TODO: 名前を変える
    @inlinable
    public var exists: Bool {
      // TODO: 利用側でpurified十分か繰り返し確認すること
      (try? map { !___is_null_or_end($0.pointer.trackingTag) }.get()) ?? false
    }
  #endif
}

extension Result {

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
}

extension Result where Failure == SealError {

  @usableFromInline
  package var error: SealError? {
    switch self {
    case .success:
      return nil
    case .failure(let failure):
      return failure
    }
  }
}

@inlinable
func liftA2<T, S, E>(_ a: Result<T, E>, _ b: Result<T, E>, _ f: (T, T) -> S) -> Result<S, E> {
  switch (a, b) {
  case (.success(let a), .success(let b)):
    return .success(f(a, b))
  case (.failure(let e), _):
    return .failure(e)
  case (_, .failure(let e)):
    return .failure(e)
  }
}

#if false
  @inlinable
  func liftM2<T, S, E>(_ a: Result<T, E>, _ b: Result<T, E>, _ f: (T, T) -> Result<S, E>) -> Result<
    S, E
  > {
    switch (a, b) {
    case (.success(let a), .success(let b)):
      return f(a, b)
    case (.failure(let e), _):
      return .failure(e)
    case (_, .failure(let e)):
      return .failure(e)
    }
  }
#endif
