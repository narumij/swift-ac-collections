# 起動・更新経路の試験の精読

CP-20261020-011。

- 対象の試験：`test-serve.py`（`test_get_routes`・`test_post_guards`・`test_sync`）、`v3/test_serve_v3_mode.py`（12件）、`v3/test_v3_sync.py`（7件）
- 突き合わせた実装：`serve.py`（main・`runtime_fingerprints`・`sync`・`get_page`・`v3_mode`）、`sync.py`（main・main_v3）、`index.template.html`の更新ボタンと再起動の知らせ（`checkCanonicalRestartSuggestion`・`/server-status`）
- 基準：HEAD `78afefa93`
- 試験は実行していない。判断はすべてコードを読んでのもの。

重点の指定がなかったので、次の3点で読んだ。
1. 起動：設定の誤りや壊れた入力で、違うモードのまま、または古い出力のまま動き出さないか。
2. 更新（`/sync`）：失敗や中断で、前の正しい出力が壊れないか。確かめる前の出力が見えないか。
3. 知らせ：コードや正本の変化を、「再起動してください」「更新してください」として正しく出すか。

## 1. 起動

- 守られていること（試験あり）：
  - V3 modeの`--v3-db`と`--v3-saves`は一緒でなければならない。どちらも既にある必要があり、DBはschema・版・quick_check・exportを確かめる。違えば起動しない。ファイルも何も作らない（`test_arguments`、`test_refusals_create_nothing`）。
  - `--output`は既にあるディレクトリだけ（`test_missing_output_is_refused`）。
  - 起動時のsyncが失敗すれば、サーバーは起動しない（`check=True`）。
  - 実プロセスで、一時rootとport 0で起動できる（`test_isolated_launch`、`test_real_isolated_startup_and_refresh`）。
- 起動してしまうこと：
  - 切り替えのあとでも、旗なしで旧modeが起動する。Markdownから作ったページを出し、旧形式の保存をInboxに受ける。DB（`Data/registry.sqlite3`）があることを見て止める仕組みはない（#71でも任意の補強として後回しにした）。試験`test_default_mode_is_unchanged`は、むしろ旧modeがそのまま動くことを確かめている。
  - syncはportを取る前に走る。8088が使用中でも、先にsyncがCache（ページ・registry.json・tools記録）を書き換えてから、bindで失敗する。動いているサーバーの出力を、起動に失敗したプロセスが上書きする。試験はない。
- 試験の抜け：
  - 起動時のsyncが失敗した場合に、サーバーが起動しないことを実プロセスで確かめた試験はない（V3のsyncの失敗は`test_v3_sync.py`がsync.pyを直接呼んで確かめている）。

## 2. 更新（/sync）

- 守られていること（試験あり）：
  - 同時に2つの更新はできない。2つ目は409になり、鍵は成功・失敗・timeout・OSErrorのどれでも外れる（`test_sync`）。
  - 正本に問題があれば、何も書かない（`build()`のerrors）。
  - sync.pyは、書く前にregistry.jsonとindex.htmlを退避する。失敗すれば戻す。V3の道で、文書が欠けたときに前の出力が残ることを確かめている（`test_missing_db_document_fails_and_keeps_the_previous_output`）。
- 壊れたり、確かめる前の出力が見えたりしうること：
  - 旧modeのsync.pyで、失敗したときに戻す処理の試験がない。V3の道だけが試されている。
  - 書込みはその場で行う（`write_text`・`copy2`）。テンプレートを写してから種（seed）を埋め込み、文書を作り、最後に`verify.cjs`で確かめる。その途中にページを読むと、確かめる前の、または途中までのページが返る。ファイルを置き換える一瞬で切り替える形（一時ファイル→rename）になっていない。試験もない。
  - サーバーはsyncを300秒で打ち切る。打ち切るとsync.pyは強制終了され、戻す処理は走らない。出力は途中のまま残り、/tmpに退避の残りが残る。`test_sync`はtimeoutをmockで起こすだけで、出力がどうなるかは見ていない。
  - 戻す処理が受けるのは`CalledProcessError`・`OSError`・`ValueError`だけ。それ以外の例外（中断、データの型の誤りなど）では戻さない。
  - V3 modeでは、ページを開くたびにsyncの作った`index.html`を読む。読めないと例外が処理されず、JSONの返答も返らないまま接続が切れる。試験はない（試験の`get_page`は、正しくある場合だけ）。

## 3. 知らせ

- 守られていること：
  - 動いているサーバーが持っているコード（serve.py・inbox.py・activity.py・approvals.py・probe.py・continuity.py、V3 modeならv3の3つ）が起動のあとで変われば、`/server-status`が`restartRecommended: true`を返す。画面がそれを出す。
  - 正本（registry.json）が変われば、画面は30秒ごとと、画面に戻ったときに確かめて、更新を勧める。V3で、CLIで適用したあとに勧めが出ることを確かめている（`test_save_resume_cli_apply_and_restart_suggestion`）。
- 知らせが出ないこと：
  - サーバーは`studio_store.py`（連絡とPINGの処理）を読み込んでいるが、見張るファイルの一覧に入っていない。連絡DBのコードを直しても、「再起動してください」が出ない。
  - 試験は`runtime_status`をmockにして、経路だけを確かめている。「読み込んでいるモジュールが、すべて見張る一覧に入っているか」を確かめる試験がないので、この漏れに気づけない。

## まとめ

- 起動の設定の確かめ（V3の旗・DBの形・出力先）と、更新の同時実行の禁止は、しっかりしている。
- 弱いところは4つ。
  1. 切り替えのあとでも旧modeで起動でき、syncがportを取る前に走るので、起動に失敗したプロセスが動いているサーバーの出力を書き換える。
  2. 更新はその場で書き換えるので、途中や確かめる前のページが見える。打ち切りや想定外の例外では、元に戻らない。旧modeで戻す処理の試験もない。
  3. `studio_store.py`が、再起動を勧めるための見張りから漏れている。それを見つける試験がない。
  4. V3 modeでページの元ファイルが読めないと、返答なしで接続が切れる。

表示との接続の試験は、次に読む。
