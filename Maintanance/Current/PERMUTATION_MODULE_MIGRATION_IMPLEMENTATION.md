# ワーカー依頼：Permutation module移行の実装・ローカル検証

固定ID：`PERM-076`。種別：EXECUTION。担当：Worker Codex（実装1体）。作成者・受入担当：Astra。
基準：`17c7ea72`。2026-10-15のユーザーの進行指示に基づく。Registry登録後に渡す依頼書。

## 目的と入力

[移行計画](PERMUTATION_MODULE_MIGRATION_PLAN.md)のmodule移行を、ローカルで検証可能な一つの差分として返す。
[調査受入](PERMUTATION_MIGRATION_INVESTIGATION_ACCEPTANCE.md)の訂正・補足を先に読む。
新名`NextPermutationModule`が実装と主入口、旧名`PermutationModule`は同じ宣言を再公開する互換入口としてmainに残す。benchmark名の整理は後段へ遅らせる。

## 確定した実施内容

1. `Sources/PermutationModule/`の実装・DocC・設計資料を`Sources/NextPermutationModule/`へ移し、旧名targetは`Sources/_PermutationModule/`の薄い再公開入口にする。`@_exported import NextPermutationModule`を用い、実装を複製しない。
2. `AcCollections` productは維持。facade targetは新旧targetへ依存し、sourceは新名を再公開する。既存settings・compiler条件・通常／2025互換modeの排他を保持する。
3. 通常ownerのgeneric parameterを決定済みの`Element`へ揃える。公開型名・method名・入れ子`Permutation`・契約・アルゴリズムは維持する。
4. 通常testとcompiler fixtureを新主入口へ揃え、旧直接importとfacadeの検査も残す。外部clientで新旧入口の型同一性とextensionの利用を確認する。
5. 新DocC catalogと見出し、旧shimの互換案内、新旧両targetのDocC matrixを揃える。READMEの通常importはAcCollectionsを維持し、新旧の役割を明記する。deprecated指定や廃止期限は加えない。
6. benchmarkのimportだけ新名へ揃える。登録title、library、測定処理、入力・結果の正規化を変更しない。
7. 下記の現行文書の名前・path・互換方針を揃える。過去の実行証拠は当時の名前を保持する。

## 編集できる範囲

- `Package.swift`、`Sources/AcCollections/AcCollections.swift`。
- 旧・新Permutation source directoryと互換shim directory。移動対象内のDocC・設計・品質資料を含む。
- `Tests/PermutationTests/`、`Tests/AcCollectionsTests/`内のPermutation関連検査。
- `Utilities/Maintenance/CompilerDiagnostics/PermutationPublicSurface/`と`Utilities/Maintenance/VerifyPermutationCompilerDiagnostics.sh`。このfixture内に新旧・facade入口の検査を加えてよい。
- `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift`のimportのみ。
- `.github/workflows/ci.yml`のDocC matrixのみ。
- `README.md`・`README.ja.md`のPermutation導入説明。
- `Maintanance/Current/QUALITY_REQUIREMENTS.md`、`QUALITY_ASSESSMENT_INVENTORY.md`、`DOCUMENTATION_CI_PLAN.md`のPermutation現行名・path・互換説明。
- `Maintanance/PermutationModule/CurrentQualityAssessment.md`と`UserDocumentationDraft.md`の同じ範囲。この管理directoryは改名しない。
- 専用返却先の「返却」以下。

範囲外の現行参照が移行で壊れる場合は、そのpathと必要な修正を返す。範囲外を勝手に編集せず、全体完了と報告しない。

## 実行と検証

開始時にHEAD・branch・未コミット差分、Registryの現在状態、関連する局所手順を確認する。基準後の変更があれば影響を確認する。既存の差分を上書きしない。

- 対象のDebug／Releaseテストとcompiler正常・期待拒否検査を実行する。関連するDeath Testも実行数を記録する。
- product AcCollectionsだけに依存する外部clientで、新名・旧名・facadeの三入口、新旧同時import時の型受渡しを確認する。通常modeと2025互換modeを分ける。使用可能なtoolchainの範囲を明記する。
- benchmark release buildと登録task一覧を確認し、旧完全titleが維持されることを確かめる。性能測定自体は今回不要。
- 新旧targetのDocCを生成し、module入口・symbol link・互換案内・診断を確認する。失敗や未実行を成功と扱わない。
- command、toolchain、対象版、件数、終了結果、未実施範囲を残す。既存の成功記録で今回の検証を代用しない。

## 停止条件と対象外

新しい仕様判断、型同一性の不成立、公開契約変更の必要、範囲外の変更が必須と判明したら、途中成果と根拠を残して返す。検査を弱めて通さない。
Registry・採番・依頼書・名称決定・AGENTS・Claude担当領域・他者返却物は編集しない。凍結taskを再開しない。benchmark名変更、性能チューニング、SPI登録、remote CI実行、branch作成、commit、push、mergeは行わない。

## 返却と受入

返却先：[実装結果](PERMUTATION_MODULE_MIGRATION_IMPLEMENTATION_RESULT.md)。変更一覧、検証証拠、未確認・停止点、残作業を記入し、作業を終了して割当範囲を返却したことを明記する。冒頭の管理欄は編集しない。
Astraが原回答を保持して独立照合する。ローカル差分の受入後はコミット許可待ちとし、ユーザー許可と保存確認後にこの実装taskをDONEとする。remote CI・main到達は別の後続段階であり、このtaskのDONEで移行全体を完了扱いにしない。
