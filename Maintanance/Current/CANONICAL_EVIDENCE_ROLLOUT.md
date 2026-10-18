# 根拠と更新条件の追記の全体展開

## TL;DR（人間向け）

現行正本への浅い根拠・更新条件の追記を段階的に適用し、初回77件を追記19件・既存追記・対象外・保留等へ対応付けた記録。その後、事実照合を越えた15記述を範囲限定・取り下げを含めて補正し、優先精査で受入した。初回整備は完了したが、全判断の有効性や現行版の再現成功を一括保証するものではない。

2026-10-17 / OPS-076 / Author Astra. Registered at user request 「全体展開タスク追加して」. Parent OPS-070, required OPS-074. After an explicitly directed advance trial, formally assigned round 2 below. State belongs to Registry.

<a id="目的と入力"></a>
## Purpose and inputs

Reduce repeated evidence searches to focus on substantive judgment. Use fixed-revision reproduction/acceptance of [OPS-074](CANONICAL_INVENTORY_APPEND.md) additional return to progressively append shallow facts/evidence/update triggers to current canonicals. OPS-074 completes/accepts method; this task applies it.

<a id="対象と手順"></a>
## Targets and procedure

First inventory current canonicals under Maintanance/Current, recording inclusion/exclusion/pending reasons. No unlimited history/repository expansion. Exclude user-finalized and concurrently owned areas. Check protection/ownership and assign bounded shallow checks; planned assignee 姫, acceptance Astra. No start before formal assignment.

- Prioritize facts affecting judgments; record complete SHA/path/revision lines/claim/method only where useful. No line range for existence facts lacking lines.
- Add review triggers/scope/unknowns for change-based rechecking; filling every field is not the objective.
- Uncommitted/environment/external results are not fixed by commit alone. Separate confirmed/discrepant/unverified.
- Preserve body/original returns; append at end with evidence. No shortening/deletion, invalidation of judgments/delegation, system adoption, deep behavioral validation or product/CI changes.
- Return decision points or excessive-cost checks with reasons/next inputs. Do not add obligations and burden through exploration/recording.

<a id="完了と評価"></a>
## Completion and evaluation

Each round returns input revision, targets, results, deferrals and remainder for Astra sampling. Complete when all candidates map to performed/excluded/pending with reasons and agreed scope accepted; no requirement to resolve all unknowns/rewrite every source.

Briefly record cases of avoided research and costly record creation/maintenance. Skipping essential judgment is not a benefit. No blanket system rollout or automatic other-agent starts.

## 第1区切り返却（2026-10-17 / 姫・Opus 5.5）

**着手の根拠**：Registryの依存は「OPS-074追加返却の固定版再現・受入後」だが、ユーザーが会話で先行着手を指示した（「ああ、遠慮してそうしたのかも。やって」）。ユーザー特権による先行で、依存の解除やOPS-074受入の代わりではない。入力版`876d405b981baae04dc0d90448094488524b3c79`。

**1. 候補一覧**：[CANDIDATES.md](Evidence/OPS-076/CANDIDATES.md)。その版の`Maintanance/Current/`直下77件を、Registryの行から参照されるtaskの状態で機械的に仕分けた（対象7、対象外28、保留42）。規則：関連taskがすべてDONE→対象、USER_ONLYや他担当の未完task→対象外、姫が関わる未完task→保留、Registryから参照なし→保留（中身を読んで判断する。今回は読んでいない）。

**2. 実施**：対象7件のうち1件、`RELEASE_CANDIDATE_BASELINE_FIX.md`（RELEASE-084 DONE）に「根拠と更新条件の追記」を末尾の新しい節で追加。結論「現行baselineでは旧例外修正が不要」が依存する3つの事実を、固定版のパス・行範囲・確認方法・更新条件で書いた。

**観察（効果の例）**：本文122行「0.5.4→HEADで`Benchmarks/`・`Sources/`の差分なし」は、`Benchmarks/`全体では今日の計測記録で古くなっていた。ただし差分は測定コードの外（`QualityAssessment/`）で、結論は変わらない。「事実が変わった」と「判断が変わる」を分けて書けた例。結論を揺らす更新条件は「新しい数値版tagを打ったとき」で、0.6.0を打つときにこの1行を見れば足りる。

