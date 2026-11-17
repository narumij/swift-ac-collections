//
//  UnsafeTreeV2+BufferHeader+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/11/17.
//

#if COMPATIBLE_ATCODER_2025
extension UnsafeTreeV2BufferHeader {
  // IndexやIteratorを結ぶ共有メモリ
  //
  // ヘッダーにとっては解放責任のデタッチ先
  //
  // - WARNING: 触ると生成されるので不必要に触らないこと
  @usableFromInline
  var tiedRawBuffer: _TiedRawBuffer {
    mutating get {
      if _tied == nil {
        _tied = .create(
          bucket: freshBucketHead,
          deallocator: freshBucketAllocator
        )
      }
      return _tied!
    }
  }

  // IndexやIteratorとのメモリ共有が発生してないことを示す
  @usableFromInline
  var isRawBufferUniquelyOwned: Bool { _tied == nil }
}
#endif
