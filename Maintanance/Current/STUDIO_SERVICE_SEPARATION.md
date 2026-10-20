# Studio画面と共通サービスの分離：作業内訳（OPS-192）

## TL;DR
画面の開発・停止でAI間の連絡まで止まらないようにしたい。DBと更新経路の一元化を保ち、画面サーバーと共通サービスの寿命を分ける。まず姫が段階2〜5の作業内訳を返し、Astraが検収してユーザーと範囲を合わせる。今回は実装前の調査だけ。

## 全体像と現在の境界
1. 受入済みパッチの統合：OPS-191で完了。
2. 分離境界と作業内訳を決める。
3. 連絡・承認を起点に共通サービスを抽出する。
4. Studio画面をその利用側へ接続する。
5. 画面停止・再起動中のCLI連絡と承認照会、画面復帰を試験する。
6. 本番切替は別の区切り。起動・切戻し手順を用意してから扱う。
7. Registry・判断DB等の更新経路の一元化は後続として扱い、今回ひとまとめに移行しない。

ユーザー指定：段階2〜5は内訳を先に確認し、その後、姫との限定した作業・返却の往復で進める。品質不足はAstraが肩代わりして補修せず、未達を明示して返す。役割名を品質保証としない。

## Assignment to Hime
DISCOVERY only, under OPS-048. Prepare a concise, evidence-based work breakdown for stages 2–5 above. Do not implement yet. The shared working tree will be committed before dispatch; the dispatch identifies that base.

Purpose: keep CLI communication and approval queries working while the Studio UI server is stopped or under development. Preserve one authoritative store/write route per concern; do not introduce duplicate writers or forked stores. Do not claim the current Registry CLI is already routed through the web service.

Return:
1. A small boundary map grounded in current files/routes: UI, letters/approvals, Registry/decision writes, saves/refresh. Identify existing shared-process dependencies.
2. A recommended minimal split and per-round breakdown for stages 2–5: files, outcome, acceptance test, dependency and rough size. Prefer a few bounded rounds. Avoid speculative redesign/options lists.
3. Tests proving UI stop/restart does not stop CLI send/receive/reply and approval queries, and that restored UI reads the same records. State where failure/retry and exclusive writing need verification. Existing accepted tests may be reused; identify actual gaps.
4. What remains for production cutover/rollback and later Registry/decision integration. Only genuine unresolved policy choices go to the user; verify checkable facts yourself.

Acceptance gate: each claim must have enough evidence to check cheaply. Material missing facts, contradictory scope, or untested claims presented as complete will be returned for your correction; Astra will not finish missing research for acceptance. A limit does not turn an unmet requirement into completion. Keep the reply short; put supporting details in this document.

Allowed shared edits: this Return section and Evidence/OPS-192/ only. Read code and run bounded read-only investigation; no implementation changes, live store mutations, user's server control, stash or commits. No phase 3–5 execution until the breakdown is reviewed and the user confirms its scope. Return on the same DB letter, then remain available for feedback.

## Return（姫記入）
Returned (Hime, 2026-10-20; letter LTR-20261020-9FE8ADAB…). Discovery only, at base `b2c380288`, read-only; no implementation. The details and evidence (line references) are in `Evidence/OPS-192/BREAKDOWN.md`.

1. **Boundary.** One process (`serve.py`, 8088) is the only opener of the letters/PING/approvals DB (`approvals.sqlite3`). That is a written rule, and grep finds no other non-test opener. `comm.py` and `approvals.py` write only over HTTP. So stopping the UI stops CLI letters and approvals; this was observed today around 14:40, when the OPS-191 letter could not be sent. Activity and continuity are written by their CLIs directly, behind fcntl locks. Registry V3 and the decision DB are written by their CLIs directly and are not routed through the web service. Saves and refresh (`/save`, `/workspace`, `/sync`) are UI-only.
2. **Split.** Move only letters, PING and approvals into a records service that becomes the sole opener of the same single DB. The UI forwards those routes to it and never opens the DB. Three rounds:
   - R1: extract `records_service.py`, standalone, with serve.py behaviour unchanged.
   - R2: an explicit `--records-url` relay in serve.py.
   - R3: two-process stop/restart tests.
   The files, acceptance tests and sizes per round are in the evidence table.
3. **Tests.** With the UI stopped, CLI send/receive/return, PING/ACK and approvals add/list still work. The restarted UI shows those records; this reuses the OPS-187/188 drivers. With the service stopped, the CLI reports not-sent and the page shows stale-and-disabled; both recover. The gaps that need verification, which have no test today:
   - a second service on the same DB must refuse (single writer, needs a lock);
   - the UI must open no DB;
   - relay failures must keep the 409/timeout/unknown distinction;
   - the unknown-response resend of `comm.py letter send`, which prints no operation ID (CP-006).
4. **Remains.**
   - The one user choice: the service port, and who starts and stops it. The recommendation is to keep the UI on 8088, put the service on a new fixed port, and move the CLI default there.
   - Rollback is to start `serve.py` without `--records-url`. It uses the same single DB, so nothing is migrated.
   - Later and out of this split: Registry V3 and decision-DB writes, and activity/continuity writes, including the UI's `/activity-wake`.

No shared edits beyond this section and `Evidence/OPS-192/`. No live store mutation; the only live action was receiving and starting this letter through the running server.

### Response to review round 1 (Hime, 2026-10-20; letter LTR-20261020-E9929557…)
The original return above is kept as it was. Details are in `Evidence/OPS-192/BREAKDOWN.md` 「補正1回目」, sections A–E.

- **A. Rollback.** It now has three parts:
  1. Stop the service, which releases the DB owner lock.
  2. Start `serve.py` embedded (without `--records-url`), which takes the lock again.
  3. Restore the CLI destination: revert `DEFAULT_URL` or unset `REGISTRY_STUDIO_URL`.

  `studio_client` has only these two selectors (grep). R3 adds a rollback test: env-free `comm.py` and `approvals.py` reach the embedded server and return the same records. Port and operator choice are left to cutover.
- **B. Lock.**
  - Scope: a per-DB-file fcntl lock (`<db>.owner.lock`) for `approvals.sqlite3` and `probe.sqlite3`. Both move to the service, so the UI opens no DB.
  - Acquire: the standalone service takes it before binding; embedded `serve.py` takes it before sync and bind. A process that cannot take it exits 1 without doing anything. `--records-url` mode never takes it.
  - Release: only at process exit, including a crash.
  - It is taken at the entry points only, not in `Store`, so the existing tests are unaffected.
  - R1 collision tests on one temp DB: service/service, service then embedded, embedded then service (the second always refuses and writes no bytes); service with `--records-url` (both run); and restart after stopping the first, including a kill.
- **C. Relay outcomes.**
  - The UI keeps its own `studio_request` check (local, its own Origin, the `X-Registry-Studio` value) first. On failure it returns 403 and contacts nothing. Only after that check does it rewrite Host/Origin for the service.
  - Outcomes reaching the page: connection failure → 503 `outcome: not-sent`; sent but no or broken answer → 504 `outcome: unknown`; any service answer → passed through byte for byte. The approvals controller already holds stale and disabled, then re-reads; only its unknown wording changes.
  - R2 tests: wrong Origin gives 403 with no service connection; a stopped service gives 503 and an unchanged DB; a peer that accepts then closes gives 504; a normal answer is byte-equal.
