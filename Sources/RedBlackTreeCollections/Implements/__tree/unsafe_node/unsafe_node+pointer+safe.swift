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

//
// 不正なポインタとして以下がある
// - nullptr
// - 解放済みポインタ
// - 再利用ポインタ
//
// 半分不正なポインタとして以下がある
// - end
//
// nullptrを返すメソッドや関数は限られていて、__tree_next_iterや__tree_prev_iter等に限られる
// これを防ぐには_SafePtrを用いてエラーとして捉え、以後のnullptrを防ぐようにする
// これを徹底することで、_SafePtrを用いる限りnullptrを毎回チェックする必要から解放される
//
// endは範囲指定などでは終端として使われれたり、空の範囲を表現するのに用いられる
// endが不正になるのは要素へのアクセスの場合に限られる。そういった場面でチェックしエラーとして伝播するようにする
// このチェックはポインタの種別に関わらず常に必要
//
// 解放済みポインタを返すメソッドは存在しない。外部での変更に限られる
// 解放済みポインタの可能性がある場合は内部にそれを取り込む際にチェックしエラーとして伝播またはトラップする
//
// 再利用済みポインタを返すメソッドはcontruct_nodeがある。外部から来たポインタと意味の不一致を起こす
// 再利用済みポインタの可能性がある場合は内部にそれを取り込む前にチェックしエラーとして伝播またはトラップする
//
// これらが徹底できていると、気にするべきなのはendで大丈夫かどうかと、nullptrが漏れてないか、という点だけになる
//
// ---
//
// nullptrはノード終端として用いられている
// 通常は0x0をnullptrとして用いるが、この実装では実態があり固有のアドレスがあり共通の番兵として表現されている
//
// endは木の根側の端として用いられている
// 各木ごとにendがあり木ごとの実態ががある
//
// ---
//
// 木や基礎的な関数のレベルではなるべく生ポインタを用い、nullptrが漏れる可能性がある部分は_SafePtrを返す
//
// コンテナのレベルでは生ポインタ又は_SafePtrを常用することになり、
// それ以外の特殊ポインタは受け取るとき、返す時のみとなる
//
// 不正なポインタのトラップ（fatalError）は、その利用が未定義動作、未規定動作となる場合に限定し、そこまで遅延してよい
//
// 再利用済みポインタの措置は未規定動作をユーザーにどの程度晒すかという問題である
// この未基底動作予防は不慣れなユーザーへの配慮であり、熟練者へのメッセージとなる
//
// ---
//
// 追記:
//
// C++の__tree由来の部分を原木、内部木を生木と表現すると会話が楽
//
// コピー後の木やまったく異なる木については現在はゆるい動作となっているが、将来的に厳しくする可能性もある
//
// ---
//
// ギリギリの性能がどうしても必要な向きのために、_SafePtrをインデックスとするtraitを付与する可能性もある
// （競技プログラミング用ではない）
// （互換動作を削除して以後）
//

/// エラー補足付きポインタ
public typealias _SafePtr = Result<UnsafeMutablePointer<UnsafeNode>, SealError>

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  // 木側は無効な生ポインタを返さないようにできているので、これで足りる
  @inlinable
  package var unchecked: _SafePtr {
    assert(!___is_null)
    return .success(self)
  }

  /// ペイロードを持っているかどうかを返す
  ///
  /// nullptr、end、解放済みポインタかどうかをひとまとめに判定できる
  @inlinable
  var ___has_payload_content: Bool {
    pointee.___has_payload_content
  }

  #if false
    // 将来用
    @inlinable
    var pointer: UnsafeMutablePointer<UnsafeNode> {
      fatalError()
    }
  #endif
}

extension Result where Success == UnsafeMutablePointer<UnsafeNode>, Failure == SealError {

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
  var ___is_end: Bool {
    switch self {
    case .success(let success):
      success.___is_end
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

  // 内部的に不正なポインタを返す場合、それは返す側のバグなので、ケアとしては最低限で足りる
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

  // 内部的に不正なポインタを返す場合、それは返す側のバグなので、ケアとしては最低限で足りる
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
}

extension Result where Success == _NodePtrSealing, Failure == SealError {

  @inlinable
  package var pointer: UnsafeMutablePointer<UnsafeNode>? {
    // TODO: 利用側でpurified十分か繰り返し確認すること
    try? map { $0.pointer }.get()
  }

  @inlinable
  package var accessible: Self {
    flatMap { $0.pointer.___has_payload_content ? .success($0) : .failure(.garbaged) }
  }
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
