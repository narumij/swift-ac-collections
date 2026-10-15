# ElementBuffer利用Validation scenario

> **文書状態:** scenario設計とScenario Aの実行記録。Scenario B・C、製品品質判定、公開判断の実施記録ではない。
>
> 本書は`ElementBuffer`の利用可能性と理解可能性を、既存の実装・仕様testとは異なる経路で観測するための
> 実行候補を分離する。外部接触、fixtureの恒久化、性能水準、公開契約、および採否は決定しない。

## 1. 目的

現行のTest as Specificationは、初期化、座標access、要素寿命、停止条件、借用寿命を直接検証している。
一方、それだけでは次を確認できない。

- repository外のSwift Package利用者が対象moduleを導入し、公開APIだけで代表用途を構成できるか。
- 利用者向け文書から、型の目的、座標順、`indices`、value access、借用参照、提供環境を理解できるか。
- 競技プログラミングの実問題で、連続storageを持つ固定shape bufferとして役立つか。

これらを一つの「利用できた」にまとめず、再現可能なconsumer Verification、無誘導の利用理解Validation、
競技利用Validationへ分ける。

## 2. 共通境界

### 入力正本

- 公開surfaceと実装: `Sources/ElementBufferModule/ElementBuffer.swift`
- 観察可能な仕様: `Tests/ElementBufferModuleTests/`
- 利用者への説明: `Maintanance/UserDocuments/ElementBufferModule/UserDocumentationDraft.md`
- 品質と証拠の境界: `Sources/ElementBufferModule/Documentation/Quality-Profile.md`
- 現在評価: `Maintanance/Quality/0.6.0-1/ElementBufferModule/CurrentQualityAssessment.md`

### 固定する情報

各実行では、少なくともcandidate commit、Swift version、OS、architecture、build configuration、import経路、
実行command、終了statusを残す。性能やメモリを扱う場合は、workload、入力規模、測定方法、比較対象も固定する。

### 共通の非目標

- Test as Specificationを再実装して件数を増やすこと。
- 一回の成功から、全platform、全toolchain、全要素型、全入力規模の適合を主張すること。
- `ElementBuffer`を標準`Array`または`Collection`の一般的な代替として評価すること。
- `@unchecked Sendable`、無同期の並行access、`-Ounchecked`の保証を推定すること。
- C++またはSwift代替構造との性能比を、このscenarioだけで受け入れること。

## 3. Scenario A — repository外consumer Verification

### 問い

固定したcandidateを依存に持つ独立SwiftPM consumerが、repository内部のtest helperに依存せず、公開surfaceだけで
build・実行できるか。

### 実行単位

#### A-1. module直接import

`BareArrayModule`を直接importし、次を実行する。

1. 1D〜4Dの各型を代表的な非対称shapeで初期化する。
2. `setElement`で一座標だけを書き換え、`element`で対象と隣接座標を確認する。
3. 2Dまたは3Dで`indices`を最外軸として反復し、全slotのchecksumを得る。
4. zero dimensionで要素生成closureが呼ばれず、空の最外軸になることを確認する。

#### A-2. facade import

`AcCollections`だけをimportし、A-1のうち2Dの代表操作を再現する。直接module成功をfacade再公開の証拠へ
読み替えない。

#### A-3. package共存

consumerから同一packageの別moduleもimportし、名前解決、dependency解決、buildに衝突がないことを確認する。
別moduleの機能品質は評価しない。

#### A-4. `MutableRef`提供経路

Swift 6.4と対応するApple OS 27以降を満たす環境だけで、可変ownerから`reference(at:)`を取得し、同一scopeで
`value`を複数回変更してowner storageへの反映を確認する。value accessのconsumer確認と別の実行単位にし、
この環境を満たさない失敗を一般導入失敗へまとめない。

### 記録する結果

- dependency resolution、build、runの成否と完全なcommand。
- 実際に解決されたpackage revisionとtoolchain情報。
- direct import、facade、共存、`MutableRef`の各結果。
- warning、skip、環境不足、source修正の必要性。
- repository内fixtureへ依存していないこと。

### 判定境界

全単位の成功は、固定した環境と操作について導入経路をVerificationできたことだけを示す。APIの理解容易性、
競技用途の有用性、性能、並行利用の安全性は示さない。fixtureをrepositoryへ恒久化するかは実行結果と別に判断する。

## 4. Scenario B — 利用理解Validation

### 対象者

`ElementBuffer`の設計と本文作成に参加していないSwift利用者を想定する。実際の参加者選定と接触はユーザーが行う。
Swiftの基本的なgeneric、value semantics、SwiftPMを知ることは前提にできるが、raw pointer実装の読解は要求しない。

### 提示物

- `Maintanance/UserDocuments/ElementBufferModule/UserDocumentationDraft.md`の利用者向け本文。
- candidateの公開宣言、またはそれを生成したAPI reference。

品質評価、内部test、正解例、設計意図の追加説明は最初に渡さない。質問への追加説明を行った場合は、その内容を
誘導として記録する。

### 無誘導課題

