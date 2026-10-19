# 番号なし通常カードの生成漏れ修正

## TL;DR（人間向け）

番号なしの通常カードが生成時に落ちる不具合を直し、実ファイル集合との照合を追加した記録。GOALだけを除外する読込みと欠落検知をAstraが受入し、現配置の同期・検査を独立実行した。隔離試験の結果は姫の保存証拠に依拠し、Safari表示や別件のゲート接続方式まで確認済みとはしない。

2026-10-18 / OPS-080 / Astra. Parent OPS-048. Implementation and verification requested of Hime; accepted by Astra. Based on the user's 「コミットして、その修正依頼しよう」.

<a id="入力確認済み"></a>
## Input and confirmed facts

The input is OPS-079's acceptance commit b07c1b8e (the full SHA is recorded at the start). See [OPS-079](REGISTRY_STUDIO_MULTIPLE_MILESTONES.md) and [the reproduction evidence](Evidence/OPS-079/generator_unnumbered.txt). sync.py's read_gates selects only numbered or GATE-form files and silently drops ordinary cards such as EXTRA.md. A verify that looks only at generated data cannot detect this loss.

In [the user specification](../Milestones/DESIGN.md), the intermediate cards in a version folder are in file-name order. Numbers are recommended, not required. GOAL.md is an ornament and is ignored. Do not extend this exception to ordinary cards.

<a id="依頼範囲"></a>
## Requested scope

- Fix sync.py's card selection to read ordinary Markdown cards except GOAL.md. Keep the existing validity checks of card information, IDs, canonical and so on, and do not silently ignore invalid cards.
- In verify or the like, check the correspondence between the actual file set and the generated cards. Do not build the expected set from the generated result alone; detect missed unnumbered cards. Distinguish the virtual START/END and the GOAL exclusion.
- Update the verification explanation in the README, the Return of this document, and the needed Evidence/OPS-080/.

Editable: RegistryApp/sync.py, verify.cjs, the needed limited verification code, README, the Return of this document, and Evidence/OPS-080/. Updating the generated cache is allowed. Out of scope: the product, each DESIGN document, the bodies/placement/IDs of real milestones, the Registry, screen design, the method of inter-version gate names and connection targets, and other matters such as the hard-coded 18. If an out-of-scope fix is needed, return the facts and reasons and stop.

<a id="検証完了条件"></a>
## Verification and completion conditions

1. In an isolated environment, reproduce the pre-fix behaviour in which EXTRA.md disappears; after the fix, the same ID is included in the name-order chain.
2. Check 0, 1 and several cards, a mix of numbered and unnumbered, order changes by file renames, and IDs other than MS.
3. GOAL.md is not generated even if it has card information. Invalid information in an ordinary card becomes an explicit error.
4. The check rejects the case where a real file exists but the generated card is missing. Keep OPS-079's checks rejecting adjacency gaps, reversed order and extra direct links.
5. sync/verify and --check succeed with the current placement. Leave no test diffs in the real placement. State it if Safari was not done.

Record the temporary environment at creation per COMMONS, and after saving evidence clean up only your own work items. The Return contains the full input SHA, changes, reproduction method, run results, limits and cleanup. Shape the fix, evidence and records so they can be reviewed together. Commit and external operations are not permitted.

With the request complete, the output scope above is handed to Hime, and Astra does not edit it until the return.

## Return（姫記入）

2026-10-18 / 姫・Opus 5.5。入力`a788adcc4f8c66c02af5c46fffd0180ed30c8e16`（OPS-079受入`b07c1b8e`の後、ユーザーの`USER_PENDING_TASKS.md` commitのみ）。作業ツリーにある未commitのAstra分（`CLAUDE_TASK.md`・Registry・Rules・`TASK_REGISTRY_APP.md`・本書）は触っていない（本書はReturnのみ）。

**一時環境**：入力commitのgit worktreeを`mktemp -d`配下に作成した。場所は作業中`Evidence/OPS-080/.wt_path_tmp`に記録し、終了時に`git worktree remove`で削除、記録ファイルも消した。実配置のMilestonesには触れていない（`git status`で差分なし）。

