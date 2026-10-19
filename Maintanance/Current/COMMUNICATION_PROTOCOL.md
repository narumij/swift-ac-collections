# 共同作業の通信規約 — 初版（OPS-130）

版：0.4 / 2026-10-19 / 作成：Astra（0.2・0.3の追記：姫）。親OPS-048。

ユーザー要求：手順省力経路とフルマニュアル経路を備え、実運用を踏まえて定期的に見直し改訂する。本書は二系統に共通する受渡しの要求と意味の正本。権限はAGENTS.md・正式依頼の既存規定に従う。CLI/HTTP/表示の具体的手順は[Studio README](../RegistryApp/README.md)、試行の証拠は[OPS-128/129](STUDIO_OPERATION_REVIEW.md)。本書の版とイベントのschemaVersionは別である。

## 1. 二つの経路

| 経路 | 実行方法 | 成立条件 |
| --- | --- | --- |
| 手順省力 | 必要情報をまとめて道具へ渡し、検査・記録・通知の一部をまとめる | 実施できた範囲と結果が確認でき、手動と同じ受渡し情報が残る |
| フルマニュアル | 担当が正本確認、記録、通知、受信確認を一つずつ行う | 同じ必要情報と権限境界を満たす。道具の内部状態を唯一の根拠にしない |

フルマニュアルはJSONLや承認DBを直接編集することではない。通常の会話と正本で受け渡せ、利用できる単機能CLIを個別に使ってもよい。Studioや通知CLIが使えないときは、正本の受渡し欄に内容を保存し、通常の会話で相手またはユーザーへ参照を渡す。現状のXcodeの姫とこの会話の間では、通常会話による直接送信経路は用意していないため、通知経路が使えなければユーザー仲介を頼む。別環境で直接会話へ送る手段がある場合だけ、その手段と権限を確認して使う。相手から応答がなければ未達/未確認として残す。表示が更新されていないことと、仕事の状態を区別する。

経路によって、依頼権限・成果の正しさ・受入・コミット許可は変わらない。省力側にだけ別の正本を設けない。人間による直接依頼も既存の合流経路を維持し、省力ツールを使わないことだけで無効にしない。

## 2. 通知の意味と必要情報

全通知で「対象の仕事・送信者・種別・内容/参照・発生時点」を特定できること。形式的フィールドがない会話では本文や会話の文脈で明示する。過去の時刻を推定で埋めない。

| 種別 | 意味 | 追加で必要な情報／成立の限界 |
| --- | --- | --- |
| 依頼 | 定めた範囲を相手へ渡す | 宛先、正式な依頼参照、完了条件・境界。通知だけでは権限を与えない |
| 受信ACK | 特定の依頼/通知を受け取った | 対応する依頼または通知。着手・完了・受入の意味を持たない |
| 着手 | 本人が実際に開始した | 対象範囲。受信ACKから自動推定しない |
| 成果返却 | 成果を確認相手へ渡す | 対応依頼、結果/証拠の参照、残件/限界、次担当。返却は受入ではない |
| 受入 | 権限のある担当が範囲を検証した | 対象の返却、受入範囲・根拠、残件、次の受渡し。送信成功を根拠にしない |
| 再依頼 | 確認結果を受けて限定作業を渡す | 元の返却、直す点・境界・返却先。古い完了を新依頼へ持ち越さない |
| 待機開始 | 本人が連絡待ちに入った | 本人・待つ対象。現行のtask IDは記録上の関連先であり、在席は本人単位。沈黙から推定しない |
| WAKE / ACK | 指定した連続待機を終了する合図と受信確認 | 一意のWAKE識別子と対応ACK。閉じた会話を起動する保証ではない |
| 区切り完了 / 全体終了 | 定めた仕事の範囲が終わった | 終了範囲と残件。commit単独から全体終了を推定しない |

各通知に全情報を複写せず、正本の特定箇所への参照を使える。相手が参照できなければ必要内容を渡し直す。コミット承認・claim/finishは既存の別契約のまま扱う。

### 情報更新依頼（UPDATE、OPS-137）

