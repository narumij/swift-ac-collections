# 同版の複数中間マイルストーンを扱う検査の修正

## TL;DR（人間向け）

同版の中間カードを各々STARTとENDへ直結させる誤った検査を、ファイル名順の鎖を検証する形へ修正して受け入れた記録。ユーザーの最新DESIGNに従いGOAL.mdは置物として除外する。この受入時点では番号なし通常カードの生成器による取りこぼしは残り、今回の検査修正を仕様全体への適合完了とはしない。

2026-10-18 / OPS-079 / written by Astra. Parent OPS-048. Implementation and verification: Hime; acceptance: Astra. Based on the user's 「複数対応をあるべき姿にして、未対応なら姫へバグ修正依頼」.

<a id="確認済みと正しい構造"></a>
## Confirmed facts and the correct structure

Input commit 5c274e38 (the full SHA is resolved and recorded at the start). The current version folders have one intermediate card each, and 0.5.4 has none. 0.7.0/GATE-0.8.0.md has history that merged the old MS-080, but restoring it, giving a new ID or changing the version plan is not done this time.

According to the user-written [structure specification](../Milestones/DESIGN.md), the intermediate cards of the same version form a chain in file-name order. 0 cards: START → END; 1 card: START → A → END; several: START → A → B → … → END. The file name is the order and the internal ID is the identifier; do not order by ID. Numbered file names are recommended, not required.

Static check: the cards loop in verify.cjs updated in efc3868a8 requires START → card and card → END for every card with a number-underscore name. This is incompatible with the correct chain of several cards. The generator add_ends lines up START, the intermediate cards and END. This time Astra did not dynamically reproduce the several-card case.

<a id="姫への依頼編集範囲"></a>
## Request to Hime and editing scope

Fix the relevant check in verify.cjs into a check that derives the expected adjacency from the actual file order in the version folder and the internal IDs. If defects in the generator's or drawing's handling of several cards also turn up, return that fact (do not expand into screen design on your own). Use independent expected values; do not check the generated edges using themselves as expected values. Also check the display from START, hidden by the gate, to the first card. Do not limit the check targets to the MS prefix or number-underscore names.

Editable: RegistryApp/verify.cjs, the needed limited fixtures and verification code, the relevant verification explanation in the README, the Return of this document, and Evidence/OPS-079/. Temporary fixtures follow COMMONS' recording and cleanup procedure. Do not change the user's existing placement or text. Work in isolated fixtures or copies, and do not leave fictitious cards in the real placement.

Out of scope: each DESIGN.md, the product, the Registry, adding/moving/renaming real milestones or changing plans, reworking the inter-version gate connection method, and other check problems such as the hard-coded 18. Return the location and reproduction of out-of-scope defects and stop.

<a id="検証完了条件"></a>
## Verification and completion conditions

- Reproduce, before the fix, that a correct chain of two or more cards fails the check, and save the error.
- Confirm correct connections for 0, 1 and 2+ cards in the same version and for a change of name order (keeping IDs). Also handle unnumbered intermediate files and IDs other than MS.
- Confirm the check rejects missing edges, reversed order and extra direct links; do not respond by merely deleting the check.
- sync, verify and --check succeed with the current placement. Leave no diff in the user's placement. State it if Safari was not done.
- Put the full input SHA, reproduction conditions, changes, run results, unconfirmed items, remaining issues and cleanup of work items in the Return. Shape the change as a functional fix plus evidence and records. Commit permission is not included this time.

With the request complete, the output scope above is handed to Hime, and Astra does not edit it until the return. The purpose this time is conformance to the specification for several cards, not a redesign of the whole Registry.

## Return（姫記入）

2026-10-18 / 姫・Opus 5.5。入力`037a3b0645d32e76cebf8166278a316efb45ea24`（依頼の入力`5c274e38`の後、OPS-079登録commitのみ）。作業ツリーの`USER_PENDING_TASKS.md`（ユーザーの変更）には触れていない。

**再現（修正前）**：隔離したgit worktree（入力commit、一時ディレクトリ）の`0.6.0/`に、`10_SPI.md`を写した2枚目`20_EXTRA.md`（ID `MS-EXTRA`）を置いてsyncした。生成器は`START-0.6.0→MS-SPI→MS-EXTRA→END-0.6.0`と正しい鎖を作ったが、`verify.cjs:15`の「MS-SPI ends at END-0.6.0」で失敗し、生成物が復元された。ログは`Evidence/OPS-079/before_fix_two_cards.log`。原因は、私がOPS-078で入れた「各カードにSTART→カードとカード→ENDを要求する」検査（カード1枚の前提）。

**変更**（`verify.cjs`と`README.md`だけ）：

