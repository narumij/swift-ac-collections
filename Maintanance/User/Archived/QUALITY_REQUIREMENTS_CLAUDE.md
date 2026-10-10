# リリース品質要求 独立ドラフト — Claude

`RELEASE-074`のClaude版。`QUALITY_REQUIREMENTS_CODEX.md`は読んでいない。

## 0. 前提

### 入力にしたコンセプト

> CやC++標準に匹敵する性能をもつ、競技プログラミングで利用可能なデータ構造を、一般のSwift開発にも提供する。

この一文を、次の3つの品質軸に分けて読む。要求は軸ごとに立てる。

- **A. 性能**: C/C++標準（`std::set`／`std::map`、Cの配列、`next_permutation`）に匹敵する。
- **B. 競技プログラミングでの実用性**: AtCoderで、C++を前提とした問題を同じ発想で書ける。
- **C. 一般のSwift開発での利用可能性**: 競技以外のSwiftプロジェクトが依存しても困らない。

### 参照した証拠（2026-10-10時点のHEAD `d53c6190`付近）

- `Package.swift`: tools 6.2、`platforms: [.macOS(.v15)]`のみ、product `AcCollections`、trait 3種
  （`USE_COMPACT_NODE_METADATA`、`USE_C_MALLOC`、`USE_INT128`）、互換mode `COMPATIBLE_ATCODER_2025`（コメントアウト）。
- `Sources/AcCollections`: RedBlackTreeCollections、PermutationModule、OptionalArrayModule、BareArrayModuleを再export。
- `.github/workflows/ci.yml`: ubuntu-24.04でDebug test、Release test、benchmarkのbase/head相対比較、Address Sanitizer。
- `.github/workflows/candidate.yml`: ubuntu-24.04でRelease＋`ENABLE_DEATH_TESTS`、DocC（RedBlackTreeCollectionsのみ）、性能。
- `.github/workflows/main.yml`: DocC生成とPages公開（RedBlackTreeCollectionsのみ）。
- `Benchmarks/Results.md`ほか: `RedBlackTreeSet vs std::set`等の比較図（最終更新2026-09-26）。
  Permutation、BareArray、OptionalArrayのC/C++比較は見当たらない。
- `README.ja.md`: 推奨は`branch: "main"`、「安定版としてのAPI互換性はまだ保証しない」、アンダースコア付き宣言は公開APIではない、
  AtCoder 2025用の別branch。
- 本日の観察: 赤黒木の型コメントの例が現行APIでコンパイルできなかった（`CP-20261010-002`で修正）。
  DocCの`--warnings-as-errors`は通っていたので、DocCはコード例のコンパイルを保証しない。
- 本日の観察: Swift 6.4のRelease最適化でiterator copyの独立性が壊れる事象（`PERM-029`）は、macOSのローカルRelease testで見つかった。CIはLinuxのみ。

## 1. 製品品質と公開契約の要求候補

### Q-A 性能

- **Q-A1** 各データ構造の主要操作が、対応するC/C++標準と同じ計算量であること。計算量は公開コメントの`Complexity`に書かれ、実装と一致すること。
- **Q-A2** 主要操作の実測が、C/C++標準と「匹敵」と言える範囲にあること。範囲はまだ定義されていない（§5のU-1）。
- **Q-A3** 前のreleaseから、意図しない性能劣化がないこと。
- **Q-A4** 性能のためのunsafe実装が、正しさ（値semantics、要素の寿命、境界）を壊さないこと。

### Q-B 競技プログラミングでの実用性

- **Q-B1** C++の`set`／`multiset`／`map`／`multimap`、`lower_bound`／`upper_bound`、`next_permutation`に相当する操作が揃い、同じ結果を返すこと（`CppBehaviorReference`の比較対象）。
- **Q-B2** AtCoderのジャッジ環境のSwift version・build設定（`-Ounchecked`を含む）でビルドでき、そこで正しく動くこと。
- **Q-B3** 誤用（範囲外添字、無効index）がDebug／Releaseで検出されること。`-Ounchecked`で検査が外れる範囲が公開コメントに書かれていること。

### Q-C 一般のSwift開発での利用可能性

- **Q-C1** 公開API（アンダースコアなしの`public`宣言）の振る舞いが、仕様testで固定されていること。
- **Q-C2** 公開APIの意味と制約が、DocCで読めること。そこに載っているコード例が、現行APIでコンパイルできること。
- **Q-C3** 宣言した対応環境でビルドとtestが通ること。対応環境の宣言自体がまだない（§5のU-3）。
- **Q-C4** releaseを利用者がversionで指定できること。READMEは現在`branch: "main"`を推奨している（§5のU-4）。
- **Q-C5** 互換mode、experimental trait、内部APIが、通常版の公開面に混入していないこと。
- **Q-C6** Swift 6の言語モード（Sendable、strict concurrency）で、利用者側に警告やエラーを持ち込まないこと。

## 2. 受け入れに必要な証拠

