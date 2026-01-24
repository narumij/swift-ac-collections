// Copyright 2024-2025 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

// TODO: プロトコルインジェクションを整理すること
// __treenの基本要素ではないので、別カテゴリがいい

public protocol ScalarValueKeyProtocol: _ScalarValueType & _BaseValue_KeyInterface {}

extension ScalarValueKeyProtocol {

  @inlinable
  @inline(__always)
  public static func __key(_ __v: _RawValue) -> _Key { __v }
}

// MARK: -

/// 要素とキーが一致する場合のひな形
public protocol ScalarValueComparer:
  ScalarValueKeyProtocol
    & ValueComparer
    & HasDefaultThreeWayComparator
{}

extension ScalarValueComparer {}
