# 外部所有型Extension監査

最終更新: 2026-10-04 / Codex

## 目的

標準ライブラリなど、swift-ac-collectionsが所有しない型へ追加しているextensionを一覧化し、
利用者や他ライブラリへ影響するものと、モジュール内部だけで使うものを区別する。

Swiftでは`extension`宣言そのものより、次が外部影響を決める。

- 追加メンバーのアクセスレベル
- 外部所有protocolへのretroactive conformance
- package/internal protocolへの適合
- `@inlinable`または`@usableFromInline`を通したclient codeへの埋め込み
- build configurationによる有無

## 現在の一覧

| 外部所有型 | 追加内容 | 宣言上の範囲 | 構成 | 外部への影響 | 判定 |
| --- | --- | --- | --- | --- | --- |
| `Collection where Index == Int` | `nextPermutations()` | `public` | 常時 | importした利用者の全該当Collectionへメソッド候補を追加 | 意図した公開API |
| `Int` | `__less()` / `__greater()` | `public` | 常時 | importした利用者の`Int`へ二つのメソッドを追加 | 公開の必要性を再確認 |
| `Int` | `ThreeWayCompareResult`適合 | internal protocolへの適合 | 常時 | protocol自体は外部非公開。主に内部実装へ影響 | 内部用途 |
| `Result` | `Comparable`適合 | `public` retroactive conformance | `DEBUG`のみ | 条件を満たすすべての`Result`へ適合を追加し、他moduleや将来の標準適合と衝突し得る | 最優先で解消候補 |
| 特殊化された`Result` | 複数の`==` / `!=` overload | `public` | 常時 | 該当する`Result`のoverload resolutionへ追加候補が見える | Index再設計時に監査 |
| `Result` | `_NodePtr` typealias | `public` | 常時 | すべての`Result`へ赤黒木内部由来の名前を追加 | 非公開化候補 |
| 特殊化された`Result` | pointer検証、変換、`SealError`伝播helper | internal / package中心 | 常時、一部`DEBUG` | 通常は外部から直接呼べない。`@inlinable`経由の依存は残り得る | 内部へ閉じる |
| `Range` / `ClosedRange` | `SortedSequence`適合 | package protocolへの適合 | `DEBUG`かつ非互換mode | package外からprotocolを利用できない | 実験用。削除可否を確認 |
| `String` | RedBlackTree診断文言 | internal `@usableFromInline` | 常時 | source APIには出ないが、公開`@inlinable`実装から参照可能 | 内部用途 |
| `MemoryLayout` | node/payload layout helper | internal `@inlinable` | 常時 | source APIには出ない。serialized implementationの依存になり得る | 内部用途 |
| `UnsafeMutablePointer where Pointee == UnsafeNode` | `_NodePtr` typealias | `public` | 常時 | 該当pointer specializationへ赤黒木内部由来の名前を追加 | 非公開化候補 |
| `UnsafeMutablePointer` | node/bucket操作helper | internal中心、一部`@inlinable` | 常時、一部deprecated | source APIには出ないが、公開`@inlinable`経路を個別確認する余地あり | 内部用途 |
| `UnsafeMutableRawPointer` | allocate/deallocate helper | internal、一部`@inlinable` | `USE_C_MALLOC`分岐 | source APIには出ない。serialized implementationの依存になり得る | 内部用途 |

## 重要な区別

### 公開メンバーの追加

`public`メンバーは、利用者がmoduleをimportすると外部所有型のメンバー候補として見える。
名前衝突やoverload resolutionへの影響がある。`Collection.nextPermutations()`は意図した
製品APIだが、`Int.__less()` / `__greater()`は赤黒木内部の都合を公開していないか確認する。

### Retroactive conformance

外部所有型を外部所有protocolへ適合させる変更は、単なるhelper追加より影響が大きい。
現在該当する重要例はDebug構成の`Result: Comparable`である。

Debug限定でも、Debugでライブラリを利用するclientと同一process内の他moduleへ適合が見える。
Releaseに存在しないため、構成によってgeneric制約の成立可否が変わる問題もある。
RedBlackTreeIndexを`Comparable`にする正式手段としては採用しない。

### Internal / package member

アクセス制御された追加メンバーは、通常は利用者のsource APIへ現れない。ただし
`@inlinable`な公開関数から使われる`@usableFromInline`宣言は、clientへ直列化される実装の
一部になり得る。source公開と同一ではないが、完全に自由な実装詳細ともみなさない。

## TestCodeへ移動できる候補

### 移動可能性が高い

