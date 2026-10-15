# Permutation module移行：実装返却

固定ID：`PERM-076`。受領・受入状態の正本はRegistry。作成者：Astra。

## 返却

2026-10-15、Swift 6.4（swiftlang-6.4.0.34.1、arm64-apple-macosx27.0）で実装とローカル検証を完了した。

### 変更

- 実装・DocC・品質資料を`Sources/NextPermutationModule/`へ移し、`Sources/_PermutationModule/`に`@_exported import NextPermutationModule`だけを持つ旧名互換targetと互換案内を追加した。実装は複製していない。
- `AcCollections`は新旧targetへ依存し、新名を再公開する。通常ownerのgeneric parameterを`Element`へ変更した。公開型名・method名・入れ子`Permutation`・アルゴリズムは変更していない。
- 通常testとcompiler fixtureを新入口へ切り替え、旧入口・facade・新旧同時importの外部client検査を追加した。2025互換modeでは既存のSequence APIを使う検査へ分岐する。
- 新旧DocC catalogとCI matrix、README、現行品質・文書計画の名前・path・互換説明を更新した。deprecated指定・廃止期限は追加していない。
- benchmarkは`import NextPermutationModule`だけを変更した。登録title・library・測定処理・入力・結果正規化は変更していない。

### ローカル検証

- Xcode build for testing：成功。
- `swift test --disable-sandbox --filter PermutationTests`：Debug runtime 61件、Death Test 17件が成功。
- `swift test --disable-sandbox -c release --filter PermutationTests`：Release runtime 61件、Death Test 17件が成功。
- `swift test --disable-sandbox -Xswiftc -DCOMPATIBLE_ATCODER_2025 --filter AtCoder2025Compatibility`：Permutation互換仕様5件が成功。既存AtCoder 2025実装のstrict-memory-safety警告は出るが、失敗はない。
- `Utilities/Maintenance/VerifyPermutationCompilerDiagnostics.sh`：新名・旧名・facade・新旧同時importの4 compile-passと、直接初期化・copy・Sequenceの3期待拒否が成功。
- product `AcCollections`だけへ依存する同fixtureを`COMPATIBLE_ATCODER_2025`付きでも別scratch pathで実行し、4入口すべて成功。
- `CLANG_MODULE_CACHE_PATH=/tmp/swift-ac-collections-clang-cache swift build --disable-sandbox --package-path Benchmarks -c release`：成功。`benchmark info --tasks`で旧完全title 7件を確認した。
- `swift package --disable-sandbox generate-documentation --target NextPermutationModule --warnings-as-errors`と旧`PermutationModule`：両方成功し、各doccarchiveを生成した。
- `git diff --check`：成功。

SwiftPMのuser cacheがsandboxから書けない警告が出たため、必要なcommandは`--disable-sandbox`を用いた。benchmarkはclang module cacheだけ`/tmp`へ置いた。製品変更に起因する検証失敗は残っていない。

### 未実施・残作業

- remote CI、PR、main到達、性能測定は今回の範囲外として未実施。
- commit、branch作成、push、mergeは行っていない。受入担当の独立照合とユーザーのcommit許可が必要。

以上で担当作業を終了し、割当範囲と作業ツリーの変更を受入担当へ返却する。
