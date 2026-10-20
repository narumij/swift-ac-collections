# OPS-192 スレッドを辿る：最小案（根拠と内訳）

base `1f57c5f65`。今のコードを読んで調べた（行番号は`Maintanance/RegistryApp/`）。試作はしていない。下の主張のうち、今のコードについてのものは読んで確かめた。設計は案。

## 今のコードで確かめたこと

- `letters`の表は7列で固定（`approvals.py` STUDIO_SCHEMA）。ほかの連絡を指す列はない。連絡どうしの関係を表すのは`task_id`だけ。
- 読む口：
  - `GET /letters/<id>`は、パスの残りをそのまま連絡IDとして`store.letter()`に渡す（`serve.py` `get_letters` 末尾）。`/letters/<id>/thread`のようなパスは、今は「IDとして不正」で400になる。
  - 読むだけでは何も記録しない（`test_reading_records_nothing…`）。
- 書く口：
  - 送信は`letters-send`の決まった欄だけを受ける（`LETTER_FIELDS`）。
  - 送信は1つの取引で、操作・連絡・本文・`sent`の出来事を書く（`studio_store.send`）。
  - 追記だけの表はtriggerで守る（`approvals.transaction`）。
- 今回の4通（連絡DBで確かめた）は、どれも互いのつながりを持たない。

| 連絡 | 状態 | 本文の版（字数） |
|---|---|---|
| 9FE8ADAB… | closed | request v1（2,143）・reply v1（282）・request v2（3,487） |
| E9929557… | closed | request v1（3,898）・reply v1（328） |
| FBDD4946… | closed | request v1（1,286）・reply v1（344） |
| F30EDE7D… | started | request v1（1,558） |

E9929557の3,898字のうち2,143字は、9FE8の元の依頼をそのまま写したもの（本文の先頭から「Correction round … not a duplicate assignment」のあとに、元の依頼の全文が続く）。

## 案：明示の「続き」のつながり

- 新しい表`letter_links(letter_id PRIMARY KEY REFERENCES letters(id), follows_id NOT NULL REFERENCES letters(id), recorded_by, received_at, operation_id REFERENCES operations(id))`。
  - 1通につき1つだけ、それが続いている前の連絡を指す。
  - UPDATEとDELETEは、ほかの表と同じtriggerで止める。
- 送るときに付ける：`send(…, follows=ID)`。
  - 同じ取引でつながりも書く。
  - payloadに入れるので、再送しても重複しない。
  - 拒否する場合：
    - 前の連絡がない。
    - 送り手が、前の連絡の送り手でも宛先でもない。
  - 前の連絡は送る時点でもうあるので、循環はできない。
- 前からある連絡（つながりなし）：
  - 自動ではつながない。task IDや本文から推測しない。
  - 後からつなぐときは`link`の操作を使う。
    - その連絡の送り手だけが、1回だけ、明示してつなぐ。
    - 理由を書く。
    - 記録は追記だけ。
  - つながりがなければ、その連絡だけで1通のスレッドになる。
- スレッド：`follows`をたどって根まで上がり、根から下の連絡を全部集める（木）。並びは送信の時刻順。
  - 閉じた連絡も含める。
  - 本文はすべての版をそのまま返す（`letter()`と同じ）。
- 読む：`GET /letters/<id>/thread`。どの連絡から始めても、同じ集まりが返る。
  - 各連絡について返すもの：一覧と同じ見出し（ID・task・送り手→宛先・状態・送信と受領の時刻）、`follows`、そのIDで本文を引く場所。
  - 本文の全体は、今の`/letters/<id>`で1通ずつ読む。
  - 読むだけで、受領・着手・状態は何も変えない。
- CLI：
  - `comm.py letter send … --follows LTR-…`
  - `comm.py letter thread LTR-… [--full]`（`--full`は本文も出す）
  - `comm.py letter link LTR-… --follows LTR-… --actor 送り手 --note 理由`
- 画面：連絡の詳細の下に「スレッド」を出す（各連絡の1行で、選んでいる連絡に印を付ける）。1行を押すと、今の`letterSelected`でその連絡を選ぶ。選ぶだけで、受領にはならない（今と同じ）。POSTはしない。

## 短い補正の例（手作業の例。本番のDBは触らない）

今回の3通につながりがあれば、こうなる。

