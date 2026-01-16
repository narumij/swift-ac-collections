// Copyright 2024-2026 narumij
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
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

/// Swift 6.2 2026/01/11時点で赤黒木の性能の肝of肝となる部分
///
/// 何がもんだいなのかというと、Comparableの比較演算が特殊化されきらず動的ディスパッチがかすかに残ること
/// 設計をあれこれ組み替えて試してもどこかに必ず型判定が入り込んだり、ディスパッチが紛れてくる
/// 比較演算での動的ディスパッチは致命的すぎてつらい。
///
/// で、試しに強制変換を試したらインライン化された場合にとても良好だったので採用しました。
/// 本質的にダイナミックキャストを含むのでインライン化されないと素の状態より性能が悪化します。
///
/// しばらくこれで試してみます。
@frozen
@usableFromInline
enum SpecializeMode {
  case asInt
  case generic

  @inlinable
  @inline(__always)
  func value_comp<_Key: Comparable>(_ __l: _Key, _ __r: _Key) -> Bool {
    switch self {
    case .asInt:
      return (__l as! Int) < (__r as! Int)
    case .generic:
      return __l < __r
    }
  }

  @inlinable
  @inline(__always)
  func value_equiv<_Key: Equatable>(_ __l: _Key, _ __r: _Key) -> Bool {
    switch self {
    case .asInt:
      return (__l as! Int) == (__r as! Int)
    case .generic:
      return __l == __r
    }
  }

  #if true
    @inlinable
    @inline(__always)
    func synth_three_way<_Key: Comparable>(_ __l: _Key, _ __r: _Key) -> __int_compare_result {
      __default_three_way_comparator(__l, __r)

      /*
       Swift 6.2.3で以下のようにコンパイルされ、これは理想的なので変な特殊化をしないことにした
       (ストア済みだからいいんだろうけど、cmp二個なのがあとで気になってきた)
      
       ; specialized __default_three_way_comparator<A>(_:_:)
       +0x00  cmp                 x1, x0
       +0x04  cset                w8, lt
       +0x08  cmp                 x0, x1
       +0x0c  csinv               x0, x8, xzr, ge
       +0x10  ret
       */
    }
  #else
    @inlinable
    @inline(__always)
    func synth_three_way<_Key: Comparable>(_ __l: _Key, _ __r: _Key) -> ___enum_compare_result {
      ___default_three_way_comparator(__l, __r)
    }
  #endif
}

// TODO: 名前てきとうすぎたので直すこと
@frozen
@usableFromInline
struct SpecializeModeHoge<_K> {
  @inlinable
  @inline(__always)
  init() {
    if _K.self == Int.self {
      specializeMode = .asInt
    } else {
      specializeMode = .generic
    }
  }
  @usableFromInline
  var specializeMode: SpecializeMode
}