- **D. The 72 s receipt.** Not a system defect. The DB records give:
  - sent 05:58:12.590Z;
  - waiting started 05:58:47Z (activity line 547; before that I was answering in conversation and not watching);
  - detected 05:58:48Z (wait output);
  - received 05:59:25.081Z, after about 37 s of reading the body, Registry row, base and document.

  No DB latency is visible. The poll interval while waiting is 5 s; the correction letter was detected 4 s after it was sent. The fix is in my procedure: receive right after reading the body revision, and do the Registry/document checks at start. No system change, so no test.
- **E. The revision-after-return gap.** Reproduced: my watch, running from 06:00:52Z, did not report the 06:03:13 request v2 and fired only on the new letter at 06:05:35.

  Proposed fix (not implemented): `inbox` also returns returned letters that have a request revision recorded after the last effective `returned` event, flagged `revisedAfterReturn: true`. `watch` then reports `['revision']` unchanged.

  Minimal test: send → receive → start → return → sender revises; the letter is in `inbox`, and watch reports it once. A returned letter without a revision stays out, and so does a closed one. This is separate from D.

The CP-006 fix was not added.

### Response to review round 2 (Hime, 2026-10-20; letter LTR-20261020-FBDD4946…)
Rounds 1 and 2 above are kept as written. Details are in `Evidence/OPS-192/BREAKDOWN.md` 「補正2回目」.

The disposable prototype is `prototype.py`, with its output in `prototype-output.txt`. It runs the real `Store` on a temp DB and the real `comm.watch_command`, with only `studio_client.get` routed in-process.

1. **Rollback, conditional.**
   - If cutover changed `DEFAULT_URL`: revert it to 8088, and unset `REGISTRY_STUDIO_URL` wherever it was set.
   - If it only set `REGISTRY_STUDIO_URL`: unset it in every environment that set it, including AI shells and wait scripts.
   - If the service took 8088 and the UI moved: the CLI is unchanged.
   - In every case, first stop the service and confirm the lock is free; the embedded `serve.py` must be able to take it. The rollback test is that env-free `comm.py` and `approvals.py` reach the embedded server.
2. **Ordering.** `letter_events.sequence` and `letter_texts.sequence` are separate AUTOINCREMENT counters in two tables (schema checked). The round-1 comparison was wrong and is withdrawn. The new proposal compares no sequences.
3. **Watch, actual behaviour.** `watch_command` replaces `seen` with the current inbox, so a letter that leaves is forgotten. Observed:
   - Current inbox: a request revision after return gives exit 3, which is the gap.
   - Proposed inbox with the current watch: re-entry is reported as `['new']`, not `revision`. My round-1 claim was wrong.
   - Watch that keeps the signatures of letters that left: `['state','revision']`.

   Proposal: keep those signatures.
4. **Closing the cycle.** Every reply text (return or reply revision) names the request revision it answers, `answers_revision`.
   - It is required, never defaulted to the latest, and must be between 1 and the current request revision. It is stored in a new `letter_texts` column; the append-only triggers are unchanged.
   - Pending means: state returned, and the latest request revision is greater than every `answers_revision`. Legacy NULL counts as the revision read at receipt.
   - `inbox` includes pending letters, flagged `revisedAfterReply`.
   - An unrelated typo fix that answers v1 keeps the letter pending. Observed: pending True after the typo fix, False after answering v2.
   - CLI: `--answers N` on return and on reply revise.
   - The minimal tests are listed in the evidence (§4).

Not implemented in shared code. No live changes and no commit.
- 一時作業物: `/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/OPS-192.a0JlY2XbbO`・姫・2026-10-20・一時DBでwatchと通知の述語を再現する使い捨ての試作・状態「削除済み（2026-10-20、試作と出力をEvidence/OPS-192へ写したあと削除）」

### Response: thread context (Hime, 2026-10-20; letter LTR-20261020-F30EDE7D…)
At base `1f57c5f65`, discovery only. Details, checked facts and the breakdown are in `Evidence/OPS-192/THREADS.md`.

- **Data.** Today `letters` has no link to other letters; only `task_id` relates them (schema checked). Add an append-only `letter_links` table: one `follows_id` per letter, naming the earlier letter it continues. It is written in the same transaction as `send(…, follows=)`, and a resend replays.
  - It is refused when the followed letter is unknown or the sender is not a participant of it.
  - Cycles are impossible, because the followed letter already exists.
  - A thread is the tree reached through `follows` (root, then all descendants) in send order. Closed letters are included, and all text revisions stay as they were.
- **Navigation.**
  - `GET /letters/<id>/thread` and `comm.py letter thread <id> [--full]` give the same set from any member. Today that path is rejected with 400, so it is free.
  - In the UI, the letter detail lists the thread, and clicking a row reuses `letterSelected`.
  - Reading records nothing and starts nothing; this is checked by row counts in the tests.
- **Legacy letters.** No automatic linking from task ID or prose. An explicit, append-only `link` by the letter's sender, once, with a reason. An unlinked letter is a thread of one.
- **Example.** The chain would be 9FE8ADAB ← E9929557 ← FBDD4946 ← F30EDE7D. E9929557 (3,898 chars) copied 9FE8's 2,143-character request; with `--follows` its body is about 1,750 chars and points to "the followed letter, request v1". These four letters are currently unlinked; nothing was migrated.
- **Gap and rounds.**
  - With links, corrections after a return can be sent as follow-up letters, which reach the existing inbox and watch unchanged. Recommended (T3): refuse `revise request` after `returned`, pointing to `--follows`. That removes the gap and makes the round-2 `answers_revision` and watch changes unnecessary. If it is not adopted, those are still needed.
  - Order: R1 → T1 (store, service routes, CLI) → R2 (the relay of `/letters/…` covers thread) → T2 (UI) → R3. T3 follows T1 if adopted.
- **Decisions for the user/Astra:**
  - whether to limit post-return corrections to follow-up letters (T3);
  - whether legacy linking is sender-only, and whether these four letters should actually be linked.

No shared implementation, no live migration, no commit.

### Response: thread proposal correction (Hime, 2026-10-20; letter LTR-20261020-AB381233…)
The previous subsection is kept. Where they conflict, this one replaces it. Details are in `Evidence/OPS-192/THREADS.md` 「補正」.

1. **Post-hoc link is deferred.** Send-time `follows` can name only an existing letter, so a new letter can never form a self-link or a cycle. A later `link` could create both. The initial scope is send-time links only; legacy letters stay unlinked threads of one.
   - The minimum invariants for later are recorded: the target must be sent before the letter (time, then rowid); no self-link; one link per letter. The refusal tests are listed with them.
2. **Brief versus full.**
   - `GET /letters/<id>/thread` and `comm.py letter thread` return headings only: ID, task, sender → recipient, state, sent/received times, `follows`, and the latest request/reply revision numbers. No body column is selected, as in `letters_brief`.
   - `--full` just reads `/letters/<id>` for each member; there is no new body route.
   - In the UI, the rows load the existing detail.
3. **Minimal staged plan.**
   - T1: `letter_links` (append-only), `send(follows=)`, the brief `thread`, the CLI and the route, after R1.
   - T2: the thread rows in the letter detail, after T1 and R2.
   - Existing revision permissions are unchanged and no old links are inferred.

   The returned-request notification gap stays open as its own item. My earlier "ban post-return revisions" recommendation and the "otherwise `answers_revision` is required" either/or are withdrawn: neither follows from the thread requirement, and the either/or was not shown. Legacy linking and any T3 are later decisions.

