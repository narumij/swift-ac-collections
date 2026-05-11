//
//  _TiedRawBufferProxy.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/11.
//

// TODO: implement this
@usableFromInline
final package class _TiedRawBufferProxy {

  @usableFromInline
  init() {}

  @usableFromInline
  var buffer: _TiedRawBuffer? {
    didSet {
      buffer?.isValueAccessAllowed = false
    }
  }
  @nonobjc
  @inlinable
  @inline(__always)
  var isValueAccessAllowed: Bool {
    get { buffer?.isValueAccessAllowed ?? false }
    set { buffer?.isValueAccessAllowed = newValue }
  }
  deinit {
    buffer = nil
  }
}

/// The type-punned empty singleton storage instance.
@exclusivity(unchecked)
@usableFromInline
nonisolated(unsafe) package let _emptyProxy = _TiedRawBufferProxy()
