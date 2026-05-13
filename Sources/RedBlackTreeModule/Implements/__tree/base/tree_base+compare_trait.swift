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

public protocol CompareUniqueTrait: _Base_IsMultiTraitInterface {}

extension CompareUniqueTrait {
  @inlinable @inline(__always)
  public static var isMulti: Bool { false }
}

public protocol CompareMultiTrait: _Base_IsMultiTraitInterface {}

extension CompareMultiTrait {
  @inlinable @inline(__always)
  public static var isMulti: Bool { true }
}

// 分岐を減らしたい気持ちはあるが、ホットパスというわけでもないので、無理にはやらない

public protocol TraitHelper: _NodePtrType {
  static func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool
  static func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool
  static func ___ptr_range_comp(_ __f: _NodePtr, _ __p: _NodePtr, _ __l: _NodePtr) -> Bool
}

public protocol UniqueTraitHelper: _Base_TraitHelperInterface
where _TraitHelper == __UniqueTrait<Self> {}
extension UniqueTraitHelper {
  
  @inlinable @inline(__always)
  public static var isMulti: Bool { false }
}

public protocol MultiTraitHelper: _Base_TraitHelperInterface
where _TraitHelper == __MultiTrait<Self> {}
extension MultiTraitHelper {
  
  @inlinable @inline(__always)
  public static var isMulti: Bool { true }
}
