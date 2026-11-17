//
//  SealError.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/11/17.
//

public enum SealError: Error {

  // nullptrが生じた
  //
  // 把握済みのケースは他のエラーとなるはずなので、これが生じるのは基本的にバグ
  case null

  // 回収された
  //
  // ただし、unsealedにも含まれる。こちらは封印前に失敗した場合のみとなる
  case garbaged

  // 知らない
  //
  // 何か変なことしてんちゃう？
  case unknown

  // 指定された限界を越えて操作した
  //
  // `index(_:by:limit:)` で指定された `limit` を越える移動を試みた
  case limit

  // 未許可
  //
  // 半分わすれたが、多分大本の木が解放済み
  //
  // これが発生するのは基本的にバグ
  case notAllowed

  // 封印が剥がされた
  //
  // 封印を剥がして転生しちゃったみたい
  case unsealed

  // nullptrに到達した
  //
  // 平衡木の下限を超えた操作を行ったことを表す
  case lowerOutOfBounds

  // endを越えようとした
  //
  // 平衡木の上限を超えた操作を行ったことを表す
  case upperOutOfBounds

  case outOfBounds

  #if !ALLOW_CROSS_TREE_INDEX
    // 木が不一致
    case crossTree
  #endif

  // 木と分離済み
  case detached

  // あとでエラーの扱いを変える予定のもの
  case other
}

extension SealError: Equatable {}
extension SealError: Comparable {}
extension SealError: Hashable {}


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

@usableFromInline
package func errorMessage<E: Error>(_ e: E) -> String {
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

extension Result where Failure == SealError {
  
  @inlinable
  func unsafeGet() -> Success {
    switch self {
    case .success(let success): return success
    case .failure(let error): fatalError(errorMessage(error))
    }
  }
}
