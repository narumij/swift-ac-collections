# RedBlackTree 0.6.0現行品質アセスメント

## 目的

RedBlackTreeCollectionsの現行実装について、0.6.0で主張できる品質と、未達・未検証・外部条件待ち・
受容済みの残余リスクを、現在の証拠に基づいて分離する。

このtaskは品質を合格へ寄せる修正作業ではない。警告、失敗、矛盾、未検証領域は、修正前に反証として
保存し、必要な改善は独立task候補へ分離する。

試験コマンドを再実行できることだけでは、アセスメントの再現可能性が成立したとは扱わない。対象commit、
dirty状態、OS、toolchain、依存解決、trait、除外条件、環境変数、実際に選択されたtest、完全log、終了statusを
一体の証拠として復元できる状態を、本アセスメントの完了条件とする。

## 対象

- `RedBlackTreeCollections`の公開4コンテナと共有View
- 現行の公開契約と番号付きTest as Specification
- Debug・Release、Death Test、Address Sanitizer、facade、DocCの検証経路
- 現行CIと性能回帰証拠の存在範囲

## 対象外・境界

- `ContainersPreview`の安定待ちであるIndex契約の最終確定
- 凍結中のstrict memory safety全面適用、並行初期化保証、利用者向け文書作業
- 1.0としての採用判断
- 評価中に発見した問題の修正

## 評価語彙

- 確認済み
- 未達
- 未検証
- 対象外
- 受容済みの残余リスク

## 実行記録

最終測定対象はcommit `36f821a4b6292f14f48b3592af04e736ed1fcb5d`、Apple Swift 6.4
（`swiftlang-6.4.0.34.1`）、arm64、macOS 27.0.1である。実行時の完全log、終了status、環境、依存解決、
dirty状態、およびコマンドは[証拠package](Evidence/RBT-032-2026-10-15/README.md)に保存した。

| 検証 | 構成・結果 | 評価上の扱い |
| --- | --- | --- |
| Debug全体 | 隔離build pathで成功。`RedBlackTreeTreeTests` 121件、`RedBlackTreeTests` 940件、`CppBehaviorReferenceTests` 35件、facade 5件が失敗0 | 確認済み |
| Release全体 | 隔離build pathで成功。`RedBlackTreeTreeTests` 68件、`RedBlackTreeTests` 743件、`CppBehaviorReferenceTests` 35件、facade 5件が失敗0 | 確認済み |
| 通常Death Test | Debug・Releaseの全体試験に含めて成功 | 通常構成では確認済み |
| ASan本体 | 隔離build pathで`DeathTests`と`RedBlackTreeInternalCoverageTests`を除外した全体試験が終了status 0。C++挙動比較35件、facade 5件を含む選択試験が失敗0 | 対象外suiteを明示した局所証拠として確認済み |
| ASan＋Death Test | `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` traitと親プロセスへのruntime注入を併用しても、子プロセスでinterceptorが遅延ロードされ終了status 1 | 検証経路未成立 |
| DocC | `RedBlackTreeCollections`を`--warnings-as-errors`で生成成功 | 確認済み |

最初のSwiftPM実行はmacOS sandboxの適用拒否でmanifest評価前に停止したため、以後はSwiftPM内部の
sandboxだけを`--disable-sandbox`で無効化した。これは製品コードの失敗には数えない。

### 実行コマンド

Debug全体:

```console
swift test --disable-sandbox -c debug
```

Release全体:

```console
swift test --disable-sandbox -c release
```

ASan全体。通常試験は進行したが、Swift TestingのDeath Test子プロセスでASan runtimeの
遅延ロードが発生し、全体として失敗した:

```console
ASAN_OPTIONS='detect_leaks=0:symbolize=1:abort_on_error=1' \
SWIFT_BACKTRACE=enable \
swift test --disable-sandbox -c debug --sanitize address --build-system native
```

ASan本体の隔離再試験。Swift TestingのDeath Testに加え、名称に`DeathTests`を含まないが
`processExitsWith`を使う`RedBlackTreeInternalCoverageTests`も除外し、終了status 0を確認した:

```console
RBT_ASAN_BUILD="$(mktemp -d /tmp/rbt-quality-asan.XXXXXX)"
ASAN_OPTIONS='detect_leaks=0:symbolize=1:abort_on_error=1' \
SWIFT_BACKTRACE=enable \
swift test --disable-sandbox -c debug --sanitize address \
  --build-path "$RBT_ASAN_BUILD" \
  --skip 'DeathTests|RedBlackTreeInternalCoverageTests' \
  --traits SKIP_DEBUG_LIFETIME_BALANCE_CHECKS
```

この再試験はbuild cacheへの依存を避けて成功し、完全log、終了status、依存解決、選択条件を
repository内の証拠packageへ保存した。

Debug lifetime balance検査をtraitで無効化し、親プロセスへASan runtimeも明示注入した再試験。
子プロセスでは同じ遅延ロード診断が発生し、全体として失敗した:

