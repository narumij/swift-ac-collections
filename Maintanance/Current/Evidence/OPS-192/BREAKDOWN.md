# OPS-192 境界の地図と作業内訳（根拠）

base `b2c380288`。読み取りだけで調べた。行番号は`Maintanance/RegistryApp/`の中のもの。

## 1. 境界の地図（今）

1つのプロセス（`serve.py`、既定port 8088）が、次のすべてを抱えている。

| 関心ごと | サーバーの口（serve.py） | 保存先 | CLI | CLIの道 |
|---|---|---|---|---|
| 画面 | `GET /`・`/index.html`・`/registry.json`（`get_page` 266）、`/server-status` | Cache（`OUTPUT`）、V3 modeはDBを読み取り専用 | — | — |
| 保存・更新 | `POST /save`（540）、`GET /workspace`（259）、`POST /sync`（474、`sync.py`を実行） | Inbox、Cache | `inbox.py` | ファイルに直接 |
| 連絡 | `GET /letters*`（`get_letters` 298）、`POST /letters-send・event・revise・senders`（`studio_records` 424） | `Approvals/approvals.sqlite3` | `comm.py letter …` | HTTPだけ（`studio_client`、既定 `http://127.0.0.1:8088`、22行） |
| PING・ACK | `POST /comm-ping・ack・cutover`、`GET /comm-messages`（`get_comm` 158） | 同じDB | `comm.py ping・ack` | HTTPだけ |
| 承認 | `GET・POST /commit-approvals`（`get_approvals` 128・`commit_approvals` 491）、`POST /approvals-cli`（`approvals.run_cli_command`） | 同じDB | `approvals.py add・list・claim・finish・abandon` | HTTPだけ |
| 疎通 | `/approval-probe` | `Approvals/probe.sqlite3`（上書きの道なし） | — | — |
| 作業イベント | `GET /activity-events・commits`、`POST /activity-wake`（517） | `Activity/events.jsonl` | `activity.py` | ファイルに直接（fcntlの鍵） |
| 連続の印 | `GET /continuity` | `Activity/continuity.json` | `continuity.py` | ファイルに直接（fcntlの鍵） |
| Registry V3 | 読み取りだけ（`v3_open` mode=ro） | `Data/registry.sqlite3` | `v3/registry_v3_cli.py` | DBに直接（webを通らない） |
| 判断DB | なし | `Data/decision-assist.sqlite3` | `decisions/decision_cli.py` | DBに直接 |

同じプロセスに頼っているところ：

- 連絡・PING・承認のDBを開くのは、`serve.py`だけ。テスト以外で`studio_store.Store(`・`approvals.Store(`・`probe.Store(`を呼ぶのは`serve.py`だけ（grep）。
  - これは規則として書かれている（`approvals.py` 4行「only the Studio server opens the database」、`serve.py` 425行）。
  - `comm.py`と`approvals.py`のCLIはHTTPでしか書かない（`studio_client`）。
- だから、画面サーバーを止めると、CLIの連絡・承認も止まる。
  - 実例：2026-10-20 14:40ごろ、8088が止まっている間に`comm.py letter inbox`は「not reachable; nothing was sent」になった。OPS-191の手紙も、送り直しが必要になった。
- ページは、連絡・承認・作業イベント・連続の印を、同じoriginの相対URLで取る。
  - 連絡：`letterListQuery`、`'/letters/'` 1602行
  - 承認：`endpoint="/commit-approvals"` 1644行
  - 作業イベント・連続の印：1354・1622行
  - POSTの受付は、同じoriginであることとヘッダの値で確かめている（`studio_request` 372行）。
- 作業イベント・連続の印は、CLIがファイルに直接書く。サーバーが止まっても書ける。止まるのは画面の表示だけ。

## 2. 分け方（推奨）と区切り

分けるのは「連絡・PING・承認」だけ。保存先は今の`approvals.sqlite3`を1つのまま使い、開くのは新しい共通サービスだけにする。画面サーバーはDBを開かず、その口を共通サービスへ中継する。作業イベント・連続の印・保存・更新・Registry・判断DBは、今のまま動かさない。

