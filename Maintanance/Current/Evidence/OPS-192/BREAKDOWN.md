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

## 補正1回目（2026-10-20、LTR-20261020-E9929557…への回答）

### A. 戻し：止める・DBの持ち主を手放す・CLIの宛先を戻す

- CLIの宛先：`studio_client.server_address()`が、`REGISTRY_STUDIO_URL`、なければ`DEFAULT_URL = 'http://127.0.0.1:8088'`を使う（22・33行）。この2つ以外の宛先指定は、リポジトリ（Evidence・Archived・試験を除く）にない（grep）。
- 本番の切り替えで、共通サービスを8088以外にしてCLIの既定を変えた場合、戻しは次の順にする。
  1. 共通サービスを止める。DBの持ち主の鍵が外れる。外れたことは、次の手順の起動が鍵を取れることで確かめる。
  2. `serve.py`を`--records-url`なしで起動する。1プロセスの形に戻り、鍵を取り直す。
  3. CLIの宛先を戻す。`DEFAULT_URL`を8088へ戻す（コードの差し戻し）か、`REGISTRY_STUDIO_URL`を消す。
- 戻しの試験（R3に足す）：上の1〜3のあと、環境変数を何も付けない`comm.py letter inbox`と`approvals.py list`が、1プロセスの`serve.py`に届き、切り替えの前と同じ記録を返す。
- 本番のport番号とだれが起動するかは、今回の調査では決めない（切り替えのときに決める）。試験は、今の`REGISTRY_STUDIO_URL`で一時のportを指せば足りる。

### B. 書き手を1つにする鍵：範囲・取る・放す、両方の形での衝突

- 範囲：DBのファイルごと。対象は`approvals.sqlite3`（連絡・PING・承認・operations）と`probe.sqlite3`（`/approval-probe`）。どちらも共通サービスへ移すので、画面のプロセスはDBを1つも開かない。鍵のファイルはDBの隣に置く（`<db>.owner.lock`、fcntlの排他）。
- 取る：
  - 単独の共通サービス：起動のとき、portを取る前に取る。
  - 1プロセスの互換の形（`serve.py`、`--records-url`なし）：起動のとき、syncとportの前に取る。
  - 取れなければ、何もせずexit 1で止まる。
  - `--records-url`ありの`serve.py`は取らない（DBを開かない）。
- 放す：プロセスが終わるとき（fcntlなので異常終了でもOSが外す）。持っている間に途中で放すことはない。
- 店（`Store`）の層には鍵を入れない。入口（起動）だけで取る。試験の中で`Store`を直接使う既存の試験は、そのまま動く。
- 衝突の試験（R1、実プロセス、同じ一時DB）：
  1. 共通サービス→2つ目の共通サービス：2つ目が拒む。
  2. 共通サービス→`serve.py`（互換）：互換が拒む。
  3. `serve.py`（互換）→共通サービス：共通サービスが拒む。
  4. 共通サービス→`serve.py --records-url`：両方とも動く。
  5. 1〜3で拒んだ側は、DBにもoperationsにも何も書かない（DBのbytesで確かめる）。
  6. 先の側を止めると、後の側が起動できる（異常終了で止めた場合も含む）。

### C. 中継の結果：送れなかった（not-sent）と、結果が分からない（unknown）を画面まで保つ

- 画面サーバーの受付：元の確かめ（localであること、Originが画面のorigin、`X-Registry-Studio`の値。`studio_request` 372行）は、今と同じに画面側で先に行う。通らなければ403で、共通サービスには何も送らない。
- 通った依頼だけを中継する。出ていく側のHostとOriginを共通サービス向けに付け替え、`X-Registry-Studio`の値は引き継ぐ。共通サービスは、それを自分の規則で確かめる。
- 結果の対応：
  - 共通サービスにつながらない（接続の前に失敗）→ 503 `{"error":…, "outcome":"not-sent"}`
  - 送ったあと返答がない、または途中で切れた → 504 `{"outcome":"unknown"}`
  - 共通サービスの返答（2xx・4xx・5xx）→ statusと本文をそのまま返す
