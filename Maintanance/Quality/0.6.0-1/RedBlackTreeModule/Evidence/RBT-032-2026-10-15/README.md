# RBT-032 0.6.0現行品質アセスメント証拠

## 対象

- commit: `36f821a4b6292f14f48b3592af04e736ed1fcb5d`
- branch: `develop/misc/66`
- 実行日: 2026-10-15 JST
- 実行開始時のdirty状態: `Maintanance/ProgressV2/TASK_REGISTRY_V2.md`の再開記録のみ
- `Package.swift`、`Sources/`、`Tests/`に追跡対象の未commit差分なし

OS、architecture、Xcode、Swift、依存graph、`Package.resolved`は
`environment-and-dependencies.txt`に保存した。各コマンドの標準出力と標準エラーを対応する完全logへ保存し、
shellの終了statusを下表へ記録した。

## 実行結果

| 検証 | 終了status | 主な結果 | 完全log |
| --- | ---: | --- | --- |
| Debug全体 | 0 | RedBlackTree内部121件、公開940件、C++比較35件、facade 5件を含め失敗0 | `debug-full.txt` |
| Release全体 | 0 | RedBlackTree内部68件、公開743件、C++比較35件、facade 5件を含め失敗0 | `release-full.txt` |
| ASan本体 | 0 | process-exitを使う2 suiteを除外。RedBlackTree内部121件、公開940件、C++比較35件、facade 5件を含め失敗0 | `asan-excluding-process-exit.txt` |
| ASan＋Death Test | 1 | RedBlackTreeのDeath Test子プロセスでASan interceptorが遅延ロードされ、期待する`SIGTRAP`より前に`SIGABRT`。他moduleのDeath Testにも同じ実行基盤上の失敗あり | `asan-with-process-exit.txt` |
| DocC | 0 | `RedBlackTreeCollections`をwarnings-as-errorsで生成 | `docc.txt` |

## 実行条件

Debug全体:

```console
swift test --disable-sandbox -c debug --build-path <isolated-debug-build>
```

Release全体:

```console
swift test --disable-sandbox -c release --build-path <isolated-release-build>
```

ASan本体:

```console
ASAN_OPTIONS='detect_leaks=0:symbolize=1:abort_on_error=1' \
SWIFT_BACKTRACE=enable \
swift test --disable-sandbox -c debug --sanitize address \
  --build-path <isolated-asan-build> \
  --skip 'DeathTests|RedBlackTreeInternalCoverageTests' \
  --traits SKIP_DEBUG_LIFETIME_BALANCE_CHECKS
```

ASan＋Death Testの反証再現:

```console
ASAN_RUNTIME='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/21/lib/darwin/libclang_rt.asan_osx_dynamic.dylib'
ASAN_OPTIONS='detect_leaks=0:symbolize=1:abort_on_error=1' \
SWIFT_BACKTRACE=enable \
DYLD_INSERT_LIBRARIES="$ASAN_RUNTIME" \
swift test --disable-sandbox -c debug --sanitize address \
  --build-path <isolated-asan-build> \
  --traits SKIP_DEBUG_LIFETIME_BALANCE_CHECKS
```

DocC:

```console
swift package --disable-sandbox -c release \
  --allow-writing-to-directory <docc-output> \
  generate-documentation \
  --target RedBlackTreeCollections \
  --output-path <docc-output> \
  --transform-for-static-hosting \
  --hosting-base-path swift-ac-collections \
  --warnings-as-errors
```

`<isolated-*-build>`と`<docc-output>`は実行ごとに`/tmp`配下へ置いた。絶対pathは完全logに残るが、
再現に必要な意味を持たないため、ここでは役割名へ置き換えた。

## 証拠の境界

- ASan成功は、`DeathTests`および`RedBlackTreeInternalCoverageTests`を除外した範囲に限る。
- ASan＋Death Testの失敗は、子プロセスのASan runtime注入経路が成立しない反証である。対象コードへ到達する前の
  失敗を、RedBlackTree本体の不正アクセスや停止契約違反とは判定しない。
- Debug・Release・DocCの成功は、strict memory safety全面適用、Index最終契約、性能再測定、一般利用・競技利用の
  Validationを保証しない。
- SwiftPM cacheがsandboxから書き込めない警告は全logに残した。依存は隔離ASan buildで取得・解決され、解決結果は
  `environment-and-dependencies.txt`と`Package.resolved`の内容で照合できる。

## SHA-256

| ファイル | SHA-256 |
| --- | --- |
| `asan-excluding-process-exit.txt` | `863ccbf3c11f5e2ee3d1f2020f3a8d0d9769d56afc8eff94dc9f54ff866005af` |
| `asan-with-process-exit.txt` | `094ac657ef9713e358050529bbbe276955b0e3c2c4263e124a54678550bf5ce2` |
| `debug-full.txt` | `c263188244c4cb102cfaadd70901bdd2646f468ddc997b9f178c80232ad70b3d` |
| `docc.txt` | `ab0e6495422e19f73b9aa2fa32cbcd348d6c22a4c4d468eddaa0dbacaa739a83` |
| `environment-and-dependencies.txt` | `3767f24a2cea6212890e6f201e88ed85eae0f86f111266d55e8144ec1e8fd420` |
| `release-full.txt` | `edd3232674a1e8871acc82354dfa7e8a37e79c6c687ef9319a22a599e7afc0a3` |
