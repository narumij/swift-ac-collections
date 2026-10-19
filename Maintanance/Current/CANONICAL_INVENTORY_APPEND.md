# 正本への棚卸し追記

## TL;DR（人間向け）

正本の本文を保ちながら浅い棚卸しを追記する方式を、固定版・出現行・確認方法・更新条件まで補完した記録。2固定版で保存結果の全項目一致を独立再実行して受け入れ、この限定作業は完了した。存在確認と意味上の正しさは別で、深い挙動・CI実走・全体適用は含まない。

2026-10-17 / OPS-074 / registered by Astra. Parent OPS-070. Merged the user's direct request CP-20261017-013 into the formal record.

<a id="範囲"></a>
## Scope

Check Current canonicals against the facts and append, at the end, inspection facts, provisional judgments to watch, correction/expiry proposals, and threads into the history. Changing or deleting existing bodies, Registry changes, user-confirmed documents, and documents under work by an owner are out of scope. Keep the current instruction of shallow checks only; deep checks are postponed. Completing every item is not an obligation: return the targets, results and remainder at each break.

<a id="第1区切り"></a>
## First break

The [return](Evidence/CP-20261017-013/SHALLOW_CHECK.md) and the additions to two documents were [accepted with corrections](OPS_072_ACCEPTANCE.md). The fact of the moves was confirmed; historical paths are not bulk-replaced.

<a id="残り"></a>
## Remainder

Correct the mismatched totals and the erroneous statement that something did not exist, and save the extraction conditions, target list and classification details reproducibly. Separate mechanical existence checks from semantic link soundness. Guaranteeing all items needs this detailed reconciliation. Do not start deep investigation automatically; return the next shallow break and get it accepted. Not yet requested at registration. On 2026-10-17, by user instruction, the second break below was formally requested of Hime.

<a id="記録の更新条件2026-10-17--ユーザー依頼astra記録"></a>
## Update conditions for records (2026-10-17 / user request, recorded by Astra)

When appending inventory notes, leave briefly, as far as known, "what change should trigger reviewing which record". This is to reduce the burden of doubting and re-investigating everything each time; classifying every statement or constant monitoring is not required.

- **Trigger for update**: when the grounds or validity conditions of the conclusion change, such as target code, referenced paths, CI settings, or Swift/toolchain versions. Write concretely only the ones that apply.
- **Scope of review**: the inspection facts that changed and the conclusions depending on them. Do not re-investigate unrelated history or other conclusions.
- **While nothing changes**: treat it as a confirmed result for the recorded version, environment and check scope. Do not extend it into a guarantee that it holds unconditionally on the current version.
- **When it is unknown whether anything changed**: when reusing the record, check only the relevant update conditions first. If they cannot be confirmed, leave it unconfirmed and do not expand into a whole-history search.

Example: when a referenced path is moved or renamed, review the path's existence and the reference target. An ASan result is checked for reusability when the target version, OS, toolchain or run settings change. Do not automatically extend from this shallow check to re-running tests.

Update conditions are triggers for reopening a record, not permission to change the body, run tests, or expire delegations or judgments. Even when history is moved to the archive, keep the conclusion's validity conditions and the unconfirmed scope on the surface. This addition does not adopt a system-wide scheme or apply it in bulk to existing documents.

<a id="姫への依頼第2区切り2026-10-17--作成受入astra"></a>
## Request to Hime: second break (2026-10-17 / written and accepted by Astra)

Based on the user's 「ひめにアサインして、こみっとしてほいて」. OPS-074 is ACTIVE. Start within the following scope.

1. Supplement the mismatched totals of the first break and the erroneous statement about the existence of past files with a correction record that keeps the original return. Use the [acceptance corrections](OPS_072_ACCEPTANCE.md) as input.
2. Save the target version, extraction conditions, target list and classification details of the shallow check reproducibly. Do not confuse the original reported values for 72 documents with the current number of targets; if they differ, distinguish them. Limit this to existence checks of referenced paths and commits; if interpretation is needed, return it as unconfirmed.
3. For records that could be confirmed, add update conditions and review scopes only where known. Classifying every statement is not needed. When supplementing the existing additions to the two documents, do so in a new appended section.

**Editing scope**: create details, re-run steps or a script, and a correction record in `Evidence/OPS-074/`. Report in the Return field at the end of this document. In `AtCoder2025CompatibilityPlan.md` and `EXTERNAL_TYPE_EXTENSION_AUDIT.md`, only inventory additions are allowed, after confirming occupancy at the start. Do not change the original bodies, past returns or acceptance records.

**Out of scope / stop conditions**: verifying deep claims, changes to product, Tests, CI or Studio, running tests, shortening canonical bodies, adopting systems, updating the Registry, and other owners' in-progress areas are out of scope. If an out-of-scope judgment or change is needed, stop at that point and return the checked scope and the needed input. Do not search to fill every item.