| 区切り | 段階 | ファイル | 成果 | 受入の試験 | 前提 | 大きさの目安 |
|---|---|---|---|---|---|---|
| R1 | 3 | 新しい`records_service.py`（`serve.py`の`get_letters`・`letter_action`・`studio_records`・`commit_approvals`・`get_approvals`・`get_comm`を移す）。`serve.py`はそれをimportして使う。 | 共通サービスが1人で起動でき、連絡・PING・承認の口を出す。`serve.py`の今の振る舞い（1プロセス）は変わらない。 | 既存の`test-studio-letters.py`・`test-studio-store.py`・`test-approvals.py`・`test-serve.py`が通る。新しい試験：共通サービスだけを実プロセスで起動し、`comm.py`で送る・受ける・返す、`approvals.py list`が通る。 | OPS-191 | 移すのが約250行、新しい試験が約120行 |
| R2 | 4 | `serve.py`に`--records-url http://127.0.0.1:<port>`（明示したときだけ）を足す。そのときは連絡・PING・承認の口を共通サービスへ中継し、自分ではDBを開かない。中継するとき、Originとヘッダの値は共通サービス向けに付け替える。 | 画面が共通サービスの利用側になる。旗がなければ今と同じ。 | OPS-187・188の実接続試験を、画面＋共通サービスの2プロセスで通す。画面プロセスがDBを作らない・開かないこと（DBの場所を、まだない場所に向けて確かめる）。 | R1 | 約100行と、試験の2〜3件 |
| R3 | 5 | 新しい`test-service-separation.py`（2プロセスの実起動）。 | 画面を止めても連絡・承認が続くことと、戻した画面が同じ記録を読むことの証拠。 | 下の3 | R2 | 約200行 |

## 3. 証明する試験と、確かめる必要のある点

R3で、実プロセス・一時の保存先・試験用portを使って確かめる。

1. 共通サービスと画面を起動し、画面を止める。その間に`comm.py letter send・receive・return`、`comm.py ping・ack`、`approvals.py add・list`が成功する。
2. 画面を起動し直す。ページ（WebKit）が、止めている間に書かれた連絡と承認を表示する。`letters_e2e.cjs`と`approvals_e2e.cjs`の手順を使い回す。
3. 共通サービスを止めると、CLIは「not-sent」で、何も記録しない。ページは「取得不調・最後に読めた内容」を出し、操作を止める。共通サービスを戻すと、両方とも戻る。

確かめる必要のある点（今は試験がない）：

- 書き手を1つにすること：共通サービスを2つ同じDBで起動したら、2つ目が起動を拒むこと。今は「開くのは1つのプロセスだけ」が規則でしかない。R1で、鍵（fcntl）と、その試験を足す。
- 画面がDBを開かないこと：R2の試験で確かめる。
- 中継の失敗：共通サービスが返答の途中で止まった場合に、画面から見て「不明」になること。今の承認の画面は、409・timeout・失敗を区別している（`test-approvals.cjs`）。中継しても、それが保たれること。
- 再送：`comm.py letter send`は、返答が失われたときに操作IDを表示しない（CP-20261020-006の精読）。分けると、プロセスの境目で「不明」が増えるので、この穴の影響が大きくなる。R3で「不明のときの再送」を試験に入れ、直すかどうかを決める。

## 4. 本番の切り替え・戻し、あとの統合に残ること

- 本番の切り替えで決めること（ユーザーの判断）：
  - 共通サービスのport番号と、だれがいつ起動・停止するか（画面と別に動かすので、起動の手順が1つ増える）。
  - 推奨：画面は8088のまま、共通サービスは新しい固定port。CLIの既定（`studio_client.DEFAULT_URL`）をそちらへ変える。
- 戻し：旗（`--records-url`）を付けずに`serve.py`を起動すれば、今の1プロセスの形に戻る。DBは同じ1つなので、記録の移し替えはいらない。
- あとの統合に回すこと（今回は動かさない）：
  - Registry V3と判断DBは、CLIが直接書く。
  - 作業イベント・連続の印は、CLIがファイルに直接書き、画面の`/activity-wake`もjsonlに書く。2つの書き手がfcntlの鍵で並んでいる。
  - これらを共通サービスに寄せるかは別の区切り。
