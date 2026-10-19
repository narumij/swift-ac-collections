# QUALITY-004 棚卸しタスク整理

## TL;DR（人間向け）
2026-10-16に品質棚卸しの継続更新を除外し、次の品質試験で改めて行うと決めた記録です。課題の状態や委任は変更しておらず、全完了条件の達成を意味しません。これは当時の管理判断であり、現在の指示ではありません。

On 2026-10-16, the user decided not to keep updating this assessment inventory and to conduct a new inventory during the next quality trial. Candidate follow-up work is marked `EXCLUDED` and removed from remaining work. This does not mean all completion conditions were verified and the task marked `DONE`.

Initial results remain in the [quality assessment materials for this review](../Quality/0.6.0-1/QUALITY_ASSESSMENT_INVENTORY.md). The status and delegation of individual issues are unchanged. Remove the old inventory-completion wait from `RELEASE-078`, but do not skip that task's own review of current delivery scope and evidence. Base the next inventory on that review's target version, implementation, and policy; do not reuse the conclusions from this one.

## 整理前の行と依存辺

| `QUALITY-004` | `PROPOSED` | Codex | [DISCOVERY] 品質評価棚卸し | 四対象の評価・証拠・現行提供区分と既存taskを照合し、残る品質課題、記録不整合、既存taskで扱う範囲と未充当部分を整理する。初期抽出結果は詳細正本へ保存済み。開始時に対象版・範囲・完了条件・必須依存を確認して有効化する。個別課題の解消、公開契約・提供方針の採用、凍結解除は含めない | `Maintanance/Quality/Current/QUALITY_ASSESSMENT_INVENTORY.md` |

| `RELEASE-078` | `QUALITY-004` | `SEQUENCE` | 現行提供区分に照らした品質課題と証拠の棚卸しを揃えてから、0.6.0開始条件と対象候補を再照合する |
