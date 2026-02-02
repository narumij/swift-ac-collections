//
//  unsafe_node+pointer+safe.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/02.
//

public typealias SafePtr = Result<_NodePtrSealing, SafePtrError>

@inlinable
@inline(__always)
func success(_ p: UnsafeMutablePointer<UnsafeNode>) -> SafePtr {
  assert(!p.___is_garbaged)
  return .success(.init(p))
}

public enum SafePtrError: Error {
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

extension Result
where
  Success == _NodePtrSealing,
  Failure == SafePtrError
{
  @inlinable
  @inline(__always)
  var checked: Result {
    self.flatMap { _node_ptr in
      // validなpointerがendやnullに変化することはない
      _node_ptr.isUnsealed
        ? .failure(.unsealed)
        : .success(_node_ptr)
    }
  }
  
  @inlinable
  var pointer: Result<UnsafeMutablePointer<UnsafeNode>, SafePtrError> {
    checked.map { $0.pointer }
  }
  
  @inlinable
  var trackingTag: Result<RedBlackTreeTrackingTag, SafePtrError> {
    checked.map { .create($0) }
  }

  @inlinable
  var unchecked_pointer: Result<UnsafeMutablePointer<UnsafeNode>, SafePtrError> {
    map { $0.pointer }
  }
  
  @inlinable
  var unchecked_trackingTag: Result<RedBlackTreeTrackingTag, SafePtrError> {
    map { .create($0) }
  }
}