- 9FE8ADAB（根）← E9929557（`--follows 9FE8ADAB…`）← FBDD4946（`--follows E9929557…`）← F30EDE7D（`--follows FBDD4946…`）
- E9929557の本文は、元の依頼を写さずに次だけで足りた（約1,750字。3,898字から写しの2,143字を除いた分）：
  > Review round 1 — NOT ACCEPTED, discovery correction only. Keep implementation paused. The assignment and base are in the followed letter (9FE8ADAB…, request v1). 1. Rollback must cover … 2. Define the lock scope … 3. Explain preservation of relay … User added: … Astra found a separate delivery gap: …
- 受け手は、E9929557から`comm.py letter thread E9929557…`で9FE8ADABの依頼v1・返答v1・依頼v2を読める。読むだけで、受領や着手にはならない。

## 返したあとの改訂の穴との関係

- つながりがあれば、返したあとの補正は「続きの連絡」として送れる。新しい連絡なので、今のinboxとwatchにそのまま届く（watchを変えなくてよい）。
- 推奨：returnedのあとの`revise request`を拒否し、「`--follows`で続きの連絡を送る」と返す。返す前の改訂は、今のまま。
  - これで「返したあとの改訂が届かない」穴が、保存の段でなくなる。
  - 補正2回目の案（`answers_revision`と、出た連絡の印を残すwatch）は要らなくなる。
  - 今ある操作を1つ止めることになるので、採るかどうかは利用の決めごと。下の「決めること」にした。
- 採らない場合は、補正2回目の案（`answers_revision`、出た連絡の印を残すwatch）が要る。

## 区切り（分離R1〜R3との順）

| 区切り | ファイル | 成果 | 受入の試験 | 前提 | 大きさの目安 |
|---|---|---|---|---|---|
| R1 | （分離のR1のとおり） | 共通サービスの抽出 | （R1のとおり） | OPS-191 | — |
| T1 | `approvals.py`（表とtrigger）、`studio_store.py`（`send`のfollows、`thread`、`link`）、`records_service.py`（`/letters/<id>/thread`、`letters-link`）、`comm.py`（`--follows`・`thread`・`link`） | 店とCLIにつながりとスレッドを足す | 次の箇条書き | R1（口はサービスに足す。`serve.py`に足してから移す二度手間を避ける） | 店が約80行、口とCLIが約60行、試験が約150行 |
| R2 | （分離のR2のとおり） | 画面の中継。`/letters/…`を中継すれば、threadも通る | （R2のとおり） | R1 | — |
| T2 | `index.template.html`（連絡の詳細のスレッドの欄）、`test-view-model-letters.cjs`、`letters_e2e.cjs`の手順を足す | 画面で辿れる | 次の箇条書き | T1、R2 | 約60行と試験 |
| R3 | （分離のR3のとおり） | 停止と再起動の試験に、threadの読み取りも入れる | — | R2・T2 | — |
| T3（採るとき） | `studio_store.revise` | returnedのあとの依頼の改訂を拒否し、続きの連絡へ案内する | 次の箇条書き | T1 | 約10行と試験 |

T1の試験：

- `--follows`で送れる。どの連絡から始めても、同じ集まりが同じ順で返る。
- 閉じた連絡も入る。本文の版はすべて元のまま。
- 拒否される場合：
  - 前の連絡がない。
  - 送り手が当事者でない。
  - 2回目の`link`。
  - つながりのある連絡への`link`。
- 再送で重複しない。
- `thread`を読んでも、letter_eventsとoperationsの行数が変わらない（受領にならない）。
- つながりのない古い連絡は1通のスレッドになる。task IDが同じでも混ざらない。

T2の試験（WebKit、実サーバー）：

- 受け取った連絡の詳細に、スレッドの前の連絡が出る。
- 押すとその本文が出る。サーバーにはGETしか届かず、受領が記録されない。

T3の試験：

- returnedのあとの`revise request`はConflictになり、続きの連絡を案内する。
- 返す前の改訂は、今のまま通る。

## 決めること（ユーザー・Astra）

- 返したあとの補正を、続きの連絡に限るか（T3）。推奨は限ること。限らなければ、補正2回目の案が要る。
- 前からある連絡を後からつなぐのは、送り手本人だけにするか。推奨はそう（`link`）。今回の3通を実際につなぐかどうかも、ここで決める（今回は手作業の例だけ）。