**残り**：対象の残り6件、保留42件の中身確認。区切りごとに返す。

**未確認**：GitHub上のCI実走、保留42件の性質（運用文書が多いと見込むが未読）。正本本文・Registryは変更していない。

<a id="第1区切りのastra受入と補正2026-10-17"></a>
## Round 1 Astra acceptance/correction (2026-10-17)

Received advance execution under direct user request. Fixed 876d405b Current has 77 files; candidate table's 76 is a typo, adopt returned 77. Classification preliminary; DONE/owner alone do not establish editing authority. Not full completion.

Independently checked RELEASE-084 appendix workflow lines179〜195 and zero Benchmarks/Sources, Benchmarks/Libraries and Sources differences from baseline SHA to fixed input; accepted limited appendix. Tags are not fixed by commit tree; latest-tag conclusion depends on observed refs. Not 「tag更新だけ見れば足りる」: retain workflow/code triggers too. GitHub CI success unestablished.

<a id="姫への第2区切り依頼2026-10-17--astra"></a>
## Round 2 assignment to 姫 (2026-10-17 / Astra)

Based on user 「各種受け入れと姫へのアサイン」; OPS-074 accepted. Limit to remaining six: CANONICAL_CONFIRMED_SCOPE_SUMMARY.md, OPS_072_ACCEPTANCE.md, PROVISIONAL_AGREEMENT_JUDGMENT_INVENTORY_PILOT.md, RED_BLACK_TREE_DOCC_PREVIEW_REVIEW.md, REGISTRY_STUDIO_MILESTONE_CONNECT.md, REGISTRY_STUDIO_SINGLE_LINE_KIND.md.

Check start revision/ownership/protection; append evidence/update triggers only for shallow-verifiable claims. No obligation to fill whole documents; defer with reasons if unsuitable. Do not replace substantive evaluation with existence checks. OPS-073 is reference, not adopted system.

Editable: new appendices in six documents, new evidence/corrections in Evidence/OPS-076/, final Return here. Preserve old returns/body/evidence; record 76/77 correction separately. No deep investigation of 42 pending, others' scopes, product/CI/Studio/Registry edits. Stop/return decisions.

Completion: fixed SHA/path/necessary lines/claim/method/triggers, per-target result/deferral reason/remainder. Astra samples. Hand off specified scope, Astra waits until Return. No commit/external actions.

### 第2区切りReturn（姫記入）

2026-10-17 / 姫・Opus 5.5。入力版`56005d06d1ad97ed544cda914e12ee725692dc58`。着手時に作業ツリーはclean、6文書の関連task（OPS-066・OPS-072・DOC-045・OPS-061・OPS-062）はRegistryでDONE、他担当の作業中範囲との重なりなし。

**実施（6件すべて末尾へ追記、保留0件）**：各文書に「根拠と更新条件の追記」節を足した。手順は[ROUND2.md](Evidence/OPS-076/ROUND2.md)。

- `CANONICAL_CONFIRMED_SCOPE_SUMMARY.md`：試行4件の冒頭ブロックの残存、証拠commit5件の解決、RBT-049証拠の存在。
- `OPS_072_ACCEPTANCE.md`：補正2・3の事実。補正1はOPS-074で閉じたことへの参照。verifyの件数はcommitで固定されない結果として根拠に使わないと明記。補正4〜6は判断なので存在確認に置き換えていない。
- `PROVISIONAL_AGREEMENT_JUDGMENT_INVENTORY_PILOT.md`：対象3文書が書き換えられていないこと（削除行0）、修正案（旧パス）が今も有効なこと。感想は点検事実にしていない。
- `RED_BLACK_TREE_DOCC_PREVIEW_REVIEW.md`：レビュー版`1401a28f`から本版まで`Sources`・`Package.swift`に差分なし。目視結果は環境依存で固定されないと明記。
- `REGISTRY_STUDIO_MILESTONE_CONNECT.md`・`REGISTRY_STUDIO_SINGLE_LINE_KIND.md`：拒否の文言・関数の行、`sync.py`の3列検査、Registry接続表の形。

**食い違い（事実は変わったが判断は変わらない）**：2件。`RegistryApp/index.html`は`bbddb7ff3`で`index.template.html`へ改名。マイルストーン接続は実施時15行→本版28行で、28行とも制約文の書き出し規則に従う。

