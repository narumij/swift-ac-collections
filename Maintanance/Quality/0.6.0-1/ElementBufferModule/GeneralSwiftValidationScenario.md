# ElementBuffer利用Validation scenario

## TL;DR（人間向け）
ElementBufferの利用可能性を、repository外のconsumer検証、利用者の理解検証、競技利用検証の三つに分けて設計し、各方法の証拠範囲と非代替関係を定めた。Scenario Aは2026-10-13の固定環境で実行済みで、Scenario B・Cや一般品質の判定は未実施である。

これはシナリオ設計と一つの実行結果を保存した記録であり、後続シナリオの実施指示や公開判断ではない。記録された成功は、固定環境でのconsumer操作だけを裏付ける。

> **文書状態:** scenario設計とScenario Aの実行記録。Scenario B・C、製品品質判定、公開判断の実施記録ではない。
>
> 本書は`ElementBuffer`の利用可能性と理解可能性を、既存の実装・仕様testとは異なる経路で観測するための
> 実行候補を分離する。外部接触、fixtureの恒久化、性能水準、公開契約、および採否は決定しない。

## 1. 目的

The existing Test as Specification directly checks initialization, coordinate access, element lifetime, bounds failures, and borrowed-reference lifetime. It does not by itself establish:

- Whether a Swift Package user outside the repository can add the module and build representative uses with only the public API.
- Whether users can understand the type's purpose, coordinate order, `indices`, value access, borrowed references, and availability from user documentation.
- Whether it is useful as a fixed-shape buffer with contiguous storage for real competitive-programming problems.

Do not collapse these into a single claim of successful use. Separate reproducible consumer Verification, unprompted comprehension Validation, and competitive-use Validation.

## 2. 共通境界

### 入力正本

- Public surface and implementation: `Sources/ElementBufferModule/ElementBuffer.swift`
- Observable specification: `Tests/ElementBufferModuleTests/`
- User-facing explanation: `Maintanance/UserDocuments/ElementBufferModule/UserDocumentationDraft.md`
- Quality and evidence boundaries: `Maintanance/Quality/Profiles/ElementBufferModule.md`
- Current assessment: `Maintanance/Quality/0.6.0-1/ElementBufferModule/CurrentQualityAssessment.md`

### 固定する情報

Record at least the candidate commit, Swift version, OS, architecture, build configuration, import path, exact command, and exit status. If performance or memory is evaluated, also fix the workload, input size, measurement method, and comparison target.

### 共通の非目標

- Reimplementing Test as Specification merely to increase the test count.
- Claiming support for every platform, toolchain, element type, or input size from one successful run.
- Evaluating `ElementBuffer` as a general replacement for standard `Array` or `Collection`.
- Inferring guarantees for `@unchecked Sendable`, unsynchronized concurrent access, or `-Ounchecked`.
- Accepting a performance ratio against C++ or alternative Swift structures based only on this scenario.

## 3. Scenario A — repository外consumer Verification

### 問い

Can an independent SwiftPM consumer that depends on a fixed candidate build and run using only the public surface, without relying on repository-internal test helpers?

### 実行単位

#### A-1. module直接import

Import `BareArrayModule` directly and:

1. Initialize each one- through four-dimensional type with a representative asymmetric shape.
2. Change one coordinate with `setElement`, then check that element and neighboring coordinates with `element`.
3. In two or three dimensions, iterate `indices` as the outermost axis and compute a checksum over all slots.
4. Check that a zero dimension does not call the element-generation closure and produces an empty outermost axis.

#### A-2. facade import

Import only `AcCollections` and reproduce the representative two-dimensional operations from A-1. Do not treat success with a direct module import as evidence that the facade reexports it.

#### A-3. package共存

Import another module from the same package in the consumer and check for conflicts in name resolution, dependency resolution, or build. Do not assess the other module's functional quality.

#### A-4. `MutableRef`提供経路

