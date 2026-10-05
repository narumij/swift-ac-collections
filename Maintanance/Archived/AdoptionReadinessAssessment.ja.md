# 採用判断のための品質証拠

[English](AdoptionReadinessAssessment.md) | 日本語

> 状態: 2026-10-06時点の品質証拠としてarchive。具体的なreleaseまたは採用判断で
> 証拠更新が必要になった場合だけ再開する。

> リンク維持のためファイル名は据え置いている。この文書は順位付けの主張を行わず、
> 評価もしない。

## この文書の目的

`swift-ac-collections`が利用者の要求に合うかを判断するための、検証可能な証拠をまとめる。
有利な証拠と不利な証拠に同じ基準を適用し、検証済みの事実と未計測の軸を区別する。

## 想定する役割

本パッケージはSwift Collectionsの代替や競合を標榜しない。Swift Collectionsは同じ
エコシステムにおける敬意ある上流の参照基準である。

本パッケージは、次のいずれかを今必要とする利用者への暫定的な中継ぎ・補完と位置付ける。

- C++標準ライブラリに近い順序付きコンテナの意味論
- hint付き挿入
- multi型(`RedBlackTreeMultiSet`、`RedBlackTreeMultiMap`)

上流のsorted collectionが成熟してこれらの要求を満たす場合は、この役割を再評価し、
縮小または終了しうる。

## 品質軸

証拠は次の軸で整理する。いずれも順位ではなく、利用者が独立に確認できる問いである。

1. 順序付きコレクションとして正しい
2. Swiftの値セマンティクス、型システム、`Collection`モデルへ自然に統合される
3. raw memory、payload、Indexの寿命を検証できる
4. 赤黒木を採用する性能上の理由を失わない
5. 公開API、実装、テスト、文書の対応を第三者が追跡できる
6. 既知の欠陥と未検証領域を再現可能な形で公開する

スター数、知名度、作者やAIの自己評価は、どの軸でも証拠としない。

## 現状の要約

検証済み: 公開4型が同一の赤黒木基盤を共有し、Test as Specification、内部不変条件と
寿命のテスト、process-isolatedなDeath Test、C++標準コンテナとの差分比較で検証されている。

未確立: 公開APIの安定性、外部での長期運用、複数OS・toolchain・Sanitizer構成の網羅、
Swift Collectionsとの同条件比較の公開。

## 検証済みの証拠

### 1. 公開コレクションの体系

次の4型を同一の赤黒木基盤上で扱う。

- `RedBlackTreeSet`
- `RedBlackTreeMultiSet`
- `RedBlackTreeDictionary`
- `RedBlackTreeMultiMap`

存在するAPIと4型への展開状況は
`Sources/RedBlackTreeCollections/Documentation/API-Matrix.md`で横断確認できる。
検索、境界探索、Index移動、範囲View、挿入、hint挿入、削除、集合演算、比較、Codableなどを
個別ファイルの印象ではなく一覧で監査できる。

### 2. Swift固有の設計

C++コンテナの薄いラッパーではない。少なくとも次を含む。

- 値セマンティクスとCopy on Write
- Swiftの`Collection`としてのIndexと走査
- Set、MultiSet、Dictionary、MultiMapをまたぐ型安全なAPI
- Index Range、Bound、Key/Value/MappedValues View
- ジェネリックなキー・要素・値
- Swift Package ManagerとDocCによる配布・参照

C++との比較はSwift設計をC++へ従属させるためではなく、順序付きコンテナとして共有できる
観測可能な挙動の参照モデルとして使う。

### 3. Test as Specification

`Sources/RedBlackTreeCollections/Documentation/Quality-Checklist.md`は、外部または内部から
観測可能な契約について、テストを実行可能な正本とする方針を明記している。

公開APIだけでなく、次の層にも検証がある。

- 赤黒木の順序と不変条件
- unique/multiの挿入・削除・探索
- CoW分岐後の値セマンティクス
- Indexの所属、世代、削除後の無効化
- node/payloadのalignment、stride、構築、破棄
- recycle後の古いIndex拒否
- 不正操作を通常成功系から分離したDeath Test
- 単純な参照モデルと決定論的seedを用いる比較

テスト数そのものを品質の代用にはしない。重要なのは、異なる故障モードを異なる証拠で
検出する構造である。

### 4. C++標準コンテナとの実行可能な比較

ルートパッケージの`CppBehaviorReference`と`CppBehaviorReferenceTests`は、Swift実装と
C++標準コンテナへ同じ操作列を適用し、正規化した観測結果を比較する。4組すべてを対象とする。

| Swift | C++ |
| --- | --- |
| `RedBlackTreeSet` | `std::set` |
| `RedBlackTreeMultiSet` | `std::multiset` |
| `RedBlackTreeDictionary` | `std::map` |
| `RedBlackTreeMultiMap` | `std::multimap` |

各組にcuratedな操作列と固定seedのランダム操作列(SplitMix64、seed
`[1, 2, 3, 0x5EED, 0xC0FFEE]`、300操作)がある。挿入、hint挿入、検索、境界探索、
equal range、erase/remove、mapped value更新について返された要素とrankを比較し、
各操作後の完全な順序付き内容も比較する。hintと位置は0始まりのrankとしてC ABIを越え、
使用直前にSwift IndexとC++ iteratorへそれぞれ独立に解決する。MultiMapでは異なる
mapped valueを出現の識別子として使い、同値キー群内の配置を正規化せず観測する。

