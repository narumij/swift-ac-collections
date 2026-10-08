//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>

  @inlinable
  nonisolated(unsafe)
    package static var nullptr: _NodePtr
  {
    UnsafeNode.nullptr
  }

  @inlinable
  package var __left_: _NodePtr {
    @inline(__always) _read { yield pointee.__left_ }
    nonmutating _modify { yield &pointee.__left_ }
  }

  @inlinable
  package var __right_: _NodePtr {
    @inline(__always) _read { yield pointee.__right_ }
    nonmutating _modify { yield &pointee.__right_ }
  }

  @inlinable
  package var __parent_: _NodePtr {
    @inline(__always) _read { yield pointee.__parent_ }
    nonmutating _modify { yield &pointee.__parent_ }
  }

  // NOTE: 移植の命名互換のための別名。意味は`__parent_`と同じ。
  @inlinable
  package var __parent_unsafe: _NodePtr {
    @inline(__always) _read { yield pointee.__parent_ }
  }

  @inlinable
  func __set_parent(_ p: _NodePtr) {
    pointee.__parent_ = p
  }

  @inlinable
  package var __is_black_: Bool {
    @inline(__always) _read { yield pointee.__is_black_ }
    nonmutating _modify { yield &pointee.__is_black_ }
  }

  @inlinable
  package var __left_ref: _NodeRef {
    _ref(to: &pointee.__left_)
  }

  @inlinable
  package var __right_ref: _NodeRef {
    _ref(to: &pointee.__right_)
  }
}

// MARK: - Reference memory layout

extension UnsafeNode {

  /// `UnsafeNode`と`Payload`を隣接配置するときに領域全体へ要求するalignmentを返す。
  ///
  /// メモリ上では次の組を連続して配置する。
  ///
  /// ```
  /// |<-- pair(0) -->|<-- pair(1) -->|
  /// | Node | Payload | Node | Payload | ...
  /// ```
  ///
  /// NodeとPayloadのどちらの型付きアクセスも有効にするため、要求値は両者の
  /// alignmentの大きい方になる。この式はRawBufferの`_MemoryLayout.init(_:_:)`が
  /// `pairLayout.alignment`を求める式と同じである。
  ///
  /// - Parameter payload: Nodeへ積載する型。
  /// - Returns: Node/Payloadペア領域に必要なalignment。
  @inlinable
  package static func _referenceAlignment<Payload>(with payload: Payload.Type) -> Int {
    max(MemoryLayout<Self>.alignment, MemoryLayout<Payload>.alignment)
  }

  /// `UnsafeNode`と`Payload`一組から次の組までのbyte strideを返す。
  ///
  /// 単純な`Node.stride + Payload.stride`を、両型に必要なalignmentの倍数へ
  /// 切り上げる。これにより先頭のNodeと直後のPayloadが整列していれば、後続する
  /// すべてのNode/Payloadも同じ整列条件を保つ。
  ///
  /// ```
  /// |<------- one pair stride ------->|
  /// | Node | Payload | pair padding   | Node | Payload | ...
  /// ```
  ///
  /// この式はRawBufferの`MemoryLayout<Payload>._pairLayout.stride`と同じである。
  /// `_advanced(with:count:)`も同じ式を用いる。
  ///
  /// - Parameter payload: Nodeへ積載する型。
  /// - Returns: 連続配置されたNode/Payload一組のstride。
  @inlinable
  package static func _referenceStride<Payload>(with payload: Payload.Type) -> Int {
    let alignment = _referenceAlignment(with: payload)
    let size = MemoryLayout<Self>.stride + MemoryLayout<Payload>.stride
    return (size + alignment - 1) / alignment * alignment
  }

