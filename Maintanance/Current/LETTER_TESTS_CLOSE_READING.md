# 連絡DBの試験の精読

CP-20261020-006。対象は`Maintanance/RegistryApp/test-studio-letters.py`（25件。StoreTests 17・HttpTests 8）。突き合わせた実装は`studio_store.py`（LetterMixin）・`approvals.py`（transaction・operations・trigger）・`comm.py`・`studio_client.py`。基準はHEAD `78afefa93`。

- 試験は実行していない。読んだだけ。
- 下で「確かめた」と書いたものは、その場で再現したもの。それ以外は、コードを読んでの判断。
- 対象外（まだ読んでいない）：`test-studio-store.py`（operations・PINGの土台）と、`test-view-model-letters.cjs`（表示）。

## 結論

主な流れ（送る→受ける→着手→返す→閉じる、止める要請、改訂、代理の記録、再送）は、よく確かめられている。抜けの大きいものは5つ。

1. 「追記だけ」はUPDATEとDELETEしか試していない。`INSERT OR REPLACE`は、BEFORE DELETEのtriggerを通らずに行を置き換える。`:memory:`で同じtriggerを作って確かめた。store自身はREPLACEを使っていない。だから「追記だけ」は、DBに直接触る者に対して保証されていない。
2. 「読んでも何も記録しない」は、letter_eventsとoperationsの行数しか見ていない。実装の読み取りも`BEGIN IMMEDIATE`（書込みの鍵）を取る。DBがなければ、フォルダとファイルとschemaを作る。行は増えないが、副作用はある。
3. 返答が失われたあとの再送は、連絡では試していない。`comm.py letter send`は、`--operation-id`を省くと毎回新しいIDを作る。結果が「不明」でもそのIDを出力しないので、同じIDで送り直す道がない。送り直すと、連絡が2通になりうる。試験は「サーバーに届かない」場合だけ。
4. 32KBの上限が、バイトなのか文字数なのかを試験で区別していない。超える側は`'x'`（1バイト文字）だけ。文字数で数える実装でも通ってしまう。
5. 状態の遷移表は、一部しか試していない。たとえば、返したあとにもう一度返す、閉じたあとにもう一度閉じる、返したあとの停止要請、は試していない。代理の記録は状態を確かめずに受け付けるので、閉じた連絡にも積める。これも試していない。

## 試験ごと

### StoreTests

- `test_original_text_and_state_machine`
  - 主張：原文はそのまま保たれ、状態は順に進む。
  - 確かめていること：BODY（Markdown・改行・code）が一致すること。sent→received→started→returned→closedの順。本文のない返答は拒否されること。
  - 抜け：`\x00`を含む本文の拒否は試していない。

- `test_refused_transitions_and_who_may_act`
  - 主張：できない遷移と、できない人を拒否する。
  - 確かめていること：sentからのstarted・returned・closedの拒否。受けるのは受け手だけ、閉じる・止める要請は送り手だけ。辞退と停止要請には理由が要ること。
  - 抜け：遷移表（7つの出来事×8つの状態）のうち、試しているのは一部だけ。returned→returned、closed→closed、returned→withdrawn、started→declined（停止要請なし）は試していない。

- `test_senders_and_no_proxy_send`
  - 主張：送れるのは一覧にいる人だけ。代わりに送ることはできない。一覧は追記で版を重ねる。
  - 確かめていること：一覧にない名前は拒否。代理の送信は拒否。版は1→2になり、metaのUPDATEはtriggerで止まる。自分宛ては拒否。
  - 抜け：
    - 受け手の名前は、どこでも確かめていない（例：「ひめ」のような打ち間違いの宛先も通る）。試験もない。
    - 一覧を誰が変えられるかの制限はない（recorded_byは自己申告）。試験は「変えられる」ことだけを見ている。

- `test_proxy_records_change_nothing`
  - 主張：代理の記録は残るが、状態を動かさない。
  - 確かめていること：代理の受領では状態がsentのまま。代理の返答では本文が保存されない。代理の改訂は拒否。
  - 抜け：代理の記録は状態の確かめを飛ばす（`if effective:`の外にある）。だから、閉じた連絡やありえない遷移にも積める。それが意図どおりかは、試験にも文書にもない。