**Completion condition**: the counts match the details, the original errors are identifiable via the correction record, and the re-run method and limits, examples of update conditions, and the remainder can be checked. Do not count unconfirmed items as normal. Astra accepts.

With the request complete, the output scope above is handed to Hime. Astra does not edit that scope until the return. This commit permission applies to committing the request preparation and coordination records. Committing Hime's output or external operations is not included in this request.

### Return（姫記入）

**実行モデル・入力版**：Claude Opus 5.5（姫）、入力版`1bdbbd4f`。ユーザー「あすとらさんに相談してきた。あとやって」を受けて着手。

**変更範囲**：`Evidence/OPS-074/`を新設（`shallow_check.py`＝再実行スクリプト、`shallow_check_result.json`＝全明細、`README.md`＝抽出条件・集計・不在21件の明細と仕分け・限界、`CORRECTION.md`＝第1区切りの訂正記録）。`AtCoder2025CompatibilityPlan.md`・`EXTERNAL_TYPE_EXTENSION_AUDIT.md`の末尾に「棚卸し追記2」（更新条件・見直す範囲）を新しい節で追加（追記時に占有を確認：PERM-079はWAITING_USER、監査はtaskなし）。元本文・過去返却・受入記録・Registryは変更していない。

**結果**：76文書・参照272件（存在249、`:行番号`付きで存在2、不在21〈gitに履歴あり15・主候補パスで履歴なし6〉）、hash100件（commit83・blob3・objectでない14）。第1区切り（72文書・97 hash）との差は第1区切り後の新規4文書。第1区切りの「23件」は「不在21＋`:行番号`付き2」に一致。集計の不一致と`DOCUMENTATION_MILESTONES.md`の誤記は`CORRECTION.md`で訂正（原因：内訳の手数え、リンクの基準取り違え）。

**検証**：スクリプトの出力（`summary`）と`README.md`の表の件数が一致することを確認。commitとして存在しないhashを指す記述は見つからなかった（objectでない14件はSHA-256先頭・外部repoの版で、種別は本文の文脈による解釈）。

**限界・未確認**：存在だけを見ており、参照の意味上の正しさは判定していない。不在21件の「仕分け」列は解釈で、#1・2・12（基準の違い）、#16〜18（提案・予定が実施されたか）は未確認。抽出規則に当たらない書き方は対象外。

**更新条件の記入例**：2文書の「棚卸し追記2」。作業中の2文書（RBT-026・RBT-007、明細#13・#19）には追記していない。

**残り**：深い点検（後回しのまま）。#13・#19の担当への受渡し。#1・2・12の基準の確認。次の浅い区切りを行う場合は、本スクリプトを再実行して差分だけ見ればよい。

<a id="第2区切り受領追加対応依頼2026-10-17--astra"></a>
## Receipt of the second break and request for additional work (2026-10-17 / Astra)

Based on the user's 「OPS-074おわったらしいので、受け取って差し戻しと、どこかに記載」. The original Return and outputs are kept. Confirmed that the totals of the saved JSON (references 272 = 249+2+15+6, hashes 100 = 83+3+14) match the README, along with the re-run script, the correction record and the additions to the two documents. Reproduction of a fixed version by re-running has not yet been confirmed. OPS-074 stays ACTIVE; completion acceptance comes after the additional return.

<a id="会話で具体化した記録方式"></a>
### Record format made concrete in conversation

Cut out the facts a judgment depends on, in a form where fact checking can be delegated to another low-cost AI if needed. This time, no new AI is started or delegated to.

The basic grounds are **the full commit SHA, the file path in the repository, the line-number range in that version, and the claim checked**. Do not try to cover every dependency of a judgment; start with the facts that could change the judgment. Hand over the question to check, where to search and when to stop, and get back confirmed / conflicting / unconfirmed with evidence. Distinguish absence from not-found.

On update, do not apply the same line numbers to the current version; follow the corresponding place through the diff between versions and re-check only the relevant claims. If there are dependencies outside the diff (settings, callers, environment, etc.), state them, and do not conclude the result is unchanged just because the target lines did not change. For facts without lines, such as a file's existence, the path and check method are enough. Do not force a line range.

Do not call uncommitted content a fact of HEAD; record saving the target content, a hash, etc. alongside. OS/toolchain and external CI results cannot be fixed by a commit alone, so keep the necessary environment, run and evidence separately. This format is a limited trial this time and is not applied in bulk to all records.

<a id="姫への差し戻し範囲"></a>
### Scope sent back to Hime

