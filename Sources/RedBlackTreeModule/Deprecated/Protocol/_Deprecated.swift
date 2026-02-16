//
//  _Deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

@usableFromInline
protocol _RedBlackTreeKeyOnlyBase:
  UnsafeIndexProtocol_tree
    & UnsafeIndicesProtoocl
    & UnsafeTreeRangeBaseInterface
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
{}
