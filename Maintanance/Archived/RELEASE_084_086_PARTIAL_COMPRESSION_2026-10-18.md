# RELEASE-084 / RELEASE-086 部分圧縮

2026-10-18 Astra。ユーザーがこの2件の部分圧縮と未解決分の整理を指示。RELEASE-084はDONEを維持、RELEASE-086はEXCLUDED（不要整理、完了認定ではない）として現役表から外す。085・087は今回の整理対象外。以下は変更前の原文であり、現行指示ではない。

## Registryの原文

元：Maintanance/ProgressV2/TASK_REGISTRY_V2.md。task行、precedence行（後続・前提・Flow・条件）、マイルストーン接続行を原順で保存。

| `RELEASE-084` | `DONE` | Claude（姫：実装・検証） / Astra（受入） | [EXECUTION] 候補CIの比較元対応の限定修正 | 2026-10-17 Astra受入済み。現行baseline 0.5.4で欠落・契約差が解消しworkflow修正不要。保存証拠とコード同一性を確認。ユーザーが証拠・受入記録のcommitを承認し、限定依頼は完了。Ubuntu CI実走成功・リリース可否は未認定。将来の恒久対策はRELEASE-085/086。 | `Maintanance/Current/RELEASE_CANDIDATE_BASELINE_FIX.md` |
| `RELEASE-086` | `PROPOSED` | Astra | [EXECUTION] 立て直しプラン作成 | RELEASE-085の範囲決定後に工程・担当・検証・停止条件を計画化。既存RELEASE-084を再利用し、実装は別依頼。 | `Maintanance/Current/RELEASE_CI_RECOVERY.md` |
| `RELEASE-086` | `RELEASE-085` | `SEQUENCE` | ユーザーが立て直し範囲を決めてから計画化する |
| `RELEASE-084` | `RELEASE-086` | `PARALLEL_JOIN` | 2026-10-17の限定再依頼は先行可。立て直し全体に関わる追加方針・範囲は確定プランと合流してから実施し、未決の比較除外・閾値変更は行わない |
| `RELEASE-087` | `RELEASE-086` | `SEQUENCE` | 計画は必要入力。実行証拠も必須であり計画完成だけではゲートを通過しない |
| `RELEASE-084` | `END-0.5.4` | この到達点の前に完了が必要。2026-10-17ユーザー指定。候補CIの限定修正・検証結果をEND-0.5.4へ合流する。未決方針やCI実走の未確認を完了扱いにしない。 |

## 立て直し正本の変更前全文

元：Maintanance/Current/RELEASE_CI_RECOVERY.md

# 候補CI・性能比較の立て直し

2026-10-16 / 作成Astra / ユーザー指定。立て直しをマイルストーンとして管理する。今回の登録は実装開始・完了認定ではない。0.5.4後へ送る判断を維持し、0.5.4の追加ゲートにはしない。対象版（0.6.1等）はまだ決めない。

## 到達点

候補CIの比較元・測定契約・未比較項目の扱いを明確にし、合意した範囲で実行証拠を揃え、ユーザーが立て直し完了と判断できる状態にする。

## 工程

1. RELEASE-085：立て直し協議。最新release tagと通常CIのbaselineの違い、新規測定の追加、Permutationの契約切替を材料に、何を今回の立て直し範囲とするかユーザーが決める。候補は比較可能性・未比較の明示・変更時の移行確認。新しい性能目標や公開契約は自動的に加えない。
2. RELEASE-086：立て直しプラン。協議で確定した範囲について、作業順・担当・比較元・検証方法・停止条件・完了証拠・必要なユーザー操作を具体化する。計画で新しい方針判断が必要になれば協議へ戻す。実装は別の実行依頼。
3. 計画に従い、必要な実行・検証taskを具体化する。RELEASE-084は既存の限定修正として再利用・見直しし、同じ修正を重複採番しない。PERM-080は性能改善の提案であり、立て直しの必須条件にはまだ含めない。ASanのRBT-049も自動的に混ぜない。
4. RELEASE-087：立て直し完了ゲート。確定範囲の実行証拠、比較不能項目、残課題と引受判断を確認し、ユーザーが完了可否を決める。計画の完成だけでは通過しない。実行taskとの依存は計画確定時に追加する。

RELEASE-085の範囲決定を受けてRELEASE-086を作成し、その計画と後続実行の証拠をRELEASE-087へ渡す。
RELEASE-087の完了可判断を、立て直しマイルストーンの到達条件とする。

## 入力と現状

RELEASE_CANDIDATE_BASELINE_FIX.mdの停止報告と後送判断、RELEASE_CANDIDATE_BASELINE_INVESTIGATION.md、PERFORMANCE_CI_CHANGE_GUIDE.md。比較元8件欠落とPermutation 3件の契約差は切り分ける。0.5.4の赤を引き受けた判断は、将来の恒久的な不合格許容ではない。

今回3件をPROPOSEDで登録。0.5.4後に協議する時点で範囲を確認し有効化する。まだ発注・修正・CI起動はしない。

AI用作業記憶：../Cache/Astra/RELEASE_CI_RECOVERY.md（Git管理外。不在時は本書とRegistryの該当行から復元）。

## 2026-10-17の限定再依頼

ユーザーがCIの修正依頼作成を指示。RELEASE-084について、現行baseline確認と既決範囲の修正・限定検証を先行してClaudeへ依頼した。今回範囲は0.5.4完了・RELEASE-086確定を待たない。比較除外・閾値・baseline選択規則の未決判断を代行せず、必要なら協議へ返す。RELEASE-085〜087はPROPOSEDを維持し、全工程の有効化・完了とはしない。現行依頼と返却先は[RELEASE-084正本](../Current/RELEASE_CANDIDATE_BASELINE_FIX.md)末尾。
