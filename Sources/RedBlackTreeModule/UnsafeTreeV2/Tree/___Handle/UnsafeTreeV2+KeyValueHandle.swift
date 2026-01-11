/// DictionaryやMultimap用に特殊化されたハンドル
///
/// `_Key`の取得に関して特殊化済みとなっている。
///
/// その他に比較演算の強制キャストによる特殊化も盛り込まれている。
///
@frozen
@usableFromInline
struct UnsafeTreeV2KeyValueHandle<_Key, _MappedValue> where _Key: Comparable {
  @inlinable
  internal init(
    header: UnsafeMutablePointer<UnsafeTreeV2Buffer<_Value>.Header>,
    origin: UnsafeMutablePointer<UnsafeTreeV2Origin>,
    specializeMode: SpecializeMode? = nil
  ) {
    self.header = header
    self.origin = origin
    self.isMulti = false
    // 性能上とても重要だが、コンパイラ挙動に合わせての採用でとても場当たり的
    self.specializeMode = specializeMode ?? SpecializeModeHoge<_Key>().specializeMode
  }
  @usableFromInline typealias _Key = _Key
  @usableFromInline typealias _Value = RedBlackTreePair<_Key, _MappedValue>
  @usableFromInline typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  @usableFromInline typealias _Pointer = _NodePtr
  @usableFromInline typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
  @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2Buffer<_Value>.Header>
  @usableFromInline let origin: UnsafeMutablePointer<UnsafeTreeV2Origin>
  @usableFromInline var isMulti: Bool
  @usableFromInline var specializeMode: SpecializeMode
}

extension UnsafeTreeV2
where
  Base: KeyValueComparer,
  _Key: Comparable,
  _Value == RedBlackTreePair<_Key, Base._MappedValue>
{

  @usableFromInline
  typealias KeyValueHandle = UnsafeTreeV2KeyValueHandle<_Key, Base._MappedValue>

  @inlinable
  @inline(__always)
  internal func read<R>(_ body: (KeyValueHandle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = KeyValueHandle(header: header, origin: elements)
      return try body(handle)
    }
  }

  @inlinable
  @inline(__always)
  internal func update<R>(_ body: (KeyValueHandle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = KeyValueHandle(header: header, origin: elements)
      return try body(handle)
    }
  }
}

extension UnsafeTreeV2KeyValueHandle {

  @inlinable
  @inline(__always)
  func __key(_ __v: _Value) -> _Key { __v.key }

  @inlinable
  @inline(__always)
  func value_comp(_ __l: _Key, _ __r: _Key) -> Bool {
    specializeMode.value_comp(__l, __r)
  }

  @inlinable
  @inline(__always)
  func value_equiv(_ __l: _Key, _ __r: _Key) -> Bool {
    specializeMode.value_equiv(__l, __r)
  }

  @inlinable
  @inline(__always)
  func __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key) -> __int_compare_result {
    specializeMode.synth_three_way(__lhs, __rhs)
  }

  @inlinable
  @inline(__always)
  func __comp(_ __lhs: _Key, _ __rhs: _Key) -> __int_compare_result {
    specializeMode.synth_three_way(__lhs, __rhs)
  }
}

// MARK: - TreeNodeValueProtocol

extension UnsafeTreeV2KeyValueHandle {

  @inlinable
  @inline(__always)
  func __get_value(_ p: _NodePtr) -> _Key {
    UnsafePair<_Value>.valuePointer(p)!.pointee.key
  }
}

extension UnsafeTreeV2KeyValueHandle: UnsafeTreeHandleBase {}

extension UnsafeTreeV2KeyValueHandle: BoundProtocol, BoundAlgorithmProtocol {}
extension UnsafeTreeV2KeyValueHandle: FindProtocol {}
extension UnsafeTreeV2KeyValueHandle: FindEqualProtocol, FindEqualProtocol_std {}
extension UnsafeTreeV2KeyValueHandle: InsertNodeAtProtocol {}
extension UnsafeTreeV2KeyValueHandle: InsertUniqueProtocol {}
extension UnsafeTreeV2KeyValueHandle: RemoveProtocol {}
extension UnsafeTreeV2KeyValueHandle: EraseProtocol {}
extension UnsafeTreeV2KeyValueHandle: EraseUniqueProtocol {}

extension UnsafeTreeV2KeyValueHandle {
  
}
