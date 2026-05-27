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

@usableFromInline
protocol _SequenceV2: UnsafeTreeHostV2, _PayloadValueBride, _KeyBride {}

extension _SequenceV2 {

  @inlinable
  package var _start: _NodePtr {
    __tree_.__begin_node_
  }

  @inlinable
  package var _end: _NodePtr {
    __tree_.__end_node
  }
  
  @inlinable
  package var _safe_start: _SafePtr {
    .success(__tree_.__begin_node_)
  }

  @inlinable
  package var _safe_end: _SafePtr {
    .success(__tree_.__end_node)
  }

  @inlinable
  package var _sealed_start: _SealedPtr {
    __tree_.__begin_node_.uncheckedSeal
  }

  @inlinable
  package var _sealed_end: _SealedPtr {
    __tree_.__end_node.uncheckedSeal
  }
  
  @inlinable
  var ___sealed_range: _RawRange<_SealedPtr> {
    .init(lowerBound: _sealed_start, upperBound: _sealed_end)
  }
}
