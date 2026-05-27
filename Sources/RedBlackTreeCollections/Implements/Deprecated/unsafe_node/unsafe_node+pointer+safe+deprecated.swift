//
//  unsafe_node+pointer+safe+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/27.
//

#if COMPATIBLE_ATCODER_2025
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
  }

  extension Result where Success == UnsafeMutablePointer<UnsafeNode>, Failure == SealError {

    /// ポインタが変化した場合に用いる
    ///
    /// 重ねてsealしないこと
    @inlinable
    var sealed: _SealedPtr { flatMap { $0.sealed } }
  }

  extension Result where Success == _NodePtrSealing, Failure == SealError {

    @inlinable
    package var trackingTag: _TrackingTag {
      (try? map(\.pointer.trackingTag).get()) ?? .nullptr
    }

    @inlinable
    package var ___is_end: Bool? {
      // endは世代が変わらず、成仏もしないのでお清めお祓いが無駄
      try? map { $0.pointer.___is_end }.get()
    }
  }

  extension Result where Success == _NodePtrSealing, Failure == SealError {

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
      (try? map { !$0.pointer.___is_end }.get()) ?? false
    }
  }
#endif