1. **Distinguish the input version**: the current script reads the working tree and puts HEAD in `input_commit`. Change it to read a fixed version by full SHA, or to a saving method that can restore whether the working tree changed and the target content. Use a fixed version for this shallow check if possible, and align existence checks to the same version. Also show the ref range of the history search and the version/hash of the script itself. Do not silently replace the old result; save it as a new result.
2. **Location of the grounds**: attach to the new result the line ranges in the source documents, the claims checked and the check method. When aggregating duplicate references, do not lose the occurrences. Using a few of the additions to the two existing documents as examples, map the format above to update conditions. Do not investigate deep product behaviour.
3. **Boundary of the total correction**: do not settle the past 72-document count from the new 76-document result alone. If the comparison with the old version can be reproduced cheaply, save the grounds; if not, correct the restoration of the old totals to unconfirmed. List the 4 additional documents in the README instead of abbreviating them as "others".

Edits are limited to the script and new results/supplementary records in `Evidence/OPS-074/`, an additional Return at the end of this document, and new additions to the two existing documents. Keep the original return, old evidence, acceptance sections and request text. Deep investigation, system changes and product/CI/Registry changes are out of scope. Where searching becomes expensive, return unconfirmed with the needed input and stop.

Completion condition: the input can be identified and restored, and claims can be looked up from the location of their grounds. Details and totals match, and the scope of re-checks and what is unconfirmed are clear. Astra independently checks a few and accepts. With the request complete, the scope above is re-delegated to Hime, and Astra does not edit it until the return. Commit and external operations are not included.

### 追加Return（姫記入）

**実行モデル・入力**：Claude Opus 5.5（姫）。ユーザー「コミットしてつぎやって」で着手。固定版`10d4951fc88d34f55d1b99f0712504c0e8468354`と`d6e6fab66fa3…`（完全SHAは結果JSON）。

**変更範囲**：`Evidence/OPS-074/`に`shallow_check_v2.py`、`result_v2_d6e6fab6.json`、`result_v2_10d4951f.json`、`SUPPLEMENT.md`を追加。旧スクリプト・旧結果・旧README・訂正記録は変更していない。`EXTERNAL_TYPE_EXTENSION_AUDIT.md`の末尾に「棚卸し追記3」（根拠の書き方の例3件）を新しい節で追加。本文・過去返却・受入節・依頼本文・Registryは変更していない。

**1. 入力版**：v2は作業ツリーを読まず、文書・存在・履歴を指定commitのtreeから取る。履歴は指定commitから到達できる範囲のみ。結果に完全SHA・スクリプトのSHA-256・対象文書一覧を記録。旧版が作業ツリー値をHEADと書いていた点は`SUPPLEMENT.md`§1に記載。

**2. 根拠の所在**：各参照・hashに出現行・確認した主張・確認方法を付け、重複も出現ごとに残した。例は`EXTERNAL_TYPE_EXTENSION_AUDIT.md`追記3の3件（行を持たない存在、`git grep`による未発見、ソースの行範囲）で、それぞれ更新条件と見直す範囲を対応させた。

**3. 集計訂正の境界**：固定版`d6e6fab6`を新スクリプトで読むと、第1区切りの報告値（重複除き不在21＋`:行`付き2＝23、hash 97中commit 80）を再現できた。第2区切りの旧結果（76・272・100）は作業ツリー値で、固定版`10d4951f`（重複除き273・hash 103）とは一致しないことを区別した。追加4文書は列挙済み（`SUPPLEMENT.md`§2）。

**検証**：2つの固定版で実行し、`SUPPLEMENT.md`の表の数をJSONの`summary`と重複除きの集計から確認。追記3の3件は、そのcommitで`git cat-file`・`git grep`・`git show`により照合。

**限界・未確認**：存在の判定だけで、意味上の正しさ・深い挙動は見ていない。「履歴なし」は主候補パス基準。objectでないhash 14件の正体は解釈。追記3は3件の例で、全記録への適用ではない。

**残り**：深い点検（後回し）。作業中2文書（RBT-026・RBT-007）の古い参照は担当へ。

<a id="追加返却のastra受入2026-10-17"></a>
## Astra acceptance of the additional return (2026-10-17)

Independently re-ran the saved v2 script on the two fixed versions d6e6fab6 and 10d4951f and confirmed all items match both saved JSON files. Directly checked lines 322–325 of Result._NodePtr in the fixed version. Accepted the input version, occurrence lines, check method, update conditions and the distinction from the old working-tree result. OPS-074 is DONE up to completing the limited format; whole-repository application is handed to OPS-076.

Limits: object-type lookup of hashes depends on the local object database. Documents and references come from a fixed tree, but reproduction is not guaranteed for hashes of external repositories or ambiguity of short hashes. Semantic correctness, deep behaviour and real CI runs are unverified. Supplement only when needed in the whole-repository trial.