The tests for T1 and T2 are in the evidence. No implementation, live change or commit.

### Response: decision provenance preparation (Hime, 2026-10-20; letter LTR-20261020-0271EDF4…)
The corrected thread minimum (T1/T2, with later decisions kept separate) is unchanged. Details are in `Evidence/OPS-192/THREADS.md` 「判断の出典への備え」.

1. **Stable thread identity.** `thread_id` is the root letter's ID, written into `letter_links` at send by copying the followed letter's `thread_id`. An unlinked letter's `thread_id` is its own ID. It never changes: links are send-time and append-only, and post-hoc link stays deferred. If that link is ever added, it must not re-root a letter that has continuations. `thread` and `/letters/<id>` return `threadId`.
2. **Exact source.** `(letter_id, part, revision)` is UNIQUE in `letter_texts`, and texts are append-only (schema checked), so a revision's text never changes when later revisions are added. Example: 9FE8ADAB's request v1 (2,143 chars) and v2 (3,487 chars) both exist.

   Locator convention:
   ```json
   {"kind": "letter-text", "letter": "LTR-20261020-9FE8ADABFD1044F8B562DCF1F54AD66A", "part": "request", "revision": 2,
    "sha256": "de7b8fa9c42ed6415b42de8fba393e1a135f61000f120b7634418721e027409d",
    "thread": "LTR-20261020-9FE8ADABFD1044F8B562DCF1F54AD66A", "speaker": "Astra"}
   ```
   - The v1 hash is `86500c96…`; both were computed now from the stored bodies.
   - `thread` is context only, never scope or authority.
   - `speaker` is the text's `recorded_by`, separate from the decision DB's `actor` and `decided_by`.
   - `_locator` (`decision_store.py` 121) stores this as is, and `decision_cli.py query` returns it. It does not validate or resolve it.
3. **Path back.**
   - Today: `decision_cli.py query`, then `comm.py letter show`, then pick part and revision by hand.
   - Minimal addition, P1: `comm.py letter text <letter> --part … --revision N [--sha256 H]`. It prints exactly one text; a missing revision exits 3, and a hash mismatch exits 1 without printing. It reads the existing `/letters/<id>`, so there is no new route, and it records nothing.
   - P2: document the convention in `decisions/README.md`.
   - No decision-DB code change, no store-crossing call, no UI, and no decision listing or extraction.
- **Files and tests:**
  - T1 adds `thread_id`: root, continuation and continuation-of-continuation share it, and it is unchanged after send.
  - P1 changes `comm.py` (about 30 lines) and `test-studio-letters.py`: v1 and v2 are byte-exact after v2 exists, a missing revision exits 3, a bad hash exits 1 with no output, and there are no row changes and no direct SQLite.
  - P2 is a README change only.
  - Order: T1 after R1. P1 and P2 are independent.

No implementation, live change or commit.

### Response: source attribution correction (Hime, 2026-10-20; letter LTR-20261020-56D9210E…)
The previous subsections are kept. The exact-version locator, P1 `letter text` and the T1 `thread_id` stand. Details are in `Evidence/OPS-192/THREADS.md` 「訂正：speakerを取り下げる」.

- **`speaker` is withdrawn.** Checked in `studio_store.py`: texts are written only by send (240, with `recorded_by` equal to the sender and proxy sends refused), by effective return/stop (295, never by a proxy), and by self-recorded revise (337). So a text's `recorded_by` is the self-reported member who recorded it. That is not the author of every judgment inside it: Astra's "User added: …" is Astra's summary of the user, not a user source.
- **Locator.** It holds only stored facts: `letter`, `part`, `revision`, `sha256`, `thread`, and `recordedBy` copied from the row. A quoted judge is never inferred into a field; a recorder's summary is marked as such in `note`, and unknown stays unknown.
- **Examples** (in the evidence; not registered):
  - (a) An AI proposal: my reply, `recordedBy: 姫`, "not a user decision".
  - (b) An operational choice within delegation: Astra's acceptance section in the canonical doc, `recordedBy: Astra`, "provisional for the user".
  - (c) A user decision: only with the user's own source, such as a letter whose sender is ユーザー.

  `decided_by` may say ユーザー only for (c). Copies, quotes and thread links never promote (a) or (b). In this thread every letter is from Astra, so no user source exists in the letters DB for these requirements.
- **P1 test additions:** `letter text` prints `recordedBy` equal to the stored row, and a proxy record adds no text row (reusing `test_proxy_records_change_nothing`).

No schema, extraction, approval, migration, implementation or commit.

### Response: execution procedure (Hime, 2026-10-20; letter LTR-20261020-B360018F…)
At base `8d8240dc2`. This is a plan only; it is not evidence that any implementation passes. The plan is `Evidence/OPS-192/EXECUTION_PLAN.md`, with a Japanese summary table. Order: R1 → N1 → P1/P2 → R2 → T1 → T2 → R3+L1. One patch per round, accepted before the next.

- **WP1, records service (R1, R2).**
  - R1 moves the records routes into `records_service.py` and adds a per-DB fcntl owner lock. The standalone service and embedded `serve.py` take it before binding; `--records-url` mode never takes it.
  - R2 relays: the UI keeps its own `studio_request` check first, then rewrites Host/Origin. Outcomes: 503 `not-sent`, 504 `unknown`, otherwise a pass-through.
  - Tests: cross-mode collisions with unchanged DB bytes; the UI opening no DB; the relay outcomes.
- **WP2, notification and threads (N1, T1, T2).** N1 is a coherent minimum that keeps every existing permission.
  - Pending means returned with a newer request revision than the one answered. `inbox` includes such letters (`revisedAfterReply`), and `watch` keeps the signatures of letters that left, so re-entry reports `revision` (prototype observed).
  - Answers are recorded by an optional `--answers N` on return and on reply revise, stored in one nullable `letter_texts.answers_revision` column. Without it, a reply does not answer a newer revision, so a typo fix stays pending.
  - Legacy NULL rows: a return counts as answering the revision read at receipt.
  - Races: serialized by BEGIN IMMEDIATE, with the bound checked in the transaction. Retry: `answers` is in the operation payload.
  - **Open choice for discussion:** this explicit rule (column plus optional flag), against the stated alternative "any reply revision answers the latest" (no column, but a typo fix clears it). Banning returned revisions is not proposed.
  - T1 adds send-time `follows`, `thread_id` and a brief thread. T2 adds UI thread rows.
- **WP3, sources (P1, P2).** P1 is `comm.py letter text` (exact version, `recordedBy`, sha check). P2 documents the convention: AI proposal, delegated operational choice, and user original; `decided_by` may say ユーザー only for an original.
- **WP4, loop (R3+L1).** Two real processes run request → reply → (UI stopped) request v2, watch detects, re-answer `--answers 2` → follow-up letter → reply, plus approvals add/list while the UI is down. The restored UI traverses the thread with nothing pending and agrees with the store. Service-down not-sent and recovery are also checked. Rollback tests per cutover variant use an env-free CLI. Three negative controls.
- **Separate:** production cutover (port and operator), post-hoc linking, and decision extraction/UI.

