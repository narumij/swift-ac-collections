# 品質資料

2026-10-16、ユーザー指示により品質評価・試験・監査・Validation資料を集約した。

## 一周分をまとめて保存する運用

2026-10-16、ユーザーと確認した運用。品質試験の資料は文書ごとの対象版で分類するのではなく、**品質確認一周分をまとめ、後から一括で移せるようにする**。

```text
Quality/
├── CONCEPT_DEFINITION.md
├── QUALITY_REQUIREMENTS.md
├── QUALITY_REQUIREMENTS_REFERENCE.md
├── Profiles/  # モジュール別の継続的な品質プロファイル
├── Current/   # 次回用。現在は空（.gitkeepのみ）
└── 0.6.0-1/   # 今回までの品質確認一式を保存
```

- `Quality/Current/`に、今回の評価・監査・試験計画・実行結果・証拠・残課題の引継ぎをまとめる。
- 次の品質試験を開始するときに、前回の対象範囲と引継ぎを確認し、その一式を`<対象バージョン>-<回数>/`へまとめて移す。例：`0.6.0-1/`、`0.6.0-2/`。回数は対象バージョンごとに1から始め、同じ版で修正・再試験した一周分も別の番号で保存する。既存の保存分は上書きせず、使用済み番号は再利用しない。
- 試験が一周した後も、そこで出た課題への対応・再確認は同じ一式に残す。次回開始時に前回分を保存し、未解決課題を元記録への参照付きで引き継いで、`Quality/Current/`を新しい一周用に切り替える。棚卸しも次回の対象版から改めて行う。過去の証拠は参照できるが、過去の判定を新しい対象版の判定へ自動的に引き継がない。
- 継続して使う品質要求・共通資料は`Quality/`直下に置く。文書内に複数版の話があることだけを理由に、一周分の資料を分散させない。
- 一周を保存することは、全項目の合格・全残課題の解消を意味しない。対象commit・構成・評価日・未確認事項と、次へ引き継ぐ仕事を残し、参照元を移動先へ更新する。

## Currentで一周分を育てる

2026-10-16、ユーザーと確認。`Quality/Current/`には、次の一周の準備から実施、結果までを積み重ねる。段階が進むたびに前の資料を置き換えず、判断と証拠の経緯を一式として残す。

| 段階 | 入れる資料 |
| --- | --- |
| 準備中 | 計画、評価対象、前回から引き継ぐ課題、サルベージした資料 |
| 実施中 | 実行記録、測定値、ログなどのエビデンス |
| 実施後 | 評価結果、判定、残課題と次回への引継ぎ |

サルベージした資料は、出典・元の対象版・未確認事項を残す。持ち込んだ時点では参考資料であり、今回の証拠として使えるかは改めて確かめる。配置しただけで旧計画を実行許可や今回の判定へ引き継がない。

棚卸しも、その一周で何を確認し、何が残ったかの記録として一式に含める。今回までの[品質評価棚卸し](0.6.0-1/QUALITY_ASSESSMENT_INVENTORY.md)は、ユーザー判断により`0.6.0-1/`に保存する。次回はこれを参考にしつつ、`Current/`に新しい棚卸しを作り、前回の結果を上書きせず今回の状態を確認する。

## 現在の配置