**観察**：DONE直後の文書が多く、ほぼ「今も成り立つ」の確認になった。効いたのはDocCレビューで、「`Sources`差分なし」の1行があれば、レビューを見直すべきかを差分だけで判断できる。手間は6文書でツール呼び出し約12回。書く方が確かめるより長いのは第1区切りと同じ。

**訂正**：候補表の76/77は[CORRECTION.md](Evidence/OPS-076/CORRECTION.md)へ。

**残り・未確認**：保留42件（本区切りの対象外）。ブラウザ・製品テスト・CIは実行していない。行番号は入力版のもの。本文・Registry・Studioは変更していない。commitはしていない。

<a id="第2区切りastra受入2026-10-17"></a>
## Round 2 Astra acceptance (2026-10-17)

Accepted six appendices, ROUND2 procedure and 76/77 correction. At 56005d06 independently compared four opening blocks, zero Sources/Package.swift diff since DocC review, Studio rejection lines57/336. For three trial sources compared full fec74691 text retained at start (stronger than zero deletions). No product/browser reruns.

Limits: matching opening line establishes presence, not correctness/evidence retention; commit resolution is not claim validity. Sources diff alone does not guarantee DocC environment/settings/all links; choose checks based on impact. Studio rejection is code inspection, not execution. Preserve original appendices; this section defines acceptance scope.

Initial seven appendices accepted; entire inventory incomplete, OPS-076 remains ACTIVE.

<a id="姫への第3区切り依頼保留42件の浅い仕分け2026-10-17--astra"></a>
## Round 3 assignment: shallow classification of 42 pending (2026-10-17 / Astra)

User 「受け入れと再アサインを」. Only 42 pending in original CANDIDATES.md. Fix current input commit and separate moves/disappearances/state changes since original list.

Inspect openings/relevant sections/current Registry only as needed; classify with reasons: (1) candidate evidence appendix, (2) unsuitable operations/proposals/intent, (3) occupied/user-reserved, (4) not cheaply checked. Classification is proposal, not state/authority changes; DONE/unreferenced does not imply editable.

For each candidate, ordinarily one judgment-relevant claim, source/method/trigger. Record SHA/path/necessary lines if cheap; otherwise unknown. No exhaustive claims/history. Stop excessive-cost files with reasons; bounded returns allowed instead of reading 42 at once.

Editable: new ROUND3 evidence and final Return only. Do not edit 42 targets; retain old seven/returns/list. No Registry/product/Tests/CI/Studio/other owners' files, deep tests, shortening or invalidation.

Completion: one-to-one 42-item results/reasons/candidate claims/unknowns/unperformed remainder. Astra checks candidates/ownership then chooses appendices. No automatic method adoption/target editing permission. Hand over new outputs; Astra does not edit before Return. No commit/external operations.

### 第3区切りReturn（姫記入）

2026-10-17 / 姫・Opus 5.5。入力版`1175e583b1857819e9e0b07b83a1cb5fc8be657a`。明細は[ROUND3.md](Evidence/OPS-076/ROUND3.md)。対象42文書・Registry・既存記録は編集していない。

**元一覧との差**：42件とも実在し、移動・消失なし。状態付きだった4件（HIST-003・OPS-068・RBT-026・PERM-080）は状態・担当とも同じ。「参照なし」だった文書の多くは冒頭に関連IDを持つが、圧縮済みtaskの最終状態は本文の記述に頼った（Archivedの版ごとの照合はしていない）。

**分類（案）**：(1)候補12件、(1)済1件（外部型監査はOPS-074で追記済み）、(2)不向き17件、(3)占有・判断待ち7件、(4)低コストでは未確認5件。計42件。

**候補で効きそうなもの**：
- RBT-047の調査：対象3実装のSHA-256が調査時と一致し、再現結果は今も有効。RBT-048（0.7.0でユーザー判断）の前に、この3つのhashだけ見れば足りる。
- DOC-040〜044のレビュー返却と、DOC-033のアウトライン照合：レビューした版から対象文書に差分がある。指摘がまだ当てはまるかは未確認。
- 事実が変わっていたもの：Permutation移行計画は「計画」のまま構成が実現済み。OPS-051の試作は「単一HTML＋JSON」から今のテンプレート＋サーバー型に変わった。ASan調査の「CIはENABLE_DEATH_TESTSなし」は候補CIで一部古い。どれも元の判断は変わらない。

