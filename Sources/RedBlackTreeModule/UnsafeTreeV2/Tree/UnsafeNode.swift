// Copyright 2024-2026 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

/// A red-black tree node designed for use in raw (unsafe) memory.
///
///  ### UnsafeNode Binary Layout Assumptions
///
///  This type is designed to be embedded in a low-level allocator with the
///  following binary memory layout per element:
///
///    | padding | UnsafeNode | Value |
///
///  Layout assumptions:
///
///  1. Padding before the node
///     - Padding may exist *before* this `UnsafeNode` instance.
///     - The padding is used to satisfy the alignment requirements of `Value`.
///     - `UnsafeNode` itself does NOT account for this padding.
///
///  2. Node position
///     - `UnsafeNode` is placed at an address such that the memory immediately
///       following it is correctly aligned for `Value`.
///     - This invariant is enforced by the allocator, not by `UnsafeNode`.
///
///  3. Value position (external invariant)
///     - The associated `Value` is stored immediately after this node.
///     - Given a pointer `p: UnsafeMutablePointer<UnsafeNode>`,
///       the corresponding value is located at:
///
///           p.advanced(by: 1)
///
///  4. Responsibility boundary
///     - `UnsafeNode` assumes the above layout invariant is already satisfied.
///     - It performs no alignment checks and no pointer arithmetic by itself.
///     - Breaking this invariant results in undefined behavior.
///
///  5. Memory management flag
///     - `___needs_deinitialize` indicates whether the associated `Value`
///       requires deinitialization.
///     - This flag is managed by higher-level allocators / pools.
///
///  ⚠️ IMPORTANT:
///     - Do NOT change the size or field order of `UnsafeNode`
///       without updating the allocator that enforces this layout.
///
/// ---
///
/// 生メモリ上で使用する赤黒木ノード。
///
/// ※ 開発者注: 「生メモリ」は研ナオコの「ナマタマゴ」と同じ発音。
///
/// ### UnsafeNode のバイナリレイアウト前提
///
/// この型は、低レベルアロケータに埋め込まれることを前提として設計されており、
/// 各要素は以下のバイナリメモリレイアウトを持つ。
///
///   | padding | UnsafeNode | Value |
///
/// レイアウトに関する前提条件:
///
/// 1. ノード前のパディング
///    - この `UnsafeNode` インスタンスの *直前* にパディングが存在する場合がある。
///    - このパディングは `Value` のアライメント要件を満たすためのものである。
///    - `UnsafeNode` 自身は、このパディングを一切考慮しない。
///
/// 2. ノードの配置位置
///    - `UnsafeNode` は、その直後のメモリが `Value` に対して
///      正しくアラインされる位置に配置される。
///    - この不変条件は `UnsafeNode` ではなく、アロケータによって保証される。
///
/// 3. Value の配置位置（外部不変条件）
///    - 対応する `Value` は、このノードの直後に連続して格納される。
///    - `p: UnsafeMutablePointer<UnsafeNode>` が与えられた場合、
///      対応する `Value` は次の位置に存在する:
///
///          p.advanced(by: 1)
///
/// 4. 責務の境界
///    - `UnsafeNode` は、上記のレイアウト不変条件がすでに満たされていることを前提とする。
///    - アライメントチェックやポインタ演算は一切行わない。
///    - この不変条件が破られた場合の挙動は未定義である。
///
/// 5. メモリ管理フラグ
///    - `___needs_deinitialize` は、対応する `Value` が
///      deinitialize を必要とするかどうかを示す。
///    - このフラグは、より上位のアロケータ／プールによって管理される。
///
/// ⚠️ 重要:
///    - このレイアウトを保証しているアロケータを更新せずに、
///      `UnsafeNode` のサイズやフィールド順序を変更してはならない。
///
public struct UnsafeNode {

  public typealias Pointer = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  public init(
    ___node_id_: Int,
    _nullpotr: Pointer
  ) {
    self.init(
      ___node_id_: ___node_id_,
      __left_: _nullpotr,
      __right_: _nullpotr,
      __parent_: _nullpotr)
  }

  @inlinable
  @inline(__always)
  public init(
    ___node_id_: Int,
    __left_: Pointer,
    __right_: Pointer,
    __parent_: Pointer,
    __is_black_: Bool = false
  ) {
    self.___node_id_ = ___node_id_
    self.__left_ = __left_
    self.__right_ = __right_
    self.__parent_ = __parent_
    self.__is_black_ = __is_black_
    self.___needs_deinitialize = true
  }

  /// Left child pointer of this red-black tree node.
  ///
  /// ---
  ///
  /// 赤黒木ノードの左の子ノードを指すポインタ。
  public var __left_: Pointer

  /// Right child pointer of this red-black tree node.
  ///
  /// ---
  ///
  /// 赤黒木ノードの右の子ノードを指すポインタ。
  public var __right_: Pointer