新しい仕事を頼むほどではないが、相手が持つ記録や状態を今の事実に合わせてほしいときに使う。仕事の発注・権限の追加・他者の記録を代わりに直す許可ではない。PING（届いたかの確認）やWAKE（待機の終了）とも別のもの。

- **送り方**（通常の会話か正本の該当欄で送る。既存のCLIを使ってもよい）：一意の番号`UPDATE-YYYYMMDD-X`（末尾は大文字の英数字、使い回さない）に、宛先・対象（文書や記録とその箇所）・直してほしい項目・返答先を添えて、1回送る。CLIで送るなら`activity.py --event request --owner <送信者> --next <宛先> --reason 'UPDATE-…：<対象>の<項目>'`（返答先の節は`--doc/--section`）。
- **返し方**：宛先の本人が自分の記録を確かめ、同じ番号で次のどれかを1回返す。
  - `UPDATE-… 更新済み`（どこを直したか）
  - `UPDATE-… 変更不要`（理由）
  - `UPDATE-… 範囲外`（通常の依頼や持ち主の判断が必要な理由）
  受け取っただけの返事（`ACK UPDATE-…`）は受信の確認で、更新が済んだことを意味しない。
- **閉じ方**：送信者が、番号・宛先・返答の内容を照合して閉じる。返事がなければ「未応答」として残す。沈黙を「変更不要」と読まない。再送するときは同じ番号で再送だと書き、別の件なら新しい番号を使う。
- **境界**：記録の訂正も、占有と権限の範囲に従う。宛先以外の者が代わりに書き換えない。ユーザーの確定事項や他者の判断を変える依頼には使わない。そういう内容なら、通常の依頼か持ち主への相談に切り替える。
- **現状の制約**：専用のUIと自動の照合は未実装。StudioはUPDATEを特別に扱わない（特別扱いはPING・WAKEとそのACKだけ）ので、CLIで送ったUPDATEとその返事は、作業レーンに通常のイベント（例：「依頼済み」）として出る。

### Member status (0.3, OPS-141)

For each member, keep three things separate and never infer one from another:

- **Declared state**: `working` (作業中), `waiting` (待機中), `ended` (待機終了). Only the member's own explicit presence changes it. Practical records, requests, PINGs and ACKs do not change it. Without a declaration it is "未申告" (not declared).
- **Last activity**: the type and time of the member's last practical record (excluding state notices and probes). It is not read as "working". A state notice is a work record with a presence, except a confirmed start (below).
- **Confirmation freshness**: the time of the member's own continuity mark (`continuity.py`). Over 55 s it is shown as "確認が古い" (confirmation is old); the declared state is not changed. Continuity `ended` means the end of a continuous run, which is different from the end of a wait. No mark is "未確認"; a failed read is "不調".

Rules:
- A return and the next state may be recorded together (`--event return --presence waiting`). Such a return stays in the work lane.
- Start (OPS-151): a member's first record for a request starts its `reason` with that request's ID (`H-20261019-05着手：…`, `D-20261019-02：…`). A work record with `presence=working` whose leading ID matches an earlier request of the same task addressed to that member is a **confirmed start**: it appears in the work lane as "着手". Other work records with a presence stay state notices.
- 開始待ち (start pending, OPS-151): a request whose `reason` starts with an ID (not PING / WAKE / UPDATE) and whose `next` is a member shows "開始待ち <ID>（sender time）" in that member's status, next to the declared state, which it never changes. Only that member's own record with the same ID and task closes it: a working, an ended or a return. A waiting with that ID leaves it open. A declaration without the ID, or with another ID (an old WAKE ACK, an earlier ended), never closes it and marks it "対応未確認". A recipient with no record of its own is listed with "本人記録なし". There is no cancel record yet; its format is undecided, so no text is matched as a cancel.
- An ACK to a WAKE only confirms receipt. To end a wait, the member records `--presence ended`. "ACK済み" on the wake button means receipt as well.
- Old records: up to the boundary event `feeb9d2cde9c43d0bc7d8cc0fa080e4b` (2026-10-18T19:35:45Z), an `ACK WAKE` keeps its old reading as "wait ended". It is labelled as the old reading and is never shown as the member's own declaration.
- Order (OPS-153): members keep the order in which they first appeared in the record window; a new member is added at the end, one that leaves is removed, and one that returns goes to the end. The order is not re-sorted by new activity. (An earlier review note said "newest first"; that held only at first appearance.)
- Two conversations using the same name cannot be told apart. Use different display names when they work at the same time.
- Manual route: in conversation, say "starting", "returning; waiting next", "received (still waiting)", "ending the wait" and "last confirmation hh:mm" to keep the same meanings.
- Not implemented: writing activity and continuity together automatically (partial failure and proxy sending would need design). The one-shot continuity CLI stays optional.