Only in an environment meeting Swift 6.4 and Apple OS 27 or later, obtain `reference(at:)` from a mutable owner, change `value` several times in the same scope, and check that the owner storage reflects the changes. Keep this separate from value-access consumer checks; do not combine failure to meet this environment with general installation failure.

### 記録する結果

- Dependency-resolution, build, and run outcomes with exact commands.
- The resolved package revision and toolchain information.
- Separate outcomes for direct import, facade, coexistence, and `MutableRef`.
- Warnings, skips, missing environment requirements, and required source changes.
- Confirmation that no repository-internal fixture was required.

### 判定境界

Success in every unit shows only that the installation paths were verified for the fixed environment and operations. It does not establish API comprehensibility, competitive usefulness, performance, or concurrent-use safety. Whether to retain the fixture in the repository is a separate decision from the run results.

## 4. Scenario B — 利用理解Validation

### 対象者

Assume Swift users who did not participate in the design or writing of `ElementBuffer`. The user selects and contacts actual participants. Basic familiarity with generics, value semantics, and SwiftPM may be assumed, but reading a raw-pointer implementation is not required.

### 提示物

- The user-facing text in `Maintanance/UserDocuments/ElementBufferModule/UserDocumentationDraft.md`.
- The candidate's public declarations or the API reference generated from them.

Do not initially provide the quality assessment, internal tests, worked solutions, or extra explanation of design intent. If additional explanations are given in response to questions, record them as prompting.

### 無誘導課題

1. Create a 3×2 integer table, change only coordinate `(2, 1)`, and read the value back.
2. Explain which two inner axes the user must supply when iterating a 3D buffer using `indices`.
3. Choose between value access and `MutableRef` for a one-time replacement and repeated changes within a scope, and explain why.
4. Explain whether a `MutableRef` can be saved beyond the owner's scope.
5. Explain what remains available on an older toolchain or Apple OS earlier than 27.
6. Explain whether `ElementBuffer` can replace standard `Array`, `Collection`, or presence-tracked storage.
7. Explain what “O(1)” tells them and what remains unknown about wall-clock time.

### 観測分類

Classify each task as:

- Correctly completed from the documentation alone.
- Completed after consulting public declarations.
- Completed after additional explanation.
- Completed with a misunderstanding, or not completed.
- Required information is absent, contradictory, or inaccessible in the documentation.

Also record time spent, questions asked, sections revisited, incorrect hypotheses, and self-corrections. Do not use these observations to rate an individual user's ability; distinguish friction in the documentation, API, or task design.

### 判定境界

Do not generalize one person's success or failure to all users. A discovered misunderstanding does not by itself establish whether the API or documentation caused it. Separate reproducible friction into documentation, public-contract, API, availability-explanation, or task-design issues.

## 5. Scenario C — 競技利用Validation

### 問い

Using copy-and-pasteable source or an authorized installation path, can a real problem requiring fixed-shape multidimensional storage be completed with correctness, runtime, and memory use recorded?

### 実行候補

1. Select one known two- or three-dimensional dynamic-programming problem that requires an asymmetric shape and a full-slot traversal.
2. Fix the problem, judge, language version, submitted source, and input constraints.
3. Separate the reason for using `ElementBuffer` from a control solution using standard nested arrays or another structure.
4. Record judge results, not only sample results.
5. Save judge-reported runtime and memory use, but do not treat a single measurement as a general performance guarantee.

### 判定境界

A correct answer is Validation evidence for that problem and submission environment, not proof of the API's overall correctness or C++-level performance. For a wrong answer, TLE, or MLE, do not conclude product unsuitability until usage error, algorithm, installation path, implementation, performance, and environment have been distinguished. Problem selection and external submission require the user's decision and are not initiated by this scenario design.

## 6. Scenario間の非代替関係

- A successful consumer build does not show that a new reader can understand the documentation.
- A successful comprehension task does not show that dependencies and availability work outside the repository.
- A correct competitive-programming submission does not show that the package can be installed as a general Swift Package.
- Green performance CI does not show external comparison, usefulness on real problems, or absolute performance.
- Compiler rejection of a borrowed escape does not show semantic safety for concurrent use, including `@unchecked Sendable`.

