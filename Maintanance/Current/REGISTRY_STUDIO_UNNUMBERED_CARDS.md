# 番号なし通常カードの生成漏れ修正

2026-10-18 / OPS-080 / Astra。親OPS-048。姫へ実装・検証を依頼、Astraが受入。ユーザー「コミットして、その修正依頼しよう」に基づく。

## 入力・確認済み

入力はOPS-079受入commit b07c1b8e（着手時に完全SHAを記録）。[OPS-079](REGISTRY_STUDIO_MULTIPLE_MILESTONES.md)と[再現証拠](Evidence/OPS-079/generator_unnumbered.txt)を参照。sync.pyのread_gatesは番号付きまたはGATE形式のファイルだけを選択し、EXTRA.mdのような通常カードを黙って落とす。生成データだけを見るverifyではこの欠落を検知できない。

[ユーザー仕様](../Milestones/DESIGN.md)では、版フォルダ内の中間カードはファイル名順。番号は推奨であって必須ではない。GOAL.mdは置物であり無視する。この例外を通常カードへ広げない。

## 依頼範囲

- sync.pyのカード選択を修正し、GOAL.mdを除いた通常のMarkdownカードを読み取る。既存のカード情報・ID・正本等の妥当性検査を維持し、不正カードを黙って無視しない。
- verify等で実ファイル集合と生成カードの対応を照合する。生成結果だけから期待集合を作らず、番号なしカードの読み落としを検出する。仮想START/ENDとGOAL除外を区別する。
- READMEの検証説明、本書Return、必要なEvidence/OPS-080/を更新する。

編集可：RegistryApp/sync.py、verify.cjs、必要な限定検証コード、README、本書Return、Evidence/OPS-080/。生成キャッシュの更新可。製品、DESIGN各書、実マイルストーンの本文・配置・ID、Registry、画面設計、版間ゲート名と接続先の方式、18件固定など別件は対象外。範囲外の修正が必要なら事実と理由を返して止める。

## 検証・完了条件

1. 隔離環境でEXTRA.mdが消える修正前挙動を再現し、修正後は同じIDが名前順の鎖へ含まれること。
2. 0・1・複数枚、番号付きと番号なしの混在、ファイル名変更による順序変更、MS以外のIDを確認する。
3. GOAL.mdはカード情報を持っていても生成対象外。通常カードの不正情報は明示エラーになること。
4. 実ファイルがあるのに生成カードが欠けるケースを検査が拒むこと。OPS-079の隣接・逆順・余分な直結の拒否検査も維持。
5. 現配置でsync/verifyと--checkが成功。実配置に試験用差分を残さない。Safari未実施なら明記。

一時環境はCOMMONSに従って作成時に記録し、証拠保存後に自分の作業物だけを片付ける。Returnには入力完全SHA、変更、再現方法、実行結果、限界と片付けを記載。修正と証拠・記録をまとめてレビューできる形にする。commitと外部操作の許可は含めない。

依頼完成で上記出力範囲を姫へ受渡し、Astraは返却まで編集しない。

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

## Astra受入（2026-10-18）

入力a788adcc4f8c66c02af5c46fffd0180ed30c8e16に対するsync.py・verify.cjs差分と保存証拠を照合し受入。GOAL.mdのみを除外したカード読込みと、ファイル集合を独立入力とする欠落検知を確認。現配置でsync/verifyを独立実行し24 PASS、missing: none、--checkずれなし。隔離環境の番号なし・改名・不正カード・旧生成器の拒否は姫の保存証拠を受領し、受入側での隔離再実行はしていない。Safari実表示は未確認。

依頼範囲を完了しOPS-080をDONEとする。版間ゲート接続方式・配置維持件数固定など別件の対応完了は含まない。ユーザーから今回の受入とcommitを明示許可された。
