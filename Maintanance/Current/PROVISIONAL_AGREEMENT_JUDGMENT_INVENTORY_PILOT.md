# 仮契約・仮判断の棚卸し記録の限定試行

## TL;DR（人間向け）

3文書で判断らしき記述を事実と照合する棚卸しと、現在の表面を短く示す案を作り、全体追記の立案まで受け入れた限定試行。元文書は差し替えず、修正・失効は案にとどめる。止めどころが引継ぎに役立った一例はあるが、継続的な省力効果や制度導入は確定していない。

2026-10-17 / OPS-072 / recorded by Astra. Parent OPS-070. The advance trial and planning the user specified have been accepted. The Task Registry is canonical for state and required dependencies.

<a id="前提"></a>
## Premise

In the original plan, the trial would take the organization of OPS-070 (provisional contracts) and OPS-071 (provisional judgments) as input, and run after settling a few targets, the method, the editing scope and the acceptance conditions with the user. That was the original premise. This limited trial was done first by a later user instruction. Introducing the system is not automatically approved.

<a id="試行案"></a>
## Trial proposal

For each target, briefly record whether it is a provisional contract or a provisional judgment, the facts checked and their sources, the result — keep, fix or discard — with the reason, and the trigger for re-checking. Keep the confirmed facts and reasons for discarded proposals too. If undecided, say undecided; do not demand proof of absence or a search of the whole history.

The inventory record is not a separate canonical for currently valid judgments, delegations or task states. Results needing a formal decision go back to the user as proposals. The record alone does not change authority, freezes or states. Try a way of handing the gate cache the inventoried scope and references to the canonicals.

<a id="評価と返却"></a>
## Evaluation and return

Observe whether work can resume without repeating the same searches or evaluations, whether it is clear how far things are checked, and whether creating and maintaining the record becomes a new burden. Separate observed effects from hypotheses and unconfirmed items, and return outputs, problems and a proposal to continue, change or end. Accepting the trial's outputs is separate from introducing the system as a whole.

## 試行の返却（2026-10-17 / 姫・Opus 5.5）

ユーザーが会話で対象と着手を指定（姫の「事実と突き合わせられそうな正本」の仕分けから3本、「それやってみて感想をタスク正本に記載する感じ」「あってるなら着手で」）。OPS-070・071の整理完了を待たずに始めたのはユーザーの指示による。入力版`fec74691`。

**対象と結果。** 記録は[棚卸し記録](Evidence/OPS-072/INVENTORY.md)。対象文書は書き換えていない（修正・失効は案）。

- `ASAN_DEATH_TEST_INVESTIGATION.md`：修正案2（Linuxの扱いが候補CIの成功で変わった）、失効案1（runtimeパス復元の候補はstrip_env=0の確認で役目を終えた）、未決1。
- `EXTERNAL_TYPE_EXTENSION_AUDIT.md`：有効3、修正案1（`Sources/PermutationModule/`のパスが0.5.4の改名で古い）、未決2（`_LazyTie`の指す先、SignedDistanceの実験）。
- `PERMUTATION_SEQUENCE_INVALID_VIEW_ISSUE.md`：有効2、未決1（Array収集時の失効の再現はPERM-060担当の占有なので触っていない）。

**感想（観察。効果は仮説）。**

1. 「判断らしき記述」は思ったより見つけやすかった。完了記録・未検証の宣言・候補・待ち条件・参照パスの5種類くらいに分かれた。参照パスは判断ではないが、一番安く確かめられて一番古くなりやすい。
2. 寿命がはっきり違った。参照パスやCI定義の記述は短命、「Linuxの成功はmacOSを証明しない」のような推論は長命。同じ段落に混ざっていると（A-1）、短命な事実が古くなったせいで推論まで疑わしく見える。分けて書いてあれば片方だけ直せる。
3. 失効は「判断を捨てる」で、「観察を捨てる」ではなかった（A-3）。候補としての判断は役目を終えたが、「setenvで戻すと通る」という事実は残す価値がある。寿命の違うものを分けるという話と同じ形。
4. 占有の欄が一番効いた。C-3は再現すれば答えが出るが、それはPERM-060の仕事なので触らないと決められた。欄が無ければ、確かめたくなって手を出していたと思う。
5. 打ち切りは「不在は証明しない」と一言書けると気楽だった（B-3の`_LazyTie`）。履歴版に答えがありそうだと分かっていても、価値に見合わないので止めた。止めた場所と、次に見るべき場所を書いておけば、次の人が同じ探索をしなくて済む。
6. 負担：3文書でツール呼び出し約15回。記録を書く方が確かめるより長かった。欄が7つは多く、未決の項目では空欄が増える。最小形は「記述・結果・確認済みの範囲・次に要るもの」の4つでも回りそう（未検証）。
7. 姫が書いた記録を、別のAI（Fable／Astra）が読んで「ここで止めてよい」と判断できるかは未確認。そこが本来の効果なので、受入時に見てほしい。

**核になった見方（ユーザーが拾ったもの）。** 試行後の会話で姫が言った「言ってみれば、文書に Test as Specification をかけている感じです」に、ユーザー「これだ！」。正本の判断らしき記述は、コード・yml・gitに対して実行できる主張で、テストと同じく今も成り立つかを確かめられる。主張の種類ごとに寿命が違い（参照パスは短命で安く確かめられる、完了記録は長命、未検証の宣言は事実が来た瞬間に古くなる、候補は答えが出ると役目を終える）、短命なものだけを時々確かめれば正本の鮮度を保てる見込み。悪魔の証明とは逆に、確かめる範囲を寿命で絞れる。効果は仮説、継続的な運用は未試行。