| 要求 | 証拠 | 現状 |
|---|---|---|
| Q-A1 | 計算量を書いたコメントと仕様testの突き合わせ | 一部（RBT系は記載が多い） |
| Q-A2 | 同一machineで、C++とSwiftを同じworkloadで測った結果 | Set/Dictの図のみ、2026-09-26。release時に再生成する手順は`UNVERIFIED` |
| Q-A3 | CIのbase/head相対比較 | あり。配置ノイズが±20%出る既知事情（10/9 Linux CIで赤4回）があり、判定の扱いが要る |
| Q-A4 | Address Sanitizer、Release test、値semanticsの仕様test | あり（Linux）。macOS Releaseは未自動化 |
| Q-B1 | `CppBehaviorReference`と同じ入力での結果比較test | targetはある。どの操作を網羅しているかは`UNVERIFIED` |
| Q-B2 | ジャッジと同じtoolchain・flagでのbuildとtest | 通常版では`UNVERIFIED`（AtCoder 2025はbranchで固定） |
| Q-B3 | Death test（macOS既定、Linuxは`ENABLE_DEATH_TESTS`） | あり |
| Q-C1 | 仕様testが公開APIを網羅していることの対応表 | module別には進行中。全体の網羅は`UNVERIFIED` |
| Q-C2 | 全公開moduleのDocC warnings-as-errors、コード例のコンパイル | DocCはRedBlackTreeCollectionsだけ。コード例は検証手段がない |
| Q-C3 | 宣言環境ごとのCI | Linuxのみ。macOSはローカル |
| Q-C4 | tag、CHANGELOG、READMEの依存例 | tagの運用は`RELEASE_CHECKLIST.md`にあるが、READMEはbranch指定 |
| Q-C5 | 公開symbolの差分（前tag比） | checklistに項目あり。手段は`UNVERIFIED` |
| Q-C6 | 利用者側から見たSwift 6 modeでのbuild | `UNVERIFIED` |

## 3. リリース停止条件と、0.5.xで受容できる残余risk

### 停止条件の候補

- **S-1** Debug、Release、Death test、Address Sanitizerのいずれかが、候補commitで赤。
- **S-2** 公開APIの値semanticsまたはメモリ安全性を壊す既知の不具合が、未修正か回避なしで残っている。
- **S-3** 公開コメントのコード例が、現行APIでコンパイルできない（本日の例がこれに当たる）。
- **S-4** 公開面に、互換modeや内部APIが混入している。
- **S-5** 性能が前releaseから明確に劣化し、その理由が説明されていない。「明確」の閾値は未定義（§5のU-2）。

### 0.5.xの実験として受容できる残余riskの候補

- **R-1** 公開APIの破壊的変更（READMEで既に「保証しない」と宣言している範囲）。
- **R-2** C/C++比較が一部のデータ構造にしかないこと。ただし、READMEやコンセプトで比較していない型について「匹敵」を名乗らないことが条件。
- **R-3** macOS／Linux以外の環境が未検証であること。
- **R-4** コンパイラ由来と見られる最適化の不具合（`PERM-029`）が、回避策と回帰testで押さえられていること。

## 4. VerificationとValidationの区別

- **Verification（要求どおり作られたか）**: Q-A1、Q-A3、Q-A4、Q-B1、Q-B3、Q-C1、Q-C2、Q-C5。
  仕様test、CI、DocC、symbol差分で機械的に判定できる。
- **Validation（コンセプトの用途に合っているか）**:
  - Q-A2: 「匹敵」と言えるか。C++との実測でしか判定できない。
  - Q-B2: AtCoderで実際に使えるか。実提出（例: `PERM-002`のABC328E）が直接の証拠になる。
  - Q-C3／Q-C4／Q-C6: 競技以外のSwiftプロジェクトが、version指定で依存し、困らずに使えるか。
    利用者経路のsmoke test（空のpackageから依存してbuildし、READMEの例を動かす）が証拠になる。
- 注意: 現在のCIはほぼVerificationだけで、Validationの証拠は散発的（図、手動提出）にしかない。

## 5. 要求から見つかる不足仕様の候補（ユーザー判断は1問ずつ）

- **U-1** 「C/C++に匹敵する」の判定基準（比較対象、workload、許容倍率）は何か。
- **U-2** releaseを止める性能劣化の閾値は何か。配置ノイズ±20%とどう区別するか。
- **U-3** 「一般のSwift開発」で対応を宣言する環境はどこまでか（macOS／Linux／iOS等、Swift version）。
- **U-4** 利用者にversion指定（tag）を勧めるのはどのreleaseからか。0.5.xでもbranch推奨を続けるか。
- **U-5** C/C++比較を載せる型は赤黒木だけか。Permutation、BareArray、OptionalArrayにも「匹敵」を求めるか。
- **U-6** 公開コメントのコード例をコンパイルで保証する手段を持つか（SE-0356のSnippets等。手段の調査は`UNVERIFIED`）。
- **U-7** 通常版（`main`）のAtCoderジャッジ設定でのbuildを、release要求に含めるか。

## 6. 範囲外として扱わなかったもの

実装案、工程表、CI設定の変更、性能閾値の確定、既存release文書の修正。
