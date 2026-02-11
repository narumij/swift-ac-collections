//
//  UnsafeIndexV3.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/11.
//

// ptrをキャッシュするが、イテレータ部分は消す方針のもの
@frozen
public struct UnsafeIndexV3: _UnsafeNodePtrType {

  @usableFromInline
  internal var tied: _TiedRawBuffer

  @usableFromInline
  internal var sealed: _SealedPtr

  @inlinable @inline(__always)
  internal init(sealed: _SealedPtr, tie: _TiedRawBuffer) {
    self.tied = tie
    self.sealed = sealed
  }
}

extension UnsafeIndexV3 {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public static func === (lhs: Self, rhs: Self) -> Bool {
    lhs.sealed == rhs.sealed
  }
}

extension UnsafeIndexV3: Equatable {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    // _tree比較は、CoWが発生した際に誤判定となり、邪魔となるので、省いている

    // TODO: CoW抑制方針になったので、treeMissmatchが妥当かどうか再検討する

    // TODO: 意味論を再検討

    lhs.tag == rhs.tag
  }
}

// MARK: Index Resolver

extension UnsafeIndexV3 {

  @inlinable
  @inline(__always)
  internal func __purified_(_ index: UnsafeIndexV3) -> _SealedPtr {
    tied === index.tied
      ? index.sealed.purified
      : tied.__retrieve_(index.sealed.purified.tag).purified
  }
}

extension UnsafeIndexV3 {
  @inlinable
  public var isValid: Bool {
    sealed.purified.isValid
  }
}

extension UnsafeIndexV3: CustomStringConvertible {
  public var description: String {
    switch sealed {
    case .success(let t):
      "UnsafeIndexV3<\(t)>"
    case .failure(let e):
      "UnsafeIndexV3<\(e)>"
    }
  }
}

extension UnsafeIndexV3: CustomDebugStringConvertible {
  public var debugDescription: String { description }
}

extension UnsafeIndexV3 {
  @usableFromInline package var value: _TrackingTag? { sealed.tag.value }
  @usableFromInline package var tag: _SealedTag { sealed.tag }
}

extension UnsafeIndexV3 {

//  @inlinable
//  static func sealedTagOrNil(_ t: UnsafeMutablePointer<UnsafeNode>?) -> UnsafeIndexV3? {
////    t.flatMap { .sealOrNil($0) }.map { .success($0) }
//    fatalError()
//  }

//  @inlinable
//  static func sealedTag(_ t: UnsafeMutablePointer<UnsafeNode>) -> UnsafeIndexV3 {
////    .success(.seal(t))
////    fatalError()
//    .init(sealed: t.sealed, tie: <#T##_TiedRawBuffer#>)
//  }
}

#if DEBUG
  extension UnsafeIndexV3 {
    fileprivate init<Base: ___TreeBase>(
      _unsafe_tree: UnsafeTreeV2<Base>, rawValue: _NodePtr, trackingTag: _TrackingTag
    ) {
      self.tied = _unsafe_tree.tied
      self.sealed = rawValue.sealed
    }
  }

  extension UnsafeIndexV3 {

    internal static func unsafe<Base: ___TreeBase>(tree: UnsafeTreeV2<Base>, rawValue: _NodePtr) -> Self {
      .init(_unsafe_tree: tree, rawValue: rawValue, trackingTag: rawValue.pointee.___tracking_tag)
    }

    internal static func unsafe<Base: ___TreeBase>(tree: UnsafeTreeV2<Base>, rawTag: _TrackingTag) -> Self {
      if rawTag == .nullptr {
        return .init(_unsafe_tree: tree, rawValue: tree.nullptr, trackingTag: .nullptr)
      }
      if rawTag == .end {
        return .init(_unsafe_tree: tree, rawValue: tree.end, trackingTag: .end)
      }
      return .init(
        _unsafe_tree: tree,
        rawValue: tree._buffer.header[rawTag],
        trackingTag: tree._buffer.header[rawTag].pointee.___tracking_tag)
    }
  }
#endif
