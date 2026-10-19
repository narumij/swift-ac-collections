# Registry V3の試験の精読

CP-20261020-008。対象は`Maintanance/RegistryApp/v3/`の、書込みに関わる試験。

- 対象の試験：`test_registry_v3_write.py`・`test_registry_v3_recovery.py`・`test_registry_v3_structural.py`・`test_change_groups.py`・`test_structural_groups.py`・`test_proposal_registration.py`・`test_new_plan_items.py`・`test_focus_and_done.py`・`test_registry_v3_cli.py`
- 突き合わせた実装：`registry_v3_write.py`・`registry_v3_recovery.py`
- 基準：HEAD `78afefa93`
- 試験の一式は実行していない。
- 「確かめた」と書いた1点は、fixtureから作った一時DBで1回だけ動かした。一時ディレクトリは記録してから使い、使ったあと削除した。
- 本番のDBは開いていない。

## 指定の3点

### 1. 発行済みIDを再利用しないか

- 守られていること（試験あり）：
  - 次の番号は、今の最大番号（highwater）+1。発行済みの番号は飛ばす（`_register`）。
  - 2つの接続から同時に登録しても、別の番号になる（`test_two_connections_get_distinct_numbers`）。
  - 退役したIDは、nodeと発行記録が残り、二度と発行されない（`test_retired_id_is_never_reused_or_edited`）。
  - 台帳（issuedThrough）は、1..nの区間をまるごと予約する（`Ledger`の5件）。
  - 失敗した登録の番号は、外に出ないまま次に使われる。外に出ていないので、再利用には当たらない（`test_failure_leaves_nothing_and_publishes_no_candidate`）。
  - 同じ下書き（saveId, draftId）は、1回だけ番号になる（`test_proposal_key_maps_once`、`IdentityRace`）。
  - 新しいカードのIDは、既存のnodeと退役したIDを拒否する（`test_ids_are_never_reused`）。
- 再利用が起きうること：
  - 復元のあとに書込みを開くとき、`enable_writes`は復元したときの最大番号と同じ値を受け付ける。backupのあとに発行した番号を、もう一度発行してしまう。試験`test_the_api_cannot_know_the_real_boundary`は、これが起きることをそのまま記録している。守りは、境界を実証してから開く、という手順の規則だけ。
  - 番号の起点は、正本の台帳（Rulesの`Task ID採番状態`）と、今のRegistryにあるIDだけ。台帳にない接頭辞は1から始まる（試験`DOC-001`で、そう動くことを確かめている）。過去に使われた番号が、Archivedにだけ残っていて台帳にない場合は、再利用される。台帳が漏れなく揃っていることが前提で、それを過去の記録と照らす試験はない。
- 確かめた穴（再利用ではなく、登録が止まる）：
  - 新しいカードのID（`CARD_ID`）は、`TASK-006`のような、taskの形のIDも受け付ける。
  - 次に発行するはずの`TASK-006`という名前のカードを作ると、そのあとの`register_task`は「TASK-006 already exists」で拒否される。
  - 最大番号は進まないので、TASKの登録はずっと止まったままになる。`is_reserved('TASK', 6)`はFalseを返す。
  - カードとtaskで、IDの形を分ける確かめも、試験もない。
- 守りの土台：
  - `id_allocations`と`issued_ids`にはtriggerがなく、SQLで直接書き換えれば最大番号を下げられる。
  - 書く道はCLI（`apply`）だけなので、運用では起きにくい。ただ、守りとして試験はない。

### 2. 古い状態を前提にした更新が、他の変更を上書きしないか

- 守られていること（試験あり）：
  - `update_task`は、変える欄ごとに前提の値を持つ。今の値が前提と違えば、操作全体を拒否する（`test_conflicting_change_is_refused_and_replayed`）。
  - 同じ前提から違う欄を変えた2つの更新は、両方とも残る（`test_independent_fields_from_the_same_base_both_stay`）。
  - 線の削除・変更・つなぎ替えは、前提の欄が揃っていなければ拒否する（`StrictBase`の5件）。
  - カードの並び・名前・版の順は、触った版のカード列を前提にする（`test_stale_base_and_series_duplicate`、`test_stale_version_order`）。
  - focusとrecordedDoneは前提を持つ（`test_roundtrip_replay_and_conflict`ほか）。
  - Studioの保存は、保存時の値を前提にする。同じ欄の競合はconflictになる（`test_a_applies_and_b_conflicts`）。
