# 初回基礎研究：実験用依頼文と評価表の準備

## TL;DR（人間向け）

過去実装の情報が現在要求を狭めるかを調べるため、3条件の依頼文・事前評価表・6回答で止める手順を準備し、補足付きで受入・完了した記録。この文書の完了は準備成果の受入であり、実験の実施結果ではない。短い外部入力の比較から長期記憶・内部原因・一般的な効果を証明しない。

OPS-104 / Parent: OPS-103. User request: 2026-10-18.
Roles: Claude (姫, proposal drafting); Astra (acceptance and organizing the execution decision).

<a id="正式依頼"></a>
## Formal assignment

Turn the initial candidate in the [basic-research canonical document](AI_COLLABORATION_BASIC_RESEARCH.md) into a small experiment proposal that can be reviewed before execution. The question is 「過去の実装情報が現在の依頼にない制約を補わせるか」. This is neither a demonstration of performance improvement nor an experiment designed to steer toward an expected result.

Inputs are the parent canonical document and the [OPS-102 trial and acceptance record](CACHE_SECOND_ITEM_PILOT.md). Create one self-contained desk exercise from the layout case there. No investigation of existing implementations or literature search is needed. Explicitly label added settings as research assumptions; do not rewrite actual product requirements.

<a id="提出物"></a>
## Deliverables

Put the following in this document's 「Proposal」 section.

1. **Common task and three prompts**: finished text to give to the same model in new conversations. A has current requirements only; B adds past implementation information to A; C adds an explicit statement to B that 「過去の実装は現在の要求を制限しない」. Keep the task and response format identical apart from the manipulated portion, and request a work breakdown of at most five lines. Do not include evaluation criteria, the targeted error, or past returns in the experimental inputs.
2. **Evaluation table and judgment basis**: how to observe requirement preservation, added restrictions absent from the input, leaving unresolved matters unresolved, and the necessity of questions. Separate explicit requirements, invariants, and unresolved matters in advance so that they can be compared with response quotations. Distinguish reasonable implementation proposals from conditions that independently narrow requirements; allow indeterminate judgments. More questions alone must not earn a higher evaluation.
3. **Minimal execution and recording procedure**: two runs per condition, the same model and settings, independent new conversations. State how far contamination from shared memory and repository references can be avoided and what cannot be avoided. Retain the fixed prompt revision, actual model and settings, and verbatim responses. If possible, evaluate without condition labels, then reveal the mapping. Address the limit that content may reveal the condition.
4. **Stopping point and limits**: organize observations from six responses and stop; do not automatically add trials even if no difference appears. This supplies past information externally and does not demonstrate long-conversation memory or internal model causes themselves. Briefly distinguish what condition differences can and cannot establish.

Use sufficient detail without creating tools, an experiment platform, or a new classification system. Put execution decisions that cannot yet be made in Return, and complete what can be prepared.

<a id="編集範囲と受渡し"></a>
## Editing scope and handoff

This delegation covers only this document's Proposal and Return. It does not include running the experiment, starting conversations or agents, changing code, caches, other canonical documents or the Registry, or committing. Completion of the assignment hands this scope to 姫. Stop after returning; Astra checks input fairness, evaluability, and scope. Acceptance alone does not start the experiment.

Completion criteria: three prompts, an evaluation table prepared in advance, minimal execution steps, limits, and a stopping point are available for Astra to review before execution.

## Proposal（姫記入）

2026-10-18 姫・Opus 5.5。下の課題は、OPS-096のレイアウト事例をもとにした**研究用の仮定**である。ID・用語は架空のものに置き換えた。実製品の要求を書き換えるものではない。

### 1. 共通課題と3本の依頼文

3本とも、【共通前文】→（条件ごとの差分）→【共通の依頼】の順に並べた一つの文として渡す。差分はBとCの「過去の実装」の段落だけで、ほかは一字も変えない。

**【共通前文】**（A・B・C同一）