**修正前の再現**：worktreeの`0.6.0/`に、`10_SPI.md`を写した番号なしの`EXTRA.md`（ID `X-EXTRA`）を置いてsyncした。syncは成功し、`X-EXTRA`は生成されず、鎖は`START→MS-SPI→END`のままだった（`before_fix_unnumbered.txt`）。

**変更**：
1. `sync.py`のカード選択：`GOAL.md`だけを除外し（DESIGN「GOALファイル」）、それ以外の`*.md`をすべて読む。`GATE-`で始まるのに`GATE-x.y.z.md`の形でないファイルは、黙って捨てずに明示エラーにした。ID・名前・状態（中間カードは`- [ ] DONE`）・正本などの既存の妥当性検査はそのまま。エラー文の「NN_ gates」は「intermediate cards」に直した。
2. `verify.cjs`：`milestoneListing()`がファイルシステムから版フォルダ（`_`始まりを除く）の`*.md`一覧を読む。`milestoneFileErrors()`はそれを生成カードと突き合わせ、次の3つを拒む。
   - `GOAL.md`以外のファイルに対応するカードがない（not generated）
   - ファイルのないカード（no file）
   - `GOAL.md`がカードになっている

   期待集合は生成データから作らない。仮想START/ENDは`virtual`で除外する。現配置の検査と隔離fixture（合格1件、拒否3件）を足した。OPS-079の鎖の検査（欠落・逆順・余分な直結の拒否）はそのまま。
3. `README.md`の検証説明に一文を足した。

**実行結果**（`Evidence/OPS-080/`）：
- 旧sync＋新verify：`not generated: …/0.6.0/EXTRA.md`で失敗。新しい検査が読み落としを検出する（`detect_old_generator.txt`）。
- 修正後、`EXTRA.md`あり：成功、鎖は`START→MS-SPI→X-EXTRA→END`（`after_fix_unnumbered.txt`）。
- `10_SPI.md`→`Z_SPI.md`へ改名（IDは同じ）：`START→X-EXTRA→MS-SPI→END`に並び替わった（`after_fix_rename.txt`）。
- IDのない`BAD.md`：`カード情報 needs ## ID…`のエラーでsyncがexit 1（`invalid_card.txt`）。
- 0枚（0.5.4、`GOAL.md`だけの1.0.0）と1枚は現配置で、複数枚・番号の混在・MS以外のIDはOPS-079のfixtureと上の再現で確かめた。
- 現配置：sync成功、`--check`でずれなし、`1.0.0/GOAL.md`は従来どおり生成対象外。
- PASS行は23→24（ファイル照合の1行が増えた。旧verifyも同じ配置で23行）。
- Safariは未確認。

**限界**：`verify.cjs`は自分の置き場所からMilestonesを読むので、生成後にファイルを動かしてsyncせずにverifyだけを再実行すると、ずれとして落ちる（意図どおり）。`GATE-`形式のファイルとゲートの接続方式は対象外のまま。161行の「保護18件」の決め打ちも対象外のまま。

**片付け**：一時worktree・記録ファイル・PASS比較用の一時コピーはすべて削除済み。

commitはしていない。

<a id="astra受入2026-10-18"></a>
## Astra acceptance (2026-10-18)

Checked the sync.py and verify.cjs diffs against input a788adcc4f8c66c02af5c46fffd0180ed30c8e16 and the saved evidence, and accepted. Confirmed card reading that excludes only GOAL.md, and loss detection that uses the file set as an independent input. Independently ran sync/verify with the current placement: 24 PASS, missing: none, --check no drift. The isolated-environment results for unnumbered cards, renames, invalid cards and rejection of the old generator were received as Hime's saved evidence; the accepting side did not re-run them in isolation. The real display in Safari is unconfirmed.

The requested scope is complete and OPS-080 is DONE. Completion of other matters such as the inter-version gate connection method or the fixed count of placement protections is not included. The user explicitly permitted this acceptance and commit.
