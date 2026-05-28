//
//  UnsafeTreeV2+Subscript.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/29.
//

extension UnsafeTreeV2 {

  // subscript helperなので、__always
  @inlinable
  @inline(__always)
  func _unsafeAddress(_ position: UnsafeIndexV3) -> UnsafePointer<_PayloadValue> {
    return UnsafePointer(_unsafeMutableAddress(position))
  }

  // subscript helperなので、__always
  @inlinable
  @inline(__always)
  func _unsafeMutableAddress(_ position: UnsafeIndexV3) -> UnsafeMutablePointer<_PayloadValue> {
    let sealed: _SealedPtr = __purified_(position)
    precondition(sealed.accessible.error == nil)
    return sealed.pointer!.__value_()
  }
}

#if false
  extension UnsafeTreeV2 {

    @inlinable
    internal subscript(_unsafe position: UnsafeIndexV3) -> _PayloadValue {

      @inline(__always)
      @_transparent
      unsafeAddress {
        _unsafeAddress(position)
      }
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension UnsafeTreeV2 {

    @inlinable
    internal subscript(_unsafe_raw pointer: _NodePtr) -> _PayloadValue {
      @inline(__always)
      @_transparent
      unsafeAddress {
        UnsafePointer(pointer.__value_())
      }
      @inline(__always)
      @_transparent
      nonmutating unsafeMutableAddress {
        pointer.__value_()
      }
    }
  }

  extension UnsafeTreeV2 {

    @inlinable
    internal subscript(_unsafe __safe_ptr_: _SafePtr) -> _PayloadValue {
      @inline(__always)
      @_transparent
      unsafeAddress {
        precondition(__safe_ptr_.___has_payload_content)
        return UnsafePointer(__safe_ptr_.pointer!.__value_())
      }
    }
  }

  extension UnsafeTreeV2 {

    @inlinable
    internal subscript(_unsafe sealed: _SealedPtr) -> _PayloadValue {
      @inline(__always)
      @_transparent
      unsafeAddress {
        let unsealed = sealed.accessible
        precondition(unsealed.error == nil)
        return UnsafePointer(unsealed.pointer!.__value_())
      }
    }
  }
#endif
