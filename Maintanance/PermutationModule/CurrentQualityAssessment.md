# PermutationModule Current Quality Assessment

## 文書の役割

この文書は、PermutationModuleの現行品質評価taskの詳細正本である。
上位品質要求は`Maintanance/User/QUALITY_REQUIREMENTS.md`、モジュールへの適用と
証拠境界は`Sources/PermutationModule/Documentation/Quality-Profile.md`を正本とする。
本書はそれらを変更せず、現在評価の作業範囲、完了条件、結果を管理する。

## Task

- ID: `PERM-039`
- 種別: `DISCOVERY`
- 担当: Codex
- 現在の中間ゴールへの近さ: `DIRECT`

現在の状態、担当、および再開条件はTask Registryを正本とする。

## 目的

PermutationModuleを最初の適用対象として、上位品質要求QR-01〜QR-06に対する
現行実装の品質を、現在の仕様と独立した証拠に基づいて評価可能な状態にする。

旧評価の判定を引き継がず、各品質主張を次のいずれかへ分類する。

- 確認済み
- 未達
- 未検証
- 対象外
- 受容済みの残余リスク

## 対象

- 通常版の公開API、実装、Test as Specification、documentation comment
- 通常版とAtCoder 2025互換modeの境界
- benchmark対象、継続測定構成、および現在利用できる性能証拠
- SwiftPM、`AcCollections`再公開、他moduleとの共存経路
- CIが実際に扱うtoolchain、platform、build configuration、trait、test
- 現在確認できる安全性、値セマンティクス、寿命、範囲検査の証拠

## 対象外

- 公開契約、性能目標、比較水準、残余リスク許容条件の新規決定
- 未確定事項をagent判断で製品契約へ取り込むこと
- `PERM-002`の実提出確認またはその代行
- `PERM-028`のstrict memory safety再検討の再開
- 発見した不足の実装修正
- Permutation以外のモジュールの品質評価

## 作業

1. QR-01〜QR-06ごとに、評価対象となる品質主張を品質プロファイルから抽出する。
2. 各主張を担当する公開契約、設計契約、Test as Specification、測定、CI構成へ接続する。
3. 証拠の現在性、対象構成、実行結果、反証、証明できる範囲を確認する。
4. 各主張を評価区分へ分類し、VerificationとValidationを分離する。
5. 不足を次の単位へ分ける。
   - 事実確認を続ける`DISCOVERY`
   - ユーザー判断を一つだけ扱う`DECISION`
   - 方針確定後の`EXECUTION`
   - 既存taskへ属する事項
6. 後続候補について必要性と`DIRECT`、`NEAR`、`FAR`、`LATER`、
   `OUTSIDE`の関係を示し、必要なものだけRegistry候補として提示する。

## 成果物

現在評価は本書へ記録する。長い調査ログや再実行用データが必要になった場合は、
本書から参照する別紙へ分離し、同じ判定を重複して正本化しない。

最低限、次を残す。

- 品質主張
- 対応する上位要求
- 仕様の正本
- 証拠と対象構成
- 評価区分
- 根拠
- 反証または未確認範囲
- 残余リスク
- 必要な後続task候補

## 完了条件

- QR-01〜QR-06の各領域について、少なくとも一つの現行評価が記録されている。
- 通常版とAtCoder 2025互換modeの証拠が混同されていない。
- Verificationの結果から競技提出、C/C++級性能、一般Swift採用のValidationを推定していない。
- `PERM-002`と`PERM-028`を開始または代行していない。
- 未達・未検証・判断待ち・実行不足が区別され、一判断一taskの規則で後続候補へ分離されている。
- ユーザーが評価結果と後続候補をレビューできる。