  /// alignment調整前のslot領域から、最初の`UnsafeNode`の位置を求める。
  ///
  /// `__value_`はNode直後をPayloadとして扱う。このためNodeだけを先に整列すると、
  /// PayloadのalignmentがNodeより強い場合にPayloadが未整列になる。ここではPayloadの
  /// 開始位置を先に切り上げ、そこからNodeのstrideだけ戻る。
  ///
  /// ```
  /// | prefix | alignment gap | Node | Payload | Node | Payload | ...
  ///
  /// storage         = prefixとalignment gapの境界
  /// result: node(0) = alignment gapとNodeの境界
  /// aligned payload = NodeとPayloadの境界
  /// ```
  ///
  /// この処理はRawBufferの`_Bucket.start(storage:payloadOrPairAlignment:)`と同じである。
  /// `storage`自体は確保領域の先頭とは限らず、Bucket metadataなどのprefix直後でもよい。
  ///
  /// - Parameters:
  ///   - storage: metadata/prefix直後にある、alignment調整前のslot領域先頭。
  ///   - payload: Nodeへ積載する型。
  /// - Returns: `node(0)`の開始アドレス。
  ///
  /// - Important: `storage`は少なくとも`UnsafeNode`のalignmentを満たす必要がある。
  ///   また呼び出し側は戻り値以降に、要求capacity分の領域が確保済みであることを
  ///   保証しなければならない。
  @inlinable
  package static func _referenceFirstNode<Payload>(
    in storage: UnsafeMutableRawPointer,
    with payload: Payload.Type
  ) -> UnsafeMutablePointer<Self> {
    let nodeStride = MemoryLayout<Self>.stride
    let payloadAlignment = MemoryLayout<Payload>.alignment
    let candidate = Int(bitPattern: storage) + nodeStride
    let alignedPayload =
      (candidate + payloadAlignment - 1) / payloadAlignment * payloadAlignment
    return UnsafeMutableRawPointer(bitPattern: alignedPayload)!
      .advanced(by: -nodeStride)
      .assumingMemoryBound(to: Self.self)
  }

  /// prefixを含む連続Node/Payload領域に必要な正確なbyte数を返す。
  ///
  /// `prefix`直後をalignment調整前の`storage`とし、最初のPayloadを整列するためのgap、
  /// `capacity - 1`組分のpair stride、最後のNodeとPayloadの実体サイズを加算する。
  /// RawBufferの`_BucketAllocator._allocationSize(prefix:capacity:)`と同じ式である。
  ///
  /// ```
  /// |< prefix >| gap | Node | Payload | ... | Node | Payload |
  /// |<------------- returned byte count -------------------->|
  /// ```
  ///
  /// - Parameters:
  ///   - prefix: 確保領域先頭からslot領域までのbyte数。
  ///   - payload: Nodeへ積載する型。
  ///   - capacity: 配置するNode/Payload組の数。0の場合はprefixだけを返す。
  /// - Returns: prefixを含む確保領域全体のbyte数。
  @inlinable
  package static func _referenceAllocationByteCount<Payload>(
    prefix: Int,
    with payload: Payload.Type,
    capacity: Int
  ) -> Int {
    precondition(prefix >= 0)
    precondition(capacity >= 0)
    guard capacity > 0 else { return prefix }
    let nodeStride = MemoryLayout<Self>.stride
    let payloadAlignment = MemoryLayout<Payload>.alignment
    let payloadOffset = prefix + nodeStride
    let leadingGap = (payloadAlignment - payloadOffset % payloadAlignment) % payloadAlignment
    return prefix
      + leadingGap
      + _referenceStride(with: payload) * (capacity - 1)
      + nodeStride
      + MemoryLayout<Payload>.stride
  }