## 補正（2026-10-20、LTR-20261020-AB381233…への回答）

前の版の「区切り」「返したあとの改訂の穴との関係」「決めること」のうち、下と食い違うところは、この節で置き換える。

### 1. 後からのつなぎ（link）は、初めの範囲から外す

- 送るときの`follows`は、もうある連絡しか指せない。だから、新しい連絡では自分自身を指すことも、循環もできない。初めの範囲は、これだけにする。
- 後からの`link`は、自分自身を指すつながりや循環を作れてしまう。たとえば、古い連絡Aが新しい連絡Bを指すと、BがAを指すつながりと合わせて輪になる。この安全の決まりと試験がそろうまで、範囲に入れない。
- 前からある連絡は、つながりのない1通のスレッドのまま。task IDや本文から推測してつなぐことはしない。
- 後で入れるときの最低限の決まり：
  - 指す先は、その連絡より前に送られたもの（送信の時刻で比べる。同じ時刻なら連絡の`rowid`で比べる）。
  - 自分自身は指せない。
  - つながりのある連絡は、もうつなげない。
  - 試験：自分を指す・自分より新しい連絡を指す・2回目、をそれぞれ拒否する。

### 2. 軽い一覧と、本文の全体を分ける

- `GET /letters/<id>/thread`と`comm.py letter thread <id>`は、本文を読まない軽い一覧にする。
  - 各連絡について：ID・task・送り手→宛先・状態・送信と受領の時刻・`follows`・依頼と返答の最新の版の番号。
  - 一覧の`letters_brief`と同じく、本文の列はSELECTしない。
- 本文のすべての版が要るときは、今の`GET /letters/<id>`で1通ずつ読む。
  - `comm.py letter thread <id> --full`は、一覧の各IDについて`/letters/<id>`を読んで並べるだけ。新しい口は作らない。
- 画面：一覧の行だけを出す。1行を押すと、今の詳細の読み込み（`/letters/<id>`）でその本文を出す。

### 3. 最小の段階案（今ある改訂の扱いは変えない）

- 範囲は「新しく送る、明示の続きの連絡」と、それを読んで辿るCLI・画面だけ。
- 次のものは変えない：
  - 改訂の権限（returnedのあとの改訂も今のまま）。
  - 前からある連絡のつながり（推測しない）。
- 返したあとの改訂が通知されない穴は、この範囲では直さない。別の項目として開いたまま残す。
  - 前の版では、改訂の禁止を推奨し、「禁止しなければ`answers_revision`が要る」と二択のように書いた。どちらも、スレッドの要求から出てくるものではない。二択であることも確かめていない。だから取り下げる。
  - 直し方の候補（補正2回目の案ほか）は、その項目で別に決める。

| 区切り | 中身 | 受入の試験 | 前提 |
|---|---|---|---|
| T1 | `letter_links`（追記だけ）、`send(follows=)`、`thread`（軽い一覧）、`comm.py letter send --follows`・`letter thread [--full]`、口`/letters/<id>/thread` | 下のT1 | R1（口は共通サービスに足す） |
| T2 | 連絡の詳細にスレッドの行を出し、押すとその本文 | 下のT2 | T1・R2 |
| 後で決める | 後からのlink（決まりは1）、返したあとの改訂の穴（T3ほか） | それぞれの決定のあとで | — |

T1の試験：

- 送ったときの`follows`：
  - もうある連絡を指して送れる。
  - ない連絡を指すと拒否する。
  - 送り手がその連絡の当事者でないと拒否する。
  - 再送しても、つながりは重複しない。
- `thread`で返る集まり：
  - どの連絡から始めても、同じ集まりが同じ順で返る。
  - 閉じた連絡も入る。
  - つながりのない古い連絡は、1通だけになる。
  - task IDが同じでも、つながりのない連絡は混ざらない。
- 読み取りは何も記録しない：
  - `thread`を読んでも、letter_eventsとoperationsの行数が変わらない。
  - 実行したSELECTに、本文の列がない（`test_brief_list_reads_no_text`と同じ方法）。
- `--full`で返る本文は、すべての版が`/letters/<id>`と一致する。

T2の試験（WebKit、実サーバー）：

- 受け取った連絡から、前の連絡の行が見える。
- 押すとその本文がそのまま出る。
- サーバーにはGETしか届かず、受領は記録されない。
