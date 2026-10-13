# OptionalElementBuffer利用Validation scenario

> **文書状態:** 実行前のscenario設計。Verification、Validation、製品品質判定、公開判断の実施記録ではない。
>
> 本書は`OptionalElementBuffer`の利用可能性と理解可能性を、既存の実装・仕様testとは異なる経路で観測する
> 実行候補を分離する。外部接触、fixtureの恒久化、性能水準、公開契約、および採否は決定しない。

## 1. 目的

現行のTest as Specificationは、初期nil状態、座標access、値・nil遷移、`removeAll()`、要素寿命、停止条件を
直接検証している。一方、それだけでは次を確認できない。

- repository外のSwift Package利用者が、公開APIだけで固定shapeのメモ化bufferを構成できるか。
- 利用者向け文書から、未設定状態、座標順、`indices`、所有、非Collection性、性能境界を理解できるか。
- 競技プログラミングの実問題で、番兵値を必要としないpresence-tracked storageとして役立つか。

これらを一つの「利用できた」にまとめず、consumer Verification、利用理解Validation、競技利用Validationへ分ける。

## 2. 共通境界

### 入力正本

- 公開surfaceと実装: `Sources/OptionalArrayModule/OptionalElementBuffer.swift`
- 観察可能な仕様: `Tests/OptionalArrayModuleTests/`
- 利用者への説明: `Maintanance/OptionalArrayModule/UserDocumentationDraft.md`
- 品質と証拠の境界: `Sources/OptionalArrayModule/Documentation/Quality-Profile.md`
- 現在評価: `Maintanance/OptionalArrayModule/CurrentQualityAssessment.md`

### 固定する情報

各実行ではcandidate commit、Swift version、OS、architecture、build configuration、import経路、実行command、
終了statusを残す。性能やメモリを扱う場合は、workload、入力規模、測定方法、比較対象も固定する。

### 共通の非目標

- 既存の仕様testをrepository外で再実装すること。
- 一回の成功から全platform、全toolchain、全要素型、全入力規模の適合を主張すること。
- 標準`Array`、`Collection`、一般的なcache、または任意shapeの動的containerとして評価すること。
- `@unchecked Sendable`、無同期の並行access、`-Ounchecked`の保証を推定すること。
- C++番兵方式またはSwift代替構造との性能比を、このscenarioだけで受け入れること。
- 凍結中の次元名、性能水準、外部assessmentを再開すること。

## 3. Scenario A — repository外consumer Verification

### 問い

固定したcandidateを依存に持つ独立SwiftPM consumerが、repository内部のtest helperに依存せず、公開surfaceだけで
build・実行できるか。

### 実行単位

#### A-1. module直接import

`OptionalArrayModule`を直接importし、次を実行する。

1. 1D〜4Dを代表的な非対称shapeで初期化し、選択位置がすべて`nil`であることを確認する。
2. 2Dまたは3Dで一座標だけを設定し、対象値と隣接座標の未設定状態を確認する。
3. 同じ座標を別値へ置換し、続けて`nil`へ戻して再設定できることを確認する。
4. `indices`を最外軸として全slotを反復し、設定済み値だけからchecksumを得る。
5. `removeAll()`後に全slotが未設定となり、同じshapeを再利用できることを確認する。
6. zero dimensionで空の最外軸になることを確認する。

#### A-2. facade import

`AcCollections`だけをimportし、A-1のうち2Dの初期化、nil判定、設定、取得、`removeAll()`を再現する。
直接module成功をfacade再公開の証拠へ読み替えない。

#### A-3. package共存

consumerから同一packageの別moduleもimportし、名前解決、dependency解決、buildに衝突がないことを確認する。
別moduleの機能品質は評価しない。

### 記録する結果

- dependency resolution、build、runの成否と完全なcommand。
- 実際に解決されたpackage revisionとtoolchain情報。
- direct import、facade、共存の各結果。
- warning、環境差、source修正の必要性。
- repository内fixtureへ依存していないこと。

### 判定境界

成功は、固定した環境と操作について導入経路をVerificationできたことだけを示す。APIの理解容易性、競技用途の
有用性、性能、並行利用の安全性は示さない。fixtureをrepositoryへ恒久化するかは実行結果と別に判断する。