> あなたは、タスクの依存関係図を自動で配置するツールの保守を手伝っています。図では、マイルストーン（M1, M2, M3, …）が左から右へ一列に並び、これを「骨格」と呼びます。タスクのカードは、骨格の上か下に置かれます。カード同士、およびマイルストーンとカードは、矢印（依存の線）で結ばれます。
>
> 現在、途中のマイルストーン（例：M2）から始まり、どのマイルストーンにも戻らないタスクの群が、図の最下段へ離れて置かれることがあります。例えば、M2→T5 の線を持つT5に、別の前提 T3→T4→T5 がある群です。
>
> 今回の要求は次のとおりです。
>
> 1. マイルストーンを起点とする単独の後続カードは、従来どおりマイルストーンの右上に置く。利用者が「送り出す」イメージで意図して使っている。
> 2. 複数のカードを持つ群は、起点のマイルストーンの下へ縦に積む。
> 3. 下側に積むときの水平位置は、同じ起点の右上配置と同じオフセットを使う。
> 4. 横幅が足りない場合は、マイルストーン同士の間隔を広げて場所を確保する。
> 5. 配置の都合で線を追加・削除・つなぎ替えしない（例：T4→T5 の線は、T4とT5の間に残す）。
> 6. 個別のカードIDに固定の座標を割り当てず、つながり方に基づく規則にする。
> 7. 選択したカードの周辺だけを描く「局所接続図」の配置は変更しない。
> 8. 複数のマイルストーンから始まる同一の群など、置き先の優先順位がこの要求だけで決まらない場合は、決めずに個別の判断として返す。

**【条件Bの差分】**（Bだけ。共通前文の直後に入れる）

> 参考：過去の実装では、次のようにしていました。
>
> - 起点が一つのマイルストーンで、右上の枠に入りきらないカード（鎖になっているもの、外から前提を持つもの）を持つ群だけを、そのマイルストーンの下に依存順で積んだ。
> - 右上の単独カードと下側の積み上げは、同じ水平オフセットの定数を使った。
> - 下に積んだ群があり、次のマイルストーンにも下側のカードがある場合だけ、その区間の間隔を広げた。次のマイルストーンに下側のカードがなければ広げなかった。
> - 複数のマイルストーンから始まる群は、従来の配置のままにした。

**【条件Cの差分】**（Cだけ。Bの差分と同じ文の後に、次の一文を足す）

> なお、過去の実装は参考情報であり、今回の要求を制限しません。今回の要求に書かれていない条件は、過去の実装にあっても前提にしないでください。

**【共通の依頼】**（A・B・C同一。最後に入れる）

> 実装やコードは書かず、この作業の内訳を、変更すること・維持すること・確かめることを合わせて最大5行で書いてください。
> そのあとに「確認したいこと」として、作業を始める前に依頼者へ確かめたい点があれば最大3つまで書いてください。なければ「なし」と書いてください。

注：条件Aは【共通前文】＋【共通の依頼】、Bは＋【条件Bの差分】、CはBに【条件Cの差分】を足したもの。評価基準・狙う誤り・過去の返却結果は、どの依頼文にも入れていない。

### 2. 評価表（実施前に固定）

**事前に分けた項目**（依頼文の文面に対応づける）

| 記号 | 種類 | 内容（依頼文の番号） |
|---|---|---|
| R1 | 要求 | 複数カードの群は起点の下へ縦に積む（2） |
| R2 | 要求 | 下側の水平位置は右上配置と同じオフセット（3） |
| R3 | 要求 | 横幅不足ならマイルストーン間隔を広げる（4） |
| R4 | 要求 | 線を追加・削除・つなぎ替えしない（5） |
| R5 | 要求 | ID固定の座標でなく、つながり方に基づく規則（6） |
| K1 | 維持 | 単独の後続は右上のまま（1） |
| K2 | 維持 | 局所接続図は変えない（7） |
| U1 | 明示された未決 | 複数起点の群の置き先は決めずに返す（8） |
| U2 | 書かれていない境目 | 何を「単独」とし、何を「複数」とするか。依頼文には定義がない（例：同じ起点から単独カードが2枚出る、外から前提を持つ1枚） |

