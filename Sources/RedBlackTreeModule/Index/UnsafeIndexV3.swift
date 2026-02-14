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

/// 木のノード識別子
///
/// - Important: 生成元以外の木での使用は未定義。
public typealias UnsafeIndexV3 = _TieWrappedPtr

// 内部実装では CoW 由来の差異を救済することがある。
// その結果として異なる木でも使えてしまう可能性があるが、仕様上は未定義。
// 失敗は許容するが、確保外メモリへのアクセスは厳禁。
//
// ポインタの3層構造（用途の棲み分け）:
// - 生ポインタ: 内部で即完結する処理専用（最速、寿命保証なし）。
// - Sealed     : 時間差で無効化し得る操作に対する安全柵。
// - Tied       : 外部に渡す識別子（メモリ寿命の紐付け）。