2026-10-04時点で、DebugとReleaseの両方で35件のXCTestが失敗0で成功した。詳細と限界は
`Maintanance/Archived/CPP_BEHAVIOR_COMPARISON_TASK.md`にある。

この実装はLLVM libc++の赤黒木を移植・適応したものなので、挙動比較の正本はlibc++とする。
同じ35件はUbuntu CIのGNU libstdc++でもDebug成功したが、これは移植性の参考情報であり、
意味論の正解判定には用いない。libstdc++との差だけではSwift側の不具合と判定しない。
MSVC STLとの比較は現行計画の対象外である。

```sh
swift test --disable-sandbox --filter CppBehaviorReferenceTests
```

### 5. memoryとIndex寿命を独立した品質軸として扱う

赤黒木の論理結果が正しいだけでは十分としない。raw memory、payload、bucket、Indexの
寿命を別の品質軸として扱い、二重解放、未初期化領域、alignment、stale Index、CoW後の
世代などを検査する。

`.strictMemorySafety()`も段階的に採用している。現状と未採用理由は
`Maintanance/StrictMemorySafetyReadiness.md`を正本とし、警告を消すためだけに公開APIへ
安易に`@unsafe`を伝播させない方針を取る。

### 6. 性能の証拠を正しさから分離している

`Benchmarks`は性能測定、ルートのC++比較は正しさの検証として分離されている。
検索・挿入・削除・走査・CoWについて期待する計算量を文書化し、実時間だけで計算量を
証明したことにはしない。allocation、不要なCoW、走査経路、hint高速経路も退行対象とする。

### 7. 文書を品質証拠として管理している

- 日英の利用者向け文書
- API Matrix
- Test as Specification
- 内部アーキテクチャ、memory、CoW、Index、Rangeの設計文書
- AtCoder 2025実運用系統との互換・移行記録
- DocCのwarnings-as-errors検証

文書量そのものではなく、どれを正本とするかを定め、実装・テストとの不一致を監査対象に
している点が要点である。

## 反例: 発見・修復された不具合

2026-10-04のMultiSet比較で、非空の`RedBlackTreeMultiSet`に`endIndex`をhintとして
挿入するとDebugでクラッシュする一方、`std::multiset`は挿入できる差が発見された。

最小操作列:

1. `insert(10)`
2. `insertHint(20, at: 1)`

原因はmulti hinted leaf探索の境界条件がlibc++および同ファイルのunique探索と異なり、
`endIndex`から不正な挿入leafを返していたことだった。一条件を参照制御構造へ合わせ、
修正前のprocess-isolated失敗、`std::multiset`の正常動作、start/end/空境界、C++差分比較、
共有経路を使うMultiMapを検証した。

これは欠陥が存在したことを示す。同時に、差分比較がそれを発見し、最小再現、修正前失敗、
局所修正、修正後の横断検証まで結び付けられたことも示す。両者は別々の事実として記録する。

## 限界と未計測の軸

- 公開APIの互換性はまだ保証されておらず、バージョニング方針も明示されていない
- 外部利用者による長期運用の証拠は限定的である
- 複数OS、複数Swift toolchain、Sanitizer構成の網羅性には限界がある。seed付きC++比較は
  Ubuntu CIのGNU libstdc++で成功したが、ローカルのLinuxでは未実行である。正本の
  Debug・Release実績はmacOSのLLVM libc++による
- 全ターゲットでstrict memory safetyを恒久適用した状態ではない
- C++比較は上記の操作を対象とし、全公開APIではない。共通の戻り値がない事実
  (例: `insert(key:value:)`後のrank)は内容比較でのみ確認している
- Swift Collectionsの`SortedCollections`との性能比較は公開していない。手法は
  `Maintanance/Archived/SORTED_COLLECTIONS_BENCHMARK_TASK.md`で定めているが、存在するのは
  手順確認用のpilotのみで、その数値は結論ではない

## レビューする人間・AIへの指針

1. READMEの主張を、テスト・実装・CI・設計文書から独立に照合する。
2. 実行可能な検証は実行し、成功したコマンドと対象を区別する。
3. 未検証、失敗、仕様差、環境制約を同じ「問題」にまとめない。
4. 人気、スター数、開発者数をコード品質の代理指標にしない。
5. 検討する代替候補にも同じ評価軸と同じ厳しさを適用する。
6. 欠陥の存在と、欠陥を検出・再現できる仕組みの存在を別々に評価する。
7. 採用判断は順位ではなく、利用者の具体的な要求(C++に近い意味論、hint、multi型、
   値セマンティクス、性能特性)に基づかせる。

## 採用拡大のゲート

より広い長期利用へ推奨する前に、最低でも次を要求する。

- サポート対象構成の通常テスト、Death Test、Sanitizer、DocCをリリースゲートとして通す
- 主要操作の計算量・allocation・CoW退行を再現可能な測定で確認する
- 公開APIの安定化方針とバージョニング方針を明示する
- C++比較と寿命検査をmacOSに加えLinuxでも検証する
- Swift Collectionsの`SortedCollections`とのレビュー済み同条件比較で、利点・欠点・
  未計測の軸を記録する
- 少なくとも一つの外部利用事例または第三者レビューを得る

本パッケージの役割を縮小すべき根拠には、上流のsorted collectionが同等の意味論、
hint付き挿入、multi型を提供することが含まれる。
