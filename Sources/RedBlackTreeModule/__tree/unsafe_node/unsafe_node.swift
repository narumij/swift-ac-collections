//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

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
@frozen
public struct UnsafeNode {

  public typealias Pointer = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  public init(
    ___tracking_tag: _TrackingTag,
    __left_: Pointer,
    __right_: Pointer,
    __parent_: Pointer,
    __is_black_: Bool = false,
    ___has_payload_content: Bool = true
  ) {
    self.___tracking_tag = ___tracking_tag
    self.__left_ = __left_
    self.__right_ = __right_
    self.__parent_ = __parent_
    self.__is_black_ = __is_black_
    self.___has_payload_content = ___has_payload_content
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
  /// Color flag of this red-black tree node.
  ///
  /// `true` indicates black, `false` indicates red.
  ///
  /// ---
  ///
  /// 赤黒木ノードの色を表すフラグ。
  /// `true` の場合は黒、`false` の場合は赤。
  public var __is_black_: Bool = false

  /// Indicates whether the payload stored after this node is currently loaded.
  ///
  /// When `true`, the associated payload memory is initialized and must be
  /// deinitialized before reuse.
  /// When `false`, the node is considered free / recycled.
  ///
  /// ---
  ///
  /// ノード直後に配置されたペイロードが有効（ロード済み）かどうかを示すフラグ。
  ///
  /// `true` の場合、ペイロードは初期化済みで解放対象となる。
  /// `false` の場合、ペイロードは未使用または回収済み。
  ///
  public var ___has_payload_content: Bool

  // IndexアクセスでCoWが発生した場合のフォローバックとなる
  // TODO: 不変性が維持されているか考慮すること
  /// A lightweight tracking tag used to identify and correlate nodes.
  ///
  /// This tag is **not** part of the tree's logical key and must not be used
  /// for ordering or lookup semantics.
  ///
  /// Primary purposes:
  /// - Tracking node identity across Copy-on-Write (CoW) operations
  /// - Distinguishing sentinel nodes (e.g. nullptr, end, debug)
  /// - Supporting debugging, diagnostics, and structural verification
  ///
  /// Special values:
  /// - `nullptr` uses `-2`
  /// - `end` uses `-1`
  ///
  /// ---
  ///
  /// ノードを追跡・識別するための軽量タグ。
  ///
  /// この値は木の論理キーではなく、
  /// 順序付けや検索には使用してはならない。
  ///
  /// 主な用途:
  /// - Copy-on-Write (CoW) 時のノード同一性の維持
  /// - nullptr / end / debug などの特殊ノードの識別
  /// - デバッグ・診断・構造検証の補助
  ///
  /// 特殊値:
  /// - `nullptr` は `-2`
  /// - `end` は `-1`
  public var ___tracking_tag: _TrackingTag

  // メモリ管理をちゃんとするために隙間にねじ込んだ
  // TODO: メモリ管理に整合性があるか考慮すること
  #if DEBUG
    public var ___recycle_count: Int = 0
  #endif

  // non optionalを選択したのは、コードのあちこちにチェックコードが自動で挟まって遅くなることを懸念しての措置
  // nullptrは定数でもなにかコストがかかっていた記憶もある
  // 過去のコードベースで再度調査してこういった諸々の問題が杞憂だった場合、optionalに変更してnullptrにnil変更しても良い
  @usableFromInline nonisolated(unsafe)
    package static let nullptr: UnsafeMutablePointer<UnsafeNode> = _singletonNull.nullptr
}

@usableFromInline
nonisolated(unsafe) let _singletonNull: UnsafeNode.Null = .create()

extension UnsafeNode {

  /// 再利用プールに改修されている状態
  ///
  /// 初期化前のメモリの状態は不明だが、利用開始時に該当フラグがtrueとなり利用中を表す。
  ///
  /// その後回収されるとこのフラグはfalseとなり、notは回収されている状態を表す。
  ///
  /// あくまでそのように使えるというだけで全てのメモリ状態に対して完全に回収されている状態を表すわけではない。
  ///
  /// `___needs_deinitialize`を回収以外の目的で利用してる箇所の意図をハッキリさせるために別名を付与したカタチ。
  @inlinable
  @inline(__always)
  var isGarbaged: Bool {
    !___has_payload_content
  }
}

extension UnsafeNode {

  @usableFromInline
  final class Null: ManagedBuffer<Int, UnsafeNode> {
    @nonobjc
    @inlinable
    @inline(__always)
    var nullptr: UnsafeMutablePointer<UnsafeNode> {
      withUnsafeMutablePointerToElements { $0 }
    }
    @inlinable
    deinit {
      _ = withUnsafeMutablePointers { header, elements in
        elements.deinitialize(count: header.pointee)
      }
    }
    @nonobjc
    @inlinable
    @inline(__always)
    internal static func create() -> Null {
      let storage = Null.create(minimumCapacity: 1) { $0.capacity }
      storage.withUnsafeMutablePointerToElements { nullptr in
        nullptr.initialize(to: .create(tag: .nullptr, nullptr: nullptr))
      }
      return unsafeDowncast(storage, to: Null.self)
    }
  }
}

extension UnsafeNode {

  @inlinable
  @inline(__always)
  package static func create(tag: Int, nullptr: UnsafeMutablePointer<UnsafeNode>) -> UnsafeNode {
    .init(
      ___tracking_tag: tag,
      __left_: nullptr,
      __right_: nullptr,
      __parent_: nullptr)
  }
}

extension UnsafeNode: Equatable {}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  @inlinable
  @inline(__always)
  var trackingTag: _TrackingTag {
    pointee.___tracking_tag
  }
}