2026-10-16、ユーザーが保存先を`0.6.0-1/`と指定し、現在の一式の移動と空の`Current/`の作成を指示した。この判断に従って保存した。判断の記録は[Release 0.6.0](../Milestones/_Archived/RELEASE_0_6_0.md#品質資料の保存に関するユーザー判断-2026-10-16)に置く。`Current/`にはGitで空の配置を保持するための`.gitkeep`だけを置く。次回試験の開始を意味しない。

`0.6.0-1/`は過去の評価・試行・証拠の保存先であり、収録資料すべてが0.6.0を対象に実測済みという意味ではない。各資料の対象版・commit・確認範囲を保持する。保存資料の旧指示・状態・判定を現行へ復活させず、全項目合格・残課題解消とも扱わない。現在の仕事はTask Registryで確認し、次回の計画と評価は`Quality/Current/`に改めて作る。

## 現在の正本・参照資料

- [製品コンセプト](CONCEPT_DEFINITION.md)：ユーザー専有の最上位正本。2026-10-16、ユーザー指示でQuality直下へ移動。配置変更によって内容の編集権限は変わらない。
- [製品品質要求](QUALITY_REQUIREMENTS.md)
- [品質要求の非規範的参照資料](QUALITY_REQUIREMENTS_REFERENCE.md)
- [前回の品質評価棚卸し（保存記録）](0.6.0-1/QUALITY_ASSESSMENT_INVENTORY.md)

## モジュール別の品質プロファイル

2026-10-16、ユーザー指示でSources側から集約した。継続的な品質基準・境界と仕様・証拠の接続先を扱い、一周ごとの試験結果とは分けて保持する。配置変更によって要求や品質判定は変更しない。

- [OptionalElementBufferModule](Profiles/OptionalElementBufferModule.md)
- [RedBlackTreeCollections](Profiles/RedBlackTreeCollections.md)
- [NextPermutationModule](Profiles/NextPermutationModule.md)
- [ElementBufferModule](Profiles/ElementBufferModule.md)

## 保存した資料一覧

- [ElementBufferModule / CurrentQualityAssessment](0.6.0-1/ElementBufferModule/CurrentQualityAssessment.md)
- [OptionalElementBufferModule / CurrentQualityAssessment](0.6.0-1/OptionalElementBufferModule/CurrentQualityAssessment.md)
- [RedBlackTreeModule / CurrentQualityAssessment](0.6.0-1/RedBlackTreeModule/CurrentQualityAssessment.md)
- [ElementBufferModule / ElementBufferAudit](0.6.0-1/ElementBufferModule/ElementBufferAudit.md)
- [ElementBufferModule / GeneralSwiftValidationScenario](0.6.0-1/ElementBufferModule/GeneralSwiftValidationScenario.md)
- [OptionalElementBufferModule / GeneralSwiftValidationScenario](0.6.0-1/OptionalElementBufferModule/GeneralSwiftValidationScenario.md)
- [OptionalElementBufferModule / OptionalElementBufferAudit](0.6.0-1/OptionalElementBufferModule/OptionalElementBufferAudit.md)
- [PermutationModule / CurrentQualityAssessment](0.6.0-1/PermutationModule/CurrentQualityAssessment.md)
- [PermutationModule / GeneralSwiftValidationScenario](0.6.0-1/PermutationModule/GeneralSwiftValidationScenario.md)
- [PermutationModule / RuntimeCheckedPermutationTestPlan](0.6.0-1/PermutationModule/RuntimeCheckedPermutationTestPlan.md)
- [PermutationModule / BorrowedPermutationTestPlan](0.6.0-1/PermutationModule/BorrowedPermutationTestPlan.md)
- [PermutationModule / DocumentationHandoffAudit](0.6.0-1/PermutationModule/DocumentationHandoffAudit.md)

## 関連する作業文書と保存済みレビュー

- [ASAN_DEATH_TEST_INVESTIGATION](../Current/ASAN_DEATH_TEST_INVESTIGATION.md)
- [DOCUMENTATION_VALIDATION_PLAN_DRAFT](../UserDocuments/DOCUMENTATION_VALIDATION_PLAN_DRAFT.md)
- [EXTERNAL_TYPE_EXTENSION_AUDIT](../Current/EXTERNAL_TYPE_EXTENSION_AUDIT.md)：公開API整理の作業判断を扱うため、品質試験一式の外に配置。
- [OPTIONAL_ELEMENTBUFFER_TEST_AS_SPEC_REVIEW](0.6.0-1/OPTIONAL_ELEMENTBUFFER_TEST_AS_SPEC_REVIEW.md)
- [PERMUTATION_TEST_AS_SPEC_CLAUDE_DRAFT](0.6.0-1/PERMUTATION_TEST_AS_SPEC_CLAUDE_DRAFT.md)
- [PERMUTATION_TEST_AS_SPEC_REVIEW](0.6.0-1/PERMUTATION_TEST_AS_SPEC_REVIEW.md)
- [RED_BLACK_TREE_TEST_AS_SPEC_REVIEW](0.6.0-1/RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md)
- [SPI_REGISTRATION_GATE](../Current/SPI_REGISTRATION_GATE.md)
- [StrictMemorySafetyReadiness](../Current/StrictMemorySafetyReadiness.md)：作業判断・着手条件を持つ品質ゲートのためCurrentに配置。
- [旧Permutation製品化所見](0.6.0-1/PermutationModule/ProductReadinessAssessment.md)

ASan調査の再現source・ログは`../Current/ASAN_DEATH_TEST_EVIDENCE_2026-10-16`に同梱する。今回の集約は配置の整理であり、旧評価の継承・退役判定・再試験開始を意味しない。品質プロファイルは`Profiles/`へ集約した。テスト運用手順と実測データは実装・実行との接続を保つため元の場所を維持する。
