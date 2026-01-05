// 最初に作ったヘルパー
// 他にもinstantiateを避ける工夫をしていたが迷子になったので途中だが止めている
public enum UnsafePair<_Value> {

  public typealias Pointer = UnsafePointer<UnsafeNode>
  public typealias MutablePointer = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  static func _allocationSize() -> (size: Int, alignment: Int) {
    let numBytes = MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride

    let nodeAlignment = MemoryLayout<UnsafeNode>.alignment
    let valueAlignment = MemoryLayout<_Value>.alignment

    if valueAlignment <= nodeAlignment {
      return (numBytes, MemoryLayout<UnsafeNode>.alignment)
    }

    return (
      numBytes + valueAlignment - nodeAlignment,
      MemoryLayout<_Value>.alignment
    )
  }

  @inlinable
  @inline(__always)
  static func allocationSize(capacity: Int) -> (size: Int, alignment: Int) {
    let (bytes, alignment) = _allocationSize()
    return (bytes * capacity, alignment)
  }

  @inlinable
  @inline(__always)
  static func pointer(from storage: UnsafeMutableRawPointer) -> MutablePointer {
    let headerAlignment = MemoryLayout<UnsafeNode>.alignment
    let elementAlignment = MemoryLayout<_Value>.alignment

    if elementAlignment <= headerAlignment {
      return storage.assumingMemoryBound(to: UnsafeNode.self)
    }

    return storage.advanced(by: MemoryLayout<UnsafeNode>.stride)
      .alignedUp(for: _Value.self)
      .advanced(by: -MemoryLayout<UnsafeNode>.stride)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  @inline(__always)
  static func advance(_ p: MutablePointer, _ n: Int = 1) -> MutablePointer {
    UnsafeMutableRawPointer(p)
      .advanced(by: (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride) * n)
      .alignedUp(for: UnsafeNode.self)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  @inline(__always)
  static func valuePointer(_ p: MutablePointer?) -> UnsafeMutablePointer<_Value>? {
    guard let p else { return nil }
    return valuePointer(p)
  }

  @inlinable
  @inline(__always)
  static func valuePointer(_ p: MutablePointer) -> UnsafeMutablePointer<_Value> {
    UnsafeMutableRawPointer(p.advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
  }
}
