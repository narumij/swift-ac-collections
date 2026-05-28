//
//  UnsafeIterator+Protocol+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/29.
//

#if COMPATIBLE_ATCODER_2025
  public protocol UnsafeIteratorProtocol: _UnsafeNodePtrType, IteratorProtocol {
    init(_start: _SealedPtr, _end: _SealedPtr)
    var _sealed_start: _SealedPtr { get }
    var _sealed_end: _SealedPtr { get }
  }

  public protocol UnsafeAssosiatedIterator: _UnsafeNodePtrType, IteratorProtocol {
    associatedtype Base: ___TreeBase
    associatedtype Source: IteratorProtocol & Sequence
    init(_ t: Base.Type, _start: _SealedPtr, _end: _SealedPtr)
    var _source: Source { get }
    var _sealed_start: _SealedPtr { get }
    var _sealed_end: _SealedPtr { get }
  }
#endif
