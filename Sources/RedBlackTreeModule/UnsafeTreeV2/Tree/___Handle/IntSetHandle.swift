@usableFromInline
struct IntSetHandle<_Value: Comparable> {
  @inlinable
  internal init(header: UnsafeMutablePointer<UnsafeTreeV2Buffer<_Value>.Header>, origin: UnsafeMutablePointer<UnsafeTreeV2Origin>) {
    self.header = header
    self.origin = origin
  }
  public typealias _Key = _Value
  public typealias _Value = _Value
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
  public typealias _Pointer = _NodePtr
  @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2Buffer<_Value>.Header>
  @usableFromInline let origin: UnsafeMutablePointer<UnsafeTreeV2Origin>
}

//extension IntSetHandle: TreeNodeProtocol & UnsafeTreeHandleBase { }