1. `expectedMilestoneChains(data)`：生成された接続を見ずに期待値を作る。カードの集合（`milestones`の`gate`）とファイル名順から、版ごとに`START → 中間カード（ファイル名順）→ END`を作る。番号の接頭辞もMS接頭辞も前提にしない。版は仮想STARTから取るので、カード0枚の版も入る。
2. `milestoneChainErrors(data)`：期待する隣接がすべてあることを確かめる（欠落）。鎖の中のノード同士に、隣でない接続（逆順・飛ばし・START→ENDの直結）がないことも確かめる。
3. 15行の旧検査を`milestoneChainErrors(original)`が空であることの検査に置き換えた。
4. 102行のゲート表示検査：最初のカードを期待の鎖の2番目から取る（MS接頭辞や生成された接続に頼らない）。カード0枚の版はENDが描かれないので対象外。
5. 隔離fixture（verify内の合成データ、版`9.9.9`）で次を確かめた。
   - 通るもの：0枚、1枚、4枚（番号なしの`GOAL.md`、ID `GOAL-X`・`Q-1`を含む）、改名で並びが変わった場合（IDは同じ）。
   - 拒むもの：改名前の並びのままの接続、欠落、逆順、START→ENDの直結、カードを飛ばすSTART→2枚目。
6. READMEの検証説明に一文を足した。

**実行結果**：
- 現配置：`sync.py`成功、`--check`でずれなし。
- PASS行は22→23（fixtureの1行が増えた。旧verifyも同じ配置で22行。一時コピーで数え、削除済み）。
- 隔離worktreeで新しいverifyを使い、次の3つを確かめた（`Evidence/OPS-079/`）。
  - 2枚：成功、鎖は上のとおり。
  - `10_SPI.md`→`30_SPI.md`へ改名：成功、`START→MS-EXTRA→MS-SPI→END`へ並び替わった。
  - 2枚目を番号なしの`EXTRA.md`にした場合：後述。
- 実配置のMilestonesは触っていない（`git status`で差分なし）。
- worktreeは`git worktree remove`で削除した。
- Safariは未確認。

**生成器の不具合（範囲外、直していない）**：`sync.py` 155行は`\d+_.+\.md|GATE-…`に合うファイルだけをカードとして読み、それ以外を「GOAL.mdなどは無視」として飛ばす。DESIGN（Milestones/DESIGN.md 44・53行）では、ゲート以外のファイルはすべて中間マイルストーンで、番号は推奨にすぎない。

- 再現：worktreeで2枚目を`EXTRA.md`に改名すると、`MS-EXTRA`が生成データから消え、syncは成功してしまう（`generator_unnumbered.txt`）。
- 現配置でも`1.0.0/GOAL.md`はカード情報（ID付き）を持つが、生成されていない。
- verifyは生成されたカードの集合から期待値を作るため、この取りこぼしは検出しない。ファイル一覧からの検査を足すと、今の`GOAL.md`で落ちる。
- 直すには`sync.py`のカード選択の変更が要り、本依頼の編集範囲外。`GOAL.md`をカードとして扱うかどうか（1.0.0の版計画）も、ユーザーの判断に関わる。

**残課題**：上の生成器の件。161行の「保護18件」の決め打ちは対象外のまま。

**作業物**：一時worktreeと一時コピーは削除済み。`/private/tmp/swift-ac-test-count.*`のprunableなworktreeが一覧に出るが、私のものではないので触っていない。

commitはしていない。

<a id="astra受入2026-10-18"></a>
## Astra acceptance (2026-10-18)

Checked Hime's verify.cjs diff and the 4 pieces of evidence. Accepted the change that builds the expected adjacency independently from the name order of the generated cards and checks 0, 1 and several cards, reordering, and invalid edges. Independently ran sync/verify with the current placement: 23 PASS, missing: none, --check no drift. The reproduction in the isolated worktree was received as saved evidence and not re-run by the accepting side. Safari unconfirmed.

The latest user-edited DESIGN added 「GOAL.mdは置物として無視」 (ignore GOAL.md as an ornament). DESIGN itself is not changed; at acceptance Astra excluded GOAL.md from verify's expected values and added a fixture for that exclusion. The fixture name of the unnumbered card was corrected from GOAL.md to EXTRA.md. Hime's original Return is kept as a return made under the old specification. Not generating GOAL is not a defect, and no version-plan decision is needed.

OPS-079 is DONE as a check fix within the requested scope. The generator's dropping of the unnumbered ordinary card EXTRA.md remains. Fixing it needs a separate delegated scope, so it is recorded as the next fix candidate of OPS-048, and this is not treated as completing conformance to the whole specification. The limit that cards the generator missed are also absent from the current verify's input and cannot be detected is kept. The real milestone placement was not changed.
