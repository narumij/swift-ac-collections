# MS-070 に効く判断と待ち条件（生成した写し）

入力：`Maintanance/RegistryApp/registry.json`（Registry SHA-256先頭 `9a0b6a42a6a5`、HEAD `94a387a7`）、印 `marks.json`

範囲：ゲート`MS-070`の上流 12件（辺の意味を残す）

## 1. 判断（印から）

### D-2026-10-16-snippet-fixed

- 判断者 User、日付 2026-10-16、対象 MS-060, DOC-034, DOC-035, MS-080, DOC-038, DOC-039
- [fix-count] 0.6.0文書作業では、既存スニペットの構成・掲載数を固定し、追加・削除しない — 有効
- [verify] 既存例の現行契約との照合・検証と、誤りの訂正は行う — 有効
- [record] 増減が必要な場合は無断で変更せず記録する — 有効
- [defer] コードスニペット追加と文書全体の再検討は0.8.0へ送る — 有効
- 原文：0.6.0との境界 — Maintanance/Current/RELEASE_0_8_0.md:21（bded81ad3c9c）
- 原文：0.8.0への拡充移管と今回の固定範囲（2026-10-16ユーザー決定） — Maintanance/Current/RELEASE_0_6_0.md:91（4ea61dc2d98d）
- 原文：DOC-034行 — Maintanance/ProgressV2/TASK_REGISTRY_V2.md:40（9a0b6a42a6a5）

## 3. 待ち条件（Registryから。判断の有無は推測しない）

**判断待ち**

- DOC-036 [USER_ONLY] [DECISION] 文書Validation計画の受入判断 — 辺 `DOC-036 → MS-VALIDATION`（required）
- DOC-037 [WAITING_USER] [DECISION] 赤黒木本文の受入判断 — 辺 `DOC-037 → DOC-035`（SEQUENCE）

**ユーザー実作業待ち**

- RELEASE-072 [USER_ONLY] [EXECUTION] 人間向けリリース工程表の作成 — 辺 `RELEASE-072 → MS-070`（required）
- RELEASE-075 [USER_ONLY] [EXECUTION] リリース工程の不足仕様充当 — 辺 `RELEASE-075 → MS-070`（required）
- RELEASE-076 [USER_ONLY] [EXECUTION] リリース工程のValidation & Verifica — 辺 `RELEASE-076 → MS-070`（required）

**材料待ち**

- MS-DOC [到達未確認] 赤黒木の本文作成完了 — 辺 `MS-DOC → MS-060`（material）
- RELEASE-078 [PROPOSED] [DISCOVERY] 0.6.0開始条件と現行提供区分の再照合 — 辺 `RELEASE-078 → MS-060`（material）

**作業・到達待ち（ACTIVE）**

- DOC-033 [ACTIVE] [DISCOVERY] 赤黒木4型アウトラインと現行契約の照合 — 辺 `DOC-033 → DOC-034`（SEQUENCE）
- DOC-034 [ACTIVE] [EXECUTION] 赤黒木4型の本文完成と派生成果の同期 — 辺 `DOC-034 → MS-DOC`（required）
- DOC-035 [ACTIVE] [EXECUTION] 0.6.0全公開対象の文書初版確認 — 辺 `DOC-035 → MS-060`（required）

**作業・到達待ち（到達未確認）**

- MS-060 [到達未確認] 0.6.0 リリース — 辺 `MS-060 → MS-070`（stage）
- MS-VALIDATION [到達未確認] Validation計画レビュー — 辺 `MS-VALIDATION → MS-070`（required）

