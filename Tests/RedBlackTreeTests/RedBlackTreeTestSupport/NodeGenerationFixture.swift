#if DEBUG && !COMPATIBLE_ATCODER_2025
@testable import RedBlackTreeCollections

/// 一意に所有された木の生存ノードに対して、世代の境界直前を作る。
/// Indexの保存済み世代は変更しない。世代変更後のIndexが必要なら木から取り直す。
enum NodeGenerationFixture {
  static func set(_ generation: UnsafeNode.Seal, at index: _LazyTiedPtrV2) {
    precondition(!index.lazyDetach.isDetached)
    precondition(index.rawValue.pointer.pointee.___has_payload_content)
    index.rawValue.pointer.pointee.___recycle_count = generation
  }

  /// 木が保持している初期化済みノードに限って読む。全削除・木の破棄後には使わない。
  static func generation(at index: _LazyTiedPtrV2) -> UnsafeNode.Seal {
    index.rawValue.pointer.pointee.___recycle_count
  }
}
#endif
