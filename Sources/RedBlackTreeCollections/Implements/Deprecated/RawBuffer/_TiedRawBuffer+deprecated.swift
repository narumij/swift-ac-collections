//
//  _TiedRawBuffer+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/10.
//

#if COMPATIBLE_ATCODER_2025
  extension _TiedRawBuffer {
    @nonobjc
    @inlinable
    public func _isIdentical(to other: _TiedRawBuffer) -> Bool {
      self === other
    }
  }

  extension _TiedRawBuffer.Header {

    @usableFromInline
    subscript(___tracking_tag: _TrackingTag) -> _NodePtr? {
      assert(___tracking_tag >= 0, "特殊ノードの取得要求をされないこと")
      var remaining = ___tracking_tag
      var p = bucketHead?.accessor(payload: deallocator.payload)
      while let h = p {
        let cap = h.capacity
        if remaining < cap {
          return h[remaining]
        }
        remaining -= cap
        p = h.next(payload: deallocator.payload)
      }
      assert(false, "ここには到達しないこと")
      return nil
    }
  }

  extension _TiedRawBuffer {

    @nonobjc
    @inlinable
    subscript(___tracking_tag: _TrackingTag) -> _NodePtr? {
      header[___tracking_tag]
    }
  }

  extension _TiedRawBuffer {

    @nonobjc
    @usableFromInline
    var begin_ptr: UnsafeMutablePointer<_NodePtr>? {
      header.bucketHead?.begin_ptr
    }
  }

  extension _TiedRawBuffer {

    @nonobjc
    @usableFromInline
    var end_ptr: _NodePtr? {
      header.bucketHead?.end_ptr
    }
  }

  // MARK: - COMPATIBLE_ATCODER_2025用

  extension _TiedRawBuffer {

    /// つながりをたぐりよせる
    ///
    /// 日本人的にはお祭りなどによくある千本引きのイメージ
    @inlinable
    package func __retrieve_(_ tag: _TrackingTag) -> _SafePtr {
      switch tag {
      case .nullptr: .failure(.null)
      case .end: .success(end_ptr!)
      default: tag < capacity ? .success(self[tag]!) : .failure(.unknown)
      }
    }
  }

  extension _TiedRawBuffer {

    @inlinable
    package func ___retrieve(tag: _TrackingTagSealing) -> _SealedPtr {
      switch tag {
      case .end:
        return end_ptr.map { $0.sealed } ?? .failure(.null)
      case .tag(let raw, let seal):
        guard raw < capacity else {
          return .failure(.unknown)
        }
        return self[raw]
          .map { .success(.uncheckedSeal($0, seal)) }
          ?? .failure(.null)
      }
    }

    /// つながりをたぐりよせる
    ///
    /// 日本人的にはお祭りなどによくある千本引きのイメージ
    @inlinable
    package func __retrieve_(_ tag: _SealedTag) -> _SealedPtr {
      tag.flatMap { ___retrieve(tag: $0) }
    }
  }
#endif
