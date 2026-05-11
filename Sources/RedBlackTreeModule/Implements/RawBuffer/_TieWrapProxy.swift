//
//  _TieWrapProxy.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/11.
//

/// 結束バンド
@frozen
public struct _TieWrapProxy<RawValue> {

  @usableFromInline
  package let rawValue: RawValue

  @usableFromInline
  package let tied: _TiedRawBufferProxy?

  @inlinable @inline(__always)
  package init(rawValue: RawValue, tie: _TiedRawBufferProxy?) {
    self.rawValue = rawValue
    self.tied = tie
  }
}

extension _TieWrapProxy {
  public func map<U>(_ transform: (RawValue) throws -> U) rethrows -> _TieWrapProxy<U> {
    .init(rawValue: try transform(rawValue), tie: tied)
  }
}

extension _TieWrapProxy: Equatable where RawValue: Equatable {

  public static func == (lhs: _TieWrapProxy<RawValue>, rhs: _TieWrapProxy<RawValue>) -> Bool {
    lhs.rawValue == rhs.rawValue && lhs.tied === rhs.tied
  }
}

extension _TieWrapProxy where RawValue == _NodePtrSealing {

  @inlinable @inline(__always)
  package var purified: Result<Self, SealError> {
    rawValue.isUnsealed ? .failure(.unsealed) : .success(self)
  }
}

extension _NodePtrSealing {

  // 某バンドオマージュ

  @inlinable
  package func band(_ tie: _TiedRawBufferProxy?) -> _TieWrappedProxyPtr {
    isUnsealed ? .failure(.unsealed) : .success(.init(rawValue: self, tie: tie))
  }
}

extension Result where Success == _NodePtrSealing, Failure == SealError {

  // 某バンドオマージュ

  @inlinable
  package func band(_ tie: _TiedRawBufferProxy?) -> _TieWrappedProxyPtr {
    flatMap { $0.band(tie) }
  }
}

extension Result where Success == _TieWrapProxy<_NodePtrSealing>, Failure == SealError {

  @inlinable
  package var tied: _TiedRawBufferProxy? {
    try? map(\.tied).get()
  }
}

// MARK: -

/// 外部に出す場合、あるいは木が常に一致するとは限らない場合に使うポインタ
///
/// `_TieWrappedPtr`は`_SealedPtr`にメモリ寿命を付与したもの
///
/// `_NodePtr`は内部用の最速
///
/// `_SealedPtr`は外部での変更リスクがある場合に使う
///
public typealias _TieWrappedProxyPtr = Result<_TieWrapProxy<_NodePtrSealing>, SealError>

extension Result where Success == _TieWrapProxy<_NodePtrSealing>, Failure == SealError {

  /// ポインタを利用する際に用いる
  @inlinable
  package var purified: Result { flatMap { $0.purified } }

  @usableFromInline
  package var isValid: Bool {
    switch purified {
    case .success: true
    default: false
    }
  }

  @inlinable @inline(__always)
  package var sealed: _SealedPtr {
    map(\.rawValue)
  }
}

extension Result where Success == _TieWrapProxy<_NodePtrSealing>, Failure == SealError {

  @usableFromInline
  package var value: _TrackingTag {
    (try? map(\.rawValue.pointer.trackingTag).get()) ?? .nullptr
  }
}

#if DEBUG
  extension Result where Success == _TieWrapProxy<_NodePtrSealing>, Failure == SealError {

    package static func unsafe<Base: ___TreeBase>(tree: UnsafeTreeV2<Base>, rawTag: _TrackingTag)
      -> Self
    {
      if rawTag == .nullptr {
        return .failure(.null)
      }

      return tree.__retrieve_(rawTag)
        .flatMap(\.sealed)
        .flatMap { $0.band(tree.tiedProxy) }
    }
  }
#endif