- `test_revisions_keep_history_and_mark_after_receipt`
  - 主張：改訂は履歴を保ち、受領のあとの改訂が見える。
  - 確かめていること：版2が積まれること、理由が要ること、状態が変わらないこと、`revisedAfterReceipt`、閉じたあとは改訂を拒否すること。
  - 抜け：docstringには「停止要請のあとも改訂できない」とあるが、試しているのは閉じた場合だけ。

- `test_receipt_names_the_revision_that_was_read`
  - 主張：受領は、読んだ版を名指す。
  - 確かめていること：v1を読み、v2に改訂されたあとでもv1で受領できる。版の指定がない受領と、ない版の指定は拒否。received以外は版を取らない。同じIDで中身の違うものは拒否。
  - 抜けは特にない（どの版を読んだかは自己申告で、確かめようがない。そう書いてもある）。

- `test_stop_request_and_answers`
  - 主張：停止要請は受信箱に残り、本人の応答だけが先へ進める。
  - 確かめていること：受領の前・作業中・返答が間に合った場合・受領して未着手の4場面。強制的に閉じることはできない。代理の停止応答は動かない。履歴が残ること。
  - 抜けは小さい。

- `test_older_withdrawals_still_derive`
  - 主張：理由を必須にする前の古い停止要請も、同じように読める。
  - 確かめていること：手で入れた行が停止要請として読め、応答できること。

- `test_brief_list_reads_no_text`
  - 主張：一覧は本文を読まない。
  - 確かめていること：実行したSELECT文に`body`という文字列がなく、letter_textsへの`select *`もないこと。一覧と全件の版数と状態が一致すること。
  - 抜け：文字列で見ているだけ（例：`select  *`のように空白が2つなら見逃す）。今の実装では足りている。

- `test_send_and_receipt_times_are_the_server_times_of_those_events`
  - 主張：送信時刻はsentの出来事の時刻、受領時刻は本人の最初の受領の時刻。読むだけでは時刻が付かない。
  - 確かめていること：時刻を1回だけ読むこと、読んでも受領にならないこと、代理は受領にならないこと、再送で時刻が変わらないこと。

- `test_brief_pages_are_stable_complete_and_filtered_on_the_server`
  - 主張：頁は新しい順で、ずれず、重ならない。絞り込みはサーバー側でする。
  - 確かめていること：130件が3頁になること、途中で足しても前の頁がずれないこと、4種類の絞り込み、返答60件が2頁で落ちないこと、壊れたcursorの拒否。
  - 抜け：
    - 件数が頁の長さのちょうど倍数になる場合は試していない（コードを読む限りは正しい）。
    - 状態で絞り込むと、全件をPythonで読んでから絞るので、件数が増えると遅くなる（性能の試験はない）。

- `test_body_limits_and_optional_references`
  - 主張：本文は空でなく、32KB以内。参照は任意で、正しい見出しだけを受ける。
  - 確かめていること：空白だけの本文は拒否、`'x'*(MAX+1)`は拒否、`'あ'*(MAX//3)`は受理、参照の4つの誤りは拒否。
  - 抜け：
    - 結論の4のとおり、バイトで数えるか文字数で数えるかを区別していない。
    - note（2,000字）の上限も試していない。

- `test_reading_records_nothing_and_inbox_lists_only_open_letters_to_me`
  - 主張：読んでも何も記録しない。受信箱は、自分宛てで開いているものだけ。
  - 確かめていること：inbox・letters・letterの前後で、letter_eventsとoperationsの行数が同じ。受信箱の並びと状態。
  - 抜け：
    - 結論の2のとおり、読み取りも書込みの鍵とschemaの作成を伴う。
    - 試験名とdocstringでは「未受領・受領・担当中」だが、実装は停止要請も受信箱に入れる（`OPEN_FOR_RECIPIENT`）。文言が実装と合っていない。

- `test_idempotent_operations_and_reused_ids`
  - 主張：同じ操作IDなら再送しても1回だけ。中身が違えば拒否。
  - 確かめていること：送信と受領の再送、行数が1のまま、中身の違いは拒否。
  - 抜け：
    - 再送の返答は、記録した結果ではなく、その時点の連絡の状態を返す。その後に出来事が進んでいれば、最初の返答とは違う。試験は`replayed`の旗しか見ていない。
    - 別の種類の操作で同じIDを使った場合（送信のIDで受領する）は試していない。