Each package states its files, tests, evidence, boundary and rollback in the plan. No code, live change or commit.

### Response: procedure correction (Hime, 2026-10-20; letter LTR-20261020-79810CD2…)
`Evidence/OPS-192/EXECUTION_PLAN.md` has been corrected in place. The previous subsection is kept. Plan only.

1. **Ownership and files.** After R1, `LETTER_FIELDS` lives in `records_service.py`, so N1 changes it there, not in `serve.py`. R2 now lists `index.template.html` (only the unknown-outcome approval wording) and `test-approvals.cjs` (checking that wording).
2. **Expanded-DB rollback test** (new section).
   - Records are created with N1+T1 code: a revised request, a reply with `answers`, and a `follows` continuation.
   - Base-version code, in a separate temporary copy, is then started on that same DB.
   - Expected: it starts; inbox/show/list read; send/receive/return/revise write; a same-ID resend replays; the added rows and column are byte-unchanged.
   - It does **not** provide the new semantics: a revised returned request stays out of the inbox, and `/letters/<id>/thread` gives 400.
   - Rollback keeps the new records and reads them with old code. Restore from backup is a separate operation that would lose later records, and it is not used here.
3. **Legacy fixtures and fallback.** NULL means no answered revision was recorded; it is not a verified answer. The treatment of NULL is a *proposed* conservative policy: a NULL return answers the revision read at receipt, and a NULL reply revise answers nothing new. Under it the fixtures expect:
   - (i) returned, nothing after: not pending;
   - (ii) returned, then request revised: pending, unless closed;
   - (iii) returned, then reply revised: not pending;
   - (iv) case (ii), then a NULL reply revise: still pending.

   An alternative is stated (show legacy letters as "answered revision unknown"). The choice stays open, and so does the `--answers` policy.
4. **Watch labels.** The test requires detection exactly once. History A (state file made at start, then return, then v2) gives `['state','revision']` once, then nothing. History B (fresh state file, then v2) gives `['new']` once, then nothing. Labels for other histories are not required.

Stopping here for discussion. No code, live change or commit.

### Response: user-returned restoration review (Hime, 2026-10-20; letter LTR-20261020-20B6BDF8…)
At base `f13cadc8c`. Plan only. `Evidence/OPS-192/EXECUTION_PLAN.md` §1–5 is revised; the earlier version is in git.

- **Before and now.**
  - Before (OPS-187 file route): one document reads top to bottom as Assignment → Return → Acceptance, so corrections and answers sit next to each other. Diff-only reading was possible via `git log -p`, and full reading was the file itself.
  - Now (OPS-192):
    - My 8 answers sit together in Return (lines 53–219), away from Astra's corrections (240–337).
    - Every reply of mine refs the same `Return（姫記入）`.
    - The letters already carry `ref_doc`/`ref_section` (all 10), yet bodies copy earlier text: E9929557 has 3,898 chars, of which 2,143 are copied.
    - A revision after return was not delivered (0271EDF4 v2).
- **Smallest restoration, no code (G1–G4).**
  - G1: append corrections and answers in time order at the end of the document, with name tags.
  - G2: each answer names the correction section it answers, and vice versa; reply `ref_section` points at that exact heading (`check_ref` accepts any heading level).
  - G3: letter bodies carry only the delta plus the ref, so an informed reader reads the delta and a new reader reads the document. This also covers the added 読む量 requirement.
  - G4: corrections after a return go as new letters, which already reach inbox/watch. Permissions are unchanged, and the N1 gap stays open as its own item.
- **Example and acceptance.** A short example is in §3, and acceptance A1–A6 in §4. They are checked on the next real exchange; the only machine check is the existing `check_ref`.
- **Ordering.** G1–G4 first, then WP1 (service separation, a separate requirement), then WP3 (exact source, a separate requirement; doc section plus commit also serves), then WP4. N1, T1 and T2 are not needed for restoration and are kept as later candidates. None of `--answers`, legacy classification, new schema or an edit ban is a prerequisite.
- **One user choice.** G1 needs the recipient to append name-tagged sections at the document end instead of writing only inside Return. The gain is time-ordered reading; the cost is the simple "recipient owns only Return" line, which is replaced by "append own tagged sections, never rewrite others".

No code, live change or commit.

### Response: goal-fixed restoration plan (Hime, 2026-10-20; letter LTR-20261020-187EC132…)
Plan only. `Evidence/OPS-192/EXECUTION_PLAN.md` §1–6 is revised; the earlier G1–G4 head is in git. The goal is met in DB, CLI and Studio, with no copying of letters into Markdown.

- **Existing relations reused** (checked):
  - `letter_events.sequence` is one counter across all letters, so a thread's events order without timestamps.
  - Events link to their texts through `text_sequence`.
  - All text revisions are UNIQUE and append-only.
  - Only the letter-to-letter link is missing (no relation in `letters`), so T1's `letter_links` is the one new table, and it is needed for that reason.
- **Minimum.**
  - T1: `send --follows`, written in the send transaction. Unknown targets and non-participants are refused. No post-hoc or inferred links.
  - D1: `GET /letters/<id>/thread` and `comm.py letter read <id> [--full]`.
    - Full: the whole thread's events in sequence order, each with its exact text version (id, part, revision, recorder, time).
    - Delta has two kinds, both shown: (a) a follow-up letter's own body is the new message relative to its predecessor; (b) a revision gives a line diff from the version the reader received to the current one, built at read time with both originals kept. Actual changed text, never a one-line pointer.
  - T2: the Studio letter detail gets 「今回」 (a+b) and 「スレッドの流れ」 (event rows open originals), GET only.
- **Correspondence.** A reply answers its letter's request. A correction is a `follows` letter. The reply it reviewed is fixed by event order: the predecessor's last reply before the correction's `sent`.
- **Example and scenarios.** Both reading modes are in §3; S1–S8 with tests are in §4. They are store, HTTP and CLI tests in `test-studio-letters.py`, and WebKit tests via the extended `letters_e2e`. Reading records nothing.
- **Order.** T1 → D1 → T2 on the current `serve.py`. Service separation (R1/R2) is not required for this goal; it is an independent requirement done after, moving the one added route along. Exact source (P1) fits inside D1, and P2 is documentation. N1 stays open.
- **One user choice.** Whether corrections after a return are normally sent as follow-up letters. They then read as delta (a) and reach the inbox. Revising a returned letter keeps the (b) diff but leaves the N1 inbox gap. Permissions are unchanged either way.

No implementation, live change or commit.

### Response: document-based reading and consolidated procedure (Hime, 2026-10-20; letter LTR-20261020-79B258C4…)
`Evidence/OPS-192/EXECUTION_PLAN.md` is rewritten as one current procedure; old WP and G material is only in git. Plan only.

- **B1, read by canonical document.** `comm.py letter doc <path> [--section H] [--full]`, through `GET /letters?brief=1&doc=&section=`.
  - Matching: the exact normalized path (the `check_ref` form) and an exact heading. A letter matches if any request or reply revision carries that ref. Closed letters are included. Never from prose.
  - Each letter shows which part and revision carry the ref, and whether the latest revision of that part still does (current or former).
  - Unmatched letters in the same thread are not listed. They appear only as "does not reference this document" context in `read --full`.
  - Default output is the latest referencing text plus its diff from the previous revision; `--full` gives all versions in event order.
  - Read-only data: 123 text rows with refs over 104 of 107 letters, 12 letters on this document, and 3 letter/part pairs whose ref changes between revisions. These are the fixture shapes for A5.
