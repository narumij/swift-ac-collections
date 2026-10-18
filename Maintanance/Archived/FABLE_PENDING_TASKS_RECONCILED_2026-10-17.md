# 照合済みqueue原文：FP-20261017-001・002（2026-10-17圧縮）

2026-10-17 / Fable（調整代理、OPS-044）。元：`Maintanance/FABLE_PENDING_TASKS.md`の「採番待ち」節。移動時点の履歴であり現行指示ではない。FP-001はOPS-048、FP-002はOPS-044（管理補助、CP-005→OPS-048・CP-006→QUALITY-002の案）へAstraが統合済み。相対リンクは移動先から同じ資料を指すように直した。本文は逐語。

### `FP-20261017-001` — Registry Studio：Fableの採番待ちqueueも表示する

- queue状態: `RECONCILED`（2026-10-17 Astra。以下の括弧は返却当時の状態）（実施済み・未commit。Studio（OPS-048）はAstraの道具なので受入が要る）
- 発見元・ユーザー指示: 2026-10-17、ユーザー「これ（RegistryApp）に、姫の採番まちはあるけど、ふぁぶるさんの採番まちがまだみれないから、みれるようにしてくれる？それ自体を採番待ちに記載して、動作みてほしい」。
- 種別候補: `EXECUTION`
- 実施:
  - `build-pending.py`：読むqueueを先頭の`queues`一覧（path・持ち主・仮ID接頭辞）にし、`CLAUDE_PENDING_TASKS.md`（CP-）と`FABLE_PENDING_TASKS.md`（FP-）の両方から未処理entryを集める。存在しないfileは飛ばす。seedに`sources`（file毎のpathとsha256）と各entryの`source`・`owner`を足した。従来の`source`文字列は両pathの連結で残した。
  - `index.html`の`renderPending`：カードの小文字にqueue状態に続けて持ち主を表示。原文を開くときのstampはそのentryのfileを出す。下部のstampは全queueを並べる。
  - `README.md`「採番待ちの表示」を両queue対応に更新。
- 対象外: `sync.py`・`verify.cjs`・`registry.json`の構造、queue本文の整形規則。
- 検証: `sync.py`完了・verify.cjs pass（`PATH`にnodeが無いため、`--node`・`--marked`にCodex実行環境`~/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/`配下のnode v24.19.0とmarkedを指定）。生成seedは姫5件（CP-013・005〜008）＋Fable 1件（FP-001）、全entryに整形済みHTMLあり。`renderPending`をstub DOMで実行し、6枚のカード・持ち主表示・FP-001クリックで`FABLE_PENDING_TASKS.md`を出典に原文が開くことを確認。`registry.json`の差分は`source.head`（HEAD 93fd0204への追随）と生成時刻だけ。画面の実表示はユーザーのSafariで確認待ち。
- commit: していない。
- Codex reconciliation: 未処理
- Astra reconciliation（2026-10-17、最新）: OPS-048へ統合。5ea16511の差分・seed照合とverify成功。Safari実操作は未確認。 原返却のcommit記述は当時の記録として保持。

### `FP-20261017-002` — 残りの採番待ち（CP-005・CP-006）の照合案

- queue状態: `RECONCILED`（2026-10-17 Astra。以下は返却時の注記）（照合案のみ。Registry・両queue・正本は未編集）
- 発見元・ユーザー指示: 2026-10-17、ユーザー「のこりの採番待ちもしょりして」。OPS-044管理試験（`Current/FABLE_MANAGEMENT_TRIAL.md`、Astra受入`318d78f4`）と同じ形式で、Fableが案を作りAstraが受入・反映する。試験の受入は「Registry直接編集まで認定しない」なので、Fableは案にとどめる。
- 種別候補: `EXECUTION`（管理補助）
- 対象: `CLAUDE_PENDING_TASKS.md`の`CP-20261017-005`・`CP-20261017-006`。対象外: `CP-20261016-013`（OPS-059としてFROZEN登録済み。再開・受入はユーザー指示が要るため触れない）。
- 照合時点: HEAD `318d78f4`。作業ツリーに`RegistryApp/index.html`・`registry.json`の未commit再生成（seed head 318d78f4、13:45生成、Fable以外の実行）と`User/MEMO.md`あり。Fableは触っていない。

#### CP-20261017-005 — Studio：DONEのtaskがあると作り直しが止まる不具合

- 事実: 作成者は姫。commit `4163ff4e`（10-17 04:37「docs: sort Studio regular list by state and allow DONE tasks before compression」、`index.html`・`verify.cjs`・`registry.json`・queue）。本文の「未commit」は当時の記録で、現在は古い。`verify.cjs`144行目にユーザー判断「DONE tasks may stay in the Registry until compression; compression is not immediate (2026-10-17 user)」がコメントとして残る。
- 重複・衝突: Rules43行目のDONE定義・`TASK_REGISTRY_ARCHIVE.md`と矛盾しない（即時圧縮を求める規則はない）。`FP-20261017-001`（`5ea16511`）とは変更箇所が別で、`5ea16511`は`4163ff4e`を含むHEADでverify pass。`TASK_REGISTRY_APP.md`・`RegistryApp/README.md`にこの修正の記録はない。
- 統合先: 既存`OPS-048`。新規採番不要。
- 提案編集:
  1. `Current/TASK_REGISTRY_APP.md`末尾に節追加: `## DONE混在時の再生成修正（2026-10-17）` 本文「CP-20261017-005（姫）をOPS-048へ統合。独立タスクの状態順の並べ替えを`independentGroups`内へ移し、`verify.cjs`の「RegistryにDONEを残さない」検査を外した（ユーザー「タスク圧縮はすぐはしないから」）。commit `4163ff4e`。」
  2. `CLAUDE_PENDING_TASKS.md`の同entry: `queue状態: `AWAITING_COORDINATOR`（実施済み・未commit。OPS-048）` → `queue状態: `RECONCILED`（2026-10-17 Astra、OPS-048へ統合。括弧内は返却当時）（実施済み・未commit。OPS-048）`、`Codex reconciliation: 未処理` の下に `- Astra reconciliation（2026-10-17）: OPS-048へ統合。commit `4532e9df`の検査撤回を含む。実装commitは`4163ff4e`。` を追加（原文は保持）。
