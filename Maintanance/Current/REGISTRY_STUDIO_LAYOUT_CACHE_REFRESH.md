# Studio配置判断のキャッシュ更新

## TL;DR（人間向け）

受入済みの配置要求と局所接続図を、固定版から姫の判断キャッシュへ反映し、受入・完了した記録。単独の右上維持・複数の下積み・共通オフセットと未決事項を区別する。任意の感想は観察として受領し、新しい常設規則や掃除依頼へ昇格させていない。

Task: OPS-097 / Parent OPS-048.
Author: Astra, 2026-10-18. Formal assignment to 姫.

<a id="入力と範囲"></a>
## Inputs and scope

Fixed commit before update: `b2f9e8e4`. Committed accepted layout changes before assigning the cache update as required.

Read only necessary portions and update your own judgment cache.

- Placement requirements in `Current/TASK_REGISTRY_APP.md`: permanent trees are separate. General tasks with edges go in the diagram; only edge-free tasks are independent. No milestone connection is not the same as no edge.
- Intermediate-milestone placement there and user decision/additional acceptance in `Current/REGISTRY_STUDIO_MILESTONE_BRANCH_LAYOUT.md`: intentionally retain single successors upper-right (launching image); multiple-card stacks below. Share horizontal offset and widen necessary milestone intervals if space is insufficient.
- Final assignment/acceptance in `Current/REGISTRY_STUDIO_NEIGHBOR_CARDS.md`: local diagram connects center and side cards with actual edges. Old three-row card-list proposal is not current.
- Pending: multiple-origin priority undecided; upper/lower choice is a future wish, not assigned. Preserve full-view display of groups without target version; version-specific treatment is a separate decision. Hiding final START→END is separate too. Do not investigate/implement these now.

Briefly retain only judgment, reason, applicability, source and update triggers. Recheck on canonical changes, user placement decisions or reproducible discrepancies; do not revive judgments from old Returns. No source duplication or full-history exploration.

<a id="編集範囲と完了条件"></a>
## Editing scope and completion criteria

Only necessary judgment caches under `Maintanance/Cache/Hime/` and this Return. Cache structure at 姫's discretion; keep Git exclusion. No other owners' caches, product, Registry or canonical changes. Record destination, fixed revision/sections, triggers and pending items in Return. Astra acceptance decides completion. No commit. Hand scope to 姫; Astra awaits Return.

<a id="任意のキャッシュメンテ感想"></a>
## Optional cache-maintenance impressions

Small user-proposed trial. Optional response; leaving it empty does not prevent completion. A separate interview system is undecided.

1. Which caches actually reduced reexploration? Recalled examples suffice.
2. Any confusing, burdensome or stale areas during update?
3. Candidates to retain/merge/discard or better triggers? Proposals only; no out-of-scope cleanup.

## Return（姫記入）

2026-10-18 姫・Opus 5.5。commitなし。正本・Registry・製品・他担当キャッシュは不変。

- 保存先：`Maintanance/Cache/Hime/STUDIO_LAYOUT.md`（新規。Git管理外を`git check-ignore`で確認）。保存・取込の既存キャッシュ`STUDIO_JUDGMENTS.md`とは分け、相互に参照させた。
- 参照した固定版：`b2f9e8e4`。参照した3文書（TASK_REGISTRY_APP.md、REGISTRY_STUDIO_NEIGHBOR_CARDS.md、REGISTRY_STUDIO_MILESTONE_BRANCH_LAYOUT.md）は、作業ツリーでも同版から差分なし。
- 記録した節：
  1. TASK_REGISTRY_APP.md「タスク配置の要求」：辺あり→見取り図、辺なし→独立欄、恒久木は別。未接続と辺なしを混同しない。
  2. 同書「途中マイルストーンから始まるタスク群の配置」と、OPS-096のユーザー判断・追加分受入：単独は右上（送り出し）、複数は下。オフセットは共通、幅不足は必要区間を拡張。
  3. NEIGHBOR_CARDS.mdの局所見取り図の依頼・受入：実辺の局所図。旧3段カード列は現行ではない。
- 更新条件：各項目に記載した。該当正本の変更、ユーザーの配置判断の変更、配置試験（OPS-095 placement、OPS-096 layout、OPS-094 smoke_map）での再現する不一致。古いReturnから判断を復活させないことを冒頭に明記した。
- 保留（探索・実装なし）：複数起点の優先配置、上下選択機能、対象版のない接続群の版別扱い、最終版のSTART→END非表示。

## 任意の感想（姫記入）

1. 減らした例：`STUDIO_JUDGMENTS.md`の「SPIのバッジは登録の後（決着済み）」は、OPS-096でMS-SPI→DOC-027が出てきたとき、順序の議論を掘り返さずに済んだ。
2. 迷った点：同じ件で「初回Return」「追加依頼」「受入」と層が重なっていて、どれが現行かを依頼冒頭の注記（「単独も下」は撤回）で判定した。この注記がなければ重かったと思う。
3. 提案のみ：`CURRENT.md`（10-16時点）は内容が古く、捨てるかまとめる候補。更新契機は「依頼の受入でDONEになったとき」に、該当キャッシュ項目の要否を一行確かめる程度が軽そう。

<a id="astra受入2026-10-18"></a>
## Astra acceptance (2026-10-18)

Inspected STUDIO_LAYOUT.md and compared placement/local-diagram/reasons/applicability/pending items with three specified sources at b2f9e8e4. Sources unchanged since that revision. Confirmed Git exclusion of new layout cache and existing STUDIO_JUDGMENTS.md. Accepted update; assignment closed, awaiting commit.

Received optional impressions as observations: the decided SPI badge order reduced reexploration; current-state note at the assignment start helped; old CURRENT.md is a cleanup candidate; a light DONE-time check was proposed. Do not create standing rules or cleanup assignments from impressions. Preserve the user's no-cleanup-today direction.

2026-10-18: user commit approval makes OPS-097 DONE. Cache remains Git-excluded. In reflection, shared the view that optional impressions with updates may suffice instead of a separate interview.