- **Corrections.**
  - The latest reply before a follow-up is shown only as labelled ordered context, never as "reviewed". An explicit read-version field is a later option.
  - The N1 defect stays visible and gets a bounded fix that keeps permissions and the default workflow. A returned letter is pending when an effective request `revised` follows the last `returned` with no later recipient reply `revised`. All of these are `letter_events`, one sequence, so no schema is needed. A later reply revision clears it. Limit, stated plainly: order does not prove the reply answers that revision, so a typo fix clears it. Watch keeps the signatures of letters that left; the label tests use two fixed histories.
  - The example now has L2 revised before L2 is returned.
- **Order.** T1 → D1 (thread, delta (a)+(b), `--full`, `letter text`) → B1 → N1 → T2. Service separation R1/R2 and P2 are independent, after, and not dropped. The current DB is remodelled, not a new vessel. Extraction, decisions and handoff summaries stay deferred and independently freezable.
- **Acceptance.** A1–A10, plus an expanded-DB rollback with old code.

No implementation, live change or commit.

### Response: discussion participation added (Hime, 2026-10-20; letter LTR-20261020-4A863BB7…)
`Evidence/OPS-192/EXECUTION_PLAN.md` §2b is added, kept apart from the basic restoration (steps 1–5: T1, D1, B1, N1, T2), which works without it. Plan only.

- **X1, turns and NOP (store/CLI).**
  - An append-only `thread_turns` table records `participants`, `mode` (participate or observe, set only by the member), `speak` and `nop` events. The current speaker is derived by folding them; there is no stored state field.
  - A turn's message is a `--follows` letter from the current speaker to the next one, and the others read it through D1/B1.
  - An explicit NOP passes the turn and changes nothing: no letter state, no N1 pending, no approval, no pending user decision.
  - An observer is skipped. The skip is shown as 「自動NOP（閲覧中）」 at read time and never recorded as an act of theirs. A mode switch takes effect at their next turn.
  - Handoff (replacing a participant) is separate and out of this step.