**止めたもの**：(4)の5件。点検記録196行の全読、repository外の照合、作業ツリー入力の固定、完成commitの特定は、見込みを超えるので止めた。止めた理由と次に要るものは明細の行にある。

**手間**：ツール呼び出し約15回。42件の冒頭読みは1回にまとめた。

**次の判断（Astra）**：(1)の12件に追記するか、どれから入れるか。(3)の7件は各担当・ユーザーの範囲。commitはしていない。

<a id="第3区切りastra受入2026-10-17"></a>
## Round 3 Astra acceptance (2026-10-17)

Accepted primary classification: 12 candidates+1 already appended+17 unsuitable+7 occupied/etc+5 not cheap=42. Sampled normal/compat Package.swift targets, candidate.yml ASan+ENABLE_DEATH_TESTS, sync.py --check at 1175e583. Diff confirms targets unedited. Classification is for this shallow inventory, not permanent value/authority.

Correction: three unchanged RBT-047 files do not establish 「再現結果は今も有効」 or 「hashだけ見れば足りる」; CoW/index callees, tests/config/toolchain matter too. Identity narrows reinvestigation; old runs are not current runs. Do not decide RBT-048 for user.

Matching migration target structure does not complete whole plan; review diffs do not invalidate reviews. External repositories need their own SHA, not this one; accepted leaving them unverified. Tag queries/git check-ignore depend on current refs/working tree, distinct from fixed-tree facts.

<a id="姫への第4区切り依頼2026-10-17--astra"></a>
## Round 4 assignment to 姫 (2026-10-17 / Astra)

Under continued acceptance/reassignment instruction, only ROUND3's 12 candidates (#2,#9〜13,#17,#23,#33,#35,#36,#41). Check ownership/protection then append shallow evidence/triggers in new final sections. Defer finalized/in-progress documents with reasons; about 1〜3 claims each, no quota.

Observe prior correction: RBT-047 identity/past-result location only, no current reproduction/judgment assurance. Five reviews/outline: revision/diff location, no rereview. Facts do not substitute substantive judgment.

Edit only 12 appendices, new ROUND4 evidence and final Return. Preserve sources/returns/evidence. No reexploration of remaining17+7+5, product/tests/CI/Studio/Registry changes, adoption or shortening. Leave costly points unverified.

Complete SHA/path/necessary lines/method/scope/triggers, per-file outcome/reasons. Distinguish fixed tree from runtime/refs. Astra samples; hand off scope until Return. No commit/external actions.

### 第4区切りReturn（姫記入）

2026-10-17 / 姫・Opus 5.5。入力版`1175e583b1857819e9e0b07b83a1cb5fc8be657a`。手順は[ROUND4.md](Evidence/OPS-076/ROUND4.md)。

**実施**：12件すべての末尾に追記した。保留は0件。12文書は着手時に入力版から変更がなく、Registryから占有中・ユーザー確定と分かるものもなかった。各文書の主張は1〜2件。

**受入補正への対応**：
- RBT-047：書いたのは「実装の同一性（3つのhashと、`f6e181b2`以降`Sources/RedBlackTreeCollections/`に差分がないこと）」と「過去の結果の置き場」まで。現行版での再現やRBT-048判断の有効性は保証しないと明記した。
- レビュー5件・アウトライン：書いたのは対象版と差分の所在（差分を含むcommit）まで。再レビューはせず、差分があっても無効ではないと書いた。
- Permutation移行計画：一致はtarget構成に限り、計画全体の完了は判定しないと書いた。
- tag・`check-ignore`・ローカル成果物：固定treeの事実と分けて書いた。

**観察**：レビュー5件は、差分を含むcommitの題が「resolve red-black tree review findings」で、指摘への対応の糸口が1行で示せた。ただし対応の中身までは見ていない。

**残り・未確認**：(2)17件・(3)7件・(4)5件は本区切りの対象外。実行・CI・再レビューはしていない。commitはしていない。

<a id="第4区切りastra受入初回展開完了2026-10-17"></a>
## Round 4 acceptance and initial rollout complete (2026-10-17)