```console
ASAN_RUNTIME='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/21/lib/darwin/libclang_rt.asan_osx_dynamic.dylib'
ASAN_OPTIONS='detect_leaks=0:symbolize=1:abort_on_error=1' \
SWIFT_BACKTRACE=enable \
DYLD_INSERT_LIBRARIES="$ASAN_RUNTIME" \
swift test --disable-sandbox -c debug --sanitize address --build-system native \
  --traits SKIP_DEBUG_LIFETIME_BALANCE_CHECKS
```

DocC生成:

```console
swift package --disable-sandbox -c release \
  --allow-writing-to-directory .build/documentation \
  generate-documentation \
  --target RedBlackTreeCollections \
  --output-path .build/documentation \
  --transform-for-static-hosting \
  --hosting-base-path swift-ac-collections \
  --warnings-as-errors
```

### ASan＋Death Testの反証

ASan付き全体試験では、Swift Testingの`#expect(processExitsWith:)`が生成する子プロセスで
`AddressSanitizer: Interceptors are not working`が発生した。診断はASan runtimeが遅れてロードされたとし、
`DYLD_INSERT_LIBRARIES`を要求する。

既存の`SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` traitを有効にし、親プロセスへASan runtimeを明示注入しても、
子プロセスでは同じ診断が再現した。したがって、Debugのprocess-globalなallocation・node・payload
釣り合い検査と、macOSでのASan runtime子プロセス継承は別問題である。

`DeathTests`だけを名前で除外しても、`RedBlackTreeInternalCoverageTests`内の`processExitsWith`が残り、
期待した`SIGTRAP`ではなくASanによる`SIGABRT`となることも確認した。したがって、suite名だけから検証対象を
推定せず、実際に選択されたtestを証拠へ含める必要がある。

両suiteを除外した隔離ASan buildは成功したため、今回の証拠だけからRedBlackTree本体の不正アクセスとは
判定しない。一方、macOS上で「ASanを有効にした停止契約が成功した」とも主張しない。

## 現在評価

| 品質領域 | 判定 | 根拠と境界 |
| --- | --- | --- |
| 公開4コンテナと共有Viewの正確性 | 確認済み | Debug 940件、Release 743件、参照モデル・fuzz・不変条件・C++挙動比較を含む現行Test as Specificationが成功 |
| `__tree`内部契約 | 確認済み | Debugで内部tree試験121件が成功。ASanでは停止契約を含む内部coverage suiteを除外 |
| 値セマンティクス・CoW・要素寿命 | 確認済み | 通常試験とDeath Test、Death Test以外のASan試験が成功 |
| 通常構成の停止契約 | 確認済み | Debug・ReleaseでSwift Testing Death Testが成功 |
| macOS ASan下の停止契約 | 未検証 | 子プロセスでASan runtime注入が成立せず、対象コードへ到達する前に失敗 |
| facadeからの利用 | 確認済み | `AcCollectionsTests` 5件がDebug・Release・ASan本体構成で成功 |
| API文書生成 | 確認済み | DocCをwarnings-as-errorsで生成成功 |
| 性能回帰 | 確認済みの既存証拠あり | 現行CIにperformance jobがあり、直近のgreen記録はRegistryで管理。今回ローカル再測定はしていない |
| strict memory safety全面適用 | 未検証 | `RedBlackTreeCollections`の`.strictMemorySafety()`は無効で、既存taskが凍結中 |
| Index最終契約 | 未確定 | 公開Index表現と`Comparable`採否は`ContainersPreview`の安定待ち |
| 一般Swift利用・競技利用へのValidation | 未検証 | Verification成功だけから利用目的への適合を推定しない |

0.6.0時点の途中Verificationとして、通常のDebug・Release、公開／内部契約、facade、C++挙動比較、
Death Test、およびDocCの個別試験は成立している。ASanは停止契約を含む2 suiteを除外した本体検証が成立した。

一方、macOSのASan＋Swift Testing Death Test経路、strict memory safety全面適用、外部条件待ちのIndex最終契約、
および利用Validationは閉じていない。これらを隠して0.6.0品質全体を無条件に合格とは判定しないが、
今回の試験から現行公開機能の修正を直ちに要求する製品不具合は確認されなかった。環境、依存解決、選択条件、
完全log、終了statusを証拠packageへ保存したため、ここに記した境界を伴う0.6.0現行品質アセスメントとして完成とする。
未確定領域は合格へ丸めず、後続の判断・調査・1.0品質ゲートへ残す。

## 既知の未確定領域

- 公開Index表現と`Comparable`採否は外部条件待ちである。
- `RedBlackTreeCollections`への`.strictMemorySafety()`全面適用は凍結中である。
- `lazyDetach`等の並行初期化保証は凍結中である。
- Mapped Values ViewのO(1)範囲契約は利用者向け文書作業まで凍結中である。
- macOSのASan＋Swift Testing Death Test子プロセス経路は、実行基盤の切り分け待ちである。
- 1.0品質保証CIで用いる永続的な証拠形式とLinux代表環境の実行は、凍結中の別taskで扱う。

これらは今回の試験失敗とは扱わず、0.6.0時点で閉じていない品質境界として評価する。