1. 3×2の整数表を作り、座標`(2, 1)`だけを書き換えて読み戻す。
2. `indices`を使って3D bufferを反復するloopのうち、利用者が補う必要のある内側2軸を説明する。
3. value accessと`MutableRef`のどちらを、一回の置換とscope内の反復変更へ使うか選び、理由を述べる。
4. `MutableRef`をowner外へ保存する案が成立するか説明する。
5. 旧toolchainまたはApple OS 27未満で利用できる範囲を説明する。
6. `ElementBuffer`が標準`Array`、`Collection`、presence-tracked storageの代替になるか説明する。
7. 「O(1)」から何が分かり、実時間について何がまだ分からないか説明する。

### 観測分類

各課題を次へ分類する。

- 本文だけで正しく完了した。
- 公開宣言の参照後に完了した。
- 追加説明後に完了した。
- 誤解したまま完了した、または完了できなかった。
- 本文に必要情報がない、矛盾する、または情報へ到達できない。

所要時間、質問箇所、読み戻した節、誤った仮説、自己訂正も記録する。利用者本人の能力評価には用いず、本文、API、
課題設定のどこに摩擦があるかを分ける。

### 判定境界

一人の成功や失敗を一般利用者全体へ一般化しない。誤解が見つかった場合も、直ちにAPIまたは本文のどちらかを原因と
確定しない。再現する摩擦を、文書修正、公開契約判断、API判断、環境説明、課題設計の問題へ分離する。

## 5. Scenario C — 競技利用Validation

### 問い

copy & paste可能なsourceまたは許可された導入経路を使い、固定shapeの多次元storageが必要な実問題を、正答、
実行時間、メモリ使用量を含めて完了できるか。

### 実行候補

1. 2Dまたは3Dの動的計画法で、非対称shapeと全slot走査を必要とする既知問題を一つ選ぶ。
2. 問題、judge、language version、提出source、入力制約を固定する。
3. `ElementBuffer`を使う理由と、標準の入れ子配列等を使う対照案を分離する。
4. sampleだけでなくjudge結果を記録する。
5. judgeが示す実行時間とメモリ使用量を保存するが、一回の値を一般性能保証にしない。

### 判定境界

正答はその問題と提出環境におけるValidation証拠であり、API全体の正確性やC++級性能の証明ではない。不正解、
TLE、MLEの場合は、利用誤り、アルゴリズム、導入経路、実装、性能、環境を切り分ける前に製品不適合としない。
問題選定と外部提出はユーザー判断を要するため、本scenario設計からは開始しない。

## 6. Scenario間の非代替関係

- consumerのbuild成功は、本文を初見で理解できることを示さない。
- 利用理解課題の成功は、repository外でdependencyとavailabilityが成立することを示さない。
- 競技提出の正答は、一般Swift Packageとして導入できることを示さない。
- performance CIのgreenは、外部比較、実問題の有用性、絶対性能を示さない。
- compilerによる借用escape拒否は、`@unchecked Sendable`を含む並行利用の意味的安全性を示さない。

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

consumer packageはlocal path dependencyとしてcandidate worktreeを参照し、A-1〜A-4を別々のexecutable targetにした。
現行packageが公開するlibrary productは`AcCollections`だけなので、全targetは同productへ依存した。
A-1とA-3の直接module importは、独立productとしての提供ではなく、`AcCollections` productへの依存から
transitive moduleが現在見えることの証拠である。

### 実行結果

- `swift run --disable-sandbox DirectConsumer`: 成功（`direct-ok`）
- `swift run --disable-sandbox FacadeConsumer`: 成功（`facade-ok`）
- `swift run --disable-sandbox CoexistConsumer`: 成功（`coexist-ok`）
- `swift run --disable-sandbox MutableRefConsumer`: 成功（`mutable-ref-ok`）

A-1では1D〜4Dの非対称shape、座標value access、隣接位置、2D checksum、zero dimensionで生成closureが
呼ばれないことを公開surfaceだけで確認した。A-2では`AcCollections`だけをimportして2Dの設定・取得を確認した。
A-3では`BareArrayModule`と`PermutationModule`を同時にimportし、名前解決・dependency解決・buildの共存だけを
確認した。A-4では可変ownerから標準`MutableRef`を取得し、同一scopeで`value`を2回変更してowner storageへ
最終値`12`が反映されることを確認した。

多次元型の`indices`は最外軸だけを表し、内側寸法propertyはpublicではないため、consumerは初期化時のshapeを
保持して反復した。OptionalArrayのconsumer Verificationでも同じ摩擦を観測しており、Scenario Bで本文と
公開surfaceの理解可能性を観測する対象とする。SwiftPM user cacheが書込み不可という環境warningは出たが、
dependency resolution、build、runはいずれも成功した。

### 判定

固定した環境とcandidateについて、repository外consumerによるA-1〜A-4の導入・build・実行を確認した。
一般利用者が無誘導で理解できること、独立module productとして提供されること、他platform・toolchain、性能、
並行利用安全性、競技利用は確認していない。一時fixtureのrepositoryへの恒久化も決定しない。
