# 文書関連マイルストーンへの移行前記録

2026-10-16、ユーザー指示によりDOC-032・RBT-014をマイルストーン管理へ移行。独立taskはEXCLUDED。達成済みとは扱わない。RBT-026に必要な現行API照合は入力条件として保持する。

## 旧行・依存辺

| `DOC-032` | `USER_ONLY` | User | [DISCOVERY] ドキュメントValidation計画ドラフトのレビュー | ユーザーが計画の目的・対象・試行方法・判定境界をレビューし、指摘または修正不要の結果を残すことで完了する。計画の受け入れ・試行開始・既存taskの凍結解除とは分ける。AIは本体の着手・代行・委任・催促を行わず、明示依頼された補助だけを行う | `Maintanance/Current/DOCUMENTATION_VALIDATION_PLAN_DRAFT.md` |

| `RBT-014` | `WAITING_USER` | Codex | RedBlackTree文書workflowと4型outlineのAPI照合 | Permutation、OptionalElementBuffer、ElementBufferの利用者向け文書作業による方式習熟は完了済み。赤黒木の利用者向け文書作業へ進めるというユーザー指示を待ち、その後、workflowと4公開型のoutlineを現在のAPI、test、設計資料へ再照合し、本文作成へ渡せる状態を確認する。状態変更だけでは実作業を開始しない | `Sources/RedBlackTreeCollections/Documentation/Head/DOCUMENTATION_WORKFLOW.md` |

| `RBT-026` | `RBT-014` | `SEQUENCE` | 現行APIとの照合を判断材料として揃えてからMapped Values契約を再判断する |
