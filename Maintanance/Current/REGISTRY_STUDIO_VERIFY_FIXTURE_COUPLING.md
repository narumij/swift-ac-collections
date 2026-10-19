# Registry Studio：到達点ファイルを版フォルダ間で入れ替えると更新が失敗する（OPS-078）

## TL;DR（人間向け）

到達点カードを版フォルダ間で入れ替えると同期検査が失敗する問題の修正記録。原因は固定配置に依存した2検査で、変更と現行入替配置での同期成功をAstraが限定受入した。同版の複数カード鎖や名前・IDへの依存、配置維持件数の固定は残り、Safari表示も未確認。

2026-10-18 / Registration/assignment: Fable (deputy, OPS-044; user instruction 「タスク化して、姫に依頼しておいて」). Investigation/fix/tests: 姫. Acceptance: Astra (Fable handles return comparison and Registry reflection only). Parent permanent task OPS-048 (Studio). Status is canonical in Task Registry.

<a id="発端ユーザー報告user_pending_tasksmd-20261018-0217スタジオバグ"></a>
## Trigger (user report in `USER_PENDING_TASKS.md`, 2026/10/18-02:17 「スタジオバグ」)

**Precondition:** Studio server running with browser open; Milestones at `97e5d4ecb907cb5a2a3cd4056e9f3c8604a8c531`.

**Steps:** swap `0.6.0/10_VALIDATION_REVIEW.md` and `0.7.0/10_SPI.md`, then press refresh.

**Expected:** updated ordering appears in the diagram.

**Observed:** order unchanged, 「更新できませんでした」. Full original log is in `USER_PENDING_TASKS.md`. After sync diff output, verify.cjs fails an assertion at `verify.cjs:15`, restoring `registry.json` and `index.html`; it also reports `Bundled 90 documents; missing: Maintanance/Milestones/0.6.0/10_VALIDATION_REVIEW.md, Maintanance/Milestones/0.7.0/10_SPI.md`.

**Frequency:** 4/4.

<a id="依頼姫へ"></a>
## Assignment to 姫

**Purpose:** swapping milestone files between version folders must not stop sync and must change diagram order; reverting must work too. `Milestones/DESIGN.md` permits these moves.

**Work:** identify/fix cause and check swap → sync success/new order → restore → sync success. Always restore Milestones after the temporary test and verify no diff. Report `missing`-path origins too: fix RegistryApp defects; for stale document paths, return document/line only.

**Editable:** `Maintanance/RegistryApp/` except screen changes in `index.template.html`, `RegistryApp/README.md`, this final Return and `Maintanance/Current/Evidence/OPS-078/` evidence. Sync may update `Cache/RegistryStudio/`.

**Excluded:** UI, Registry rows, permanent Milestones placement, Milestones/DESIGN, product code and commit.

**Stop:** if UI/Registry structural changes are needed, return location/reason. If exploration exceeds estimate, follow COMMONS 「探索の打ち切り」 with checked scope.

**Completion:** sync succeeds at HEAD, swapped and restored arrangements, new column order is generated, no Milestones diff; PASS count not reduced without reason; cause/fix and missing-path diagnosis reported; Return written.

**Acceptance:** Astra samples evidence; Fable only compares return and reflects Registry. Commit requires separate user instruction.

## Return（姫記入）

2026-10-18 / 姫・Opus 5.5。入力HEAD`1e468aa3f`。作業ツリーの未commit分（Astra・Fableの`CLAUDE_TASK.md`・Registry・Rules・本書）には触れていない。

**再現**：報告どおり`0.6.0/10_VALIDATION_REVIEW.md`と`0.7.0/10_SPI.md`を入れ替えて`sync.py`を実行し、`verify.cjs:15`のassertionで失敗、`registry.json`・`index.html`が復元されることを確認した（1/1）。

**原因**：生成器（`sync.py`）は正しく動いていた。入れ替え後の生成データでは`START-0.6.0→MS-SPI→END-0.6.0`、`START-0.7.0→MS-VALIDATION→END-0.7.0`と新しい並びになっていた。落ちたのは`verify.cjs`で、今のカード配置を決め打ちした検査が2か所あった。

1. 15行：`MS-VALIDATION→END-0.6.0`の接続がある、という検査。
2. 102行（OPS-069の検査）：`GATE-0.6.0→MS-VALIDATION`の線がSTART-0.6.0の代わりに引かれる、という検査。

1を直すと2で落ちた。どちらも、Milestones仕様で正当な「カードを版フォルダ間で動かす」操作を拒む形だった。

**直した箇所**（`verify.cjs`の2文だけ。画面・生成器・Registryは変えていない）：

1. 15行：版フォルダのカード（`gate`が`Milestones/<版>/<番号>_*.md`の到達点）をすべて取り出し、それぞれについて`START-<版>→カード`と`カード→END-<版>`の接続があることを確かめる。版はカードの置き場所から求める。カードが1枚以上あることも確かめる。
2. 102行：ゲートの後ろに隠れるSTART（`GATE→START`の関係を持つもの）から最初のカードへの接続をすべて取り出し、それぞれが「ゲート→カード、`shownFrom`=START」で描かれることを確かめる。

`README.md`の「検証範囲」に一文を足した。

**検証**：
- 入れ替えた配置：`sync.py`成功。生成された列は上の新しい並び。
- 元に戻した配置：`sync.py`成功、`missing: none`。
- `git status`でMilestonesに差分なし。
- verifyのPASS行は22行のまま（HEADの旧`verify.cjs`も同じ配置で22行。一時コピーで数え、コピーは削除済み）。
- 検査の中身は狭めていない。決め打ちの1件を、すべてのカードについての検査に広げた。
- Safariでの見え方は確かめていない（並びは生成データで確認）。

**missingの出どころ**：RegistryApp側の不具合ではなく、文書側の古いパスだった。入れ替えると、Registryの行が正本欄に持つカードのパスが古くなる。

- `TASK_REGISTRY_V2.md` 38行（DOC-036）：`Maintanance/Milestones/0.6.0/10_VALIDATION_REVIEW.md`
- 52行（DOC-026）・53行（DOC-027）：`Maintanance/Milestones/0.7.0/10_SPI.md`

内蔵文書の生成はこれを警告として出すだけで、syncは止めない。実際にカードを動かすときは、この3行のパスも直す必要がある（Registryの行は本依頼の対象外なので触っていない）。

**同じ形の残り（直していない、一行報告）**：`verify.cjs` 161行に`protectionRecords(original).length,18`という件数の決め打ちがある。配置維持の指定が増減すると、同じように同期が止まる。本依頼の範囲（カードの配置）の外なので、候補として返す。

commitはしていない。

<a id="astra受入2026-10-18"></a>
## Astra acceptance (2026-10-18)

Compared fix commit efc3868a86355991c766f02f0e04cb324f52e61e. Preserved the user's current swapped placement, updated DOC-036/026/027 canonical paths and independently ran sync.py: 22 PASS, missing: none. Received 姫's result for original placement without reversing user placement to retest. Safari unverified.

Accepted this two-card-swap fix as DONE. The Return's 「すべてのカードについての検査」 statement is limited to current data: new checks require direct START→card→END links for each card, not general name-ordered multi-card chains. Numeric-underscore filenames/MS prefixes remain dependencies. Keep these and fixed protection-count 18 as OPS-048 maintenance candidates; do not certify elimination of all fixed-data dependencies.

The 「配置を元へ戻す」 condition applied to 姫's temporary test; current user placement and commit instruction are separate.
