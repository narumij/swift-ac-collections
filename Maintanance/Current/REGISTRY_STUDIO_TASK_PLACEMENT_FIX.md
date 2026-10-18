# 接続に基づくタスク配置の修正

## TL;DR（人間向け）

辺を持つ一般タスクを見取り図へ、辺のないものを独立欄へ置き、重複表示を解消した修正記録。Astraの独立試験では配置31件・8表示と関連スモークが成功した。実ブラウザは未確認で、どの版にも結び付かない接続群を版別表示でどう扱うかは将来判断として残す。

Task: OPS-095 / Parent OPS-048.
Author Astra, 2026-10-18. Formal assignment to 姫 at user request.

<a id="要求の正本"></a>
## Canonical requirements

Follow [TASK_REGISTRY_APP.md 「タスク配置の要求」](TASK_REGISTRY_APP.md#タスク配置の要求); do not define separate requirements here. Use the existing [OPS-092 test record](REGISTRY_STUDIO_DISPLAY_PARTITION_TEST.md) as reproduction input.

<a id="仕事と受入条件"></a>
## Work and acceptance criteria

- Retain permanent-tree treatment; put all other connected tasks in the diagram and edge-free tasks in the independent section. Show related groups lacking milestone connections too.
- Remove QUALITY-005/DOC-026 duplication. Independently test destination as well as occurrence counts using connected groups, isolated tasks, permanent trees and milestone fixtures.
- Test full-view coverage; version filtering alone must not make tasks independent. Do not independently change version-filter semantics. Return any otherwise-undetermined target-version handling decision needed for the fix.
- Do not change canonicals, states, edges or save contract. Preserve local diagrams, selection-following and input protection. Do not hide placement problems by adding/removing lines.
- Leave a test failing before/passing after the fix; run verify, local/selection-following smokes and sync/check. No screen operations; explicitly leave actual browser unverified.

<a id="範囲受渡し"></a>
## Scope and handoff

Editable: RegistryApp/index.template.html, verify.cjs, Evidence/OPS-095/ tests and this Return. Keep OPS-092 evidence unchanged and put enhanced tests here. Generated outputs may update. Global layout changes only as needed for these requirements. Hiding final START→END and other improvements are separate.

Hand scope to 姫; Astra awaits Return. Do not change Registry, Rules, permanent canonical requirements, actual Inbox, Milestones or others' edits. No commit assignment. Return cause/change/verification/remaining decisions.

## Return（姫記入）

2026-10-18 / 姫・Opus 5.5。入力HEAD`993c6911e0ca753ed45b8dbcd546ccc323eae65f`。他者の未commit分（DESIGN 2件）と、姫のCP-20261018-001の記録には触れていない。

**再現**：
- OPS-092の`display-partition.cjs`（原証拠、変更なし）を現行で実行すると、DOC-026とQUALITY-005が見取り図と独立欄の両方に出ていた（全体・HEAD以降とも）。
- 強化版の`Evidence/OPS-095/placement.cjs`は修正前、fixture段階で失敗した（`before_fix.txt`）。マイルストーン未接続のtask同士の一群（X→Y）と、接続を持つ追加案が独立欄に入っていたため。

**原因**：独立欄の判定（`independentGroups`）が、「到達点への経路があるか」（到達点の上流と、START・カードの下流）で決めていた。一方、見取り図はtaskの連結成分ごと描く。そのため、DOC-026・QUALITY-005のように到達点への経路がなく、到達点につながるtask（DOC-027）とは依存でつながっているtaskが、両方に出ていた。恒久要求の「独立＝辺がない」とも食い違っていた。

**修正**（`index.template.html`の`independentGroups`だけ）：
- 恒久木（恒久taskとその子孫）を除いたうえで、依存またはマイルストーン接続の線を1本でも持つtaskは独立欄に入れない。線のないtaskだけを独立欄に入れる。追加案も同じ規則。
- 見取り図側は、もともと線のあるノードをすべて配置していたので、変更していない（マイルストーン未接続の一群も全体表示に出る）。
- 版の絞込み（`versionView`）は変えていない。独立欄は版に関係しないので、絞込みで独立扱いに変わることはない。
- 線は追加も削除もしていない。

**試験の強化**（`Evidence/OPS-095/placement.cjs`）：
- 表示回数ではなく配置先を検査する。線あり→見取り図に配置・独立欄にない、線なし→独立欄にちょうど1回・見取り図にない、恒久木のtaskは独立欄にない。
- 各版の表示で、線のないtaskが配置されていないこと。
- 自己検査のfixture：到達点に接続する鎖、到達点未接続の一群、孤立task、線を持つ子を含む恒久木、孤立した追加案、接続した追加案。
- 結果：修正後、現行データ31件・8表示で違反なし（終了コード0）。OPS-092の原証拠も違反なしになった。

**verifyの扱い**：verify 64〜67行の`discoveryFixture`は、POLICY（恒久木）へ依存するWORKを「独立」と期待していた。これは置き換えられた旧規則（到達点への経路の有無）なので、新しい要求に合わせて期待を空に直し、理由をコメントに書いた。線のないtaskだけが独立欄に入る検査を1件足した。

**検証**：
- verify 32 PASS、`sync.py`成功、`--check`でずれなし。
- 局所接続図（OPS-094）と選択追従（OPS-093）のスモークもPASS。
- 実ブラウザでは確認していない。

**残る判断**：現行データでは、線を持つtaskはどれかの版の表示に必ず出ていて、該当0件だった。そのため、対象版を決められない接続群の扱いは、今回の修正には不要だった。将来、到達点に一切つながらないtaskだけの一群ができたら、全体表示には出るが、版ごとの表示には出ない（版の絞込み規則を変えていないため）。その一群をどの版に見せるかは、既存規則からは決まらないので、判断事項として残す。

**作業物**：一時ファイルなし。commitはしていない。

<a id="astra受入2026-10-18"></a>
## Astra acceptance (2026-10-18)

Accepted after diff inspection and independent retesting. Enhanced placement: 31 cases/8 displays, no violations. Original OPS-092 test now has no violations (29 full-view cases and the two HEAD-onward duplicates resolved). OPS-094 local and OPS-093 selection smokes pass; sync --check agrees. Changes limited to independent-section logic/tests, no canonical edges/states changed. Actual browser unverified.

Preserved existing behavior: versionless connected groups appear in full view but not version-specific view. Not a decision required for this fix; retain as future handling issue. Hiding final START→END remains out of scope. Assignment closed, awaiting commit.

2026-10-18: user commit approval made OPS-095 DONE within the accepted scope above.
