# DOC-034 に効く判断と待ち条件（生成した写し）

入力：`Maintanance/RegistryApp/registry.json`（Registry SHA-256先頭 `9a0b6a42a6a5`、HEAD `94a387a7`）、印 `marks.json`＋試験用 `test_marks.json`

範囲：`DOC-034`自身、直接の前提 1件、下流のゲート・task 13件（下流のゲートに付いた判断もこのtaskへ効く）

## 1. 判断（印から）

### D-2026-10-16-snippet-fixed

- 判断者 User、日付 2026-10-16、対象 MS-060, DOC-034, DOC-035, MS-080, DOC-038, DOC-039
- [fix-count] 0.6.0文書作業では、既存スニペットの構成・掲載数を固定し、追加・削除しない → **置き換え済み（TEST-partial-narrow）**
- [verify] 既存例の現行契約との照合・検証と、誤りの訂正は行う — 有効
- [record] 増減が必要な場合は無断で変更せず記録する — 有効
- [defer] コードスニペット追加と文書全体の再検討は0.8.0へ送る — 有効
- 原文：0.6.0との境界 — Maintanance/Current/RELEASE_0_8_0.md:21（bded81ad3c9c）
- 原文：0.8.0への拡充移管と今回の固定範囲（2026-10-16ユーザー決定） — Maintanance/Current/RELEASE_0_6_0.md:91（4ea61dc2d98d）
- 原文：DOC-034行 — Maintanance/ProgressV2/TASK_REGISTRY_V2.md:40（9a0b6a42a6a5）

### TEST-partial-narrow（試験用の仮想例）

- 判断者 User、日付 2026-10-20、対象 DOC-034
- [fix-count] （仮想）誤りの訂正に伴う1件の差し替えに限り、掲載数を保ったまま入れ替えてよい — 有効
- 原文：試験用 — 試験用（原文なし）

### TEST-unlinked-newer（試験用の仮想例）

- 判断者 User、日付 2026-10-21、対象 DOC-035
- [x] （仮想）0.6.0でもスニペットを1件追加する — 有効
- 原文：試験用 — 試験用（原文なし）

## 2. 矛盾候補（置き換え関係の記載がない、同じ話題の新旧）

- TEST-unlinked-newer と D-2026-10-16-snippet-fixed（話題：0.6.0の既存スニペット）。新しい日付だけで旧判断を失効させない。原文で関係を確かめる
- TEST-unlinked-newer と TEST-partial-narrow（話題：0.6.0の既存スニペット）。新しい日付だけで旧判断を失効させない。原文で関係を確かめる

## 3. 待ち条件（Registryから。判断の有無は推測しない）

**作業・到達待ち（ACTIVE）**

- DOC-033 [ACTIVE] [DISCOVERY] 赤黒木4型アウトラインと現行契約の照合 — 辺 `DOC-033 → DOC-034`（SEQUENCE）