- 前提を持たない操作：
  - `retire_task`には前提がない。退役を決めたあとで、ほかの人がそのtaskの状態や担当を変えていても、そのまま退役する。古い見え方を前提にした退役が、ほかの変更を無効にしうる。試験もない（退役の試験は、退役したものを再利用・編集できないことだけ）。
  - `add_edge`にも前提はない。足すだけで、ほかの線を消さないので、上書きにはならない。循環は最新の状態で確かめる（`test_concurrent_edges_forming_a_cycle_refuse_the_later`）。
- 試験の抜け：
  - `update_task`は、変えない欄の前提を見ない（設計どおり）。それを、意図として試験に書いたものはない。たとえば「stateだけ変える更新は、ownerが変わっていても通る」こと。
  - Studioの保存の前提は、exportしたときの値。exportを1つの時点で読むことは、`test_export_snapshot.py`で確かめている（#61の補正）。

### 3. 失敗・再送で、部分更新や二重登録が起きないか

- 守られていること（試験あり）：
  - 1つの操作は1つの取引（BEGIN IMMEDIATE）で行う。データ・発行記録・操作記録・改訂番号を一緒にcommitする。途中で失敗すれば、全部戻る（`test_failure_leaves_nothing…`、`test_history_is_written_with_the_change`）。
  - 同じ操作IDで再送すると、記録した結果がそのまま返る（拒否も同じ拒否が返る）。番号・改訂・記録は増えない（`test_replay_returns_the_same_result_without_writing`）。連絡DBと違い、返るのは最初の結果そのもの。
  - 同じ操作IDで中身が違えば拒否し、何も変えない（`test_same_id_with_another_request_is_refused`）。
  - 拒否を記録するまでのあいだに、ほかの依頼が同じ操作IDを取れない（`SameOperation`の2件）。
  - つなぎ替えの「消して足す」の途中で失敗すれば、元に戻る（`test_rewire_failure_between_remove_and_add_rolls_back`）。
  - 下書きの登録で、番号とつながる線は一緒に入るか、一緒に入らないか（`test_failure_rolls_back_the_number_and_every_connection`）。
  - CLIは`--op`が必須なので、返答が失われても同じコマンドで安全に送り直せる（`test_apply_query_and_replay`）。連絡DBの`comm.py`と違い、IDを自分で作らない。
  - 前の世代の操作IDは、復元のあとに再送しても実行されない（`test_old_operations_are_kept_for_query_and_never_replayed`）。
- 部分的に入ること（設計どおりで、試験もある）：
  - Studioの保存を、まとまりごとに入れる`apply_groups`は、まとまりをまたいで原子的ではない。途中のまとまりが拒否されれば、前のまとまりは入ったまま残る（`test_partial_results_are_reported`、`test_plan_success_then_proposal_refusal_is_not_complete`）。結果は`complete: false`で返る。
  - 生成するviewのその場での置き換えは、ファイルごとの公開なので、途中で失敗すると一部だけ公開される（`ViewPartial`。`test_registry_v3_views.py`にある）。
  - 新しいカードの文書は、SQLiteの取引の外にある。確かめたときのsha256を記録するだけで、鍵はかけない（docstringに書いてある）。
- 試験の抜け：
  - 途中で失敗させる試験（`hook`で例外）は、`register_task`と`update_task`と、つなぎ替えの間だけ。`apply_plan`（版とカードの追加、版の並べ直し）の途中の失敗は試していない。`apply_plan`は版の位置を一度+1000000ずらしてから並べ直すので、途中で失敗したときに巻き戻ることを確かめる価値がある。
  - 同じ下書きの登録が2つの接続から同時に来る場合は、続けて実行して試しているだけ（BEGIN IMMEDIATEで直列になることは、別の試験で確かめている）。
  - ライブラリの`apply()`は、`evidence`がなくても`[]`として受け付ける。CLIは拒否する（#41の補正）が、ライブラリの段では緩いまま。

## まとめ

- 3点とも、主な道は試験で押さえてある。特に、再送で最初の結果が返ることと、拒否も記録して同じ拒否を返すことは、連絡DBより厳密。
- 直すべき候補は3つ。
  1. カードのIDに、taskの形を許さない（確かめた。このままでは、登録が止まりうる）。
  2. `retire_task`に前提の値を持たせる（今は、古い見え方での退役が通る）。
  3. `apply_plan`の途中で失敗したときに、全部戻ることの試験を足す。
- 復元のあとに番号を再利用しうること（境界の実証）は、もとから分かっている未決。今の守りは、手順の規則だけ。