## 3. 一操作と記録の関係

正本に結果を保存してから通知する。省力ツールの成功は、そのツールが実施した検査/記録の成功だけを意味する。参照先が存在することは内容が正しいことや完了したことを保証しない。

相互対応にはtask IDだけでなく、依頼節・返却節・必要なら一意の依頼識別子を使う。同じtaskで並行する依頼をtask IDだけで結び付けない。どれへの返事か曖昧なら相手へ確認する。自動照合が未実装でも、この確認は手動で可能である。

通知後に結果・観察・受入判断へ影響する追記や訂正をした場合は、元の通知/参照との関係と変更点を追加通知する。送信成功後にしか分からない観察値は後から追記してよいが、未通知のまま相手が読んだと推定しない。

履歴の訂正は元の通知を消さず、何を訂正するか示す追加記録で行う。参照先は更新されうるため、固定した内容への判断が必要な場合だけcommit等の版を記す。過去の通知を読むたびに現行文書を再検証しない。

## 4. 失敗と経路の切替

1. 検査に失敗した場合：未送信と明示し、入力を直すか手動へ移る。拒否を成果不合格と混同しない。
2. 正本は保存済みで通知だけ失敗した場合：正本を巻き戻さず、未通知と記録して通常の会話で渡す。
3. 書込/送信結果が不明な場合：履歴と相手の返事を確認してから再送する。不明を成功と呼ばない。
4. 重複した場合：同一通知の再送か、新しい訂正/依頼かを対応先と内容で確認する。重複だけで作業を再実行しない。
5. 順序逆転・遅延・再起動の場合：最後に到着した通知だけで状態を確定せず、正本と対応する依頼を照合する。通信断や無通信から終了を推定しない。
6. 途中で手動へ切り替える場合：「済んだ操作・未確認の操作・残る操作・元の依頼/記録」を短く引き渡す。完了済みの操作を最初から繰り返さない。省力側へ戻る場合も同じ照合をする。

自動再送・厳密な一度だけの配送・省力/手動間の自動同期は、本初版では実装済みと主張しない。手動時も認証・権限・編集占有を迂回しない。

## 5. このリポジトリでの実装状況

| 共通の要求 | 現状 |
| --- | --- |
| 省力経路 | OPS-129の返却CLIでdoc/section/nextを検査し、refつき通知を一度で追記する。試行中 |
| 手動経路 | 正本にReturnを書き、通常の会話または従来のactivity通知で参照と次担当を明示する。通知不能時は会話へ戻す。履歴直接編集はしない |
| 依頼と返答の対応 | 正式依頼/Returnの参照とWAKE ID。全イベント共通の構造化requestId/replyToは未実装 |
| 状態の表示 | event ID・owner・next・presenceから派生。直近200件の表示であり、正式状態の正本ではない。Studio keeps one input snapshot (activity, approvals and continuity each with last good value, success, generation and receipt time; the clock and UI state as inputs) and derives the timeline, cards, member status and 待機完了 once per input with one revision (OPS-153). The sources are combined as received, not as one simultaneous server state |
| 重複・中断 | 自動重複排除なし。appendロック・末尾不完全時の拒否。結果不明時は手動確認 |
| 手動フォールバック | 上記手順を定義。通知ツール停止からの往復を通した実地試験は未実施 |
| 継続確認（OPS-139/141） | Each member writes one-shot `continuity.py --owner <name> --state alive` marks at milestones and around waits, and `ended` at an intended end of a continuous run. Studio shows them in the Work page member status (not the top bar) as "継続 hh:mm", "確認が古い" over 55 s, "連続動作の終了", "未確認" or "不調". "確認が古い" only means no recent confirmation; it does not change the declared state or assert a stop. Long tool runs also look old. No background heartbeat. Within a minute only while the page is in front and the server runs |
| 開始待ち・着手（OPS-151） | Derived in Studio from the leading request ID, task and recipient of the recent 200 records (one parser; the ID ends at a non-alphanumeric boundary). Not implemented: platform "実行確認済み", cancel records, proxy stop confirmation (OPS-149) and derivation from the whole log; a request outside the 200-record window is not shown |
| 待機完了の依頼（OPS-138） | Studioの「待機完了」から、ユーザーが担当を選んでWAKEを送る。番号・関連task・文面はサーバーが決める。未応答の依頼が同じ担当にあれば、新しく作らずにそれを返す。完了扱いは、宛先本人が同じ番号の`ACK`を書いたときだけ。自動の再送や起動はしない |