## 4. Scenario B — 利用理解Validation

### 対象者

`OptionalElementBuffer`の設計と本文作成に参加していないSwift利用者を想定する。実際の参加者選定と接触は
ユーザーが行う。Swiftのgeneric、Optional、SwiftPMの基礎は前提にできるが、raw pointer実装の読解は要求しない。

### 提示物

- `UserDocumentationDraft.md`の利用者向け本文。
- candidateの公開宣言、またはそれを生成したAPI reference。

品質評価、内部test、正解例、設計意図の追加説明は最初に渡さない。追加説明を行った場合は誘導として記録する。

### 無誘導課題

1. 3×2のメモ表を作り、未計算なら値を保存し、計算済みなら既存値を返す処理を書く。
2. 一座標を未設定へ戻す操作と、全座標を未設定へ戻す操作を選び分ける。
3. `removeAll()`後にshapeとstorageを再利用できるか説明する。
4. `indices`を使った3D反復で、利用者が補う必要のある内側2軸を説明する。
5. 要素型の値から番兵を一つ選ぶ方式と、presence mapを持つ本型の意味上の違いを説明する。
6. move-only所有型を暗黙copyできるか、同じinstanceへ無同期に並行accessできるか説明する。
7. `ElementBuffer`、標準`Array`、一般的な`Collection`の代替になるか説明する。
8. 「O(1)」から何が分かり、実時間とC++番兵方式との性能比について何がまだ分からないか説明する。

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

一人の結果を一般利用者全体へ一般化しない。誤解が見つかっても、直ちにAPIまたは本文のどちらかを原因と確定しない。
再現する摩擦を、文書修正、公開契約判断、API判断、環境説明、課題設計の問題へ分離する。

## 5. Scenario C — 競技利用Validation

### 問い

単一fileまたは許可された導入経路を使い、未計算状態を持つ固定shapeの多次元メモ化が必要な実問題を、正答、
実行時間、メモリ使用量を含めて完了できるか。

### 実行候補

1. 既存のEDPC-J／EDPC-Lを候補として、どちらが本型のpresence管理を実際に観測できるか確認して一題を選ぶ。
2. 問題、judge、language version、提出source、入力制約を固定する。
3. compile fixtureの既存コードをそのまま正答済み実装とはみなさず、期待値またはjudgeで結果を確認する。
4. `OptionalElementBuffer`を使う理由と、番兵値やnested Optional配列を使う対照案を分離する。
5. sampleだけでなくjudge結果を記録する。
6. judgeの実行時間とメモリ使用量を保存するが、一回の値を一般性能保証にしない。

### 判定境界

正答はその問題と提出環境におけるValidation証拠であり、API全体の正確性やC++級性能の証明ではない。不正解、
TLE、MLEの場合は、利用誤り、アルゴリズム、導入経路、実装、性能、環境を切り分ける前に製品不適合としない。
問題選定と外部提出はユーザー判断を要するため、本scenario設計からは開始しない。

## 6. Scenario間の非代替関係

- consumerのbuild成功は、本文を初見で理解できることを示さない。
- 利用理解課題の成功は、repository外でdependencyと再公開が成立することを示さない。
- compile済みEDPC例や競技提出の正答は、一般Swift Packageとして導入できることを示さない。
- performance CIのgreenは、外部比較、実問題の有用性、絶対性能を示さない。
- move-onlyと条件付き`@unchecked Sendable`は、同一instanceへの無同期並行accessの安全性を示さない。

## 7. 後続実行候補

### 独立SwiftPM consumer Verification

- 種別: `EXECUTION`
- 担当候補: Codex
- 前提: candidate revisionと実行環境を固定する。
- 成果: A-1〜A-3の再現command、結果、環境、未確認範囲。
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
- nil遷移、`removeAll()`、再利用、座標と`indices`、所有と並行利用、性能説明を観測課題へ接続している。
- 代表利用者、提示物、課題、観測分類、保存する証拠、非代替関係を示している。
- `Sendable`調査、外部接触、提出、fixture恒久化、性能水準、次元名、公開契約を決定していない。
- 後続候補が、それぞれ独立に実行・受入できる。
