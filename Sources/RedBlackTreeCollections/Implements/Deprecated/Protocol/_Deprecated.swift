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

#if COMPATIBLE_ATCODER_2025
  @usableFromInline
  protocol ___UnsafeIndexRangeBaseV2:
    UnsafeTreeRangeBaseInterfaceV2
      & UnsafeIndexProviderProtocolV2
  {}

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
      & _PaylodValueBridge_Element
  {}
#endif