現行の待機終了送信は `--event request --reason 'WAKE-YYYYMMDD-X：待機終了依頼'`、返信は `--event work --reason 'ACK WAKE-YYYYMMDD-X：会話へ戻る' --presence ended`。task/ownerは従来どおり添える。これは疎通PINGとは別の操作。

手動と省力は意味が等価であって、現状の自動検査・画面反映が同等に実装済みという意味ではない。

## 6. 疎通手順

疎通は連絡経路の確認だけを行い、作業開始・成果受入・コミット許可・待機終了を伴わない。WAKEは待機終了なので疎通用には使わない。

1. **確認区間を決める。** 送信者→記録、記録→受信者、受信者→返信、返信→送信者、Studio表示のどこを確認したいかを明示する。相手が生きた会話で待機していることは別に確認する。通常の会話への手動送信なら、その会話が届く経路を対象にする。
2. **一意の疎通番号を付ける。** このrepoでは `PING-YYYYMMDD-X`（末尾は大文字英数字、使用済みと重ならないもの）を用いる。宛先・目的・返答先を添えて一度送る。同じ番号を別の試験へ再利用しない。
3. **相手が受信して返信する。** `ACK <同じ番号>` と実際の受信者を記す。疎通への返信だけでは実務を始めず、待機終了にもならない。権限を持つ依頼と取り違えない。
4. **対応するACKを照合する。** 番号・相手・対象経路が合えば、その時点で往復できた範囲だけを確認済みにする。送信ログだけ、HTTP成功だけ、ランプ点灯だけでは本人が受信した証拠にしない。過去のACKを今回の成功として使わない。
5. **結果を短く残す。** 番号、試した区間、送信/ACKの参照、成立した範囲、未確認箇所。試験を終えたら定期送信を続けない。疎通のためだけに継続監視を新設しない。

### 二経路での実行

- **手順省力側**：利用可能な通知道具でPING/ACKを記録する。専用の統合疎通コマンドは現状未実装。現在は `activity.py` の通常通知と専用reason書式を組み合わせる。通知保存とStudio表示と相手の応答をそれぞれ確認する。現行送信は `--event work --reason 'PING-YYYYMMDD-X：宛先・目的・返答先'`、返信は `--event work --reason 'ACK PING-YYYYMMDD-X：受信'`。送信番号の直後のコロンと、返信reason先頭のACKが表示側の疎通判定に必要（番号への単なる言及は実務として扱われる）。
- **フルマニュアル側**：通常の会話で番号・宛先・目的・返答先を渡し、相手の同番号の返信を確認する。必要ならユーザーに伝達を依頼する。その場合は「ユーザー仲介で成立」と記録し、直接のイベント経路が直ったとは言わない。正本に結果を残し、ログの直接編集はしない。

### ACKが来ないとき

事前に決めた待ち時間まで、無用な連投をせず確認する。時間超過は「期限内にACK未確認」であり、相手の故障・停止・未受信を確定しない。送信結果が不明なら記録を先に確認。記録の有無、受取側の待機状況、返信記録、表示の取得不調を、必要な区間だけ調べる。実サーバー再起動・相手の起動や設定変更は、この疎通依頼から自動的に許可されない。

