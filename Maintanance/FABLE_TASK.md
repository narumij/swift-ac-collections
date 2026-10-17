# Codex-to-Fable Work Request

## 占有権と受渡し

占有権とは、ユーザーの委任に基づき、明示された範囲を、いま自分の判断で変更できる権限である。所有権とは別であり、調整役であることだけでは得られない。以下は担当名に依存せず、依頼する側と引き受ける側のどちらにも適用する。

受け入れ・検収・統合も、ユーザーの委任に基づく代理執行である。委任された範囲と受け入れ条件に従って成果を確認・反映する仕事であり、担当者に委任から独立した受け入れの判断権限を与えるものではない。委任に含まれない判断が必要になった場合は、事実と論点を整理してユーザーへ返す。占有と受け入れ・検収・統合の権限は、いずれも役職や担当名ではなく、ユーザーの委任から生じる。

| 段階 | 占有権の扱い |
| --- | --- |
| 作成中 | 作成者が、任された範囲を変更できる。依頼本文・入力資料・記入先を揃えてから相手へ渡す。 |
| 相手へ渡す | 依頼本文と入力資料は、双方が依存するものとして固定する。相手がまだ着手していなくても、渡した側は一方的に変更できなくなる。 |
| 作業中 | 引き受けた側が、明示された作業範囲・回答欄を変更できる。依頼本文や共有入力まで変更できるわけではなく、渡した側も相手の作業範囲を一方的に変更しない。 |
| 返却 | 引き受けた側は返却範囲の変更を終える。返却物は検収対象として固定され、受け取った側にも自由な書換え権限は生じない。検収・受け入れ・統合と、原回答の編集は区別する。 |
| 再編集 | 対象範囲と担当を明示し、改めて占有権を割り当てる。作業中の範囲を変更する場合は、先に停止を伝え、停止と途中成果を確認してから受け渡し直す。 |

手放した占有権は、相手へ丸ごと移るわけではない。固定されて誰も一方的には変更できない部分と、次の担当が変更できる部分を区別する。依頼後に依頼書を作り足すことや、返却物を受け取っただけで書き換えることはしない。

本書の受入済みの節を履歴へ移す圧縮は、ユーザーの常設の委任として、Fableが都度の確認なしで行ってよい。本文を要約・改変せず`Maintanance/Archived/`の履歴ファイルへ保存し、既存の履歴を上書きせず、本書に保存先へのリンクを残して、原文の保存と参照経路を確認する（移動に伴う相対リンクの調整は可）。未受入・作業中の節、および現在の作業に必要な条件は動かさない。この委任は受入判断やRegistryの変更を含まない。

Status: Bounded assignments only.

Task selection and start authority are defined in the root `CLAUDE.md`. This document records only the current job and
bounded-task execution constraints. Codex integrates returned results, performs Registry acceptance and state updates,
and owns public-document completion. Repository evidence establishes factual correctness; product decisions remain with
the user.

調整役が`FABLE_TASK.md`で依頼する仕事は、事前にTask Registryへ登録し、依頼本文に固定IDを記載する。未登録なら、登録してから依頼する。

Fableが自分の感想・観察を`Maintanance/FABLE_OBSERVATIONS.md`へ追記する常設の委任は、個別依頼の編集対象に同書が含まれていなくても有効とする（同書は未作成。初回記入時にFableが作成する）。都度の確認は不要であり、記入は任意とする。本作業や必要な報告を妨げない範囲で行う。

## Current job status

OPS-044：管理試験は2026-10-17 Astra受入・対象3件の記録統合済み。[評価と補正](Current/FABLE_MANAGEMENT_TRIAL.md)を参照。現在の追加依頼なし。親恒久taskはACTIVEを維持。

ユーザーがFableへ直接依頼した採番前の作業は、[採番待ちqueue](FABLE_PENDING_TASKS.md)に記録する。
この節のjob有無と、queueの未処理記録は区別する。

Use [Progress V2](ProgressV2/PROGRESS_OVERVIEW_V2.md) as the current entry point. Frozen work, remaining tasks,
assignees, dependencies, and restart conditions are recorded in [Task Registry V2](ProgressV2/TASK_REGISTRY_V2.md).
Task rules, numbering, and document authority are defined in [Task Rules V2](ProgressV2/TASK_RULES_V2.md).
Current assignments must follow the current request and explicit delegation, not a Registry assignee name alone.

For the authority of historical records, follow [AGENTS.md — 現在の仕事と正本](../AGENTS.md#現在の仕事と正本).

## 受入済み依頼の履歴

まだない。受入済みの節は、上記の委任に従って`Archived/FABLE_TASK_HISTORY_<日付>.md`へ移し、ここにリンクを残す。

## OPS-044 — Bounded management trial (2026-10-17)

The user approved one trial of pending-entry reconciliation. Follow [the canonical assignment](Current/FABLE_MANAGEMENT_TRIAL.md): CP-20261017-007, CP-20261017-008, and FP-20261017-001 only. Produce an evidence-backed update proposal in its Return section. Do not edit the Registry or queues, allocate IDs, accept your own work, or expand the task. The registered parent is OPS-044 and remains ACTIVE. Assignment complete: the specified output scope is handed to Fable until Return. No commit or external operation is delegated.
