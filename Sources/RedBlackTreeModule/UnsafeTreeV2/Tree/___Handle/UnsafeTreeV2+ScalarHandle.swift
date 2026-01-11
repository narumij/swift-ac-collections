/// SetやMultiset用に特殊化されたハンドル
///
/// `_Key`の取得に関して特殊化済みとなっている。
///
/// その他に比較演算の強制キャストによる特殊化も盛り込まれている。
///
@frozen
@usableFromInline
struct UnsafeTreeV2ScalarHandle<_Key: Comparable> {
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
  @usableFromInline typealias _Value = _Key
  @usableFromInline typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  @usableFromInline typealias _Pointer = _NodePtr
  @usableFromInline typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
  @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2Buffer<_Value>.Header>
  @usableFromInline let origin: UnsafeMutablePointer<UnsafeTreeV2Origin>
  @usableFromInline var isMulti: Bool
  @usableFromInline var specializeMode: SpecializeMode
}

extension UnsafeTreeV2 where _Key == _Value, _Key: Comparable {

  @usableFromInline
  typealias Handle = UnsafeTreeV2ScalarHandle<UnsafeTreeV2<Base>._Value>

  @inlinable
  @inline(__always)
  internal func read<R>(_ body: (Handle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = Handle(header: header, origin: elements)
      return try body(handle)
    }
  }

  @inlinable
  @inline(__always)
  internal func update<R>(_ body: (Handle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = Handle(header: header, origin: elements)
      return try body(handle)
    }
  }
}

extension UnsafeTreeV2ScalarHandle {

  @inlinable
  @inline(__always)
  func __key(_ __v: _Value) -> _Key { __v }

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
  func __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key) -> __eager_compare_result {
    specializeMode.synth_three_way(__lhs, __rhs)
  }

  @inlinable
  @inline(__always)
  func __comp(_ __lhs: _Key, _ __rhs: _Key) -> __eager_compare_result {
    specializeMode.synth_three_way(__lhs, __rhs)
  }
}

// MARK: - TreeNodeValueProtocol

extension UnsafeTreeV2ScalarHandle {

  @inlinable
  @inline(__always)
  func __get_value(_ p: _NodePtr) -> _Key {
    UnsafePair<_Value>.valuePointer(p)!.pointee
  }
}

extension UnsafeTreeV2ScalarHandle: UnsafeTreeHandleBase {}

extension UnsafeTreeV2ScalarHandle: BoundProtocol, BoundAlgorithmProtocol_old {}
extension UnsafeTreeV2ScalarHandle: FindProtocol {}
extension UnsafeTreeV2ScalarHandle: FindEqualProtocol, FindEqualProtocol_std {}
extension UnsafeTreeV2ScalarHandle: InsertNodeAtProtocol {}
extension UnsafeTreeV2ScalarHandle: InsertUniqueProtocol {}
extension UnsafeTreeV2ScalarHandle: RemoveProtocol {}
extension UnsafeTreeV2ScalarHandle: EraseProtocol {}
extension UnsafeTreeV2ScalarHandle: EraseUniqueProtocol {}
