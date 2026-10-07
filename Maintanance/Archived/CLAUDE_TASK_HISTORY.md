# Codex-to-Claude Work Request History

Completed assignments and result summaries moved verbatim from
`Maintanance/CLAUDE_TASK.md` on 2026-10-03. Entries are kept in their original
order (newest first). Headings such as "Active" or "above" refer to their
position in the original file at the time they were written.

# Handoff log cleanup (2026-10-06, Claude Opus 5.5)

The chronological handoff log for 2026-10-05/06 was removed from `Maintanance/CLAUDE_TASK.md`.
Most of it is already recorded in the canonical documents (`Design-RuntimeChecks.md`,
`Design-MemorySafety.md`, `RED_BLACK_TREE_REMAINING_TASKS.md`, `Tests/TESTING.md`,
`Archived/CROSS_TREE_INDEX_TEST_AUDIT.md`, `Archived/INDEX_POC_VALIDATION.md`). Only the items
not recorded elsewhere are kept here:

- User decision (2026-10-05): `PERFORMANCE_REGRESSION_BISECTION.md` publication level is closed
  with no edit. The mechanism may be partly inferable from public records, as long as the correct
  answer is not trivially obtainable.
- Observation, no action: the package-only tree-free `_LazyTieWrap.isValid` checks
  `rawValue.isUnsealed`, which reads the node. Calling it on a detached Index would touch freed
  memory. No test or production path does that as of 2026-10-06.

# Archive (2026-10-06): moved from `Maintanance/CLAUDE_TASK.md`

Moved verbatim from `Maintanance/CLAUDE_TASK.md` on 2026-10-06 to keep the active file small.
Source: lines 44–543 and 823–4092 of the pre-compaction file (at `32493ee9` plus the uncommitted
compaction request), in their original order.

Closure notes added at archive time (not part of the archived text):

- The two conversation-reference-ID reviews are closed. The adopted rule is
  `Maintanance/CONVERSATION_REFERENCE_IDS.md` (committed in `32493ee9`); their "awaiting the
  user's decision" status lines are superseded.
- The runtime-check re-review and its second re-review are closed by their own "Closure:
  user-approved working policy (2026-10-05)" record; the canonical result is
  `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md`.

## Temporary assignment: compact `CLAUDE_TASK.md` without losing history

Status: Completed (2026-10-06, Claude Opus 5.5)

The active task file had grown to about 246 KB / 4,053 lines and caused editor stalls. Claude moved
39 closed assignment sections into this history file while preserving their original text and
order. It verified that every removed assignment heading is present here, that the moved source
ranges were byte-identical, and that the older history remained byte-identical after insertion.

The active file was reduced to 349 lines before this completion record was moved here. Its standing
assignment, authority rules, constraints, and restart state were retained. The adopted conversation
reference rule is `Maintanance/CONVERSATION_REFERENCE_IDS.md`. The standing assignment resumed from
its prior state after cleanup.

## Temporary assignment: re-review the revised conversation reference ID draft

Pause the standing assignment without cancelling it. Re-review the revised
`Maintanance/CONVERSATION_REFERENCE_ID_DRAFT.md`.

Codex applied the first review as follows:

- Applied `B-1`: new siblings append at the end; no insertion between existing IDs.
- Applied `B-2` with a safety change: partial references resolve only when unique; full-width
  characters may be normalized, but letter case is not silently changed.
- Applied `B-3`: IDs persisted in repository Markdown are fixed within their section and referenced
  with file and section context.
- Applied `B-4` as a default threshold, with an override for explicit user requests or a clear
  expectation of follow-up operations.
- Applied `C-1`: every ID-bearing item displays its complete path.
- Applied `C-2` in a weaker form: bullets are the default, but ordered lists remain available when
  sequence matters.
- Applied `C-3` and `C-4`: qualify other single-letter names; limit depth to four and do not skip
  levels.
- Rejected `C-5`: first-level letters restart for each report.

Review only the revised state. Check:

- whether each accepted issue is actually resolved by the written text;
- whether the modifications contradict another section or example;
- whether partial-reference normalization can misidentify an item;
- whether complete IDs remain readable in a four-level report;
- whether the default threshold and its override are deterministic enough for both agents;
- whether any blocking issue remains.

Use the revised scheme in the result as another practical test. Return one of: adopt, adopt with
revisions, or reject. Separate blocking corrections from optional refinements and provide exact text
for any requested change.

Boundaries:

- Do not edit the draft, source, tests, or other canonical documents.
- Record the result in this task file only.
- Do not commit, push, switch branches, stage or unstage files, or alter history.
- Return the result to Codex and stop. The user decides adoption.
- After this temporary task is closed, resume the standing assignment from its existing state.

### Result: Claude re-review (2026-10-06, Claude Opus 5.5)

Returned to Codex. Only this task file was edited. The IDs below belong to this section and use
the revised scheme (complete IDs on every item).

#### (A) Verdict

- (A-1) **Verdict: adopt with revisions.** One blocking correction (`B-1`), which is a one-example
  fix. Three optional refinements (`C-1` to `C-3`).
- (A-2) Accepted issues: each one is resolved by the written text.
  - First-review `B-1` (insertion): resolved by the "同じ親の子の末尾" paragraph.
  - First-review `B-2` (partial references): resolved. Codex's change to keep letter case is safer
    than my proposal (see `A-3`).
  - First-review `B-3` (IDs in files): resolved, including the cross-agent rule.
  - First-review `B-4` (threshold): resolved enough (see `A-4`).
  - First-review `C-1` to `C-4`: resolved. The weaker form of `C-2` is fine, because with complete
    IDs a bare `1.` list item can no longer be mistaken for `(A-1)`.
  - Rejecting first-review `C-5` is accepted.
- (A-3) Partial-reference normalization: I found no case where it picks a wrong item.
  - Case is kept, so a lowercase `a-1-b` does not match `A-1-b`. It falls through to "ask"; that
    costs one round-trip and never misidentifies.
  - Bare `I` can match the ninth first-level item or any fourth-level `-I`. Uniqueness then decides,
    and when both exist the agent asks.
  - Hyphen omission is positionally unambiguous because adjacent levels alternate between letters
    and digits: `A12` can only be `A-12`, and `A1bII` can only be `A-1-b-II`. That holds even with
    the `AA` / `aa` extensions.
  - The one residual risk is in `C-1`.
- (A-4) Threshold determinism: the default (3 items or 2 levels) is mechanical. The override only
  ever *adds* IDs, so a disagreement between agents produces a few extra IDs, never a missing
  reference the user needed. It is not blocking.
- (A-5) Four-level readability: `(A-1-b-II) compatibility上の問題` is about 10 characters of prefix.
  It is readable, and writing this section with complete IDs removed the parent lookup I hit in the
  first review.

#### (B) Blocking correction

- (B-1) **The split example contradicts the complete-ID rule.** 「項目の分割」 still shows `(b)`,
  `(I)`, and `(II)`. An agent copying the example would emit single-level IDs. Replace the example
  block:

  ```
  - (b) シールドの問題
    - (I) lifetime
    - (II) compatibility
  ```

  with:

  ```
  - (A-1-b) シールドの問題
    - (A-1-b-I) lifetime
    - (A-1-b-II) compatibility
  ```

#### (C) Optional refinements

- (C-1) **Retired IDs and partial matching.** If `A-1-b` was resolved and `B-2-b` is live, a bare
  `b` matches only `B-2-b`, but the user may mean the retired item. Append to 「省略した参照の解釈」:

  > 末尾一致の候補には、廃止・解決済みのIDも含める。

- (C-2) **The format list can read as the display form.** 「形式」 lists `(1)`, `(a)`, and `(I)`,
  while the next paragraph requires `(A-1)` and so on. Replace "階層ごとに次のIDを使う。" with:

  > 階層ごとに次の記号を使う(表示は下記の完全IDとする)。

- (C-3) **Two examples do not render as inline code.** ``` ``CLAUDE_TASK.md`の…B-2` ``` and
  ``` ``A-1-b`は整理上…` ``` open with a double backtick and close with a single one, so Markdown shows
  stray backticks. Make each a single inline code span, or drop the inner backticks:

  > `CLAUDE_TASK.mdの会話参照ID review結果のB-2`
  >
  > `A-1-bは整理上B-2-aへ移動した。以後はB-2-aを使用する。`

#### (D) Friction observed while writing this section

- (D-1) Complete IDs made cross-references easy; no parent lookup was needed.
- (D-2) Writing `A-3` needed sub-bullets without IDs. The "単なる列挙には箇条書き" rule handled that
  naturally.
- (D-3) No remaining friction that would make IDs harder to use than ordinary headings.

### Closure: adopted by the user (2026-10-06)

The user adopted the revised conversation reference ID rule, with the final review corrections
applied. The canonical rule is now
`Maintanance/CONVERSATION_REFERENCE_IDS.md`.

Use it in qualifying user-facing reports. Treat operational problems as evidence for later
refinement rather than attempting to anticipate every edge case now. The temporary review is closed,
and the standing assignment resumes from its prior state.

## Temporary assignment: review the conversation reference ID draft

Pause the standing assignment below, but do not cancel or replace it. Independently review
`Maintanance/CONVERSATION_REFERENCE_ID_DRAFT.md`, which is a Codex draft produced after the idea
passed through ChatGPT, Claude, ChatGPT, and Codex.

The proposed system gives hierarchical temporary IDs such as `A-1-b-II` to actionable items in
long user-facing reports, so the user can adopt, reject, defer, revise, delegate, or deepen an item
without quoting its full text.

Review goals:

1. Determine whether the system will actually reduce the user's conversational load.
2. Find ambiguity, instability, excessive ceremony, or cases where IDs become harder to use than
   ordinary headings.
3. Check update behavior: deletion, insertion, movement, split, merge, retired IDs, and references
   to older reports.
4. Check interaction with persistent repository IDs, task IDs, issue/test numbers, and table cells.
5. Check whether the rules are usable consistently by both Codex and Claude without flooding short
   replies with identifiers.
6. Identify any missing rule that would cause two reasonable agents to assign or interpret IDs
   differently.

As a practical test, write the review result itself using the draft's hierarchical reference IDs.
Report any point where applying the scheme feels awkward; that friction is evidence, not a reason to
hide the problem.

Return one of: adopt, adopt with revisions, or reject. For every requested revision, provide exact
replacement or insertion text when practical. Separate blocking problems from optional refinements.

Boundaries:

- Read the draft and relevant existing task conventions only.
- Do not edit the draft, source, tests, or other canonical documents.
- Record the review result in this task file.
- Do not commit, push, switch branches, or alter history.
- Return the result to Codex and stop. The user will decide whether to revise or adopt the draft.
- After this temporary review is closed, resume the standing assignment from its existing state.

### Result: Claude review (2026-10-06, Claude Opus 5.5)

Returned to Codex. The draft, source, tests, and other documents are unchanged. This review uses
the draft's own IDs as the practical test; the IDs below belong to this section.

#### (A) Verdict and overall assessment

- (1) **Verdict: adopt with revisions.** Four blocking revisions (`B-1` to `B-4`) and five optional
  refinements (`C-1` to `C-5`).
- (2) Goal 1 (load reduction): yes. The decisive gain over the previous Ⅰ / α / ① rule is that every
  ID is typeable ASCII. Stable IDs across updates, retired IDs, and the table-cell rule also address
  the problems seen in practice (the 2026-10-05 "1-a" collision between a task and a report item).
- (3) Goals 2–6: the update rules (deletion, move, split, merge) and the separation from persistent
  IDs are sound. The gaps are where two agents would act differently: insertion position (`B-1`),
  partial references from the user (`B-2`), IDs that end up in repository files (`B-3`), and the
  application threshold (`B-4`).

#### (B) Blocking revisions

- (1) **Insertion position is undefined.** "既存の参照を壊さない形で追加する" lets one agent insert a
  new `(b)` by renaming nothing and appending `(d)`, and another insert between `(a)` and `(b)` with
  an ad hoc ID. Replace the line "新しい項目は、既存の参照を壊さない形で追加する。" with:

  > 新しい項目は、同じ親の子の末尾に、その階層でまだ使っていない次のIDを付けて追加する。
  > 既存項目の間へは挿入しない。論理的な位置を示したい場合は、本文に「`A-1-a`の補足」のように書く。

- (2) **Partial and loosely typed references are undefined.** The user will often type `1-b`, `b`,
  or full-width `Ａ－１－ｂ`. Also, `I` is both the ninth first-level ID and the first fourth-level
  ID, so a bare `I` is ambiguous by construction. Insert a new section after 「報告本文からもIDを使う」:

  > ## 省略した参照の解釈
  >
  > ユーザーは`1-b`や`b`のように、IDの一部だけで指定することがある。エージェントは、直近の対象報告の
  > 中で末尾一致により一意に決まる場合に限り、その項目と解釈する。一意に決まらない場合は推測せず、
  > 候補を完全IDで示して確認する。
  >
  > 解釈した対象は、返答の中で完全IDで書き戻す(例: `A-1-bをやります`)。
  >
  > 大文字・小文字の違い、全角文字、区切りの省略(`A1b`)は、各位置の階層の型(英大文字・数字・
  > 英小文字・Roman numeral)に従って解釈する。

- (3) **IDs written into repository files are not covered.** In this repository, reports are often
  recorded in task files (this section is one). The draft calls the IDs temporary, but there they
  persist and are read by the other agent. Append to 「IDの有効範囲」:

  > 報告をrepositoryのMarkdown(task文書の結果欄など)へ記録した場合、そのIDはその節の中で固定される。
  > 以後その記録を参照するときは、ファイル名と節名を付ける
  > (例: `CLAUDE_TASK.md`の会話参照ID review結果の`B-2`)。
  >
  > 別のエージェントの報告のIDを指定され、その報告の本文を確認できない場合は推測せず、本文の提示か
  > 記録先を求める。

- (4) **The application threshold is subjective.** "分量のある報告" will be read differently by Codex
  and Claude, and the result is either IDs in short replies or none where the user wanted them.
  Replace the paragraph "複数の論点、選択肢、問題、対応候補があり、後続会話で個別指定する可能性が
  ある場合に使用する。" with:

  > 次のどちらかに当たる返答で使用する。
  >
  > - 個別に採否・指示を受けうる項目が3つ以上ある。
  > - 項目が2階層以上になる。
  >
  > それ未満の返答では新しいIDを作らない。既存IDを参照することはできる。

#### (C) Optional refinements

- (1) **Show the full ID on each item, not only `(b)`.** With bracketed single-level IDs, the user
  must trace the indentation upward to compose `A-1-b-II`. That is the same scanning load the
  scheme tries to remove, and it is harder for a user who finds visual comparison tiring. Replace the
  paragraph 「見出しや一覧では各階層の括弧付きIDを使い、…」 with:

  > 見出しや一覧の各項目には完全IDを付ける(`A`、`A-1`、`A-1-b`、`A-1-b-II`)。
  > ユーザーが階層をたどってIDを組み立てる必要をなくすためである。

- (2) **No numbered lists inside ID-bearing items.** A Markdown `1.` list inside `(A)` looks like a
  second-level ID. Insert under 「形式」:

  > ID付き項目の中の補足には番号付きリストを使わず、箇条書き(`-`)にする。

- (3) **Generalize the table-cell rule.** Single-letter names exist outside tables too: `案S` / `案E`
  in the runtime-check policy and items E / K in `RED_BLACK_TREE_REMAINING_TASKS.md`. Append to
  「表の座標との区別」:

  > 表以外でも、既存文書で英字1文字が名前になっているもの(`案S`、残タスクの`項目K`など)は、
  > `案`や`項目`を付けて呼ぶ。

- (4) **Depth and skipping.** Insert under 「形式」:

  > 第4階層より深くしない。必要なら報告を分けるか、IDなしの箇条書きにする。
  > 階層は飛ばさない(`(A)`の直下は必ず`(1)`から始める)。

- (5) **Optional alternative, not recommended now:** continue first-level letters across reports in
  one conversation (the next report starts at the next unused letter). This would remove most
  "which report's `A-1`?" ambiguity, but letters run out in long sessions. `B-2`'s "ask when
  ambiguous" rule is enough for now.

#### (D) Friction observed while writing this review

- (1) Giving the one-sentence verdict its own ID (`A-1`) felt ceremonial. This supports `B-4`: not
  every paragraph should get an ID.
- (2) To refer to the replacement text under `B-2`, I had to look up its parent to write the path.
  This is direct evidence for `C-1`.
- (3) The draft itself has no IDs, so I referred to its sections by heading text. That worked, and
  it is not a reason to number design documents.
- (4) No point felt worse than ordinary headings once full paths were written.

## Temporary assignment: Claude re-review of runtime-check policy

Pause the standing assignment below and re-review the discussion in `Design-RuntimeChecks.md`,
section `検討中: Indexの検査も標準に揃えるか`.

The standing assignment is paused, not cancelled. Complete this re-review first and present the
recommendation directly to the user. Do not modify source, tests, or the canonical design conclusion
until the user approves a policy. After approval, update the canonical design and task records, then
resume the standing assignment from the restart point recorded below.

Re-review inputs and questions:

- Reassess all four questions in the comparison section; do not merely adopt Codex's conclusion.
- Codex confirmed from current Swift sources that native `Dictionary` validates bucket occupancy
  and Index age using `_precondition`, and recommends案S.
- Check Codex's important qualification: immediate same-tree stale-Index resolution appears to stay
  within the node pool, but a stale mutation may corrupt tree or recycle-pool structure and a later
  operation may then reach an out-of-bounds access. Distinguish immediate resolution safety from any
  broader post-misuse memory-safety claim.
- Recommend案S or案E in Claude's own judgment, state the decisive reason briefly, and identify the
  exact documentation, source, and test consequences if案S is chosen.
- Stop for the user's explicit approval before applying that conclusion.

### Result: Claude re-review (2026-10-05, Claude Opus 5.5)

Returned to Codex by the user's instruction. **The user has not yet approved a policy.** Do not
apply either option to source, tests, or the canonical conclusion until the user approves.

**Recommendation: 案S**, reached independently. Decisive reason: `-Ounchecked` is the user's explicit
request to drop precondition checks. That is the same argument the user already accepted for empty
removal ("すり抜けてくれる方がいい"). Runtime cost is equal under both options, because the CoW
cross-tree resolution (tag lookup and generation match) runs either way, so only rule consistency
separates them. Codex's confirmation that native `Dictionary` uses `_precondition` for bucket
occupancy and Index age settles the precedent.

**Codex's qualification is correct, and the consequences of 案S are wider than the draft said.**
Claude corrected its own comparison section in `Design-RuntimeChecks.md` (the discussion section
only; the canonical conclusion is untouched):

1. **Out-of-bounds slot: possible.** The draft claimed the `initializedCount` comparison survives
   under 案S. That was wrong. With the failure branch as `preconditionFailure`, the `-Ounchecked`
   optimizer may assume success. The comparison exists only to produce the failure, so it may be
   removed.
2. **Double payload destruction: possible** (new). Erasing through a stale Index whose node's
   payload was already destroyed destroys it again. For a reference-type element this is a double
   release, which corrupts the heap outside the tree.
3. **Tree / recycle-pool corruption: possible.** A node pushed to the recycle pool twice can later
   be handed out to two tree positions.

Correct statement for 案S: "for programs that violate documented preconditions, nothing is
guaranteed under `-Ounchecked`". This is the same position as `Array` and `Dictionary`. Immediate
same-tree resolution staying inside the pool does not extend to a post-misuse memory-safety claim.
Correct-use safety is identical under both options.

**If 案S is approved, the work is:**

- Documentation:
  - `Design-RuntimeChecks.md`: drop the exception. Rewrite the guarantee section and the
    classification table, and replace "Index解決を例外とする理由" with the rationale for following
    the standard library.
  - `RED_BLACK_TREE_REMAINING_TASKS.md:272`: revise the "全構成で維持" contract row.
  - `PROGRESS_OVERVIEW.md:177`: annotate the completed item.
  - `Design-MemorySafety.md`: add a scope note to its opening goal ("失敗時にも確保外メモリへアクセス
    しない") that excludes `-Ounchecked` misuse.
  - `UnsafeTreeV2+Subscript.swift`: revise the "Keep this check active under -Ounchecked" comment.
- Source: Index-resolution failure `fatalError` → `preconditionFailure`, about 45 sites:
  - `UnsafeTreeV2+Index.swift`;
  - `UnsafeTreeV2+Subscript.swift`;
  - the four containers' `.invalidIndex` sites;
  - the four containers' `+RangeExpression.swift`;
  - `_SealedTag.swift`.

  These sit in `@inlinable` code, so the change is performance-sensitive and is not complete until
  the performance job is green.
- Tests:
  - Normal Debug and Release are unchanged, since both primitives trap.
  - Under `_O_UNCHECKED`, the Index Death Tests stop terminating. Record this as by design, like
    empty removal.
  - The `_O_UNCHECKED` evidence in `INDEX_POC_VALIDATION.md` is no longer a requirement.

Restart state:

- Branch: `develop/misc/49`.
- Uncommitted task-owned changes: this file and `Design-RuntimeChecks.md`.
- `git diff --check` passed before reassignment. No build or tests were required for the
  documentation-only transition.
- No commit, push, branch switch, or source/test change was made during the transition.

## Second re-review: product responsibility and the 1.0 gate

The user has returned the policy to Claude for one more review before treating the current direction
as settled. Review the technical recommendation together with the product-level responsibility it
expresses; do not reduce this pass to another inventory of failure primitives.

Current proposed disposition:

- Adopt案S as the working policy: follow Swift's standard-library contract model for Index misuse.
- Under `-Ounchecked`, documented preconditions are assumed; detection, safe termination, and memory
  safety after misuse are not guaranteed.
- Preserve案E's strongest case in the record rather than presenting it as technically mistaken:
  its inexpensive always-on checks can contain stale-Index misuse before double destruction or
  tree/recycle-pool corruption, and the implementation and tests already exist.
- Treat案S as the present engineering decision, not an irreversible product promise.
- Before declaring version 1.0, reopen this policy explicitly. Recheck runtime cost, every relevant
  failure site's classification, the public safety claim, then-current Swift standard-library
  behavior, and whether `-Ounchecked` is a supported configuration.
- Do not mechanically convert the estimated 45 sites. Separate caller/Index contract failures from
  internal corruption barriers, allocation-boundary checks, and truly impossible implementation
  states; retain always-on failure where the latter classifications justify it.

The user's framing is part of the review input:

> The final responsibility belongs to the user, and this policy is part of the foundation of how the
> user chooses to face the world through this product.

Interpret this concretely: the decision defines how responsibility is divided between the library
and its callers. Standard-library precedent and performance evidence inform that decision but do
not make it automatically. Codex's role and Claude's role are to surface facts, counterarguments,
costs, and failure consequences; the product owner makes and owns the final choice.

Claude should now answer briefly:

1. Does this framing change the recommendation between案S and案E? Why?
2. Is adopting案S now with a mandatory pre-1.0 review a coherent policy, or does it create a harmful
   temporary contract?
3. What exact caveats and reopening criteria must survive in the canonical record so that the 1.0
   review is substantive rather than ceremonial?
4. Is there any remaining objection strong enough that the user should not adopt案S even as the
   working policy?

Return the result to Codex and stop. Do not change source, tests, or the canonical design conclusion,
and do not resume the standing assignment until the user has considered this second review.

### Result: Claude second re-review (2026-10-05, Claude Opus 5.5)

Returned to Codex. No source, test, or canonical-conclusion change.

**1. Does the framing change the recommendation?** No, 案S stands. The framing changes what 案S
*is*: a statement of how responsibility is split between the library and callers who choose
`-Ounchecked`, not merely a primitive choice.

It therefore adds one obligation. The split must be stated where callers will read it (the public
guides and DocC), not only in internal design notes. Precedent and cost inform the choice; the
written allocation of responsibility is what the user owns.

**2. Is 案S now plus a mandatory pre-1.0 review coherent?** Yes, if the contract and the code are
separated:

- The safe direction of change matters. Moving later from 案S to 案E *adds* a guarantee, which is
  non-breaking. Moving from 案E to 案S *removes* one. Adopting 案S as the documented contract now
  keeps the 1.0 review free in both directions.
- The harmful version would be converting the ~45 sites now and possibly reverting them at 1.0.
  That is churn in `@inlinable` code, needs a performance job each time, and buys nothing measurable,
  since the predicted runtime difference is about zero.
- Recommendation: adopt 案S as the **documented contract** now, and **leave the current
  `fatalError` implementation in place**. Behavior that over-delivers on a weaker contract is
  allowed. Make "convert the sites or not" one of the 1.0 review items, decided on measured
  `-Ounchecked` cost.
- This also satisfies Codex's "do not mechanically convert": nothing is converted until the
  per-site classification exists.

**3. Caveats and reopening criteria that must survive in the canonical record.** Otherwise the 1.0
review becomes ceremonial.

- Caveats:
  - The explicit misuse consequences under `-Ounchecked`, listed rather than summarized:
    out-of-bounds slot, double payload destruction (heap corruption for reference elements), and
    tree / recycle-pool corruption.
  - Correct-use safety is guaranteed in every configuration.
  - 案E's strongest case, recorded as a legitimate alternative: cheap, already implemented and
    tested, and it contains stale-Index misuse before double destruction.
  - The current gap between contract and implementation: the contract follows 案S, while the code
    still stops via `fatalError`. Record the reason for the gap.
- 1.0 review items, each with the evidence it requires:
  1. Measured `-Ounchecked` cost of the Index-resolution failure branches. Use interleaved A/B runs
     plus a machine-code comparison, because code layout alone moves results by ±20% here.
  2. A complete per-site classification: Index contract, internal corruption barrier, allocation
     boundary, or impossible state. Only the first class is eligible for conversion.
  3. Public claims (README, DocC, guides, `AdoptionReadinessAssessment`) consistent with the chosen
     contract.
  4. The Swift standard-library behavior at that toolchain, rechecked (the `Dictionary`
     `_precondition` precedent).
  5. Whether `-Ounchecked` is a configuration the product supports or merely tolerates, including
     what the primary target environment actually compiles with (see 4).
  6. The status of the `_O_UNCHECKED` Index Death Tests and of the `INDEX_POC_VALIDATION.md`
     evidence that encode the current behavior.
- Owner and trigger: the user decides. The review is triggered by declaring 1.0, or earlier if
  item 5 shows that `-Ounchecked` is the main deployment configuration.

**4. Any objection strong enough to block 案S as the working policy?** No blocking objection. One
fact could change the weight and must be checked first in the 1.0 review, or sooner:

- This package targets AtCoder. If the AtCoder judge's Swift build uses `-Ounchecked`, then
  `-Ounchecked` is the main deployment configuration, not a niche one.
- Under 案S, a contestant's stale-Index bug would then become a silent wrong answer or heap
  corruption instead of a runtime error.
- Claude has not verified the judge's flags. The repository records none, and network access was
  not used.
- This does not block 案S as a documented contract, because the current `fatalError` code keeps
  stopping in the meantime. It does weigh on whether the sites should ever be converted.
- **User reply (2026-10-05):** the judge's Swift environment is decided by a volunteer, and that
  volunteer is the user. The user acknowledged the need for care.
  - The library contract and the judge configuration are therefore in the same hands.
  - The judge configuration affects every Swift contestant, not only users of this library.
  - The user has read this second review.

### Closure: user-approved working policy (2026-10-05)

The user approved closing this discussion at the current landing point:

- 案S is the current documented contract.
- The existing 案E-style `fatalError` implementation remains as behavior that exceeds the contract.
- No source or test conversion is performed now.
- 案E's safety case and the concrete consequences of `-Ounchecked` misuse remain in the canonical
  design record.
- The policy and implementation are reopened before version 1.0, or earlier if `-Ounchecked` is
  found to be a primary deployment configuration.
- The final decision belongs to the user as product owner; standard-library precedent and
  performance evidence inform, but do not replace, that responsibility.

`Design-RuntimeChecks.md` records the decision and reopening criteria. The temporary review is
closed, and the standing assignment below resumes from its prior restart point.
## Completed assignment: update Claude's user assessment and reflection

The previous retrospective task updated agent task-fit evidence but did not perform the user's
requested update to Claude's dedicated assessment of the user. Correct that omission.

Update `Maintanance/USER_MANAGEMENT_INTERVIEW_CLAUDE.md` with a new, clearly dated independent
reassessment covering the period after its existing `2026-10-05 再評価`, especially:

- the performance CI failure and the user's request for local CI-equivalent reproduction;
- the user's correction that the performance job already existed;
- the user's diagnosis of lost generic/protocol specialization and witness-table dispatch;
- the distinction the user drew between `@inlinable`, `@usableFromInline`, and paths such as
  `RawBuffer` / `BufferHeader` that remove type variables;
- the user's definition of which visibility audits were uniform and which changes require direct
  user involvement;
- branch/commit/publication corrections, including public bisection history versus private tuning
  notes; and
- whether the user intervened too much, too little, or at the appropriate points.

Re-evaluate all 15 existing dimensions. Explicitly list every score that changes and every score
that remains unchanged with new evidence. Do not preserve a score merely for consistency, and do
not change one merely because the incident is recent. Separate faults in Codex/Claude execution
from faults in user management.

Also append a new entry to `Maintanance/CLAUDE_OBSERVATIONS.md` giving your current personal
impression of working with the user during this incident. The user explicitly requested an updated
impression, not another technical incident summary or only self-criticism. Be candid: include both
what you valued and anything that was difficult, surprising, or could improve. Write in your own
voice; do not imitate Codex or optimize the entry to obtain a favorable evaluation.

Record a concise result here and set `Status: Completed`. Tell the user only `完了` unless a direct
conversation or user decision is genuinely required.

### Boundaries

You may edit only:

- `Maintanance/USER_MANAGEMENT_INTERVIEW_CLAUDE.md`
- `Maintanance/CLAUDE_OBSERVATIONS.md`
- `Maintanance/CLAUDE_TASK.md`

Do not edit the integrated assessment, Codex's interview/observations, task-fit interview, source,
tests, benchmarks, workflows, public bisection record, or any private/untracked note. Do not stage,
commit, push, switch branches, use network access, or alter Git history. Preserve all existing
worktree changes. Run `git diff --check`, inspect the task-owned diff, and report
`git status --short`.

### Result

2026-10-05, Claude Opus 5.5, on `try/index/1`.

**Assessment update.** I appended `## 2026-10-05 再評価(性能回帰の期間)` to
`USER_MANAGEMENT_INTERVIEW_CLAUDE.md`, written without consulting Codex's assessment. It marks
which evidence is direct (Claude's conversations and its own audits and reviews) and which is
indirect (the bisection and CI-history corrections, taken from the docs and Git).

**Scores:** 1 of 15 changed. The other 14 are unchanged, each with new evidence.

- Changed: タスク境界の明確さ, 4 → 5. The user drew a category-level automation boundary:
  - Uniform: `@usableFromInline` on non-public protocols.
  - User involvement required: `@inlinable`, `@usableFromInline`→`@inlinable` changes, and the
    `RawBuffer` / `BufferHeader` type-erasure boundary.
- Unchanged at 5 (8):
  - 技術的な優先順位
  - 品質証拠への感度
  - 方針転換の判断
  - 問題発見の勘
  - 完了条件の明確さ
  - 途中介入の精度
  - 報告の受け取り設計
  - scopeを止める力
- Unchanged at 4 (6):
  - 公開API・利用者価値の判断
  - AIへの技術的文脈共有. Added concern: the performance rule was tacit before the incident, and
    the private note is now outside the repository.
  - AI間の役割分担
  - マイクロマネジメント度
  - 意思決定の記録
  - 自分の負荷の管理. The load spike was AI-caused.

**Attribution of faults:**

- AI faults:
  - Codex: the scope narrowing, the CI-history hypothesis, the branch slip, and the
    order omission.
  - Claude: the G2 approval claiming "not needed".
- User-management findings: only the tacit-rule gap, and it was a deliberate secrecy trade-off.

**Intervention level:** appropriate overall. The interventions concentrated on AI errors and
on decisions only the user can make.

**Top improvement:** put the rule alone, without the reasoning, in standing agent instructions,
so the next session does not repeat G2.

**Observation log.** I appended a personal impression to `CLAUDE_OBSERVATIONS.md`. It covers
what I valued, what surprised me, and what was difficult, and it is not a technical summary.

**Worktree.** `git diff --check` is clean. Task-owned diffs are the two appended sections and this
result. Other modified files are Codex's and are untouched. `git status --short`:
`M AGENT_TASK_FIT_INTERVIEW.md`, `M CLAUDE_OBSERVATIONS.md`, `M CLAUDE_TASK.md`,
`M CODEX_OBSERVATIONS.md`, `M PERFORMANCE_REGRESSION_BISECTION.md`,
`M USER_MANAGEMENT_INTERVIEW_CLAUDE.md`, `M USER_MANAGEMENT_INTERVIEW_CODEX.md` (Codex's, untouched; all under `Maintanance/`).

## Completed assignment: review the performance-incident retrospective

Perform a read-only factual and role-assessment review of Codex's newly appended
`## Performance regression evidence update (2026-10-05)` in
`Maintanance/AGENT_TASK_FIT_INTERVIEW.md`.

Review the period covering the performance CI failure, local reproduction and bisection,
`@usableFromInline` correction, the non-public protocol and generic nominal visibility audits,
cross-branch cherry-picks, and the decision to close `develop/misc/48` without merge in favor of
`try/index/1`.

Determine whether you agree with:

1. keeping H, A, and X1 scores unchanged;
2. the stated evidence for Codex's strengths and failure modes;
3. the updated role assigned to the user/domain owner;
4. the operational safeguards added by Codex; and
5. the factual distinction between the private tuning-policy notes and the public performance
   bisection record.

Do not silently rewrite Codex's self-assessment. Append a clearly attributed Claude review stating
agreement, corrections, and any score or assignment change you recommend. Update your own
task-fit evidence only where this incident provides new evidence. Do not change a score merely
because the task was recent.

You may optionally append your own words to `Maintanance/CLAUDE_OBSERVATIONS.md` if you genuinely
have a reflection you want the user to read later. This is optional; do not manufacture a feeling
or repeat the technical report just to fill the log.

Return one verdict: `retrospective agreed`, `retrospective needs factual corrections`, or
`retrospective needs role/score changes`. Record evidence and the verdict in this task, set
`Status: Completed`, and tell the user only `完了` unless a user decision is required.

### Boundaries

You may edit only:

- `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`
- `Maintanance/CLAUDE_OBSERVATIONS.md` (optional)
- `Maintanance/CLAUDE_TASK.md`

Do not edit source, tests, benchmarks, workflows, the public bisection record, Codex's observation
log, or any untracked/private note. Do not stage, commit, push, switch branches, use network access,
or alter Git history. Preserve Codex's existing edits and append your review separately. Run
`git diff --check`, inspect the complete task-owned diff, and report `git status --short`.

### Result

2026-10-05, Claude Opus 5.5, on `try/index/1`. Verdict: `retrospective needs role/score changes`.

I appended `## Claude review of performance regression evidence update (2026-10-05)` to
`AGENT_TASK_FIT_INTERVIEW.md`. Codex's section is unchanged.

**Factual corrections:**

- Protocol audit counts: 181 is the total number of protocols. Of those, 126 are non-public:
  121 already had the attribute and 5 were added.
- Generic nominal audit counts: 71 is the total number of `struct` / `class` declarations.
  Only 5 are non-public and generic, all already attributed, so 0 were added.
- Missing approval path: the first red commit `cf7a7d36` (G2) was approved by Claude's review.
  That review explicitly answered "No `@usableFromInline` is needed", using compile and test
  evidence only.
- Missing Claude case: Claude's earlier narrowing of 3 原木 protocols to plain `package`.
  Their performance impact was not measured.
- Cross-branch nuance: `--cherry-pick` alone still leaves `0bcb8508` unmatched. `range-diff`
  shows the difference from `747c0486` is test context lines only.
- Unverifiable claim: the original narrow scope wording has no Git record.

**Recommendations:**

- Keep H, A, and X1 unchanged.
- Leave the B score unchanged, but add two conditions:
  - Never omit `@usableFromInline` on newly non-public protocols or generic types on the grounds
    that compile does not need it.
  - Claude's `approve` covers API, compile, and function only. A narrowing batch is not complete
    until the performance job is green.

**User decision needed:** `PERFORMANCE_REGRESSION_BISECTION.md`, pushed to
`origin/try/index/1`, states the `package` + `@usableFromInline` recovery result itself. That may
overlap the knowledge the user wants to keep private. Not edited.

**Worktree:** `git diff --check` is clean. Task-owned edits are the appended section, this
result, and one optional entry in `CLAUDE_OBSERVATIONS.md`. Codex's existing edits are
preserved. `git status --short`:
`M AGENT_TASK_FIT_INTERVIEW.md`, `M CLAUDE_OBSERVATIONS.md`, `M CLAUDE_TASK.md`,
`M CODEX_OBSERVATIONS.md` (Codex's, untouched).

## Completed assignment: repair Index PoC DocC curation identifiers

Finish the remaining pre-integration correction reported by the immediately following completed
assignment. The success-only Index type changed the precise DocC identifiers for `erase(_:)` and
`distance(from:to:)`, leaving 20 stale disambiguation suffixes across Set, MultiSet, Dictionary,
and MultiMap Topics.

Required work:

1. Reproduce the Release DocC `--warnings-as-errors` failure and record the exact command.
2. Resolve every stale Index-related curation link to the intended overload. Update only the hash
   suffix or precise symbol link needed for that overload; do not reorder or rewrite Topics.
3. Re-run the same Release DocC command with warnings as errors and require a clean result.
4. Run `git diff --check` and inspect the final diff for accidental documentation changes.

Do not edit source or tests, change public API, perform the broader P10 design-record rewrite, or
touch the deferred Bound DSL bug, `_O_UNCHECKED` empty removals, `Comparable`, nominal wrappers,
ContainersPreview, Permutation, or frozen tasks.

### Boundaries

You may edit only the affected DocC catalog files and `Maintanance/CLAUDE_TASK.md`. Do not edit
`Maintanance/INDEX_POC_VALIDATION.md`; Codex will integrate the result. Do not stage, commit, push,
switch branches, merge, or alter Git history. If any error is not an obsolete symbol
disambiguation caused by the Index type change, leave it unchanged and report it separately.

Record the exact command, changed catalog files, old/new link classification, and final result in
the first Result section below. Set `Status: Completed` and tell the user only `完了` unless a
product-owner decision remains.

### Result

2026-10-05, Claude Opus 5.5. Release DocC `--warnings-as-errors` is now clean. Only DocC catalog
files were changed, and nothing was staged.

**Command** (the CI command, both before and after the fix):

```
swift package --disable-sandbox -c release --allow-writing-to-directory .build/documentation \
  generate-documentation --target RedBlackTreeCollections --output-path .build/documentation \
  --transform-for-static-hosting --hosting-base-path swift-ac-collections --warnings-as-errors
```

- **Before:** 20 errors of the form "'<hash>' isn't a disambiguation", plus the follow-on archive
  move error caused by the failed build.
- **After:** exit 0, "Finished building documentation".

**How the intended overload was identified.** I did not guess from position. In a task-owned
`mktemp -d` directory, since removed:

1. I exported `Sources/RedBlackTreeCollections` from develop `2796d7c2` (`git archive`) and copied
   the current working tree.
2. For each, I compiled a symbol graph with `swiftc` (`-DALLOW_CROSS_TREE_INDEX`, `-O`), with no
   package resolution.
3. I ran `xcrun docc convert` with that catalog.

The develop run reproduced every old hash exactly, which validates the mapping. For each
container, I then paired the old and new hash pages by their rendered declaration.

**Changed files and links** (old → new; 5 per file, 20 in total):

| File | `erase(_ ptr: Index)` | `erase(_: IndexRange)` | `erase(_: IndexRangeExpression)` | `erase(_: UnboundedRange)` | `distance(from: Index, to:)` |
| --- | --- | --- | --- | --- | --- |
| `RedBlackTreeSet.md` | `1hm5m`→`66kob` | `7sncn`→`207dn` | `1chhq`→`fmh0` | `zwzk`→`6xhp2` | `9y0yy`→`7ecok` |
| `RedBlackTreeMultiSet.md` | `8bace`→`7om7w` | `8o69d`→`9tgad` | `5st1y`→`9ceva` | `8u5n5`→`6z958` | `74m7h`→`5fn2h` |
| `RedBlackTreeDictionary.md` | `12h1o`→`tsqp` | `7r9ok`→`7b3q1` | `96i73`→`1yrnu` | `88doh`→`7e9wt` | `1nyff`→`26cz3` |
| `RedBlackTreeMultiMap.md` | `78u56`→`151rw` | `5jzi8`→`7ofvq` | `7haxv`→`8begn` | `42awa`→`sjf1` | `6mvs2`→`4uhx1` |

All files are under `Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/`.

- **Classification:** all 20 are obsolete disambiguations caused by the Index type change. The
  overloads that do not involve `Index` (`Bound` / `BoundRangeExpression` `erase`, and the Bound
  `distance`) kept their hashes and were not touched.
- **Unchanged otherwise:** only the suffixes changed. No Topics were reordered or reworded, and no
  other link was edited.
- **One correction to an assumption:** in each container's "Removing …" section, the lone
  `erase(_:)` link points to the **IndexRangeExpression** overload (Dictionary `96i73`, for
  example), not the single-Index overload. The old mapping preserved this.
- **Other errors:** none.

**Checks.** `git diff --check` was clean. The catalog diff has 20 insertions and 20 deletions, all
hash suffixes. I made no source, test, or ledger edits in this task.

### Result

Pending.

---

## Completed assignment: implement the approved pre-integration Index corrections

Implement the local corrections required by the immediately following completed verdict
(`adopt after corrections`) on `try/index/1`. Keep the success-only Index representation intact.

Required work:

1. P6 public surface:
   - restore `@_documentation(visibility: internal)` on `UnsafeIndexV3`;
   - make the newly introduced `_LazyTiedPtr._NodePtr` alias `package` unless its implementation
     makes that impossible, in which case stop and report the exact compiler constraint.
2. P14 dual family:
   - first make the obsolete Result-valued overload candidates unavailable in a disposable edit
     and build to prove that production callers do not need them;
   - then remove only the proven-unused `_LazyTieWrappedPtr` variants of tree/header
     `index`/`index_or_nil`, container/View `___index`/`___index_or_nil`, and movement functions;
   - retain the `_LazyTieWrappedPtr` alias and resolver/construction paths that still have genuine
     diagnostic, Debug, or test consumers;
   - remove the unused seal-only `_LazyTieWrap.isValid`, or document its real remaining consumer.
3. P13 DocC: move the misplaced `Complexity` callouts below the summary sentences in Dictionary
   and MultiMap Index documentation.
4. P11 cleanup: remove only the listed PoC/merge artifacts: the commented-out old alias and its
   `実質V4` block, duplicated `過去の状態で封印する` line, trailing blank lines, Package.swift
   comment-spacing-only drift, and temporary `O(1) ready` notes (replace with proper Complexity
   prose only where it adds a public contract).

Do not perform P10's post-integration design-document rewrite yet. Do not touch the deferred Bound
DSL bug, `_O_UNCHECKED` empty removals, `Comparable`, nominal wrappers, ContainersPreview,
Permutation, or frozen tasks.

Validation:

- run `git diff --check`;
- run the four-container P4 filter and the four P1 restored invalid-Bound tests;
- run a Release DocC build with warnings as errors if the repository's existing command is readily
  discoverable; otherwise report it as the remaining Codex integration check;
- run a narrow Release + `_O_UNCHECKED` Index filter only if you can derive a precise filter that
  excludes the known empty-removal cases. Record the exact command and counts.

### Boundaries

You may edit the necessary source files, `Package.swift`, and `Maintanance/CLAUDE_TASK.md`. Do not
edit `Maintanance/INDEX_POC_VALIDATION.md`; Codex will integrate the result. Do not stage, commit,
push, switch branches, merge, or alter Git history. Do not broaden cleanup beyond the enumerated
artifacts. If the disposable unavailable proof finds a caller, restore that disposable edit and
report the overload as retained rather than redesigning it.

Record changed files, proof results, exact validation commands/counts, and any retained overloads
in the first Result section below. Set `Status: Completed` and tell the user only `完了` unless a
product-owner decision is required.

### Result

2026-10-05, Claude Opus 5.5. All four corrections are implemented on `try/index/1`, and the
success-only representation is unchanged. Nothing was staged. The ledger is not edited.

**Changed files** (14; 12 insertions, 196 deletions):

- `Package.swift`: the comment-spacing drift is reverted; the file is identical to develop.
- `Implements/Index/UnsafeIndexV3.swift`:
  - P6: restored `@_documentation(visibility: internal)` and the develop-style `//` comment header.
  - P11: removed the commented-out old alias and the 「実質V4」 block.
- `Implements/RawBuffer/_LazyTieWrap.swift`:
  - P6: `_LazyTiedPtr._NodePtr` is now `@usableFromInline package`. Plain `package` is impossible:
    the compiler requires it to be `@usableFromInline` because the `@inlinable` `unchecked(_:end_ptr:lazyDetach:)`
    uses it in its signature (errors: "type alias '_NodePtr' is package and cannot be referenced from
    an '@inlinable' function" and "the parameter of a '@usableFromInline' method must be
    '@usableFromInline' or public"). It is no longer externally nameable.
  - P11: removed both `/// O(1) ready` notes. No Complexity prose was added, because `==` / `hash`
    are not documented public entry points.
  - P14: kept `isValid` and documented its real consumers with a comment. Its tree-free,
    issuer-based check is used by `RedBlackTreeSet_98_IndexValidityXCTests:77,99`,
    `RedBlackTreeDictionary_98_IndexValidityXCTests:72,95`, `RedBlackTreeSet_3_IndexSequenceTests:53,72`,
    and `RedBlackTreeSet_98_PerformanceTests:192-195`.
- `Implements/RawBuffer/_LazyTie.swift`: removed the trailing blank lines; the file is identical to
  develop.
- `__tree/unsafe_node/Seal/_NodePtrSealing.swift`: removed the duplicated `/// 過去の状態で封印する`.
- `RedBlackTreeDictionary+Index.swift` and `RedBlackTreeMultiMap+Index.swift` (P13): removed the
  misplaced `/// - Complexity: O( log count )` above the summary. Each comment already contains a
  correctly placed `- Complexity: O(log count)` below its Returns line, so moving the line would
  only have duplicated it.
- P14 removals, with the extensions they left empty also removed:
  - `UnsafeTreeV2+Index.swift`: the old `index_or_nil`, `prev_iter`, `next_iter`,
    `adv_iter(offsetBy:)`, `adv_iter(offsetBy:limitedBy:)`, `index_or_nil(offsetBy:limitedBy:)`,
    and `form_index`.
  - `UnsafeTreeV2+BufferHeader.swift`: the old `index_or_nil`.
  - Set, MultiSet, Dictionary, and MultiMap `+Index.swift`: the old `___index` /
    `___index_or_nil`.
  - MappedValues, KeyOnly, and KeyValue Views: the old `___index`.

**P14 proof.**

1. Disposable `@available(*, unavailable)` on all 21 candidates. The Debug build failed only
   inside the old bodies themselves (old `___index` → old `index`), so the proof was inconclusive.
2. Restored the originals from a `mktemp -d` backup and deleted all 21. The build then found real
   callers: the success-only movement functions use `.flatMap { index($0) }`, which resolves to the
   Result-valued `UnsafeTreeV2.index(_:)` (`UnsafeTreeV2+Index.swift:102,115,128,146`).
3. **Retained**, with a comment: `UnsafeTreeV2.index(_:) -> _LazyTieWrappedPtr` and the header's
   `index(_:) -> _LazyTieWrappedPtr` that it calls.
4. **Removed:** the other 19.
5. With only those two retained, these all succeed:
   - `swift build --disable-sandbox --build-tests` (Debug);
   - `swift build --disable-sandbox -c release --target RedBlackTreeCollections`;
   - `swift build --disable-sandbox --build-tests -Xswiftc -DCOMPATIBLE_ATCODER_2025`.
6. Also retained: the `_LazyTieWrappedPtr` alias, the `__purified_` / `__purified_safe_(_: _LazyTieWrappedPtr)`
   resolvers, the success-only `adv_iter(limitedBy:)`'s internal `Result` return, and the Debug
   `band`.
7. The backup directory has been removed.

**Validation**:

- `git diff --check`: clean.
- P4: `swift test --disable-sandbox --skip-build --filter 'RedBlackTree(Set|MultiSet|Dictionary|MultiMap)(IndexValidityXCTests|IndexRangeTests|BidirectionalCollectionTests|CopyOnWriteTests)'`:
  111 tests, 0 failures.
- P1: `swift test --disable-sandbox --skip-build --filter 'InternalTests/boundExpressionIndexValidity'`:
  4 tests in 4 suites passed.
- Release + `_O_UNCHECKED`:
  `swift test --disable-sandbox -c release --traits _O_UNCHECKED --filter 'RedBlackTree(Set|MultiSet|Dictionary|MultiMap)IndexValidityXCTests|RedBlackTreeMappedValuesViewTests|(indexAfterEndIndex|indexBeforeStartIndex|indexOffsetBy[A-Za-z]*|formIndexOffsetBy[A-Za-z]*|staleIndexSubscript|mappedValues[A-Za-z]*|removingAnAlreadyRemovedIndex)_terminates'`.
  - XCTest: 17 (MappedValues), 0 failures. The `IndexValidityXCTests` suites are `#if DEBUG` and
    therefore absent in Release.
  - Swift Testing: 23 tests in 4 Death-test suites passed. The empty `removeFirst` /
    `removeLast` cases are excluded by name.
- After those runs I made only one more edit, a whitespace fix (removing two stray blank lines
  left by the extension removal), and rebuilt Debug successfully.

**Remaining Codex integration check: Release DocC `--warnings-as-errors` fails** with 20 curation
errors such as `'88doh' isn't a disambiguation for 'erase(_:)'`.

- They break down per container (Set, MultiSet, Dictionary, MultiMap) as 4 × `erase(_:)` and
  1 × `distance(from:to:)`.
- They come from the PoC's Index type change itself: the overloads taking `Index` now have
  different precise identifiers, so the hash suffixes changed. None of these corrections causes
  them, since no public signature changed.
- Fixing them means regenerating the hash suffixes in the DocC Topics. That belongs with
  P10 / integration documentation, so I left it.

There is no product-owner decision.

### Result

Pending.

---

## Completed assignment: issue the final success-only Index validation verdict

Independently review the now-complete evidence ledger in `Maintanance/INDEX_POC_VALIDATION.md`,
including Codex's uncommitted final-batch integration after `714252d1`. Issue exactly one verdict:

- `adopt after corrections`
- `adoption blocked by specified evidence`
- `evidence incomplete`

Judge only the success-only Index representation. Do not fold `Comparable`, a nominal public
wrapper, ContainersPreview, the deferred shared Bound DSL bug, `_O_UNCHECKED` empty-removal triage,
or frozen work into the representation verdict. Verify that the P9 complexity note is supported by
the cited implementation shape and that P2's intentional unmapping is consistent with the stated
public contract. Treat missing original command text for already-reviewed normal Release and
`_O_UNCHECKED` runs as a reproducibility/documentation limitation, not automatically as missing
behavioral evidence; say explicitly if it changes your verdict.

If the verdict is `adopt after corrections`, list only the corrections required before integrating
the PoC, separating them from optional or deferred work. If blocked or incomplete, identify the
smallest concrete missing evidence. Keep the result concise enough to serve as the validation's
closing decision record.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, the validation ledger,
other documentation, Package.swift, or workflows. Do not run broad tests, fix findings, stage,
commit, push, switch branches, or alter Git history. Read-only inspection and a narrow disputed-
claim check are allowed. Run `git diff --check` and inspect `git status --short` at the end.

Record the verdict in the first Result section below, set `Status: Completed`, and tell the user
only `完了` unless a product-owner choice remains.

### Result

2026-10-05, Claude Opus 5.5. **Verdict: `adopt after corrections`.**

**Scope.** The verdict covers the success-only representation on `try/index/1` (`714252d1` plus
Codex's uncommitted ledger integration), in the default configuration: `ALLOW_CROSS_TREE_INDEX`
on, `USE_LAZY_DETACH` off, normal mode, Debug and Release. It does not cover `Comparable`, a
nominal wrapper, ContainersPreview, the shared Bound DSL `limit:` bug, the `_O_UNCHECKED`
empty-removal triage, the `USE_LAZY_DETACH` configuration (unused, commented out), or frozen work.

**Basis.** Every required Quality Checklist property now has positive evidence or a documented
intentional unmapping:

- P1: invalid-Bound coverage restored.
- P2: stale, recycled, movement, MappedValues, detached marking, and memory-safe outliving storage,
  in Debug, Release, narrow `_O_UNCHECKED`, and ASan. The unmapped parts are outside the public
  contract (another tree is unspecified per `UnsafeIndexV3.swift`).
- P3: configuration matrix, including compat Debug and Release as legacy-contract evidence.
- P4: four-container breadth (111 tests, reproduced), plus three Views.
- P7: equality and hashing.
- P8: stale limit, corrected in both overload families.
- P9: complexity, closed by inspection.
- P14: no public `Index` path can reach the old family, by type.

I checked P9 against the code:

- Same-tree purification compares the tie identity, then compares one stored seal with the node's
  `___recycle_count` (`_NodePtrSealing.isUnsealed`): O(1).
- Cross-tree lookup walks the fresh-pool buckets, which is O(1) under the post-CoW invariant.
- At most one `lazyDetach` is created per storage.
- `makeIterator` returns `Tree._PayloadValues`, a raw-pointer `_Obverse4`, so traversal is O(K).

Ledger nuance: "reads the stored seal" should read "compares the stored seal with the node's
recycle count". The cost is unchanged.

None of the evidence shows a deeper contradiction. No required behavior needs a failure value in
the public Index, validity checks stay O(1), and lifetime is held by the existing storage tie.

**Missing command text.** The original command text for the normal Release and `_O_UNCHECKED`
runs is still missing. This does **not** change the verdict: those results were reviewed and the
filters are re-derivable. It is a reproducibility limitation. The integration's own validation run
should record its commands.

**Corrections required before integrating the PoC.** All are local and none changes the
representation.

1. **P6, public surface.**
   - Restore `@_documentation(visibility: internal)` on `UnsafeIndexV3`.
   - Make the new nested `_LazyTiedPtr._NodePtr` non-public (package), or record an explicit owner
     decision to keep it. It is new public surface, and it parallels the frozen `Result._NodePtr`
     item.
2. **P14, dual family.** Remove the old Result-valued overloads that differ from the success-only
   ones only by return type, and that have no remaining caller:
   - the `_LazyTieWrappedPtr` variants of `___index` / `___index_or_nil`;
   - the tree and header `index` / `index_or_nil`;
   - the movement family.

   A disposable `@available(*, unavailable)` build is the mechanical proof that they have no
   caller. Keep the `_LazyTieWrappedPtr` alias and resolver paths that remain genuinely used. Also
   remove or document the unused seal-only `_LazyTieWrap.isValid`.
3. **P13.** Move the two `/// - Complexity` lines below the summary sentences in
   `RedBlackTreeDictionary+Index.swift` and `RedBlackTreeMultiMap+Index.swift`.
4. **P11.** Remove the merge and prototype artifacts:
   - the commented-out old alias and its 「実質V4」 comment block;
   - the duplicated 「過去の状態で封印する」 doc line;
   - the trailing blank lines;
   - the `Package.swift` comment-spacing change;
   - the `/// O(1) ready` notes, or turn them into proper `Complexity` text.
5. **P10.** After integration, update the design records that still describe
   `UnsafeIndexV3 = _LazyTieWrappedPtr`, and close the X1 identity-map and PoC entries.
6. **Re-run after corrections.** Run the four-container P4 filter, the P1 tests, the narrow
   Release + `_O_UNCHECKED` Index filter, and the Release DocC `--warnings-as-errors` build. Record
   the exact commands.

**Optional or deferred** (not required for integration):

- the Debug `.unsafe(tree:rawTag:)` / `.nullptr` non-empty-tree rule (P5), which only needs a
  comment;
- wall-clock A/B timing;
- an ASan run in Release;
- the Bound DSL `limit:` fix and the `_O_UNCHECKED` empty-removal triage, both already deferred;
- `lazyDetach` concurrent first-access, which remains frozen and also exists on develop;
- `Comparable`, the nominal wrapper, and ContainersPreview.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows
Codex's ledger plus this file.

### Result

Pending.

---

## Completed assignment: review the final Index PoC evidence gap

Independently review the committed `try/index/1` evidence through `714252d1`. The product owner
wants to finish the overall success-only Index validation before applying the already-confirmed
shared Bound DSL `.advanced(limit:)` fix. Minimize additional work: distinguish evidence required
for the representation decision from cleanup, later API design, frozen work, and defects shared
with `develop`.

Required output:

1. Review the new `P3` compatibility Release evidence: 120 XCTest cases passed with 4 intentional
   skips, followed by 1 Swift Testing case passed. Return `P3 pass`, `P3 fail`, or `P3 unmapped`.
2. Review the new `P4` four-container batch: 111 tests spanning Index validity/ranges,
   bidirectional movement, and CoW across Set, MultiSet, Dictionary, and MultiMap, plus the already
   reviewed Range View evidence. Return `P4 pass`, `P4 fail`, or `P4 unmapped`.
3. Audit the remaining `P2`, `P9`, `P10`, `P11`, and `P13` entries. Classify each as exactly one of:
   `required before adoption verdict`, `correction after verdict`, or `intentionally unmapped`.
4. For every item classified as required, specify the smallest concrete command, inspection, or
   measurement that would close it. Do not request a broad matrix rerun when committed evidence
   already establishes the property.
5. State whether the next Codex step can be a final evidence batch, or whether more than one
   independent batch is genuinely necessary. Do not issue the final adopt/reject verdict yet.

The success-only representation is the leading candidate. A shared/local defect, cleanup item,
documentation drift, `Comparable`, nominal wrappers, and ContainersPreview are not representation
blockers unless you identify a concrete safety, correctness, external-contract, or complexity
failure. The Bound DSL fix and `_O_UNCHECKED` empty-removal triage are deferred until this overall
validation is closed. Permutation compatibility work and the other recorded frozen tasks remain
frozen.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, the validation ledger,
other documentation, Package.swift, or workflows. Do not fix findings, stage, commit, push, switch
branches, or alter Git history. Prefer committed records and read-only inspection; run only a
narrow command needed to resolve a disputed claim. Run `git diff --check` and inspect
`git status --short` at the end.

Record the review in the first Result section below, set `Status: Completed`, and tell the user
only `完了` unless a product-owner choice remains.

### Result

2026-10-05, Claude Opus 5.5. Read-only review through `714252d1`. The only command I ran was the
P4 reproduction below.

**1. `P3 pass`.** The compatibility Release batch (120 XCTest, 4 intentional skips, 1 Swift
Testing) is configuration evidence for the legacy `UnsafeIndexV2` contract and the shared
resolver. As already classified, it is not direct success-only evidence. Limitation: the ledger
still records no exact command or `--filter` for this run, or for the normal Release and
`_O_UNCHECKED` runs. This is a bookkeeping gap, not a missing property.

**2. `P4 pass`.** I reproduced the batch in Debug at HEAD:

```
swift test --disable-sandbox --skip-build \
  --filter 'RedBlackTree(Set|MultiSet|Dictionary|MultiMap)(IndexValidityXCTests|IndexRangeTests|BidirectionalCollectionTests|CopyOnWriteTests)'
```

It executed 111 tests with 0 failures, matching the ledger. Scope note:
`BidirectionalCollectionTests` exists only for Set and MultiSet. Dictionary and MultiMap
movement is covered through their `IndexValidityXCTests` and `IndexRangeTests`. The Range View
evidence was reviewed previously.

**3–4. Classification of the remaining entries:**

| Item | Class | Reason / smallest closure |
| --- | --- | --- |
| `P2` | `intentionally unmapped` | The required lifetime properties already pass: stale, recycled, movement, MappedValues, detached marking, memory-safe outliving storage; in Debug, Release, narrow `_O_UNCHECKED`, and ASan. What remains is (a) a non-empty unrelated receiver, whose behaviour is documented as unspecified (生成元以外の木での使用は未定義), and (b) the exact internal `.detached` reason. Neither is a public contract |
| `P9` | `required before adoption verdict`, but only the complexity part | Closure is a source-inspection note in the ledger; no benchmark is needed. It must state: <br>(1) same-tree `__purified_` is a tie identity comparison plus one seal read, O(1); <br>(2) cross-tree resolution walks the fresh-pool buckets, O(1) under the single-bucket-after-CoW invariant (`_FreshPool.swift:112`); <br>(3) `index(_:)` builds `_LazyTieWrap` with no allocation per Index; the `lazyDetach` getter creates at most one tie per storage (`UnsafeTreeV2+BufferHeader.swift:157-165`); <br>(4) traversal uses `_Obverse4` raw pointers and never constructs or resolves an Index per element, so K-element traversal stays O(K); <br>(5) `==` / `hash` are O(1) (P7). <br>Real-time A/B measurement is `correction after verdict` (optional): it is not a Checklist gate, and this repository needs interleaved runs plus a machine-code comparison for any wall-clock claim |
| `P10` | `correction after verdict` | Design-record update. It must follow the verdict, as the entry itself says |
| `P11` | `correction after verdict` | Merge-artifact cleanup. Not a quality property |
| `P13` | `correction after verdict` | A DocC abstract regression in two doc comments, shared by every representation. Not a representation property |

**Side note, not a blocker and not new.** Creating the first Index on a shared, immutable
collection mutates the storage header lazily (`lazyDetach`). Concurrent first access from two
threads is therefore the already-frozen 「`lazyDetach`等の並行初期化保証」 item. The develop
representation has it too.

**5. One final evidence batch is enough.** It needs only:
- (a) the P9 complexity inspection note above;
- (b) the exact commands and filters for the normal Release, Release `_O_UNCHECKED`, compatibility
  Release, and P4 runs (copied from the shell history, not re-run).

No further independent batch is needed. After that, the ledger has positive evidence or
documented intentional unmapping for every required property, and the final verdict can be
issued. No adopt/reject verdict is given here.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows only
this file.

### Result

Pending.

---

## Completed assignment: independently review the accumulated Index PoC evidence batches

Independently review the committed evidence and corrections on `try/index/1` through
`beba869e`. The evidence ledger is `Maintanance/INDEX_POC_VALIDATION.md`. Preserve a separate
neutral verdict for every batch; do not collapse them into one overall adoption verdict.

Required batch verdicts:

1. `P14`: dual-representation call-site inventory — verify whether any normal public `Index` path
   can resolve to the old Result-valued overload family.
2. `P6`: external public-surface evidence — verify the classification of `UnsafeIndexV3` and
   `_LazyTiedPtr._NodePtr` as externally nameable prototype artifacts.
3. `P2/P3 Release`: review the normal Release pass, the broad `_O_UNCHECKED` scope-contaminated
   failure, and the narrower Index-specific `_O_UNCHECKED` pass.
4. `P3 compatibility Debug`: confirm that the passing compatibility batch tests the separate
   legacy Index contract and is not direct success-only evidence.
5. `P2/P3 ASan`: review the representative 64-test ASan pass and its stated limitations.
6. `P2 outliving storage`: review the new test proving detached marking and safe rejection by a
   live receiver; confirm that the document does not overclaim the exact internal error reason.
7. `P8`: review the stale-limit diagnosis and correction. Confirm that the bug existed in the old
   Result-valued implementation, that `edcf8c46`/`5e41e32b` correct that shared path, and that
   `425c02c3` correctly applies equivalent failure propagation to the success-only overload.
   Include the later `formIndex` backward-direction test committed in `beba869e`.
8. `P4`: review the KeyValue and KeyOnly bounded Range View tests and whether their half-open
   `isElement(at:)` / `isEnd(_:)` expectations match the public contract.

For each item return exactly one of `pass`, `fail`, or `unmapped`, followed by concise evidence and
any scope limitation. Then state whether the current ledger wording should be corrected. Do not
issue a final adopt/reject verdict; remaining breadth, performance, compatibility Release, cleanup,
and documentation work is intentionally unfinished.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, the validation ledger,
other documentation, Package.swift, or workflows. Do not fix findings, use network access, stage,
commit, push, switch branches, or alter Git history. Read-only inspection is allowed. Run only
narrow tests needed to resolve a disputed claim; do not rerun the whole matrix. Run
`git diff --check` and inspect `git status --short` at the end.

Record the review in the first Result section below, set `Status: Completed`, and tell the user only
`完了` unless a product-owner choice remains.

### Result

2026-10-05, Claude Opus 5.5. Per-batch neutral verdicts are below; there is no adoption verdict.
Inspection covered `try/index/1` through `beba869e`, read-only. I re-ran only the five tests whose
claims I reviewed, in Debug:

- the two StaleLimit exit tests (2 passed);
- the outliving-storage test (1 passed);
- the KeyValue and KeyOnly `isElementAndIsEnd_respectViewBounds` tests (2 passed).

| Batch | Verdict | Evidence / limitation |
| --- | --- | --- |
| **P14** dual representation | `pass` | Every non-Deprecated `_LazyTieWrappedPtr` reference is an old-family internal declaration: `index` / `index_or_nil`, movement, `___index` helpers, `__purified_`, and `band`. No public signature uses it apart from the public alias itself. The type system rules out the feared path: there is no implicit conversion between `_LazyTiedPtr` and `Result`, so a public `-> Index` context cannot select the old overload, and a public `Index` argument cannot enter the old movement family. Limitation: this is a declaration survey, not a compile-time proof. Marking the old family `@available(*, unavailable)` in a disposable experiment would make it mechanical |
| **P6** external surface | `pass`, with a classification correction | An external `swiftc -typecheck` against `.build/out/Products/Debug` accepted `UnsafeIndexV3`, `_LazyTiedPtr._NodePtr`, and `RedBlackTreeIndex`. However, `UnsafeIndexV3` and `_LazyTiedPtr` were already public and nameable on develop (`2796d7c2`). The PoC artifact is therefore (a) the removal of `@_documentation(visibility: internal)`, which changes DocC exposure, not nameability, and (b) the new nested `public typealias _NodePtr`. It mirrors the already-frozen `Result._NodePtr` item. The ledger should say this, not "externally nameable prototype artifacts" for both |
| **P2/P3** Release | normal Release `pass`; narrow `_O_UNCHECKED` `pass`; broad `_O_UNCHECKED` `unmapped` for the PoC | The scope-contamination reasoning is correct: `removeFirst` / `removeLast` on an empty collection are not Index paths, and `-Ounchecked` removes their `precondition`. Two limitations: (1) the ledger gives counts but not the exact `--filter` strings or full commands for either Release batch, so the batches are not reproducible as written; (2) the four "successful exits" are a **develop-side** observation that needs separate triage, because an unchecked empty `removeFirst` / `removeLast` may not be memory-safe. It is not PoC evidence |
| **P3** compat Debug | `pass` (classification confirmed) | In compat mode the containers' `Tree.Index` is `UnsafeIndexV2<Base>` (`UnsafeTreeV2+index+deprecated.swift:11`). It stores its own `_SealedPtr` plus `_TiedRawBuffer`, not `_LazyTiedPtr`. The batch therefore checks the legacy contract and the shared resolver, and is correctly `unmapped` as direct success-only evidence. Compat Release is still not run |
| **P2/P3** ASan | `pass` (scoped) | 64 XCTests with no report. The stated limitations are accurate. The ASan section's "does not cover … Index outliving its storage" is now stale, because the outliving test was later run under ASan |
| **P2** outliving storage | `pass` for the stated narrow property; the wording overclaims | Detached marking is verified, and memory safety holds: the cross-tree path reads only the Index's stored tag and seal, not its freed pointer. But the receiver in the test is **empty**, so `__retrieve_` fails on `tag < initializedCount` (0). With a **non-empty** receiver, the tag and seal of the outliving Index can match a live receiver node (for example tag 0 with seal 0). `deepPurified` would then succeed, and `isElement(at:)` could return `true`. That is the documented unspecified other-tree behaviour (`UnsafeIndexV3.swift`: 生成元以外の木での使用は未定義), not a rejection. "Safe public receiver-based rejection path" holds only for an empty receiver. I traced this in code and did not test it |
| **P8** stale limit | `pass` | `5e41e32b` (the old overload) and `425c02c3` (the success-only overload) both replace `let __l = __purified_(limit).map(\.pointer)` with `__purified_(limit).flatMap { … .success(limit.pointer) }`, which propagates a limit failure before traversal. The old structure confirms the bug was not representation-specific. The forward `index` test and the backward `formIndex` test (`beba869e`) both pass. `form_index`'s double `adv_iter` is retained. **Sibling instance outside the ledger:** the Bound DSL `.advanced(offset, limit:)` path (`UnsafeTreeV2+BoundsExpression.swift:86-90`) still passes `l = evaluate(__l)` unpropagated to `___tree_adv_iter`. A failed limit Bound is therefore ignored there by the same mechanism. It is shared with develop. Its classification needs a user decision, as the stale-limit case did |
| **P4** Range View bounds | `pass` | The KeyValue and KeyOnly half-open expectations match the public docs. The View's `endIndex` can be a base element; `isEnd` is `true` only for the view's end; the base `endIndex` is neither an element of the view nor its end (`RedBlackTreeRangeView+KeyValue.swift:474-480`; API-Matrix-View lines 39-42) |

**Ledger wording corrections:**

1. P6: reclassify as described in the table.
2. P2 outliving: limit "rejected by another receiver" to an empty receiver, and add the non-empty
   receiver case as `unmapped` (unspecified cross-tree acceptance).
3. Record the exact commands and filters for both Release batches.
4. Remove the stale "does not cover outliving" phrase from the ASan section.
5. Move the KeyOnly paragraph, which currently sits inside the ASan section, under P4.
6. Add two triage items:
   - the Bound DSL `.advanced(limit:)` sibling;
   - `_O_UNCHECKED` empty `removeFirst` / `removeLast` (develop-side).

**Product-owner choice:** whether the Bound DSL `limit:` failure should be treated as a bug, like
the stale-limit `limitedBy` case.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows only
this file.

### Result

Pending.

---

## Completed assignment: independently review P1 invalid-Bound coverage restoration

Review the uncommitted P1 test-only change and its evidence in
`Maintanance/INDEX_POC_VALIDATION.md`. The four container internal tests replaced their commented
failure-valued public Index assertion with `.index(.nullptr)` on a non-empty container.

Required checks:

1. Confirm the new assertion exercises the lost property (an invalid Index-bound is rejected)
   without reintroducing a public failure-valued Index.
2. Confirm every fixture is non-empty and therefore avoids the P5 `_emptyLazyDetach` same-tie null
   assertion hazard.
3. Check that `.index(.nullptr)` reaches the intended resolver failure path and that a passing
   Boolean assertion cannot be explained by an unrelated process trap.
4. Review the recorded Xcode result: 67 passed, 0 failed, and one `No result`. Confirm or refute that
   `erasingRangeFromAnotherSet_terminatesProcess()` was not compiled because
   `ALLOW_CROSS_TREE_INDEX` is enabled, and that its absence from `swift test list` makes the Xcode
   entry stale discovery metadata rather than a test failure.
5. Run only the four restored internal tests if needed. Do not expand into Release,
   `_O_UNCHECKED`, compatibility, sanitizer, or the next P2 batch.

Return a neutral evidence verdict exactly as one of: `P1 pass`, `P1 fail`, or `P1 unmapped`.
Record concise evidence in the first Result section, set `Status: Completed`, and tell the user only
`完了` unless a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the four tests, validation document,
source, other documentation, Package.swift, or workflows. Do not fix findings, use network access,
stage, commit, push, switch branches, or alter Git history. Read-only inspection and the four-test
Debug run are allowed. Run `git diff --check` and inspect `git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `P1 pass`.

1. **The lost property is restored, and no public failure-valued Index is reintroduced.**
   - Each of the four tests now runs `#expect(!x.isValid(.index(.nullptr)))`.
   - `.index(_:)` is the Debug-only `package static` on `RedBlackTreeBoundExpression`.
   - `.nullptr` is the Debug-only `_LazyTieWrap.nullptr` (`_LazyTieWrap.swift:142`).
   - Neither is public. The public Index stays success-only.
2. **The fixtures are non-empty.**
   - Set and MultiSet use `(0..<10)`.
   - Dictionary uses `uniqueKeysWithValues: (0..<10)…`.
   - MultiMap uses `keysWithValues: (0..<10)…`.
   - Only the `UnsafeTreeV2Buffer.empty()` singleton carries `_emptyLazyDetach`
     (`UnsafeTreeV2+Buffer.swift:105`). Non-empty buffers create their own tie on demand
     (`BufferHeader.swift:162`).
   - The synthetic Index therefore never shares the tree's tie, and the P5 hazard is avoided.
3. **The intended failure path is reached.**
   - `isValid(_ bound:)` is the test helper `self[bound] != nil`.
   - Bound evaluation, Debug `.index(let i)`, runs `switch __purified_(i)`
     (`UnsafeTreeV2+BoundsExpression.swift:129`).
   - With different ties, `ALLOW_CROSS_TREE_INDEX` takes the cross-tree branch,
     `__retrieve_(index.tag)`.
   - `tag` evaluates to `.failure(.null)` because `rawValue.trackingTag == .nullptr`. The
     singleton null node is created with `tag: .nullptr` (`unsafe_node.swift:270`).
   - The failure branch sets `ptr = .failure(.null)`, so the subscript yields `nil`.
   - A process trap cannot explain the pass: an in-process Swift Testing crash would fail the run,
     not satisfy `#expect`.
   - Limitation: the Boolean alone does not distinguish "rejected" from "resolved to end". The trace
     above shows that it is the rejection path.
4. **The Xcode `No result` entry is confirmed as stale discovery metadata.**
   - `erasingRangeFromAnotherSet_terminatesProcess()` sits under `#if !ALLOW_CROSS_TREE_INDEX`
     (`RedBlackTreeSet_99_DeathTests.swift:139`), and `ALLOW_CROSS_TREE_INDEX` is active
     (`Package.swift:25`).
   - `swift test list` contains 0 occurrences of it, so it is not compiled. It is not an executed
     failure.
5. **The four-test run passed.**
   - `swift build --disable-sandbox --build-tests` (Debug): succeeded.
   - `swift test --disable-sandbox --skip-build --filter 'InternalTests/boundExpressionIndexValidity'`:
     4 tests in 4 suites passed.
   - Nothing else was run: no Release, no `_O_UNCHECKED`, no compat, no sanitizer, and no P2.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows Codex's
four test files and the validation document plus this file.

---

## Completed assignment: agree or disagree with the success-only Index validation posture

The product owner has stated a strong preference to adopt the `try/index/1` success-only Index
representation. Independently review the resulting validation posture now recorded under
`## Product-owner direction` in `Maintanance/INDEX_POC_VALIDATION.md`.

The proposed posture is:

- treat the success-only Index representation as the leading implementation candidate, not one
  equally weighted option in a neutral bake-off;
- treat missing tests, documentation drift, prototype public-surface artifacts, and localized
  defects as correction work unless they expose a deeper contradiction;
- block or reject adoption only on concrete evidence that correctness, memory/Index lifetime,
  external contract, or required complexity cannot satisfy the Quality Checklist without
  abandoning the success-only representation;
- keep `Comparable`, a nominal public wrapper, and ContainersPreview conformance as later,
  separate decisions.

Assess whether this framing is technically coherent, preserves the existing Quality Checklist and
stop conditions, and avoids both confirmation bias and unnecessary reopening of already separated
design questions. Identify any wording that would make a serious defect too easy to classify as a
mere correction.

Return exactly one verdict: `agree with success-only validation posture`, `agree after specified
posture corrections`, or `do not agree with success-only validation posture`. Record concise
reasoning in the first Result section, set `Status: Completed`, and tell the user only `完了` unless
a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. This is a policy/agreement review, not a code
review. Do not inspect or comment on the currently uncommitted P1 test edits, edit the validation
document or other files, run builds/tests, use network access, stage, commit, push, switch branches,
or alter Git history. Read-only inspection of the Quality Checklist and recorded stop conditions is
allowed. Run `git diff --check` and inspect `git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `agree after specified posture corrections`.

**What is sound.**
- Making the success-only Index the leading candidate is coherent and legitimate. The owner prefers
  it, the PoC already compiles, and resolver diagnostics stay internal.
- The posture keeps the bar: "Passing this baseline is not adoption approval".
- It keeps all stop conditions.
- It correctly prevents `Comparable`, the nominal wrapper, and ContainersPreview from being
  smuggled in as rejection reasons.

**Where serious defects could be too easily reclassified.** There are three wording problems.

1. **Severity is conflated with remedy.** "localized defects are correction work unless they
   reveal a deeper contradiction" lets the *location* of a defect decide its handling.
   - A use-after-free, an out-of-bounds read, or the acceptance of a stale or recycled Index can sit
     in one function and still be a Quality Checklist §2 failure.
   - "Deeper contradiction" is undefined, so almost anything can be argued to be localized.
2. **The burden of proof is unfalsifiable.** "Rejecting requires concrete evidence that … cannot be
   made to satisfy … without abandoning the representation" asks for proof of impossibility. One
   can always say "it could be fixed". Adoption must instead rest on positive evidence for each
   Checklist property. A gap means `evidence incomplete`, not `adopt after corrections`.
3. **Corrections are not tied to re-verification.** Nothing says that a "correction" counts only
   after it has been re-verified under the same matrix. Without that, a planned fix can be counted
   as if it were evidence.

**Posture corrections** (replacement wording for the three bullets under
`## Product-owner direction`):

- Replace bullet 1 with:
  > Missing tests, documentation drift, and prototype public-surface artifacts are correction work.
  > Any failure of a Quality Checklist property — especially §2 memory safety and Index validity
  > (stale, recycled, detached, cross-tree, outliving storage, `_O_UNCHECKED`) — is a blocking
  > finding regardless of how localized its code is. It stops validation, is recorded before any
  > fix, and counts as resolved only after the fix is re-verified in every configuration where it
  > failed. It may be classified as correctable only if the demonstrated fix keeps the public Index
  > success-only.
- Replace bullet 2 with:
  > Adoption requires positive evidence for each applicable Quality Checklist property. If a
  > property fails and no fix within the success-only representation has been demonstrated, the
  > verdict is `adoption blocked by specified evidence`. Unmeasured or unmapped properties give
  > `evidence incomplete`. Neither outcome requires proving that a fix is impossible.
- Add a definition after bullet 2:
  > A deeper contradiction exists when any of the following holds:
  > - a required observable behavior can only be expressed by a failure value inside the public
  >   Index;
  > - validity checking needs more than O(1) per access, or adds per-element work to traversal;
  > - Index lifetime cannot be guaranteed without a different storage tie.
- Extend bullet 3 symmetrically:
  > …they are not reasons by themselves to reject this representation, nor evidence for adopting it.

**Process guard against confirmation bias** (no posture change needed beyond the above):

- Claude's independent tasks should produce per-property evidence: commands, configurations,
  counts, and stderr reasons. Each task should use a neutral pass / fail / unmapped outcome, not
  an adopt/block verdict.
- The adopt/block judgment should be made only at step 6, from that evidence.

**Residual, outside the posture.** `## Validation order` still lists step 1 (inventory review) as
pending, although it is done. Step 4 still includes "MappedValues View", which step 2 already
moved to first place. Both are wording-only fixes.

Checks: only this file was edited. I did not inspect the uncommitted P1 test edits.
`git diff --check` was clean. `git status --short` shows Codex's four test files plus this one.

---

## Completed assignment: independently review the merged Index PoC issue inventory

Review the merged `try/index/1` branch at `6bdcfecd` against `develop/misc/48` at `2796d7c2`.
Codex has created `Maintanance/INDEX_POC_VALIDATION.md` as an initial issue inventory. This is the
first validation gate after the user explicitly restarted work on the PoC.

The product owner has now stated a strong preference to adopt this success-only Index approach.
Treat it as the leading candidate. Do not lower the quality bar, but distinguish correctable
prototype gaps from evidence that would actually invalidate the representation.

Independently inspect the 24-path PoC-specific diff and the Quality Checklist. For each `P1`–`P12`
item, determine whether it is supported, overstated, understated, duplicated, or missing a critical
condition. Look especially for correctness or lifetime risks that compilation and the 69 passing
BoundExpression tests would not expose.

Required questions:

1. Is the develop-to-HEAD comparison the correct current PoC scope after the merge?
2. Does any source difference constitute an already-demonstrable defect rather than merely an
   unverified requirement?
3. Does the proposed representative pair (`RedBlackTreeSet` and
   `RedBlackTreeKeyValueRangeView`) exercise the right first boundary, or should another View be
   selected?
4. Are the stop conditions sufficient to prevent accidental redesign or premature horizontal
   expansion?
5. What is the smallest next executable validation batch after the inventory is corrected?

Return exactly one verdict: `approve initial PoC issue inventory`, `approve after specified
inventory corrections`, or `issue inventory misses a blocking product decision`. Record concise
evidence in the first Result section, set `Status: Completed`, and tell the user only `完了` unless
a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the inventory, source, tests, other
documentation, Package.swift, or workflows. Do not fix findings, run broad test matrices or
performance measurements, use network access, stage, commit, push, switch branches, or alter Git
history. Read-only repository inspection and narrow compile/test inspection of existing results are
allowed. Run `git diff --check` and inspect `git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified inventory corrections`.

No product-owner decision blocks the next step: P12 already keeps the nominal type, Comparable,
and ContainersPreview separate. Evidence came from a read-only reading of
`git diff 2796d7c2..HEAD` (on `try/index/1` at `6bdcfecd`, whose parents are `1b126ba3` and
`2796d7c2`). Nothing was built or run.

**Q1. Scope.** Correct. `merge-base(2796d7c2, HEAD)` = `2796d7c2`, so the two-dot diff is exactly
the net PoC delta on top of current develop. Two things are missing from the scope:

- The 10-04 merge (`1b126ba3`) and the new merge (`6bdcfecd`) resolutions are folded into that net
  delta. The X1 stop condition ("a conflict resolution has no recorded intent") is not carried
  over.
- The X1 identity map is still anchored at `aecbcddf` / `1b126ba3`. It should be recorded as
  superseded or re-anchored for this validation.

**Q2. Demonstrable defects.** I found none in production behavior. Two concrete problems are
visible in the diff and are missing or understated:

- **P13 (new, documentation regression).** In `RedBlackTreeDictionary+Index.swift` and
  `RedBlackTreeMultiMap+Index.swift`, `/// - Complexity: O( log count )` is inserted above the
  existing summary line ("Returns the index of the element with the given key."). The callout
  therefore becomes the first doc line and displaces the DocC abstract. This is a PoC artifact.
  Classify it with P11 as a cleanup item, but note that it is user-visible.
- **P14 (new, dual representation).** The old-type overloads still exist alongside the new ones,
  differing only in return type: `___index` / `___index_or_nil` returning `_LazyTieWrappedPtr` in
  the four containers, plus `UnsafeTreeV2.index(_:)`, the header `index(_:)`, and the
  form-/adv-iter family. Sources contain 31 non-Deprecated `_LazyTieWrappedPtr` references.
  - Overload resolution by return type currently selects the right one silently, so this is not a
    failure today. It is, however, the main place where an old-representation path can survive
    unnoticed.
  - Add a gate: list which call sites still resolve to `_LazyTieWrappedPtr`, and confirm that none
    is reachable from a public `Index`-typed API.
  - The new `_LazyTieWrap.isValid` (seal-only, `purified` without a tree) has no Sources consumer.
    Note that it does not reflect cross-tree / CoW resolution.

**Corrections to the existing items:**

- **P1.** Understated remedy. A Debug-only replacement already exists: `.index(.nullptr)` on a
  non-empty container. The synthetic Index takes the cross-tree path,
  `__retrieve_(tag = .failure(.null))`, and fails, so `isValid` returns `false`. Restore the four
  assertions this way. A public failure value is not needed.
- **P5.** Understated, and missing a critical condition. The synthetic `.nullptr` uses
  `_emptyLazyDetach`, and every storage-less (empty) tree shares that same tie
  (`UnsafeTreeV2+Buffer.swift:105`). On an empty tree, `__isSameLazyDetach` is therefore `true`,
  so the same-tree path `index.sealed.purified` runs on the nullptr sentinel and hits
  `assert(!pointer.___is_null)`. The intended `SealError` failure does not occur.
  - An exit test that only expects `.failure` can pass for the wrong reason.
  - Require any test built from `_LazyTieWrap.unsafe(tree:rawTag:)` or `.nullptr` to use a
    non-empty tree, or to assert the `SealError` message.
- **P7.** Overstated. This can be closed from code reading.
  - Synthesized `Hashable` / `Equatable` on `_NodePtrSealing` both cover pointer, seal, and
    `trackingTag` (the last only `#if !USE_LAZY_DETACH`, and derived from pointer). The old custom
    hash covered pointer and seal, so it was coarser but consistent.
  - `_LazyTieWrap.hash` still omits `lazyDetach` while `==` includes its identity. This is
    consistent, because the hash is coarser than equality.
  - Both are O(1). Downgrade P7 to "verified by inspection; keep one regression test".
- **P8.** Also add a check that `form_index(limitedBy:)` keeps develop's deliberate double
  `adv_iter` call (cache-line comment) unchanged, so that P9 timing is comparable.
- **P2 / P3 / P4 / P6 / P9 / P10 / P11 / P12.** Supported as written. For P11, also list the
  trailing blank lines in `_LazyTie.swift` and the duplicated `/// 過去の状態で封印する` doc line in
  `_NodePtrSealing.swift`.

**Q3. Representative pair.** Keep `RedBlackTreeSet`, but use `RedBlackTreeMappedValuesView`
instead of, or in addition to, KeyValue.

- Since `211ca2fc`, the MappedValues single-Index operations rely only on `__purified_` of the
  Index type: no membership check, O(1), and CoW migration inside the setter and `swapAt`. That
  makes them the most sensitive boundary for a change of Index representation.
- KeyValue can follow, because it shares the same tree path but adds range checks that can hide
  resolver faults.

**Q4. Stop conditions.** Add the following:

- (a) a merge conflict resolution, in either merge, without recorded intent;
- (b) any public `Index`-typed path resolving to a `_LazyTieWrappedPtr` overload (P14);
- (c) a Debug `assert` firing where a `SealError` trap was expected. Exit tests must check the
  `SealError` reason, not only `.failure` (P5).

With these added, the list prevents redesign and premature expansion.

**Q5. Smallest next executable batch.**

1. Correct the inventory as above.
2. **Test-only change:** restore the four P1 assertions via `.index(.nullptr)` on non-empty
   containers.
3. On the branch, Debug only, run the existing narrow suites for the pair:
   - the Set Index-validity, CoW, and Death tests;
   - `RedBlackTreeMappedValuesViewTests`;
   - the Dictionary MappedValues Death tests.
4. Record the commands, counts, and any stderr reasons.
5. Run Release and `_O_UNCHECKED` only after this passes. Stop on the first signal.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows Codex's
staged `INDEX_POC_VALIDATION.md` plus this file.

---

## Completed assignment: audit the remaining RedBlackTree backlog classification

Independently audit the current RedBlackTree tracking documents after the two test-responsibility
reviews. The user's temporary operating policy is that every remaining RedBlackTree item must now
be exactly one of:

1. Index work (including Index-dependent API, tests, performance, and documentation);
2. documentation-only work;
3. explicitly frozen until the user requests restart or makes the required product decision.

Inspect at least `Maintanance/PROGRESS_OVERVIEW.md`,
`Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`, `Tests/TESTING.md`, and the unchecked items in the
RedBlackTree API matrices. Identify any item whose current wording still appears to authorize an
unfrozen non-Index implementation task, any duplicate with inconsistent status, and any completed
item still presented as pending.

Pay particular attention to public-surface shrinking, Debug/Release protocol differences,
Memoize/external-consumer migration, ContainersPreview tracking, cross-tree/range/unsafeAddress
tests, and dead or unwired code. Do not decide Comparable, restart `try/index/1`, or reinterpret a
frozen item as active merely because it remains unchecked.

Return a compact table with the item, correct class (`Index`, `documentation`, or `frozen`), and the
exact tracking wording/status correction needed. If the documents already satisfy the policy, say
so explicitly. This is a tracking audit, not authorization to implement any item.

Return exactly one verdict: `backlog classification is consistent`, `classification needs the
specified documentation corrections`, or `classification needs product-owner decision`. Record
the findings in the first Result section, set `Status: Completed`, and tell the user only `完了`
unless a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, API matrices, or other
documentation. Do not inspect `try/index/1`, restart frozen work, build/test, use network access,
stage, commit, push, switch branches, or alter Git history. Read-only repository inspection is
allowed. Run `git diff --check` and inspect `git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `classification needs the specified documentation corrections`.

No product-owner decision is required. Every item already fits one of the three classes. The
problem is wording: a few entries still read as active, non-Index implementation work, and two
pairs are duplicated with inconsistent status. Read-only inspection covered
`PROGRESS_OVERVIEW.md`, `RED_BLACK_TREE_REMAINING_TASKS.md`, `Tests/TESTING.md`, `API-Matrix.md`,
and `API-Matrix-View.md`.

#### Items that need corrections

| # | Item (location) | Class | Correction |
| --- | --- | --- | --- |
| 1 | 「意図しない`public`をpackage/internal/TestSupportへ縮小」 (PROGRESS:153) and 「source compatibilityを意図する公開API以外を…縮小する」 (RED:523) | Index / frozen | Both read as an open, active shrink task. The independent batches are exhausted. The remainder falls into four groups: <br>• Index-binding (Index); <br>• G4 / G3 SignedDistance (deferred public-witness design); <br>• G5 / G6 / Memoize / Balanced / `Result` overloads / `_NodePtr` (frozen); <br>• BENCHMARK hooks (Index-returning hooks = Index, the rest frozen). <br>Append: 「（2026-10-05時点で独立縮小batchは無し。残りはIndex依存または凍結clusterのみ）」 |
| 2 | 「DebugとReleaseで公開protocol適合集合が変わる箇所を解消」 (PROGRESS:154) | Index + frozen | Replace 「いずれも保留中のcluster」 with 「Balanced群は凍結（executable API Matrix方針）、Debug比較群はIndex依存」 |
| 3 | 「TestCode専用の宣言と実験経路をproduction targetから分離する」 (RED:524) | frozen / Index | Still unfrozen wording, although B4-c is done. The only remainders are Balanced (Debug-only executable matrix → frozen) and the Debug Comparable group (Index). Append the same class note, or check it off and point to those clusters |
| 4 | 「B4-b: Memoize群は外部consumer 2件の移行後に…判断する」 (RED:522) | frozen | Append 「（外部consumer移行まで凍結）」. The wording is conditional, but it does not say frozen |
| 5 | 「Fで決定した`index(inserting:)`の提供範囲を実装・テストへ反映する」 and 「…`erase(exactly:)`…」 (RED:556-557) | Index | These duplicate RED:530-531 with stale wording. The scope was already decided (all four containers, plus naming) by review, not by F. Remove these two lines, or replace them with 「→ 上記K項目（530-531）へ統合」 |
| 6 | `index(inserting:)` / `erase(exactly:)` expansion (PROGRESS:180-181) | Index | The RED copies say 「Kで」, but the PROGRESS copies do not, so they read as immediately actionable. Prefix both with 「Kで（Index移行後）」 |
| 7 | 優先事項: 「現在の確認地点は、公開範囲の縮小と…Index契約の最終判断である」 (TESTING.md:17-18) | Index | Public-surface shrinking is no longer an active checkpoint. Reword to 「独立した公開範囲の縮小は区切り済み。現在の確認地点は…Index契約の最終判断である」 |
| 8 | 判断待ち: 「内部テスト層の区分、および生木テストと変更コストの均衡。」 (TESTING.md:83) | documentation (closed) | An unclassified leftover. Both test-responsibility reviews are now recorded in the bullets that follow it. Remove it, or mark it 「（TestSupport/DebugAdditionals・UnsafeNode/RawBuffer整理で完了）」 |
| 9 | 判断待ち: 「未結線コードを削除するかテストするか…」 (TESTING.md:102-104) | frozen | Stale. The decision is now staged deletion, decided item by item by the user. Reword to match PROGRESS:224 / RED:571: 「段階的に削除（個々の削除はユーザーが決定し、再開指示まで凍結）」 |
| 10 | 「公開面の監査・縮小は主経路A・Bで先に行う」 (RED, first bullet of 主経路と並行できる完成前の整理) | — | Minor. Since A and B are done, change 「先に行う」 to 「主経路A・Bで実施済み」 |

#### Already consistent; no change needed

- **Index:**
  - ContainersPreview / Comparable tracking (PROGRESS:167, RED:526 = D);
  - PROGRESS:170-179 and RED:529-540 (F–L, gate items 544-552);
  - the 「Kで処理するIndex依存タスク」 tests: cross-tree re-audit, erase range-sanitize test, and
    the MultiMap `unsafeAddress` Release check (RED:559-561);
  - the API Matrix TODOs (`index(inserting:)` and `erase(exactly:)` for MultiSet and Dictionary),
    which the legend defines as 採用済みで未実装.
- **Frozen, already labelled:**
  - the `try/index/1` PoC (PROGRESS:172, RED:528 = E);
  - `Result` overloads and `_NodePtr` (PROGRESS:221);
  - dead code (PROGRESS:224, RED:571);
  - Permutation compat (PROGRESS:227; not RedBlackTree);
  - OptionalArray / BareArray audits (PROGRESS:188-189; not RedBlackTree);
  - the 保留・完成を止めない追加検証 list (PROGRESS:233-239);
  - the TestSupport / DebugAdditionals frozen groups and the RawBufferHeadFixture alignment note
    (TESTING.md).
- **Completed items presented as pending:** none, other than #8 (and #5, which is a stale-wording
  duplicate).

This audit authorizes no implementation.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows only
`Maintanance/CLAUDE_TASK.md`.

---

## Completed assignment: repair the earlier `develop/misc/48` merge into `try/index/1`

The branch previously carried a Claude-reviewed merge-repair pass. The full pre-rotation task text
was superseded by the incoming current task log; this summary preserves the branch-specific result:

- The failureless public Index prototype was retained rather than reverted to the incoming
  `Result` representation.
- View conversion helpers and the active `_LazyTiedPtr` iterator paths were repaired for the moved
  source layout while retaining explicit `SealError` diagnostics and the intentional double
  `adv_iter` cache-line behavior.
- Relocated internal tests that attempted to construct failure-valued Index instances were disabled
  consistently with the prototype's earlier decision.
- Debug build/tests and a Release RedBlackTreeCollections build passed in that repair pass.
- Release tests, ASan, compatibility mode, and the full suite were not run. The invalid-Index bound
  coverage replacement remained a product-design question and was not guessed.

---

## Completed assignment: define the UnsafeNode / RawBuffer test-layer responsibilities

Take primary ownership of the remaining RedBlackTree test-organization review. Independently inspect
the UnsafeNode reference-fixture tests, RawBuffer/UnsafeTreeV2 single-layer tests, and the
UnsafeNode-versus-RawBuffer cross-check introduced on 2026-10-01. Determine what distinct defect
class each layer detects and whether the current intentional overlap is justified.

At minimum, trace these areas and their actual helpers/call sites:

- `Tests/RedBlackTreeFixture/UnsafeNodeReferenceFixture.swift`;
- `RawBufferHeadFixture` and `UnsafeNodeRawBufferCrossCheckTests` under the current
  `Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/` organization;
- the existing `MemoryLayoutTests`, `UnsafeNodeMemoryLayoutTests`, `BucketAllocatorTests`, and their
  `checkXxx` helpers or payload-type matrices;
- the current records in `Tests/TESTING.md` and `Tests/TESTING_REFERENCE.md`.

Answer:

1. What independently computed fact does each test layer establish?
2. Would consolidating the duplicated helper logic or payload matrices weaken fault independence?
3. Which duplication is deliberate verification redundancy, and which—if any—is merely accidental?
4. Is any code move, helper merge, or new test required now?
5. Can this item be closed through documentation alone so the RedBlackTree work remains limited to
   Index work, documentation, and explicitly frozen items?

Prefer preserving independent calculation paths when sharing would allow one defect to make both
sides agree incorrectly. Do not treat fewer lines or fewer fixtures as an objective by itself.

Return exactly one verdict: `retain independent test layers`, `consolidate specified test support`,
or `test-layer responsibility needs product-owner decision`. Record concise evidence and a concrete
remaining-work recommendation in the first Result section, set `Status: Completed`, and tell the
user only `完了` unless a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit, move, merge, rename, or delete tests,
fixtures, sources, or other documentation. Do not inspect `try/index/1`, restart frozen work,
build/test, use network access, stage, commit, push, switch branches, or alter Git history.
Read-only repository inspection is allowed. Run `git diff --check` and inspect
`git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `retain independent test layers`.

I inspected the test files and the production layout code read-only. Nothing was built or run.

#### 1. What each layer establishes independently

| Layer | Expected value comes from | Defect class detected |
| --- | --- | --- |
| `MemoryLayoutTests.checkMemoryLayout` | Arithmetic local to the test (`nodeStride + payload.stride`, `alignedUp`, `max(align)`) | `MemoryLayout<P>._pairLayout` (production `_MemoryLayout.init`, a bit-mask formula) and `__value_(as:)` placement wrong for one payload type |
| `UnsafeNodeMemoryLayoutTests.checkMemoryLayout` | The same kind of test-local arithmetic | `_advanced(with:count:)` ±1 movement and `__value_(as:)` address/alignment in the UnsafeNode layer |
| `BucketAllocatorTests.checkHeadAllocationSize` | Byte-ownership counting over the whole allocation (header / end_ptr / nodes / payloads) | Overlap, gaps, or out-of-bounds placement in `_headAllocationSize` + `start` + `_BucketAccessor`. No other layer catches this |
| `BucketMemoryLayoutTests` | Agreement between queue, accessor, and traverser | Two of the three access paths using different strides |
| `UnsafeNodeRawBufferLayoutAgreementTests` (2026-10-04) | Production reference functions against `_BucketAllocator` (`_referenceAlignment`/`_referenceStride`/`_referenceAllocationByteCount(prefix:)`/`_referenceFirstNode` vs `pairLayout`/`_allocationSize(prefix:)`/`start`), with prefixes 0, 1, and 3 bucket strides | The two production calculators diverging. `_referenceStride` rounds by division, `_MemoryLayout` by bit mask, and the two are written separately |
| `UnsafeNodeRawBufferCrossCheckTests` + both fixtures | `UnsafeNodeReferenceFixture` (`_advanced`) against `RawBufferHeadFixture` (`_BucketAccessor[i]`) | Per-element node offsets diverging at capacities 1, 2, 3, and 16 across 10 payload types, with element counts beyond 2 |

#### 2. Would consolidating weaken fault independence?

Yes.
- Each single-layer test computes its expected value without calling the code under test.
- If those expectations were moved into a shared helper, or into one of the fixtures, then a defect
  in that shared code would make both sides agree incorrectly. For example, if the "expected" side
  started using `_referenceStride`, a bug there would be invisible.
- The fixtures exist to reach the two production paths, not to provide expectations. Keeping them
  separate from the test-local arithmetic is the point.

#### 3. Deliberate redundancy versus accidental duplication

- **Deliberate:**
  - The two groups use different payload matrices (single-layer tests vs. the 10-type cross-check
    matrix).
  - Each layer computes the same layout fact in its own way.
  - `__value_(as:)` is used on both sides of the cross-check. This is acceptable because
    `MemoryLayoutTests` and `UnsafeNodeMemoryLayoutTests` verify `__value_` independently against
    test-computed addresses.
- **Accidental but harmless:**
  - `CrossCheck.testPairStrideMatchesAcrossLayers` asserts the same pair as
    `LayoutAgreementTests` (`_referenceStride` vs `pairLayout.stride`), just over a different type
    matrix. It adds coverage breadth, not an independent calculation path.
- **Fixture call form differs from production:**
  - `RawBufferHeadFixture` and `BucketAllocatorTests` call
    `start(storage:payloadOrPairAlignment: MemoryLayout<P>.alignment)`.
  - The production call sites (`_BucketAccessor`, `_BucketQueue`, `_BucketTraverser`) pass
    `pairLayout.alignment`.
  - The results are identical today. `start` branches only on whether the argument is at most the
    node alignment, and `max(node, payload)` falls in the same branch as `payload`.
  - However, the fixture is documented as measuring the actual layout. If `start` ever treats these
    two arguments differently, the fixture would silently stop measuring the production path.

#### 4. Is any move, merge, or new test needed now?

No.

#### 5. Can this item close through documentation alone?

Yes. The recommended documentation is:

- In `Tests/TESTING.md`, close the open item (line 86) by recording the layer → defect-class table
  above, and the rule that test-local expected arithmetic must not be shared with fixtures or
  production helpers.
- Optionally note the two minor items:
  - the duplicated stride assertion, kept for breadth;
  - the alignment-argument difference between `RawBufferHeadFixture` and production.
- If Codex wants zero ambiguity, the second item has an alternative: a one-line future fixture
  change to pass `pairLayout.alignment`. That is a frozen, optional follow-up, not required work.

With this, the RedBlackTree work stays limited to Index work, documentation, and explicitly frozen
items.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows only
`Maintanance/CLAUDE_TASK.md`.

---

## Completed assignment: classify `RedBlackTreeTestSupport` and `DebugAdditionals` responsibilities

Take primary ownership of the test-side responsibility review. Independently inspect
`Tests/RedBlackTreeTests/RedBlackTreeTestSupport/` and
`Tests/RedBlackTreeTests/DebugAdditionals/`, including their actual references from the test suite.
The goal is to leave the RedBlackTree area, for now, with only Index work, documentation work, and
explicitly frozen items. This assignment is classification and recommendation only; do not move or
delete code.

Classify the relevant files or coherent file groups into these three roles:

1. executable reusable infrastructure used by automated tests;
2. human-facing diagnostics or visualization support;
3. disabled, historical, transitional, or otherwise frozen experiments.

Then answer:

- What is the durable responsibility boundary between `RedBlackTreeTestSupport` and
  `DebugAdditionals`?
- Which current items are clearly in the correct location?
- Which items cross that boundary or have ambiguous ownership?
- Which disabled or historical groups should simply be marked frozen rather than moved or deleted?
- After applying that classification, does any concrete unfrozen implementation task remain in this
  area, or can it be reduced to documentation plus frozen follow-ups?

Use actual declarations and call sites as evidence. Existing notes in `Tests/TESTING_REFERENCE.md`
and `Tests/RedBlackTreeFixture/Fixtures.md` are inputs, not binding conclusions. A preliminary Codex
scan noticed active shared fixtures/assertions in `RedBlackTreeTestSupport`, active dump/Graphviz
helpers in `DebugAdditionals`, and several `#if false` or `#if DEBUG && false` clusters; verify or
correct that independently rather than assuming it is complete.

Return exactly one verdict: `approve responsibility boundary`, `approve after specified
reclassification`, or `responsibility boundary needs product-owner decision`. Record a concise
file/group classification and the resulting remaining-work recommendation in the Result section,
set `Status: Completed`, and tell the user only `完了` unless a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not move, rename, delete, or edit test/source
files or other documentation. Do not inspect `try/index/1`, restart any frozen audit, build/test,
use network access, stage, commit, push, switch branches, or alter Git history. Read-only repository
inspection is allowed. Run `git diff --check` and inspect `git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified reclassification`.

**Method.** Read-only. I read every file under `Tests/RedBlackTreeTests/RedBlackTreeTestSupport/`
(13 files) and `Tests/RedBlackTreeTests/DebugAdditionals/` (15 files), together with their
compile guards. For every distinctive symbol I searched for call sites across `Tests`. Some
names are generic (`.value`, `.index`, `lower`/`upper`), and I could not resolve those by text
search alone, so this report states only uses that I actually found. I did not compile anything.

#### Classification

| File / group | Guard | Role | Evidence (call sites) |
| --- | --- | --- | --- |
| TestSupport: `RedBlackTreeTestCase` | DEBUG blocks inside | 1 | Base class of 125+ XCTests. `PointerRedBlackTreeTestCase` is used by `BufferHeaderTests` and `UnsafeNodeTests`. The `RedBlackTreePair(key:value:)` helper is used here |
| TestSupport: `RedBlackTree{Set,MultiSet,Dictionary,MultiMap}+Test(ing)` | `DEBUG && !COMPAT` | 1 | `___tree_invariant(_for_fuzz)` is used by the four `_98_FuzzTests`. `_copyCount` is used by CoW, removal, and compat tests. `assertEquiv` is used by `Set_98_SetAlgebraStressTests` |
| TestSupport: `RedBlackTreeFixture`, `SplitMix64`, `DeathTestSignal`, `KeyValueComparer+Tuple`, `RedBlackTreePair+Testing`, `UnsafeIndexV3Range+Testing` | various | 1 | `RawBufferHeadFixture` and `UnsafeNodeRawBufferCrossCheckTests` (fixture); the four FuzzTests (RNG); `expectedSwiftTrapSignal` (11 files); `KeyValueComparerTests` (tuple payload); the Range View and comparator tests (`.lower`/`.upper`) |
| TestSupport: `FixtureAtCoder2025Support` | `DEBUG && COMPAT` | 1 | `___node_positions` and `___is_garbaged` are used by the four `*AtCoder2025CompatibilityTests` |
| TestSupport: `_NodePtr_.swift` | `#if false` plus an active tail | **3 + 1 mixed** | Lines 4–17 (`_TrackingTag.offset`) are disabled. The active `_TrackingTag.index` after `#endif` has no consumer I could resolve |
| DebugAdditionals: `UnsafeTreeV2+Dump`, `UnsafeTreeV2+GraphvizDebug`, `unsafe_node+dump` | DEBUG | 2 | No test call sites. They are reached only by a human from the debugger or from ad-hoc code. `dumpNode` is used only by `Dump` |
| DebugAdditionals: `_LazyTieWrap+Debug` (`Result.value: _TrackingTag`) | DEBUG | **1, misplaced** | Used by `*_98_IndexValidityXCTests` (`Index.unsafe(…).value`) |
| DebugAdditionals: `unsafe_node+debug` (`UnsafeMutablePointer<UnsafeNode>.index`) | DEBUG | **1, misplaced** | Used by `___RedBlackTreeContainerTests_unsafe.swift:211` (`tree.__root.index`) |
| DebugAdditionals: `ThreeWay+Old/` (3 files) | DEBUG, compiled | **3, but exercised** | Comments say 資料的に残している / 期待したほどじゃなかった. The only consumer is `RedBlackTreeInternal_98_CoverageTests`, which covers `___default_three_way_comparator`. The other `__lazy_synth_three_way_comparator` hits are separate same-named declarations in other targets and production |
| DebugAdditionals: `UnsafeTreeV2+Testing` (tag-based `__left_(_:)` etc.), `RedBlackTreeDebugFixture` | DEBUG, compiled | **3 (orphaned)** | Their only consumer I found is `RedBlackTreeSet+UnsafeTreeDebug.swift`, which is `#if DEBUG && false` |
| DebugAdditionals: `TransitionFromLegacy/` (3 files), `RedBlackTreeSet+UnsafeTreeDebug`, `___Node.swift` | `DEBUG && false` / `false` | 3 | Disabled. `___Node` is one of the three deliberately kept same-named `___Node`s (user decision not to unify) |

#### Answers

- **The durable boundary is set by purpose, not by mechanism.** Both directories use `#if DEBUG`
  plus `@testable` extensions on internals, so that cannot be the dividing line.
  - `RedBlackTreeTestSupport` holds code that an automated test calls: fixtures, invariants and
    assertions, base classes, the RNG, signal constants, test-only initializers, and accessors.
  - `DebugAdditionals` holds human-facing diagnostics (dump, Graphviz) and frozen reference or
    transition code.
- **Correctly located:**
  - all of TestSupport except `_NodePtr_.swift`;
  - Dump, Graphviz, and `unsafe_node+dump` in DebugAdditionals;
  - the disabled transition groups.
- **Crossing the boundary:**
  - `_LazyTieWrap+Debug` and `unsafe_node+debug` are active test infrastructure, so they belong in
    TestSupport.
  - `_NodePtr_.swift` mixes a frozen block with an active extension.
  - `ThreeWay+Old` is frozen reference code that is still compiled and kept alive only by a
    coverage test. It stays where it is, but it should be labelled as frozen, not as
    infrastructure.
- **Mark frozen; do not move or delete:**
  - `TransitionFromLegacy/`;
  - `RedBlackTreeSet+UnsafeTreeDebug` together with its orphaned helpers `UnsafeTreeV2+Testing`
    and `RedBlackTreeDebugFixture`;
  - `___Node.swift`;
  - `ThreeWay+Old/`;
  - the `#if false` block in `_NodePtr_.swift`.

  Removing any of these touches same-name / era history, which belongs to the user.

#### Remaining work

No unfrozen implementation task remains in this area.

- **Documentation.** Record the purpose-based boundary and the frozen list above, for example in
  `Fixtures.md` or `TESTING.md`. This is Codex's domain.
- **Optional mechanical follow-up (tiny, not required).** Move `_LazyTieWrap+Debug.swift` and
  `unsafe_node+debug.swift` into TestSupport. Either do the move, or record them as documented
  exceptions; nothing else in the area needs to change.
- **Not decided by this review.** If anyone wants the orphaned `UnsafeTreeV2+Testing` or
  `RedBlackTreeDebugFixture` removed, that is a separate user decision. They may be needed again
  if the disabled debug file is revived.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows Codex's
files plus this one.

---

## Completed assignment: review the package-wide `AcCollections` facade

Independently review the current uncommitted facade change. The product decision is fixed:
`AcCollections` re-exports every current collection module, and a module is removed from the facade
later only if it is confirmed not to meet the package's quality requirements.

Expected normal-mode facade:

- `RedBlackTreeCollections`
- `PermutationModule`
- `OptionalArrayModule`
- `BareArrayModule`

AtCoder 2025 compatibility mode additionally re-exports the legacy `RedBlackTreeModule` shim.

### Required review

1. Verify `Package.swift` dependencies and `Sources/AcCollections/AcCollections.swift` implement
   exactly the expected normal and compatibility surfaces without redundant or missing imports.
2. Verify `AcCollectionsTests` proves reachability through `import AcCollections` alone for all four
   defining modules. Check that the sample operations are valid public uses and not made visible by
   another explicit test import.
3. Review both new DocC module pages for factual accuracy, module ownership, compatibility wording,
   and unsupported guarantees.
4. Check `PROGRESS_OVERVIEW.md` and `Tests/TESTING.md` accurately record the decision without
   claiming the unfinished OptionalArray/BareArray quality audits are complete.
5. Run the `AcCollectionsTests` target and a normal build. If practical within the existing project
   setup, also check that both DocC catalogs are recognized; do not expand into a full documentation
   audit.

Return exactly one verdict: `approve all-module AcCollections facade`, `approve after specified
corrections`, or `reject all-module AcCollections facade`. Record concise evidence in `### Result`,
set `Status: Completed`, and tell the user only `完了` unless a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, DocC, other maintenance
files, Package.swift, or CHANGELOG. Do not inspect `try/index/1`, change any module's public API,
perform its quality audit, use network access, stage, commit, push, switch branches, or alter Git
history. Run `git diff --check` and inspect `git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified corrections`.

The facade, the tests, and the progress records are correct. The two corrections concern a DocC
sentence and an untracked catalog.

1. **Surfaces are exact.**
   - `Package.swift` (unchanged): the `AcCollections` target already depends on
     `RedBlackTreeCollections`, `RedBlackTreeModule`, `PermutationModule`, `OptionalArrayModule`,
     and `BareArrayModule`.
   - `AcCollections.swift` now `@_exported import`s the four collection modules unconditionally.
     Under `#if COMPATIBLE_ATCODER_2025` it imports only `RedBlackTreeModule`.
   - `PermutationModule` has moved out of the compat block, with no duplicate import left behind.
   - `RedBlackTreeModule.swift` is just `@_exported import RedBlackTreeCollections`. Re-exporting it
     in compat mode is therefore redundant at the symbol level, but intentional for the module name.
2. **Reachability is proven through `import AcCollections` alone.**
   - The `AcCollectionsTests` target depends only on `AcCollections` and `RedBlackTreeCollections`.
     The file imports `AcCollections`, and imports `@testable RedBlackTreeCollections` only under
     `#if DEBUG`, for the lifetime counters.
   - `PermutationModule`, `OptionalArrayModule`, and `BareArrayModule` are not dependencies of the
     test target and are not imported by it, so the three new tests can compile only through the
     facade.
   - The sample calls are public API: `Array.nextPermutations()`;
     `OptionalArray1D(capacity:)` with `subscript(position:) -> Element?`
     (`OptinalArray.swift:28,64`); `BareArray(repeating:count:)` with
     `subscript(position:)` (`BareArray.swift:24,51`).
   - In Release, the RedBlackTree tests also rely on the facade alone.
3. **DocC pages.**
   - `AcCollections.md` is accurate. It covers ownership ("does not declare collection types of its
     own"), the compat-mode wording, and the inclusion policy. "bare multidimensional arrays" is
     slightly loose, because 1D `BareArray` is included, but it is acceptable.
   - `RedBlackTreeModule.md` contains one unsupported recommendation: "New code should import
     `RedBlackTreeCollections` directly". The package's only product is
     `.library(name: "AcCollections")` (`Package.swift:122`). `RedBlackTreeCollections` is not
     exposed as a product, so external clients have no supported way to import it.
4. **Records.** `PROGRESS_OVERVIEW.md` and `Tests/TESTING.md` record the facade decision only. The
   OptionalArray and BareArray audit rows and checkboxes stay open, and the existing note that test
   progress is not comment-doc completion is kept. No audit is claimed as complete.
5. **Validation.**
   - Normal mode: `swift build --disable-sandbox --build-tests` succeeded.
   - `swift test --skip-build --filter AcCollectionsTests`: 6 tests passed, including the three new
     `exposesNextPermutations`, `exposesOptionalArray`, and `exposesBareArray`.
   - Compat mode: `swift build --target AcCollectionsTests -Xswiftc -DCOMPATIBLE_ATCODER_2025`
     succeeded.
   - DocC: Release `generate-documentation --warnings-as-errors` for both `--target AcCollections`
     and `--target RedBlackTreeModule` succeeded, writing into a `mktemp -d` directory that was then
     removed. Both catalogs were recognized (`accollections`, `redblacktreemodule`). The only
     output was the existing compiler warning "-Ounchecked … strict memory safety", which is not a
     DocC warning.

**Corrections:**

- **(a)** `RedBlackTreeModule.md`, last paragraph. Replace with: "New code should import
  `AcCollections`, the package's library product."
- **(b)** `Sources/_RedBlackTreeModule/RedBlackTreeModule.docc/` is untracked (`??`), whereas
  `AcCollections.docc` is staged. Add it with the batch, or the catalog will be missing from the
  commit.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows Codex's
files plus this one.

### Codex follow-up

Accepted both corrections. The legacy-module page now directs new external clients to the
`AcCollections` library product rather than the non-product `RedBlackTreeCollections` target. The
untracked `RedBlackTreeModule.docc` catalog will be explicitly included in the batch commit.

---

Status at completion: Completed

## Completed assignment: call-site review of the scheduler handle workflow

Re-evaluate the insertion-Index API name using the new executable main-use-case experiment, rather
than relying primarily on abstract naming rules.

Read
`Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_5_InsertionTests.swift`, especially
`test_indexInserting_linuxSchedulerStyleRunQueueExperiment()`. The modeled workflow is a Linux
scheduler-style red-black-tree run queue: order runnable tasks by virtual runtime, retain the node
position returned at enqueue time, and later dequeue a sleeping task through that saved handle
without searching by value again.

### Questions

1. At the actual call sites below, is the operation immediately readable to a Swift user?
   - `let backgroundNode = runQueue.index(inserting: background)`
   - `runQueue.erase(exactly: backgroundNode.index)`
2. Is `index(inserting:)` memorable and discoverable when a user remembers the concept as either
   "enqueue and retain its node/index" or "insert and give me a handle"?
3. Does the tuple force awkward `.index` repetition (`backgroundNode.index`), and if so is that a
   naming problem, a local-variable problem, or a return-contract problem?
4. Write the same short workflow using each serious alternative from the prior review. Judge the
   complete two-line enqueue/dequeue pair, not the insertion method in isolation.
5. Consider whether Swift-facing terminology should remain `Index` rather than expose the
   implementation idea of a node or generic handle. Do not rename the public Index type.
6. Give a concrete recommendation for the declaration and the clearest natural local-variable
   naming pattern. A previous `retain index(inserting:)` verdict is not binding; change it if the
   executable usage exposes a better API.

Return exactly one verdict: `retain index(inserting:) after call-site review`, `rename to <exact
declaration base name>`, or `return contract must be decided first`. Record a concise comparison
and preferred example in `### Result`, set `Status: Completed`, and tell the user only `完了` unless
a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the experiment, source, other tests,
API Matrix, maintenance decisions, DocC, or CHANGELOG. Do not implement the four-container
expansion, inspect `try/index/1`, use network access, build/test, stage, commit, push, or alter Git
history. Read-only repository inspection is allowed. Run `git diff --check` and inspect
`git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `retain index(inserting:) after call-site review`.

I read `test_indexInserting_linuxSchedulerStyleRunQueueExperiment()` (uncommitted, in
`RedBlackTreeSet_5_InsertionTests.swift`). This review was read-only; I built and ran nothing.

1. **Readability.** `runQueue.index(inserting: background)` and
   `runQueue.erase(exactly: backgroundNode.index)` are both understandable at a glance: "give me
   the index, inserting X" and "erase exactly this position". The friction in the experiment does
   not come from either method name. It comes from the local variable:
   `backgroundNode` holds a **tuple**, not a node. `.index` then reads as "the node's index".
2. **Memorability and discoverability.**
   - "Enqueue and keep its index" maps directly onto the name.
   - "Insert and give me a handle" does not: a user who types `runQueue.insert` will not find it
     in completion. This is the real cost of the name.
   - An `insert…`-prefixed name would gain completion but loses on the call-site reading (item 4).
     The cheaper fix is documentation: add a See Also link to `index(inserting:)` from each
     container's `insert(_:)`, and from `erase(exactly:)`.
3. **The `.index` repetition is a local-variable problem**, not a naming or return-contract one.
   The contract `(inserted: Bool, index: Index)` matches the swift-collections precedent
   `OrderedSet.append(_:) -> (inserted: Bool, index: Int)`, and that precedent is used
   destructured. Keep the tuple. In the scheduler case `inserted` is uninteresting, because the
   pid tie-break makes tasks unique, but for Set and Dictionary it matters in general.
4. **The whole enqueue/dequeue pair, written with each candidate:**

   ```swift
   // index(inserting:)
   let (_, backgroundIndex) = runQueue.index(inserting: background)
   runQueue.erase(exactly: backgroundIndex)

   // insertAndReturnIndex(_:)  — "AndReturnIndex" is redundant, and inaccurate: it also returns `inserted`
   let (_, backgroundIndex) = runQueue.insertAndReturnIndex(background)
   runQueue.erase(exactly: backgroundIndex)

   // insertReturningIndex(_:)  — the same inaccuracy; reads as a variant of SetAlgebra insert(_:)
   let (_, backgroundIndex) = runQueue.insertReturningIndex(background)
   runQueue.erase(exactly: backgroundIndex)

   // ensureIndex(for:)  — reads as a lookup, and is dishonest for MultiSet/MultiMap
   let (_, backgroundIndex) = runQueue.ensureIndex(for: background)
   runQueue.erase(exactly: backgroundIndex)
   ```

   Read as a pair, `index(inserting:)` / `erase(exactly:)` is the shortest. Its first line is the
   only one whose base name matches what is kept, an index, and nothing in it is redundant.
5. **Keep "Index" as the Swift-facing term.** "Node" exposes the implementation, and "handle"
   suggests ownership or lifetime guarantees beyond the Index contract. The experiment's local
   names (`interactiveNode`, `backgroundNode`) and its comment "saved node handle" should become
   `…Index` / "saved index". This is an edit to the experiment, so it is Codex's call; I did not
   make it.
6. **Recommendation.**
   - Declaration: unchanged.

     ```swift
     @discardableResult
     public mutating func index(inserting newMember: Element) -> (inserted: Bool, index: Index)
     ```

   - Preferred call-site pattern:

     ```swift
     let (_, backgroundIndex) = runQueue.index(inserting: background)
     // … later, when the task sleeps:
     runQueue.erase(exactly: backgroundIndex)
     ```

     When only the index is needed, use `let backgroundIndex = runQueue.index(inserting: background).index`.
   - Add a DocC See Also link from `insert(_:)` to `index(inserting:)`.
   - The earlier naming result's requirements still apply to the four-container expansion: fix the
     MultiMap doc comment, and specify the Dictionary existing-key behaviour.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows Codex's
uncommitted files plus this one.

---

Status at completion: Completed

## Completed assignment: review the `index(inserting:)` API name

Perform an independent API-naming review before the already-approved four-container expansion of
`index(inserting:)`. This is naming and contract analysis only; implementation remains deferred.

Codex's provisional recommendation is to retain `index(inserting:)`: the primary result is an
Index, the argument label makes the insertion side effect visible, and the same spelling can cover
unique and multi containers. Rejected provisional alternatives are `insertAndReturnIndex(_:)` as
overly procedural and `ensureIndex(for:)` because MultiSet/MultiMap always insert a new element.

### Required review

1. Inspect the current Set and MultiMap declarations, documentation, tests, API Matrix entries, and
   adjacent insertion/index naming in all four containers.
2. Evaluate `index(inserting:)` under Swift API naming conventions at the call site. Explicitly
   compare it with at least `insertAndReturnIndex(_:)`, `insertReturningIndex(_:)`, and
   `ensureIndex(for:)`; add another serious candidate only if it is materially better.
3. Account for the semantic split:
   - Set/Dictionary are unique-key containers and may return an existing position;
   - MultiSet/MultiMap always insert a new occurrence;
   - the API must return the usable position in every case.
4. Determine whether one shared name remains honest across all four containers. Do not assume the
   existing `(inserted: Bool, index: Index)` result shape must be identical for all four; identify
   any return-label issue that must be settled alongside the name.
5. Review `erase(exactly:)` only for consistency with the paired workflow. Do not redesign it
   unless its spelling makes the recommended insertion name misleading.
6. Separate naming conclusions from Index representation, Comparable, `try/index/1`, and the
   implementation gate. `try/index/1` is explicitly deferred until the user requests its restart.

Return exactly one verdict: `retain index(inserting:)`, `rename to <exact declaration base name>`,
or `naming decision blocked by return contract`. Record concise reasoning in a `### Result`
subsection below, set `Status: Completed`, and tell the user only `完了` unless a product-owner
decision is required.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, API Matrix, other
maintenance files, DocC, or CHANGELOG. Do not implement APIs, switch branches, inspect
`try/index/1`, use network access, build/test, stage, commit, push, or alter Git history. Use only
read-only repository inspection, then run `git diff --check` and inspect `git status --short`.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `retain index(inserting:)`.

This is read-only inspection; no build was run. It is independent of the Index representation,
Comparable, `try/index/1`, and the implementation gate.

1. **Current state.**
   - Set (`RedBlackTreeSet+Index.swift:284`) and MultiMap (`RedBlackTreeMultiMap+Index.swift:307`)
     declare `mutating func index(inserting newMember: Element) -> (inserted: Bool, index: Index)`
     with `@discardableResult`.
   - Both are guarded by `!COMPATIBLE_ATCODER_2025 && ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH`.
   - Tests: `RedBlackTreeSet_5_InsertionTests.swift:235,248` and
     `RedBlackTreeMultiMap_5_InsertionTests.swift:99,102`.
   - Adjacent naming in all four containers: `insert(_:)` returns
     `(inserted: Bool, memberAfterInsert: Element)`. That includes MultiSet (`RedBlackTreeMultiSet.swift:236`)
     and MultiMap (`:264,280`), where `inserted` is always `true`. The insertion family also has
     `insert(_:hint:)`, `update(with:)`, and `updateValue(_:forKey:)`.
2. **Call-site reading.**
   - `let (inserted, i) = set.index(inserting: x)` reads as "the index, inserting x". The argument
     label states the side effect, and the base name states the primary result.
   - The cost: Swift API guidelines say methods with side effects should read as imperative verb
     phrases, and `index(…)` is otherwise a non-mutating family (`index(after:)`, `index(forKey:)`).
     This is acceptable here. `mutating` is enforced by the compiler, so it cannot be called on a
     `let` or used as a silent query, and the label `inserting:` makes the mutation explicit.
   - The verb-led alternatives are worse:
     - `insertAndReturnIndex(_:)` is procedural; "AndReturn" restates the return type.
     - `insertReturningIndex(_:)` is non-idiomatic. It also reads like a variant of `insert(_:)`
       while returning a different shape, which invites confusion with the SetAlgebra
       `insert(_:)`, whose return type cannot change (the source comment notes this).
     - `ensureIndex(for:)` is dishonest for MultiSet/MultiMap, which always add a new occurrence;
       "ensure" implies idempotence.
     - Overloading `insert(_:)` by return type alone would be ambiguous under
       `@discardableResult`.
   - No materially better candidate exists.
3. **Semantic split.** One name stays honest across all four containers:
   - Set and Dictionary may return an existing position with `inserted == false`, which matches
     `Set.insert`.
   - MultiSet and MultiMap always insert and return the new occurrence.
   - "inserting" names the attempted action in both cases, exactly as `insert(_:)` already does
     across the same four containers.
4. **The return contract is not blocking; precedent settles it.** Every container's `insert(_:)`
   already keeps `inserted` even where it is constantly `true`, so the uniform
   `(inserted: Bool, index: Index)` shape should be kept for all four. Settle these points
   alongside the expansion:
   - **(a) Bug to fix with the expansion.** The MultiMap doc comment is copied from Set. It says
     "inserting it if necessary" and "If an equivalent element is already present, `inserted` is
     `false`…". Both are false for MultiMap. The MultiSet/MultiMap doc should say that a new
     occurrence is always inserted, that `inserted` is always `true`, and that `index` refers to
     the new occurrence.
   - **(b) Dictionary must specify existing-key behaviour.** Follow `insert(_:)`: the stored value
     is not replaced, and `index` refers to the existing pair. The overwrite form remains
     `updateValue(_:forKey:)`. Without this sentence, "inserting" is ambiguous for a key-value
     container.
   - **(c)** `@discardableResult` can stay. The method's purpose is the index, but discarding it
     degrades only to an ordinary insert.
5. **`erase(exactly:)`.** It pairs consistently:
   `let i = s.index(inserting: x).index; …; s.erase(exactly: i)`. The `erase` verb plus a
   distinguishing label is the library's existing removal style, and it returns the successor
   `Index?`. Its spelling does not make `index(inserting:)` misleading, so no redesign is needed.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows only
`Maintanance/CLAUDE_TASK.md`.

---

Status at completion: Completed

## Completed assignment: review O(1) MappedValues single-Index operations

Independently review the current uncommitted change that removes the per-operation View-range
membership search from `RedBlackTreeMappedValuesView` subscript access and `swapAt(_:_:)`.

The product decision is fixed: as with standard Collection Index operations, an Index passed to a
single-Index operation must belong to the View; violating that precondition has unspecified
behavior. These operations must not pay O(log N) to prove View membership. The explicit
`isElement(at:)` query and range/Bound operations remain checked and are not part of this change.

### Required review

1. Confirm that removing the three `isElement(at:)` calls eliminates key comparisons from the
   getter, setter, and `swapAt(_:_:)` normal paths.
2. Trace `_unsafeAddress`, `_unsafeMutableAddress`, `__purified_`, and the `accessible` result far
   enough to determine whether invalidated, stale/recycled, detached, end, and otherwise
   unresolvable indices still fail without unsafe memory access, including under `-Ounchecked`.
3. Check CoW index migration in the setter and `swapAt(_:_:)`; in particular, verify that an Index
   accepted before `_ensureUnique()` still resolves to the corresponding node after a copy.
4. Review the three removed death tests. Confirm that same-tree-but-outside-View cases, including a
   View `endIndex` that is still a base-tree element, must no longer assert a controlled trap.
5. Check that the new comparison-count regression test actually isolates the three single-Index
   operations and cannot pass while an O(log N) membership search remains.
6. Check the source comments and `API-Matrix-View.md` against the fixed contract. Flag any claim
   that is broader than the implementation or inconsistent with cross-tree configurations.
7. Run the focused MappedValues tests and a normal Xcode build if available. Do not broaden this
   into the unresolved Comparable/Index PoC design or range-operation redesign.

Return exactly one verdict: `approve O(1) MappedValues Index operations`, `approve after specified
corrections`, or `reject O(1) MappedValues Index operations`. Record concise evidence under a
`### Result` subsection below, set `Status: Completed`, and tell the user only `完了` unless a
product-owner decision is required.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Review all four current changed implementation,
test, and documentation files plus the minimum Index-validation dependencies needed for the safety
trace. Do not edit source/tests/docs, switch branches, inspect `try/index/1`, use network access,
stage, commit, push, or alter Git history. Do not run the full test suite. Run `git diff --check`
and inspect `git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified corrections`.

The implementation change is correct. Both corrections are test-only, and neither is a safety
regression.

1. **Key comparisons are gone from the normal paths.**
   - The removed `isElement(at:)` (`RedBlackTreeMappedValuesView.swift:362`) called
     `_NodeKey.isInHalfOpenRange`. That function calls `lessThan`, which compares
     `_NodeKey(.key(Base._Key))` values, that is, key `<`.
   - After the change, the getter, setter, and `swapAt` paths are `__purified_` → `.accessible` →
     pointer only. None of them makes a key comparison.
2. **Unresolvable indices still fail safely, including under `-Ounchecked`.**
   - The getter goes through `_unsafeAddress`; the setter goes through `_unsafeMutableAddress`
     (`UnsafeTreeV2+Subscript.swift:28-45`).
   - `_unsafeMutableAddress` switches on `__purified_(position).accessible` and calls `fatalError`
     on failure. That is not `precondition` or `!`, so `-Ounchecked` does not remove it.
   - `swapAt` uses `guard … .accessible.pointer else { fatalError }`.
   - Same tree: `index.sealed.purified` rejects a seal mismatch (stale or recycled) as `.unsealed`
     (`_NodePtrSealing.swift:100`).
   - Cross tree in the default config (`ALLOW_CROSS_TREE_INDEX` on, `USE_LAZY_DETACH` off):
     - `__retrieve_(tag).deepPurified` returns `.unknown` when the tag is at or beyond
       `initializedCount`.
     - `deepPurified` itself returns `.garbaged` for a node without payload, and `.unsealed` for
       a seal mismatch.
   - `.accessible` maps the end node and garbaged nodes to `.garbaged`.
   - The node memory being validated is kept alive by the index's `_LazyTie`.
   - This is the same validation `isElement(at:)` ran first; the removed code added only the
     range-membership test, never a safety check.
3. **CoW index migration is correct in the default config.**
   - `_ensureUnique()` copies the tree and re-retrieves `_sealed_start` / `_sealed_end`.
   - The caller's index still refers to the old tree, so `__purified_` takes the cross-tree path
     and resolves it by tracking tag in the copy.
   - The new test exercises this path, because `values` shares storage with `dictionary`.
   - Pre-existing, not a regression: without `ALLOW_CROSS_TREE_INDEX`, a caller's index taken
     before the copy fails with `.crossTree` after `_ensureUnique()`. The old code behaved the
     same way after its `isElement` check passed.
   - Cross-tree resolution walks the fresh-pool buckets (`_FreshPool.swift:112`). That is O(1)
     under the documented single-bucket-after-CoW invariant.
4. **The three removed death tests are correctly removed.** All three used indices that were valid
   base-tree elements but outside the View (`startIndex` below a lower bound, and the View's
   `endIndex` while it was still a base element). Under the fixed contract these are
   unspecified-behaviour cases, and they are memory-safe because the nodes are live, so no
   controlled trap can be required of them.
5. **The comparison-count test does isolate the three operations.**
   - Against the old code it would fail: `lessThan` short-circuits only when the two nodes are
     equal. `first` equals the View's start node, but it is still compared with the View's end,
     `upper`, which is a base element with key 4. So the getter, setter, and `swapAt` would each
     count at least one `<`.
   - Robustness note: the test depends on `upper` being a base element. If the View's end were
     `.end`, no key `<` would run, and an O(log N) check could slip through.
6. **Docs are consistent with the contract.** The doc comments (`Precondition` / `Complexity: O(1)`)
   and `API-Matrix-View.md` match it. "対象のtreeで要素へ安全に解決できないIndexは下層のIndex検証で拒否する" is no
   broader than the implementation:
   - In the no-cross-tree configuration, a CoW-copied index is one that cannot be resolved, so it
     is rejected.
   - An index from an unrelated tree can resolve to an unrelated live node. That is memory-safe,
     and `UnsafeIndexV3.swift` already documents it as unspecified.
7. **Validation.**
   - `swift build --disable-sandbox --build-tests`: succeeded.
   - `swift test --skip-build --filter RedBlackTreeMappedValuesViewTests`: 17 tests, 0 failures.
     The new `test_subrangeValuesSingleIndexOperations_doNotCompareKeys` was discovered and passed.
   - No Xcode build and no full suite were run.

**Corrections (tests only):**

- **(a)** With the three removals, no MappedValues test remains that pins the safety half of the
  contract. Add death tests to `RedBlackTreeDictionary_99_DeathTests.swift`, each using
  `observing: [\.standardErrorContent]` plus `expectNoInvalidMemoryAccess`. They should check that
  the following terminate without invalid memory access:
  - `values[i]` where `i` was erased from the base;
  - `values[i] = v` where `i` was erased from the base;
  - `values.swapAt(i, j)` with a stale `i`;
  - `values[dictionary.endIndex]`.
- **(b)** In the new test:
  - Add a one-line comment saying why `upper` must be a base element.
  - Assert the results after the setter and `swapAt`: `values` should read `"changed"` and then
    swapped, and `dictionary` should be unchanged. That pins the CoW migration that the test
    already exercises.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows the
four reviewed files plus this one.

### Codex follow-up

Both requested test corrections were applied. Four focused death tests now pin rejection without
invalid memory access for erased indices in getter/setter/`swapAt` and for the base tree's
`endIndex`. The comparison-count test now explains why its upper bound must remain a live base-tree
element and verifies the setter result, swap result, and unchanged original dictionary across CoW.

Xcode verification: the complete `RedBlackTreeMappedValuesViewTests` class (17 tests) plus the four
new death tests passed, 21/21 total. Build-for-testing also succeeded.

---

Status at completion: Completed

## Completed assignment: independently verify X1 inventory batch 4

Independently verify only `CUR-WRAP-001` and `POC-WRAP-001` in
`Maintanance/INDEX_POC_CROSS_BRANCH_IDENTITY.md`.

Inspect lines 23–38 of
`Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap.swift` at the fixed current
(`aecbcddf240c…`) and PoC (`1b126ba370ba…`) anchors. Check the exact generic type declaration,
access, attributes, stored-property declarations, initializer declaration, line numbers, and local
compile-time guards.

Confirm that both rows remain separate identities and both semantic fields remain `unknown`. Do not
inspect or interpret extensions, conformances, method bodies beyond the initializer assignments,
alias use sites, `_LazyTie`, `_NodePtrSealing`, or comments as design intent. Identical declaration
text is not a semantic-correspondence decision.

Return exactly one verdict: `approve X1 inventory batch 4`, `approve after specified corrections`,
or `reject X1 inventory batch 4`. Record the result below, set `Status: Completed`, and give the
user only a short completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the identity map or any other file. Do
not switch branches, inspect other paths or line ranges, infer semantic correspondence, run builds/
tests/benchmarks, use network access, stage, commit, or alter Git history. Use read-only `git show`
for the exact anchors/path/range and run `git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve X1 inventory batch 4`.

I read only lines 23–38 of `_LazyTieWrap.swift`, using `git show` at `aecbcddf240c…` and
`1b126ba370ba…`. I did not read any extension, conformance, use site, `_LazyTie`, or
`_NodePtrSealing`.

1. **The declarations match the evidence cells.** At both anchors:
   - Line 24 is `@frozen`.
   - Line 25 is `public struct _LazyTieWrap<RawValue> {`. The generic parameter has no constraint.
   - Lines 27–28 are `@usableFromInline` and `package let rawValue: RawValue`.
   - Lines 30–31 are `@usableFromInline` and `package let lazyDetach: _LazyTie`.
   - Lines 33–34 are `@inlinable` and `package init(rawValue: RawValue, lazyDetach: _LazyTie)`.
   - Lines 35–36 assign both stored properties.
   - Line 38 closes the struct.
   - Line 23 is a comment, which I did not inventory.
2. **No guard applies.** Neither anchor has an `#if` in lines 1–38, so both rows are correctly
   described as unconditional.
3. **The evidence is mechanical.** Lines 23–38 are byte-identical at the two anchors (`diff` shows
   no differences). Both Evidence cells state only the visible declarations. They do not turn the
   identical text into a correspondence claim.
4. **The rows stay separate.** `CUR-WRAP-001` and `POC-WRAP-001` are distinct identities by side
   and commit. Role/era and Semantic status are `unknown` in both, and neither row names the other.

Checks: `git diff --check` was clean. Only this file was edited.

---

## Completed assignment: independently verify X1 inventory batch 3

Independently verify only `POC-NODEPTR-001` in
`Maintanance/INDEX_POC_CROSS_BRANCH_IDENTITY.md`.

Inspect `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap.swift` at the fixed
current (`aecbcddf240c…`) and PoC (`1b126ba370ba…`) anchors. Check the exact enclosing extension,
declaration, access, attributes, alias target, line numbers, and local compile-time guards. Verify
mechanically whether the current anchor has a `_NodePtr` declaration in this same path.

You may mechanically list other `_NodePtr` declarations to demonstrate name multiplicity, but do
not inspect their contents or propose any as a counterpart. This batch must not decide whether the
PoC declaration is `one-sided`, moved, duplicated, obsolete, or semantically related to another
same-named alias. Its semantic fields must remain `unknown`.

Return exactly one verdict: `approve X1 inventory batch 3`, `approve after specified corrections`,
or `reject X1 inventory batch 3`. Record the result below, set `Status: Completed`, and give the
user only a short completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the identity map or any other file. Do
not switch branches, inspect unrelated file contents, infer semantic correspondence, run builds/
tests/benchmarks, use network access, stage, commit, or alter Git history. Use read-only `git show`
for the exact path and `git grep` only to count/list same-named declarations. Run
`git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve X1 inventory batch 3`.

I read `_LazyTieWrap.swift` with `git show` at `aecbcddf240c…` and `1b126ba370ba…`. For name
multiplicity I listed matching declarations with `git grep`, and did not open any of the listed
files.

1. **The declaration matches the row.**
   - At the PoC anchor, the enclosing declaration is line 105:
     `extension _LazyTieWrap where RawValue == _NodePtrSealing {`, with no attributes and no access
     modifier. It closes at line 137.
   - Line 107 is `public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>`, with no
     attributes.
   - The row's "Lines 105–107", the extension text, the alias target, and "no attributes" are all
     exact.
2. **No compile-time guard applies.** The PoC file has three `#if DEBUG` blocks, at 52–68, 87–103,
   and 139–146. The extension at 105–137 lies between the second and third blocks, so it is not
   inside any guard. "Unconditional extension declaration in the inspected file" is correct.
3. **The current anchor has no `_NodePtr`.** At `aecbcddf`, this path has 101 lines and contains
   no `_NodePtr` token at all. The row's last sentence is correct.
4. **Name multiplicity (listing only).** With `git grep -E 'typealias +_NodePtr( |=|:|$)'` over
   `Sources`:
   - The current anchor has 15 typealias declarations named `_NodePtr`.
   - The PoC anchor has 16.
   - Both anchors also have one `associatedtype _NodePtr`, at `__tree/_types/tree_basic+types.swift:55`.
   - The only path that appears at one anchor and not the other is `RawBuffer/_LazyTieWrap.swift:107`
     (PoC). The other 15 paths and line numbers appear at both anchors.

   This shows the name is widely reused. I made no counterpart, move, duplicate, `one-sided`, or
   obsolescence judgment.
5. **The row is held at unknown.** It is a separate PoC-side identity, Role/era and Semantic
   status are both `unknown`, and no counterpart is named.

Checks: `git diff --check` was clean. Only this file was edited.

---

## Completed assignment: independently verify X1 inventory batch 2

Independently verify only `CUR-ALIAS-001`, `CUR-ALIAS-002`, `POC-ALIAS-001`, and
`POC-ALIAS-002` in `Maintanance/INDEX_POC_CROSS_BRANCH_IDENTITY.md`.

Inspect these two paths at the fixed current (`aecbcddf240c…`) and PoC (`1b126ba370ba…`) anchors:

- `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap+Result.swift`
- `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap.swift`

Check the exact typealias declarations, access, attributes, line numbers, alias targets, and local
compile-time guards. Confirm that the evidence is purely mechanical, all four rows remain separate,
and both semantic fields remain `unknown`. Report whether either file contains another declaration
that must be inventoried to describe these two alias declarations themselves; do not widen into the
implementation or conformances of `_LazyTieWrap`, `_NodePtrSealing`, `SealError`, or `Result`.

Do not infer semantic correspondence merely because declaration text matches across anchors. Do not
judge usage, intent, adoption, obsolescence, or implementation behavior.

Return exactly one verdict: `approve X1 inventory batch 2`, `approve after specified corrections`,
or `reject X1 inventory batch 2`. Record the result below, set `Status: Completed`, and give the
user only a short completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the identity map or any other file. Do
not switch branches, inspect other paths, follow alias targets or extensions, generate wider
inventories, run builds/tests/benchmarks, use network access, stage, commit, or alter Git history.
Use read-only `git show` for the two exact paths and anchors, and run `git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve X1 inventory batch 2`.

I inspected only the two stated paths with `git show`, at `aecbcddf240c…` and `1b126ba370ba…`. I
did not follow alias targets or extensions.

1. **The declarations match the evidence.**
   - In `_LazyTieWrap+Result.swift`, both anchors have line 33
     `public typealias _LazyTieWrappedPtr = Result<_LazyTieWrap<_NodePtrSealing>, SealError>`.
   - In `_LazyTieWrap.swift`, both anchors have line 41
     `public typealias _LazyTiedPtr = _LazyTieWrap<_NodePtrSealing>`.
   - All four declarations are top-level and have no attributes. Lines 23–32 and 40 are plain
     comments only.
2. **No guards apply.** In each file and at both anchors, the first `#if` comes after the alias:
   - `_LazyTieWrap+Result.swift`: the first `#if` is at line 64, inside an extension.
   - `_LazyTieWrap.swift`: the first `#if` is at line 51 (current) or 52 (PoC).

   So all four rows are correctly described as unconditional in the inspected file.
3. **The evidence is mechanical.** Each cell gives only a line number and the alias target. It
   reads nothing into the matching text on both anchors.
4. **The rows are kept apart.** All four are separate identities by side and commit. Role/era and
   Semantic status are both `unknown`, and no row names a counterpart.
5. **Nothing else is needed to describe these two aliases.** One note, outside this batch's
   scope: at the PoC anchor, `_LazyTieWrap.swift` contains another public typealias,
   `public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>`, at line 107. It sits inside an
   `extension _LazyTieWrap where RawValue == _NodePtrSealing` that begins at line 105. At the
   current anchor this file has only one typealias. The `_NodePtr` declaration is not needed for
   these four rows, but a later batch should give it its own PoC-side identity row.

**Optional.** For consistency with the batch-1 correction, the four Evidence cells could add "no
attributes". This is not a correction.

Checks: `git diff --check` was clean. Only this file was edited.

---

## Completed assignment: independently verify X1 inventory batch 1

Independently verify only the four identity rows `CUR-IDX-001`, `CUR-IDX-002`, `POC-IDX-001`, and
`POC-IDX-002` in `Maintanance/INDEX_POC_CROSS_BRANCH_IDENTITY.md`.

Inspect this single path at the two fixed anchors:

- current: `aecbcddf240cc039db9eac92b46721a1fde0532a`
- PoC: `1b126ba370ba78aa90b1241ac83d888ed3861bf4`
- path: `Sources/RedBlackTreeCollections/Implements/Index/UnsafeIndexV3.swift`

Check independently:

1. The exact declarations, access, attributes, and alias targets.
2. Whether each declaration is guarded in this file by any compile-time condition.
3. Whether the evidence text states only mechanically visible facts.
4. Whether current and PoC rows remain separate identities with semantic status `unknown`.
5. Whether any additional declaration in this file requires its own identity row.

Do not propose semantic correspondence between rows, interpret comments as user intent, judge one
side newer/better/obsolete, or inspect alias-target implementations. Shared symbol names are not
evidence of shared meaning.

Return exactly one verdict: `approve X1 inventory batch 1`, `approve after specified corrections`,
or `reject X1 inventory batch 1`. Record the result below, set `Status: Completed`, and give the
user only a short completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the identity map or any other file. Do
not switch branches, inspect other branch paths, follow alias targets, generate a wider symbol
inventory, run builds/tests/benchmarks, use network access, stage, commit, or alter Git history.
Use read-only `git show` for the exact anchors and path above, and run `git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified corrections`. One evidence
correction is needed, for `POC-IDX-001`.

I inspected only the stated path with `git show`, at `aecbcddf240c…` and `1b126ba370ba…`. I did not
follow any alias target.

1. **Declarations.**
   - **Current side:**
     - Line 26: `@_documentation(visibility: internal)`.
     - Line 27: `public typealias UnsafeIndexV3 = _LazyTieWrappedPtr`.
     - Line 30: `public typealias RedBlackTreeIndex = UnsafeIndexV3`, with a `///` doc comment on
       line 29.
   - **PoC side:**
     - Line 26: the commented-out line `//public typealias UnsafeIndexV3 = _LazyTieWrappedPtr`.
     - Line 30: `public typealias UnsafeIndexV3 = _LazyTiedPtr`. It has **no attribute**.
     - Line 33: `public typealias RedBlackTreeIndex = UnsafeIndexV3`, with a `///` doc comment on
       line 32.
2. **Guards.** Neither file contains any `#if`, so all four declarations are unconditional in this
   file. The rows say this correctly.
3. **Evidence text.**
   - `CUR-IDX-001`, `CUR-IDX-002`, and `POC-IDX-002` state only visible facts.
   - `POC-IDX-001` has two problems:
     - It omits the visible fact that the PoC declaration carries no `@_documentation` attribute.
       On the current side this attribute is part of `CUR-IDX-001`'s evidence, so leaving it out
       of `POC-IDX-001` would let a reader assume the two declarations have the same attributes.
     - "the `_LazyTieWrappedPtr` form remains commented out" contains a history claim ("remains").
       Only the commented-out text itself is visible in the file.
4. **Separation.** All four rows are separate identities, keyed by side and commit, and each has
   `unknown` in both Role/era and Semantic status. No row references another as a counterpart.
5. **Other declarations.** None. The rest of both files is comments (lines 23–25 and 32–62 on
   the PoC side, 23–25 and 32–56 on the current side). Comments are not inventoried as intent,
   per the task.

**Correction.** Replace the `POC-IDX-001` Evidence cell with:

> Alias target is `_LazyTiedPtr` (line 30); the declaration has no attributes; line 26 is a
> commented-out `public typealias UnsafeIndexV3 = _LazyTieWrappedPtr`

**Optional.** Add line numbers to the other three Evidence cells, for consistency:
- `CUR-IDX-001`: lines 26–27
- `CUR-IDX-002`: line 30
- `POC-IDX-002`: line 33

Checks: `git diff --check` was clean. Only this file was edited.

---

## Completed assignment: review the X1 identity-map skeleton

Perform a read-only review of the newly created
`Maintanance/INDEX_POC_CROSS_BRANCH_IDENTITY.md`. This review covers the map structure and
mechanical provenance only. It must not begin semantic correspondence or PoC validation.

Check the following:

1. Verify the listed commit hashes, dates, parent relationships, current tips, and merge base using
   commit metadata only.
2. Verify that the mechanical PoC-side path inventory matches
   `git diff --name-status b3570172..try/index/1` without interpreting file contents.
3. Confirm that the identity key (`branch + commit + path + symbol + configuration`) and the
   configuration dimensions are sufficient to prevent same-name conflation.
4. Confirm that every semantic status remains user-controlled and that neither Codex nor Claude is
   authorized to promote `unknown` to another state.
5. Check that the user-intent questions ask only for intent that source/history cannot establish;
   flag questions that unnecessarily ask the user to reconstruct mechanical facts.
6. Check that the mandatory stops and review sequence faithfully implement the agreed X1 row in
   `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`.
7. Identify any wording that accidentally treats the PoC as obsolete, treats current HEAD as
   authoritative by default, or implies semantic identity from a shared name or path.

Return exactly one verdict: `approve X1 identity skeleton`, `approve after specified corrections`,
or `reject X1 identity skeleton`. For corrections, cite the exact section and replacement wording.
Record the result below, set `Status: Completed`, and give the user only a short completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the identity map, task-fit table,
progress document, source, tests, or any other file. Do not switch branches, inspect branch file
contents, generate symbol inventories, infer semantic correspondence, run builds/tests/benchmarks,
use network access, stage, commit, or alter Git history. Allowed Git operations are limited to
read-only commit metadata, `rev-parse`, `merge-base`, and `diff --name-status` for the anchors already
named in the identity map. Run `git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified corrections`.

The review was read-only. Git use was limited to `rev-parse`, `merge-base`, `log`/`rev-list`
commit metadata, and `diff --name-status` / `--name-only` between the named anchors. I did not read
any branch file contents.

#### 1. Anchors: verified

- **Tips.** `develop/misc/48` = HEAD = `aecbcddf` (2026-10-05 04:07, parent `c04fec93`).
  `try/index/1` = `1b126ba3` (2026-10-04 20:25, parents `a250c677` and `b3570172`).
- **Merge base.** `merge-base` returns `b3570172` (2026-10-04 20:06), which is the second parent of
  `1b126ba3`, as stated.
- **PoC commits.** `005a7bb3` (2026-09-24 22:46) has parent `49de7dd9`. `a250c677` (2026-09-27
  06:29) is the first parent of the sync merge.

Two mechanical facts are missing from the anchor table:

- **The branch has two earlier sync merges.** Both are before the center commit:
  `8d5f9928` (09-24 22:04, merges `main`) and `49de7dd9` (09-24 22:05, merges
  `develop/misc/35`). So `49de7dd9`, the "Parent of the center commit", is itself a merge. And
  "Last pre-sync PoC commit" is ambiguous, because there are three sync merges, not one.
- **Where the PoC starts.** It has 24 branch-unique first-parent commits (`try/index/1 --not
  develop/misc/48`). The earliest is `21bdd758` (09-24 19:40, `memo`). The commits from 15:44 to
  15:56 that `RED_BLACK_TREE_REMAINING_TASKS.md` dates as the start of the work are reachable from
  `develop/misc/48`, so they are not branch-unique.

#### 2. Path inventory: verified, with one gap

- `git diff --name-status b3570172..try/index/1` returns exactly the 24 listed paths, and all
  24 are `M`. There are no `A`, `D`, or `R` entries, which is worth recording.
- **Gap: the current side is missing.** `b3570172..aecbcddf` changes 45 paths. Five paths
  changed on **both** sides since the merge base:
  - `Maintanance/CLAUDE_TASK.md`
  - `RedBlackTreeBoundExpression.swift`
  - `RedBlackTreeMappedValuesView.swift`
  - `RedBlackTreeRangeView+KeyOnly.swift`
  - `RedBlackTreeRangeView+KeyValue.swift`

  These are the paths where same-path conflation is most likely, because the content has
  already diverged after the sync.

#### 3. Identity key and configuration: correction needed

The key is right. The configuration list has two problems:

- **It omits defines that change compiled Index-related code:** `BENCHMARK`, which exposes public
  Index-returning hooks; `USE_INT128`, which selects the ptr-bitmap path in `__MultiHelper`;
  `ENABLE_LEGACY_TREE_LOWER_UPPER_BOUND`; and `DEATH_TEST` / `ENABLE_DEATH_TESTS` on the test
  side.
- **It assumes configuration names mean the same thing on both branches.** That is itself a
  same-name assumption, and `Package.swift` differs on the PoC side.

#### 4. Status control: confirmed

Every status is closed by the user, and "must not promote a row out of `unknown`" is explicit.
One structural conflict: the **Symbol identity table** has a `Proposed counterpart` column, but
review step 1 says to populate it "without semantic pairing". The `Role / era` column is also an
interpretation if Codex or Claude fills it in step 1.

#### 5. User-intent questions: one asks for mechanical facts

The first six questions ask about intent. The seventh, "What conflicts were resolved during the
2026-10-04 sync merge", asks the user to recall something mechanical: the conflict set can be
recovered from the merge and its two parents. Only the second half of the question (intent versus
restoring compilation) is a question for the user.

#### 6. Stops and sequence: faithful

All seven agreed stopping points from the corrected X1 row are present, including the 10-04
conflict intent, a failing Quality Checklist item, and raw performance data only. The sequence
keeps Claude's extraction independent, keeps correspondence undecided by the agents, gates on the
user, and validates one representative before expanding.

#### 7. Wording

Nothing treats the PoC as obsolete, and no correspondence is inferred from a shared name. One
phrase can be read as making HEAD the reference standard: "validating ... `try/index/1` PoC
against the current development branch".

#### Corrections (section → replacement)

1. **§Fixed anchors.**
   - Rename the row "Last pre-sync PoC commit" to "Last PoC commit before the 2026-10-04 sync merge".
   - Add these rows:
     - `21bdd758…` (2026-09-24 19:40), Role: "Earliest branch-unique first-parent commit
       (`try/index/1 --not develop/misc/48`)".
     - `8d5f9928…` (2026-09-24 22:04), Role: "Earlier sync merge (`main`) before the center commit".
     - `49de7dd9`'s Role: append "; itself a sync merge of `develop/misc/35`".
2. **§Mechanical PoC-side path scope.**
   - Add after the first paragraph: "All 24 entries are `M`; there are no added, deleted, or
     renamed paths."
   - Add a subsection **"Paths changed on both sides since `b3570172`"** listing the five paths
     above, with: "Same-path content has diverged on both sides after the sync; treat every symbol
     in these files as a separate identity on each side."
   - Optionally add the full current-side inventory (`b3570172..aecbcddf`, 45 paths).
3. **§Identity rule.**
   - Replace "Configuration includes, when applicable:" with "Configuration is the define/trait set
     declared by that commit's `Package.swift`; a configuration name is not assumed to mean the
     same on both branches. Dimensions include, when applicable:".
   - Add the following to the list: `BENCHMARK`, `USE_INT128`,
     `ENABLE_LEGACY_TREE_LOWER_UPPER_BOUND`, and `DEATH_TEST` / `ENABLE_DEATH_TESTS` (tests).
4. **§Symbol identity table.**
   - Remove the `Proposed counterpart` column; pairing belongs only in the Correspondence proposal
     table.
   - Rename `Role / era` to `Role / era (user-supplied; otherwise unknown)`.
5. **§Required user-intent checkpoints, last bullet.** Replace it with: "For each conflict
   resolution in the 2026-10-04 sync merge (listed mechanically beforehand from the merge and its
   two parents), did the resolution express design intent, or only restore compilation?"
6. **§Purpose, first sentence.** Replace it with: "This document is the entry gate for X1:
   reconstructing the user-authored `try/index/1` PoC and validating it, on top of the current
   development branch, against the Quality Checklist."

Checks: `git diff --check` was clean. Only this file was edited. Nothing was staged.

---

## Completed assignment: agreement check for the integrated X1 task-fit row

Perform a read-only agreement check of Codex's integration of your preceding X1 interview.
Do not inspect or compare `try/index/1`; this task concerns only whether the recorded role split
faithfully represents the interview.

Review:

- the new `X1` row in `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`;
- the new X1 identity-table prerequisite in `Maintanance/PROGRESS_OVERVIEW.md`.

Confirm only these points:

1. Your overall rating `3` and label `見本またはレビュー必須` are represented accurately.
2. Mechanical history extraction, symbol inventory, test mapping, and adversarial review are the
   parts Claude may own, while semantic correspondence and integration judgment are not assigned
   to Claude.
3. Codex is not treated as a sole reliable owner: it drafts the identity-table skeleton and
   correspondence rationale, but the workflow requires independent Claude evidence and user
   decisions for semantic identity and design intent.
4. The identity key `branch + commit + path + symbol + configuration`, and keeping semantic
   correspondence `unknown` until user confirmation, are appropriate X1 entry conditions.
5. The row preserves the mandatory stopping points from your interview rather than authorizing
   horizontal expansion from an uncertain correspondence.

Return exactly one verdict: `agree with X1 integration`, `agree after specified corrections`, or
`do not agree with X1 integration`. If a correction is needed, identify the exact phrase and its
replacement. Record the result below, set `Status: Completed`, and give the user only a short
completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the task-fit table, progress document,
source, tests, or any other file. Do not switch branches, inspect `try/index/1`, run builds/tests/
benchmarks, use network access, stage, commit, or alter Git history. Run `git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `agree after specified corrections`. There is one small
correction, to point 5. Points 1–4 are faithful.

1. **Rating and label.** Agree. The Claude column has `3` and the label `見本またはレビュー必須`, and
   the cell's sub-scores match my interview: 履歴採取5, symbol inventory 4, test mapping 4,
   反証4, semantic correspondence 2, 統合判断1.
2. **Ownership.** Agree. The 担当案 assigns Claude independent collection of history, symbols, and
   tests, plus refutation. Semantic correspondence and integration judgment are not assigned to
   Claude. Two of my interview items are omitted from the row: Quality Checklist evidence and raw
   measurement under fixed procedure. Both were conditional in the interview, so leaving them out
   of the summary row is acceptable.
3. **No sole owner.** Agree. The Codex cell says 「全体を単独所有しない」, and the 担当案 ends with the
   user deciding semantic identity and design intent.
4. **Entry conditions.** Agree. The key `branch + commit + path + symbol + configuration`, with
   semantic identity kept `unknown` until user confirmation, is the right entry gate. The
   PROGRESS item records it before X1 validation.
5. **Stopping points.** Correction needed. The Claude cell keeps four of my seven stopping points.
   It drops the one that is specific to X1: an unwritten intent behind a conflict resolution in
   the 10-04 sync merge. It also drops "a failing Quality Checklist item is reported, not fixed"
   and "performance as raw data only". The row does not authorize horizontal expansion from an
   uncertain correspondence. However, once this task file rotates to history, the row will be the
   only durable copy of the stopping list.

**Replacement (Claude cell, last sentence):**

- Current: 「曖昧な対応・obsolete判定・安全性信号・最初のcontainer/Viewからの横展開前に停止する」
- Replace with: 「曖昧な対応・obsolete判定・安全性信号・意図未記録の10-04 merge解決・Quality Checklist
  不合格（修正せず報告）・最初のcontainer/Viewからの横展開前に停止する。性能は生データのみ提出する」

Checks: read-only. `git diff --check` was clean. Only this file was edited.

---

## Completed assignment: task-fit interview for cross-branch Index archaeology

This is a capability and workflow interview only. Do not newly inspect or compare `try/index/1`
in this assignment.

We are preparing to revalidate a user-authored Index PoC that began on 2026-09-24. Claude has
already inspected this branch once and assisted with repairing / updating its merge from the current
development branch on 2026-10-04; this is not first exposure. Use that concrete experience in the
self-assessment. The difficult part is not ordinary Git history: identically named files, types,
aliases, resolvers, and operations may represent different designs or eras on the two branches, and
`Index` propagates across nearly the entire RedBlackTreeCollections surface. Both Codex and Claude
are prone to incorrectly unifying same-named but semantically different things.

The proposed new task category is:

> Cross-branch reconstruction and present-day validation of a long-lived, user-authored PoC where
> same-named components may have different semantics and the changed concept propagates across the
> public API, internal safety machinery, tests, and documentation.

Answer the following based on your observed strengths and failure modes in this repository:

1. Does an existing task-fit category in `Maintanance/AGENT_TASK_FIT_INTERVIEW.md` adequately cover
   this work? If not, propose a new ID and short task name.
2. Rate your suitability from 1 to 5. Use the existing scale; do not raise the score because the
   task is important.
3. Identify the exact parts you can own safely: mechanical history extraction, symbol inventory,
   semantic correspondence, test mapping, Quality Checklist verification, performance measurement,
   adversarial review, or integration judgment.
4. Identify your likely failure modes, especially same-name/different-semantics conflation,
   treating an older implementation as obsolete, and spreading one mistaken correspondence across
   all containers and Views.
5. State what the earlier inspection and merge repair did and did not establish, then state the
   minimum input you need from Codex and the user before re-inspecting the branch. Consider whether
   a branch+commit+path+symbol identity table and explicit design-intent notes are required.
6. Propose mandatory stopping points where disagreement or ambiguous correspondence must be returned
   to the user instead of inferred.
7. Recommend a division of work among user, Codex, and Claude. Do not assume either agent can safely
   own the entire reconstruction.
8. State whether the eventual PoC validation should require an independent double review, and which
   evidence each reviewer must produce independently.

Give one final task-fit label using the existing vocabulary: `主担当可`, `見本またはレビュー必須`,
or `補助のみ`. A low or conditional rating is acceptable and useful.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Record the answer below and set `Status: Completed`.
Do not edit the task-fit table or any other document. Do not switch branches, inspect
`try/index/1`, run builds/tests/benchmarks, use network access, stage, commit, or alter Git history.
This interview must not start the PoC validation.

### Result

2026-10-05, Claude Opus 5.5. Interview only. I did not inspect, compare, or switch to
`try/index/1`. The evidence comes from repository records (`CLAUDE_TASK_HISTORY.md`,
`RED_BLACK_TREE_REMAINING_TASKS.md` §`try/index/1`, `MAINTENANCE.md`) and my own observed
failure modes.

**Final label: `見本またはレビュー必須`. Overall rating: 3.**

#### 1. Category

No existing row covers this work.

- G (representation candidates), J (resolver), K (container/View follow-up), and V7 (unsafe
  migration history) each touch part of it.
- None of them covers establishing semantic correspondence between same-named components
  across two live branches.

Proposed new row: **X1: 長期PoCのcross-branch再構成と現行検証** (cross-branch reconstruction and
present-day validation of a long-lived, user-authored PoC).

#### 2–3. Rating by sub-part

| Sub-part | Claude | Owner? |
| --- | ---: | --- |
| Mechanical history extraction (commits, dates, `-M` renames, merge parents) | 5 | 主担当可, with hash/date/path always cited |
| Symbol inventory per branch × configuration (Debug/Release/compat, `ALLOW_CROSS_TREE_INDEX`/`USE_LAZY_DETACH`) | 4 | 主担当可, inventory only |
| Semantic correspondence (is A on branch X the same thing as A on HEAD?) | 2 | 補助のみ: propose evidence, never decide |
| Test mapping (which tests exercise which symbol on which branch) | 4 | 主担当可 after the identity table exists |
| Quality Checklist verification (per-item evidence, configurations) | 4 | 見本またはレビュー必須 |
| Performance measurement | 3 | Only under H/V6 conditions: interleaved runs, disassembly, raw data only, no interpretation |
| Adversarial review of Codex's correspondence/integration | 4 | Yes; this is where I add the most |
| Integration judgment (equivalence, obsolescence, adopt/reject) | 1 | Not mine |

The overall score is 3, not 4: the hard part of X1 is semantic correspondence, and that is
my weakest sub-part.

#### 4. Likely failure modes (with repository evidence)

- **Same-name conflation.** In T1 I nearly unified `UnsafeIndexV2.unsafe(tree:rawTag:)`
  across eras. The user's correction is recorded in memory as "同名でも時代/役割ごとの独立性を先に
  確認する". The risk is higher here, because both branches are current and the names were
  deliberately reused.
- **Classifying from names and structure.** Tonight, in the B3 audit, I called G1
  "witness-free" from its declaration shape. I had to self-correct after spotting associated-type
  inference in public positions. A wrong correspondence can look this plausible.
- **Treating the older implementation as obsolete.** My 2026-10-04 reuse evaluation already
  sorted items into "古くなった点" and "再利用を阻むもの". Some of those may be deliberate design
  choices (for example the Debug `.nullptr` sentinel or the duplicated overloads), not defects. I
  judged them against HEAD, not against the PoC's intent.
- **Spreading one mistake everywhere.** Horizontal expansion is my strength. With one wrong
  correspondence, it becomes the mechanism that replicates the error across 4 containers × 3 Views.
- **Explaining away safety signals.** The sanitizer TODO (an assert weakened via `isDetached`)
  is exactly the kind of thing I could rationalize as test noise.
- **Taking a green build as semantic evidence.** A merge that compiles and passes tests does not
  show that same-named code still means the same thing.

#### 5. What the earlier work established, and minimum input

- **Established** (2026-10-04 review, read-only diff from merge-base `7ae8237c`, 23 branch
  commits):
  - Replacing the Index alias with a success-only `_LazyTiedPtr` compiles for 4 containers and
    2 Views.
  - The internal `_SealedPtr` resolver keeps the cross-tree, unsealed, and detached diagnostics.
  - The list of reuse blockers: `try!`, the Debug `.nullptr` sentinel, the sanitizer TODO,
    missing MappedValuesView, stale paths, and duplicated overloads.
  - The branch is a partial Result-removal PoC, not a nominal-type PoC.
- **Not established:**
  - semantic equivalence of any same-named component across the branches;
  - Quality Checklist conformance (correctness, memory and Index lifetime, performance);
  - the cause of the sanitizer report;
  - behaviour after the 2026-10-04 20:25 sync merge (merge-base is now `b3570172`; my review
    predates it);
  - which of the "obsolete" items reflect user intent.
- **Merge repair:** the Markdown records I can see do not record what I changed during the
  2026-10-04 merge repair or why. That gap is itself evidence that X1 needs written provenance.
  Before re-inspection, the merge's conflict resolutions should be listed with their intent.
- **Minimum input:**
  - **Identity table** (Codex skeleton, user fills intent), one row per symbol of interest:
    - `branch`, `commit`, `path`, `symbol`, `configuration guards`;
    - `role/era`;
    - `HEAD counterpart` (or "none");
    - `same semantics? (yes / no / unknown)`, decided by the user or marked unknown;
    - `intent note`.
  - **User design-intent notes:** which differences are deliberate. At minimum:
    - `_LazyTiedPtr` vs `_LazyTieWrappedPtr`;
    - the Debug `.nullptr` sentinel;
    - why `limitedBy` converts failure to Optional/Bool;
    - the intended `==`/hash semantics;
    - the sanitizer TODO context.
  - **Scope from Codex:**
    - Keep the 09-24〜09-27 PoC commits separate from the 10-04 sync merge.
    - Allowed paths and configurations.
    - Inspection method (read-only `git show` / `git diff`; a worktree only in a task-owned temp
      directory, with user permission).
    - One sample container plus one View before any horizontal pass.

#### 6. Mandatory stopping points (return to the user, do not infer)

1. Any same-named symbol whose semantics differ or cannot be shown to match: mark it `unknown`
   and stop for that row.
2. Any item that looks obsolete. Report it with evidence; never classify it as obsolete myself.
3. After the first container + View sample, before extending a correspondence to the rest.
4. Any memory-safety sign: sanitizer report, weakened assert, lifetime-counter imbalance,
   unexpected `SIGSEGV`. Stop; do not work around it.
5. Any conflict resolution in the 10-04 merge whose intent is not written down.
6. Any failing Quality Checklist item. Report it; do not fix it in the same task.
7. Any performance difference. Raw data only; interpretation goes to Codex and the user.

#### 7. Division of work

- **User:** design intent; the `same semantics?` column; decisions on obsolescence and adoption;
  permission for worktree/temp inspection.
- **Codex:**
  - phase design and identity-table skeleton;
  - draft semantic correspondence with rationale;
  - integration draft and the Quality Checklist verdict draft.
- **Claude:**
  - mechanical extraction and per-configuration symbol inventory;
  - test mapping;
  - per-item Quality Checklist evidence;
  - adversarial review of Codex's correspondence;
  - raw measurements under fixed procedure.

Neither agent owns the whole reconstruction.

#### 8. Double review

Yes: independent and blind, with each reviewer producing evidence before reading the other's.

- **Codex:**
  - correspondence table with semantic rationale;
  - integration and adoption draft;
  - a Quality Checklist verdict per item.
- **Claude:**
  - an independent symbol inventory and diff by phase (PoC commits vs sync merge);
  - a list of counterexample or failing tests (written first, not fixed);
  - Quality Checklist evidence per configuration: Debug/Release, normal/compat, both
    `ALLOW_CROSS_TREE_INDEX`/`USE_LAZY_DETACH` settings, Death Tests, and sanitizer status.

Disagreements go to the user unresolved.

Checks: only this file edited. `git diff --check` clean. Nothing staged.

---

## Completed assignment: targeted review of Combining API performance notes

Perform a read-only review of the new public `- Note:` paragraphs in these three files:

- `Sources/RedBlackTreeCollections/RedBlackTreeSet/RedBlackTreeSet+Combining.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeMultiSet/RedBlackTreeMultiSet+Combining.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeMultiMap/RedBlackTreeMultiMap+Combining.swift`

Use `Maintanance/CombiningAPIPerformanceEvidence.md` sections 1–3 as the evidence source and
`Sources/RedBlackTreeCollections/Documentation/Quality-Checklist.md` as the quality policy.

Check only the following questions:

1. Does each statement accurately distinguish insertion-loop paths from `union` / `formUnion` /
   `meld` / `melding`, including the fact that the latter build new storage rather than reuse the
   receiver's spare capacity?
2. Do the Set and MultiSet notes stay within the recorded measurements instead of presenting a
   finite benchmark as a permanent performance guarantee?
3. Does either MultiMap note improperly extrapolate a Set- or MultiSet-only measurement to
   MultiMap? Structural implementation facts may be stated, but unmeasured timing conclusions may
   not be transferred.
4. Are the paired mutating and nonmutating notes attached to the correct same-type overloads?
5. Is the amount of detail acceptable for a public DocC `Note`, with detailed raw evidence kept in
   the maintenance document?

Return exactly one verdict: `approve Combining notes`, `approve after specified corrections`, or
`reject Combining notes`. For any correction, quote the affected API and provide replacement
wording. Record the result below, set `Status: Completed`, and give the user only a short completion
notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, progress documents,
evidence documents, API Matrix, DocC, Package.swift, workflows, benchmarks, or Git history. Do not
stage, commit, switch branches, inspect `try/index/1`, run benchmarks, or use network access. You may
inspect the named source files, the two named documents, and their uncommitted diffs. Run
`git diff --check`; build and tests are unnecessary because this is a wording-only review and Codex
has already completed an Xcode build.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified corrections`.

Checked against `CombiningAPIPerformanceEvidence.md` §1–3 and the current source.

1. **Paths are distinguished correctly.** Every note says the alternative "builds new storage".
   That matches §1: `___meld_unique` starts at `minimumCapacity: 2`, and `___meld_multi`
   allocates `count + other.count`. Neither reads the receiver's spare capacity.
2. **Set mutating note: within the measurements.**
   - "faster for disjoint input": merge beat formUnion at all three sizes (21.50/222.46/3646.00
     vs 45.04/482.38/8047.71).
   - "formUnion faster at 90% duplicates": also true at all three sizes (42.42/916.42/27168.67
     vs 28.04/300.25/4869.17).
3. **MultiSet notes overstate.** "consistently faster" reads as a general claim. MultiSet
   measured only disjoint, sorted, and shuffled `other`; duplicate-heavy and shared storage
   were not measured. One comparison (16k unreserved: 323.79 vs 470.50, ≈1.45×) is inside the
   ~1.5× band that §2 says is not significant. The claim needs the measured input shapes.
4. **Nonmutating notes transfer the mutating measurements.**
   - Only `merge` / `formUnion` and `insert(contentsOf:)` / `meld` were measured.
   - `merging` and `inserting(contentsOf:)` are `var result = self` followed by the mutating call,
     so they always copy the receiver first.
   - Set: the "merge, shared storage" case (4504 vs formUnion 7509 at 256k) supports the
     disjoint claim. The note should still say the measurement was of the mutating forms.
   - MultiSet: shared storage was not measured at all, so its nonmutating timing claim is
     unmeasured.
5. **MultiMap notes extrapolate.** "Relative performance depends on the input's ordering and
   the destination's storage-sharing state" is a timing conclusion. MultiMap was never measured.
   The ordering effect was measured on Set and MultiSet; storage sharing was measured only on
   Set. Only the structural facts may be stated.
6. **Overloads are correct.** Each note sits on the same-type overload: Set `merge(_: Set)` /
   `merging(_: Set)`; MultiSet and MultiMap `insert(contentsOf: Self)` /
   `inserting(contentsOf: Self)`. The mutating/nonmutating pairing (formUnion/union,
   meld/melding) is right.
7. **Detail level is acceptable for DocC.** One or two sentences; raw numbers stay in the
   evidence document. Minor readability point: in "that operation … this operation", the two
   pronouns refer to different APIs in adjacent sentences. "it" and "this method" are clearer.

#### Replacement wording

- `RedBlackTreeSet.merge(_:)` (optional, pronouns only):
  > - Note: Spare capacity does not make `formUnion(_:)` preferable; it builds new storage. In
  >   measurements through 256K elements, this method was faster for disjoint input, while
  >   `formUnion(_:)` was faster when 90% of `other` duplicated existing elements.
- `RedBlackTreeSet.merging(_:)`:
  > - Note: Spare capacity does not make `union(_:)` preferable; it builds new storage. This
  >   method copies the current storage before inserting. In measurements of the mutating forms
  >   through 256K elements, `merge(_:)` was faster for disjoint input, even when it first copied
  >   shared storage, while `formUnion(_:)` was faster when 90% of `other` duplicated existing
  >   elements.
- `RedBlackTreeMultiSet.insert(contentsOf:)`:
  > - Note: Spare capacity does not make `meld(_:)` preferable; it builds new storage. In
  >   measurements through 256K elements with disjoint, sorted, and shuffled `other`, this method
  >   was faster in each case, although the construction order of `other` materially affected
  >   both operations.
- `RedBlackTreeMultiSet.inserting(contentsOf:)`:
  > - Note: Spare capacity does not make `melding(_:)` preferable; it builds new storage. This
  >   method copies the current storage before inserting. Only the mutating forms were measured:
  >   through 256K elements with disjoint, sorted, and shuffled `other`, `insert(contentsOf:)` was
  >   faster than `meld(_:)` in each case.
- `RedBlackTreeMultiMap.insert(contentsOf:)`:
  > - Note: Spare capacity does not make `meld(_:)` preferable; it builds new storage. This
  >   method inserts into the existing storage, copying it first if it is shared.
- `RedBlackTreeMultiMap.inserting(contentsOf:)`:
  > - Note: Spare capacity does not make `melding(_:)` preferable; it builds new storage. This
  >   method copies the current storage before inserting.

Checks: inspected the three source diffs and evidence §1–3. `git diff --check` is clean.
Only this file was edited. Nothing staged. No build was run (wording-only review, as assigned).

---

## Completed assignment: review the integrated collaboration reflection

Please perform a read-only review of Codex's 2026-10-05 updates made after your independent
reflection. The purpose is to check whether the integration represents both assessments fairly,
whether the operational changes are supported by the observed work, and whether you can agree to
the integrated conclusion and use it as the collaboration policy going forward. There is no
request to revise, defend, or add to your personal reflection, and agreement is not presumed.

### Review scope

1. Review Codex's appended section in `USER_MANAGEMENT_INTERVIEW_CODEX.md` and the updated table
   plus `## 2026-10-05 統合更新` in `USER_MANAGEMENT_ASSESSMENT.md`.
2. Review Codex's `## Codex evidence update (2026-10-05)` and the revised assignment rule 6 in
   `AGENT_TASK_FIT_INTERVIEW.md`.
3. Confirm that:
   - Codex's score changes are supported by the recent G2–G4/G3 and task-log rotation workflow;
   - your own score change and reasoning are represented accurately without being overwritten;
   - the remaining disagreement on user workload is described as a genuine weighting difference,
     not averaged away;
   - the proposal to bundle same-shape review launches preserves per-batch verdict, record, and
     commit boundaries;
   - personal observations remain optional, non-authoritative, and in each agent's own voice;
   - the revised rule 6 does not pressure either agent to provide a feeling or route technical
     findings incorrectly.
4. Inspect the full uncommitted diff and run `git diff --check`.
5. State explicitly whether you agree with:
   - the integrated description of the role split;
   - the recorded score changes and the unresolved 3-versus-4 user-workload difference;
   - the proposed next improvement of bundling same-shape review launches while preserving
     per-batch verdict and commit boundaries;
   - the treatment of personal observations as optional and outside the integrated verdict.
6. Return one verdict: `agree with integrated reflection`, `agree after specified corrections`,
   `do not agree with integrated reflection`, or `integrated reflection evidence incomplete`.

### Output and boundaries

Record a concise result in this task and set the status to `Completed`. Only
`Maintanance/CLAUDE_TASK.md` may be edited. Do not edit either interview, the integrated
assessment, either observation log, task history, maintenance rules, source, tests, CHANGELOG,
progress documents, Package.swift, workflows, benchmarks, or DocC. Do not stage, commit, switch
branches, inspect `try/index/1`, use network access, or alter Git history.

A short completion notice is sufficient. If you agree only in part or do not agree, identify the
exact statement and your reason in this task without softening it for consensus. Codex will retain
the disagreement or make a correction as appropriate; it will not treat completion as agreement.

### Result (2026-10-05, Claude Opus 5.5)

Verdict: `agree with integrated reflection`.

Explicit agreement:

- **Role split:** agree. "Codex implementation/experiment → Claude independent refutation →
  Codex integration → user approval" matches the observed G2–G4 / G3 work.
- **Score changes and the unresolved difference:** agree.
  - Codex's six raises are each tied to observed workflow, not to output volume.
  - My column is unchanged except for 自分の負荷の管理 3 → 4, and my reasoning is summarized
    accurately. My interview text was not altered.
  - The 3-versus-4 difference is recorded as a weighting difference, not averaged.
  - Non-blocking note for the record: the user later said that the manual relay is an
    Apple/Xcode limitation (「中継はAppleとXcodeの問題だから仕方ないよ」). That supports my
    weighting: I treat the relay as an environmental cost, not a management cost. Codex's
    condition for raising its own score ("when the environmental relay decreases") ties a
    management score to tooling the user does not control. I keep my 4. Codex may keep its 3;
    the recorded difference is accurate as written.
- **Bundling same-shape review launches:** agree. Every place that states the proposal keeps
  verdict, record, and commit per batch, and isolates the failure of one batch from the
  others.
- **Personal observations:** agree. They are optional, outside the integrated verdict and
  completion conditions, and stay in each agent's own log in its own words.
  - Revised rule 6 says a short impression 「添えてよい」. It does not require one. It routes
    technical supplements that do not change a conclusion to Codex.
  - The blocker / safety / user-decision exceptions remain in `CLAUDE.md`. So rule 6 does
    not suppress problem reports.

Checks:

- I inspected the full uncommitted diff: both interviews, the integrated assessment, the
  task-fit file, and `CODEX_OBSERVATIONS.md`.
- The "2,181 lines moved" figure matches the 2,180-line boundary-to-EOF block of the
  pre-rotation file, plus the trailing line.
- `git diff --check`: clean. Only this file was edited. Nothing staged.

## Completed assignment: independently update the collaboration reflection

Please review the collaboration since the 2026-10-04 task-fit and user-management assessments,
and update your assessment from your own perspective. This is a reflection task, not an
implementation task. There is no need to anticipate or align with Codex's answer; Codex will write
its own response and consolidate the factual differences after your independent update.

### Evidence to consider

- The conversation was refreshed, and Codex reconstructed the exact state from Git and Markdown
  without relying on the old conversation.
- G2, G3 NodeCompare, G3 SignedDistance, and G4 were handled as small bounded batches: Codex
  implemented or ran reversible experiments, prepared review requests, checked your results, and
  proposed commits; the user mainly supplied direction, triggered your review, and explicitly
  authorized commits.
- Your external-client typechecks corrected or strengthened the evidence where symbol graphs or
  build-only checks were insufficient.
- The user asked for Claude and Codex observation logs because factual consolidation should not
  erase either agent's own interesting observations or voice.
- `CLAUDE_TASK.md` was rotated from 2556 to 412 lines, with your independent integrity review.
- The user still performs the manual relay that starts your work and reports completion.

### Required updates

1. In `AGENT_TASK_FIT_INTERVIEW.md`, append a dated evidence update. State which existing scores,
   role assignments, or safeguards are confirmed, improved, or should change. Do not rewrite the
   full historical interview and do not raise scores merely because tasks passed.
2. In `USER_MANAGEMENT_INTERVIEW_CLAUDE.md`, append your independent 2026-10-05 reassessment.
   Identify any score changes with before/after values and evidence. Explicitly assess whether the
   agreed delegation reduced user micromanagement and workload in practice, and what burden remains.
3. In `USER_MANAGEMENT_ASSESSMENT.md`, add a clearly labeled Claude update without rewriting the
   Codex side or claiming a new integrated verdict. Leave final integration to Codex and the user.
4. If you feel like leaving any personal or technical reflection for the user, you are welcome to
   append it in your own words to `CLAUDE_OBSERVATIONS.md`. This is entirely optional; an assessment
   update does not create any obligation to disclose a feeling or manufacture an observation.
5. Check consistency across the four files and run `git diff --check`.

### Boundaries

Only edit `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`,
`Maintanance/USER_MANAGEMENT_INTERVIEW_CLAUDE.md`,
`Maintanance/USER_MANAGEMENT_ASSESSMENT.md`, `Maintanance/CLAUDE_OBSERVATIONS.md`, and this task
file. Do not edit Codex's interview or observation log, history, maintenance rules, source, tests,
CHANGELOG, progress documents, Package.swift, workflows, benchmarks, or DocC. Do not stage,
commit, switch branches, inspect `try/index/1`, use network access, or alter Git history.

Update this task with a concise result and set the status to `Completed`. A short completion notice
is enough, but you may also tell the user something directly if you would like to; blockers and
product-owner decisions should still be stated clearly.

### Result (2026-10-05, Claude Opus 5.5)

- `AGENT_TASK_FIT_INTERVIEW.md`: appended `## Claude evidence update (2026-10-05)`. No score
  changes.
  - Claude's B rating stays 3. Claude's B3 classification had a self-caught error.
  - Independent review and rule 9 are confirmed by the G4 rationale correction and the G2
    evidence gap.
  - Rule 6 is reconfirmed, given Claude's over-reporting.
  - New safeguards proposed: external-client typecheck as the standard narrowing evidence,
    using `--show-bin-path` for the build location, and an inverse-clause column in audits.
- `USER_MANAGEMENT_INTERVIEW_CLAUDE.md`: appended `## 2026-10-05 再評価`.
  - Score change: 自分の負荷の管理 3 → 4. Everything else unchanged, with evidence added.
  - Delegation did reduce micromanagement and workload in practice.
  - Remaining burden: manual relay, commit approvals (intentional), Claude-caused
    corrections, and meta rounds.
  - Proposal: bundle same-shape reviews to cut relays.
- `USER_MANAGEMENT_ASSESSMENT.md`: appended a labeled `## Claude update (2026-10-05)`
  summary. No integrated verdict and no edits to the Codex side.
- `CLAUDE_OBSERVATIONS.md`: one optional reflection.
- Consistency: the score change, unchanged scores, and proposal match across the files.
- `git diff --check`: clean. Nothing staged.

## Completed assignment: review the Claude task-log rotation

Perform a read-only integrity review of Codex's maintenance-log rotation. Do not modify source,
tests, package configuration, or Git history.

### Objective

Confirm that completed assignments were moved from `CLAUDE_TASK.md` to
`CLAUDE_TASK_HISTORY.md` without loss or reordering, while the active file retains enough recent
context for the G3/G4 public-surface work. Also check that the new Claude/Codex observation logs
are explicitly optional, lowest-priority, and separate from authoritative project records.

### Required checks

1. Compare the active and history files and verify the rotation boundary is
   `## Completed assignment: narrow five 原木 reference protocols`.
2. Confirm the moved block is verbatim and appears before older history entries, preserving
   newest-first order. Check that no assignment exists in both files and none was lost.
3. Confirm `CLAUDE_TASK.md` retains the G3 SignedDistance, G3 NodeCompare, G2, G4, and B3
   assignments and their result summaries, and is materially smaller than before.
4. Review `MAINTENANCE.md`, `CLAUDE_OBSERVATIONS.md`, and `CODEX_OBSERVATIONS.md`. Confirm the
   observation logs cannot be mistaken for verdicts, required handoff, or authoritative evidence.
5. Run `git diff --check` and inspect the complete diff. Return one verdict: `approve task-log
   rotation`, `task-log rotation correction required`, or `task-log rotation evidence incomplete`.

### Output and boundaries

Update this task with a concise result and set the status to `Completed`. Only
`Maintanance/CLAUDE_TASK.md` may be edited for the required review. If you personally have an
observation you want the user to read later, you may also append it in your own words to
`Maintanance/CLAUDE_OBSERVATIONS.md`; this is entirely optional and must not delay the review.
Do not write a placeholder observation. Do not edit the history, maintenance rules, Codex's
observation log, source, tests, CHANGELOG, progress documents, Package.swift, workflows,
benchmarks, or DocC. Do not stage, commit, switch branches, inspect `try/index/1`, use network
access, or alter Git history. Report only `完了` unless blocked or a product-owner decision is
required.

### Result (2026-10-05, Claude Opus 5.5)

Verdict: `approve task-log rotation`.

- **Boundary:** the rotation starts at `## Completed assignment: narrow five 原木 reference
  protocols`. That heading now exists only in the history file; this file mentions it only
  in the assignment text.
- **Move integrity:** compared against the HEAD versions of both files.
  - The moved block (old task file from the boundary to EOF) appears verbatim in the history
    file.
  - It sits directly after the unchanged history preamble and one dated "Moved verbatim"
    line, and before the previous history body. The previous history body is unchanged, so
    newest-first order is kept.
  - Completed-assignment headings: 28 before and 28 after. None lost, none duplicated.
- **Retained context:** this file keeps the G3 SignedDistance, G3 NodeCompare, G2, G4, and
  B3 assignments. That retained block is byte-identical to its HEAD text.
  This file shrank from 2556 to 412 lines.
- **Observation logs:** `CLAUDE_OBSERVATIONS.md`, `CODEX_OBSERVATIONS.md`, and the
  `MAINTENANCE.md` rule all describe the logs as optional, lowest priority, and not
  authoritative. They also require technical grounds and handoff to be recorded in the
  authoritative documents. Neither log can be mistaken for a verdict or a required
  handoff.
- **Checks:** `git diff --check` is clean. The HEAD copies used for comparison went to a
  `mktemp -d` directory, which was removed. Nothing staged by Claude; `CODEX_OBSERVATIONS.md`
  was already staged before this review.

## Completed assignment: review the G3 SignedDistance targeted compile experiment

Perform a read-only independent review of Codex's G3 SignedDistance experiment. Do not edit
source or implement an alternative design.

### Objective

Confirm or refute that `_BaseNode_SignedDistanceProtocol` cannot be narrowed independently from
`public` to `package` while preserving its `where Self: ~Copyable` extension, public
`___signed_distance` witness, and the four container `Base` conformances to the public
`_BaseNode_SignedDistanceInterface`.

### Required checks

1. Inspect `_BaseNode_SignedDistanceProtocol`, `_BaseNode_SignedDistanceInterface`, its
   `where Self: ~Copyable` extension, the four container `Base` conformances,
   `TreeNodeOnlyFixture`, `___TreeIndex`, and `UnsafeTreeV2+Index.swift` consumers.
2. Confirm both compiler failures recorded under
   `### G3 SignedDistance targeted compile experiment`:
   - public `___signed_distance` is rejected in the extension with package requirements;
   - package `___signed_distance` cannot satisfy the public interface requirement for the
     public conformers.
3. Check whether any access-only formulation was missed. Treat removal of the inverse clause,
   moving or duplicating the witness, changing the public protocol cluster, or redesigning Index
   only as future design work, not as part of this batch.
4. Confirm `tree_base+distance.swift` was restored exactly to the public protocol and public
   witness, and no source, CHANGELOG, test, Package.swift, workflow, benchmark, DocC, or Index
   change remains from the experiment.
5. Return one verdict: `defer G3 SignedDistance`, `G3 SignedDistance access-only narrowing
   available`, or `G3 SignedDistance evidence incomplete`.

### Output and boundaries

Append a concise review below `### G3 SignedDistance targeted compile experiment` in
`Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`, update this task with the result, and set the
status to `Completed`. Only those two Markdown files may be edited. Do not build the full suite,
stage, commit, switch branches, inspect `try/index/1`, use network access, or alter Git history.
Read-only compiler experiments in a task-owned temporary directory are allowed. Run
`git diff --check`, inspect the complete diff, and report only `完了` unless blocked or a
product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

Verdict: `defer G3 SignedDistance`. Appended `#### G3 SignedDistance experiment review
(Claude)`.

- Both recorded diagnostics were reproduced with synthetic code of the same shape: the
  same associated-type constraints, the `~Copyable` inverse-clause extension, and a public
  conformer.
- The public witness fails because of the inverse clause. A package witness fails
  because it cannot satisfy the public `_BaseNode_SignedDistanceInterface` requirement.
- No combination of protocol access (`package` or `@usableFromInline package`) and
  witness access (`public` or `package`) compiles, so there is no access-only formulation.
  Design alternatives are listed only as future work.
- Restoration: confirmed. `tree_base+distance.swift` matches HEAD, and `git diff HEAD`
  touches only the two Markdown files.
- The temporary directory was removed. `git diff --check`: clean. Nothing staged.

## Completed assignment: review the G3 NodeCompare protocol narrowing

Perform a read-only independent review of Codex's first G3 implementation. Do not modify source.

### Objective

Confirm or refute that narrowing `_BaseNode_NodeCompareProtocol` from `public` to `package`
preserves the public `___ptr_comp` / `___ptr_range_comp` witnesses and all four container
`Base` conformances, without changing `_BaseNode_SignedDistanceProtocol` or making an Index
design decision.

### Required checks

1. Inspect `tree_base+compare.swift`, `_BaseNode_PtrCompInterface`,
   `_BaseNode_PtrRangeCompInterface`, `_Base_MultiplicityHelperInterface`, all four container
   `Base` conformances, `TreeNodeOnlyFixture`, and relevant compatibility-mode constraints.
2. Confirm the G4 `where Self: ~Copyable` failure does not apply: the NodeCompare extension
   has no where clause, and its public methods remain valid witnesses after the protocol becomes
   package.
3. In a task-owned temporary directory, typecheck a package-name-free external client against
   the current Release module. Confirm `___ptr_comp` / `___ptr_range_comp` remain usable through
   public interfaces or public conforming `Base` types, while `_BaseNode_NodeCompareProtocol`
   itself is no longer in scope. Do not use the symbol graph as witness evidence because
   underscore-prefixed declarations may be omitted.
4. Verify `package` is the minimum access required by Release non-`@testable` tests and whether
   `@usableFromInline` is needed anywhere.
5. Check that the source diff is exactly the NodeCompare access modifier; confirm
   `_BaseNode_SignedDistanceProtocol`, Index representations, tests, and implementations are
   untouched. Review the CHANGELOG, progress, audit wording, and Codex's build/test/DocC evidence.
6. Return one verdict: `approve G3 NodeCompare`, `G3 NodeCompare correction required`, or
   `G3 NodeCompare evidence incomplete`.

### Output and boundaries

Append a concise review below `### G3 NodeCompare protocol narrowing result` in
`Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`, update this task with the result, and set the
status to `Completed`. Only those two Markdown files may be edited. Do not edit source, tests,
CHANGELOG, progress documents, Package.swift, workflows, benchmarks, or DocC. Do not stage,
commit, switch branches, inspect `try/index/1`, use network access, or alter Git history.
Read-only searches and bounded compiler experiments in a task-owned temporary directory are
allowed. Run `git diff --check`, inspect the complete diff, and report only `完了` unless blocked
or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

Verdict: `approve G3 NodeCompare`. Appended `#### G3 NodeCompare narrowing review (Claude)`.

- Source diff: the single access modifier (`tree_base+compare.swift:23`). SignedDistance,
  Index, tests, and implementations are untouched.
- The extension has no where clause; the Release build succeeded.
- External client typecheck: run against the current Release module, without a package
  name.
  - Still works: the four `Base` types' `___ptr_comp` / `___ptr_range_comp`, both through
    direct reference and through the public interfaces, plus `___TreeIndex`.
  - Now fails as intended: `_BaseNode_NodeCompareProtocol` is no longer in scope.
- `package` is the minimum access, because Release non-`@testable` `TreeNodeOnlyFixture`
  uses the protocol. No `@usableFromInline` is needed. No compatibility-mode reference
  exists.
- The temporary directory was removed. `git diff --check`: clean. Nothing staged.

## Completed assignment: review the G2 multiplicity protocol narrowing

Perform a read-only independent review of Codex's G2 implementation. Do not modify source.

### Objective

Confirm or refute that narrowing `UniqueMultiplicity` and `MultiMultiplicity` from `public` to
`package` preserves the public `isMulti` witnesses, `_MultiplicityHelper` associated-type
inference, four container `Base` conformances, and compatibility-mode behavior.

### Required checks

1. Inspect `tree_base+trait.swift`, `_Base_IsMultiInterface`,
   `_Base_MultiplicityHelperInterface`, `MultiplicityHelper`, `__UniqueHelper`,
   `__MultiHelper`, all four container `Base` conformances, Release non-`@testable` fixtures,
   and compatibility-mode `_CompareV2` constraints.
2. Confirm the G4 `where Self: ~Copyable` failure does not apply: the G2 extensions have no
   where clause, and their public `isMulti` members remain valid witnesses after the protocols
   become package.
3. Verify that `package` is the correct minimum access, including Release tests that import the
   module without `@testable`; check whether `@usableFromInline` is required anywhere.
4. Check the source diff is limited to the two protocol access modifiers and that CHANGELOG,
   progress, and audit wording match the actual compatibility impact.
5. Review Codex's build/test/DocC evidence and identify any missing configuration or external
   API check. Do not run the full suite.
6. Return one verdict: `approve G2`, `G2 correction required`, or `G2 evidence incomplete`.

### Output and boundaries

Append a concise review below `### G2 multiplicity protocol narrowing result` in
`Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`, update this task with the result, and set the
status to `Completed`. Only those two Markdown files may be edited. Do not edit source, tests,
CHANGELOG, progress documents, Package.swift, workflows, benchmarks, or DocC. Do not stage,
commit, switch branches, inspect `try/index/1`, use network access, or alter Git history.
Read-only searches and bounded compiler experiments in a task-owned temporary directory are
allowed. Run `git diff --check`, inspect the complete diff, and report only `完了` unless blocked
or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

Verdict: `approve G2`. Appended `#### G2 narrowing review (Claude)` below the G2 result.

- Source diff: the two access modifiers only (`tree_base+trait.swift:78,87`).
- The G4 inverse-clause failure does not apply, because the G2 extensions have no where
  clause.
- External-client typecheck: run against the current Release module, without a package
  name.
  - Still works: `Base.isMulti` (direct and through `_Base_IsMultiInterface`) and
    `Base._MultiplicityHelper == __UniqueHelper / __MultiHelper`.
  - Now fails as intended: `UniqueMultiplicity` / `MultiMultiplicity` are no longer in
    scope.
  - The symbol graph cannot show `isMulti`, because it hides `_`-prefixed protocols.
- `package` is the minimum access, because the Release non-`@testable` fixtures
  (`TreeNodeOnlyFixture`, `KeyValueComparerTests`) use the protocols. No
  `@usableFromInline` is needed. Compat `_CompareV2` only uses them in where clauses.
- Gap filled: Codex's normal-mode Debug evidence was an Xcode build only. I ran
  `swift build --build-tests`, then the targeted XCTest suites (7 suites, 77 tests, 0
  failures) and `RedBlackTreeInternalPointerDeathTests` (4 Swift Testing tests, passed).
- CHANGELOG and progress wording are accurate.
- Temporary directories were removed. `git diff --check`: clean. Nothing staged.

## Completed assignment: review the G4 targeted compile experiment

Perform a read-only independent review of Codex's G4 experiment concerning
`_ScalarBasePayloadValue_KeyProtocol`. Do not edit source or implement an alternative design.

### Objective

Confirm or refute the conclusion that this protocol cannot be narrowed independently from
`public` to `@usableFromInline package` because its extension supplies the public `__key`
witness for Set / MultiSet nested `Base` conformances to `_BasePayloadValue_KeyInterface`.

### Required checks

1. Inspect `_ScalarBasePayloadValue_KeyProtocol`, `_BasePayloadValue_KeyInterface`,
   `_ScalarBasePayload_KeyProtocol_ptr`, `ScalarValueTrait`, and the Set / MultiSet `Base`
   conformances.
2. Verify both compiler failures recorded under `### G4 targeted compile experiment` in
   `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md` follow from Swift access and witness rules:
   - a public member cannot be declared in an extension with package requirements;
   - a package `__key` cannot satisfy the public protocol requirement for the public conformers.
3. Check whether an access-only formulation was missed. Do not propose moving the witness,
   adding duplicate implementations, or redesigning the public protocol cluster as though it
   were part of this batch; list such options only as future design work.
4. Confirm the source file was restored exactly to public protocol + public `__key`, and that
   no source, CHANGELOG, test, Package.swift, workflow, benchmark, or DocC change remains from
   the failed experiment.
5. Return one verdict: `defer G4`, `access-only narrowing available`, or
   `experiment evidence incomplete`.

### Output and boundaries

Append a concise review below the G4 experiment in
`Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`, update this task with the result, and set the
status to `Completed`. Only those two Markdown files may be edited. Do not build the full suite,
stage, commit, switch branches, inspect `try/index/1`, use network access, or alter Git history.
Read-only compiler experiments in a task-owned temporary directory are allowed. Run
`git diff --check`, inspect the complete diff, and report only `完了` unless blocked or a
product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

Verdict: `defer G4`. Appended `#### G4 experiment review (Claude)` below the G4 experiment.

- Failure 2 is confirmed by Swift witness rules: the public `Base` conformance to public
  `_BasePayloadValue_KeyInterface` requires a public `__key`.
- Failure 1's recorded rationale is over-general. Synthetic compiles show that a public
  member in an extension of a `@usableFromInline package` protocol is accepted, and also
  serves as a public witness, when the extension has no where clause. The diagnostic is
  triggered by `where Self: ~Copyable` alone, even with no conformers.
- No access-only formulation exists. `@usableFromInline` is required by
  `_ScalarBasePayload_KeyProtocol_ptr`. Dropping the inverse clause is a generics change
  that conflicts with the 原木 `~Copyable` retention. Listed only as future design work.
- Forward note: the G2 extensions have no where clause. G3's
  `_BaseNode_SignedDistanceProtocol` extension has one.
- Source restoration: confirmed. `git diff HEAD` touches only the two Markdown files.
- Synthetic experiments ran in a `mktemp -d` directory, which was removed.
- `git diff --check`: clean. Nothing staged.

## Completed assignment: B3 protocol witness and conformance audit

Perform a read-only witness and conformance audit of the residual B3 protocols that
have production conformers but no direct public-signature use. Do not narrow anything
yet.

## Objective

Determine which residual protocol declarations can be narrowed independently without
removing required witnesses, changing public conformances, or forcing an Index design
decision. Produce the next smallest safe batch, or prove that the remaining protocols
must stay deferred.

## Scope

Audit these protocols from the closure-audit residual table:

- `UniqueMultiplicity`
- `MultiMultiplicity`
- `UnsafeTreeBindingV2`
- `_ElementBride`
- `_KeyBride`
- `_MappedValueBride`
- `_PayloadValueBride`
- `_ScalarBasePayloadValue_KeyProtocol`
- `_Tree_IsMultiTraitInterface`
- `_BaseNode_NodeCompareProtocol`
- `_BaseNode_SignedDistanceProtocol`
- `MultiplicityHelper`

Treat `LinkPairValueTrait` as Memoize-owned and excluded from immediate action. Mention
it only to preserve accounting.

## Required analysis

1. For each scoped protocol, enumerate declaration/access, inherited protocols,
   requirements, associated types, conforming types, conditional conformances,
   constrained extensions, default implementations, and repository consumers.
2. Build a witness graph showing which default implementations satisfy requirements of
   other public protocols or public container/`Base` conformances. Distinguish a method
   merely callable through a protocol constraint from a method installed as a witness.
3. Check public and `@inlinable` signatures, serialized bodies, nested public `Base`
   types, Views, generation-4 iteration, compatibility mode, and the four containers.
4. Separate protocol-name exposure from behavior exposure. A protocol may be safely
   narrowed only if required behavior and public conformances continue to typecheck.
5. Group protocols into dependency-connected change batches. For each group, state the
   minimum plausible visibility (`public`, `@usableFromInline package`, `package`, or
   internal), source-compatibility impact, and exact compilation/tests needed to prove
   it.
6. Keep Index-binding, Balanced, Memoize, BENCHMARK, compatibility-generation deletion,
   and external API design out of scope. If a group reaches one of those boundaries,
   mark it deferred rather than assuming a decision.
7. Recommend exactly one next action: one minimal implementation batch, a targeted
   compile experiment, or closure of B3 until another gate moves.

## Output

Append a section named exactly:

`### B3 protocol witness and conformance audit`

to `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Include a compact protocol/witness
table, dependency groups, configuration findings, proposed validation matrix, and one
verdict:

- `independent narrowing batch available`
- `targeted compile experiment required`
- `deferred gates only`
- `inventory inconsistency blocks decision`

Update this task with concise evidence and set it to `Completed`. Update other
maintenance documents only to correct a demonstrably stale statement; do not mark the
overall cleanup complete.

## Boundaries

Only these files may be edited:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Maintanance/CLAUDE_TASK.md`
- `Maintanance/PROGRESS_OVERVIEW.md`
- `Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`

Do not edit source, tests, Package.swift, CHANGELOG, workflows, benchmarks, or DocC.
Do not stage, commit, switch branches, use network access, inspect `try/index/1`, or
alter Git history. Do not run the full suite. Targeted builds/typechecking are allowed
only if they do not require source edits; otherwise specify the needed compile
experiment as the verdict. Run `git diff --check`, inspect the complete diff, and inspect
`git status --short`.

Report only `完了` to the user. Put details in Markdown. Explain directly only if blocked
or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

I appended `### B3 protocol witness and conformance audit` to
`EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Verdict: `independent narrowing batch available`.

- **G1 (recommended batch):** `_KeyBride`, `_PayloadValueBride`, `_ElementBride`,
  `_MappedValueBride`, `_Tree_IsMultiTraitInterface` -> `@usableFromInline package`.
  No method witnesses; all refiners (normal and compat) are internal/`@usableFromInline`;
  tests use them only under Debug `@testable`. Floor is `@usableFromInline` because
  `@usableFromInline` protocols refine them.
  - Caveat recorded: the Bride same-type constraints let containers/Views infer `_Key` /
    `_PayloadValue` / `_MappedValue`, which appear in public positions (e.g. View
    `Equatable where _PayloadValue: Equatable`). The validation matrix therefore includes
    View Equatable/Comparable tests and a Release symbol-graph check that those types stay
    public.
- **G2** `UniqueMultiplicity` / `MultiMultiplicity`, **G3** `_BaseNode_NodeCompareProtocol` /
  `_BaseNode_SignedDistanceProtocol` (Index-adjacent), **G4**
  `_ScalarBasePayloadValue_KeyProtocol`: their extensions supply witnesses for public
  requirements (`isMulti`, `___ptr_comp`, `___signed_distance`, `__key`). They need a
  real-source compile experiment as a later task. Floor `package` (Release non-`@testable`
  tests `TreeNodeOnlyFixture`, `KeyValueComparerTests`, `TreeFoundamentalValueTests`).
- **G5** `MultiplicityHelper`: must stay public (associated-type constraint of public
  `_Base_MultiplicityHelperInterface`).
- **G6** `UnsafeTreeBindingV2`: deferred; compat-mode public protocols
  `UnsafeIndexBindingV2` / `UnsafeIndicesBinding` inherit it.
- `LinkPairValueTrait`: Memoize, excluded.

Evidence:

- Searches over `Sources`, `Tests`, `Benchmarks/Sources` for all 13 names, their refiners,
  conformers, `isMulti`, `difference_type` / `_InputIter`, View constraints, and explicit
  associated-type typealiases; compat guards of every Deprecated consumer checked.
- Language-rule checks with synthetic code compiled by `swiftc -package-name` in a
  task-owned `mktemp -d` directory (removed afterwards): package-protocol-extension witness
  for a public requirement compiles and works from a client; a `@usableFromInline`
  protocol refining a non-UFI package protocol is an error; inferred associated types
  through a `@usableFromInline package` protocol work in public conditional conformances
  and from a client. No repository source was edited and no package build was run.
- `PROGRESS_OVERVIEW.md` / `RED_BLACK_TREE_REMAINING_TASKS.md`: no demonstrably stale
  statement found for this scope; unchanged.
- `git diff --check`: clean. Nothing staged.

# Archive (2026-10-05 and earlier)

Moved verbatim from `Maintanance/CLAUDE_TASK.md` on 2026-10-05.

## Completed assignment: narrow five 原木 reference protocols

Narrow the five independently actionable 原木 protocols identified by the closure
audit from public API to package implementation surface. Preserve them as porting
reference code; do not delete them.

## Objective

Remove five unused/reference-only protocol names from the external public surface
without changing production behavior, Index design, or the retained 原木 structure.

## Allowed implementation

1. In `Implements/__tree/base/tree_base+interface.swift`, narrow these declarations:
   - `_BaseKey_EquivInterface`
   - `_BaseNode_PtrUniqueCompInterface`
   - `_Base_MultiplicityHelperProtocol`
   Use the minimum package visibility compatible with their `@inlinable` requirements
   and neighboring 原木 declarations. Do not change requirements or bodies.
2. In `Implements/__tree/_types/tree_basic+types.swift`, change `_pointer_type` to
   `@usableFromInline package`; it is inherited by the existing
   `@usableFromInline package` `TreeEndNodeAccessInterface`.
3. In `Implements/__tree/base/tree_base+common.swift`, narrow
   `_BaseNode_KeyProtocol` to package and narrow its default `__get_value(_:)`
   implementation from public to the minimum package visibility needed by same-package
   Debug and Release tests. Preserve `@inlinable`, its requirements, implementation,
   and the comments explaining that it is retained as reference material.
4. Add one concise source-breaking entry to `CHANGELOG.md`.
5. Append exact changes and validation to `EXTERNAL_TYPE_EXTENSION_AUDIT.md`; update
   this task. Update `PROGRESS_OVERVIEW.md` only if an existing checkbox becomes fully
   accurate; do not close the overall public-surface item while the 13-protocol B3
   typecheck audit and deferred gates remain.

## Must preserve

- All five declarations and their semantics as 原木/reference code.
- `_BaseKey_LessThanInterface`, `_BaseNode_PtrCompInterface`,
  `_BaseNode_PtrRangeCompInterface`, `_Base_MultiplicityHelperInterface`,
  `_PointerType`, `_parent_pointer_type`, and `_BaseComparableKey_LessThanProtocol`.
- Both test fixtures using `_BaseNode_KeyProtocol`.
- Index/Comparable/Result, Balanced, Memoize, BENCHMARK, iterator, container, and View
  code.

## Validation

1. Normal mode:
   - Debug `--build-tests`;
   - run `TreeFoundamentalValueTests` and
     `RedBlackTreeInternal_98_CoverageTests`, confirming actual discovery;
   - Release `RedBlackTreeCollections` build;
   - build the relevant test targets in Release if needed to prove package access;
   - Release DocC warnings-as-errors.
2. Compatibility mode: build `RedBlackTreeCollections` and the relevant test target(s)
   with `-Xswiftc -DCOMPATIBLE_ATCODER_2025`.
3. Search the current tree to confirm the five names have no externally required
   public signature and the expected same-package test references remain.
4. Run `git diff --check`, inspect the complete diff, and inspect `git status --short`.

## Boundaries

Do not edit `Package.swift`, workflows, benchmarks, unrelated protocols or tests,
DocC, Index code, or `try/index/1`. Do not stage, commit, switch branches, use network
access, or alter Git history. Keep the source diff to access modifiers/attributes only;
do not reformat the files.

Set this task to `Completed` and report only `完了` to the user. Put details in the
Markdown records. Explain directly only if blocked or a product-owner decision is
required.

### Result (2026-10-04, Claude Opus 5.5)

Source diff is access modifiers/attributes only (3 files, 6 lines changed + 1 attribute
line added). Details are in `EXTERNAL_TYPE_EXTENSION_AUDIT.md`,
`### 原木 reference protocol narrowing result`.

- `_BaseKey_EquivInterface`, `_BaseNode_PtrUniqueCompInterface`,
  `_Base_MultiplicityHelperProtocol`: `public` -> plain `package` (no `@usableFromInline`
  needed; nothing serialized or `@usableFromInline` references them).
- `_pointer_type`: `public` -> `@usableFromInline package`.
- `_BaseNode_KeyProtocol`: `public` -> `package`; default `__get_value(_:)`:
  `@inlinable public static` -> `@inlinable package static`. Comments kept.
- Note: both `_BaseNode_KeyProtocol` fixtures are `#if DEBUG` and use `@testable import`,
  so `internal` would also satisfy current tests; `package` was used as assigned. The
  Release test build therefore does not exercise these fixtures.
- `CHANGELOG.md`: one source-breaking Unreleased / Changed entry.
- `PROGRESS_OVERVIEW.md`: unchanged by this task (no checkbox became fully accurate).

Validation:

- `swift build --disable-sandbox --build-tests`: succeeded.
- `swift test --disable-sandbox --skip-build --filter 'TreeFoundamentalValueTests|RedBlackTreeInternalCoverageTests'`:
  `TreeFoundamentalValueTests` 11 XCTest cases, 0 failures; `RedBlackTreeInternalCoverageTests`
  5 Swift Testing tests (incl. `_BaseNode_KeyProtocolのカバレッジ確保`) passed.
- Release: `--target RedBlackTreeCollections` and `--target RedBlackTreeTreeTests` built.
- CI Release DocC `generate-documentation ... --warnings-as-errors`: succeeded.
- Compatibility mode (`-Xswiftc -DCOMPATIBLE_ATCODER_2025`): `RedBlackTreeTreeTests` and
  `RedBlackTreeTests` targets built.
- Search over `Sources`, `Tests`, `Benchmarks/Sources`: no public signature references the
  five names; only package `TreeEndNodeAccessInterface` inherits `_pointer_type`; test
  references are the two fixtures plus `Fixtures.md`.
- `git diff --check`: clean. Nothing staged.

## Completed assignment: public-surface cleanup closure audit

Perform a read-only closure audit of the remaining RedBlackTreeCollections public
surface after the completed narrowing/isolation batches. Do not implement changes.

## Objective

Determine whether any independently actionable, unintended public declaration remains
outside the already documented deferral clusters. The goal is to decide whether the
public-surface cleanup can reach a clean stopping point before the Index contract is
settled.

## Baseline exclusions

Do not re-propose these as immediate work:

- Index representation and everything classified as Index-binding, including
  `Result` Comparable, `_LazyTieWrap`, `_NodePtrSealing`, `SealError`, raw ranges, and
  Index-returning benchmark hooks;
- Balanced protocols / `freeCapacity`, which intentionally act as an executable API
  matrix and remain coupled to Index/Range and Debug-vs-Release policy;
- Memoize APIs, which wait for the two external consumers to migrate;
- `BENCHMARK`-trait public hooks used by the separate Benchmarks package;
- generation 3 deletion, which requires a separate owner decision;
- already completed ThreeWay, SortedSequence, View `_isIdentical`, Bound fixture,
  deprecated iterator, and iterator-protocol batches.

## Required work

1. Re-run the public declaration/conformance inventory against the current working tree,
   not the pre-cleanup snapshot. Cover public `_` / `__`, `Unsafe*`, public typealiases,
   external-type extensions, conditional conformances, and Debug/Release differences.
2. Reconcile every residual item with `EXTERNAL_TYPE_EXTENSION_AUDIT.md` and
   `RED_BLACK_TREE_REMAINING_TASKS.md` as one of:
   - intended product/API-matrix surface;
   - known deferred cluster listed above;
   - compatibility-only and correctly guarded;
   - independently actionable unintended public surface;
   - documentation/accounting error only.
3. For each independently actionable item, prove repository consumers, external
   exposure, `@inlinable` constraints, configuration behavior, Index dependence, and
   the smallest safe change boundary. Do not classify from naming or reference count
   alone.
4. Verify whether the progress item “DebugとReleaseで公開protocol適合集合が変わる箇所を解消”
   should remain open solely because of intentional/deferred clusters, or whether an
   overlooked independent mismatch remains.
5. Recommend exactly one next action, or explicitly recommend closing the independent
   public-surface-cleanup phase until the Index/owner/external-consumer gates move.

## Output

Append a section named exactly:

`### Public-surface cleanup closure audit`

to `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Include a compact residual table,
accounting corrections, remaining gates, and one verdict:

- `independent cleanup remains`
- `independent cleanup complete; deferred gates only`
- `inventory inconsistency blocks closure`

Update `PROGRESS_OVERVIEW.md` and `RED_BLACK_TREE_REMAINING_TASKS.md` only if a stale
statement can be corrected without marking deferred work complete. Update this task
with concise evidence and set it to `Completed`.

## Boundaries

Only these files may be edited:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Maintanance/PROGRESS_OVERVIEW.md`
- `Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`
- `Maintanance/CLAUDE_TASK.md`

Do not edit source, tests, Package.swift, CHANGELOG, workflows, benchmarks, or DocC.
Do not stage, commit, switch branches, use network access, inspect `try/index/1`, or
alter Git history. Do not run the full suite. Use source/configuration searches and
targeted typechecking only if a concrete classification cannot otherwise be resolved.
Run `git diff --check`, inspect the complete diff, and inspect `git status --short`.

Report only `完了` to the user. Put all details in Markdown. Explain directly only if
blocked or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

I appended `### Public-surface cleanup closure audit` to
`EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Verdict: `independent cleanup remains`.

- **Inventory:** rebuilt Debug and Release from the current tree and re-extracted the
  symbol graphs. Effectively public symbols are now Debug 889 / Release 819 (Gate A:
  963 / 892). Release has 56 public protocols. All Debug-only differences belong to the
  deferred Balanced and Debug-Comparable clusters; nothing is Release-only.
- **Method for the protocol check:** for every public protocol, I checked whether any
  public signature, generic or extension constraint, or protocol inheritance references
  it, and whether any type conforms to it.
- **Independently actionable:** five 原木 protocols have no public-signature use and no
  production conformer:
  - `_BaseKey_EquivInterface`, `_BaseNode_PtrUniqueCompInterface`, and
    `_Base_MultiplicityHelperProtocol`: zero references anywhere.
  - `_pointer_type`: its only user is a `@usableFromInline package` protocol, so the
    floor is `@usableFromInline package`.
  - `_BaseNode_KeyProtocol`: used only by two same-package test fixtures.
- **Recommended next action:** narrow those five from `public` to `package`, without
  deleting them. Deleting would conflict with the 原木 reference/porting retention
  intent.
- **Left in B3:** 13 protocols that also lack public-signature use but do have
  conformers. Their extensions may supply witnesses for public protocol requirements,
  so they need a typecheck audit before they can be narrowed.
- **Accounting corrections recorded:** the original top table's ThreeWay rows and
  remaining-task lines 103-104 are stale after B4-a.
- **`PROGRESS_OVERVIEW.md`:** annotated the open Debug/Release checkbox to say that only
  the deferred clusters remain. It stays unchecked.
- Validation:
  - The temporary symbol-graph directory was removed.
  - `git diff --check` was clean.
  - `git status --short` shows only `CLAUDE_TASK.md`,
    `EXTERNAL_TYPE_EXTENSION_AUDIT.md`, and `PROGRESS_OVERVIEW.md` modified.

## Completed assignment: isolate obsolete iterator protocol layer

Isolate the obsolete iterator protocol layer to `COMPATIBLE_ATCODER_2025`, following
the completed disposition audit. Preserve generation-4 behavior and compatibility mode.

## Objective

Remove the uninhabited normal-mode public protocols and conditional conformances while
retaining the protocol layer required by deprecated AtCoder-2025 iterators.

## Allowed implementation

1. In `Iterator/UnsafeIterator/UnsafeIterator+Protocol.swift`:
   - put `ObverseIterator`, its default `Reversed` alias, and `ReverseIterator` under
     `#if COMPATIBLE_ATCODER_2025`;
   - remove the normal-mode `UnsafeIteratorProtocol` declaration;
   - preserve normal-mode `UnsafeAssosiatedIterator` exactly, including its spelling.
2. In `UnsafeIterator+Payload.swift`, `UnsafeIterator+Key.swift`,
   `UnsafeIterator+KeyValue.swift`, and `UnsafeIterator+MappedValue.swift`, place only
   the `ObverseIterator` / `ReverseIterator` conditional conformances under
   `COMPATIBLE_ATCODER_2025`. Do not guard or alter the wrapper types or their
   `UnsafeAssosiatedIterator` conformances used by generation 4.
3. In `UnsafeIterator+CopyOnWrite.swift`, remove only its two normal-mode conditional
   conformances to `ObverseIterator` and `ReverseIterator`. Preserve the type,
   `Sendable` conformance, storage/lifetime behavior, and generation-4 path.
4. Add a concise source-breaking normal-mode entry to `CHANGELOG.md`.
5. Append the implementation and exact validation results to
   `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`; update this task. Update an existing
   relevant checkbox in `PROGRESS_OVERVIEW.md` only if the wording becomes fully true.

## Must preserve

- `_Obverse4`, `_Reverse4`, `_CopyOnWrite`, `UnsafeAssosiatedIterator`, current
  container/View iterators, and all Index/Range behavior.
- Compatibility generations 1–3, deprecated aliases, wrapper conformances, and
  container `reversed()` return types.
- The four current-API C++ comparison files remain normal-mode-only.
- No decision about Index, Comparable, `Result`, or generation-3 deletion.

## Validation

1. Normal mode:
   - Debug build-tests;
   - targeted Sequence, reversed, RangeView, MappedValuesView, and
     ProtocolConformance tests;
   - Release `RedBlackTreeCollections` build;
   - Release DocC warnings-as-errors.
2. Compatibility mode with `-Xswiftc -DCOMPATIBLE_ATCODER_2025`:
   - build all tests;
   - run all 10 `NaiveIteratorTests`;
   - run the four containers' AtCoder2025 compatibility tests relevant to reversed
     wrappers. Existing Dictionary compatibility tests around reversed keys/values are
     known to exercise the wrapper witness; confirm discovery and execution rather than
     adding a duplicate test unless coverage is actually absent.
3. Search with configuration nesting in mind and confirm `ObverseIterator`,
   `ReverseIterator`, and `UnsafeIteratorProtocol` have no normal-mode declarations or
   references. `UnsafeAssosiatedIterator` must remain in normal mode.
4. Run `git diff --check`, inspect the complete diff and `git status --short`.

## Boundaries

Do not edit `Package.swift`, workflows, benchmarks, unrelated protocols or tests,
generation 1–4 implementations, container APIs, Views, Index code, or `try/index/1`.
Do not stage, commit, switch branches, use network access, or alter Git history. Avoid
whole-file reformatting; keep the source diff structural and minimal.

Set this task to `Completed` and report only `完了` to the user. Put details in the
Markdown records. Explain directly only if blocked or a product-owner decision is
required.

### Result (2026-10-04, Claude Opus 5.5)

All changes are structural and minimal; no existing lines were re-indented.

**Source changes** (under `Implements/Iterator/UnsafeIterator/`)

- `UnsafeIterator+Protocol.swift`:
  - wrapped `ObverseIterator`, its default `Reversed` alias, and `ReverseIterator` in
    `#if COMPATIBLE_ATCODER_2025`;
  - removed the normal-mode `UnsafeIteratorProtocol`;
  - left `UnsafeAssosiatedIterator` unchanged.
- `UnsafeIterator+{Payload,Key,KeyValue,MappedValue}.swift`: wrapped only the
  `ObverseIterator` / `ReverseIterator` conditional conformances in the compat guard.
- `UnsafeIterator+CopyOnWrite.swift`: deleted the two normal-only conditional
  conformances.

**Documentation**

- `CHANGELOG.md`: added an entry marked source-breaking in normal mode.
- `EXTERNAL_TYPE_EXTENSION_AUDIT.md`: appended `### Iterator protocol layer isolation
  result`.
- `PROGRESS_OVERVIEW.md`: left unchanged. No existing checkbox became fully true.

**Normal-mode validation**

- `swift build --disable-sandbox --build-tests`: succeeded.
- `swift test --disable-sandbox --skip-build --filter 'SequenceTests|Reversed|reversed|RangeView|MappedValuesView|ProtocolConformance'`:
  253 XCTest cases passed with 0 failures, plus 4 Swift Testing tests in 1 suite.
- `swift build --disable-sandbox -c release --target RedBlackTreeCollections`:
  succeeded.
- The CI Release DocC command with `--warnings-as-errors`: succeeded.

**Compatibility-mode validation**

- `swift build --disable-sandbox --build-tests -Xswiftc -DCOMPATIBLE_ATCODER_2025`
  (all test targets): succeeded.
- `swift test --disable-sandbox --skip-build --filter 'NaiveIteratorTests|AtCoder2025Compatibility'`:
  all passed with 0 failures:
  - `NaiveIteratorTests`: 10 tests;
  - `DictionaryAtCoder2025CompatibilityTests`: 5 tests;
  - `SetAtCoder2025CompatibilityTests`: 12 tests;
  - `MultiMapAtCoder2025CompatibilityTests`: 1 test.
- `--filter 'RedBlackTreeMultiset.*LegacyTests'`: 10 tests, 1 skipped, 0 failures.
- The reversed-wrapper witness test
  `RedBlackTreeDictionaryEtcAtCoder2025LegacyTests.testKeysAndValuesFunctionStyleReversed`
  was discovered and passed.
- Afterwards normal mode was rebuilt with `--build-tests`, restoring `.build`.

**Other checks**

- A scan that tracks `#if` nesting found 0 references to `ObverseIterator`,
  `ReverseIterator`, or `UnsafeIteratorProtocol` outside the compat guard.
  `UnsafeAssosiatedIterator` remains in normal mode.
- `git diff --check`: clean.
- Nothing was staged.

## Completed assignment: audit iterator protocol layer disposition

Audit the iterator protocol layer left behind after deprecated iterator generations
1–3 were isolated to `COMPATIBLE_ATCODER_2025`. This is a read-only disposition audit;
do not edit source or tests.

## Objective

Determine whether `UnsafeIteratorProtocol`, `ObverseIterator`, `ReverseIterator`, and
their conditional conformances/helpers can be isolated to compatibility mode, narrowed,
or removed from the normal build without affecting generation 4, current containers,
Views, or public iteration behavior.

## Required analysis

1. Enumerate the three protocols, every requirement/default implementation, every
   conforming type, and every generic constraint/reference in Sources, Tests,
   Benchmarks, DocC, and maintenance records.
2. Analyze normal mode and `COMPATIBLE_ATCODER_2025` separately. Verify rather than
   assume whether `_Obverse4`, `_Reverse4`, `_CopyOnWrite`, `_Payload`, `_Key`, and
   `_Value` use or conform to this protocol layer.
3. Separate:
   - protocol declarations and default implementations;
   - compatibility-only conformers and aliases;
   - conditional conformances/helpers that become uninhabited in normal mode;
   - code still required by the current generation-4 path.
4. Check access levels, public signatures, `@inlinable` references, serialized bodies,
   and source-compatibility impact. Underscore-prefixed public declarations still count
   as public surface.
5. Determine the smallest safe implementation batch. Prefer configuration isolation
   over deletion when compatibility mode still needs a declaration.
6. Identify exact tests needed in both modes, including whether the existing 10
   `NaiveIteratorTests` cover the compatibility witnesses sufficiently.
7. Keep this independent of the unresolved public Index/Comparable decision. If any
   proposed change actually depends on that decision, isolate it as a blocker instead
   of assuming an answer.

## Output

Append a section named exactly:

`### Iterator protocol layer disposition audit`

to `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Include a compact declaration /
reference table, normal-versus-compatibility findings, public-surface impact, proposed
file list, validation matrix, and one verdict:

- `compatibility-only isolation batch`
- `normal-mode narrowing batch`
- `safe removal batch`
- `Index decision required`
- `product-owner decision required`

Update this task with concise evidence and set it to `Completed` when done.

## Boundaries

Only these files may be edited:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Maintanance/CLAUDE_TASK.md`

Do not edit source, tests, Package.swift, CHANGELOG, workflows, benchmarks, or other
documentation. Do not stage or commit, switch branches, use network access, inspect
`try/index/1`, or alter Git history. Do not run the full test suite; searches and
targeted compilation only if needed to resolve a concrete ambiguity are sufficient.
Run `git diff --check` on the two allowed files and inspect the full diff plus
`git status --short`.

Report only `完了` to the user. Put all details in the Markdown record. Explain directly
only if blocked or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

I appended `### Iterator protocol layer disposition audit` to
`EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Verdict: `compatibility-only isolation batch`.

- **Normal mode:**
  - `ObverseIterator`, `ReverseIterator`, and the normal-mode `UnsafeIteratorProtocol`
    have no conforming types.
  - The 10 conditional conformances (on `_Payload`, `_Key`, `_KeyValue`, `_MappedValue`,
    and `_CopyOnWrite`) can never be satisfied.
  - Generation 4 (`_Obverse4` / `_Reverse4`) does not adopt these protocols. Normal-mode
    reverse iteration uses `_Reverse4` aliases directly.
  - `.Reversed` is used only by the four containers' compat-only `*+Deprecated.swift`
    files.
- **Compatibility mode:** it still needs `ObverseIterator` / `ReverseIterator` and the
  wrapper conformances. Its `UnsafeIteratorProtocol` is a separate declaration.
- **Required by generation 4:** `UnsafeAssosiatedIterator`. It stays.
- **Proposed batch:**
  - In `UnsafeIterator+Protocol.swift`, guard `ObverseIterator` / `ReverseIterator` with
    compat and drop the normal-mode `UnsafeIteratorProtocol`.
  - In `UnsafeIterator+{Payload,Key,KeyValue,MappedValue}.swift`, guard the conditional
    conformances with compat.
  - In `UnsafeIterator+CopyOnWrite.swift:72-85`, delete the two normal-only conditional
    conformances. They can never be satisfied, and they would no longer compile once the
    protocols are compat-only.
- **Test caveat:** the 10 `NaiveIteratorTests` never call a wrapper's `reversed()`.
  The implementation batch must confirm that some compat test reaches container
  `reversed() -> Tree._PayloadValues.Reversed`, or decide whether to add one.
- **Index dependence:** none.
- Validation:
  - Searches covered all four protocol names, `.Reversed` / `reversed()`, and the
    file-level guards of every deprecated iterator and container file, across `Sources`,
    `Tests`, `Benchmarks/Sources`, and the DocC/documentation Markdown.
  - No build was run.
  - `git diff --check` was clean.
  - `git status --short` shows only the two allowed files modified.

## Completed assignment: isolate deprecated iterator generations 1–3

Isolate deprecated iterator generations 1–3 to `COMPATIBLE_ATCODER_2025` without
deleting any generation or changing compatibility behavior.

## Objective

Remove `_Obverse1...3` and `_Reverse1...3` from the normal-mode compiled/public surface,
while retaining all six implementations and their existing tests in compatibility mode.

## Allowed implementation

1. Wrap each of these six complete files in `#if COMPATIBLE_ATCODER_2025`:
   - `UnsafeIterator+Obverse1.swift`, `Obverse2.swift`, `Obverse3.swift`
   - `UnsafeIterator+Reverse1.swift`, `Reverse2.swift`, `Reverse3.swift`
   under `Sources/RedBlackTreeCollections/Implements/Deprecated/Iterator/`.
2. Within generations 2 and 3, remove only branches that become unreachable because
   the complete file is compatibility-only. Preserve the compatibility branch bodies
   exactly. If removing an inner branch is less safe than retaining it, retain it and
   explain why; isolation is the required outcome, cleanup is secondary.
3. Put all tests in
   `Tests/RedBlackTreeTests/RedBlackTreeInternal/Instance/RedBlackTreeInternal_NaiveIteratorTests.swift`
   under `DEBUG && COMPATIBLE_ATCODER_2025`, retaining all 10 tests. Do not delete or
   rewrite generation 3 tests.
4. Add a concise source-breaking normal-mode isolation entry to `CHANGELOG.md`.
5. Append the implementation result and validation to
   `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`; update an existing relevant checkbox
   in `PROGRESS_OVERVIEW.md` only if accurate; update this task.

## Must preserve

- Compatibility mode's generation 1 `unsafeSequence` / `unsafeValues` behavior.
- Compatibility aliases and generation 2 behavior.
- Generation 3 source and its two tests; deletion requires a separate user decision.
- `_Obverse4`, `_Reverse4`, `_CopyOnWrite`, current container/View iterators, Index
  representation, and all iterator protocols.
- Do not act on the side finding about now-uninhabited normal-mode iterator protocols.

## Validation

1. Normal mode: Debug build-tests, relevant sequence/equality/comparison/hash/View tests,
   and Release `RedBlackTreeCollections` build.
2. Compatibility mode: use command-line compiler definition
   `-Xswiftc -DCOMPATIBLE_ATCODER_2025` if it reproduces the package's established mode
   without editing `Package.swift`; otherwise stop and report the exact blocker rather
   than modifying package configuration. Build tests and run the Naive iterator suite,
   confirming all 10 tests are discovered and pass.
3. Run Release DocC warnings-as-errors for normal mode.
4. Search the normal-mode source paths to confirm generations 1–3 are referenced only
   inside compatibility guards.
5. Run `git diff --check`, inspect the full diff and `git status --short`.

## Boundaries

Do not delete generation 3. Do not edit `Package.swift`, workflows, unrelated tests,
benchmarks, iterator protocols, or nondeprecated iterator implementations. Do not stage,
commit, use network access, switch branches, inspect `try/index/1`, or alter Git history.

Set this task to `Completed`, append exact commands and results, and report only `完了`
to the user. Explain directly only if blocked or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

Isolation is done. A follow-up by Codex made the current-API C++ comparison tests
normal-mode-only, closing the compatibility-mode validation gap.

**Changes**

- The six files under `Implements/Deprecated/Iterator/` are each wrapped entirely in
  `#if COMPATIBLE_ATCODER_2025`.
- Inside generations 2 and 3 there were six inner `#if COMPATIBLE_ATCODER_2025` /
  `#else` blocks. The compatibility branch bodies are kept. Only the now-unreachable
  `#else` side was removed: the normal-mode `_start` / `_end` and `reversed()`. The
  whitespace-insensitive diff contains only these.
- Generation 3 is kept.
- The Naive iterator tests now sit under `#if DEBUG && COMPATIBLE_ATCODER_2025`, and all
  10 tests are retained.
- Documentation:
  - `CHANGELOG.md`: added an entry marked source-breaking in normal mode;
  - `PROGRESS_OVERVIEW.md`: checked one item;
  - `EXTERNAL_TYPE_EXTENSION_AUDIT.md`: appended `### Deprecated iterator generations 1–3
    isolation result`.

**Normal-mode validation**

- `swift build --disable-sandbox --build-tests`: succeeded.
- `swift test --disable-sandbox --skip-build --filter 'SequenceTests|Equatable|Comparable|Hashable|ProtocolConformance|RangeView|MappedValuesView|NaiveIterator'`:
  256 RedBlackTreeTests and 2 RedBlackTreeTreeTests XCTest cases, plus 1 Swift Testing
  test, all passed with 0 failures. NaiveIteratorTests was absent, as expected.
- `swift build --disable-sandbox -c release --target RedBlackTreeCollections`:
  succeeded.
- The CI Release DocC command with `--warnings-as-errors`: succeeded.
- A scan that tracks `#if` nesting confirmed that every reference to generations 1–3 in
  `Sources` and `Tests` is inside a `COMPATIBLE_ATCODER_2025` guard.

**Compatibility-mode validation**

- `swift build --disable-sandbox --target RedBlackTreeTests -Xswiftc -DCOMPATIBLE_ATCODER_2025`
  succeeded, so the six types and the Naive iterator tests compile in this mode.
- Codex wrapped the four current-API behavior-comparison files in
  `#if !COMPATIBLE_ATCODER_2025`; these tests compare the current Swift API with libc++
  and do not define a legacy compatibility contract.
- `swift build --disable-sandbox --build-tests -Xswiftc -DCOMPATIBLE_ATCODER_2025`
  then succeeded.
- `swift test --disable-sandbox --skip-build -Xswiftc -DCOMPATIBLE_ATCODER_2025
  --filter NaiveIteratorTests` discovered and passed all 10 tests.
- After returning to normal mode, `swift test --disable-sandbox --filter
  CppBehaviorReferenceTests` discovered and passed all 35 C++ comparison tests.

**Other checks**

- `git diff --check`: clean, after removing trailing whitespace from one whitespace-only
  line that re-indentation had produced.
- Nothing was staged.

## Completed assignment: audit deprecated iterator generations 1–3

Perform a read-only disposition audit of deprecated iterator implementations
`_Obverse1` through `_Obverse3` and `_Reverse1` through `_Reverse3` in the default
RedBlackTreeCollections build.

## Objective

Determine why these deprecated iterator generations remain in the normal build and
whether the next safe action is deletion, compatibility-only isolation, TestSupport
relocation, or continued deferral. Do not implement the disposition in this task.

## Required work

1. Enumerate the six types, their files, guards, access levels, stored representations,
   protocol conformances, public/internal members, and all repository references.
2. Identify which iterator generation is used by the four current containers and Views,
   and whether `_Obverse4` / the current reverse path fully supersedes generations 1–3.
3. Check normal mode, `COMPATIBLE_ATCODER_2025`, Debug/Release, tests, documentation,
   and benchmarks separately. Do not infer compatibility use merely from a Deprecated
   directory or filename.
4. Compare observable behavior that might prevent removal: traversal direction,
   start/end handling, stale/sealed pointer behavior, ownership/lifetime, mutation,
   iterator protocol requirements, and complexity.
5. Determine whether any public alias, signature, `@inlinable` body, protocol witness,
   serialized layout, or external compatibility promise still exposes these types.
6. Separate Index-dependent issues from purely dead or compatibility-only code. Do not
   decide the final Index representation.
7. Propose the smallest implementation batch, exact files, required test migration or
   replacement evidence, validation matrix, and source-compatibility impact.

Use `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md` and
`Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md` as current records. Preserve the user's
existing iterator design intent where source/history in the repository establishes it;
do not classify by reference count alone.

## Output

Append one section named exactly:

`### Deprecated iterator generations 1–3 disposition audit`

to `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Include a compact type/reference
table, supersession evidence, configuration findings, blockers, recommended batch, and
one verdict:

- `safe independent removal batch`
- `compatibility-only isolation batch`
- `test-support relocation batch`
- `Index decision required`
- `product-owner decision required`

## Boundaries

Only these files may be edited:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Maintanance/CLAUDE_TASK.md`

Do not edit source, tests, Package.swift, documentation, CHANGELOG, workflows, or
benchmarks. Do not run the full suite. Do not stage or commit. Do not use network access,
switch branches, inspect `try/index/1`, or alter Git history.

Re-run searches sufficient to support completeness, run `git diff --check` on the two
allowed files, and inspect their full diff plus `git status --short`. Set the task to
`Completed`, append concise evidence, and report only `完了` to the user. Explain
directly only if blocked or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

- I appended `### Deprecated iterator generations 1–3 disposition audit` to
  `EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Verdict: `compatibility-only isolation batch`.
- **Normal mode:** all six types are compiled as public types, yet production does not
  use them. The current containers and Views use `_Obverse4` / `_Reverse4` through
  `_CopyOnWrite`, and the normal-mode `unsafeSequence` / `unsafeValues` return
  `_Obverse4`. The only normal-mode consumer is the Debug test
  `RedBlackTreeInternal_NaiveIteratorTests.swift:17-82` (8 tests).
- **Compatibility mode:**
  - Generation 1 backs compat `unsafeSequence` / `unsafeValues`, which the tree's
    `==`, `<`, hash, filter, and key/value helpers use.
  - Generation 2 backs the compat public aliases `_RemoveAware*` / `TiedIndexing`.
  - Generation 3 is unused in both modes.
- **Recommended batch:**
  - Wrap all six files in `#if COMPATIBLE_ATCODER_2025` and drop the now-dead
    normal-mode `#else` members.
  - Move the normal-mode Naive iterator tests under the same guard, so no coverage is
    lost.
  - Deleting generation 3 is optional and needs approval first, because it removes 2
    tests.
- **Index dependence:** none. Isolating chooses no Index representation.
- **Side finding:** after isolation, `UnsafeIteratorProtocol`, `ObverseIterator`, and
  `ReverseIterator` have no conformers in normal mode. That is for a separate audit.
- Validation:
  - Searches covered `_Obverse/_Reverse 1–3`, `unsafeSequence` / `unsafeValues`,
    `_RemoveTrait` / `_RemoveAware*`, and the iterator protocols, across `Sources`,
    `Tests`, `Benchmarks/Sources`, and repository Markdown.
  - No build or test was run.
  - `git diff --check` was clean.
  - `git status --short` shows only the two allowed files modified.

## Completed assignment: narrow Debug-only Bound fixtures

Narrow the two Debug-only `RedBlackTreeBoundExpression` fixture constructors from
client-visible public API to package-only API, without changing their behavior or the
other Debug-only clusters.

## Objective

Change only `index(_:)` and `debug(_:)` under `#if DEBUG` from
`@inlinable public static` to `@inlinable package static`. Preserve their bodies,
internal enum cases, evaluation behavior, and all callers.

## Allowed changes

- `Sources/RedBlackTreeCollections/Implements/BoundsExpression/RedBlackTreeBoundExpression.swift`
- `CHANGELOG.md`
- the relevant current-state row or note in
  `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Maintanance/PROGRESS_OVERVIEW.md` only if an existing checklist/status statement can
  be accurately advanced without rewriting unrelated history
- `Maintanance/CLAUDE_TASK.md`

The intended source change is exactly the two access modifiers. Tests should not need
editing because every caller belongs to this Swift package and package access is the
required floor for the non-`@testable` numbered specification test.

## Must preserve

- Keep `#if DEBUG`, `@inlinable`, signatures, bodies, `Internal.index` / `.debug`, and
  `UnsafeTreeV2` evaluation unchanged.
- Do not touch the `Balanced*` executable API Matrix, its conformances,
  `freeCapacity`, or `popFirst(_:)` / `popLast(_:)`.
- Do not touch `Result` retroactive conformance, `_LazyTieWrap`, `_NodePtrSealing`,
  `_LazyTie`, public Index representation, Range/View contracts, or compatibility mode.

## Do not

- Do not edit `Package.swift`, workflows, benchmarks, API Matrix documents, or tests.
- Do not perform unrelated cleanup.
- Do not stage or commit files and do not perform branch/history/network operations.
- Do not inspect `try/index/1`.

## Validation

1. Build tests in Debug.
2. Run the numbered Set Bound Expression tests and the four container
   `*_98_InternalTests` that use `.index` / `.debug`; confirm intended tests were
   discovered and executed.
3. Build `RedBlackTreeCollections` in Release.
4. Run the established Release DocC warnings-as-errors command.
5. Run `git diff --check`, inspect the complete diff, and confirm that only allowed
   files changed.

Record the access-floor evidence, exact commands, test discovery/counts, and results.
Set this task to `Completed` and report only `完了` to the user. Explain directly only
if blocked, if an unrelated regression appears, or if a product-owner decision is
required.

### Result (2026-10-04, Claude Opus 5.5)

- Changed `RedBlackTreeBoundExpression.swift:209,214` (`index(_:)`, `debug(_:)`) from
  `@inlinable public static` to `@inlinable package static`. Nothing else in source
  changed.
- Access-floor evidence: `RedBlackTreeSet_16_BoundExpressionTests` imports without
  `@testable` and still compiles unchanged, which requires `package`. The four
  `*_98_InternalTests` use `@testable`.
- Documentation updated:
  - `CHANGELOG.md`: added an Unreleased / Changed entry (Debug-only source break);
  - `PROGRESS_OVERVIEW.md`: added one checked item to the existing public-surface
    checklist;
  - `EXTERNAL_TYPE_EXTENSION_AUDIT.md`: appended `### Bound index / debug implementation
    result`. That file's earlier uncommitted diff is the previous audit section.
- Validation:
  - `swift build --disable-sandbox --build-tests` (Debug): succeeded.
  - `swift test --disable-sandbox --skip-build --filter 'RedBlackTreeSetBoundExpressionTests|InternalTests'`:
    - XCTest: `RedBlackTreeSetBoundExpressionTests`, 27 tests, 0 failures.
    - Swift Testing: `RedBlackTree{Set,MultiSet,Dictionary,MultiMap}InternalTests`,
      4 tests in 4 suites, all passed.
  - `swift build --disable-sandbox -c release --target RedBlackTreeCollections`:
    succeeded.
  - The CI Release DocC `generate-documentation ... --warnings-as-errors` command:
    succeeded.
  - `git diff --check`: clean.
  - Changed files are only the allowed ones: source file, `CHANGELOG.md`, the audit,
    `PROGRESS_OVERVIEW.md`, and this file. Nothing was staged.

## Completed assignment: audit Debug / Release public-surface differences

Perform a read-only decision audit of the Debug-only public surface in
RedBlackTreeCollections, separating work that is safe before the public Index decision
from work that must remain deferred.

## Objective

Produce the next bounded implementation recommendation for eliminating unintended
Debug/Release API differences. Do not change source, tests, access levels, or build
configuration in this task.

## Scope

Audit these known groups as coherent dependency clusters:

1. `BalancedSequence`, `BalancedCollection`, `BalancedMultiCollection`, `BalancedView`,
   `BalancedDynamic`, `BalancedSomething`, their container/View conformances, and
   `RedBlackTreeSet.freeCapacity`.
2. Debug-only `RedBlackTreeBoundExpression.index(_:)` and `.debug(_:)`.
3. Debug-only comparison declarations involving `Result`, `_LazyTieWrap`,
   `_NodePtrSealing`, and their conformances.

Product-owner clarification for cluster 1: the `Balanced*` protocols are an executable,
source-level API Matrix. Their purpose is to make the compiler verify that the intended
container/View API families remain present and mutually aligned. Do not classify them
as unused abstraction merely because production algorithms do not consume them.

Use these records as the starting point:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`
- `Maintanance/PROGRESS_OVERVIEW.md`
- `Tests/TESTING.md`

Inspect relevant production declarations, direct and generic callers, numbered tests,
Debug additionals, compatibility guards, `@inlinable` visibility requirements, and
public signatures. Repository-local evidence only; no network access.

## Required analysis

For each cluster, record:

- exact declarations and guards;
- why it exists and every repository consumer;
- whether it affects observable product semantics or is test/debug instrumentation;
- whether moving it to TestSupport, narrowing it, deleting it, or making it consistent
  across Debug/Release is mechanically possible;
- whether it depends on the unresolved public Index representation, `Index: Comparable`,
  Range/View contracts, compatibility mode, or performance design;
- the smallest independent implementation batch, required files, expected validation,
  and source-compatibility impact.

Do not treat all Debug-only declarations as one batch merely because they share a guard.
In particular:

- Preserve the compile-time API-matrix function of the `Balanced*` cluster. Compare the
  tradeoffs of keeping it Debug-only in production source versus relocating an
  equivalent compile-time contract to test support, but do not recommend deletion
  unless an equally comprehensive compiler-checked replacement is identified.
- Treat `freeCapacity` as part of that executable contract even if it has no runtime
  caller. Determine whether it expresses an intended API requirement or an obsolete
  matrix row; do not infer the answer from reference count alone.
- Do not remove or redesign the retroactive `Result: Comparable` conformance; classify
  it as Index-dependent unless source evidence proves otherwise.
- Do not remove `freeCapacity` independently from the `BalancedDynamic` requirement.
- Do not decide the final public Index representation or Comparable policy.
- Do not turn Debug-only diagnostics into Release product API merely to equalize symbol
  graphs.

## Output

Append one concise section named exactly:

`### Debug / Release public-surface decision audit`

to `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Include:

1. a dependency table for the three clusters;
2. confirmed independent work, if any;
3. deferred Index/product decisions;
4. one recommended next implementation batch, or an explicit finding that none is safe;
5. one verdict:
   - `independent implementation batch available`
   - `all remaining work is decision-bound`
   - `product-owner decision required`

If an independent batch is recommended, its boundary must compile without changing the
other two clusters.

## Boundaries

The only files this task may edit are:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Maintanance/CLAUDE_TASK.md`

Do not edit source, tests, `Package.swift`, workflows, API matrices, CHANGELOG, or other
management documents. Do not run the full test suite. Do not stage files. Do not commit,
push, pull, merge, rebase, switch branches, inspect `try/index/1`, or alter Git history.

## Validation and handoff

Re-run searches covering every declaration and repository reference used by the
conclusion. Run `git diff --check` on the two allowed files and inspect their complete
diff plus `git status --short`. Tests are not required for this read-only audit.

Set this task to `Completed`, append a concise result and validation evidence below the
assignment, and report only `完了` to the user. Explain directly only if blocked, if a
safety issue is found, or if a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

I appended `### Debug / Release public-surface decision audit` to
`EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Verdict: `independent implementation batch available`.

- **Cluster 1 (Balanced\* protocols + `freeCapacity`):** moving it to TestSupport is
  mechanically possible, but two decisions block it.
  - The numbered spec test `RedBlackTreeMultiMap_8_RangeViewTests.swift:68-82` uses the
    Debug-only `popFirst(_ k:)` / `popLast(_ k:)`. The TODO in their source says they are
    wrong, so what happens to them is a spec decision.
  - The performance TODO says removing the conformances hurts performance, but the
    conformances exist only in Debug, so they cannot affect Release performance. Removing
    that TODO contradicts the owner's note.
  - Its Index requirement is `Equatable` only, so this cluster does not depend on
    `Comparable`.
- **Cluster 2 (Debug `RedBlackTreeBoundExpression.index(_:)` / `.debug(_:)`):** this is
  the recommended next batch.
  - Change both from `@inlinable public static` to `@inlinable package static` in
    `RedBlackTreeBoundExpression.swift:208-216`.
  - All callers are tests in this package. `RedBlackTreeSet_16_BoundExpressionTests`
    imports without `@testable`, which is why the floor is `package` rather than
    `internal`.
  - No test edits are needed, the other clusters stay untouched, and the Release surface
    does not change.
  - Gate A had listed these two as waiting on the Index contract. I revised that,
    because narrowing access does not fix the Index representation.
- **Cluster 3 (Debug Comparable declarations: `Result` retroactive, `_LazyTieWrap`,
  `_NodePtrSealing`, `_LazyTie`):** deferred until the Comparable policy and Index
  representation are decided. Its consumers are the numbered test
  `RedBlackTreeSet_9_ProtocolConformanceTests:66-71` and `TreeFoundamentalNodeSealingTests`.

Validation:

- Searches covered Balanced\*, `freeCapacity`, `popFirst(k)` / `popLast(k)`,
  bound `.index` / `.debug` forms (explicit and implicit-member), and the Debug
  Comparable declarations plus their users. They ran over `Sources`, `Tests`,
  `Benchmarks/Sources`, and repository Markdown.
- No build or test was run.
- `git diff --check` on both allowed files was clean.
- `git status --short` shows only `Maintanance/CLAUDE_TASK.md` and
  `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md` modified.

## Completed assignment: narrow View `_isIdentical(to:)`

Narrow the normal-mode View-only `_isIdentical(to:)` hooks from public API to the
minimum visibility required by their public `@inlinable` comparison operators.

## Objective

Remove the three underscored View identity hooks from the client-visible API without
changing View equality, ordering, complexity, compatibility mode, or the four
containers' documented `isTriviallyIdentical(to:)` API.

## Context

- Branch: `develop/misc/48`. The working tree was clean when assigned.
- Codex independently confirmed that normal mode has three relevant declarations:
  KeyOnly Range View, KeyValue Range View, and MappedValues View.
- KeyOnly and KeyValue call the hook from public `@inlinable` `==` / `<`; MappedValues
  has no repository caller. No public protocol requires the hook.
- This batch is independent of the unresolved public Index representation decision.
- The four containers' non-underscored `isTriviallyIdentical(to:)` is intentional,
  documented public API and is not part of this change.

## Allowed changes

1. In these three normal-mode files only, replace `public` on `_isIdentical(to:)` with
   the narrowest compiler-valid visibility required by serialized callers, expected to
   be `@usableFromInline internal`, while preserving `@inlinable` and the implementation:
   - `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeRangeView+KeyOnly.swift`
   - `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeRangeView+KeyValue.swift`
   - `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift`
2. Update the `_isIdentical(to:)` row in
   `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` so it records the
   completed narrowing rather than listing it as an unresolved public audit candidate.
3. Add a concise source-breaking public-surface narrowing entry to `CHANGELOG.md`.
4. Append a concise implementation result to
   `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`, including exact declarations,
   validation, and the fact that compatibility-mode declarations were untouched.
5. Update this task with the result and validation evidence.

## Must preserve

- Do not change `isTriviallyIdentical(to:)` on Set, MultiSet, Dictionary, or MultiMap.
- Do not change compatibility-mode `_isIdentical` declarations under
  `Implements/Deprecated`.
- Do not change method bodies, equality/ordering semantics, raw range representation,
  Index representation, protocols, or generic constraints.
- Preserve unrelated user changes and existing completed audit records.

## Do not

- Do not perform unrelated cleanup or documentation rewrites.
- Do not edit `Package.swift`, workflows, benchmarks, or tests unless compilation proves
  a narrowly scoped test edit is indispensable; stop and record the reason before doing
  so.
- Do not commit, push, pull, merge, rebase, switch branches, or alter Git history.
- Do not stage files.
- Do not inspect or modify `try/index/1`.

## Validation

Run the narrowest checks first, then confirm the batch across its serialization boundary:

1. Refresh/compile the three changed source files or build `RedBlackTreeCollections` in
   Debug.
2. Run the existing Range View and MappedValues View tests, confirming intended tests
   were actually discovered and executed.
3. Build `RedBlackTreeCollections` in Release.
4. Validate Release DocC with warnings as errors using the repository's established
   command if it is available without changing configuration.
5. Run `git diff --check` and inspect `git status --short` plus the complete diff.

If `@usableFromInline internal` does not compile, do not broaden visibility by guesswork.
Record the compiler evidence and choose only the narrowest visibility demonstrably
required by the public `@inlinable` callers.

## Handoff

Set this task to `Completed`, append a concise result and exact validation commands
below this assignment, and report only `完了` to the user. Put all technical detail in
this Markdown file. Explain directly only if blocked, if an unrelated regression is
found, or if a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

- Narrowed `public func _isIdentical(to:)` to `internal func` in three files, keeping
  `@inlinable` and the bodies unchanged:
  - `RedBlackTreeView/RedBlackTreeRangeView+KeyOnly.swift:351`
  - `RedBlackTreeView/RedBlackTreeRangeView+KeyValue.swift:422`
  - `RedBlackTreeView/RedBlackTreeMappedValuesView.swift:351`
- Why the access is `@inlinable internal` rather than `@usableFromInline internal`: an
  internal `@inlinable` declaration is already usable from inlinable code, so the public
  `@inlinable` `==` / `<` can still call it, and the Release build compiles. Adding
  `@usableFromInline` would be redundant. No caller elsewhere in the package needs
  `package` access.
- Left unchanged:
  - the compatibility-mode `_isIdentical` declarations under `Implements/Deprecated`;
  - the four containers' `isTriviallyIdentical(to:)`;
  - tests, benchmarks, and `Package.swift`.
- Documentation updated:
  - `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md`: the
    `_isIdentical(to:)` row now records the completed narrowing;
  - `CHANGELOG.md`: added an `Unreleased` / `Changed` entry marked source-breaking;
  - `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`: appended
    `### _isIdentical implementation result`.
- Validation:
  - `swift build --disable-sandbox --target RedBlackTreeCollections` (Debug): succeeded.
  - `swift build --disable-sandbox --build-tests` (Debug): succeeded.
  - `swift test --disable-sandbox --skip-build --filter 'RangeView|MappedValuesView'`:
    98 RedBlackTreeTests XCTest cases passed with 0 failures, plus 1 Swift Testing test.
    The discovered suites included KeyOnly, KeyValue, and MappedValues View tests, and
    the Set, MultiSet, Dictionary, and MultiMap Range View tests.
  - `swift build --disable-sandbox -c release --target RedBlackTreeCollections`:
    succeeded.
  - The CI Release DocC command (`swift package --disable-sandbox -c release ...
    generate-documentation --target RedBlackTreeCollections --output-path
    .build/documentation --transform-for-static-hosting --hosting-base-path
    swift-ac-collections --warnings-as-errors`) succeeded. Its output went to the
    existing `.build/documentation` path.
  - `git diff --check`: clean.
  - `git status --short` shows only the seven intended files modified. Nothing was
    staged.

## Completed assignment: review of the RedBlackTree Index decision gate

Perform a read-only review of `### C〜F 調査結果と暫定推奨` in:

- `Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`

The product owner uses apple/swift-collections' `Sources/ContainersPreview` as the
upstream design reference. We should track and learn from the experimental protocol as
it evolves, permit small disposable compatibility experiments, and avoid finalizing the
production Index representation until the requirements are sufficiently stable. The
current nominal/non-Comparable/non-failure-valued design is a provisional recommendation.

Check specifically:

1. whether all four normal-mode containers and all Range/MappedValues Views can retain
   their documented APIs without `Index: Comparable`;
2. whether any public generic constraint, operator, range expression, benchmark,
   external compatibility surface, or planned conformance actually requires
   `Comparable`;
3. whether removing failure-valued public Index loses any intentional behavior of
   movement, bounds evaluation, stale-index diagnostics, or cross-tree resolution;
4. whether `Equatable` / `Hashable` can honestly remain O(1), including storage identity,
   generation, `endIndex`, and `ALLOW_CROSS_TREE_INDEX` behavior;
5. whether the proposed public/internal boundary is implementable without exposing
   `_LazyTieWrap`, `_NodePtrSealing`, `UnsafeNode`, `SealError`, or `Result` through
   public signatures or `@inlinable` bodies;
6. source-compatibility and migration risks that must be explicit before implementation;
7. whether any work in C〜F remains safe and useful now without prematurely choosing the
   future Container conformance or Index representation;
8. whether the new `Container protocol追跡基準` accurately reflects current upstream,
   especially `Index: Equatable & Hashable` without `Comparable`, and whether span/lifetime
   requirements create a separate blocker for this node-based tree;
9. the existing `try/index/1` preparation implementation, using its merge-base with HEAD
   and only the Index-related diff. Confirm what it already proves, what is obsolete, and
   what blocks reuse on current HEAD. Pay particular attention to `_LazyTiedPtr`, internal
   resolver Results, `try!`, bare `fatalError()`, the Debug `.nullptr` sentinel, the
   sanitizer TODO, and O(1) equality/hash claims. Do not merge or modify that branch.

Do not edit source, tests, access levels, Package.swift, the proposed section, or another
document. Do not implement or benchmark a prototype and do not reopen Memoize/B4 work.
Append only `### Claude review of C〜F Index decision gate` immediately before
`### 主経路のチェックリスト` in the same file. Separate blocking corrections,
non-blocking safeguards, confirmed findings, and give one verdict:

- `tracking boundary is correct`
- `decision boundary needs correction`

Then set this task to Completed, append a concise result below this assignment, and
report only `完了` to the user. All detail belongs in the Markdown record.

### Result (2026-10-04, Claude Opus 5.5)

Appended `### Claude review of C〜F Index decision gate` before `### 主経路のチェックリスト`.
The review was read-only: no build, test, or prototype was run. Upstream evidence came
only from the in-repo checkouts: swift-collections 1.7.0 (`a66de878`, pinned by
`Benchmarks/Package.resolved`) and a 2026-05 snapshot.

Verdict: `decision boundary needs correction`. Blocking corrections:

1. Upstream 1.7.0 `Container.Index` is `Equatable, Comparable, Hashable`, and
   `RangeExpression2` also requires `Comparable`. The 2026-05 snapshot had `Equatable`
   only, so Comparable was added, not removed. Cite a newer upstream commit or correct
   the tracking criteria.
2. Rejecting a stale index before dereference fails under the `_O_UNCHECKED` trait. The
   subscript validates with `precondition` followed by `pointer!`, and `-Ounchecked`
   removes both checks. E's "precondition failure" would carry the same gap into the
   contract.
3. With `ALLOW_CROSS_TREE_INDEX`, an old index still resolves in a CoW copy but compares
   unequal to that copy's indices. F must define `==` as token identity. The hash
   description in C is also inaccurate: it does not include storage identity.
4. `try/index/1` still publicly aliases `_LazyTieWrap`. It is a partial Result-removal
   PoC, not a nominal-type PoC.

Non-blocking points cover:

- compat-mode Comparable;
- the Debug Comparable numbered spec test;
- source-migration items;
- `@frozen` having no effect without library evolution, and `@inlinable` bodies still
  serializing internals;
- HEAD's bare `fatalError()` and the double `adv_iter` call in `form_index`;
- span and lifetime as a separate blocker.

Reuse blockers in `try/index/1`:

- `try!` without diagnostic messages;
- the Debug `.nullptr` sentinel, which reintroduces a failure state;
- an assert weakened around a sanitizer report (suspected early release);
- missing MappedValuesView;
- stale paths and duplicated overloads.

## Completed assignment: adversarial review of Gate B classification draft

Read-only review the new `## Gate B classification draft` in:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`

Check whether Codex has classified any declaration as Index-independent when it is
actually required by the current or candidate Index/Range/View surface, or proposed a
batch that cannot compile independently. Focus on B4-a through B4-e, the boundary
between B2 and B3, and the claim that B4-a is the safest first implementation unit.

Use source/reference evidence. Verify especially `@inlinable` / `@usableFromInline`
constraints, public protocol requirements, benchmark target access, production vs
experimental `___meld_unique`, Memoize references, and Debug-only APIs. Do not edit the
draft, source, tests, access levels, or Package.swift; do not run the full suite.

Append only `### Claude review of Gate B draft` after the draft verdict, containing
blocking corrections, non-blocking safeguards, confirmed classifications, and a verdict
on whether B4-a may become the first implementation work order. Then mark this task
Completed and report only `完了` to the user.

### Result (2026-10-04, Claude Opus 5.5)

Appended `### Claude review of Gate B draft` to `EXTERNAL_TYPE_EXTENSION_AUDIT.md`. The
review was read-only: no build or test was run, and no source, test, or `Package.swift`
was edited.

Blocking corrections:

1. B4-d: `freeCapacity` exists only to satisfy the Debug `BalancedDynamic` requirement,
   so it cannot be removed independently. Move it to B5 with the Balanced group.
2. B4-e has two problems:
   - It is not Index-independent: `_Indices.next()` returns `UnsafeIndexV3`, and
     `__raw_find` returns `UnsafeMutablePointer<UnsafeNode>`.
   - The `Benchmarks/` client is a separate package, so it can never use `package` or
     test-support access.
3. B2 and B3 overlap: B3 lists `UnsafeNode` and `_RawRange*`, which are Index layout and
   range storage, and `UnsafeTreeV2.Index` belongs to B2.

Verdict: B4-a may be the first work order, under these conditions:

- the narrowing floor is `@usableFromInline package`, because tests in three targets use
  these declarations directly;
- the order states whether `__eager_compare_result` is included;
- the three test targets are built and run in both Debug and Release;
- the design document and CHANGELOG are synchronized.

B4-b (Memoize) is technically separable but needs a product-owner decision, because it
was published in 0.1.33 as a feature.

## Completed assignment: close RedBlackTree public-surface inventory gate A

Perform the final read-only mechanical extraction for gate A of
`Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`.

Primary record:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`

Inspect `Sources/RedBlackTreeCollections` and enumerate declarations that can affect
clients before Codex classifies or narrows them. Cover at least:

- public members and types whose names begin with `_` or `__`;
- public `Unsafe*`, `SealError`, public typealiases, global functions and operators;
- extensions of standard-library-owned types, including split-line access modifiers;
- public and retroactive protocol conformances;
- declarations exposed through a public typealias or public signature;
- `@frozen`, `@inlinable`, and `@usableFromInline` declarations relevant to client
  compatibility;
- differences under DEBUG / Release, `COMPATIBLE_ATCODER_2025`,
  `ALLOW_CROSS_TREE_INDEX`, `USE_LAZY_DETACH`, and compact metadata branches.

This is inventory only. Do not decide what should remain public, edit source/tests,
move TestCode, run the suite, change access levels, or act on Index-dependent groups.
Do not inspect unrelated module APIs except where `AcCollections` re-exports the
RedBlackTree surface.

Append a bounded `## Gate A final extraction` section to
`EXTERNAL_TYPE_EXTENSION_AUDIT.md`. It must contain:

- newly found omissions with source/line evidence;
- existing rows confirmed complete;
- configuration-only surface differences;
- an explicit list of declarations whose classification must wait for the Index
  contract;
- a verdict: `complete for classification` or `not complete`, with exact blockers.

Do not rewrite the existing audit table. If there are no omissions, say so and record
the extraction method. Then change this task status to `Completed`, append a concise
result here, and report only `完了` to the user.

### Result (2026-10-04, Claude Opus 5.5)

- Appended `## Gate A final extraction` to `EXTERNAL_TYPE_EXTENSION_AUDIT.md`. The
  existing table was not rewritten.
- Method: `swift build --target RedBlackTreeCollections` in Debug and Release, plus
  Debug variants with `-Xswiftc -D{COMPATIBLE_ATCODER_2025,USE_LAZY_DETACH,USE_COMPACT_NODE_METADATA}`.
  The default Debug was rebuilt afterward. Symbol graphs were extracted with
  `swift-symbolgraph-extract -minimum-access-level internal` into a `mktemp -d` directory,
  filtered to effectively public symbols, and the directory was then deleted.
  Disabled `ALLOW_CROSS_TREE_INDEX` and `BENCHMARK` were checked from source only.
- Result: all stdlib-type extension rows were confirmed. The `UnsafeMutablePointer` helper
  row is mostly `package`, not "internal-centred". There are 13 omission groups. The main ones:
  - the Debug `Result: Comparable` is generic over every `Result` whose `Success` and
    `Failure` are `Comparable`;
  - Debug-only public `Balanced*` protocols and container conformances, Debug-only
    `RedBlackTreeSet.freeCapacity`, and `BoundExpression.index`/`.debug`;
  - 60 public protocols (45 underscore-named);
  - `UnsafeTreeV2`/`UnsafeNode` public members;
  - deprecated `_Obverse1-3`/`_Reverse1-3` compiled in the default build;
  - the Memoize group;
  - `@frozen` layout exposure.
- Configuration-only differences are recorded. Debug vs Release: +71/0 declarations.
  Compat: +340/-297. `USE_LAZY_DETACH`: removes Set/MultiMap
  `index(inserting:)`/`erase(exactly:)` and changes the Index layout. Compact metadata:
  changes `_TrackingTag`/`Seal` widths.
- An Index-bound list is recorded. Verdict: `complete for classification`, with no
  blockers. No source, tests, or `Package.swift` were changed, and the suite was not run.

## Completed assignment: independently assess the user's project management

Fill only:

- `Maintanance/USER_MANAGEMENT_INTERVIEW_CLAUDE.md`

Do not read `USER_MANAGEMENT_INTERVIEW_CODEX.md` until your independent answer is
complete. Evaluate the user's management of this repository and AI collaboration, not
the user's personality. Use observed events and outcomes, and do not turn stylistic
preferences into faults.

Replace every `未回答` in the table, write the short overall assessment, and propose a
delegation boundary among user, Codex, and Claude. Distinguish necessary product-owner
involvement from avoidable micro-management caused by weak AI task handling. Explicitly
acknowledge cases where your own behavior created the need for closer supervision.

Do not change the Codex file, source, tests, another maintenance document, or reopen a
technical task. When finished, change this file's status to `Completed`, append a short
result under this assignment, and report only `完了` to the user.

Result (2026-10-04, Claude Opus 5.5): `USER_MANAGEMENT_INTERVIEW_CLAUDE.md` is filled independently, without reading the Codex file. It covers all 15 rows, the overall assessment, and the delegation boundary, and it states where Claude's own behavior required closer supervision. No other file was changed.

## Completed assignment: final agreement on the task-fit policy

Read the final applied corrections and `## Codex response to Claude review` in:

- `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`

This is a final agreement check, not another open-ended review. Confirm only whether:

1. the score changes and role labels accurately reflect your review;
2. public-contract decisions are correctly left to the user after Codex drafts and
   integrates evidence;
3. the symmetric read-only review rule is acceptably limited to high-risk or canonical
   Codex work rather than every local edit;
4. the resulting table is safe to use for future assignments.

Do not introduce new optimization ideas, residual tasks, source findings, or stylistic
preferences. Do not edit the interview table, source, tests, or another document.
If you agree, append exactly one short `### Claude final agreement` paragraph under
`## Codex response to Claude review`, stating agreement and any already-recorded
conditions that remain binding. If you disagree, list only a concrete mismatch between
your prior review and the applied text; do not reopen settled subjects.

Then change this file's status to `Completed` and append a one-sentence result under
this assignment. Report only `完了` to the user.

Result (2026-10-04, Claude Opus 5.5): I agreed to the applied task-fit policy in `AGENT_TASK_FIT_INTERVIEW.md` (`### Claude final agreement`); the per-row conditions already recorded remain binding.

## Completed assignment: adversarial review of Codex self-assessment

Perform a read-only adversarial review of the Codex side of:

- `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`

Review the newly filled `Codex自己評価・懸念`, the Codex ratings, assignment proposals,
and `## Codexヒアリング回答`. The purpose is to detect overconfidence and weak task
separation, not to be agreeable and not to re-evaluate your own column.

For each material objection:

- identify the row ID;
- state whether the Codex score should stay, decrease, or increase;
- distinguish `主担当可` from work that still requires a user decision, a Claude
  adversarial review, an external/toolchain check, or a second implementation pass;
- cite repository-specific evidence from prior tasks, diffs, maintenance records, or
  observed failure modes;
- flag places where Codex claims integration skill but may consume too much context,
  broaden scope, stop before repetitive completion, or mistake a plausible design for
  verified behavior;
- also confirm strengths where the existing assignment split has concrete evidence.

Pay special attention to rows rated Codex `5`, and to H, J, V1, V3, V4, and V5 where
performance, unsafe memory, ownership, or concurrency make self-confidence costly.
Do not lower a score merely because all engineering benefits from review; explain what
would make the proposed ownership unsafe or inefficient in this repository.

Do not edit the interview table, either self-assessment column, source, tests, or any
other maintenance document. Do not implement residual work or run tests. Append only a
compact `## Claude review of Codex self-assessment` section to
`AGENT_TASK_FIT_INTERVIEW.md`, containing:

- required rating/assignment corrections;
- recommended safeguards that do not require a rating change;
- confirmed Codex strengths;
- a verdict on whether the table is safe to use for future assignment.

Then change this file's status to `Completed` and append a one-paragraph result note
under this assignment. Report only `完了` to the user; the review belongs in the MD.

### Result (2026-10-04, Claude Opus 5.5)

I appended `## Claude review of Codex self-assessment` to `AGENT_TASK_FIT_INTERVIEW.md`. The table,
both self-assessment columns, and every other file are unchanged, and no test was run. The review
recommends lowering B, G, H, J, V1, V3, and V4 from 5 to 4, and V5 from 4 to 3 for both agents. It
recommends relabeling D, E, F, I, P1, and P2 as draft ownership with the decision going to the user,
and marking D3 as blocked on the facade re-export decision. It also proposes a symmetric rule: a
Codex-authored plan, audit, or progress index needs a Claude factual review before it becomes a work
order. The main evidence is that all three Codex planning documents reviewed today had blocking
corrections. The review also confirms Codex strengths in cross-configuration integration, contract
preservation on Linux, evidence restraint, and audit-driven bug discovery.

## Completed assignment: answer the remaining-task fit interview

Read and answer the Claude side of:

- `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`

This is a self-assessment and assignment-design interview, not an implementation task.
Evaluate your fit based on how you actually work in this repository, including both
successful long-form test expansion and the observed tendency to broaden scope or
over-report when boundaries are unclear.

For every row in the remaining-task table:

- fill `Claude自己評価・懸念` with one compact entry using
  `主担当可` / `見本またはレビュー必須` / `補助のみ`;
- name the most important risk or prerequisite in the same cell;
- challenge the existing Claude score or assignment proposal when you disagree, but
  give a concrete repository-specific reason;
- distinguish work you can implement well from work where your stronger role is
  adversarial/read-only review;
- state where you need a Codex example, design decision, stop point, or final review.

After the table, add a short `## Claudeヒアリング回答` section answering the common
questions once at the level of overall working style. Include:

- the three task shapes where you are most useful;
- the three task shapes most likely to go wrong;
- the minimum instructions needed to keep scope bounded;
- when you should stop and return the work to Codex;
- whether detailed findings should always go to the task MD while the user receives
  only `完了`.

Do not edit the Codex self-assessment column, silently rewrite Codex's ratings, alter
source/tests, change any other maintenance document, implement a residual task, run
tests, or reopen cancelled work. You may suggest score/assignment changes in your own
cell or response section; Codex will decide whether to apply them.

Keep each table response short. This is not an invitation to produce an essay for each
row. When finished, change this file's status to `Completed` and append a one-paragraph
result note immediately below this assignment. Report only `完了` to the user; the
substantive answer belongs in `AGENT_TASK_FIT_INTERVIEW.md`.

### Result (2026-10-04, Claude Opus 5.5)

I filled only the `Claude自己評価・懸念` column for all 28 rows and added a `## Claudeヒアリング回答`
section in `AGENT_TASK_FIT_INTERVIEW.md`. The Codex column, the ratings, and every other file are
unchanged, and no test was run. Rows rated `主担当可`: A, K, L, T1, U1, D1, D2, V6, V7. Each assumes
a Codex example or boundary where noted, and Codex keeps final judgment for L. Suggested score
changes appear in my cells and only cover my role in the judgment itself: D 4→3, I 3→2,
P1/P2 3→2, V2 5→4, V5 4→3. For contract and representation rows (B, D–F, I, P1/P2) I recommend
treating me as an adversarial read-only reviewer rather than an author.

## Completed assignment: review the consolidated progress overview

Perform a read-only factual review of:

- `Maintanance/PROGRESS_OVERVIEW.md`

Check it against the current source, tests, package manifest, git-visible documentation,
and the existing maintenance records. The purpose is to make the overview trustworthy,
not to expand the project scope or restart old work.

Review all modules, not only `RedBlackTreeCollections`. In particular:

- identify completed or active work missing from the overview for
  `PermutationModule`, `BareArrayModule`, `OptionalArrayModule`, `AcCollections`, and
  `_RedBlackTreeModule`;
- verify that every `完了`, `ほぼ完了`, `部分完了`, `保留`, and `中止` judgment has
  evidence and is not overstated;
- review the new module-by-module comment-documentation table. Distinguish existing
  comments from a systematic public-API audit, and check whether each module's stated
  remaining work is accurate;
- verify that facade/re-export modules really have no independent public declarations,
  and whether module-level documentation is the right remaining unit;
- check that the LLVM libc++ normative comparison, GNU libstdc++ reference-only result,
  and explicit exclusion of MSVC are represented consistently;
- check that the current work order reflects real dependencies: public-surface audit
  and Index contract first, dead-code judgment afterward, without falsely making
  independent non-RedBlackTree documentation depend on Index;
- identify stale claims, duplicated tasks, missing evidence documents, incorrect names,
  or material completed work recorded only elsewhere;
- distinguish a missing progress entry from a new task proposal. Do not manufacture
  completion claims from raw comment counts or passing tests alone.

Do not edit `PROGRESS_OVERVIEW.md` or any source/test/documentation file. Do not implement
fixes, resume benchmarks, run the full test suite, or reopen the cancelled broad
Compatibility-document audit. Narrow read-only searches are allowed; builds are not
needed unless a specific factual claim cannot otherwise be checked.

Append a concise `### Review result` directly under this assignment containing:

- blocking factual corrections;
- missing progress items;
- non-blocking wording or ordering improvements;
- confirmed claims;
- an explicit verdict on whether the overview is safe to use as the project progress
  index.

Give file/line or maintenance-record evidence for material corrections. Then change
the status to `Completed`. Report only `完了` to the user; all details belong in this
file for Codex to read.

### Review result (2026-10-04, Claude Opus 5.5)

Read-only: grep/sed of source, manifest, tests, and maintenance records. No build or test was run.
Line numbers refer to `Maintanance/PROGRESS_OVERVIEW.md` (abbreviated `PO`) unless a file is named.

**Blocking factual corrections**

1. *PermutationModule's AtCoder 2025 compatibility mode is missing, so 「ほぼ完了」 is overstated.*
   The plan is user-requested (`MAINTENANCE.md:91-93`) and still unimplemented.
   `AtCoder2025CompatibilityPlan.md:101-110` lists every implementation step as 「今回実施しない」.
   `Sources/PermutationModule` contains neither `COMPATIBLE_ATCODER_2025` nor `Compatibility/`, and
   `COMPATIBLE_ATCODER_2025` is still a commented manual define (`Package.swift:36`), not a trait.
   PO:33 and PO:104 should list this as 未着手/保留 with the plan as evidence. PO:178 (ABC328E) is
   step 3 of that same plan (`AtCoder2025CompatibilityPlan.md:86-91`), so it is not an independent
   item. "PO:30 Permutationは完了" applies only to the current-mode comment docs.
2. *Module name.* The module/target is `RedBlackTreeModule`; `_RedBlackTreeModule` is only its
   directory (`Package.swift:226-229`, `path: "Sources/_RedBlackTreeModule"`). Fix PO:108 and PO:162.
3. *The AcCollections re-export scope is stated too broadly.* PO:107 and PO:130 say re-export works
   in normal and compat mode. Normal mode re-exports only `RedBlackTreeCollections`. Compat mode
   adds `RedBlackTreeModule` and `PermutationModule` (`Sources/AcCollections/AcCollections.swift:1-6`).
   `OptionalArrayModule` and `BareArrayModule` are dependencies of `AcCollections`
   (`Package.swift:184-196`) but are never re-exported, and the only product is `AcCollections`
   (`Package.swift:122`). The tests cover exactly RBT in normal mode and `nextPermutations()` in
   compat mode (`Tests/AcCollectionsTests/AcCollectionsTests.swift:48-79`). The overview should
   state this scope as fact. Whether it is intended is a facade-documentation question for the
   user or Codex, not something already verified.
4. *Permutation comment-doc 「完了」 does not meet the recorded stop condition.* `MAINTENANCE.md`
   (停止条件, 2026-10-02 21:08) requires independent Codex and Claude checks that include DocC
   output. Only `RedBlackTreeCollections` has a DocC catalog and a CI DocC step (single `.docc`
   under `Sources/RedBlackTreeCollections`; `.github/workflows/swift.yml` builds `--target
   RedBlackTreeCollections` only). Write PO:104 as 区切り完了 (独立確認・DocC未実施), not 完了.
   Also, public `enum Permutations` has no `///` (`Sources/PermutationModule/Permutations.swift:27-29`),
   and `SubSequenceN._copyCount` is public only under `AC_COLLECTIONS_INTERNAL_CHECKS`
   (Debug, :172-174). That is a Debug-only public member, the same class of issue as the RBT
   Debug/Release surface gate.

**Missing progress items (completed or active work recorded elsewhere)**

- Decodable bug fix for unsorted and duplicate input in all 4 RBT types (2026-10-03), with
  regression tests: `RedBlackTreeSet_13_CodableTests.swift:18`, `RedBlackTreeDictionary_10_CodableTests.swift:20`,
  `RedBlackTreeMultiSet_15_CodableTests.swift:18`, `RedBlackTreeMultiMap_10_CodableTests.swift:22`.
  It was found by the comment audit (`MAINTENANCE.md:292`). It is absent from PO:38-47, and it is
  also absent from `CHANGELOG.md` Fixed. Record that gap; do not fix it here.
- OptionalArray1D/View double-free on `nil` assignment, fixed (`CHANGELOG.md:42`). PO:123-130
  lists only the BareArray clone fix.
- Strict memory safety permanently applied to `AcCollections` and `RedBlackTreeModule` with
  0 warnings (`Package.swift:194,231`; `MAINTENANCE.md:85`). PO only mentions Permutation.
- DocC catalog plus Release `--warnings-as-errors` CI and GitHub Pages publishing (`CHANGELOG.md`
  Added; `swift.yml:49-74`). PO:90 mentions only the Topics reorganization.
- The RBT public comment audit series (Sequence/transform/protocol conformance comments,
  `MAINTENANCE.md:292` and neighbouring entries). PO:103 summarizes it, but this is evidence
  for the 「宣言コメント」 part and could be cited.
- Missing evidence documents in 正本 (PO:207-216): `CHANGELOG.md`; `CombiningAPIPerformanceEvidence.md`
  (needed by PO:177); `PermutationModule/{Specification,ImplementationPlan,ProductReadinessAssessment,
  AtCoder2025CompatibilityPlan}.md`; `REFACTORING_FROM_ATCODER_2025.md` (PO:95);
  `AdoptionReadinessAssessment*.md` (PO:31).

**Non-blocking wording / ordering improvements**

- Stale claims in documents that PO marks complete or canonical:
  - `Tests/TESTING.md:15` still says `CppBehaviorReferenceTests` 17件 (actual 35). PO:209 names
    `TESTING.md` as canonical. The update task exists only in `RED_BLACK_TREE_REMAINING_TASKS.md`.
  - `AdoptionReadinessAssessment.md:189-190,221` and `.ja.md:173-174,200` still list Linux
    validation as unmeasured or as a gate, and do not state the libc++-normative / libstdc++-reference
    split. This conflicts with PO:27 and PO:31 「完了・更新継続」.
- PO:79: the Linux Death Test run used `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` (this file, MultiMap
  Linux note). Qualify it, so that no one reads it as Linux lifetime-balance evidence. Linux
  lifetime balance relies on the normal CI Debug job; cite that run if one is claimed.
- Duplicated or misplaced tasks:
  - PO:169-170 are already main-path items in PO:136-140 and the audit's checklist.
  - PO:171-173 (`index(inserting:)`, `erase(exactly:)`, KeyValue View rejection) are now F-step
    contract decisions (`RED_BLACK_TREE_REMAINING_TASKS.md:233-234`), not open 判断待ち. Move them
    under PO §2.
  - PO §2 omits step C (confirming the existing safety/CoW/traversal contracts).
- PO:198-205 is presented as a linear sequence. Per `RED_BLACK_TREE_REMAINING_TASKS.md:124`, the
  A/B audit, C, D, and E can run in parallel, and PO:165 says non-RBT comment docs are independent.
  Mark steps 3 and 6 as parallelizable rather than "after".
  Step 2 should exclude the Debug-only Comparable group (`_NodePtrSealing`/`_LazyTieWrap`/`_LazyTie`/
  `Result`). That group is classify-only until D–I.
- PO:87 「4コンテナの英日ガイド」: the four-type set exists only under
  `Sources/RedBlackTreeCollections/Documentation/Head/`. Root `Documentation/` has Set, MultiSet,
  and MultiMap guides, with no Dictionary guide. Name the canonical location.
- Comment-doc table: the BareArray/OptionalArray rows correctly separate test evidence from a
  comment audit (PO:110). As a sanity hint only, not as completion evidence: about 6/29 and about
  10/29 public declaration lines are preceded by `///` in `BareArray.swift` / `OptinalArray.swift`.
  This matches 「体系監査未完」. The OptionalArray 「重要契約のみ更新」 claim is supported by
  `MAINTENANCE.md:303`.

**Confirmed claims**

- The C++ standard-library roles are consistent across PO:27,69-70,193,
  `CPP_BEHAVIOR_COMPARISON_MATRIX.md:9-12,91-93,100`, `RED_BLACK_TREE_REMAINING_TASKS.md:23,295`, and
  `MAINTENANCE.md:278-279`: libc++ normative with 35 tests in Debug and Release, libstdc++ reference
  with 35 tests in Debug, MSVC excluded.
- The MultiMap `find` non-guarantee is reflected in `Documentation/Compatibility/multimap.ja.md:104,112`.
- Neither facade declares anything public of its own. Their sources are only `@_exported import`s.
- The PO:142-143 claim that the topology review is reflected holds:
  `EXTERNAL_TYPE_EXTENSION_AUDIT.md:24-25,29,35,39,86,104,110-111` and
  `RED_BLACK_TREE_REMAINING_TASKS.md:77,112-115,124,225`.
- Permutation: strict memory safety is permanent (`Package.swift:318`), the API was reduced to
  `nextPermutations()` (`CHANGELOG.md` Removed; `TESTING.md:50-58`), and the Sendable rationale is
  documented (`Permutations.swift:153-155`).
- BareArray/OptionalArray strict memory safety is deferred pending storage redesign (`MAINTENANCE.md:86-89`).
- SortedCollections is 保留 after the Phase 3 pilot (`SORTED_COLLECTIONS_BENCHMARK_TASK.md:3,443-462`).
- The Compatibility-audit stop is recorded in 中止 with a no-resume rule.

**Verdict:** The overview is usable as a progress index once corrections 1–4 are applied
(Permutation compat-mode status, module name, re-export scope, Permutation doc-completion wording)
and the missing items are added. Until then it overstates Permutation and facade completeness. The
RBT main-path content and the C++ comparison representation are accurate.

## Completed assignment: review RedBlackTree remaining-task topology and public-surface audit

Perform a read-only review of these two new planning documents:

- `Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`
- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`

The purpose is to check whether the remaining work is ordered by real dependencies and
whether declarations that can affect library users are identified before dead-code
cleanup. The intended three layers are:

1. external contract;
2. implementation choices that can still affect clients, compatibility, overload
   resolution, conformances, layout, or serialized client code;
3. implementation details that are genuinely hidden from clients.

Review the documents against the actual source. In particular:

- verify the claims about `RedBlackTreeIndex`, its `Result` representation, and the
  Debug-only retroactive `Result: Comparable` conformance;
- check the external-type extension inventory for material omissions or incorrect
  visibility classifications, including `Int`, `Result`, `Range`, `ClosedRange`,
  `String`, `MemoryLayout`, pointer types, and any other standard-library-owned type;
- distinguish public members, public/retroactive conformances, package/internal
  members, `@usableFromInline`, and `@inlinable` effects precisely;
- verify which candidates are genuinely test-only by checking all source and test
  references. Pay particular attention to the `SortedSequence` experiment,
  `_LazyTieWrap`/`Result` Comparable support, and `unsafe(tree:rawTag:)`;
- review the A-to-L dependency order. Flag choices that are independent, incorrectly
  serialized, circular, or placed after work that depends on them;
- check that public-surface narrowing is correctly prioritized ahead of dead-code
  decisions without making unrelated PermutationModule API block RedBlackTree
  completion;
- identify any public `_`/`__`, `Unsafe*`, `SealError`, public typealias, or protocol
  conformance that should be included in the public-surface gate.

Do not implement fixes, move code, change access levels, run broad benchmarks, resume
the cancelled Compatibility audit, or edit either reviewed document. This assignment
is review only. Read-only searches and narrowly targeted build/typecheck checks are
allowed if needed, but do not run the full suite merely for a documentation review.

Append a concise `### Review result` under this active assignment containing:

- blocking corrections, if any;
- non-blocking improvements;
- confirmed claims;
- an explicit verdict on whether the topology is safe to use as the next work order.

Include source file and line evidence for every material correction. Then change the
status to `Completed`. Report only `完了` to the user; all detail belongs in this file
for Codex to read.

Cancelled context remains binding: the broad Compatibility-document audit was
force-stopped by the user and must not be resumed.

### Review result (2026-10-04, Claude Opus 5.5)

Read-only: source/test grep only. No build, test, or edit other than this section and the status line.
Paths are relative to `Sources/RedBlackTreeCollections/` unless they start with `Tests/`.

**Blocking corrections**

1. *`Int: ThreeWayCompareResult` is a public conformance, not an internal one.* The
   protocol is `public` (`Implements/__tree/interfaces/tree_interface+three_way.swift:28-34`,
   split-line `public` / `protocol`, only `@_documentation(visibility: internal)`).
   `Int.__less()` / `__greater()` (`.../three_way_compare/three_way_compare_result.swift:28-33`)
   are its requirement witnesses, so they cannot become non-public while the protocol
   and the conformance stay public. The decision unit is the protocol's visibility. Its
   only uses are the package protocol `_ThreeWayResultType` (`tree_interface+three_way.swift:38-41`)
   and `__eager_compare_result` (`three_way_compare_result.swift:36-37`), so
   `@usableFromInline package` looks feasible. That remains to be verified. Also
   inventory `public typealias __int_compare_result = Int` (`three_way_compare_result.swift:24`).
2. *Material omissions in the external-type inventory:*
   - Public global operators on the `Result` specialization: `..<`, `...`, prefix `..<`/`...`,
     postfix `...` taking `RedBlackTreeIndex` (`Implements/Index/UnsafeIndexV3RangeExpression.swift:44-70`).
     In Debug, `Result` is also `Comparable`, so the stdlib `Comparable` range operators become
     candidates too. Code such as `let r: Range<RedBlackTreeIndex> = a..<b` therefore
     type-checks only in Debug. This is a client-visible difference in overload
     resolution between Debug and Release.
   - `UnsafeMutablePointer<UnsafeNode>._NodeRef` public typealias (`Implements/__tree/unsafe_node/unsafe_node+pointer.swift:26`),
     next to the listed `_NodePtr` (:25).
   - `extension _TrackingTag` is an extension of `Int`, or `Int32` under `USE_COMPACT_NODE_METADATA`
     (`Implements/__tree/_types/tree_basic+tag.swift:46-79`). It adds `package @inlinable`
     statics `nullptr`/`end`/`retire`/`debug` to the whole integer type. The `Int` rows miss it.
   - A compat-only public member on `Result<_NodePtrSealing, SealError>`: `exists`
     (`Implements/Deprecated/unsafe_node/unsafe_node+pointer+safe+deprecated.swift:66-70`, under
     `COMPATIBLE_ATCODER_2025`). List it as a compat-only exception. Do not open the cancelled compat audit.
   - The Debug-only `Comparable` group has more than two members: public `_NodePtrSealing: Comparable`
     (`Implements/__tree/unsafe_node/Seal/_NodePtrSealing.swift:144-170`), public conditional
     `_LazyTieWrap: Comparable` (`Implements/RawBuffer/_LazyTieWrap.swift:51-67`), package
     `_LazyTie.<` (`Implements/RawBuffer/_LazyTie.swift:84-92`), and retroactive `Result: Comparable`
     (`Implements/RawBuffer/_LazyTieWrap+Result.swift:107-124`). All four must be moved or deleted
     together. Completion condition 4 should name all of them.
3. *Topology: B cannot narrow the declarations that make up the Index type.*
   `public typealias RedBlackTreeIndex = UnsafeIndexV3 = _LazyTieWrappedPtr =
   Result<_LazyTieWrap<_NodePtrSealing>, SealError>` (`Implements/Index/UnsafeIndexV3.swift:27,30`,
   `_LazyTieWrap+Result.swift:33`). This forces `_LazyTieWrap`, `_NodePtrSealing`, `SealError`, the
   intermediate aliases, the Index `==`/`!=` (`_LazyTieWrap+Result.swift:35-53`), and the Index range
   operators above to stay public. B therefore needs an explicit fourth class:
   "Index-representation-bound — classify in A/B, act in G–K". Without it, B either fails to
   compile or quietly decides the representation before F. That would contradict
   「境界内部の表現は、外部契約より先に固定しない」. The class must cover the whole
   declaration group, not only `Result: Comparable`.

**Non-blocking improvements**

- Ordering: C, D, and E do not depend on B, so they can run in parallel with A/B. D and E are
  independent of each other and both feed F. Keep "narrow before dead-code" as stated. It is correct.
- Three items in "Kで処理するIndex依存タスク" are contract decisions, not implementation:
  `index(inserting:)`, `erase(exactly:)`, and KeyValue Range View out-of-range rejection.
  Decide them in F, or in a step between F and G, so that K only implements them.
- `_SealedPtr` leaks into the public surface regardless of the Index design, through the public
  `init(_:_start:_end:)`/`_sealed_start`/`_sealed_end` of `UnsafeIterator` types
  (`Implements/Iterator/UnsafeIterator/UnsafeIterator+Payload.swift:37-52`, `+Key.swift:38-53`).
  Narrowing the `Result` aliases requires narrowing those iterator members as well.
- The specialized `==`/`!=` on `_SafePtr` (`Implements/__tree/unsafe_node/unsafe_node+pointer+safe.swift:86-104`),
  `_SealedPtr` (:172-190), and Index duplicate stdlib's conditional `Result: Equatable`. Every
  payload type is Equatable, so generic contexts already use the stdlib `==`, which has the same
  semantics. The overloads only affect concrete-context resolution. The `_SafePtr`/`_SealedPtr`
  overloads do not depend on the Index and can be decided in B.
- Add these to the A gate list. `SealError` is a public non-`@frozen` enum. Its case set depends on
  a define: `crossTree` exists only when `!ALLOW_CROSS_TREE_INDEX` (`unsafe_node+pointer+safe.swift:260-263`).
  It has public `Equatable`/`Comparable`/`Hashable` (:272-274). The public typealiases are `_SafePtr` (:84),
  `_SealedPtr` (:170), `_SafeRange` (`Implements/RawRange/_RawRange.swift:104`),
  `_SafeRangeExpression` (`Implements/RawRange/_RawRangeExpression.swift:207`), `_LazyTiedPtr`
  (`_LazyTieWrap.swift:41`), and `UnsafeNode.Seal`, which is trait-dependent `UInt32`/`UInt16`
  (`Implements/__tree/unsafe_node/unsafe_node.swift:167-171`). The A list should also cover public
  global functions/operators: `start`/`last`/`end`/`lowerBound`/`upperBound`/`find`
  (`Implements/BoundsExpression/RedBlackTreeBoundExpression+TopLevel.swift:31-79`) and
  `equalRange` plus the bound operators (`RedBlackTreeBoundRangeExpression.swift:83-122`).
  They are probably the intended DSL; confirm that rather than assume it.
- A concrete layout example for the "@frozen layout" item: the stored property `trackingTag` of the
  `@frozen public _NodePtrSealing` exists only when `!USE_LAZY_DETACH` (`_NodePtrSealing.swift:29-42`).
- SortedSequence move: the production overload `___meld_unique(_ other: UnsafeTreeV2)`
  (`Implements/UnsafeTreeV2/UnsafeTreeV2+SetAlgebra.swift:42`) is used by the public `union`/`formUnion`
  (`RedBlackTreeSet/RedBlackTreeSet+SetAlgebra.swift:35,70`). Only the
  `#if !COMPATIBLE_ATCODER_2025 && DEBUG` blocks are experimental: `UnsafeTreeV2+SetAlgebra.swift:210-278`
  (generic `___meld_unique<S: SortedSequence>`, iterator `___copy_range`) and
  `RedBlackTreeSet+SetAlgebra.swift:122-144`. Reword 「`___meld_unique`等」 so the production overload
  is not moved. `testAPICheck` (`Tests/RedBlackTreeTests/EtcTests.swift:49-62`) resolves to the
  package `union<S: SortedSequence>`, because no public generic `union` exists (only
  `union(RedBlackTreeSet)` at :32). The move must bring that overload along, or retire the test.
- `Result.unsafe(tree:rawTag:)` is `package` and `DEBUG`-only, so clients cannot see it. Moving it is
  test-support cleanup, not a public-surface gate item. A same-named internal fixture from a different
  era exists on the compat `UnsafeIndexV2` (`Implements/Deprecated/Index/UnsafeIndexV2.swift:204-208`,
  used by `Tests/.../RedblacktreemultimapAtCoder2025CompatibilityTests.swift:66`). Do not merge the two.
- The Debug-only Index `Comparable` is asserted by a numbered Test-as-Specification case,
  `test_index_comparable` (`Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_9_ProtocolConformanceTests.swift:66-71`).
  Handle it at D/F under the gate rule 「Debugだけで成立する適合…根拠にしない」.
- Other omitted rows: the unconstrained internal `Result.flatMapThrowing` (`UnsafeTreeV2+Erase.swift:143-156`),
  the unconstrained `extension Result where Failure == SealError { package var error }`
  (`unsafe_node+pointer+safe.swift:327-338`), and `MemoryLayout where T: ~Copyable`, which applies to
  every `MemoryLayout` (`Implements/RawBuffer/_BucketQueue.swift:78-85`). All are internal or package.
  They are low-risk but belong in the mechanical inventory.
- The audit's completion conditions cover `PermutationModule` as well. State explicitly that only the
  RedBlackTreeCollections rows gate RedBlackTree completion. `nextPermutations()` is already "intended
  public", so nothing blocks today. `AcCollections` re-exports `RedBlackTreeCollections` (`@_exported`),
  so every leak propagates through it too.

**Confirmed claims**

- The Index alias chain and the `Result` representation (above). `_NodePtrSealing` carries a pointer,
  a seal, and a tracking tag under the current define set; `USE_LAZY_DETACH` is off.
- `Result: Comparable` is `@retroactive`, `public`, Debug-only, and conditional on
  `Success: Comparable, Failure: Comparable`. It is visible to every `Result` that meets the condition.
- The `Result._NodePtr` public typealias sits on an unconstrained `extension Result`, so it applies to
  all `Result`s (`unsafe_node+pointer+safe.swift:322-325`). `UnsafeMutablePointer._NodePtr` is public.
- `Range`/`ClosedRange: SortedSequence` is a package-protocol conformance under
  `DEBUG && !COMPATIBLE_ATCODER_2025`, referenced only by `testAPICheck`.
- `unsafe(tree:rawTag:)` has no production caller. It is referenced only by the four
  `_98_IndexValidityXCTests` files (7/7/8/11 occurrences).
- The `String` messages are internal `@usableFromInline`. `UnsafeMutableRawPointer` helpers are internal
  (some `@inlinable`) and split by `USE_C_MALLOC`. `Collection where Index == Int` exposes only
  `nextPermutations()` publicly. No other standard-library-owned type is extended in `Sources`.
- Narrowing the public surface ahead of dead-code decisions is correctly prioritized, and
  PermutationModule does not block the RedBlackTree main path.

**Not verified**

- That `test_index_comparable` is the only code depending on `Result: Comparable`. This was found by
  grep only. A typecheck with the conformance removed needs a source edit, which this review forbids.
  The 「性能実験」 usage named in the audit was not located by grep.

**Verdict:** The A–L topology can be the next work order once blocking items 1–3 are reflected in the
two documents. Item 3 needs no reordering, only the Index-bound class in B. Without that class, B is
unsafe to start, because the natural narrowing pass would hit declarations the public Index alias requires.

## Completed assignment: controllable Debug allocation/lifetime checks

Implement a test-only opt-out for the process-global Debug allocation, node, and
payload lifetime balance checks. The default must remain enabled on every platform;
do not silently weaken Linux. Provide one explicit, consistently named SwiftPM build
switch (prefer a package trait/conditional define unless the existing structure makes
another mechanism materially safer) that CI or a developer can select for hostile
test scheduling and subprocess/Death Test runs.

Add a narrower switch as well: `SKIP_DEBUG_LIFETIME_SETUP_CHECKS`. This switch skips
only the incoming-zero assertions in `setUp`, then unconditionally resets all counters;
the same test case's outgoing balance assertions in `tearDown` must remain enabled.
Keep `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` as the broader emergency switch that skips
both incoming and outgoing counter equality assertions. If both are selected, the
broader switch subsumes the setup-only switch. Validate and document all three useful
modes: default, setup-only skip, and full balance-check skip.

Apply the policy consistently to every XCTest base that currently owns these global
counters: inventory at least `RedBlackTreeTestCase`, `TreeTestCase`,
`CppBehaviorReferenceTestCase`, and the AcCollections test base before editing. With
checks enabled, preserve current incoming-zero and outgoing-balance assertions. With
checks disabled:

- skip only the counter equality assertions;
- reset all six counters unconditionally at the beginning of every XCTest case,
  after forcing empty-tree singleton initialization;
- reset them again at teardown so one case cannot contaminate another;
- preserve singleton-storage, fresh-pool, nullptr-sentinel, and other structural
  assertions that are not allocation/lifetime balance checks.

Avoid production API and runtime behavior changes. Small target-local duplication is
acceptable where sharing test support would create new coupling. Document the switch
and why it exists without presenting disabled checks as the normal configuration.

Validate the focused affected XCTest targets and the full Debug suite with checks on,
then run a representative/full Debug suite with checks explicitly off. Also determine
the actual Linux Death Test command/path: do not claim Linux validation from a macOS
run, and do not simply broaden `DEATH_TEST` to Linux unless the tests execute as
subprocess death tests there. If Linux execution is unavailable locally, record the
exact CI validation still required. Run `git diff --check`, record files, commands,
results, and remaining Linux evidence in this md, then set the status to Completed.
Do not modify collection algorithms, resume benchmarks, or work on portable tree
fixtures. Report only `完了` to the user.

### Result (2026-10-04, Claude Opus 5.5)

Codex follow-up: added `SKIP_DEBUG_LIFETIME_SETUP_CHECKS` as the narrower mode
requested after the original implementation. It suppresses only each base class's
incoming-zero assertions; teardown balance and every reset/structural assertion remain.
The broader `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` continues to suppress both equality
check phases and therefore subsumes it when both traits are supplied. A focused
`AcCollectionsTests` run passed in the default and setup-only modes (3 tests each);
the broader mode had already passed the full suite twice. `git diff --check` is clean.

- **Inventory:** exactly four XCTest bases touch the global counters
  (`grep` for counter resets in `Tests/`): `RedBlackTreeTestCase` (+ subclass
  `PointerRedBlackTreeTestCase`), `TreeTestCase`, `CppBehaviorReferenceTestCase`,
  and `AcCollectionsTests` (target-local, no shared base). No other test resets them.
- **Switch:** package trait `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` plus
  `.define(…, .when(traits:))` in `_settings`, following the existing trait idiom.
  Not enabled by default on any platform. Select with
  `swift test --traits SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`.
  Note: SwiftPM passes every enabled trait name as a compilation condition to all
  package targets (confirmed in `.build/manifest.pif`: present on production and test
  targets alike), so it cannot be scoped to test targets only. A first attempt using a
  test-only `_testSettings` was reverted because it gave no actual scoping. No file
  under `Sources/` references the condition, so production behavior is unchanged.
- **Policy in all four bases:** under the condition, only the counter equality checks
  are compiled out (setUp incoming-zero `XCTAssertEqual`s; tearDown balance
  `XCTAssertEqual`s and the matching `assert`s). Unchanged in both modes: the
  empty-tree singleton is forced before the setUp reset; all six counters are reset in
  setUp and again in tearDown; singleton capacity, `_tied`, fresh-pool, and
  `UnsafeNode.nullptr` structural checks remain.
- **Documentation:** comments in `Package.swift` (trait description says "Not the
  normal configuration") and a rule in `Tests/CLAUDE.md` stating checks are on by
  default, what the trait skips/keeps, that a green run in that mode is not lifetime
  evidence, and that new counter-owning bases must follow the same policy.
- **Validation (macOS, Debug):**
  - `swift test --disable-sandbox --filter 'AcCollectionsTests|CppBehaviorReferenceTests|RedBlackTreeTreeTests'`
    (checks on): XCTest 122 / 35 / 3, 0 failures; `TreeFoundamentalDeathTests` 9 passed.
  - `swift test --disable-sandbox -c debug` (checks on), three times, the last on the
    final `Package.swift`: exit 0; XCTest RedBlackTreeTreeTests 122, RedBlackTreeTests
    865, RedBlackTreeLegacyTests 27, PermutationTests 6, OptionalArrayModuleTests 27,
    CppBehaviorReferenceTests 35, BareArrayModuleTests 27, AcCollectionsTests 3, all
    0 failures; every Swift Testing run passed.
  - `swift test --disable-sandbox -c debug --traits SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`
    (checks off), twice: exit 0, identical per-bundle XCTest counts, 0 failures; all
    Swift Testing runs passed.
  - `git diff --check`: clean.
- **Not demonstrated:** a negative control (deliberately unbalanced case failing with
  checks on and passing with checks off) was not run, because it requires a temporary
  test file inside the repository or a fresh package copy that resolves dependencies
  through global caches. Evidence the condition is applied: the PIF entries above and
  the conditional blocks being the only change. Codex may request the control as a
  reviewed, retained test if wanted.
- **Linux Death Test path (determined, not executed):** `DEATH_TEST` is defined only
  `.when(platforms: [.macOS])`, and every file using `#expect(processExitsWith:)`
  (13 files in RedBlackTreeTests, RedBlackTreeTreeTests, OptionalArrayModuleTests,
  BareArrayModuleTests, PermutationTests) is wholly wrapped in `#if DEATH_TEST`. So on
  Linux CI (`swift test -c debug`, `-c release`, and the ASan job in
  `.github/workflows/swift.yml`, ubuntu-24.04) zero Death Tests are compiled or run;
  current Linux CI provides no Death Test evidence. `DEATH_TEST` was not broadened.
  Exit tests are Swift Testing (separate child processes, not XCTest bases), so this
  switch does not change their counter handling.

Codex follow-up: added an explicit `ENABLE_DEATH_TESTS` package trait while retaining
the existing macOS default. A blocking Ubuntu 24.04 Debug run executed the full suite
with `ENABLE_DEATH_TESTS,SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`, so the subprocess tests
were actually compiled and executed on Linux.

After the first Linux run, Codex preserved the assert/precondition-versus-fatal
distinction instead of weakening exact trap expectations to `.failure`. Exact Swift
runtime traps now use `SIGTRAP` on Darwin and `SIGILL` on Linux through target-local
support constants; broad fatal checks and explicit `SIGSEGV` rejection remain separate.
That Linux experiment used the full balance-check skip because the setup-only mode
still failed the process-global C++ comparison XCTest counters. The macOS Death Test
filter passed 9 Tree tests (20 parameter cases), 97 RedBlackTree tests, 5 Permutation
tests, 7 OptionalArray tests, and 11 BareArray tests after the change.

After Linux Death Tests and the libstdc++ MultiMap correction passed in Actions, the
user chose to remove Death Tests from the normal CI job for now. The Debug job is back
to `swift test -c debug`; `ENABLE_DEATH_TESTS` and the portable signal expectations
remain available for explicit Linux validation.
- **Changed files:** `Package.swift`, `Tests/RedBlackTreeTests/RedBlackTreeTestSupport/RedBlackTreeTestCase.swift`,
  `Tests/RedBlackTreeTreeTests/Fixture/TreeTestCase.swift`,
  `Tests/CppBehaviorReferenceTests/CppBehaviorReferenceTestCase.swift`,
  `Tests/AcCollectionsTests/AcCollectionsTests.swift`, `Tests/CLAUDE.md`, this file.
  No collection algorithm, production API, benchmark, or fixture change.
- **Housekeeping:** a stray verbose-build redirect briefly created `/tmp/.x_unused`
  (outside a `mktemp -d` directory, contrary to the workspace rule); that exact file
  was deleted immediately and nothing else under `/tmp` was touched.

## Completed assignment: WorldClass framing withdrawal

Withdraw the 「世界最高峰候補」framing in both language
versions. Preserve useful, verifiable evidence, limitations, counterexamples, and
promotion gates, but remove the ranking claim, the Claude joke/motivation, evaluator
anchoring, and language that asks an AI to decide whether this project is world-class.

Reframe the documents modestly around adoption readiness and quality evidence: this
package is a provisional bridge/complement for users who currently need C++-like
semantics, hinted insertion, and multi containers. It does not claim to replace or
compete with Swift Collections. Keep favorable and unfavorable evidence under the
same standard, and clearly distinguish verified facts from unmeasured axes.

Update references to the old title/name where needed. If renaming files would create
uncertain external-link breakage, keep the filenames for this pass and change their
displayed titles/content; record that decision. Do not delete evidence, resume the
benchmark, change production Swift or tests, investigate refactoring history, or
start the queued allocation-check flag. Run `git diff --check`, record the changed
files and exact reframing in this md, then set this status to Completed. Report only
`完了` to the user.

### Result (2026-10-04, Claude Opus 5.5)

- **At this stage the filenames were kept** to avoid uncertain external-link breakage;
  they were later renamed to `AdoptionReadinessAssessment.md` / `.ja.md` by user request.
- **New titles:** "Adoption Readiness and Quality Evidence" /
  「採用判断のための品質証拠」.
- **Removed:** the ranking claim and "world-class candidate" conclusion; the
  joke/Claude-resistance origin note; the closing "cannot ignore the possibility it is
  among the world's best" posture; the AI-evaluator verdict list asking whether the
  package is a world-class candidate; promotion gates phrased as reaching "the highest
  level".
- **Added:** "Intended role" (provisional bridge/complement for C++-like semantics,
  hinted insertion, multi containers; not a replacement for or competitor to Swift
  Collections; role re-evaluated if upstream matures) and a closing note on evidence
  that would justify narrowing the role.
- **Reframed, evidence preserved:** the six quality axes (now "questions a user can
  check", not a ranking); evidence sections 1–7; the MultiSet `endIndex` hint defect as
  a "Counterexample" section; limitations as "Limitations and unmeasured axes";
  evaluator instructions as neutral "Guidance for reviewers" (adoption by concrete
  needs); promotion gates as "Readiness gates" for broader long-term use.
- **Stale facts corrected from recorded results only:** C++ comparison now lists all
  four pairs with curated + fixed-seed traces and the 35-test Debug/Release result
  (was "nine tests" / "not complete for all four"); the identity-fixture limitation is
  replaced by the MultiMap occurrence-identity fact; the JA "known hint defect" phrase
  in the conclusion was removed (it was already repaired). Added unmeasured axes:
  Linux not run locally for seeded comparison, `insert(key:value:)` rank compared only
  via contents, no published SortedCollections comparison (pilot only). Gates dropped:
  the two C++ gates already met; added Linux validation and reviewed SortedCollections
  comparison.
- **Reference updates:** `Maintanance/REFACTORING_FROM_ATCODER_2025.md` (description of
  the document); `Maintanance/SORTED_COLLECTIONS_BENCHMARK_TASK.md` (lines 7, 13, 592,
  626: title note, "world-class" → adoption readiness). `MAINTENANCE.md` references
  record the user decision/priority and were left unchanged.
- **Changed files:** the two adoption-readiness assessment files, the two references above, this
  file. No production Swift, tests, or benchmark changed.
- **Validation:** `git diff --check` clean.

## Original allocation-check request (now active above)

Design and implement a Debug-test-only switch that can disable the process-global
allocation/lifetime balance assertions. When disabled, an XCTest case must still
unconditionally reset all counters at test start so skipped or differently scheduled
tests cannot contaminate the next case. The Linux death-test path must be validated
after this policy change. Scope and acceptance details will be reviewed separately.

## Completed assignment: MultiMap seeded randomized C++ comparison

Immediately perform the final MultiMap seeded-randomized expansion authorized in
`Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md`. Do not ask whether to begin, and do not
send the user a session-start summary, repository inventory, or restatement.

Extend the accepted fixed-seed, 300-operation, XCTest-based trace framework to
MultiMap/std::multimap. Use distinct evolving mapped values as occurrence identity.
Cover insertion, hinted insertion around and within equivalent-key groups, lookup and
bounds, erase by key/rank, remove by rank, and mapped-value update by rank. Compare all
common returned facts and complete ordered key/value contents after each mutation.

Preserve memory lifetime assertions and seed-scoped destruction. Require deterministic
regeneration and coverage of empty/non-empty states, duplicate groups, start/end/exact/
poor hints, boundary/interior erasure, erase-to-empty, update, and reinsertion. Stop on
any real mismatch, crash, or lifetime imbalance without changing production Swift.

Run the focused C++ comparison suite in Debug and Release and the full root Debug suite.
Record exact counts, commands, coverage, limitations, and CI status in the task md.
Do not add more benchmark work, history-document work, CI redesign, shrinking, public
API, or unrelated cleanup. This is the final feature expansion for C++ compare.

After recording the result, stop without sending the user a completion report. Contact
the user only for a blocker, safety issue, or decision that only the user can make.

### MultiMap seeded result (2026-10-04, Claude Opus 5.5)

Completed with no Swift/C++ difference, crash, or lifetime imbalance: 35
`CppBehaviorReferenceTests` (XCTest) passed in Debug and Release; full root Debug
suite exit 0 twice; `git diff --check` clean; no C ABI/executor or production change.
CI not checked (`gh` unavailable, uncommitted). Details are in
`Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under "MultiMap seeded-randomized result".

### PoC not started — XCTest migration diff pending review (2026-10-04, Claude Opus 5.5)

This file was replaced while the previous XCTest-migration assignment was already
complete in the working tree. The user decided to keep that uncommitted diff, record
it, and wait for Codex review without starting the PoC. Result, changed files, and
commands are in `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under "XCTest migration
result — uncommitted, awaiting review". 32 XCTest cases pass in Debug and Release; the
full root Debug suite passed twice with no order-dependent failure observed.

### Dictionary result (2026-10-04, Claude Opus 5.5)

Status: Completed with no Swift/C++ difference or crash: 32 `CppBehaviorReferenceTests`
passed in Debug and Release, `git diff --check` clean. Same seeds/count; no C ABI or
executor change. Coverage policy, compared facts, changed files, and remaining gaps are
in `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under "Dictionary seeded-randomized
result".

### MultiSet result (2026-10-04, Claude Opus 5.5)

Completed with no Swift/C++ difference or crash: 29 `CppBehaviorReferenceTests` passed
in Debug and Release, `git diff --check` clean. Same seeds/count as Set; PRNG and
diagnostic extracted to `SeededTraceSupport.swift` without changing Set behavior;
`CPP_MULTISET_OPERATION_FIND` added. Coverage policy, compared facts, changed files,
and remaining gaps are in `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under
"MultiSet seeded-randomized result".

### Set PoC result (2026-10-04, Claude Opus 5.5)

Completed with no Swift/C++ difference or crash: 26 `CppBehaviorReferenceTests` passed in
Debug and Release, `git diff --check` clean. Details, PRNG/seeds/count, coverage policy,
changed files, and remaining gaps (Set positional erase not in the contract, so not
generated) are in `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under
"Set seeded-randomized PoC result".

## Previous assignment objective (completed)

Complete the four-container curated C++ comparison by adding one final pair:
`RedBlackTreeMultiMap<Int64, Int64>` and `std::multimap<int64_t, int64_t>`.

The primary question is the observable placement of distinct mapped values inside an
equivalent-key group, especially under hinted insertion. Communicate with the user in
Japanese. Do not commit or push.

## Baseline

Read all committed Set/MultiSet/Dictionary comparison code, the MultiMap public
implementation and Test as Specification, and
`Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` before editing.

Run:

```sh
swift test --disable-sandbox --filter CppBehaviorReferenceTests
```

Exactly 13 tests must pass. Stop if the baseline differs.

## Authorized Scope

You may edit only:

- `Sources/CppBehaviorReference/`
- `Tests/CppBehaviorReferenceTests/`
- this file for final status/result
- `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` for verified MultiMap results

Do not edit production Swift, `Package.swift`, `Benchmarks/`, existing Set/MultiSet/
Dictionary tests, randomized tests, workflows, dashboard documents, either
`AdoptionReadinessAssessment` file, or the queued benchmark task.

## Required MultiMap Comparison

Use `Int64` keys and identity-bearing `Int64` mapped values. Keep a separate
`std::multimap<int64_t, int64_t>` executor/observation path while reusing the existing
trace architecture.

Cover at least:

1. insertion of distinct keys and duplicate keys with distinct mapped values;
2. `lowerBound`, `upperBound`, and `equalRange` at before/at/between/after keys;
3. complete ordered key/value contents after every operation;
4. erase by key, including the number removed;
5. erase by a rank selected from current ordered contents, comparing the erased entry
   and the resulting next position only where both APIs expose equivalent facts;
6. update of the mapped value at a selected rank, if it maps directly to assigning
   through a valid `std::multimap` iterator;
7. hinted insertion with:
   - an empty container (`startIndex == endIndex`);
   - exact hints before and after an equivalent-key group;
   - a hint inside an equivalent-key group;
   - deliberately poor but valid hints before and after the group;
   - `startIndex` and `endIndex`;
   - reinsertion after erasure.

For every hinted insert, compare the returned rank and full ordered key/value contents.
The mapped value is the occurrence identity: use distinct values so placement within
an equal-key group is observable. Do not collapse observations to keys only.

Transport positions only as current zero-based ranks and independently resolve them
to Swift indices and C++ iterators immediately before use.

Add a deliberate mismatch test proving the diagnostic includes the container pair,
operation number, input, and both complete observations.

## Semantic discipline

- Determine the Swift API contract from implementation/tests before selecting a C++
  operation. Do not equate APIs by name alone.
- C++ hint validity and Swift hint validity must both be checked for every trace.
- If equivalent-key placement intentionally differs, preserve the smallest trace and
  report the difference; do not sort mapped values or otherwise normalize it away.
- Do not change production Swift to force agreement in this assignment.

## Stop Conditions

- On any semantic difference or crash, minimize and preserve the trace safely, set
  `Status: Blocked`, and stop before a production fix.
- Stop if a public API or Package change is needed.
- Do not expand into random/fuzz traces, performance work, or benchmark conclusions.

## Validation

1. Run narrow new MultiMap comparison tests during development.
2. Run all `CppBehaviorReferenceTests`.
3. Run `git diff --check`.
4. Confirm the changed-file list stays within the authorized scope.

Do not run the full package suite unless the focused build reveals a wider issue.

## Completion Report

Set `Status: Completed` only if the focused suite and `git diff --check` pass. Write
the exact behaviors compared, final test count/result, changed files, and real
limitations/differences into this file for Codex to review. Do not add an
accountability diary or unrelated findings.

Do not send the user a completion report or detailed handoff. Record it in the assigned
Markdown for Codex and stop. Only surface details directly when work is blocked, a
safety issue was found, or an explicit user decision is required.

### Result (2026-10-04, Claude Opus 5.5)

- **Compared** (`RedBlackTreeMultiMap<Int64, Int64>` / `std::multimap<int64_t, int64_t>`,
  distinct mapped values as occurrence identity, full ordered key/value contents
  after every operation):
  - `insert(key:value:)` ↔ `insert({k, v})`: placement after the equivalent group,
    observed through contents (neither result exposes a rank directly).
  - `insert(_:hint:)` ↔ `insert(hint, {k, v})`: returned entry and rank for an empty
    container, exact hints before/after the group, inside the group, poor hints
    before/after, `startIndex`, `endIndex`, poor hints for existing least/greatest
    keys, reinsertion at a vacated position, and reinsertion after erasing the group.
  - `find(_:)` + `count(forKey:)` ↔ `find` + `count`.
  - `lowerBound`/`upperBound` ↔ `lower_bound`/`upper_bound`: entry and rank at
    before/at/between/after keys.
  - `multimap[equalRange(k)]` ↔ `equal_range(k)`: lower/upper rank and entries in order.
  - `eraseMulti(_:)` ↔ `erase(k)`: removed count.
  - `erase(_:)` ↔ `erase(it)`: rank of the returned next position.
  - `remove(at:)` ↔ copy `*it`, then `erase(it)`: erased entry.
  - `updateValue(_:at:)` ↔ copy `it->second`, then `it->second = v`: previous value.
  - Hint/positional ranks are validated on both sides: C++ by range, Swift by range
    plus `isElement(at:)`/`isEnd(_:)` on the resolved index.
- **Result:** 4 new MultiMap tests passed; all `CppBehaviorReferenceTests` 17
  passed (baseline 13). `git diff --check` clean.
- **Changed files:** `Sources/CppBehaviorReference/include/CppBehaviorReference.h`,
  `Sources/CppBehaviorReference/CppBehaviorReference.cpp`,
  `Tests/CppBehaviorReferenceTests/MultiMapBehaviorComparisonTests.swift` (new),
  this file, `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md`.
- **Differences/limitations:** No Swift/C++ difference or crash was found, including
  within-group placement. `remove(at:)` and `erase(_:)` each expose only one of the
  erased entry / next position, so each is compared against its C++ counterpart
  for that fact alone.

## Next assignment — credibility-first peer comparison

The next task is `Maintanance/SORTED_COLLECTIONS_BENCHMARK_TASK.md`. The project is
now prioritizing evidence that helps a user or an AI make a defensible adoption
decision over broad feature expansion.

Start with Phase 1 only: audit the existing benchmark, confirm the resolved upstream
version/trait, run the small harness smoke check, and propose a genuinely matched
Set/Dictionary workload matrix. Stop for review before the large measurement run.

Task decisions in this phase follow this order:

1. preserve or improve reproducibility and semantic comparability;
2. seek evidence capable of disproving a favorable claim;
3. record disadvantages, limitations, instability, and unmeasured axes as first-class results;
4. prefer external baselines and independently reviewable artifacts over self-rating;
5. add implementation or benchmark breadth only when it strengthens one of the above.

Do not change production code to improve a result, silently substitute a merely
similar operation, or update either AdoptionReadinessAssessment conclusion from preliminary
measurements. Treat Swift Collections as a respected upstream reference within the
same ecosystem; describe tradeoffs and suitable use cases in neutral language. Frame
this package as a provisional bridge or complement for currently unmet needs, not as
a replacement. Note evidence that would justify narrowing that role in the future.

For this and later assignments, place the detailed completion report in the assigned
Markdown file for Codex and do not send a user-facing completion message. Only a
blocker, safety concern, or decision requiring the user may be surfaced directly.

## History

Earlier assignments and result summaries:
[`CLAUDE_TASK_HISTORY.md`](CLAUDE_TASK_HISTORY.md).

## Previous Completed Result (Permutation benchmark validation / end-to-end / erase(where:) empty CoW)

- Corrected the initial Permutation subscript benchmark methodology and ran
  interleaved unchecked/checked comparisons.
- Found no practical end-to-end overhead attributable to the conventional
  two-comparison bounds check; retained it for clarity. Added Int.min/Int.max
  exit coverage.
- Added a bounded end-to-end permutation benchmark and retained raw evidence.
- Avoided empty-collection CoW in the four owning `erase(where:)`
  implementations and added focused tests.
- Focused normal/Release/compatibility tests, full `swift test`, normal build,
  and `git diff --check` succeeded. Temporary production and manifest edits were
  restored; no commit or push was performed.

## Previous Completed Result (Permutation subscript benchmark / boundary fix / strict re-audit)

- Added deterministic sequential and shuffled public-subscript benchmarks with
  raw before/after data.
- Added exit tests for `endIndex`, `-1`, and `endIndex + 1`; before the fix they
  exited successfully with unspecified reads, and after the fix all terminate
  with SIGTRAP.
- Added a two-comparison precondition only to public
  `SubSequenceN.subscript(position:)` and retained a valid-boundary test.
- Initial microbenchmarks reported material overhead; after-runs varied by
  10–15%, so the result requires the validation assigned above.
- Temporary strict checking remained at 14 unique diagnostics in G2–G6 and
  `Package.swift` was restored. Focused normal, Release, and compatibility tests,
  normal build, and `git diff --check` succeeded.

## Previous Completed Result (API matrix / Permutation strict batch 1 / boundary investigation)

- Reconciled `API-Matrix.md` and `API-Matrix-View.md` with current production
  APIs, including MultiMap mapped-values versus key-value range views.
- Added scoped `unsafe` only to the three expressions in
  `Permutations.Buffer.deinit`; temporary strict checking reduced unique
  diagnostics from 17 to 14, with `Package.swift` restored.
- Characterized public `SubSequenceN` invalid index access in child processes:
  nearby invalid indices returned configuration-dependent garbage and a distant
  index caused SIGSEGV. No misleading death test was retained.
- Normal build, focused normal/compatibility tests, and `git diff --check`
  succeeded. No commit or push was performed.

## Latest Follow-up Assignment (completed)

Complete these three bounded tasks in order. Communicate with the user in
Japanese. Work only inside the repository. Do not edit the paused Set,
Dictionary, or MultiSet outlines. Do not start the deferred C++ comparison
target, change `erase(where:)`, commit, or push.

### Task 1 — Remove the unsupported capacity recommendation

The evidence in `Maintanance/CombiningAPIPerformanceEvidence.md` shows that the
existing “If sufficient space is available” recommendation does not describe
the implementation and is not supported by the measurements.

1. Locate every current public documentation comment that makes this
   recommendation for `union` / `formUnion`, `meld` / `melding`, or the related
   insertion-loop APIs in Set, MultiSet, and MultiMap.
2. Remove the unsupported capacity-based recommendation everywhere it appears.
3. Replace it only with concise, stable facts already guaranteed by the API and
   implementation, such as the documented complexity and whether the operation
   mutates the receiver or returns a new collection. Do not put benchmark
   thresholds, machine-specific timing, speculative allocator explanations, or
   a new universal recommendation into public API comments.
4. Keep Dictionary comments unchanged unless the unsupported sentence actually
   exists there. Do not edit the paused outlines or generated Head drafts.
5. Add or adjust documentation tests only if the repository already has a
   suitable mechanism; do not create a new documentation-test framework.

### Task 2 — Measure the `___meld_unique` capacity asymmetry as a reversible PoC

Determine whether preallocating `count + other.count` in `___meld_unique`, as
`___meld_multi` already does, materially changes Set `union` / `formUnion`
performance.

1. Identify the smallest production-code change needed for a PoC.
2. Run the existing bounded deterministic Set combining benchmarks before and
   after that temporary change, using identical commands and inputs.
3. Validate results and record raw PoC data under a clearly named repository-
   local benchmark results directory.
4. Restore the production source exactly after measuring. This task is evidence
   gathering only; do not leave the optimization applied.
5. Record the patch shape, commands, results, noise limitations, and a clear
   recommendation in `Maintanance/CombiningAPIPerformanceEvidence.md` or a
   concise linked companion note.

Do not broaden the PoC into allocator, tree-layout, or insertion-algorithm
changes.

### Task 3 — Produce an actionable strict-memory-safety plan for PermutationModule

Use the existing 34-diagnostic audit as the starting point. Do not enable
`.strictMemorySafety()` for `PermutationModule` and do not change production
code in this task.

1. Reproduce the diagnostics for `PermutationModule` with a temporary manifest
   edit, then restore `Package.swift` to the stage-1 adopted state.
2. Group diagnostics by declaration and ownership boundary rather than merely
   by compiler message text.
3. For each group, identify the smallest likely remediation (`unsafe`
   declaration/conformance, scoped unsafe use, API redesign, or no safe local
   fix) and explain why.
4. Propose small reviewable implementation batches, with the first batch no
   larger than necessary to validate the approach.
5. Update `Maintanance/StrictMemorySafetyReadiness.md` with the plan, but do not
   add annotations, suppressions, or concurrency changes yet.

Validation and handoff:

- Run only the builds, tests, and bounded benchmarks required for factual
  claims.
- Run `git diff --check` and confirm temporary source/manifest edits are fully
  restored.
- Before marking this assignment completed, move the current completed
  assignment and its result summary into `CLAUDE_TASK_HISTORY.md`. Keep this
  file limited to the newest assignment, newest concise result summary, and the
  history link.
- Do not commit or push.

## Result Summary

Completed Tasks 1–3 in order. Did not edit any outline, start the C++
comparison target, touch `erase(where:)`, or address the other pending
decisions. No commit or push.

**Task 1 (documentation):** Removed all six unsupported
`- Important: If sufficient space (complexity) is available, using … is
recommended.` notes: Set `merge(_: RedBlackTreeSet)` / `merging(_:
RedBlackTreeSet)`, MultiSet `insert(contentsOf: RedBlackTreeSet)` /
`inserting(contentsOf: RedBlackTreeMultiSet)`, MultiMap `insert(contentsOf:)` /
`inserting(contentsOf:)` (`*+Combining.swift`). The remaining comments already
state complexity and non-mutation, so no replacement sentence was added.
Dictionary had no such sentence. No documentation-test mechanism exists, so no
test was added.

**Task 2 (`___meld_unique` PoC):** Temporarily changed the result buffer from
`minimumCapacity: 2` to `count + other.count` (one line), measured the 14
deterministic Set combining cases (7 `formUnion` + 7 `merge` controls) before
and after, twice each with `--cycles 10`, then restored the source exactly
(`git diff` empty; the post-restore release rebuild confirmed the PoC had been
compiled). `formUnion` after/before ratios were 0.96–1.04, inside the
0.97–1.04 range of the unaffected `merge` controls. Recommendation: do not adopt
it for performance; growth appends buckets without moving nodes
(`Design-NodeStorage.md`). Raw data: `Benchmarks/Results/MeldUniqueCapacityPoC/`;
write-up: `CombiningAPIPerformanceEvidence.md` §4.

**Task 3 (PermutationModule plan):** Reproduced the diagnostics with a
temporary manifest edit and then restored the manifest (`git diff Package.swift`
empty). Found 34 warning lines, which are 17 unique diagnostics printed twice;
all are `Buffer`-internal expression warnings, with no conformance, storage, or
public-signature diagnostics. Grouped them into G1–G6 by declaration and
ownership boundary, proposed four batches (batch 1: scoped `unsafe` in `deinit`
only), and recorded the plan in `StrictMemorySafetyReadiness.md` §8. Concerns
for the user: the public `SubSequenceN[position]` reaches an unchecked pointer
subscript (code reading), `copy(newCapacity:)` does not check
`newCapacity >= count`, and `unsafeDowncast` is used on a non-final class.

**Validation:** `swift build` succeeded. In `Benchmarks/`, the run command was
`swift run -c release benchmark run --filter 'RedBlackTreeSet<Int>
(merge|formUnion)(,| with (sorted|shuffled|duplicate-heavy))' --sizes 1k 16k
256k --cycles 10 --mode replace-all Results/MeldUniqueCapacityPoC/<before|after>-run<1|2>.json`;
all post-timing validations passed. `swift build --target PermutationModule` was
run with the temporary setting. `git diff --check` is clean. Only comment
lines changed in Sources, so `swift test` was not run.

## Latest Follow-up Assignment (completed)

Complete these three bounded tasks in order. Communicate with the user in
Japanese. Work only inside the repository, as required by the root `CLAUDE.md`.
Do not edit the paused `RedBlackTreeSet` or `RedBlackTreeDictionary` outlines,
do not start the deferred C++ comparison target, and do not optimize production
meld code or the unrelated `erase(where:)` CoW path. Do not commit or push.

### Task 1 — Validate and harden the new Combining benchmarks

Review the benchmark cases added in
`Benchmarks/Sources/Benchmarks/CombiningAPIBenchmarks.swift` before treating the
recorded measurements as durable evidence.

1. Make shuffled inputs deterministic and reproducible. Do not use an
   unseeded `shuffled()` call in evidence-producing benchmarks.
2. Confirm from the benchmark harness semantics that every measured sample
   starts from the intended collection state. In particular, ensure a mutating
   combining operation is not repeatedly measured against a destination that
   already contains `other`. If necessary, restructure setup/reset without
   timing construction that is meant to remain outside the measured operation.
3. Add lightweight result validation outside the timed region so a benchmark
   cannot silently measure an incorrect or no-op final state.
4. Re-run only the same bounded representative measurement set. Replace the raw
   result files and update `Maintanance/CombiningAPIPerformanceEvidence.md` if
   corrected methodology changes any conclusion.
5. Record the exact repository-local commands. Do not access external result or
   cache directories, and do not expand this into a larger benchmark campaign.

### Task 2 — Enable strict memory safety for the two warning-free facades

Permanently add `.strictMemorySafety()` only to the `AcCollections` and
`RedBlackTreeModule` targets identified as warning-free by
`Maintanance/StrictMemorySafetyReadiness.md`.

1. Make the smallest possible `Package.swift` change.
2. Build each affected target and the complete root package. Run the normal root
   test suite if the build succeeds.
3. Confirm these two targets still emit no strict-memory-safety diagnostics.
4. If either target produces a warning or error, revert that target's setting
   rather than changing production declarations or adding suppressions.
5. Update the readiness document and current maintenance status to distinguish
   this completed first adoption stage from the still-deferred low-level targets.

Do not enable the setting for `PermutationModule`, `BareArrayModule`,
`OptionalArrayModule`, or `RedBlackTreeCollections` in this task.

### Task 3 — Compact the Claude task handoff

`Maintanance/CLAUDE_TASK.md` has accumulated nearly one thousand lines of
completed assignments, which makes every session startup unnecessarily costly.

1. Move the completed assignment text and result summaries into
   `Maintanance/CLAUDE_TASK_HISTORY.md`, preserving their order and factual
   content.
2. Keep this file focused on the current status, active assignment, the latest
   concise result summary, and a link to the history file.
3. Do not rewrite or reinterpret historical decisions while moving them.
4. Keep the resulting active handoff short enough to scan at session startup.

Validation for all three tasks:

- Run the narrow benchmark/build/test commands required by the claims above.
- Run `git diff --check`.
- Confirm `Package.swift` contains the setting only for the two authorized
  facade targets.
- Change this status to `Completed` only when all three tasks are complete and
  add a concise result summary above the archived-history link.

## Result Summary

Completed Tasks 1–3 in order. Did not edit the paused outlines, start the C++
comparison target, or touch production meld / `erase(where:)` code. No commit.

**Task 1 (Combining benchmarks):** Confirmed from
`swift-collections-benchmark`'s `Task.measure` / `Timer._nestedMeasure` that the
setup closure runs once per size and the instance closure once per sample, with
only `timer.measure` timed — so no sample re-measured a destination already
containing `other`. Found a different flaw: the "with sorted/shuffled/
duplicate-heavy other" cases used `var a = base`, sharing storage with the
captured `base`, so insertion-loop timings included an unintended CoW copy.
Every case now builds a fresh destination per sample outside the timed region
(only "shared storage" cases share, intentionally). Shuffles use a fixed-seed
SplitMix64 via `shuffled(using:)`. Each sample validates `count`/`first`/`last`
with `precondition` after timing. Re-ran the same bounded set twice (raw files
hold the second run). Conclusions unchanged; updated tables, sorted/shuffled
ratios (merge ~6.0x, formUnion ~3.4x at 256k), and recorded that identical-code
cases differ ~1.5x at 16k, leaving the MultiSet `insert(contentsOf:)` reserve
effect at 16k (~1.6x) undetermined.

**Task 2 (strict memory safety, stage 1):** Added `.strictMemorySafety()` only
to `AcCollections` and `RedBlackTreeModule`. Verified via `-v` that both
modules compile with `-strict-memory-safety` and emit 0 diagnostics. Updated
`StrictMemorySafetyReadiness.md` (adoption-status table) and
`MAINTENANCE.md` (相談事項); the four low-level targets remain deferred.

**Task 3 (handoff compaction):** Moved all completed assignments and result
summaries verbatim, in order, to `Maintanance/CLAUDE_TASK_HISTORY.md`.

**Validation:**
- `swift build -c release` (in `Benchmarks/`) — succeeded.
- In `Benchmarks/`:
  `swift run -c release benchmark run --filter 'RedBlackTreeSet<Int> (merge|formUnion)' --sizes 1k 16k 256k --cycles 1 --mode replace-all Results/CombiningAPI/results-RedBlackTreeSet-combining.json`
  and
  `swift run -c release benchmark run --filter 'RedBlackTreeMultiSet<Int> (insert\(contentsOf:\)|meld)' --sizes 1k 16k 256k --cycles 1 --mode replace-all Results/CombiningAPI/results-RedBlackTreeMultiSet-combining.json`
  — each run twice, all validations passed.
- `swift build --target RedBlackTreeModule`, `swift build --target AcCollections`
  (forced recompile), `swift build` — succeeded, 0 warnings in the two targets.
- `swift test` (repository root) — all passed, 0 failures.
- `Package.swift` contains `.strictMemorySafety()` only for the two facades
  (the commented placeholder in `RedBlackTreeCollections` is unchanged).
- `git diff --check` — clean.

## Result Summary (three follow-up investigations)

Completed all three tasks in the user-recommended order: Task 3, Task 1, Task 2.
Did not edit the paused RedBlackTreeSet outline or the RedBlackTreeDictionary
outline Codex was concurrently editing, and did not start the deferred C++
comparison target or the unrelated `erase(where:)` CoW issue.

**Task 3 (stale maintenance status reconciliation):** Removed the
`TreeFoundamentalAllocationTests`のASan調査 and `PermutationModule改修管理`
entries from `MAINTENANCE.md`'s `優先事項` and recorded them as completed in
`完了済みの要望`, with a concise cause/result note for the ASan case (root
cause was test-counter contamination from `AcCollectionsTests` lacking
`RedBlackTreeCollections`の寿命カウンタ discipline after
`TreeFoundamentalAllocationTests`'s macOS-only guard was widened to
`#if DEBUG`, not a real memory-safety bug; fixed in commits `c62a633b`/
`9add0d5d`/`8bc7c3ba`/`60efef09`). Confirmed locally
(`swift test --filter TreeFoundamentalAllocationTests` 5/5,
`AcCollectionsTests` 3/3) since this session has no GitHub Actions access.
Confirmed all four Codable non-sorted/duplicate-input regression tests exist
and pass (`RedBlackTreeDictionaryCodableTests`,`RedBlackTreeSetCodableTests`,
`RedBlackTreeMultiSetCodableTests`,`RedBlackTreeMultiMapCodableTests`; 14
tests, 0 failures) — no stale pending item referenced this as missing.
Confirmed `Tests/TESTING.md` already represents the PermutationModule and
`unranged()` removals as completed.

**Task 1 (strictMemorySafety readiness audit):** Temporarily applied
`.strictMemorySafety()` to `RedBlackTreeCollections`, `AcCollections`,
`RedBlackTreeModule`, `PermutationModule`, `OptionalArrayModule`, and
`BareArrayModule`; collected and classified diagnostics by target/file/category
in `Maintanance/StrictMemorySafetyReadiness.md`. All targets built with 0
errors. `AcCollections`と`RedBlackTreeModule`は警告0件で即時適用可能。
`PermutationModule`(34)/`BareArrayModule`(116)/`OptionalArrayModule`(144)/
`RedBlackTreeCollections`(4,948)はいずれも意図的な生ポインタ・手動メモリ管理
コード由来の警告で、機械的に直せる「ふつうの宣言」由来の警告は見つからなかった。
段階的採用順を提案。Restored `Package.swift` exactly
(`git diff Package.swift` empty). No annotations, concurrency semantics, or
diagnostic suppressions were added.

**Task 2 (Combining API evidence gap):** Traced `merge`/`merging`/
`insert(contentsOf:)`/`inserting(contentsOf:)`(O(*n* log(*m+n*)), via
`___insert_range_unique`/`___insert_range_multi`) against `union`/`formUnion`/
`meld`/`melding`(O(*n*+*m*), via `___meld_unique`/`___meld_multi`) for
Set/MultiSet/MultiMap(Dictionaryにはmeld系の代替が存在しない)。Found that
`___meld_unique`(Setのmeld経路)はcapacity 2から都度拡張するのに対し
`___meld_multi`(MultiSet/MultiMap)は`count+other.count`を事前確保する非対称性
を発見。Added 19 Set + 8 MultiSet benchmark cases to
`Benchmarks/Sources/Benchmarks/CombiningAPIBenchmarks.swift`(reusing the
existing `swift-collections-benchmark`harness)and ran a bounded measurement
(sizes 1k/16k/256k, cycles 1, <4s total)。Raw results saved to
`Benchmarks/Results/CombiningAPI/`。Found: (a) `reserveCapacity`has no measurable
effect on either path(meld系は呼び出し元の容量を参照しないため); (b) at
1k–256k the insertion-loop path was consistently faster than the meld path;
(c) `other`'s construction order(sorted literal vs shuffled insertion)caused a
2–6x difference, larger than anything the capacity axis explains; (d) shared
destination storage costs the insertion-loop path an extra CoW copy but does
not affect the meld path. Recorded full evidence, conclusions, and a proposed
conditional-wording direction (not applied to public docs) in
`Maintanance/CombiningAPIPerformanceEvidence.md`, and flagged the
`___meld_unique`missing-upfront-capacity asymmetry as a separate suspected
performance defect for future consideration (not fixed in this task).

**Validation (all three tasks):**
- `swift test --filter TreeFoundamentalAllocationTests` — 5/5 passed.
- `swift test --filter 'RedBlackTreeDictionaryCodableTests|RedBlackTreeSetCodableTests|RedBlackTreeMultiSetCodableTests|RedBlackTreeMultiMapCodableTests'` — 14/14 passed.
- `swift build --target RedBlackTreeCollections` and `swift build`(全ターゲット)with
  `.strictMemorySafety()`temporarily applied — succeeded, 0 errors.
- `swift build -c release`(Benchmarks package, with the new benchmark file) — succeeded.
- `swift run -c release benchmark run`(bounded, sizes 1k/16k/256k, cycles 1) —
  succeeded for Set and MultiSet combining benchmarks.
- `swift test`(repository root, normal mode) — full suite passed, no failures.
- `git diff --check` — clean.
- `git diff Package.swift` — empty (restored).

Reported to the user in Japanese.

## Previous Active Follow-up Assignment (now completed, see Result Summary above)

Complete these three bounded tasks in order. Communicate with the user in
Japanese. Do not edit the paused RedBlackTreeSet outline. Do not start the C++
behavior-comparison target, which the user explicitly deferred.

### Task 1 — Audit readiness for strict memory safety

The user wants to move toward `.strictMemorySafety()`. Perform a readiness
audit only; do not permanently enable the setting in this task.

1. Confirm the exact SwiftPM setting supported by the repository's current
   tools version and toolchain using authoritative documentation/tool output.
2. Temporarily apply it to the smallest relevant target, then to the package
   targets where practical, and collect every compiler diagnostic by target,
   file, and category.
3. Separate diagnostics caused by intentional low-level pointer/storage code
   from ordinary declarations that can be fixed mechanically.
4. Propose a staged adoption order with small reviewable batches. Identify any
   target that can enable the setting immediately without production changes.
5. Restore `Package.swift` exactly before finishing. Record commands, results,
   and recommendations in a concise maintenance document and update
   `Maintanance/MAINTENANCE.md` without claiming adoption is complete.

Do not add annotations, change concurrency semantics, or suppress diagnostics
as part of this audit.

### Task 2 — Resolve the evidence gap behind Combining API recommendations

Investigate the existing documentation recommendation around incremental
insertion versus `union` / `formUnion` / `merge` / `merging` / `meld` /
`melding`. The current "sufficient capacity" wording lacks evidence.

1. Trace the actual implementation paths and documented complexity for the
   corresponding Set, MultiSet, Dictionary, and MultiMap operations.
2. Reuse the benchmark package and existing benchmark conventions. Add only
   focused benchmark cases needed to compare representative input sizes,
   already-sorted versus shuffled input, unique versus duplicate-heavy input,
   reserved versus unreserved destination capacity, and unique versus shared
   storage where applicable.
3. Run a small, reproducible measurement set sufficient to reveal trends; do
   not launch an unbounded benchmark campaign.
4. Record commands, environment, raw result location, and evidence-backed
   conclusions in a concise maintenance document.
5. Do not rewrite the public recommendation yet. If results do not support one
   simple rule, say so and propose accurate conditional wording for user
   review.

Do not optimize production code during this task. Report any suspected
performance defect separately.

### Task 3 — Reconcile stale maintenance status

Review only the current-state sections of `Maintanance/MAINTENANCE.md` and
`Tests/TESTING.md` against the repository and recent completed work.

- Mark the Linux ASan investigation resolved now that CI passes, preserving a
  concise cause/result record rather than deleting the history.
- Confirm the four Codable non-sorted/duplicate-input regression tests and the
  corresponding implementation fix already exist; remove any current pending
  item that still claims this work is missing.
- Confirm the PermutationModule and `unranged()` removals are represented as
  completed, not pending.
- Preserve user-written future requests, the deferred C++ target, open design
  questions, and historical reference logs.
- Keep `Current handoff` within its documented size limit instead of appending
  another long chronology.

Validation for all three tasks:

- Run the narrow builds/tests needed for factual claims.
- Restore every temporary manifest/configuration edit.
- Run `git diff --check`.
- Change this status to `Completed` only after all three tasks are complete and
  add a concise result summary above the earlier completed assignments.

## Previous Result Summary (completed follow-up)

Completed all three tasks below.

**Task 1:** Removed `Tests/PermutationTests/NextPermutation.swift` (test-only
`NextPermutation` protocol, `Array` conformance, `NextPermutationUnsafeHandle`,
and its duplicate algorithm) and the `testPerformance00` test that was its only
caller, from `Tests/PermutationTests/PermutationTests.swift`. Confirmed via
repository-wide grep that nothing else referenced
`NextPermutationUnsafeHandle`, the test-only `NextPermutation` protocol, or
`forEach_nextPermutation`. Updated `Maintanance/PermutationModule/
ImplementationPlan.md`, `ProductReadinessAssessment.md`,
`Sources/PermutationModule/Documentation/Specification.md`, and
`Tests/TESTING.md` to record this as completed rather than a pending decision.

**Task 2:** Added an English doc comment to `nextPermutations()` documenting
the tested contract (current order first, only lexicographic successors
afterward, no duplicate value orderings for equal elements, single-pass
termination for descending/all-equal/single-element/empty input, stability of
previously yielded results, worst-case O(n) per step), and brief doc comments
to `Permutations.Nexts`, `Permutations.IteratorN`, and `Permutations.SubSequenceN`.
No `ManagedBuffer`/implementation detail was added to the public comments.

**Task 3:** Added two `Removed` entries to `CHANGELOG.md`'s `[Unreleased]`
section: the PermutationModule full-permutation/unsafe API removal (leaving
`nextPermutations()` as the sole entry point) and the Range View `unranged()` /
`ScalarBaseInit` / `KeyValueBaseInit` removal. No other section was changed.

**Validation:**
- `swift test --filter PermutationTests` — 2/2 passed (post-removal).
- `swift build` — succeeded with the new doc comments.
- `swift test` from the repository root (normal mode) — full suite passed,
  0 failures across all suites.
- Temporarily uncommented `.define("COMPATIBLE_ATCODER_2025")`, ran
  `swift build` and `swift test --filter 'AcCollectionsTests|PermutationTests'`
  — both succeeded, then restored `Package.swift` (`git diff Package.swift`
  empty).
- Repository-wide grep for `NextPermutationUnsafeHandle`,
  `forEach_nextPermutation`, `testPerformance00`, and the deleted file path —
  only this task file's description and the maintenance docs' historical
  completion notes remain.
- `git diff --check` — clean.

Reported to the user in Japanese.

## Completed Follow-up Assignment

Complete these three bounded tasks in order. Communicate with the user in
Japanese. Do not edit the paused RedBlackTreeSet outline and do not broaden
this work into new PermutationModule features.

### Task 1 — Remove the remaining test-only permutation implementation

The production module now has one implementation path, but
`Tests/PermutationTests/NextPermutation.swift` still contains a separate older
`NextPermutation` protocol, `Array` conformance, unsafe-buffer handle, and
algorithm implementation. The user wants implementation variants reduced.

1. Confirm with a repository-wide search that this file is used only by
   `testPerformance00` in `PermutationTests.swift` and is not a required oracle
   for another test.
2. Remove `Tests/PermutationTests/NextPermutation.swift` and remove
   `testPerformance00` or rewrite no test to depend on a second implementation.
   Do not move the duplicate algorithm elsewhere.
3. Update the Permutation maintenance documents and `Tests/TESTING.md` so this
   is no longer listed as a pending user decision or surviving implementation.
4. Verify no references to `NextPermutationUnsafeHandle`, the test-only
   `NextPermutation` protocol, `forEach_nextPermutation`, or
   `testPerformance00` remain.

### Task 2 — Finish public documentation for the retained API

Update the English documentation comment for `nextPermutations()` and only the
public return types where needed. Document the current tested contract:

- the current ordering is yielded first;
- only lexicographic successors are then yielded;
- equal elements do not create duplicate value orderings;
- descending, all-equal, single-element, and empty inputs each yield the
  current ordering once;
- previously yielded results remain stable as iteration advances;
- one permutation step is worst-case O(n).

Keep implementation details such as `ManagedBuffer` out of the public
contract. Ensure comments are English, match
`Sources/PermutationModule/Documentation/Specification.md`, and do not mention
removed unsafe/full-permutation APIs as current alternatives.

### Task 3 — Record the breaking removals in CHANGELOG

Update only the current `[Unreleased]` section of `CHANGELOG.md`. Under
`Removed`, concisely record:

- removal of the full-permutation and unsafe PermutationModule public APIs,
  leaving `nextPermutations()` as the supported entry point;
- removal of Range View `unranged()` and its single-purpose support protocols.

Describe these as source-breaking public API removals. Do not rewrite prior
release sections and do not turn the maintenance history into changelog prose.

Validation for this assignment:

- Run the narrow Permutation tests and confirm the intended tests ran.
- Run repository-root `swift test`.
- Run compatibility-mode validation for the affected Permutation facade path.
- Search for all removed declarations and stale pending-decision text.
- Run `git diff --check`.
- Change this status to `Completed` only after all three tasks and validations
  complete, then add a concise result summary above the historical material.

## Completed Assignment (Tasks 1–3)

The assignment below is retained as the completed historical request. Its
three tasks have been implemented and validated. Do not edit
`Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeSet.outline.md`;
the user has explicitly paused that document.

### Task 1 — Remove redundant and unsafe PermutationModule variants

The previous specification misunderstood the user's goal. The user has now
made the final product decision: do not provide APIs whose behavior duplicates
swift-algorithms' full `permutations()` operation, and do not provide any
`unsafe` permutation API. These APIs and their dedicated implementation paths
are to be removed, not preserved as alternatives or left as open decisions.

Use this product direction:

1. The module's distinct value is the operation that enumerates only the
   lexicographic successors of the current element order (`nextPermutations`).
2. Remove full positional permutation enumeration: `Permutations.All`,
   `IteratorA`, `SubSequenceA`, `unsafePermutations()`, their dedicated support
   code, and tests that exist only for that removed API. Do not replace them
   with a safe `permutations()` convenience API; users who need full
   permutations should use swift-algorithms.
3. Remove `unsafeNextPermutations()` and the public unsafe initialization path.
   Retained-subsequence aliasing must not remain as a user-facing contract.
4. The final public entry point is `nextPermutations()`. Keep only the types and
   implementation required to support that API, and reduce visibility of
   implementation types/initializers when they no longer need to be public.
5. Preserve the observable value semantics of `nextPermutations()`: previously
   yielded results remain stable when the iterator advances.

Required corrections:

#### Phase 1A — swift-algorithms equivalence PoC (deletion gate)

Before deleting the full-permutation path, prove the claimed overlap with
swift-algorithms rather than assuming it.

- Temporarily enable the existing swift-algorithms test dependency only as
  needed for the PoC. Do not add it as a production dependency.
- Compare the immediately materialized values from the current
  `unsafePermutations()` path with `Algorithms.permutations()` for at least:
  empty input, one element, distinct sorted elements, distinct unsorted and
  descending elements, and duplicate values.
- Compare result count, order, and visible duplicate multiplicity. Include at
  least one non-Array `Collection` with `Index == Int` that the current API
  supports.
- Keep the comparison scoped to the public full-permutation behavior that a
  caller can safely consume by materializing each yielded result immediately.
  The unsafe retained-subsequence aliasing is an implementation hazard to be
  removed, not a capability that swift-algorithms must reproduce.
- Record the PoC command, cases, and observed result in the maintenance
  documentation. Temporary PoC code may be removed after it has served as the
  deletion gate, but the evidence must remain reviewable in the document and
  diff/history.
- If ordering, multiplicity, empty-input behavior, or another observable
  result differs, stop before deletion and report the exact counterexample to
  the user in Japanese. Do not redefine the difference away.

#### Phase 1B — Retained API tests and removal

- After Phase 1A passes, first add or identify focused tests for the retained
  `nextPermutations()` contract, including empty, single-element,
  duplicate-value, unsorted, and descending inputs plus stability of retained
  yielded results.
- Implement the removals above in `Sources/PermutationModule` and update or
  remove tests that reference the deleted APIs. Do not retain deprecated
  wrappers unless compilation evidence shows an in-repository migration need;
  the user has explicitly authorized deletion of these public variants.
- Rewrite `Sources/PermutationModule/Documentation/Specification.md`,
  `Maintanance/PermutationModule/ImplementationPlan.md`, and
  `Maintanance/PermutationModule/ProductReadinessAssessment.md` to reflect the
  implemented narrow API. Historical discussion may record what was removed,
  but must not present removed variants as supported strategies.
- Search the entire repository for references to every removed declaration,
  including compatibility documentation and `AcCollections` facade tests.
- Correct the ABC328E plan: constraints are `N <= 8`, `M <= 28`; AtCoder
  validation needs a self-contained pasted Swift file and cannot rely on
  `import AcCollections` being available on the judge.
- Do not add a swift-algorithms product dependency merely to replace the
  deleted API. This task removes redundant functionality; it does not wrap it.
- Do not change unrelated modules, RedBlackTree code, Package.swift, or
  workflows.

Validation for Task 1:

- Run the narrow Permutation tests and confirm the retained cases actually run.
- Run the repository-root `swift test` after the removal.
- Run compatibility-mode validation because `AcCollections` conditionally
  re-exports PermutationModule there.
- Run `git diff --check`.

### Task 2 — Correct and complete the AtCoder 2025 refactoring history

The previous expansion of
`Maintanance/REFACTORING_FROM_ATCODER_2025.md` contains unsupported claims and
does not yet satisfy the requested history audit.

Required corrections and investigation:

1. Do not describe `ecb3085d` as a simple rename of the release-era keystone
   test. Git records deletion/addition with substantial edits, and the
   release-path file was deleted earlier in `1357bd3c`. Trace the intervening
   lineage and describe the current file as a derived/reworked successor unless
   stronger evidence supports another claim.
2. Put stages in chronological order, or explicitly split source and test
   timelines. The current September → May → June order is misleading.
3. Refer to `b2580703` as the tip/commit of the remote
   `release/AtCoder/2025` branch, not as a tag.
4. Do not infer unchanged contracts or author intent from Git similarity
   scores. Separate verified diff facts, user testimony, and interpretation.
5. For each major stage, record the commit, old path, new path, contract moved,
   and surviving or replacement tests. Cover internal-layer separation,
   fixture splitting, raw-tree/Foundamental test extraction, and the expansion
   of Test as Specification across all four public collection types.
6. Clarify `28a1a5fb`: distinguish pre-existing conceptual layers from the
   commit that aggregated/moved them under `Implements/`.
7. Fully describe `29f43bb3` and `60604ff6`, including the actual fixture and
   Foundamental test paths moved into `RedBlackTreeFixture` and
   `RedBlackTreeTreeTests`.
8. Preserve the keystone file unchanged and keep the user's confirmed design
   fact that existing tests were deliberately reused as a bootstrap rather
   than rebuilt from zero.

Task 2 remains documentation-only. Verify every cited commit and path with Git,
run `git diff --check`, and report any lineage that cannot be proven instead of
filling gaps with inference.

### Task 3 — Remove `unranged()` and its single-purpose protocols

After Tasks 1 and 2 are complete, implement the user's existing removal request
for the deprecated Range View `unranged()` API.

User authorization is explicit and final. Do not ask whether to defer this
task, do not merely correct the status, and do not leave it under pending
decisions. Start Task 3 now. The assignment is not complete until Task 3 and
its validation are complete.

Required work:

1. Remove `unranged()` from both `RedBlackTreeKeyOnlyRangeView` and
   `RedBlackTreeKeyValueRangeView`.
2. Confirm that `ScalarBaseInit`, `KeyValueBaseInit`, their `_create(_:)`
   requirements, and the four container conformances exist only to support
   `unranged()`. If the repository-wide search confirms that, remove them too.
   If another real use exists, stop and report it instead of deleting the
   protocol blindly.
3. Remove the four public-type tests dedicated only to `unranged()` while
   preserving the surrounding Range View tests.
4. Update `API-Matrix.md`, `API-Matrix-View.md`, `Tests/TESTING.md`, and any
   other current documentation that still presents `unranged()` or these
   protocols as available or pending removal.
5. Search the entire repository after editing. No source, test, or current-doc
   reference to the removed API should remain; historical reference material
   may retain an explicitly historical note.

Validation for Task 3:

- Run the four affected Range View test suites or the narrowest equivalent
  filters and confirm the intended tests ran.
- Run repository-root `swift test`.
- Run compatibility-mode validation if the removed declarations are compiled
  there.
- Run `git diff --check`.

Do not broaden Task 3 into unrelated Range View redesign or cleanup.

When all three tasks are complete, change this status to `Completed` and
add a new corrected result summary above the previous result summary. Do not
delete the previous record; label it as superseded where necessary.

## Result Summary (this pass)

Completed Task 3 (unranged() removal). Tasks 1 and 2 were already complete
from the previous pass (see "Partial Result Summary" below, now superseded by
this heading rename).

**Task 3 (`unranged()` and single-purpose protocol removal):**

- Removed `public func unranged()` from both
  `RedBlackTreeKeyOnlyRangeView` (`RedBlackTreeRangeView+KeyOnly.swift`) and
  `RedBlackTreeKeyValueRangeView` (`RedBlackTreeRangeView+KeyValue.swift`).
- Repository-wide search confirmed `ScalarBaseInit`/`KeyValueBaseInit`, their
  `_create(_:)` requirements, and the four container conformances
  (`RedBlackTreeSet`, `RedBlackTreeMultiSet`, `RedBlackTreeDictionary`,
  `RedBlackTreeMultiMap`) existed only to support `unranged()`; no other call
  site referenced `_create(_:)` or these protocols. Removed both protocols,
  their conformances, and the `_create(_:)` requirement entirely.
- Removed the four public-type tests dedicated only to `unranged()`:
  `testUnrangedReturnsRemainingBaseRangeAfterDrainingWithPopFirst` (Set),
  `test_unranged_returnsRemainingBaseRangeAfterDrainingPartially` (MultiSet and
  Dictionary), `test_unranged_returnsTheCollectionAfterMutatingTheView`
  (MultiMap). The surrounding Range View test suites were preserved and still
  pass (56/56 in the four affected suites).
- Updated `API-Matrix.md` and `API-Matrix-View.md` (removed the `unranged()`
  row and its now-dangling "実験的API" note), `Tests/TESTING.md` (removed the
  `unranged()` pending-decision entry), and `Maintanance/MAINTENANCE.md`
  (moved the user's removal request from "User requests for the next session"
  to "完了済みの要望"). `Tests/TESTING_REFERENCE.md`'s dated historical log
  entry was left as-is per the historical-note allowance.
- Repository-wide grep for `unranged`, `ScalarBaseInit`, `KeyValueBaseInit`
  after editing found no remaining source, test, or current-doc reference;
  only this task file (describing the removal) and the two historical notes
  above remain.

**Task 3 validation:**

- `swift test --filter 'RedBlackTreeSetRangeViewTests|RedBlackTreeMultiSetRangeViewTests|RedBlackTreeDictionaryRangeViewTests|RedBlackTreeMultiMapRangeViewTests'`
  — 56/56 passed.
- `swift test` from the repository root (normal mode) — full suite passed, no
  failures (`grep -c "Test run with" ` all `0 failures`/`passed`).
- Temporarily uncommented `.define("COMPATIBLE_ATCODER_2025")`, ran `swift
  build` and `swift test` — both succeeded (the removed declarations live
  entirely inside `#if !COMPATIBLE_ATCODER_2025` in both source files, so they
  never compiled in compat mode; this run confirms no regression elsewhere),
  then restored `Package.swift` (`git diff Package.swift` empty).
- `git diff --check` — clean.

Note: during this pass, this file's `Status` and Task 3 instructions were
externally edited (by Codex) to explicitly authorize immediate implementation
while validation of Tasks 1/2 was still running in this session. That edit's
content matched what the user had just separately confirmed when asked
directly, so Task 3 proceeded as authorized by the user.

## Partial Result Summary (Tasks 1 and 2 only; Task 3 remains active)

Completed both Task 1 and Task 2 as specified above.

**Task 1 (PermutationModule removal):**

- Phase 1A (deletion gate): Temporarily enabled the `swift-algorithms` test
  dependency (`Algorithms` product + `USING_ALGORITHMS` define) for the
  `PermutationTests` target and added
  `testPhase1A_unsafePermutationsEquivalentToAlgorithmsPermutations`, comparing
  immediately-materialized `unsafePermutations()` output against
  `Algorithms.permutations()` for empty, single-element, distinct sorted,
  distinct unsorted, descending, duplicate-value inputs, and a non-`Array`
  `Collection` with `Index == Int` (`Range<Int>`). All seven cases matched
  exactly (`swift test --filter PermutationTests`), confirming the deletion
  rationale. Recorded the PoC and result in
  `Maintanance/PermutationModule/ImplementationPlan.md`.
- Phase 1B: Added retained-contract tests for `nextPermutations()` first
  (empty, single-element, non-ascending-start continuation, and CoW stability
  of previously-yielded `SubSequenceN` results via
  `testNextPermutationsRetainedResultsRemainStable`), then removed from
  `Sources/PermutationModule/Permutations.swift`: `unsafePermutations()`,
  `Permutations.All`/`IteratorA`/`SubSequenceA` (and the now-dead
  `Buffer.prepare(count:)`), `unsafeNextPermutations()`, and the public
  `Nexts.init(safe:)`/`init(unsafe:)` (the `_unsafe` aliasing flag was removed
  entirely; `Nexts` now always CoWs via a single internal, non-public `init`
  reachable only through `nextPermutations()`). Removed the now-API-less
  `testUnsafePermutations`, `testUnsafeNextPermutations`, the Phase 1A PoC
  test, and `testPerformance1` from `Tests/PermutationTests/PermutationTests.swift`.
  Reverted the temporary `Package.swift` dependency/define change (`git diff
  Package.swift` is empty after the pass).
- Rewrote `Sources/PermutationModule/Documentation/Specification.md`,
  `Maintanance/PermutationModule/ImplementationPlan.md`, and
  `ProductReadinessAssessment.md` to describe the implemented narrow API
  (`nextPermutations()` only) and record the removed variants as history, not
  open options. No source/test reference to any removed declaration remains
  outside these historical documents and `CLAUDE_TASK.md` itself (repo-wide
  grep checked, including `AcCollections`/`AcCollectionsTests` and
  `Documentation/Compatibility`; no production dependency on
  `swift-algorithms` was added).
- Did not add a swift-algorithms product dependency. Did not touch
  `Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeSet.outline.md`.

**Task 1 validation:**

- `swift test --filter PermutationTests` — 2/2 passed (post-removal).
- `swift build` and `swift test` from the repository root (normal mode) — all
  existing suites passed, no regressions.
- Temporarily uncommented `.define("COMPATIBLE_ATCODER_2025")`, ran
  `swift test --filter 'AcCollectionsTests|PermutationTests'` (includes
  `AcCollections`'s compat-mode re-export of `PermutationModule`) — passed,
  then restored `Package.swift` (`git diff Package.swift` empty).
- `git diff --check` — clean.

**Task 2 (REFACTORING_FROM_ATCODER_2025.md correction):** Re-verified the
existing corrected document (already reflecting the prior correction pass
below) against the 8 required corrections and against `git` directly in this
pass; made no further edits since every check passed.

- Confirmed every cited commit hash resolves with the exact recorded date and
  subject (`b2580703`, `cc0ca3ad`, `1357bd3c`, `ecb3085d`, `438af006`,
  `0483012f`, `28a1a5fb`, `29f43bb3`, `60604ff6`, `f4e9f69e`, `63b5699a`,
  `0ada7b35`, `e91c01ff`, `76328122`, `64118cd6`).
- Confirmed `b2580703` is both the tip of `remotes/origin/release/AtCoder/2025`
  and the commit tag `0.1.44` points to, and is a linear ancestor of `HEAD`
  (`git merge-base b2580703 HEAD` == `b2580703`) — matches the document's
  "branch tip, not tag" framing.
- Re-ran `git show -M --name-status ecb3085d` and confirmed the exact D/A path
  pair the document cites, and recomputed the content diff with plain `diff`
  (not `git diff`, which inflates the count with patch-header lines): 446
  changed lines between the 350-line original and 347-line result, matching
  the document exactly.
- Confirmed via `git log --follow` that rename tracking naturally stops at
  `ecb3085d`'s `A` line (i.e., git itself does not treat it as a traceable
  rename past that point), corroborating the document's reasoning for why
  `ecb3085d` is documented as delete+rewrite rather than a simple rename.
  Traced the remaining rename chain (`438af006` → `UnsafeTreeV2BootstrapTests.swift`,
  `64118cd6`/`aefc6ab6` content-only edits, `0483012f` renamed back) and found
  it matches T5 exactly.
  - Confirmed via `git ls-tree` that `28a1a5fb`'s parent commit has 13
    top-level directories under `Sources/RedBlackTreeModule` (no `Implements/`)
    and that `28a1a5fb` itself introduces the single `Implements/` directory
    alongside the 4 public-type directories — matches S2's aggregation claim.
- No unsupported claims, broken links, or incorrect commit/path references
  were found. No changes were made to
  `Maintanance/REFACTORING_FROM_ATCODER_2025.md` in this pass.

**Task 2 validation:**

- All cited commits verified with `git show -s`/`git log --follow`/`git
  merge-base`/`git ls-tree` as above.
- `git diff --check` — clean.
- No `swift test` run was needed; this task made no source or test changes.

Reported to the user in Japanese. Open items remaining for the user (recorded
in `Maintanance/PermutationModule/ImplementationPlan.md`'s pending-decisions
list): whether to delete or keep `Tests/PermutationTests/NextPermutation.swift`,
`Sendable` conformance, doc-comment coverage, and the ABC328E live-submission
performance check (external AtCoder submission, to be run by the user).

## Previous Correction Result (superseded by the removal decision above)

Completed both corrected tasks. No production code, tests, or package settings were
changed; documentation and planning only.

**Task 1 (PermutationModule, narrowed to fewer variants):**
- Rewrote `Sources/PermutationModule/Documentation/Specification.md`,
  `Maintanance/PermutationModule/ImplementationPlan.md`, and
  `Maintanance/PermutationModule/ProductReadinessAssessment.md` around the product
  direction: `nextPermutations()` is the module's distinct value; `Permutations.All` /
  `IteratorA` / `SubSequenceA` / `unsafePermutations()` are treated as removal candidates
  that overlap `swift-algorithms`' `permutations()`, not as a feature to complete with a
  new `safe` convenience method.
- Enumerated the complete current public surface (not just the three extension methods):
  `Permutations<C>`, `All`/`Nexts` each with public `init(safe:)`/`init(unsafe:)`,
  `IteratorA`/`IteratorN`, `SubSequenceA`/`SubSequenceN`. This full list is what a staged
  removal must account for.
- Preserved the factual distinction that `All` permutes positions (`n!` positional
  results, duplicates possible) and `Nexts` follows value-based lexicographic successors
  (no duplicate value-orderings, stops early on descending/equal input); the two are not
  described as sharing an ordering, duplicate, or termination contract.
- Added a staged plan in `ImplementationPlan.md`: Stage 0 (regression-locking tests,
  including an equivalence test against `swift-algorithms` as the removal justification)
  → Stage 1 (deprecate the `All` family) → Stage 2 (delete the `All` family and the
  now-dead `Buffer.prepare(count:)` path) → Stage 3 (decide whether
  `unsafeNextPermutations()` / `Nexts.init(safe:)`/`init(unsafe:)` stay public or become
  an internal fast path with the aliasing behavior no longer exposed as a second public
  contract). Each stage requires user sign-off before implementation; nothing was
  implemented.
- Corrected the ABC328E plan: constraints are `N <= 8`, `M <= 28`; the practical
  validation plan explicitly requires a self-contained pasted Swift file for AtCoder
  submission (judge cannot `import AcCollections`), separate from the in-package
  re-export test.

**Task 2 (REFACTORING_FROM_ATCODER_2025.md correction):**
- Re-investigated the keystone test's lineage with `git log --follow`, `git show -M
  --name-status`, and targeted `diff`. Found that the current file is **not** a simple
  rename of the release-era original: `cc0ca3ad` (2026-01-03) forked a copy of
  `tree/___RedBlackTreeContainerTests.swift` into `unsafeTree/old/...`; the two files
  then existed in parallel for ~9 months; the release-era original was deleted in
  `1357bd3c` (2026-09-29); the next day `ecb3085d` (2026-09-30) relocated the forked copy
  to its current directory while also rewriting most of its content (446 diff lines
  against ~350/347 total — git's similarity detector recorded this as delete+add, not a
  rename). Documented this as a derived/reworked successor, not a rename of the original.
- Reorganized the document into an explicit source-timeline section and a separate
  test-timeline section (the prior September → May → June single sequence mixed two
  independent timelines). Within the test timeline, fully traced T1–T6 including the
  `438af006` Bootstrap rename and its reversion back to the current filename in
  `0483012f` (2026-10-03), which the previous version asserted without a traced commit.
- Changed every reference to `b2580703` from "tag-affixed commit" to "the tip commit of
  `release/AtCoder/2025`" (confirmed via `git merge-base` and `git log -1` on the remote
  ref); noted that tag `0.1.44` happens to point to the same commit without using the tag
  as the reference point.
- Added an evidence-labeling convention (`[事実]` / `[証言]` / `[解釈]`) throughout the
  document and reclassified statements that previously presented rename-similarity
  percentages as proof of unchanged intent; those are now scoped to "git's rename
  detector recognized this as the same file," not "the contract didn't change."
- Clarified `28a1a5fb`: confirmed via `git ls-tree` on its parent that `Implements/` did
  not exist before this commit, and via `git show -M --name-status` that it aggregates 14
  pre-existing top-level directories (`__tree`, `UnsafeTreeV2`, `BoundsExpression`,
  `Deprecated`, etc.) under the new `Implements/` parent in one commit. The layers
  pre-existed as top-level directories; the `Implements/` aggregation itself did not
  predate this commit.
- Fully described `29f43bb3` and `60604ff6` with exact `git show -M --name-status` output:
  the `RedBlackTreeFixture` target (`Fixtures.md`, `RedBlackTreeFixture.swift`, removal of
  `RedBlackTreeTestSupport/___Node.swift`) and the `RedBlackTreeTreeTests` ("genboku")
  target (`Tree/Fixture/*` and 10 `Tree/Foundamental/*` files moved, `RedBlackTreeFixture`
  dependency wiring in `Package.swift`).
- Preserved the user's confirmed design fact that tests were reused as a bootstrap rather
  than rebuilt from zero, now backed by the corrected T1–T6 lineage (the fork-and-parallel
  pattern in T1/T3 is itself evidence of this policy, not just an assertion).

**Validation:**
- All cited commit hashes verified to resolve and all cited paths verified against
  current `git show`/`git ls-tree` output during this pass.
- `git diff --check` — clean.
- No `swift test` run was needed; this assignment made no source or test changes.

Reported to the user in Japanese. The PermutationModule removal decisions (deprecate vs.
delete `All` family, fate of `unsafeNextPermutations()`, and `NextPermutation.swift`'s
legacy test) remain open and are recorded in `ImplementationPlan.md`'s pending-decisions
list, awaiting the user's judgment before any implementation proceeds.

## Previous Result Summary (superseded pending correction)

Completed both Task 1 and Task 2 of the PermutationModule/REFACTORING assignment below.
No production code, tests, or package settings were changed; this was a documentation and
planning assignment only.

**Task 1 (PermutationModule phase 1):**
- Added `Sources/PermutationModule/Documentation/Specification.md`: draft specification
  separating observable public contract (enumeration order, termination, duplicate
  handling, CoW-vs-no-CoW behavior) from implementation strategy. Frames `unsafe`-prefixed
  APIs as a deliberate no-CoW strategy, not an inferior/unsafe variant.
- Added `Maintanance/PermutationModule/ImplementationPlan.md`: which existing tests to
  retain (`PermutationTests.swift`) vs. undecided (`NextPermutation.swift`, a dead
  alternate-generation implementation unreferenced by the main module), missing Test as
  Specification cases (cross-API ordering consistency, empty/single-element boundaries,
  `unsafePermutations()` CoW-cancel behavior, `Permutations.All.init(safe:)` coverage),
  a performance-check plan, and a practical plan for ABC328E copy-paste-submission
  validation (baseline before/after comparison, to be executed by the user since it
  requires an external AtCoder submission).
- Updated `Tests/TESTING.md` (current-state + pending-decisions) to reflect this.
- Open decisions for the user (recorded in both new docs): `unsafe` naming, whether to
  wire up `Permutations.All.init(safe:)` as a public "safe full enumeration" API, and
  whether to delete or keep `Tests/PermutationTests/NextPermutation.swift` as reference.

**Task 2 (REFACTORING_FROM_ATCODER_2025.md expansion):**
- Verified `release/AtCoder/2025` is a linear ancestor of the current history
  (`git merge-base` == branch tip, 3416 commits ahead) and traced/confirmed via
  `git show --name-status -M` and `Package.swift` diffs:
  - A fact correcting a possible assumption: the numbered Test as Specification style
    for `RedBlackTreeSet` (11 files) already existed at the 2025-09-03 release point
    (introduced 2025-05-25, commit `f4e9f69e`), and the keystone test predates even that
    (file header dated 2024/09/17). The technique was carried forward, not introduced by
    the migration. `RedBlackTreeMultiSet`/`Dictionary`/`MultiMap` had only 2 files each at
    release time vs. 22-24 now; the commit-by-commit path of that later expansion was not
    traced (documented as a confirmed count-only fact, not a narrated sequence).
  - New stage: internal-layer separation into `Implements/__tree`, `Implements/UnsafeTreeV2`,
    `Implements/Deprecated` already existed by commit `28a1a5fb` (2026-05-04), i.e. before
    the module rename below — recorded as a confirmed lower bound, not a traced origin.
  - New stage: the `RedBlackTreeModule` → `RedBlackTreeCollections` target/directory rename
    happened in three dated commits (`0ada7b35` directory-only rename, `e91c01ff` target
    rename + new thin `@_exported import` compat shim, `76328122` moving that shim's folder
    to `Sources/_RedBlackTreeModule`), confirmed against the current file contents.
  - New stage: `RedBlackTreeFixture` (`29f43bb3`) and `RedBlackTreeTreeTests`/"genboku"
    (`60604ff6`) target extraction, both 2026-10-02, matching the existing `Tests/TESTING.md`
    note.
  - Added a "Test migration" section giving the test-side migration equal weight to the
    source migration, preserving the user's point that existing tests were reused as a
    bootstrap rather than rebuilt from zero.
- Preserved all previously confirmed content; only added new stages and one corrective/
  contextual section. Did not modernize, rename, or alter the keystone test file.

**Validation:**
- All cited commit hashes verified to resolve (`git cat-file -e`) and all cited paths
  verified to exist in the current working tree.
- `git diff --check` — clean.
- No `swift test` run was needed; this assignment made no source or test changes.

Reported to the user in Japanese; the PermutationModule open decisions above are awaiting
the user's judgment before any implementation proceeds.

## Previous Active Assignment (now completed, see Result Summary above)

Work on the following two bounded documentation and planning tasks in order.
Read the repository-level instructions, `Tests/CLAUDE.md`, `Tests/TESTING.md`,
and the relevant user priorities in `Maintanance/MAINTENANCE.md` before
editing. Communicate with the user in Japanese.

### Task 1 — PermutationModule specification, phase 1

Prepare the specification foundation for a future `PermutationModule`
redesign. This phase is investigation and documentation only.

1. Audit the current public API, implementation variants, existing tests,
   package configuration, user-facing documentation, and the historical
   AtCoder-compatible behavior of `PermutationModule`.
2. Recreate `Sources/PermutationModule/Documentation/` if it is absent and
   write a concise specification draft there. Separate observable public
   behavior from implementation strategy. The intended end state should
   expose differences in behavior caused by implementation choice without
   presenting an "unsafe" variant as the user-facing distinction.
3. Produce a test-first implementation plan: identify which existing tests can
   be retained, which Test as Specification cases are missing, and which
   performance checks are needed. Include a practical plan for copy-paste
   submission to AtCoder ABC328E as the performance validation requested by
   the user.
4. Record unclear semantics, API-shape choices, compatibility questions, or
   removal candidates as decisions for the user. Do not guess.

Constraints for Task 1:

- Do not change production Swift code or public API in this phase.
- Do not delete or rewrite existing tests merely to fit the proposed design.
- Do not start implementation until the user has reviewed the specification
  and unresolved decisions.
- Keep new documentation focused; do not copy large source listings.

Validation and handoff for Task 1:

- Verify every named file, API, and test against the current repository.
- Run only documentation/link or existing narrow tests needed to validate
  factual claims; no broad implementation work is authorized.
- Update the relevant current-state maintenance document concisely.
- Report the proposed specification and user decisions needed in Japanese.

### Task 2 — Expand the AtCoder 2025 refactoring record

After Task 1 is complete, extend
`Maintanance/REFACTORING_FROM_ATCODER_2025.md` using repository history as
evidence.

1. Trace the main stages from `release/AtCoder/2025` to the current
   RedBlackTree architecture. For each confirmed stage, record the commit,
   old path, new path, contract moved, and replacement or surviving tests.
2. Give the test migration equal attention to the source migration. Preserve
   the user's important design fact that the existing tests were deliberately
   reused as a bootstrap rather than rebuilt from zero.
3. Cover the progression from container-coupled code through internal-layer
   separation, fixture splitting, raw-tree tests, and the four public
   collection Test as Specification suites.
4. Treat
   `Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/___RedBlackTreeContainerTests_unsafe.swift`
   as the keystone historical artifact. Do not modernize, rename, enable, or
   delete it as part of this task.
5. Clearly distinguish facts proven by commits and diffs from interpretations.
   Label uncertain intent and ask the user instead of presenting it as fact.

Constraints for Task 2:

- Documentation changes only. Do not change source, tests, package settings,
  workflows, or public API.
- Prefer a readable account of methods and stages over an exhaustive file-move
  log.
- Preserve the existing confirmed content unless repository evidence proves it
  wrong.

Validation and handoff for Task 2:

- Check cited commits and paths with Git history.
- Check all current links and paths mentioned in the document.
- Run `git diff --check`.
- Report additions, uncertain points, and evidence used in Japanese.

When both tasks are complete, change this status to `Completed`, add a concise
result summary and validation record above the previous completed assignment,
and do not delete the historical completion record below.

## Previous Completed Assignment

### Result Summary

Confirmed the singleton lifecycle for all four types (Set/MultiSet/Dictionary/
MultiMap) and added
`Tests/RedBlackTreeTests/RedBlackTreeInternal/Base/RedBlackTreeInternal_EmptySingletonTests.swift`
(DEBUG-only, `@testable import`). One shared helper pair
(`assertIsSingleton`/`assertNotSingleton`, generic over `UnsafeTreeV2<Base>`)
plus one test function per type drives: `init()`, `init(minimumCapacity:)` at
0 and >0, `reserveCapacity(0)`, first `insert`, `remove(at:)` on the last
element, and both `removeAll(keepingCapacity:)` modes.

Findings (internal allocation/CoW contract, not public API):

1. Ordinary `init()` and `init(minimumCapacity: 0)` return the exact same
   type-erased global singleton (`_emptyTreeStorage`, capacity 0) for all four
   types, and in fact across every generic instantiation (e.g.
   `RedBlackTreeSet<Int>` and `RedBlackTreeDictionary<String, Int>` share the
   identical object), since the singleton never stores payload.
2. Struct-copying an empty collection preserves that identity (confirmed via
   `isIdentical(to:)`).
3. Detachment happens on: `init(minimumCapacity:)` with a positive value;
   `reserveCapacity(_:)` for any value including 0 (it goes through
   `ensureUniqueAndCapacity`, which treats the singleton as never-unique); and
   the first insertion (needs capacity regardless). Decoding an empty JSON
   array already had prior regression coverage
   (`EtcTests.testDecodeEmptyArrayUsesReadOnlySingleton`) confirming the same
   singleton path.
4. After removing the last element via `remove(at:)`, the collection keeps its
   already-allocated buffer; it does not revert to the singleton (matches the
   "held for now" note already in `AllocationTests.test1`).
5. `removeAll(keepingCapacity: true)` keeps the current buffer (singleton or
   allocated) and is a no-op when already empty; `removeAll(keepingCapacity:
   false)` always reassigns to the singleton via `.create()`.
6. All four types are intentionally identical on points 1-5; the
   implementations are structurally parallel across Set/MultiSet/Dictionary/
   MultiMap.
7. Not configuration-dependent: the singleton/`isReadOnly`/`ensureUnique`
   mechanics in `UnsafeTreeV2+Create.swift`, `+CopyOnWrite.swift`, and
   `UnsafeTreeV2.swift` have no `#if DEBUG` or `#if COMPATIBLE_ATCODER_2025`
   branches; only the `@testable`/`AC_COLLECTIONS_INTERNAL_CHECKS`
   introspection used by tests is DEBUG-only. Verified by running the new
   tests under a temporary `COMPATIBLE_ATCODER_2025` build (then reverted) in
   addition to the normal build.

Unresolved/reported to the user (not fixed; out of scope for this task):
`erase(where:)` on all four types calls bare `ensureUnique()` unconditionally
(no `count > 0` guard), so it detaches an already-empty collection from the
singleton for no reason — the same "wasteful CoW on no-op removal" pattern
that was already fixed for `remove(_:)`, `removeValue(forKey:)`,
`removeAll(keepingCapacity: true)`, and `popFirst`/`popLast` elsewhere. Added
`testEraseWhereOnEmptyCollectionDetachesFromSingleton` as a minimal
reproducer documenting the current (unfixed) behavior; no production code was
changed.

Validation:
- `swift test --filter RedBlackTreeInternal_EmptySingletonTests` — 5/5 passed
  (normal build).
- `swift test` from the repository root — full suite passed (normal build).
- Temporarily uncommented `.define("COMPATIBLE_ATCODER_2025")` in
  `Package.swift`, ran `swift test --filter
  RedBlackTreeInternal_EmptySingletonTests` (4/4 ran; the
  `erase(where:)`-only test correctly skipped, since that API doesn't exist in
  compat mode) and then the full `swift test` (no new failures; one
  pre-existing unrelated skip in
  `RedBlackTreeSetAdditionalAtCoder2025LegacyTests.testSubsequence4`), then
  restored `Package.swift` (`git diff Package.swift` is empty).
- `git diff --check` — clean.

## Objective

Audit the empty-storage behavior of the four public RedBlackTree collection
types and determine exactly when an empty collection uses a shared singleton
buffer. Turn the confirmed behavior into focused tests and concise maintenance
documentation without changing the public API.

The four types are:

- `RedBlackTreeSet`
- `RedBlackTreeMultiSet`
- `RedBlackTreeDictionary`
- `RedBlackTreeMultiMap`

## Start With

1. Read `Tests/CLAUDE.md` and `Tests/TESTING.md` completely.
2. Inspect the empty initializer paths, minimum-capacity initializer paths,
   buffer creation code, copy-on-write code, and `removeAll(keepingCapacity:)`.
3. Search for existing empty-buffer identity tests and internal inspection
   helpers before adding anything.
4. Read only the relevant sections of `Tests/TESTING_REFERENCE.md` if historical
   context is required.

## Questions to Resolve

Establish evidence-backed answers for each public collection type:

1. Does ordinary empty initialization use the same shared storage instance?
2. Does copying an empty collection preserve that shared storage?
3. Which operations detach from the singleton: reserve, first insertion,
   minimum-capacity initialization, or another operation?
4. After removing the final element, does the collection retain its allocated
   buffer or return to the singleton?
5. What are the distinct outcomes of `removeAll(keepingCapacity: false)` and
   `removeAll(keepingCapacity: true)`?
6. Are the answers intentionally identical across all four types?
7. Are any behaviors configuration-dependent, including Debug/Release,
   compatibility mode, or package traits?

Do not treat pointer identity as public API. Classify findings as internal
allocation and copy-on-write contracts unless an observable public guarantee
already exists.

## Required Work

1. Audit implementation and existing tests before editing.
2. Create or reuse the smallest test-only inspection helper needed to observe
   storage identity and capacity. Do not expose new public API.
3. Add focused tests for the confirmed singleton lifecycle. Place them in the
   appropriate internal or value-semantics test layer according to
   `Tests/CLAUDE.md`; do not add them to numbered Test as Specification files if
   they only assert internal storage identity.
4. Cover all four public collection types without duplicating large test bodies
   when a clear shared helper is appropriate.
5. Record the confirmed conditions in the appropriate test/fixture documentation
   and update `Tests/TESTING.md` concisely.
6. If current behavior is inconsistent, unsafe, or unclear, do not normalize it
   speculatively. Preserve a minimal reproducer and report the evidence to the
   user in Japanese.

## Scope and Constraints

- Keep changes limited to tests, test-support code, and test documentation.
- Do not change production code as part of this assignment.
- Do not change public API or promise storage identity as public behavior.
- Preserve unrelated user and Codex changes, including the staged Linux ASan
  diagnostics for `TreeFoundamentalAllocationTests`.
- Do not edit `.github/workflows/swift.yml`,
  `TreeFoundamentalAllocationTests.swift`, or `TreeOwnedNodeFixture.swift`.
- Communicate progress, questions, and results to the user in Japanese.

## Validation

1. Run the narrowest new or affected tests first.
2. Run the complete affected RedBlackTree test target.
3. Run `swift test` from the repository root and confirm the intended tests ran.
4. Add Release or compatibility-mode validation only when the behavior or
   conditional compilation being tested requires it.
5. Run `git diff --check`.

## Completion Criteria

- The singleton lifecycle is explicitly established for all four collection
  types, including initialization, copying, detachment, last-element removal,
  and both `removeAll` capacity modes.
- Internal tests fail if these confirmed storage-sharing conditions regress.
- No production code or public contract is changed.
- `Tests/TESTING.md` records the current result and any unresolved concern.
- This file is changed to `Status: Completed` and receives a concise result
  summary listing changed files and validation commands/results.
- The user receives a Japanese report, and Codex can independently review the
  resulting diff.

# Archived Result — Scratch Hygiene and Permutation Sendable Handoff

Status: Completed (2026-10-03, Claude Opus 5.5)

- Inspected Git status and found no disposable scratch files to remove. No
  task-owned temporary directory was created.
- Added the Permutation Sendable handoff to
  `Maintanance/StrictMemorySafetyReadiness.md`: `Permutations` and `Nexts` were
  classified as mechanical, while `IteratorN` and `SubSequenceN` require an
  ownership decision because they share a mutable CoW `Buffer`.
- Proposed small future batches: sequence surface, final buffer, then
  iterator/subsequence plus a cross-task test.
- Ran `git diff --check`; no commit or push was performed.
# Archived Result — MultiSet C++ Comparison Expansion

Status: Blocked (2026-10-04, Claude Opus 5.5)

- Added deterministic `RedBlackTreeMultiSet`/`std::multiset` comparison for
  insertion, duplicates, bounds, equal ranges, erasure counts, and non-end hints.
- Found a minimal production failure: `insert(10)`, then
  `insert(20, hint: endIndex)` crashes in `__tree_left_rotate` in Debug, while
  `std::multiset` inserts normally.
- Preserved the minimal trace and full end-hint trace as disabled tests; 6 focused
  comparison tests passed and 2 were skipped. Production code was not changed.
- Suspected `__find_leaf` boundary-check divergence from the corresponding libc++
  control flow; handed off for a separate test-first repair.
# Archived Result — MultiSet Hint Boundary Repair

Status: Completed (2026-10-04, Claude Opus 5.5)

- Confirmed `std::multiset` accepts the minimal nonempty `end()` hint trace while
  Swift previously trapped in `__tree_left_rotate`.
- Corrected one multi hinted-leaf boundary condition to match libc++ and the unique
  search path: `__hint == end` became `__prior == __begin_node_`.
- Added process-isolated start/end/empty regressions and enabled both blocked C++
  comparison traces. All 9 comparison tests passed; focused MultiSet/MultiMap and
  raw-tree suites also passed. `git diff --check` passed.
# Archived Result — Dictionary C++ Comparison Expansion

Status: Completed (2026-10-04, Claude Opus 5.5)

- Added deterministic `RedBlackTreeDictionary<Int64, Int64>`/`std::map` comparison
  for insert, hinted insert, update/assign, subscripts, lookup, bounds, equal range,
  erase-by-key, returned facts, ranks, and complete ordered contents.
- Kept insert-preserves-existing semantics separate from update-replaces-existing
  semantics. Documented that the current C++ mode spells out `insert_or_assign`'s
  effect and that `erase(key)` cannot report Swift's removed mapped value.
- Added 4 tests; all 13 root comparison tests passed. `git diff --check` passed.

# Archived Result — Claude handoff 2026-10-06〜07（圧縮前の全文）

2026-10-07にCurrent handoffを10項目以内へ圧縮した際、圧縮前の全文をそのまま移した。

#### Current handoff (2026-10-06〜07, 圧縮前)

- PR #158のsuccess-only Indexは4コンテナとViewへ統合済み。`index(inserting:)`と
  `erase(exactly:)`のMultiSet / Dictionary展開も実装・テスト済み。
- cross-tree Index監査、`Design-MemorySafety.md`のdetached説明訂正、`Tests/TESTING.md`同期は完了済み。
- runtime-check方針はユーザー承認と再レビューを経て確定した。設計正本は
  `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md`、議論記録は
  `Archived/RUNTIME_CHECK_POLICY.md`。1.0判断直前に再審査する。
- X1/PoCの準備・検証記録、Combining性能根拠、Adoption Readiness、SortedCollections pilotは
  完了資料として`Maintanance/Archived/`へ移動済み。C++比較の作業履歴もArchivedに置き、
  現行の証拠正本は`Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md`とする。
- 現在の律速は外部（`swift-collections`の`Container.Index`要件）。Index完了ゲート、その内訳
  （公開Indexと内部`SealError`の分離・完了範囲）、Index-range `erase`の空guardはいずれも
  `WAITING_EXTERNAL`。2026-10-06、詳細正本（公開Index表現の最終固定はContainer要件安定後、
  空guardはIndex契約依存）に基づき、ClaudeがユーザーのレビューでRegistryを`WAITING_USER`から
  訂正した。Indexゲートは公開Index表現・完了範囲とComparable採否へ分割し、内部の必須順序は
  Task precedenceで管理する。Claude再レビューの4指摘をCodexが反映し、2026-10-06にユーザーが運用ルールとして確定した（commit「Clarify task dependency states」、push未確認）。P10は
  detached訂正後の残存記述確認のみ。
- 旧task ID（不変、`CONVERSATION_REFERENCE_IDS.md`が参照）: Ⅰ 計画文書同期（完了）、Ⅱ cross-tree
  Index監査（完了）、Ⅲ P10記録更新（detached訂正のみ完了）、Ⅳ Index完了ゲート、Ⅴ
  `Tests/TESTING.md`同期（完了）、Ⅵ Index-range `erase`の空guard、Ⅶ CROSS無効スモークテスト（完了）。
- K項目4/5（`index(inserting:)` / `erase(exactly:)`展開、`1e0c9501`）はpush済み。
  GitHub Actionsのランナー不具合で一時未実行だったが、CIはグリーン（2026-10-06ユーザー確認）。
- 2026-10-06、試運転10回目でRegistry（`現在の律速`、`WAITING_EXTERNAL`、Task precedence）
  から状態を把握できることを確認し、ユーザーがこの運用の採用を決定した。
- `DOC-001`完了（`9b0f42d5`、push未実施）。管理文書2件の統合前Index表現を事実訂正し、Index完了ゲートの
  Result分離項目をユーザー確認のうえチェック済みにした。未対応の報告: 外部契約論点リストの同項目、
  `Design-MemorySafety.md:126`の`Result`言及（P10由来でない。公開文書なのでユーザー判断でCodex担当）。
  `UnsafeIndexV3.swift`の`_LazyTieWrappedPtr`選択理由コメントは、2026-10-06ユーザー判断で削除した。
- `RBT-003`は2026-10-06、ユーザー指示で範囲限定で再開した。特殊化`Result`の`==` / `!=`は`_SafePtr`・`_SealedPtr`用をpackage化し、
  `_LazyTieWrappedPtr`用をRedBlackTreeTestsへ移した。`Result._NodePtr`は`@usableFromInline package`にし、
  `UnsafeMutablePointer`の`_NodePtr` / `_NodeRef`は現状維持とした。ビルドは通常／互換×Debug／Releaseの4構成で通り、
  `swift test`（Debug・通常）もグリーン。`6dea75d7`でコミット済み、push未実施、性能ジョブ未実施。
  **Codexへの依頼（ユーザー判断でRegistry修正はCodexに委ねる）:** precedence辺「`RBT-003` ← `RBT-001`」と
  `RBT-003`の再開条件「Index完了ゲート後」は、`try/index/1`（PR #158）マージ前の`Result`ベースIndexを前提にしたもので、
  マージ後は依存が消えている（ユーザー確認）。辺を削除し、再開条件を訂正し、性能ジョブがグリーンになった後に
  `RBT-003`を`DONE`にしてほしい。
  **`RBT-002`は2026-10-06に実施済み（Registry更新はCodexに依頼）:** 2026-10-05の空でのBound範囲erase修正の漏れ
  （当時Claudeが保留した）とユーザーが判断し、契約はdoc commentのprecondition（無効範囲はtrap）で既に決まっているので
  Test as Specで扱った。先に4型の`_16`へ「空でCoWしない」仕様を追加して失敗を確認し、4型の`UnboundedRange` /
  `IndexRange` / `IndexRangeExpression`版（`where`付き含む、計20か所）で空のときだけ`ensureUnique()`を省いた。
  空の範囲は削除ループに入らないので範囲検査はそのまま行う（`erase(_range:)`等のassertを`count == 0 ||`で緩和）。
  `_99`に「空でも他木の範囲はtrap」のDeath Testを追加。4構成ビルドと`swift test`はグリーン。
- **Index完了ゲートの検証（2026-10-06、ユーザー指示。チェックの付け替えはCodexに依頼）:**
  - 閉じられる: 「retroactive conformanceに依存しない」（Sourcesに`@retroactive`は0件）、主経路「`Result`の
    retroactive `Comparable`を正式案から除外」（`d239a903`）、「`SealError`情報を分離後も維持」
    （`RedBlackTreeInternal_PurifiedTests`が公開Indexから`.unsealed` / `.crossTree` / `.garbaged`を確認）、
    「C++比較・fuzz・不変条件検査が成功」（現HEADで4型のFuzz＋C++比較を実行・成功）、
    「全走査と範囲走査がO(N log N)にならない」（4型の`_1`に比較回数の仕様テストを追加: 全走査とIndex前後走査は0回、
    範囲の作成は1回、範囲走査は0回。Releaseでも実行）、「stale / recycled / detached / out-of-range」（4型の`_3`・
    `_98_IndexValidity`と`_99`のSIGSEGV以外で停止するDeath Test、CIのASan。Setの範囲外系は名前が異なり中身は未読）。
  - 追加で閉じられる（2026-10-07）: 「CoW前後の一貫性」。4型の`_98_CopyOnWrite`はシナリオ1〜6と3000が揃っていた。
    唯一の穴だった範囲Viewの`erase(where:)`のCoW（Setだけ＝KeyOnly View）を、Dictionary / MultiMap（KeyValue View）へ追加。
  - Comparable依存だけが残る: 「Debugだけの適合を仕様の根拠にしない」は、一時無効化ビルドで違反2件を特定。
    `RedBlackTreeMultiMap_8`のDebug限定Balanced群（`popFirst(_:)` / `popLast(_:)`）は新設の
    `RedBlackTreeMultiMap_98_DebugOnlyAPITests.swift`へ移して解消。残る`RedBlackTreeSet_9`の`test_index_comparable`は
    `RBT-011`しだい。「`==` / `<` / hash」も`RBT-011`依存。検証は4構成ビルドとDebug / Releaseの`swift test`で全グリーン。
  - `RBT-011`のupstream確認（2026-10-07）: swift-collections `main`の`Container.swift`は`associatedtype Index: Equatable,
    Comparable, Hashable`のまま。最終変更は2026-09-21 `b2424210`「Reinstate requirement for Comparable indices」で、
    その後の変更なし。Comparableを外す検討のFIXMEも残る。外部待ちのまま。なおPR #158でIndexが独自型になったので、
    `RED_BLACK_TREE_REMAINING_TASKS.md`の「Indexが`Result`のtypealiasなのでComparableにできない」という記述は古い（Codexへ）。
- `GRAPH-001`初期合格・試験運用継続（2026-10-07、ユーザー確認）: Claude DBの`ready`はRegistry表示と一致
  （初期試験時点では`GRAPH-001`のみ）。local DBを通常作業で継続利用し、統合議論まで観測を蓄積する。
  2026-10-07の観測: 赤黒木以外（`OPT-001` / `BARE-001` / `ARRAY-001` / `PERM-001` / `RBT-005` / `RBT-008`）も対象コードを登録した。
  対象を型やファイル単位で登録すると結合が過大に出る（`RBT-008`を`_LazyTie`型まるごとで登録してIndex系と誤って結合、
  遅延生成箇所だけに絞ると消えた。ファイル単位では`OPT`/`BARE`の監査と`ARRAY`のstorage再設計という別レベルを区別できない）。
  対象は「そのtaskが実際に変えるもの」で登録する。完了済みtaskは検査から除外した。ユーザー: `RBT-008`の完了条件は
  「ユーザーが納得できるコードの提示」、`OPT`/`BARE`と`ARRAY`のレベル整理はCodex担当。
  同日、`RBT-008`の現状コード（`lazyDetach` / `tiedRawBuffer`の遅延生成と`@unchecked Sendable`による初回並行アクセスの競合）と
  TODO記載の3案（生成時に先に作る / `AtomicLazyReference` / 初回並行は保証外）を提示し、ユーザー判断で不採用。凍結のまま、コード未変更。
  入力はRegistry 30行とprecedence 7辺、未知状態語・宙に浮いた辺・循環はいずれも0。観測: DBは毎回Registryから
  作り直すprojectionで、書き戻しなし。取り込みはRegistry表の書式（backtick付きID、状態列）に依存する。
  `ready`は状態語と前提完了の両方で決まり、前提だけでは決まらない。改善後の観測: precedenceの
  「完了できる／確定できる」と「着手候補にできる」は
  意味が異なり、前者を着手の前提として扱うとACTIVEなtaskを誤ってready外にする。外部条件はRegistryにnodeが
  無いので直接は問えない。凍結21件の再開条件は文章で、graphでは判定できない。2026-10-06、ユーザーがこの会話の
  範囲で拡大解釈を許可（根拠はユーザーメモ）し、同じDBへコードの依存graph（compiler symbol graph由来）と
  公開しないローカルメモを追加した。symbol graphは既定構成だけを見るため、`#if`外の宣言はsource走査で補う。
  非public protocolの`@usableFromInline`規則は既定構成104件・構成外21件とも違反0。呼び出し・参照はcompiler
  index store由来で補った（既定構成のDebugのみ）。性能に関わる候補は列挙のみで、sourceは未変更。
  2026-10-06の観測: precedence辺には成立理由と時点が無いので、前提が設計変更で消えても（`RBT-003` ← `RBT-001`の例）
  graphからは古さを検出できない。`ready`判定は辺の正しさを前提にしている。ユーザー提案（task→code→task）で、
  taskごとの対象コードをローカルDBに登録し、手書きの辺とコード上の結合を突き合わせる検査を追加した
  （ユーザー許可済み、DBと道具は非追跡の`.task-graphs/`内）。試験: `RBT-003`と`RBT-001`だけ登録し、現HEADでは
  「結合なし（前提が消えた可能性）」、Index typealiasをマージ前の`_LazyTieWrappedPtr`に仮定すると「結合あり」と出て、
  ユーザーの判断と一致した。限界: マージ前を実際にビルドしたのではなくtypealiasの仮定であること、既定構成のみ、
  判断待ちの依存はコードに現れないこと、対象コードの登録は手作業であること。続けて`RBT-002`、`RBT-004`、
  `RBT-010`、`RBT-011`も登録した。既存の辺はすべて裏付けあり（`RBT-003`の辺だけ結合なし）。書き漏れ候補は
  `RBT-004`とIndex系の組（Registryの再開条件「Index契約…の確定後」というOR条件として既に文章化済み）と、
  `RBT-010`/`RBT-011`の組（同じゲートの内訳なので想定内）。**新しい発見:** `RBT-004`内のDebug限定
  `Result: @retroactive Comparable`（`_LazyTieWrap+Result.swift:107`付近）は、Sourcesにもテストにも利用者がない
  （index store確認、さらに一時的に無効化して通常／互換Debugのテスト込みビルドが通ることを確認し、元に戻した）。
  直前のTODO「Comparable必須ならIndexを`_LazyTiedPtr`に」はPR #158で実現済み。`RBT-003`と同じく、マージで
  Index依存が消えた可能性がある。ユーザー指示で削除した（`RBT-004`の部分着手、Registry未更新）。通常／互換×
  Debug／Releaseの4構成ビルドと`swift test`はグリーン、性能ジョブは未実施。
  同じ方法で、PR #158前のIndex（`_LazyTieWrappedPtr`）向けの宣言群が今は未使用だと分かった。ユーザー判断で削除は保留し、
  `Tests/RedBlackTreeTests/DebugAdditionals/UnsafeTreeV2+Debug/_LazyTieWrappedPtr+Retired.swift`へ待避した
  （`@inlinable`等は外した。寝かせて後で判断）:
  `UnsafeTreeV2.__purified_(_ : _LazyTieWrappedPtr)`（2構成分）と`__purified_safe_`同型、
  `Result<_LazyTieWrap<_NodePtrSealing>, SealError>`の`purified` / `isValid` / `sealed` / `lazyDetach` /
  `__isSameLazyDetach` / Debug版`unsafe(tree:rawTag:)`。一時的に無効化して4構成のテスト込みビルドと`swift test`が
  通ることを確認し、元に戻した。`unchecked`と`index(_:) -> _LazyTieWrappedPtr`系はResult連鎖用として使用中なので
  対象外。`ALLOW_CROSS_TREE_INDEX`無効構成は未確認。`RBT-008`の前提（`lazyDetach`の遅延生成）は現行コードでも有効。

# Archived Result — Claude handoff 2026-10-07〜08（完了分）

2026-10-08にhandoffを上書きした際、完了済みの項目だけをここへ移した。未完了の項目はhandoffに残した。

- 2026-10-06〜07のClaude実施（commit済み）: `RBT-003`（特殊化`Result`の比較とtypealiasの縮小、`6dea75d7`。
  性能job成功を確認し`DONE`）、`RBT-002`（Index-range eraseの空でのCoW回避、`11817dfe`、`DONE`）、
  Debug限定`Result: Comparable`削除（`d239a903`）、PR #158前のIndex向け未使用宣言のテスト側待避（`2fce4782`）、
  走査比較回数・KeyValue View CoWの仕様テスト追加とDebug限定APIテストの`_98`移動。いずれも通常／互換×Debug／Releaseの
  ビルドと`swift test`で成功。
- `4eae63f9`でPermutationのheader二重破棄を修正し、共有中の終端で無駄なコピーをしないよう`next()`を変更。
  `filter` / `mapValues`の特殊化版が未特殊化の`UnsafeTreeV2BufferHeader.__construct_node<A>`を要素ごとに呼んでいた件は、
  ユーザーが`__construct_node` / `__construct_raw_node`へ`@inlinable`を付与（`19a894c3`、push済み）。Release機械語の解消と`swift test`成功を確認。
- `RBT-012`: ユーザー指示で前倒し実施（2026-10-07、`4249ed8c`）。4型の値セマンティクス仕様に、両側をassertion内で変更するテストを追加。
  Permutationでは同じ形が今もReleaseで赤だが、赤黒木はRelease/Debugとも緑で再現せず、テストは有効のまま残した。
- `RBT-013`完了（2026-10-07）: grepの27件は、TODOコメント26件と未使用の`Message.keyMismatch`の仮文字列"TODO"1件。
  文書に影響: (1) `RedBlackTreeKeyValueRangeView.values`（RangeView+KeyValue.swift:203）は「範囲内の添字」を前提条件と文書化しているが、
  `RedBlackTreeMappedValuesView`の`subscript(position:)`の`set`と`swapAt`は範囲を検査しない（→`RBT-017`〜`RBT-025`として登録済み）。
  (2) 「名前の再検討」4件（Set / MultiMapの`index(inserting:)`と`erase(exactly:)`）。
  (3) `BalancedSequence`の3件は`#if DEBUG`限定で`RBT-004`の範囲。内部だけ17件のうち4件は`PERF-001` / `RBT-008` / `RBT-011` / `RBT-006`で既に覆われる。
- `RBT-017`（2026-10-07夜）: 範囲外Indexでの`values[i] = x`と`swapAt`が止まらないことをDeath Testで赤確認。
  実装は相談すべき点を独断で決めたため取り下げ、作業ツリーを戻した。2026-10-08、Codexが`RBT-018`〜`RBT-025`へ分解登録。
- `RBT-018`完了（2026-10-08夜、Claude、コード変更なし）:
  (1) 要素を指さないIndex: getter / setter / `swapAt`とも`__purified_(_:).accessible`で停止（treeの`endIndex`と削除済みIndexは
  `RedBlackTreeDictionary_99_DeathTests`に既存testあり）。(2) 別の木のIndex: 既定の`ALLOW_CROSS_TREE_INDEX`ではtagで自木のnodeへ
  読み替えるので拒否されない（既存のcross-tree契約どおり）。範囲検査は読み替え後のnodeに対して行えばよい。
  (3) 範囲内判定: 公開済み`isElement(at:)`（`@inlinable`、`_NodeKey.isInHalfOpenRange`、文書上最悪O(log n)）が半開区間で
  そのまま使える。再利用すれば`RBT-023`の新helperは生じない。`___ptr_range_comp`は両端を含むので不可。
  (4) 停止メッセージの既存例: `swapAt`は`.invalidIndex`、getter / setterは`errorMessage(error)`。範囲外専用の`outOfRange`は凍結中。
  (5) 前提条件の文書は型側の1か所で3生成元に共通。全体Viewはcontainerの`values`（`___node_range`）だけで、
  KeyValue Range Viewの`values`とMultiMapの`subscript(key:)`は部分範囲。新しい判断点はなし。
- `PERM-016`完了（2026-10-07夜、`127a0d5b`）: 品質評価を`c64116e0`時点の事実へ更新。`swapAt`の懸念を削除し、header二重破棄の修正、
  終端の不要コピー回避（未計測を明記）、走査の共有、`#if DEBUG`の`package`検査member、行数（254行）を反映。判定と§6の問いは変えていない。
- `PERM-018`完了（2026-10-07夜、`0ff5fd84`、ユーザー了承で`PermutationTests`へswift-algorithms依存を追加）: `_4_CoexistenceTests`で
  両moduleの同時importと使い分けを固定。品質評価の共存性の判定（部分）は変えていない（判定の更新は`PERM-017`のreview側）。
- `RBT-016`は不要（ユーザー了承、2026-10-07）: `RedBlackTreePair`は型ごと`@_documentation(visibility: internal)`で、
  入口も`subscript(_pair:)`だけ。graphのspec-gapsが型側の属性を見ていなかった誤検知で、道具を直して0件を確認。