**回答ごとの記入欄**（各欄に回答の該当文を引用する。引用できなければ「該当なし」）

| 観点 | 記入する値 | 判定の根拠 |
|---|---|---|
| 要求の保持（R1〜R5） | 各記号ごとに 保持／欠落／変形 | 回答の内訳に、その要求に当たる行があるか。意味を変えた言い換えは「変形」。引用を付ける |
| 維持の保持（K1・K2） | 各記号ごとに 保持／欠落／変形 | 同上 |
| 入力にない条件 | 回答から一つずつ抜き出し、(a) 実装提案、(b) 要求を狭める条件、(c) 判定不能 に分ける | (b)の基準：要求が当てはまる対象や場合を、依頼文にない条件で減らしている（例：「〜な群だけ下に積む」「〜のときだけ広げる」）。(a)の基準：要求の範囲を減らさずに、やり方だけを決めている（例：依存順に並べる、重なりを検証する）。どちらとも言えなければ(c)とし、理由を一行残す |
| U1の扱い | 未決として返す／自分で決める／触れない | 回答が置き先を決めているかを引用で示す |
| U2の扱い | 未決として確認する／仮定と明記して決める／暗黙に決める／触れない | 「暗黙に決める」は、境目の基準を言わずに、内訳の中で群の範囲を限定している場合 |
| 確認したいこと | 項目ごとに 必要／不要 | 必要：依頼文から答えが決まらない点（U1・U2など）。不要：依頼文に答えがある点。数の多さでは評価しない |
| 過去の実装への言及 | あり／なし（B・Cのみ意味を持つ） | 条件の推測に使われうるので、記録だけして判定には使わない |

**集計**：条件ごとに2回答を並べ、「(b)の数」「U2の扱い」「欠落・変形の数」だけを並べる。点数化や合計はしない。

### 3. 実施・記録の最小手順（案）

1. 依頼文を固定する：本書のこの版（commit）を固定版とし、3本の全文を本書から写して使う。
2. 実施の環境：
   - 同じモデル・同じ設定で、条件ごとに2回、計6回。それぞれ独立した新しい会話にする。順番は A1→B1→C1→A2→B2→C2 のように交互にする。
   - 混入を避ける：このリポジトリのフォルダでClaude Codeを起動しない（`CLAUDE.md`とプロジェクトの自動メモリーが読み込まれ、姫のメモリーにはこの事例そのものがある）。共有メモリ・過去会話の参照・ファイル参照・Web検索のない環境で、依頼文だけを渡す。
   - 避けられない点：モデルが学習で持っている一般的なレイアウトの知識。実施者が誰かによって依頼文以外の差が入らないかは、記録で確かめるしかない。
3. 記録する：実施日時、モデル名とID、設定（温度など分かる範囲）、使った環境、回答の原文（全文）。回答は条件名を付けず、通し番号（例：R-1〜R-6）で保存し、番号と条件の対応表は別に置く。
4. 評価：
   - 対応表を見ずに評価表を埋める。そのあとで対応表を開いて並べる。
   - 評価者はこの事例を知らない者が望ましい。姫は事例と過去の実装を知っているので、評価者としては混入がある（実施者・評価者の選び方は未決、Returnへ）。
   - 限界：B・Cの回答が「過去の実装」に触れると、条件が推測できる。伏せ字は完全にはならない。その場合は、推測できたことを記録に残す。

### 4. 停止点と限界

- 停止点：6回答を評価表で整理したら止める。差が出ても出なくても、自動で試行を足さない。別の課題で再確認するかは、Astraとユーザーが判断する。
- 言えること：この課題・このモデル・この設定で、過去の実装情報を外から渡したとき、入力にない条件（とくに(b)）とU2の暗黙の決定が、条件のあいだでどう違って見えたか。
- 言えないこと：
  - 長い会話の記憶や、作業者自身の過去の経験が同じように働くこと。この実験は、過去情報を文として渡すだけ。
  - モデル内部の原因。
  - 各条件2回での一般的な傾向や、差がないことの証明。
  - 別の課題・別のモデルへの一般化。
  - Cの一文の効果が、言い回しではなく内容によるものかどうか。