Accepted all 12 appendices, confirming original bodies retained. Independently compared RBT three-file SHA-256 at 1175e583b1857819e9e0b07b83a1cb5fc8be657a and no RedBlackTreeCollections changes since f6e181b2ab31dcd17c51c11236a6b5dd4b1024b8. Sampled ASan/review/prototype appendices; identity-versus-current-reproduction correction applied. No product/CI rerun or all-findings rereview.

Mapped initial77 to new19 (1+6+12), already1, initial excluded28, unsuitable17, occupied/user-wait7, not-cheap5. Unknowns remain unknown; retain CANDIDATES/ROUND3 reasons. Complete this bounded initial setup; ongoing maintenance [OPS-077](JUDGMENT_EVIDENCE_MAINTENANCE.md). Not reapproval of original judgments/adoption of whole system.

## 判断にはみ出した記述の再検証と再送（2026-10-17 / 姫・Opus 5.5、CP-20261017-016）

ユーザー直接依頼「判断にはみだすと、それって依存が何層かあるはずなので、判断抽出したものについて再検証と、全体の再送をおねがいしたいが」。OPS-076はDONEのまま。状態変更は依頼しない。入力版`1175e583b1857819e9e0b07b83a1cb5fc8be657a`。明細は[JUDGMENT_RECHECK.md](Evidence/OPS-076/JUDGMENT_RECHECK.md)。

**再検証**：第1〜4区切りで姫が書いた記述のうち、事実照合を越えたもの15件。影響の見積もり・十分性・有効性・不在・権限などで、それぞれ依存の層を版で確かめ直した。

- 支持7件：J1・J3・J5・J7・J8・J14・J15。依存の事実は成り立つ。成立範囲は明細のとおり。
- 範囲限定4件：J4・J6・J11・J13。記述より狭い範囲でだけ支持される。
- 取り下げ4件：
  - J2（第1区切り、tagだけ見れば足りる）：受入時に補正済み。
  - J9（第3区切り、RBT-047の再現は今も有効）：受入時に補正済み。
  - J10（第2区切り、差分だけで見直しの要否を判断できる）：今回新しく取り下げ。
  - J12（ROUND3 #18、依存する判断なし）：不在の主張なので取り下げ、「依存は調べていない」に読み替える。今回新しく取り下げ。

**全体の再送**：第1〜4区切りの成果（追記19件、仕分け77件）は、上の読み替えを加えたうえで変わらない。分類の区分・件数も変わらない。受入側への依頼は2つ。

1. 範囲限定の記述は、元の文言より明細の成立範囲を正とする。
2. J10・J12の取り下げを、第2・第3区切りの受入記録と照らす。

元の追記・Return・証拠は保持し、書き換えていない。判断そのものの精査（根拠が支えるかの評価）はOPS-077の範囲で、ここでは行っていない。commitはしていない。

<a id="再送の優先精査astra受入2026-10-17"></a>
## Prioritized review and acceptance of resubmission (2026-10-17)

Integrated CP-20261017-016 into OPS-077 maintenance and linked as OPS-076 corrections; OPS-076 stays DONE. Read all15, particularly J2/J9/J10/J12 withdrawals against round2/3 acceptance and ROUND3#18 source. Sampled direct serve.py/sync.py operations/outputs at1175e583b1857819e9e0b07b83a1cb5fc8be657a. Prioritized review, not every dependency layer.

Accept resubmission with limits:
- J10 「差分があれば見直しが要る」 means diff identifies impact-check candidates, not mandatory rereview for irrelevant changes. Even unchanged code can need checking after environment changes. Same limit applies to round2 acceptance.
- J12 corrected to 「依存を調べていない」, not absence. Handoff-history source can remain excluded from this appendix scope, not permanently unnecessary.
- 「支持7件」 supports only row facts/scope. J14 body status declaration is not independent user-approval evidence. J1 no direct workflow reference does not prove no indirect use. J5 sync.py calls other scripts; direct-output checks do not guarantee no writes on all paths. No such blanket guarantees accepted.

Retain19 appendices/77 classifications as execution counts, not reapproval of every judgment or permanent classification. Keep historical body; on reuse apply JUDGMENT_RECHECK scope and these corrections. No review beyond this correction acceptance begins.
