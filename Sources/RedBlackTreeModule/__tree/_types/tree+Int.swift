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

/// 赤黒木の内部Index
///
/// (説明が古いので注意)
/// (現在はCoW時のノード解決や特殊ポインタ判定簡略の為に使っている)
///
/// ヒープの代わりに配列を使っているため、実際には内部配列のインデックスを使用している
///
/// インデックスが0からはじまるため、一般的にnullは0で表現するところを、-2で表現している
///
/// endはルートノードを保持するオブジェクトを指すかわりに、-1で表現している
///
/// llvmの`__tree`ではポインタとイテレータが使われているが、イテレータはこのインデックスで代替している
public typealias _PointerIndex = Int

extension _PointerIndex {

  /// 赤黒木のIndexで、nullを表す
  @inlinable
  package static var nullptr: Self {
    -2
  }

  /// 赤黒木のIndexで、終端を表す
  @inlinable
  package static var end: Self {
    -1
  }

  @inlinable
  package static var debug: Self {
    -999
  }

  /// 数値を直接扱うことを避けるための初期化メソッド
  @available(*, deprecated, message: "_NodePtrがIntからポインタに移行したので、概ね不要になったため")
  @inlinable
  @inline(__always)
  package static func node(_ p: Int) -> Self { p }
}

/// pointer indexでのsentinel判定関数
@inlinable
@inline(__always)
package func ___is_null_or_end(_ ptr: _PointerIndex) -> Bool {
  ptr < 0
}
