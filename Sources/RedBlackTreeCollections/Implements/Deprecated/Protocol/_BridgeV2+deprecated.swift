#if COMPATIBLE_ATCODER_2025
  @usableFromInline
  protocol _PtrRangeCompBridge: _BaseBridge
  where Base: _BaseNode_PtrRangeCompInterface {}

  extension _PtrRangeCompBridge {

    @inlinable
    func ___ptr_range_comp(_ __f: Base._NodePtr, _ __p: Base._NodePtr, _ __l: Base._NodePtr) -> Bool
    {
      Base.___ptr_range_comp(__f, __p, __l)
    }
  }
#endif