- 画面の扱い：
  - 承認のcontrollerは、200以外を失敗として「最終情報を保持・操作停止中」にし、次の読み込みで本当の状態を出す（`createApprovalController` 1644行）。
  - unknownのときだけ、文言を「結果不明：一覧で確かめ直します」にする（既存の失敗表示の文字だけを変える）。
  - 連絡は読むだけ（GET）なので、今の「取得不調・最後に読めた内容」で足りる。
- 試験（R2）：
  1. 誤ったOrigin → 403で、共通サービスへの接続が0。
  2. 共通サービスが止まっている → 503 not-sentで、DBは変わらない。
  3. 受け付けてすぐ切る相手（その場で書いた最小のsocket相手。障害を起こすためだけに使う）→ 504 unknown。
  4. 正常 → 共通サービスの返答と、bytesまで同じ。

### D. 受領の遅れ（約72秒）の実際の流れ

最初の連絡（LTR-20261020-9FE8ADAB…）。時刻は連絡DBとactivityの記録で、UTC。

| 時刻 | 出来事 | 出典 |
|---|---|---|
| 05:58:12.590 | 送信 | letter_events `sent` |
| 05:58:47 | 姫が連続待機を始めた（それまでは会話に答えていて、見張っていなかった） | activity 547行 `連続待機` |
| 05:58:48 | 監視が新着を検知（待機を始めて最初の確認） | 待機の出力 `letters changed 14:58:48` |
| 05:58:48〜05:59:25 | 本文を読み、Registryの行・base・正本の文書を確かめてから受領した | 姫の操作（記録なし。この間の時刻は推定） |
| 05:59:25.081 | 受領 | letter_events `received` |

- 内訳は、見張っていなかった時間が約35秒、検知が1秒以内、受領の前に読んで確かめていた時間が約37秒。
- 連絡DBの遅れは見当たらない。送信の時刻と、`show`で本文が読めた時刻の間に遅れはない。
- 待機の確認は5秒ごとなので、待機している間の検知は最大5秒遅れる。補正の連絡（E9929557…）は、送信06:05:31.777→検知06:05:35（4秒）→受領06:06:10.599。受領の前に本文と受入の欄を読んだ時間が約35秒。
- 仕組みの不具合ではない。改めるのは姫の手順で、本文の版を読んだらすぐ受領し（受領は読んだ版を名指す）、Registryや正本の確かめは着手の段で行う。最小の試験は要らない（仕組みは変えない）。

### E. 返したあとの改訂が届かない（Astraが確かめた穴、再現した）

- 仕組み：
  - `revise`は状態を変えない（`studio_store.py` 305行のdocstring）。
  - `inbox`は`OPEN_FOR_RECIPIENT = {'sent','received','started','withdrawn'}`だけを返す（143・373行）。
  - `comm.py letter watch`は`/letters-inbox`だけを読む。
  - だから、返したあと（returned）の依頼の改訂は、受け手の監視に出ない。
- 実際に起きた：
  - 改訂は06:03:13.565（request v2）。
  - 姫の待機の監視は15:00:52（JST）から動いていたが、これを検知しなかった。
  - 検知したのは、06:05:35の新しい連絡だけ（待機の出力）。
- 直す候補（実装しない）：`inbox`が、状態がreturnedでも、最後に本人が返したあとに依頼の改訂がある連絡を含める。目印は`revisedAfterReturn: true`。比べるのは、最後の有効なreturnedの出来事のsequenceと、最新のrequestの本文のsequence。`watch`は今のままでも、版が変わったことを`revision`として出す。
- 最小の試験：
  1. 送る→受ける→着手→返す→送り手が依頼を改訂する。
  2. `inbox('姫')`がその連絡を含み、`revisedAfterReturn`がtrueになる。
  3. `comm.py letter watch`が`['revision']`を一度だけ出す。
  4. 改訂のない返した連絡は、inboxに出ない（今と同じ）。
  5. 送り手が閉じたら（closed）出ない。
- 受け手がどう答えるか（返答の改訂か、新しい連絡か）は、今の遷移のままで足りる。returnedのあとでも、受け手は`revise reply`ができる。
