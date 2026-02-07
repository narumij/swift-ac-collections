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

public protocol _PairBaseRawValue_KeyProtocol: _PairBaseType & _BasePayload_KeyInterface {}

extension _PairBaseRawValue_KeyProtocol {

  @inlinable
  @inline(__always)
  public static func __key(_ __v: _PayloadValue) -> _Key { __v.key }
}

public protocol _PairBaseRawValue_MappedValueProtocol: _PairBaseType
    & _BasePayload_MappedValueInterface
{}

extension _PairBaseRawValue_MappedValueProtocol {

  @inlinable
  @inline(__always)
  public static func ___mapped_value(_ __v: _PayloadValue) -> _MappedValue { __v.value }
}

public protocol _BasePairRawValue_WithMappedValueProtocol: _PairBaseType & WithMappedValueInterface {}

extension _BasePairRawValue_WithMappedValueProtocol {

  @inlinable
  @inline(__always)
  public static func ___with_mapped_value<ResultType>(
    _ __v: inout _PayloadValue,
    _ __body: (inout _MappedValue) throws -> ResultType
  ) rethrows -> ResultType {
    try __body(&__v.value)
  }
}