  /// prefixを持たない単独のNode/Payload領域に必要な正確なbyte数を返す。
  ///
  /// `_referenceAllocationByteCount(prefix:with:capacity:)`へ`prefix: 0`を渡す便宜API。
  @inlinable
  package static func _referenceAllocationByteCount<Payload>(
    with payload: Payload.Type,
    capacity: Int
  ) -> Int {
    _referenceAllocationByteCount(prefix: 0, with: payload, capacity: capacity)
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  // ゆっくりendを返す
  //
  // どのくらいゆっくりかというとO(log N)ぐらい
  //
  // ルートのペアレントまたはペアレントがヌルなのがend
  @usableFromInline
  package func __slow_end() -> _NodePtr {
    var __r = self
    while __r.__parent_ != .nullptr {
      __r = __r.__parent_
    }
    return __r
  }

  // ゆっくりbeginを返す
  //
  // どのくらいゆっくりかというとO(log N)ぐらい
  //
  // ルートからたどれる最小値ノードがbegin
  package func __slow_begin() -> _NodePtr {
    __tree_min(__slow_end().__left_)
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  // ペイロードの生ポインタ
  //
  // ```
  // ...|Node|Payload|Node...
  //    |    ^--__payload_
  //    ^self
  // ```
  @inlinable
  var __raw_payload_: UnsafeMutableRawPointer {
    UnsafeMutableRawPointer(advanced(by: 1))
  }

  // ペイロードを値とみなしたポインタ
  //
  // ```
  // ...|Node|PayloadValue|Node...
  //    |    ^--__value_
  //    ^self
  // ```
  //
  // 型推論で型が決定する
  //
  // インスタンス名は既存踏襲で`__value_`。型としてはより明確な`_PayloadValue`となる。
  @inlinable
  func __value_<_PayloadValue>() -> UnsafeMutablePointer<_PayloadValue> {
    UnsafeMutableRawPointer(advanced(by: 1))
      .assumingMemoryBound(to: _PayloadValue.self)
  }

  // ペイロードを値とみなしたポインタ
  //
  // ```
  // ...|Node|PayloadValue|Node...
  //    |    ^--__value_
  //    ^self
  // ```
  //
  // 引数で型が決定する
  //
  // インスタンス名は既存踏襲で`__value_`。型としてはより明確な`_PayloadValue`となる。
  @inlinable
  package func __value_<_PayloadValue>(as t: _PayloadValue.Type) -> UnsafeMutablePointer<
    _PayloadValue
  > {
    UnsafeMutableRawPointer(advanced(by: 1))
      .assumingMemoryBound(to: _PayloadValue.self)
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  @inlinable
  var trackingTag: _TrackingTag {
    pointee.___tracking_tag
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  @inlinable
  package func _advanced(raw bytes: Int) -> UnsafeMutablePointer {
    UnsafeMutableRawPointer(self)
      .advanced(by: bytes)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  // 単位移動量と移動量を指定して、他のノードアドレスを取得する
  //
  // ```
  // ...|Node|stride|Node|stride|...
  //    |           ^self       |
  //    ^--_advanced -1         ^--_advanced +1
  // ```
  @inlinable
  package func _advanced(with stride: Int, count: Int) -> UnsafeMutablePointer {
    _advanced(raw: (MemoryLayout<UnsafeNode>.stride &+ stride) &* count)
  }

  // 型と移動量を指定して、他のノードアドレスを取得する
  //
  // ```
  // ...|Node|PayloadValue|Node|PayloadValue|...
  //    ^--_advanced -1   ^--self           ^--_advanced +1
  // ```
  @inlinable
  package func _advanced<_PayloadValue>(with t: _PayloadValue.Type, count: Int) -> UnsafeMutablePointer {
    let alignment = max(
      MemoryLayout<UnsafeNode>.alignment,
      MemoryLayout<_PayloadValue>.alignment)
    let size = MemoryLayout<UnsafeNode>.stride &+ MemoryLayout<_PayloadValue>.stride
    let stride = (size &+ alignment &- 1) & -alignment
    return _advanced(raw: stride &* count)
  }
}

@inlinable
package func _ref<T>(to a: inout T) -> UnsafeMutablePointer<T> {
  withUnsafeMutablePointer(to: &a) { $0 }
}