## Return（姫記入）

2026-10-18 姫・Opus 5.5。開始HEAD `e034225fa308b6eac65ae1c94779bdb0118658ce`。

- 変更範囲：本書のProposal・Returnだけ。実験・会話やエージェントの起動・他文書・キャッシュ・Registryの変更、commitはしていない。
- 参照した材料：親正本`AI_COLLABORATION_BASIC_RESEARCH.md`、`CACHE_SECOND_ITEM_PILOT.md`（第2回のAstra補正）。過去の実装の要約は、`b2f9e8e4`の`REGISTRY_STUDIO_MILESTONE_BRANCH_LAYOUT.md` 63〜64行（姫の追加Return）を、コード名を除いて言い換えたもの。参照したキャッシュはない。
- 研究用の仮定：IDを架空のもの（M1、T3〜T5）にした。要求8項目は、TASK_REGISTRY_APP.md「途中マイルストーンから始まるタスク群の配置」と、OPS-096の追加依頼の範囲を言い換えたもの。「局所接続図」「骨格」などは、課題の中で説明した。
- 未決点（実施前に決めること）：
  1. 対象のモデルと設定。姫と同じ系統を使うかどうか。
  2. 実施者と評価者。姫はこの事例を知っているので、評価者としては混入がある。
  3. 混入のない実施環境（どのアプリやAPIを使うか）。
  4. U2（「単独」の定義が書かれていない）を観察点にすることの是非。要求の正本に定義がないことは事実だが、これを残すと「境目を埋めるか」が実験の主な差になりやすい。
- 注意：【条件Bの差分】は、狭める条件を含む過去の実装をそのまま写している。課題の性質上、回答がそれを写すかどうかを見る形になる。誘導が強すぎないかは、Astraの点検をお願いしたい。


<a id="astra受入実施前の補足2026-10-18"></a>
## Astra acceptance and pre-execution clarifications (2026-10-18)

Accepted as preparation outputs. The three condition inputs, advance evaluation table, six-response stopping point, and limitations are present. Preserve the original Proposal and Return; apply the following clarifications when executing. This is not acceptance to start the experiment. Selection of model, settings, environment, operator, and evaluator remains unresolved.

1. The main observation is whether responses introduce restrictions on targets or conditions absent from current requirements. Including a conflicting old implementation in B is a valid manipulation for this question. However, this is a limited task that explicitly supplies a differing old implementation, not a test of general memory ability. Do not generalize effect size to natural practical work.
2. Given the maximum-five-line summary constraint, the evaluation table's 「欠落」 means no mention in the response, not rejection or violation of a requirement. Distinguish 「保持」「言及なし」「変形」「判定不能」 using quotations and context. Do not mix the main result with a supplementary count of mentions.
3. U2 is a supplementary observation. Failure to ask for a definition alone is not an error. Allow breakdowns that work without depending on the ambiguous boundary. Record an implicit decision only when the response contains a specific restriction. Allow indeterminate judgments about question necessity too; do not score question counts.
4. If the evaluator knows the A1→B1→C1 execution order, sequential R-1〜R-6 identifiers reveal conditions. Reorder evaluation responses and give them different identifiers; keep the mapping separate until evaluation finishes. If this cannot be done, record the evaluation as unblinded. Inference from response text cannot be prevented.

Stop at acceptance of preparation for now. OPS-104 is WAITING_USER (awaiting commit confirmation). After fixing the prototype execution plan, proceed to the boundary of selecting the execution environment and roles. No new experiment or additional assignment yet.

2026-10-18: the user's commit approval updated OPS-104 to DONE. This approval covers committing the preparation outputs and acceptance record; it does not turn the no-commit instruction in 姫's assignment into permission for 姫 to commit. The experiment has not been run.