  /// Parent pointer of this red-black tree node.
  ///
  /// ---
  ///
  /// 赤黒木ノードの親ノードを指すポインタ。
  public var __parent_: Pointer
  // IndexアクセスでCoWが発生した場合のフォローバックとなる
  // TODO: 不変性が維持されているか考慮すること
  /// A temporary node identifier assigned in initialization order.
  ///
  /// Used during CoW reconstruction to preserve tree structural identity.
  /// Intended for use during copy operations only.
  /// After CoW splits tree instances, this ID allows equivalent nodes
  /// to be associated across the copies.
  ///
  /// ---
  ///
  /// ノードが初期化された順に付与される一時的な識別子
  ///
  /// CoW 再構築時に木構造の同一性を維持するために使用される。
  /// 通常はコピー処理中にのみ参照される。
  /// CoW により木のインスタンスが分離した後でも、
  /// この ID を用いて等価なノード同士を対応付けることができる。
  ///
  /// nullptrは-2、endは-1をIDにもつ
  public var ___node_id_: Int
  /// Color flag of this red-black tree node.
  ///
  /// `true` indicates black, `false` indicates red.
  ///
  /// ---
  ///
  /// 赤黒木ノードの色を表すフラグ。
  /// `true` の場合は黒、`false` の場合は赤。
  public var __is_black_: Bool = false

  /// Indicates whether the associated value requires deinitialization.
  ///
  /// This flag is used by low-level allocators / pools to determine
  /// whether the value stored after this node should be deinitialized.
  ///
  /// ---
  ///
  /// 値の解放（deinitialize）が必要かどうかを示すフラグ。
  /// ノード直後に配置された値を解放すべきかを判断するために、
  /// 低レベルのアロケータ／プールで使用される。
  public var ___needs_deinitialize: Bool
  // メモリ管理をちゃんとするために隙間にねじ込んだ
  // TODO: メモリ管理に整合性があるか考慮すること
  #if DEBUG
    public var ___recycle_count: Int = 0
  #endif
}

extension UnsafeNode {

  @inlinable
  @inline(__always)
  static func valuePointer<_Value>(_ pointer: UnsafeMutablePointer<Self>?) -> UnsafeMutablePointer<
    _Value
  >? {
    guard let pointer else { return nil }
    return UnsafeMutableRawPointer(pointer.advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
  }

  @inlinable
  @inline(__always)
  static func valuePointer<_Value>(_ pointer: UnsafeMutablePointer<Self>) -> UnsafeMutablePointer<
    _Value
  > {
    UnsafeMutableRawPointer(pointer.advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
  }

  @inlinable
  @inline(__always)
  static func value<_Value>(_ pointer: UnsafeMutablePointer<Self>) -> _Value {
    UnsafeMutableRawPointer(pointer.advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
      .pointee
  }
}

extension UnsafeNode {

  @inlinable
  @inline(__always)
  static func initializeValue<_Value>(_ p: UnsafeMutablePointer<UnsafeNode>, to: _Value) {
    p.advanced(by: 1)
      .withMemoryRebound(to: _Value.self, capacity: 1) { pointer in
        pointer.initialize(to: to)
      }
  }

  @inlinable
  @inline(__always)
  static func deinitialize<_Value>(_ t: _Value.Type, _ p: UnsafeMutablePointer<UnsafeNode>) {
    if p.pointee.___needs_deinitialize {
      UnsafeMutableRawPointer(p.advanced(by: 1))
        .alignedUp(for: _Value.self)
        .assumingMemoryBound(to: _Value.self)
        .deinitialize(count: 1)
    }
    p.deinitialize(count: 1)
  }
}

extension UnsafeNode {

  fileprivate final class Null {
    fileprivate let pointer: UnsafeMutablePointer<UnsafeNode>
    fileprivate init() {
      let raw = UnsafeMutableRawPointer.allocate(
        byteCount: MemoryLayout<UnsafeNode>.stride,
        alignment: MemoryLayout<UnsafeNode>.alignment)
      pointer = raw.assumingMemoryBound(to: UnsafeNode.self)
      pointer.initialize(to: .init(___node_id_: .nullptr, _nullpotr: pointer))
    }
    deinit {
      pointer.deinitialize(count: 1)
      pointer.deallocate()
    }
  }
}

fileprivate
nonisolated(unsafe) let shared: UnsafeNode.Null = .init()

/// `__swift_instantiateConcreteTypeFromMangledNameV2`を避けるためには、
/// 直接利用せずに、一度内部に保持する必要がある
@usableFromInline
nonisolated(unsafe) let ___slow_shared_unsafe_null_pointer: UnsafeMutablePointer<UnsafeNode> = shared.pointer
