# 接続タスクの表示網羅性・排他性試験

## TL;DR（人間向け）

当時の表示排他性を検査し、タスク2件の重複表示を検出して試験・結果記録を完了したもの。辺の独立照合では生成上の取り違え・二重生成は検出せず、最終版ENDへの線が非表示になる点を追加検出した。表示実装は変更せず、後に変わった現行配置要求や実ブラウザ描画の合格を認定する試験ではない。

- Task: OPS-092 (parent OPS-048)
- Written and run by: Astra / 2026-10-18
- Test requirement of the time: a task with connections is shown in exactly one of the map or the independent-task column, except tasks shown in the permanent-task tree.
- Completion condition: prepare a re-runnable test of the requirement and record the result and scope for the current data. Do not treat a failure as a pass. Fixes are requested separately.
- Scope: check formal tasks with connections in the all-versions view. The HEAD-onward view is limited to reproducing QUALITY-005 and DOC-026 this time (it does not newly decide whether excluded versions should be shown). No screen operation.
- Evidence: `Evidence/OPS-092/display-partition.cjs`. It uses the template's actual functions for extracting display targets, placement, the permanent tree and the independent column. It checks up to having a drawing position; it does not guarantee browser drawing itself.

<a id="現行要求への参照"></a>
## Reference to the current requirement

By the user's decision on 2026-10-18, the canonical placement requirement is [permanent task OPS-048 "タスク配置の要求"](TASK_REGISTRY_APP.md#タスク配置の要求). The test results below are the record of their time and are not treated as having verified the placement under the new requirement. From now on, following that section, add a test that sorts general tasks with connections into the map and those without into the independent column. OPS-092's completion is kept.

<a id="実施結果"></a>
## Results

2026-10-18 Astra. Run with base commit ef50c83d, the unchanged index.template.html and the generated registry.json.

- The test's own judgment check: fixtures detecting 0 occurrences (missing) and 2 occurrences (duplicate), and treating 1 occurrence and permanent-tree exclusion as normal, succeeded.
- All-versions view: checked 29 after excluding the permanent tree. DOC-026 and QUALITY-005 are each shown twice. The other 27 are shown once each. No display gaps with 0 occurrences.
- HEAD onward: a regression test limited to these 2 detected 2 occurrences for both.
- Exit code 1 is the result of detecting a requirement violation. The test run is complete; the display requirement is not met.
- The adopted scope of the map's task connected components and the independent column's judgment of connections to arrival points do not agree. Not fixed. Determining the cause of doubled lines or broken layout is outside this test's guarantee.
- Out of this test's scope: tasks without connections not in the permanent tree, tasks intentionally excluded by the version filter, proposal cards, and drawing in a real browser.

Re-run: `node Maintanance/Current/Evidence/OPS-092/display-partition.cjs` (an optional first argument specifies the JSON to check). It does not change states, connections or saved data.

<a id="次へ残すもの"></a>
## What is left for next

This task waits for commit as completion of the test and result record. The display fix refers to this document as an unresolved item of the parent OPS-048 and is handled in the next request. After a fix, the same test checks for a total of 1 occurrence.

<a id="全接続と線生成の追加試験2026-10-18"></a>
## Additional test of all connections and line generation (2026-10-18)

At the user's additional request, also checked that the edges match the canonical. Added `Evidence/OPS-092/edge-audit.cjs`; it ran to completion with exit code 0.

- Read the Registry tables directly with a separate implementation and checked 9 task-to-task edges and 27 milestone-connection edges. Reconstructed 25 skeleton edges from the IDs and placement of the actual Milestones files. The direction and multiplicity of all 61 edges match the JSON. The 36 constraint sentences in the tables also match.
- Folder order was checked numerically for the current placement. The specification of the comparison method itself was not decided.
- The 48 edges after display conversion match graphData. 12 edges are absorbed by aggregating START/END. Separately, one edge START-1.0.0 → END-1.0.0 is not shown: the final version has no next GATE, so END has no display replacement. This matches the conversion implementation; it is not a pass meaning every canonical edge is visible. The 1.0.0-only view also has 0 visible lines. Left as a fix candidate.
- Ran the line-generation part of the actual graph() with an SVG stub. 48 lines in total, 38 from HEAD onward, and per version 0.5.3/0.5.4/0.6.0/0.7.0/0.8.0/0.9.0/1.0.0: 2/4/21/6/2/9/0. One visible line per displayed edge, no duplicates with the same end points or the same path. Each edge also has one transparent click-target path with the same shape as the visible line; this is distinguished from doubled visible lines.
- Adding QUALITY-005 → MS-SPI in memory only gives 1 line for this connection, and the existing QUALITY-005 → DOC-026 also remains. The whole-layout fallback is true. This is not a test that captured the user's unsaved screen state.
- The per-version check verifies that the extracted display targets match line generation. Not guaranteed: an independent specification of whether the version filter selects every needed edge, the meaning of condition sentences and validity of connections, the appearance in a real browser, and line crossings or overlaps with cards.

Conclusion: no mix-ups or double generation of connections in the generated data were detected this time. The known duplicate display of 2 tasks is unresolved. Additionally detected that the line to the final version's virtual END is not shown. The display implementation was not changed.

2026-10-18: by the user's commit approval this task is DONE. The recorded unresolved items and verification scope are unchanged.