| 対象 | 現在地 | 利用状況 | 移動先候補 | 備考 |
| --- | --- | --- | --- | --- |
| `Range` / `ClosedRange: SortedSequence` | `RedBlackTreeSet+SetAlgebra.swift` | `EtcTests.testAPICheck()`だけ | `RedBlackTreeTestSupport`または当該test file | protocol、`union<S: SortedSequence>`、`___meld_unique`等の実験経路を一群で移す必要がある |
| `Result: Comparable` | `_LazyTieWrap+Result.swift` | DebugのIndex比較テストと性能実験 | `RedBlackTreeTestSupport` | 正式APIにしない場合。`_LazyTieWrap: Comparable`も同時に移す |
| 特殊化`Result.unsafe(tree:rawTag:)` | `_LazyTieWrap+Result.swift` | 4コンテナの`_98_IndexValidityXCTests`等だけ | `RedBlackTreeTestSupport` | 不正・任意tagのIndexを合成するfixtureであり、production処理から参照されない |

`Result: Comparable`の移動は、Indexを正式に`Comparable`へ適合させない場合に限る。
正式適合させる場合はTestCodeへ移すのではなく、固有Index型等でproductionに実装する。

### 本体に残すが公開範囲を狭める候補

| 対象 | 本体に必要な理由 | 対応候補 |
| --- | --- | --- |
| `Int: ThreeWayCompareResult`と`__less()` / `__greater()` | 赤黒木の検索・境界・比較アルゴリズムが使用 | TestCodeへは移さず、publicが必要かを見直す |
| 特殊化`Result`の`==` / `!=` | 現行Indexとsealed pointerの等価比較に使用 | Index再設計後に固有型または内部helperへ閉じる |
| `String`診断文言 | productionのprecondition/fatal errorで使用 | internalを維持 |
| `MemoryLayout` helper | bucket/node layout計算で使用 | internalを維持 |
| pointer操作extension | productionの木・allocatorアルゴリズムで使用 | internal/packageを維持し、public typealiasだけ監査 |
| `Collection.nextPermutations()` | PermutationModuleの意図した公開API | publicを維持 |

### 移動時の注意

- extensionだけを移してproduction側に専用protocolや専用algorithmを残さない。
- TestSupportへ置くconformanceはtest process内には影響するため、標準型への適合追加は
  最小限にする。
- `@testable import`だけに依存せず、package accessで必要なfixtureを構成できるか確認する。
- Debug/Release双方でtest target自体がcompileできる構造にし、`#if DEBUG`の位置を確認する。

## 残タスク

- [ ] `Int.__less()` / `__greater()`をpublicにする必要があるか確認する
- [ ] Debug限定の`Result: Comparable`をIndex設計の決定に従って削除する
- [ ] `SortedSequence`実験経路を一群でTestCodeへ移す
- [ ] `Index.unsafe(tree:rawTag:)`をTestSupportへ移す
- [ ] 特殊化`Result`のpublic `==` / `!=`が必要か確認する
- [ ] `Result._NodePtr`と`UnsafeMutablePointer._NodePtr`のpublic typealiasを非公開化できるか確認する
- [ ] 外部所有型extension内の全`public` / `package`メンバーを機械的に再抽出する
- [ ] 公開を維持するextensionをAPI MatrixまたはDocCへ記録する
- [ ] 内部用途のextensionは、可能なら名前空間を所有する内部型またはfree functionへ寄せる
- [ ] DebugとReleaseでprotocol conformance集合が変わる箇所をゼロまたは明示的な例外にする

## 完了条件

1. 外部所有型へ追加するすべての公開メンバーとprotocol conformanceが列挙されている。
2. 各項目について、製品API、境界内部、完全な内部用途のいずれかが決まっている。
3. 意図しない公開メンバーとretroactive conformanceが除去されている。
4. DebugとReleaseの差が診断コードだけに限定され、公開適合の集合を変えない。

## 主な確認元

- `Sources/PermutationModule/Permutations.swift`
- `Sources/RedBlackTreeCollections/Implements/__tree/three_way_compare/three_way_compare_result.swift`
- `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap+Result.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeSet/RedBlackTreeSet+SetAlgebra.swift`
- `Sources/RedBlackTreeCollections/Implements/Misc/Message.swift`
- `Sources/RedBlackTreeCollections/Implements/RawBuffer/_BucketQueue.swift`
- `Sources/RedBlackTreeCollections/Implements/RawBuffer/UnsafeMutableRawPointer+malloc.swift`
