# Sol OJT第2回：検査範囲の説明の補正

## TL;DR（人間向け）

SolのOJT第2回として、倍率操作の再描画確認が実動作試験ではなく文字列検査であることを文書へ補った記録。固定版を作業役と確認役が読み、Astraが最小補正を反映して完了した。コードや試験は変更せず、能力向上・費用低減・Fableへの有効性は実証していない。

OPS-109 / Parent: OPS-103; work area: OPS-048. On 2026-10-18, the user approved the next small practical task with 「こみっとしてつぎやろう」.

The sole target is the explanation of zoom-operation verification in TASK_REGISTRY_APP.md. Clarify the finding from OPS-108: retention across redraws is checked through a string test, rather than a behavioral test. Do not delete previous passing-test records. The worker Sol reads the implementation and verify at fixed revision 9637b62f and returns proposed wording; a separate checker Sol compares it with the evidence; Astra applies it after acceptance. Both roles use gpt-6.1-sol/medium with no inherited history. Only reading and drafting are delegated; Astra performs the edit. No code or test changes, test execution, or screen operations. At most one feedback round trip; do not expand the target independently.

<a id="結果"></a>
## Results

The worker Sol read the fixed revision's record and verify, then returned a proposal to separate 「再描画への適用」 from the old wording into its own sentence. The evidence was script.includes at Maintanance/RegistryApp/verify.cjs:450 and index.template.html:628. The proposal preserved previous passing-test records and made no claim of a rerun in this task.

The checker Sol also read the fixed revision independently and returned an acceptance recommendation for the minimal correction, distinguishing a string test from unverified actual behavior. Astra compared the proposal with the same evidence already checked in OPS-108 and applied it to the relevant paragraph in TASK_REGISTRY_APP.md. No rework was requested. Each role returned once; no code or test changes. Caches consulted: none.

Applied wording (verbatim original):

> 再描画への適用は、ソースに`replaceChildren(s);applyGraphZoom();`が含まれることを文字列一致で検査しており、再描画時の実動作は未確認。

<a id="ならしからの観察"></a>
## Observations since the warm-up

Unlike the previous round, neither role mixed ordinary materials into the cache field. Both were fresh agents with no inherited history, and the assignment explicitly stated the distinction. This is an example of carrying a caution forward in an assignment, not evidence of learning or improved capability. One document correction was completed by specifying the target paragraph, permitted changes, and what must be preserved, then obtaining a working proposal and an independent check. Cost reduction and effectiveness for Fable were not measured.

On 2026-10-18, the user's commit approval made OPS-109 DONE. Stop here.
