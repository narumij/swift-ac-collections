//
//  _Deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//


#if COMPATIBLE_ATCODER_2025
@usableFromInline
protocol ___UnsafeIndexRangeBaseV2:
  UnsafeTreeRangeBaseInterfaceV2
    & UnsafeIndexProviderProtocolV2
{}
#endif

#if COMPATIBLE_ATCODER_2025
  public typealias RedBlackTreeIndex = UnsafeIndexV2
  public typealias RedBlackTreeIndices = UnsafeIndexV2Collection
  public typealias RedBlackTreeIterator = RedBlackTreeIteratorV2
  public typealias RedBlackTreeSlice = RedBlackTreeSliceV2
#endif

#if COMPATIBLE_ATCODER_2025
  @usableFromInline
  protocol _RedBlackTreeKeyOnlyBase:
    UnsafeIndexProtocol_tree
      & UnsafeIndicesProtoocl
      & UnsafeTreeRangeBaseInterfaceV2
      & _SetBridge
      & _CompareV2
      & _SequenceV2
      & _RemoveV2
      & ___RemoveV2
      & ___UnsafeIndexV2
      & ___UnsafeKeyOnlySequenceV2
  {}

  @usableFromInline
  protocol _RedBlackTreeKeyValuesBase:
    UnsafeIndexProtocol_tree
      & UnsafeIndicesProtoocl
      & _MapBridge
      & _CompareV2
      & _SequenceV2
      & _RemoveV2
      & ___RemoveV2
      & ___UnsafeIndexV2
      & ___UnsafeKeyValueSequenceV2
      & _PaylodElementBridge
  {}
#endif