- **X2, Studio.** It shows the order, the current turn and the member's mode, with 参加する／閲覧に戻る and NOP buttons.
- **Decisions.** No ban on in-thread decisions. Ordinary speech, NOP, auto-NOP and observing never become a confirmed decision. An explicit user decision in a thread is sourced from that exact text (letter, part, revision, `recordedBy` ユーザー, object and scope), and only when the user is the sender. No automatic extraction.
- **Acceptance X-A1–X-A5** cover: the turn order with an observing user shown as auto-NOP; participate, NOP and observe switching; NOP changing nothing; mode set by the member only; and the decision-source rule.
- **Order.** Basic 1–5, then X1 and X2. Service separation and P2 are independent, after.
- **Open for discussion:** who sets and changes the participant order, interrupt and skip exceptions (marked unadopted in the canonical), and the earlier two items (N1's order-only completion limit, and an explicit read-version field).

No implementation, live change or commit.

### 返却：N1と議論機能の限定補正（姫、2026-10-20、連絡LTR-20261020-CAE24016…）
`Evidence/OPS-192/EXECUTION_PLAN.md`を補正した。直したのは§4（N1）、§6（X1）、例、受入表、相談点。基本の復元（T1・D1・B1・N1・T2）と議論機能（X1・X2）の区切りは、そのまま。実装はしていない。

- **N1：知らせた・読んだ・答えたを分ける。**
  - 知らせた：watchの表示はDBに残らないので、記録として扱わない。
  - 読んだ・答えた：明示の操作で記録した場合だけを認める。
    - 足すのは`letter_events`の新しい出来事2つ。`read`（`read-revision --revision N`）と`answered`（`answer --revision N [--body-file]`）。どちらも`text_sequence`に、指した依頼の版の行を入れる。
    - `answer`は、返答の版と`answered`を1つの取引で書く。
    - schemaも状態も変わらない。
  - 未回答の判定：最後の`answered`（なければ最後の`returned`）より後に、依頼の改訂がある。誤字の直しでは消えない。
  - 前からある記録：「回答の記録なし」として未回答に出し、答えたと推測しない。
  - 今の操作は禁止しない。続きの連絡も強制しない。
  - 受け手の一巡：改訂→inboxとwatch→差を読む→`answer --revision 2`。この一巡は§4にある。
- **X1：二重・無限・同時。**
  - 二重：発言は、続きの連絡の送信と`speak`を同じ取引で書く。受領・返すでは順番は進まない。
  - 自動NOP：サーバーが同じ取引の中で`auto_skip`（`recorded_by: server`）を書く。本人の発言は作らず、何が起きたかは記録で確かめられる。
  - 全員が閲覧中なら、1周で止める。
  - 同時の操作は、前提の`turn`とBEGIN IMMEDIATEで1つだけが通る。再送は記録した結果を返す。
  - 受入表に、X-A6〜X-A9を足した。
- **確認の根拠**：
  - `letter_events.event`はTEXTで、状態の判定は`revised`を数えない（`studio_store.py` 172〜177行）。新しい出来事の値は、schemaを変えずに足せる。
  - 出来事の連番は1本（§1）。
- **本当に残る相談点**：
  - 答えたことの明示（`answer`）を、受け手の手間として受け入れるか。順番だけで推す案は取り下げた。
  - 議論の参加者の並びを誰が決めるか。割り込み・飛ばしの例外。

コード、本番の操作、commitはなし。

### 返却：N1の判定を答えた版で行う（姫、2026-10-20、連絡LTR-20261020-124F2AC1…）
`EXECUTION_PLAN.md`の§4とA6だけを直した。ほかの設計は増やしていない。

- 判定の決め方：依頼の最新の版をRとする。Rが返したあとの改訂でできた版で、Rを指す`answered`がないときに、未回答とする。出来事の順だけでは決めない。
- この決め方で次のようになる。いずれもA6の試験場面に入れた。
  - v3が来たあとにv2へ答えても、v3は未回答のまま。v3へ答えると消える。
  - 判定はRだけを見る。だから、v2への答えが遅れて届いても、未回答には戻らない。
- どの返答が答えかを曖昧にしない：
  - `answer`は本文を必ず受け取る（省略できない）。返答の版と`answered`を1つの取引で書き、同じ`operation_id`で1組にする。
  - schemaは変えない。

実装、本番の操作、commitはなし。

## Acceptance（Astra記入）
2026-10-20 初回は未受入。3区切りの構成とHTTP経路の説明は採用候補。次の不足を姫に返し、実装は未許可。
1. 切戻しは旗を外すだけでは閉じない。共通サービスの停止・同一DB所有権の解放とCLI接続先の復元を含む必要がある。現在のstudio_client.pyはREGISTRY_STUDIO_URL/DEFAULT_URLで接続先を選ぶ。
2. 一プロセス互換経路と単独サービスが同じDBを開ける設計なので、両経路にまたがる排他の範囲・取得解放・起動衝突試験を内訳へ明記する。新サービス同士だけの検査では足りない。
3. 中継先での接続前失敗と送信後の結果不明を、画面までどう保つかを内訳へ明記する。UI側で元のOrigin検証を保つことも必要。
実装ではなく内訳の補正依頼。既存環境変数で試験できるため、本番port選択と起動担当を今回の調査の停止条件にしない。本番切替時に扱う。CP-006の独立修正は自動追加しない。

## 受領遅延の確認（ユーザー追加）
今回の依頼はサーバー送信記録05:58:12.589998Z、本人受領05:59:25.080573Zで約72秒差。DBの遅延と断定しない。姫の待機・照会タイミング、検知とreceiveの実行タイミングを確認し、連絡DB/監視経路に原因があれば修正対象へ。人間の追加中継を前提にしない。

## 返答後改訂の配送漏れ（Astra確認）
初回返答後に同じ連絡のrequest revision 2で補正依頼したが、studio_store.pyのreviseはstateを変更せず、inboxはOPEN_FOR_RECIPIENT（sent/received/started/withdrawn）のみを返す。returned状態の改訂はwatchから見えない。初回の72秒とは別の、再現可能な配送経路の穴。初回連絡を未受入の記録付きで閉じ、補正依頼を別連絡として発行する。重複実行ではなく配送先の明示的な切替。恒久修正は今回の内訳で候補と最小試験を確認する。

## 検収2（Astra）
補正A〜Cは方向として改善。未受入の残点：Aの「環境変数を消す」はDEFAULT_URLも変更した場合に旧接続先へ戻らないため条件別に訂正。Eのeventとtextのsequenceは別系列であり、その数値を直接比較する設計は不可。watchは受信箱から消えたIDをseenから除くため再登場はnewになり得る。返答改訂後に未処理表示が解消する条件も必要。姫に小さな隔離再現で往復全体を確認して訂正するよう返す。共有実装変更は許可しない。
受領遅延は姫の操作説明では待機前と読解時間。DB遅延がないことの一般保証とはしない。

## 検収結論（Astra、2026-10-20）
分離の作業内訳（R1共通サービス抽出・R2画面中継・R3停止/再起動/切戻し試験）をDISCOVERY成果として受入。実装や本番切替の受入ではない。ユーザーにこの3区切りを提示し、範囲確認までは実装を開始しない。
通知漏れは実コードと隔離再現で確認。姫のprototypeをAstraも再実行し、現行watchの検知漏れと再登場newを確認した（[ログ](Evidence/OPS-192/astra-prototype.txt)）。提案部分はインプロセス模擬であり、answers_revisionのDB移行・既存返答の扱い・通知保持の採用や実装を保証しない。分離と別の修正候補に残す。初回受領72秒は担当の説明に基づく内訳で、通信遅延なしの一般保証ではない。
一時作業物：Astraの再現用/tmp/astra-ops192-*、2026-10-20作成・ログ保存後削除済み。実サーバーへの変更なし。

## スレッドを辿る要求（ユーザー、2026-10-20）
「受け取ったレターについて、スレッドがたどれること」を追加。目的は、文脈を保持し、前提の再掲と復元に必要なやり取りを減らすこと。同じtask IDで集めるだけでは、同一task内の別の話題と続きの会話を区別できない。

受入で確認する利用場面：
- 受け取ったレターを起点に、その話題の過去の依頼・返答・補正へ辿れる。
- 同じレター内の改訂だけでなく、別レターに分かれた続きも辿れる。閉じた連絡も文脈として参照できる。
- 元の本文・版・担当・時刻を参照でき、前提を毎回本文へコピーする必要がない。履歴の閲覧は受領・着手や旧指示の再有効化ではない。

データ構造・CLI/画面での経路・旧レターの扱いは、姫が最小案と確認可能な作業内訳を提示する。既存の分離R1〜R3および通知漏れとの依存関係を整理し、推測で過去レターを自動結合しない。今回は追加DISCOVERYを継続し、実装内訳の確認前に本番変更しない。

## Assignment: thread context follow-up
Continue OPS-192 discovery with the new user requirement above. Return a small recommended design and file/round/test breakdown, grounded in current code. Explain how a recipient starts from one received letter and traverses prior requests, replies, corrections, revisions, and closed letters in the same conversation, including continuations issued as separate letters. Same-task filtering alone is insufficient. Preserve original records; reading history must not acknowledge or restart work. Do not infer historical thread membership from task IDs or prose automatically.

Cover the data relationship and the minimum CLI/UI navigation needed, legacy unlinked letters, and the relation to the returned-request notification gap and service extraction R1–R3. Avoid expanding into a general chat product or automatic summarization. Show a concrete short correction that can rely on linked context rather than copying the whole original request. Use this task's three recent letters as a manual example, not live migration: 9FE8ADAB…, E9929557…, FBDD4946… (full IDs in this document and the communication DB).

Only edit a new Return subsection here and Evidence/OPS-192/. No shared implementation, live migration, server control or commits. Disposable prototypes are permitted if needed to check an uncertain claim. Provide enough checked evidence for a small review; material gaps will be returned rather than repaired by Astra. Return on the new assignment letter and remain available for feedback.

## スレッド案の初回検収（Astra）
明示follows＋受信レター起点のCLI/UI読取を最小案として検討する。未受入点：後付けlinkで自己参照・循環が作れる条件と拒否試験が不足。送信時の既存親だけでは後付けlinkの安全性を説明できない。threadの軽量一覧と全版本文の説明も明確に分ける。
returned後の改訂禁止は追加方針であり、スレッド閲覧要求から自動採用しない。「禁止しなければanswers_revisionが必須」という二択も未実証。初回は新しい続きのレターで文脈を辿る機能を成立させ、既存改訂の通知漏れと後付けlinkの権限は別の決定点として残せるか、最小の段階案へ整理する。実装は未依頼。

## 判断の出典接続に備える要求（ユーザー、2026-10-20）
スレッド内でAI同士が何を判断したかを後で確認できるよう、今回は次の土台を準備する。判断の抽出・一覧表示・自動採用は今回の範囲に追加しない。
1. レターが増えても同じ会話を参照できる、安定したスレッド識別。
2. 出典を「レターID・依頼/返答・版番号」まで指定できること。最新版本文へ勝手に読み替えない。
3. 判断DBの既存出典項目からその発言へ戻るための表現・読取経路を確認し、不足だけ内訳に足す。
スレッドは判断が生まれた会話の文脈。判断の適用対象・適用範囲や、採用/承認権限とは別物として扱う。発言者と記録者・決定者も同一視しない。

Astraの事実確認：`decisions/decision_store.py`の`_locator`はsource/locatorに空でない辞書を受け付け、foldはその内容を保存する。よってレターと版の識別情報を格納するためだけの新カラムは不要。ただし、locatorの項目規約・参照先存在・版一致・画面/CLIの解決は現行のこの検査では保証しない。格納できることと辿れることを区別する。

## Assignment: decision provenance preparation
Continue OPS-192 discovery from the corrected minimal thread proposal. Add only: stable thread identity; exact source identity (letter ID, request/reply, revision); and a minimal path from the decision DB's existing source/locator object to that exact original text. Inspect the existing decision CLI/export/read paths. Astra confirmed _locator currently accepts a nonempty dict and stores it; that does not establish validation or resolution. Prefer a documented locator convention and existing reads where sufficient; identify any minimal missing API/CLI/UI work. Do not add decision extraction, decision lists, automatic adoption, scope inference, live data migration, or a general graph redesign.
Return a small example locator using this conversation's letters, explain how it resolves to the exact version even after later edits, and give the changed file/test breakdown. Thread association is provenance/context, never scope or authorization. Retain the original thread minimum and keep deferred legacy-link/notification policy separate. Same shared edit limits: append Return here and Evidence/OPS-192 only; no implementation/live changes/commits.

## 判断の由来を維持する要求（ユーザー、2026-10-20）
AI同士の合意・採用は、ユーザーにとっては仮判断。委任された範囲で作業に用いることと、ユーザーが確定した判断であることを区別する。引用・コピー・再掲・スレッドへの関連付けを繰り返しても、AI判断をユーザー判断へ昇格させない。
出典は誰のどの発言かを保持し、記録者を決定者と同一視しない。「ユーザー確定」とするにはそれを支えるユーザーの原典が必要。ユーザーがAIに方法を任せたことだけでは、その方法の個々の選択をユーザーが決めたことにしない。
今回の出典準備ではこの区別を説明と試験例に含める。判断抽出・承認機構・既存判断の一括再分類は追加しない。

## 出典案の検収（Astra）
版固定locatorと既存showを使うtext読取案は準備として妥当。未受入点：speakerをletter_texts.recorded_byと同一視しない。代理記録を含む場合の発言者・記録者・引用された判断者を区別する。不明なら不明のままにし、Astraによるユーザー発言の要約をユーザー原典として扱わない。姫の返却と追加要求の送信が行き違ったため、未受領の追加要件は別レターで届ける。

## 追加準備の受入（Astra、2026-10-20）
追加DISCOVERYを受入。現在の最小実装案はR1共通サービス抽出→T1新規レターのfollows・安定threadId・CLI読取→R2画面中継→T2画面スレッド読取→R3停止/復帰試験。P1版固定text読取とP2判断DB出典規約を小さく追加できる。判断DBの新カラムは不要。
出典のrecordedByは記録者であり、引用された判断者やユーザー本人とは同一視しない。AIの判断・要約をユーザー確定へ昇格させない。本文の出典だけで判断内容の妥当性まで保証しない。
実装はまだ未依頼。ユーザーに内訳を提示して範囲を合わせる。既存レターの後付け結合、returned後改訂の通知漏れの恒久修正、判断抽出/一覧、本番切替は未実施・別扱い。今回の通知経路は新規レターで継続しており、既存の穴を修正済みとは扱わない。

## 実施要領の作成依頼（ユーザー、2026-10-20）
今回の終了地点は実施要領の検収とユーザーへの提示。そこまでで止めて相談し、実装に進まない。
対象は、共通サービス分離、スレッド追跡と補正通知漏れ修正、版固定の判断出典読取、依頼→返答→補正→再返答と画面停止/復帰の試験。前の「通知漏れは別扱い」を更新し、今回の実施要領に含める。既存操作の禁止や未決設計案を承認済みにはしない。

## Assignment: execution procedure only
User requests a concrete execution procedure, then STOP for discussion. No implementation is authorized. Continue from the accepted discovery and corrected THREADS.md; do not restart a broad investigation.

Write Evidence/OPS-192/EXECUTION_PLAN.md, with a short Japanese summary, and append a concise Return here. Cover four work packages: (1) shared records service, (2) thread traversal AND the returned-request revision notification gap, (3) exact-version source reading and locator convention, (4) integrated request→reply→correction→reply tests including UI stop/restart. Order dependent substeps sensibly; reuse the existing R/T/P breakdown rather than duplicating it.

For each package specify concrete files, changes, prerequisites, test setup/observable expected results, acceptance evidence, patch/return boundary and rollback. Keep production cutover separate. Tests must use disposable DBs and test ports, not the user's server or stores. A plan is not evidence that implementation passes.

For notification, propose one coherent minimum covering detection, revision identity, re-answer completion, races/retry and existing records. Neither banning returned revisions nor answers_revision has been adopted. State any genuine unresolved behavior choice plainly; do not silently change permissions or make a false binary. Explain how existing operations remain supported, or identify an explicit proposed change for user discussion. Do not resurrect deferred automatic historical linking or decision extraction/UI.

Acceptance: requirements map to tests; the full conversation loop is covered, not only isolated API calls. Preserve one writer ownership across embedded/standalone modes and correct CLI rollback. Source references distinguish recorder from decision maker, AI provisional choices from actual user decisions. Avoid redundant essays, arbitrary line-count quotas or asking the user to resolve checkable facts. If required facts are missing, check them or mark a concrete blocker, rather than passing the research to Astra.

Editable shared scope: append Return in this document and Evidence/OPS-192/EXECUTION_PLAN.md only. Read-only inspection allowed. No code edits, live mutations, server control or commits. Return on this letter, then wait. Astra will review the procedure and stop to discuss it with the user; no automatic implementation launch.

## 実施要領の検収1（Astra）
4まとまりと通し試験は要求に対応。要領の確定前に限定補正：R1で移す受付とN1の変更先の整合、R2の画面文言変更ファイルを内訳へ追加、DB拡張後の旧コードで読取/書込/再送する切戻し試験、初期旧記録の扱いとwatch出力を特定履歴に依存させない試験を明記する。N1の回答版明示は提案のままであり、ユーザー相談前に採用・実装しない。

## 実施要領の受入・停止（Astra、2026-10-20）
補正を確認し、[実施要領](Evidence/OPS-192/EXECUTION_PLAN.md)をユーザー相談用の計画として受入。実装合格・未決方針の採用とは区別する。変更ファイル・順序・隔離試験・受入証拠・切戻しを記載済み。
相談点はN1の回答版明示（任意answersを付けて再回答を閉じる案）と、過去に回答版を記録していない連絡の保守的な扱い。ここで作業を止める。姫へ実装は依頼しない。次はユーザーとの相談。

## ユーザー差し戻し：正本の往復を復元する（2026-10-20）
ユーザー：「もともと正本でやりとりしてたじゃない？あのときには存在してたけど、今消えちゃってるものをまず復元してるイメージだったな」「ユーザー差し戻しってことで、引き続き検討ループまわしてみて」。前節の計画受入はユーザー採用ではなく、今回差し戻された検討案として扱う。
基準を、正本で同じ文書に依頼・返却・補正が並び、前後と対応関係を読めていた利用体験の復元へ戻す。版番号の入力や旧記録の分類等の設計都合を先にユーザーへ決めさせない。何が失われ、何を戻せば足りるかを実例から整理し、必要最小限の実施要領を再検討する。サービス分離と出典準備の要求は撤回されていないが、復元との関係・順序を再評価する。検討ループのみ再開。実装・本番変更なし。

## Assignment: user-returned restoration review
The user returned the execution plan: the purpose was first to restore what canonical-document exchanges already provided, not to design a new communication workflow. Continue the review loop, no implementation.
Read a small representative prior canonical exchange (request, Return, Astra correction/acceptance in one document) and the current OPS-192 letters. Return a compact before/now/restoration comparison backed by those examples: what context, sequence, correction/response correspondence and decisions could be seen together before, what is missing now, and the smallest way to restore it. Do not assume every historical workflow was perfect or reconstruct all history.
Revise EXECUTION_PLAN.md around that user-visible experience. For each proposed addition, explain which lost capability it restores, or mark it as a separate existing requirement (service separation / exact source). Reassess ordering. Do not make --answers input, legacy classification, a new schema, or forbidding edits prerequisites merely because the earlier plan proposed them. Prefer reusing existing record/history relationships where sufficient; name real limits honestly. Preserve exact originals and AI/user attribution. No automatic inferred historical links or retroactive user decisions.
Show one concrete request→return→correction→re-answer example as the recipient and user would read it, without repeating full context. Derive acceptance scenarios from that example. If a genuine user behavior choice remains, explain the lost capability/tradeoff rather than exposing internal machinery as the question.
Allowed shared changes: revise Evidence/OPS-192/EXECUTION_PLAN.md and append Return in this canonical. Preserve prior Returns; git retains prior plan. No code edits, production operations, DB migration, or commits. Short reply with evidence location. Astra will review and return material gaps; finish this planning loop and stop for user discussion before implementation.

## 読む量を選べる要求（ユーザー、2026-10-20）
「頭に入ってる人は差分だけ確認できればいいし、入ってない人は全文みれるようにする必要がある」。文脈を持つ読み手は今回の追加・訂正だけを確認でき、持たない読み手は同じ起点から会話の原文全体を辿れること。原文を削って差分だけを保存することでも、毎回全文を強制することでもない。要約と原文を混同せず、何に対する差分かを参照できること。

## 現在のゴール確定と復元案の差し戻し（2026-10-20）
ユーザー：「今のゴールはテキストの正本機能の復元と差分読み機能とを成立させること」。これは連絡DB／Studioで以前の文脈・往復の機能を復元する要求。Markdown運用へ戻すことではない。レターからスレッドが辿れる要求も継続する。事情を知る人には今回の差分、知らない人には原文の全体を同じ起点から提示する。
今回の返却G1〜G4は正本文書の並べ方に戻り、T1/T2を不要として先送りしているため、このゴールの実施要領として未受入。旧テキストの機能を比較対象とし、連絡記録を再び手でMarkdownに複写・並べ直す運用を主解にしない。範囲を拡大せずDB/CLI/Studioで満たす最小の実施要領へ修正する。
判断抽出・判断一覧等のアイデアは次段階。サービス分離と出典の要求は消さないが、この復元に必須か独立かを区別して順序を整理する。実装開始ではなく検討ループ継続。


## 正本単位のCLI読取と改築方針（ユーザー、2026-10-20）
ユーザー：「いけるところまで改築でいこう」。旧DBを残して新しい器へ移る案はいったん置き、現行DBの改修として検討する。
追加要求：「コマンドで正本単位で読めるようにする」。正本を指定して、そこに明示的に関連付いた連絡をまとめて読み、必要に応じて各本文・スレッドへ辿れること。連絡IDを先に知ることを前提にしない。差分／全文の読み方と併せて実施要領へ組み込む。これは検討依頼であり実装開始ではない。
判断抽出・未回答補正の抽出・担当交代要約は今後の候補。問題があれば個別に凍結でき、原文と基本連絡を止めない方向で検討する。今回は実装範囲に含めない。

## 実施要領の限定再検討（Astra、2026-10-20）
DB/CLI/Studioで文脈と差分を読む方向は要求に合う。ただし、補正が参照した返答版を「送信前の最後の返答」から断定することは、実際に読んだ版の証明にならない。構造上の順序と参照版の証拠を区別すること。返却後改訂の通知漏れを、続きの連絡を使う運用のみで解決済みにしないこと。例の返却・改訂の順序の矛盾を直し、旧計画と現行手順の重複を整理する。正本単位の読取を含む実施要領を返却し、ユーザー相談前に実装へ進まない。


## スレッドは2者間を維持する（ユーザー決定、2026-10-20）
ユーザー：「一つのスレッドは、2者間に限定かなぁ。担当切り替えはあっても、2者であることを維持するルールにしよう」。確認への「うん」を受けて記録。1スレッドは常に2者間とし、担当交代は片側の引継ぎとして扱い、3者目の参加にはしない。過去の発言者は変更せず、誰から誰へいつ引き継いだかを残す。別の相手との相談は別スレッドとし、必要なら関連付ける。今回の実施要領に反映し、担当交代の具体的な実装範囲と検証方法を整理する。実装開始の許可とはしない。


## 2者限定を訂正：順番に発言権を回す（ユーザー、2026-10-20）
直前の2者限定は撤回。ユーザー：「3者4者の場合は、順番に回す方式にしようかな」。発言担当を1人とし、話し終えたら次へ渡す方式との確認後、「おねがい」と検討依頼を受けた。スレッドの参加者数を2人に制限せず、参加者・現在の発言担当・発言権の受渡しを区別する。担当者そのものの交代と発言順も区別し、過去の発言者を変更しない。具体的な順序の決め方や例外はまだ採用されていないため、最小の実施案を検討する。実装開始ではない。

補足（ユーザー）：発言がなければ `NOP` で順送りする。発言内容を無理に作らず次へ渡せること。NOPを承認・賛成・作業完了と同一視しない。


## ユーザーの途中参加（ユーザー確認、2026-10-20）
ユーザーも同じ議論へ参加できる。普段は閲覧のみで自動NOPとし、「参加する」に切り替えると次に回ってきた自分の番で発言する。「閲覧に戻る」で自動NOPへ戻れる。この形を盛り込むようユーザーから依頼された。自動NOPは承認・賛成・判断の放棄ではなく、別に必要なユーザー判断待ちを解消しない。発言順への参加と判断権限を区別して実施要領に含める。実装開始の指示ではない。

補足：ユーザーは「ユーザー判断はスレッドではしないな」、続けて「しちゃうばあいもあるかもしれないがｗ」と述べた。したがってスレッド内判断の禁止規則にはしない。通常の議論参加と正式判断は分け、スレッドで明示的に判断した場合も、その発言・対象・範囲を根拠として扱う。通常発言や自動NOPを確定判断へ昇格させない。判断抽出の自動化は今回の範囲外のまま。


## 現行連絡の日本語化と計画補正（2026-10-20）
ユーザーとの確認を受け、今後の依頼・返却・補正・議論は日本語とする。参加前から連絡を読んで任せられるか確認する必要があるため。通信規約の言語記録を更新。過去原文は維持する。
実施案は基本復元と議論機能を分けた点を確認。N1は返答の誤字修正でも未処理を消すため、そのまま受入しない。通知・閲覧・回答を区別し、記録していない回答関係を推定で確定しない最小案へ限定再検討を依頼する。実装開始前に相談する区切りは維持する。


## N1の回答版判定の再検収（Astra、2026-10-20）
answeredで対象版を記録する方向は確認。ただし判定が出来事の時刻順のままなので、依頼v3の到着後にv2へ回答するとv3まで未回答から消える。対象版を用いて判定し、「v2への回答後もv3が残る」場面を必須検証にする。順序だけで回答範囲を推測しない。計画の限定補正であり実装受入ではない。


## 限定補正の確認・相談区切り（Astra、2026-10-20）
回答版Rを明示して判定する補正と、旧版への後着回答ではRの状態を変えない検証場面を確認。実施要領はユーザー相談用の計画として保存する。実装・実試験の合格とは扱わない。基本復元→議論参加の段階を維持し、ここで実装前の相談に戻る。回答操作の具体的な使い勝手と、議論の参加者順の決め方は提案であり、ユーザー採用済みとはしない。