**未実施と境界。** 修正案を対象文書へ反映していない（各文書の占有者・調整担当の判断）。CIログ・品質評価原文・履歴版監査は読んでいない。棚卸し記録は正本ではなく、Registryの状態も変えていない。受入はユーザーまたは指名された調整担当。

### 試行2：「今の表面」案（2026-10-17 / 姫・Opus 5.5）

試行1の後、ユーザーとの会話で観点が深まった（Test as Specは過去がgitに沈むがメンテナンス文書は全部露出している／仮判断は動くので残す、事実に裏付けられた判断は点検事実さえ分かればリポジトリの過去にできる／大事なのは寿命）。この観点で同じ3文書の「今の表面」案を作った：[表面案](Evidence/OPS-072/SURFACES.md)。対象文書は差し替えていない（案のみ）。

- ASan（DONEのtask）：55行→約13行。大半が確定済みの経緯で、点検事実4行と仮判断2つで足りた。
- 外部型Extension監査：68行→約28行。再開条件（契約）と長命な「守る決まり」が残る。
- PERM-060（ACTIVE）：縮まない。寿命が尽きた記述がほぼ無く、点検事実を2行足すだけ。

**感想。** 試行1の「棚卸し記録を別に作る」より、試行2の「表面を作る」方が後の人は楽になる。試行1の記録は表面ができると役目を終える（中間生成物だった）。縮む量は文書の寿命の状態でほぼ決まり、DONEのtaskの文書ほど大きく縮む。逆に言えば、taskがDONEになった時が表面を作り直す自然なきっかけ。点検事実を1行で書けるかどうかが、判断が事実に裏付けられているかの試金石にもなった（書けないものは仮判断として残すしかない）。迷ったのは長命な規則（B「監査で守る決まり」）の置き場で、この文書よりRules側かもしれない。

**次に要る判断（ユーザー）。** 表面案で実際に正本を差し替えるか（占有の付与。旧版はgitに残る）。差し替える場合、DONEのtaskの文書（A）から始めるのが安全と考える。

### 立案：全体へ広げるときの追記範囲（2026-10-17 / 姫・Opus 5.5）

ユーザー指示「立案までがこのタスクで、次は未採番タスクをあらたにして、全体着手タスクにしよう。そうすると、あとからよみやすい」。OPS-072の成果は、試行1・2と以下の立案まで。全体での実施は別task（CP-20261017-013）とする。

- **場所**：対象正本の末尾に「棚卸し追記（日付・担当・実行モデル）」節を1つ置く。
- **書いてよいもの**：点検事実（これを見れば今も成り立つ、の1行）、見張る仮判断と見直しのきっかけ、修正案・失効案（案として）、糸口（`git log -- パス`と最後の版）。
- **してはいけないこと**：既存本文の書き換え・削除、Registryの状態変更。
- **対象外**：ユーザーが確定した文書、今だれかが占有して作業中の文書（ACTIVEで担当がいるもの）。
- **その後**：持ち主または調整担当が、追記を材料に表面を作り直す（旧版はgitに残る）。追記は表面を作り直すまでの短命な材料。
- **順番の目安**：DONEのtaskの文書から（縮む量が大きく、作業中の人とぶつからない）。

<a id="astra受入2026-10-17"></a>
## Astra acceptance (2026-10-17)

Accepted according to the user's change of scope to an advance trial up to planning. Removed the wait for both earlier studies to complete from this trial's dependencies. The corrections and guaranteed scope are in [the acceptance record](OPS_072_ACCEPTANCE.md). The whole-repository addition is [OPS-074](CANONICAL_INVENTORY_APPEND.md). The shortening proposal is not adopted.


<a id="根拠と更新条件の追記2026-10-17--姫opus-55--ops-076第2区切り"></a>
## Grounds and update conditions, appended (2026-10-17 / Hime, Opus 5.5 / OPS-076 break 2)

Input version `56005d06d1ad97ed544cda914e12ee725692dc58`. The body and old records were not changed. Each row is "a claim checked in that version, and the method". Checked only by reading with `git`; no browser, product tests or CI were run.

| Claim | Check method and result | Trigger for update |
| --- | --- | --- |
| Trial 1 「対象文書を書き換えていない」 (did not rewrite the target documents) | The diff of the 3 documents from input version `fec74691` to this version has no deleted lines. Only `EXTERNAL_TYPE_EXTENSION_AUDIT.md` went from 68 to 94 lines (OPS-074's appended section); the other 2 have the same line counts | When someone fixes the bodies of the 3 documents (e.g. rebuilding the surface) |
| The fix proposal 「`Sources/PermutationModule/`のパスが古い」 (the path is outdated) is still valid | `git cat-file -e <版>:Sources/PermutationModule`: absent. The old path remains at line 64 of the audit body | Fixing the path in the body, or a change of module structure |
| The inventory record and surface proposal exist in that version | `Evidence/OPS-072/INVENTORY.md` and `SURFACES.md`: present | Moving or compressing the evidence |
| Line counts 「55行」「68行」 | At input version `fec74691`, ASan 55 lines and audit 68 lines. In this version ASan 55 and audit 94 (the appended part) | Rebuilding the surface changes the premise of the comparison |

The impressions (items 1–7 of the trial section, and trial 2's impressions) are observations and hypotheses, not inspection facts.
