<!-- Codex/Claude作業メモ -->

# `.strictMemorySafety()` 採用レディネス調査 (CLAUDE_TASK.md Task 1)

`.strictMemorySafety()`を各ターゲットへ**一時的に**適用し、診断を収集した調査結果。
**production codeの変更はなく、`Package.swift`は調査後に元の状態へ復元済み**
(`git diff Package.swift`はクリーン)。

## 1. 設定の確認

- `static func strictMemorySafety(_ condition: BuildSettingCondition? = nil) -> SwiftSetting`
  はPackageDescription 6.2以降で利用可能(Apple Developer Documentationで確認)。
- 本パッケージの`swift-tools-version: 6.2`はこれを満たす。
- ツールチェーン: `swift-driver version: 1.168.6 Apple Swift version 6.4
  (swiftlang-6.4.0.34.1 clang-2100.3.34.1)` / `arm64-apple-macosx27.0.0`。
- `Package.swift`の`RedBlackTreeCollections`ターゲットには
  `// .strictMemorySafety()`というコメントアウト済みプレースホルダーが既に存在
  していた(数ヶ月前のコミットから存在、未適用のまま)。

## 2. 手順と検証コマンド

1. `RedBlackTreeCollections`へ最初に適用し、単体ビルド(`swift build --target
   RedBlackTreeCollections`)で診断を収集。
2. 続いて`AcCollections`、`RedBlackTreeModule`(`Sources/_RedBlackTreeModule`の
   facade)、`OptionalArrayModule`、`BareArrayModule`、`PermutationModule`の
   各ターゲットにも追加し、`swift build`でパッケージ全体をビルド。
3. 診断をターゲット・ファイル・カテゴリ別に集計。
4. `git checkout -- Package.swift`で復元し、`git diff Package.swift`が空である
   ことを確認。

テストターゲット(`*Tests`)へは適用していない(本番コードのみ対象)。

## 3. 結果: ターゲット別診断件数

| ターゲット | 警告件数 | エラー件数 | 備考 |
| --- | --- | --- | --- |
| `AcCollections`(facade) | **0** | 0 | `@_exported import`のみで構成。即時適用可能 |
| `RedBlackTreeModule`(`_RedBlackTreeModule`互換shim) | **0** | 0 | 即時適用可能 |
| `PermutationModule` | 34 | 0 | 全件`Permutations.swift`、`ManagedBuffer`ベースの手動メモリ実装由来 |
| `BareArrayModule` | 116 | 0 | 手動メモリ管理モジュール(名称の通り低レベルポインタ操作が本体) |
| `OptionalArrayModule` | 144 | 0 | 同上 |
| `RedBlackTreeCollections` | 4,948 | 0 | 赤黒木の生ポインタ実装本体。最大のターゲット |

全ターゲットでエラーは0件(ビルドは全て成功)。警告のみ。

## 4. 診断カテゴリの分類

`RedBlackTreeCollections`の4,948件の内訳(カテゴリ別、上位):

| カテゴリ | 件数 |
| --- | --- |
| `expression uses unsafe constructs but is not marked with 'unsafe'` | 9,548(1警告が複数行のnoteを伴うため警告行数と一致しない。実警告数は上表の集計値) |
| `conformance of 'UnsafeIterator...' to protocol '_NodePtrType' involves unsafe code` | 124 |
| その他`conformance of '...'`系(View/Tree型の`_NodePtrType`適合) | 約100 |
| `struct '...' has storage involving unsafe types`(`UnsafeNode`/`Header`/`Template`/`Null`等) | 約20 |

ディレクトリ別では`Implements/UnsafeTreeV2`(1,178件)と`Implements/__tree/unsafe_tree`
(1,046件)が最多で、赤黒木の生ポインタ実装(`UnsafeMutablePointer<UnsafeNode>`を
直接保持・比較・演算する層)に集中している。これは意図された低レベル実装であり、
`Design-MemorySafety.md`で既に文書化されている設計上の判断である。

## 5. 診断の分離: 意図的な低レベル実装 vs 機械的に直せるもの

- **意図的な低レベル実装由来(修正しない)**: `RedBlackTreeCollections`の
  `Implements/UnsafeTreeV2`、`Implements/__tree/unsafe_node`、
  `Implements/__tree/unsafe_tree`、`Implements/RawBuffer`配下。生ポインタの
  直接比較・加算・ストレージ保持が本質的な実装手段であり、`@unsafe`注釈を
  機械的に付けるだけでは設計の見通しを改善しない。`BareArrayModule`/
  `OptionalArrayModule`/`PermutationModule`の警告も同様に、`UnsafeMutablePointer`/
  `ManagedBuffer`を直接操作する手動メモリ管理が本体のため、同じ分類に属する。
- **機械的に直せる可能性がある宣言**: 本調査では、上記以外の「ふつうの宣言」
  (たとえば`Unsafe`型を一切含まない公開APIシグネチャに対する警告)は
  見つからなかった。`RedBlackTreeCollections`の全警告は、生ポインタ型
  (`UnsafeMutablePointer<UnsafeNode>`等)を直接保持・参照するコードに起因する。

## 6. 段階的採用の提案

1. **即時適用可能(production code変更なし)**: `AcCollections`、
   `RedBlackTreeModule`。警告0件のため、`Package.swift`への追加だけで
   採用できる。
2. **第2段階(手動メモリ管理の低レベルモジュール)**: `PermutationModule`
   (34件)→`BareArrayModule`(116件)→`OptionalArrayModule`(144件)の順。
   件数が少ない順に、各警告が妥当な`unsafe`マーキングで解消できるか個別に
   判断する。これらは比較的独立した小モジュールのため、1モジュールずつ
   レビュー・適用できる。
3. **第3段階(`RedBlackTreeCollections`本体)**: 4,948件は規模が大きく、
   `Design-MemorySafety.md`が既に整理している責務分離(`UnsafeNode`/
   `UnsafeTreeV2`/Public型)に沿って、内部層ごとに`@unsafe`適合・注釈を
   計画的に追加する大規模タスクになる。本調査の範囲では、レディネス確認
   (ビルドが成功しエラーが出ないこと)のみを確認し、注釈追加の実作業は
   別タスクとして提案する。

## 7. 検証結果

- `swift build --target RedBlackTreeCollections`(`.strictMemorySafety()`
  一時適用): 成功、警告4,948件、エラー0件。
- `swift build`(全ターゲットへ適用、パッケージ全体): 成功
  (`Build complete!`)、エラー0件。
- `git checkout -- Package.swift`後、`git diff Package.swift`は空
  (復元確認済み)。
- 本調査はビルド診断の収集のみで、`swift test`は実行していない
  (production codeの変更がないため)。

## 保留事項

- `RedBlackTreeCollections`本体への実際の注釈付け作業は本タスクの範囲外。
  ユーザーが段階2・3の着手順を承認した後、別タスクとして計画する。
- 診断メッセージの正確なカウントはビルドログの行パターンマッチングに依存して
  いるため、Swiftコンパイラの出力形式が変わった場合は再集計が必要。
