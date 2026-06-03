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

public protocol _PairBasePayloadValue_KeyProtocol:
  _PairBaseType
    & _BasePayloadValue_KeyInterface
{}

extension _PairBasePayloadValue_KeyProtocol {

  @inlinable
  public static func __key(_ __v: _PayloadValue) -> _Key { __v.tuple.key }
}

public protocol _PairBasePayloadValue_MappedValueProtocol:
  _PairBaseType
    & _BasePayloadValue_MappedValueInterface
{}

extension _PairBasePayloadValue_MappedValueProtocol {

  @inlinable
  public static func ___mapped_value(_ __v: _PayloadValue) -> _MappedValue { __v.tuple.value }
}