- `test_failure_rolls_back_text_event_and_operation`
  - 主張：失敗すれば、本文・出来事・操作がまとめて戻る。
  - 確かめていること：returnedとsendの途中で失敗させ、letter_texts・letter_events・operationsの行数が戻ること。
  - 抜け：sendは先に`letters`へ行を入れるが、試験は`letters`の行数を数えていない。改訂（revise）の途中の失敗も試していない。

- `test_append_only_tables`
  - 主張：連絡の3つの表は追記だけ。
  - 確かめていること：UPDATEとDELETEがtriggerで止まること。
  - 抜け：結論の1のとおり、`INSERT OR REPLACE`で置き換えられる。DROP TRIGGERもできる（ファイルに触れる者には止められない。限界として書くべきこと）。

- `test_concurrent_events_one_winner`
  - 主張：同時に受領しても、通るのは1つ。同じ操作IDの同時送信は1通になる。
  - 確かめていること：6本のthreadで受領1・拒否5、同時送信でIDが1つ。
  - 抜け：改訂と受領が同時に起きる場合（H-27の競合）は、順番に実行して試しているだけ。

### HttpTests

- `test_full_exchange_through_comm_cli`
  - 主張：comm.pyからHTTPを通して、一通りやりとりできる。
  - 確かめていること：送る・受信箱・見る・受ける（版が要る）・着手・返す・閉じる（送り手だけ）・一覧・送り手の一覧。メインthreadではSQLiteを直接開かない（guardで確かめている）。

- `test_line_endings_are_kept_from_files_and_standard_input`
  - 確かめていること：ファイルと標準入力から、CRLF・混在した改行・LFがそのまま保たれる。

- `test_stop_request_and_answer_through_comm_cli`
  - 確かめていること：理由のない停止要請は拒否、受信箱の`stopRequested`、途中成果つきの停止応答。

- `test_watch_reports_changes_once_and_never_loses_them`
  - 主張：watchは変化を1回だけ知らせ、失っても落とさない。
  - 確かめていること：GETは1回、受領を記録しない、新着・改訂・状態・停止要請、届かない場合と不明の場合で状態ファイルが動かない、状態ファイルが持ち主とサーバーに結びついていること、壊れたファイル11種類。
  - 抜け：`activity.EVENTS`を一時ファイルに差し替えるコードと、「OPS-184: watch also reads /activity-events」という注記が残っている。だが今の`comm.py`のwatchは/letters-inboxしか読まない。取り下げたOPS-184の名残（126f189a7）で、注記が実装と合っていない。

- `test_watch_save_failure_is_explicit_and_keeps_the_old_file`
  - 確かめていること：保存に失敗するとexit 4、前の状態ファイルが残る、一時ファイルが残らない、次の回にもう一度出る。

- `test_list_pages_through_comm_cli`
  - 確かめていること：50件と5件、`--all`で55件が2頁、重ならないこと、`--all`には`--brief`が要ること、壊れたcursorは400。

- `test_http_guards_and_queries`
  - 確かめていること：actionの食い違いは403、欠けは400、知らない連絡は409/404、問い合わせの誤り7種類は400、日本語の持ち主名。
  - 抜け：本文が大きすぎるHTTPリクエストと、JSONでない本文は、この試験にはない（`test-studio-store.py`にあるかは未確認）。

- `test_unreachable_server_sends_nothing`
  - 確かめていること：届かなければ何も記録されない。読めない本文ファイルなら送らない。
  - 抜け：結論の3のとおり。届いたが返答が失われた場合（不明）は、連絡では試していない。不明のときに操作IDが出力されないことも試していない。

## docstringの主張との対応

- 「Temporary files and servers only」：DB・activity.ROOT・EVENTSは一時ファイルに差し替えている。serve.pyを読み込んだときに本物の場所を読むかは、未確認。
- 「reading without side effects」：行は増えないが、鍵とschemaの作成はある（結論の2）。
- 「idempotency」：再送で二重にならないことは確かめている。再送で同じ返答が返ることは確かめていない。