再送には同じ試験の再送だと明記する。新しく試験するなら新しい番号を使う。遅れて来たACKは元の試験の記録へ結び付け、新しい試験を完了にしない。切り分けが進まなければ手動経路へ移り、最後に確認できた区間と未確認箇所を伝える。

## 7. 見直し・改訂

定期的な見直しは、既存の調整役振り返りまたは運用棚卸しのタイミングに合わせる。別の定期ジョブや監視義務は作らない。障害、試行結果、別プロジェクトへの移植、必要情報や権限境界の変更があれば、その時にも見直す。

改訂では、変更理由・変わる意味/必須情報・旧版との互換・移行/手動退避・確かめた範囲を残す。呼出側と受取側の版が異なる場合に、未対応項目を成功扱いで捨てない。既存のschemaVersionとは独立に、本書の版と改訂履歴を更新する。過去記録の意味を新しい版で黙って変えない。権限を変える改訂は持ち主の判断へ返す。

| 版 | 日付 | 変更理由・範囲 |
| --- | --- | --- |
| 0.1 | 2026-10-19 | ユーザー要求により二系統・共通意味・手動切替・疎通手順・改訂方法を初版化。OPS-129の限定実装と未実装の要求を分離 |
| 0.2 | 2026-10-19 | 実運用からの追加（OPS-137〜139）。§2に情報更新依頼（UPDATE）、§5に継続確認と待機完了の依頼の現状を足した。0.1の意味は変えていない。未実装・限界：UPDATEの専用UIと自動照合はない。継続確認は本人の単発の記録だけで、停止の断定はしない。待機完了は届いたかどうかを保証しない。どちらも実サーバーの再起動後の確認は未実施 |
| 0.3 | 2026-10-19 | OPS-141. Added member status to §2 (declared state, last activity, confirmation freshness), `working`, the distinction between wait end and continuous-run end, ACK = receipt, the old-record boundary, the same-name limitation and the manual route. Old ACKs keep their old reading with a label. Not implemented: automatic combined update of activity and continuity |
| 0.4 | 2026-10-19 | OPS-156。DB連絡の原文/受領版/代理/停止応答/二重送信と手動退避を追加。旧経路は維持。実稼働切替は未実施 |

## 連絡DB経路（0.4、OPS-156）

連絡原文と配送状態をサーバー専用SQLiteへ保持する経路。DB/API/CLIは隔離試験で受入済み。実運用への切替は、対応サーバー・送信者設定・担当の待機接続の確認後に行う。まだ切り替えていない依頼には旧経路を使う。

- `LTR-`の連絡は、依頼/返答の本文と改訂版、出来事をDBの正本にする。成果・仕様・判断の正本は従来のMarkdownに残せる。本文を必ずMarkdownへ複写する必要はない。
- 同じDB依頼をjsonlの依頼として重ねて送らない。既存の旧経路の依頼はその経路で閉じる。配送失敗時に別IDで送り直す前に、同じ操作IDの結果を照会する。結果不明と未送信を区別する。
- 読み取り・一覧表示・差分監視は受領ではない。受領は本人が実際に読んだ版を指定して記録する。受領後の改訂は未読の可能性を残す。
- 代理記録は本人の応答に数えない。表示名の自己申告は本人認証ではない。経路の利用は既存の依頼権限・占有・commit許可を増やさない。
- 取り下げは停止要請。本人の停止応答、未着手時の本人辞退、または着手済み成果の返却まで未確認として残す。本人応答なしに閉じる機能はない。停止前に着手していた仕事の成果返却は受け取れるが、追加作業の許可・受入・占有解放とは扱わない。
- DB経路が使えない場合は既存の手動経路へ退避できる。その際は元の依頼IDと結果不明の有無を引き継ぎ、二重着手しないよう相手と照合する。沈黙から停止や未送信を推定しない。

## 作業記録

OPS-130：初版記述。既存README・activity実装と照合。未実装の配送保証や手動往復の実証を完了扱いにしない。サーバーの整理は別task OPS-131で実施する。

初版照合：姫の運用レビュー5点を反映（通知後追記、疎通書式、担当単位の待機、WAKEの実装対応、現環境のユーザー仲介）。証拠はSTUDIO_SERVER_REFACTOR.md「姫規約確認Return」。
