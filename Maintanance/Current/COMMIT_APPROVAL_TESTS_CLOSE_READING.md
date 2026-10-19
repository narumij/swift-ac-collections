# コミット承認DBの試験の精読

CP-20261020-009。

- 対象の試験：`Maintanance/RegistryApp/test-approvals.py`（8件）と、`test-studio-store.py`のうち承認に関わる5件（operationの再送・拒否の記録・取引の巻き戻し・同時送信・CLI経由）。画面の`test-approvals.cjs`は、承認の送り方に関わる行だけを見た。
- 突き合わせた実装：`approvals.py`（Store.add・mutate・claim・finish・abandon、transaction、trigger）、`serve.py`の受付の確かめ（`POST_ACTIONS`・origin）
- 基準：HEAD `78afefa93`
- 試験は実行していない。下の判断はすべてコードを読んでのもの。

状態の流れ：pending（依頼）→ approved（承認、mutate）→ claimed（実行開始、claim）→ consumed（コミット完了、finish）。途中で止めればcancelled（cancel／abandon）。

## 指定の3点

### 1. 承認した対象・範囲が、実行時にも一致しているか

- 守られていること（試験あり）：
  - 承認の対象（card：task・題・範囲・paths・条件・branch）は、triggerで書き換えられない（`test_database_history_and_content_retained`）。
  - 承認するときは、画面に出ていた版（revision）を名指す。版が変わっていれば拒否する（`test_atomic_snapshot_revision_and_durability`）。
  - 実行の開始（claim）は、決まったcheckout、cardのbranch、今のbranchが一致したときだけ通る（`test_claim_finish_token_and_real_commit`）。
  - 完了（finish）は、次のときだけ通る。
    - claimしたときのHEADから、新しいcommitがちょうど1つで、HEADがそのcommitである。
    - 変えたファイルが、承認したpathsの中に収まる。
  - 試験：pathsの外のファイル（`test_finish_rejects_outside_paths_and_branch_change`）、名前の前後の空白（`test_filename_whitespace_is_not_normalized`）、branchを外した場合。
- 一致を確かめていないこと：
  - 承認は、どの時点のcommitを前提にしたかを持たない。claimしたときのHEADが起点になる。承認してから時間がたち、別のcommitが積まれても、古い承認でそのまま実行を始められる。期限もない。試験もない。
  - 確かめるのは、変えたファイルの名前だけ。範囲（scope）や条件の文は、機械では確かめない（人の受入に任せている）。承認したファイルの中で何を変えても通る。
  - 試験の抜け：
    - commitが2つ以上の場合（`actual != [sha, claimHead]`で拒否されるはず）
    - merge commitの場合
    - 空のcommitの場合（`not paths`で拒否されるはず）
    - pathsの外からの改名の場合（`--no-renames`なので、両方の名前で確かめるはず）
    - コードを読む限りはどれも拒否されるが、試験はない。

### 2. 使用済み・取消済みの承認を再利用できないか

- 守られていること（試験あり）：
  - finishのあとはconsumedになり、2回目のfinishは拒否する。tokenはfinishとabandonで消える（`token_hash`をNULLにする）。
  - 取り消した依頼は、承認できない（`test_atomic_snapshot_revision_and_durability`の最後）。
  - abandonしたあとは、claimできない。もう一度やるには、新しい承認が要る（`test_claim_finish_token_and_real_commit`）。
  - 1つのcheckoutで、同時にclaimできるのは1件だけ。
  - 同じ承認の同時送信は、1回だけ効く（`test_concurrent_approval_one_winner`、`test_concurrent_sends_of_one_operation_apply_once`）。
- 試験の抜け：
  - consumedになった依頼を、もう一度承認・claim・取り消しする場合は試していない（コードではすべて拒否される）。
- 再利用が起きうること：
  - `requests`表のstate列にはtriggerがない（守っているのはcard列の変更と、行の削除だけ）。SQLで直接書けば、consumedをapprovedに戻せる。また`INSERT OR REPLACE`は、DELETEのtriggerを通らずに行を置き換える（連絡DBの精読で再現した性質と同じ）。書く道はサーバーだけ、という規則に頼っている。

### 3. 承認・実行開始・コミット完了を混同せず、失敗時も記録が正しく残るか

- 守られていること：
  - 3つは別の状態と別の出来事として、履歴に残る（approve・claim・finish）。claimにはHEAD・受入の参照・branchを、finishにはcommit SHAを記録する。
  - 承認の拒否は、操作として記録される。同じ操作IDで再送すると、同じ拒否が返り、二重に記録しない（`test_refused_change_is_recorded_and_nothing_changes`）。
  - 承認の途中で失敗すれば、全部戻り、操作の記録も残らない（`test_failure_inside_the_transaction_rolls_everything_back`）。
  - 実行を途中でやめるときは、abandonで理由を残し、cancelledになる。
- 混同・記録の穴：
  - 承認者が本人であることを確かめていない。承認（mutate）の記録の`actor`は、いつも`'ユーザー'`に固定されている。サーバーが確かめるのは、localであることと、Originと`X-Registry-Studio`の値だけ。同じ機械で動くプログラムなら、AIでもこの値を付けて承認を送れる。CLIには承認の命令はないが、HTTPなら送れる。試験（`test_http_guards…`）は、値が違えば403になることしか見ていない。承認と実行を同じAIができてしまう形で、記録上は「ユーザーの承認」に見える。
  - claimの返答が失われると、元に戻れない。tokenは返答の中にしかなく、listにも出ない（意図どおり）。返答が失われると、状態はclaimedのままtokenが分からなくなる。そうなるとfinishもabandonもできず、そのcheckoutではほかのclaimも全部止まる。claimには操作IDも再送の仕組みもない。試験もない。
  - finishとclaimの失敗は、記録されない。pathsの外、branchの違い、tokenの誤りでの拒否は、取引ごと戻り、履歴にもoperationsにも残らない。試験も「状態がclaimedのまま」ことしか見ていない。たとえばpathsの外を含むcommitがgitに残っても、DBにはその試みの記録がない。
  - commitそのものはDBの外（git）で起きる。claimしたあとでcommitしてfinishしなければ、claimedのままになる。claimせずにcommitしても、DBは知らない。承認はcommitを止める仕組みではなく、記録と照合の仕組み（POLICY_NOTICEにも「Astraが会話で直前承認を確認します」とある）。
  - 失敗の種類がそろっていない。detachしたHEADでfinishすると、Conflictではなく`subprocess.CalledProcessError`が出る（試験もそう期待している）。HTTPでは別の応答になりうる。

## まとめ

- 主な道（対象を変えられないこと、版で承認すること、branchとpathsの照合、1回きりのfinish、取り消しのあとは使えないこと）は、試験で押さえてある。
- 大きい穴は3つ。
  1. 承認者を確かめていない。記録はいつも「ユーザー」になり、同じ機械のAIでも承認を送れる。
  2. claimの返答が失われると、tokenが分からなくなり、checkout全体が止まる。戻す道がない。
  3. claim・finishの失敗が記録に残らない。承認の拒否は記録されるのに、そろっていない。
- そのほか：承認に前提のcommitも期限もないこと、DBのstate列が守られていないこと、commitの形（2つ以上・merge・空・改名）の試験がないこと。