- ユーザー判断待ち: なし。任意: 「DONEはしばらく残す」の判断をRulesか`TASK_REGISTRY_ARCHIVE.md`に一文置くか（今はqueueとコードのコメントだけ）。

#### CP-20261017-006 — 候補CIにLinuxのASan＋death test jobを追加

- 事実: 作成者は姫。実装commit `8631a031`（10-17 04:37、`.github/workflows/candidate.yml` +43/−2）、CI通過の記録commit `eb52378c`（04:44）。HEADの`candidate.yml`に`address-sanitizer-death-tests` job（126行目〜、`--sanitize address`、`report`のneedsと一覧に登録）が残っている。CI成功はユーザー報告のみで、run URL・対象commitは未記録。本文の「commit: `8631a031`」は正しいが状態欄の「未commit」は古い。
- Registry: 直接の受け皿はない。`RBT-049`（DONE、「Linux・CI・リリース可否は未検証」）、`QUALITY-002`（ACTIVE、Codex、1.0品質保証CIの構成・証拠化、「今回CI変更・起動は行わず」）、`RELEASE-085`（PROPOSED、候補CI立て直し範囲のユーザー判断）。`Current/RELEASE_CI_RECOVERY.md`13行目「ASanのRBT-049も自動的に混ぜない」。
- 重複・衝突: 本jobはユーザーの明示依頼で入ったので規則違反ではないが、立て直し（RELEASE-085）が未決のまま候補CIの構成が1 job増えた点は、RELEASE-085の範囲決定時に扱う必要がある。`RBT-049`の「Linux未検証」は、本jobの成功で「Linuxでは`strip_env`相当の対処なしで成立」という新事実が出た（ただしrun URL未保存、Astra未確認）。重複する既存entryやtaskはない。
- 統合先（案）: 既存`QUALITY-002`へ「Linux代表環境でのASan＋death test証拠」として統合。`RBT-049`正本へは相互参照だけ。新規採番は不要（受入時にAstraが`RELEASE-085`側で扱うと判断するなら、そちらでも可）。
- 提案編集:
  1. `TASK_REGISTRY_V2.md`の`QUALITY-002`行、説明末尾に追記: 「2026-10-17、ユーザー依頼で候補workflowにLinux ASan＋death test jobを追加（`8631a031`、CP-20261017-006）。成功はユーザー報告、run URL未保存。恒久採用は未決。」
  2. `Current/ASAN_STRIP_ENV_FIXED_REVISION_VALIDATION.md`末尾に節追加: `## Linux候補CIでの後続（2026-10-17 / Astra）` 本文「CP-20261017-006により`candidate.yml`へASan death test jobを追加し、ubuntu-24.04で成功（ユーザー報告、`8631a031`・`eb52378c`）。本taskの結論（macOS DYLD経路のstrip_env）とは独立で、Linuxでは対処不要と整合。本taskのDONE範囲は変更しない。」
  3. `Current/RELEASE_CI_RECOVERY.md`の13行目の段落末尾に一文: 「2026-10-17時点で候補workflowには`address-sanitizer-death-tests` jobが入っている（CP-20261017-006）。立て直し範囲の決定時に残す・外すを明示する。」
  4. `CLAUDE_PENDING_TASKS.md`の同entry: `queue状態: `AWAITING_COORDINATOR`（実施済み・未commit。…）` → `queue状態: `RECONCILED`（2026-10-17 Astra、QUALITY-002へ証拠として統合。括弧内は返却当時）（…）`、`Codex reconciliation: 未処理` の下に `- Astra reconciliation（2026-10-17）: QUALITY-002へ統合、RBT-049正本・RELEASE_CI_RECOVERYへ参照追記。CI成功のrun URLは未保存。` を追加。
- ユーザー判断待ち: (a) 候補CIにこのjobを恒久的に残すか（RELEASE-085の範囲）。(b) 成功runのURLか対象commitを記録するか（GitHub側はユーザーの領分。残すなら本entryへ一行）。
- 範囲外所見: なし。

- 成果・検証: 本entryのみ。commit hash・行番号は`git show --stat`・`grep -n`で確認した。Studio再生成・commitはしていない。
- commit: していない。
- Codex reconciliation: 未処理
- Astra reconciliation（2026-10-17、最新）: OPS-044の管理補助として受入、CP-005/006を既存OPS-048/QUALITY-002へ統合。ASan恒久採用の再判断とrun保存をユーザー専任とする提案は不採用。既存の明示依頼を維持し、run証拠の照合はQUALITY-002へ残す。


<!-- 2026-10-18ユーザー指示による状態名の一括統一。過去の引用中も現在の表記に正規化した。内容・当時の担当・処理結果は変更していない。変更前の表記はGit履歴で参照できる。 -->
