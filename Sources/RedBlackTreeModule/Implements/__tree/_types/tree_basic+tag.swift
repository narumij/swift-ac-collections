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

/// 赤黒木ノードに付与される追跡用タグ
///
/// ノードを補助的に識別・追跡するためのID。
/// 主に以下の用途で使用される:
///
/// - CoW（Copy-on-Write）時のノード対応付け
/// - 特殊ノード（nullptr / end）の簡易判定
/// - デバッグおよび構造検証時の識別
///
/// ### 設計意図
///
/// 元々はポインタやメモリを配列で代替するカタチで導入したが、
/// 現在は **ノードの追跡タグ（tracking tag）** としての役割が主となっている。
///
/// 配列のインデックスが0からはじまることに由来してnullが0に割り当てられていない
/// 配列的な走査はコピー処理などでいまだにのこり、処理が簡略できる都合、今後もnullは0以外となる。
///
/// ### 特殊値
///
/// - `-2` : nullptr（ヌルノード）
/// - `-1` : end（終端ノード）
/// - `-999` : デバッグ用途のダミー値
///
public typealias _TrackingTag = Int


extension _TrackingTag {

  /// 赤黒木の`_TrackingTag`で、nullを表す
  @inlinable
  package static var nullptr: Self {
    -2
  }

  /// 赤黒木の`_TrackingTag`で、終端を表す
  @inlinable
  package static var end: Self {
    -1
  }

  /// メモリでバッグのための`_TrackingTag`のダミー値
  @inlinable
  package static var debug: Self {
    -999
  }
}

/// 追跡タグが nullptr または end を表すかを判定する
///
/// `_TrackingTag` は負数を特殊ノード識別に使用しているため、
/// `0` 以上は通常ノード、`0` 未満は sentinel として扱われる。
@inlinable
@inline(__always)
package func ___is_null_or_end(_ ptr: _TrackingTag) -> Bool {
  ptr < 0
}