## 7. 後続実行候補

### 独立SwiftPM consumer Verification

- 種別: `EXECUTION`
- 担当候補: Codex
- 前提: candidate revisionと実行環境を固定する。
- 成果: A-1〜A-4の再現command、結果、環境、未確認範囲。
- 含めないもの: fixture恒久化、API変更、一般利用Validation、製品採否。

### 利用理解Validation試行

- 種別: `EXECUTION`
- 担当候補: User / Codex
- 前提: ユーザーが参加者と接触可否を決める。
- 成果: 無誘導課題の観測記録、摩擦の分類、後続候補。
- 含めないもの: 参加者評価、単一結果からの一般化、その場でのAPI変更。

### 競技利用Validation試行

- 種別: `EXECUTION`
- 担当候補: User / Codex
- 前提: ユーザーが問題、judge、提出可否を決める。
- 成果: 固定した提出source、結果、時間、メモリ、証拠限界。
- 含めないもの: C++級性能の判定、一般Swift利用への一般化。

## 8. 本設計の完了条件

- consumer Verification、利用理解Validation、競技利用Validationを別の問いとして扱っている。
- value accessと`MutableRef`のtoolchain・OS境界を別の実行単位にしている。
- 代表利用者、提示物、課題、観測分類、保存する証拠、非代替関係を示している。
- 外部接触、提出、fixture恒久化、性能水準、公開契約を決定していない。
- 後続候補が、それぞれ独立に実行・受入できる。

## 9. Scenario A 実行記録（2026-10-13）

### 固定条件

- candidate commit: `693b1bab3ad78240a83a84fe90a4d53cf621cf88`
- consumer: repository外の一時SwiftPM package（repository内fixtureには未保存）
- Swift: Apple Swift 6.4 (`swiftlang-6.4.0.34.1`)
- OS: macOS 27.0.1 (Build 26A434)
- architecture: arm64
- configuration: SwiftPM debug

The consumer package used the candidate worktree as a local-path dependency and placed A-1 through A-4 in separate executable targets. The current package exposes only the `AcCollections` library product, so every target depended on that product. The direct module imports in A-1 and A-3 therefore demonstrate that transitive modules are currently visible through the `AcCollections` product dependency; they do not demonstrate that those modules are offered as independent products.

### 実行結果

- `swift run --disable-sandbox DirectConsumer`: passed (`direct-ok`)
- `swift run --disable-sandbox FacadeConsumer`: passed (`facade-ok`)
- `swift run --disable-sandbox CoexistConsumer`: passed (`coexist-ok`)
- `swift run --disable-sandbox MutableRefConsumer`: passed (`mutable-ref-ok`)

In A-1, the public surface alone was used to check asymmetric shapes in one through four dimensions, coordinate value access, neighboring positions, a two-dimensional checksum, and that a zero dimension does not invoke the generation closure. A-2 imported only `AcCollections` and checked two-dimensional setting and retrieval. A-3 imported `BareArrayModule` and `PermutationModule` together and checked only coexistence in name resolution, dependency resolution, and build. A-4 obtained the standard `MutableRef` from a mutable owner, changed `value` twice within the same scope, and confirmed that the final value `12` was reflected in owner storage.

For multidimensional types, `indices` represents only the outermost axis and the inner-dimension properties are not public, so the consumer retained the shape used during initialization to iterate. The same friction was observed in OptionalArray consumer Verification and is a candidate for Scenario B's assessment of documentation and public-surface comprehensibility. SwiftPM emitted an environment warning that the user cache was not writable, but dependency resolution, build, and run all succeeded.

### 判定

For the fixed environment and candidate, an external consumer successfully installed, built, and ran A-1 through A-4. This did not establish that general users can understand the API without prompting, that the modules are offered as independent products, or anything about other platforms or toolchains, performance, concurrent-use safety, or competitive use. It also did not decide whether to retain the temporary fixture in the repository.
