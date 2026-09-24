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

/// 木のノード識別子
///
/// - Important: 生成元以外の木での使用は未定義。
//public typealias UnsafeIndexV3 = _LazyTieWrappedPtr

public typealias UnsafeIndexV3 = _LazyTiedPtr

// 内部実装では CoW 由来の差異を救済することがある。
// その結果として異なる木でも使えてしまう可能性があるが、仕様上は未定義。
// 失敗は許容するが、確保外メモリへのアクセスは厳禁。
//
// ポインタの3層構造（用途の棲み分け）:
// - 生ポインタ: 内部で即完結する処理専用（最速、寿命保証なし）。
// - Sealed     : 時間差で無効化し得る操作に対する安全柵。
// - Tied       : 外部に渡す識別子（メモリ寿命の紐付け）。

// ~EscapableなIndexにしたいと考えていたが、以下でIndexはCopyable & Escapableと縛られてしまったので、断念
// ただ、~Escapableが欲しかったのはバッファ寿命管理コストを下げたかったことが理由だが、
// 今はその点に関して気にならないコストとなっているので、Copyable & Escapableで問題が無い
// https://github.com/apple/swift-collections/blob/main/Documentation/Container-design.md


// Index は container 内の論理的位置を表す。endIndex も有効な Index で、最後の要素の直後の空位置を表す。
// ○

// Index は Copyable / Escapable な soft reference。container の mutation によって stale になってよい。つまり mutation 後も Index 自体の値は存在できる。
// ○

// その代わり、Index を dereference するときには、その Index がその container の有効な位置を表していることを安全かつ高速に検証できなければならない。さらに、検証後は Index 内の情報から正しい storage element を効率よく特定できる必要がある。
// ○

// Index は Equatable / Comparable / Hashable を要求し、それらの比較・hash は O(1) としている。
// ×

