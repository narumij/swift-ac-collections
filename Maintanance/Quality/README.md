# 品質資料

2026-10-16、ユーザー指示により品質評価・試験・監査・Validation資料を集約した。

- [0.5.x](0.5.x/README.md)
- [0.6.x](0.6.x/README.md)
- `CrossVersion/`：複数版にまたがる評価、試験計画、監査、利用Validation資料。
- `Unversioned/`：対象release版を確定していない退役記録。日付だけで版を推定しない。

配置は評価合格や全項目完了を意味しない。各文書の対象commit・実行構成・評価日と、現行Registryの状態を確認する。退役・履歴の文書は証拠として保存し、現行の依頼や着手条件として使わない。技術探索・互換移行計画・利用者向け本文は今回移動していない。

## 版共通の正本・参照資料

- [製品品質要求](QUALITY_REQUIREMENTS.md)
- [品質要求の非規範的参照資料](QUALITY_REQUIREMENTS_REFERENCE.md)
- [品質評価棚卸し](QUALITY_ASSESSMENT_INVENTORY.md)

## 資料一覧

- [ElementBufferModule / CurrentQualityAssessment](0.6.x/ElementBufferModule/CurrentQualityAssessment.md)
- [OptionalElementBufferModule / CurrentQualityAssessment](0.6.x/OptionalElementBufferModule/CurrentQualityAssessment.md)
- [RedBlackTreeModule / CurrentQualityAssessment](0.6.x/RedBlackTreeModule/CurrentQualityAssessment.md)
- [ElementBufferModule / ElementBufferAudit](CrossVersion/ElementBufferModule/ElementBufferAudit.md)
- [ElementBufferModule / GeneralSwiftValidationScenario](CrossVersion/ElementBufferModule/GeneralSwiftValidationScenario.md)
- [OptionalElementBufferModule / GeneralSwiftValidationScenario](CrossVersion/OptionalElementBufferModule/GeneralSwiftValidationScenario.md)
- [OptionalElementBufferModule / OptionalElementBufferAudit](CrossVersion/OptionalElementBufferModule/OptionalElementBufferAudit.md)
- [PermutationModule / CurrentQualityAssessment](CrossVersion/PermutationModule/CurrentQualityAssessment.md)
- [PermutationModule / GeneralSwiftValidationScenario](CrossVersion/PermutationModule/GeneralSwiftValidationScenario.md)
- [PermutationModule / RuntimeCheckedPermutationTestPlan](CrossVersion/PermutationModule/RuntimeCheckedPermutationTestPlan.md)
- [PermutationModule / BorrowedPermutationTestPlan](Unversioned/PermutationModule/BorrowedPermutationTestPlan.md)
- [PermutationModule / DocumentationHandoffAudit](Unversioned/PermutationModule/DocumentationHandoffAudit.md)

## 共通の検証・レビュー・公開判定

- [ASAN_DEATH_TEST_INVESTIGATION](ASAN_DEATH_TEST_INVESTIGATION.md)
- [DOCUMENTATION_VALIDATION_PLAN_DRAFT](DOCUMENTATION_VALIDATION_PLAN_DRAFT.md)
- [EXTERNAL_TYPE_EXTENSION_AUDIT](EXTERNAL_TYPE_EXTENSION_AUDIT.md)
- [OPTIONAL_ELEMENTBUFFER_TEST_AS_SPEC_REVIEW](OPTIONAL_ELEMENTBUFFER_TEST_AS_SPEC_REVIEW.md)
- [PERMUTATION_TEST_AS_SPEC_CLAUDE_DRAFT](PERMUTATION_TEST_AS_SPEC_CLAUDE_DRAFT.md)
- [PERMUTATION_TEST_AS_SPEC_REVIEW](PERMUTATION_TEST_AS_SPEC_REVIEW.md)
- [RED_BLACK_TREE_TEST_AS_SPEC_REVIEW](RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md)
- [SPI_REGISTRATION_GATE](SPI_REGISTRATION_GATE.md)
- [StrictMemorySafetyReadiness](StrictMemorySafetyReadiness.md)
- [旧Permutation製品化所見](Unversioned/PermutationModule/ProductReadinessAssessment.md)

ASan調査の再現source・ログは`ASAN_DEATH_TEST_EVIDENCE_2026-10-16/`に同梱する。今回の集約は配置の整理であり、旧評価の継承・退役判定・再試験開始を意味しない。Sources側の品質プロファイル、テスト運用手順、実測データは実装・実行との接続を保つため元の場所を維持する。
