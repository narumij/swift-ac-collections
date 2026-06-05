//
//  UnsafeTreeV2+subscript+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/06/06.
//

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
