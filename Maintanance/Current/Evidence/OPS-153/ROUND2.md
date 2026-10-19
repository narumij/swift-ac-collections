# D-20261019-06 最終独立評価

## 結論

専用4試験とcontinuity試験はPASS。ただし入力→snapshot/VMとVM配布の境界に3指摘。全試験PASSを契約成立と同一視しない。修正・受入・仕様変更は行わず調整担当へ返す。

## 固定版

2026-10-18T22:41:42Z開始読取。以下SHA256は評価後も一致した。

| ファイル | SHA256 |
| --- | --- |
| index.template.html | c0f0ea60d52e4ec30c3e94e4bc7cdc07db953e88b702b9a0e59c21acc6a28139 |
| test-view-model.cjs | 7345921a72829ab5804539e1f09e77aa4c83af4a6f1901a706ecd75abd718232 |
| test-view-model-members.cjs | b6e24446dae8d726416488d7517ed6751df06f3b81ed20e9a4f41b65d1c0152c |
| test-view-model-cards.cjs | ba4e0e2c3caabb16aa764e53c6f091f475e1e2f5493b354d9e7ca4c33bab8679 |
| test-view-model-current-wake.cjs | 308649d2e323adf9d6fba73c5a438ed514b4e3c27314c288d75b54eb453d63e5 |

H-12順序補正、H-14依頼・返却、ユーザー二観点を根拠にした。旧baselineのmembers `e7cc46d7…210cc6ef`、cards `755cb483…ba433626`、current-wake `927b139d…0aba3e31`を確認。

## 指摘（3件）

### 1 同revision配布が依存部分のみへ変更されている

**期待・根拠**：H-09合意とH-14は、入力更新一回で一deriveし同revisionのmembers/cards/current/wakeを各Viewへ配布する。

**実態**：createStudioはSTUDIO_PART_SOURCESでaffectedを絞り、deriveStudio(s, affected)とそのViewだけを呼ぶ。専用試験もactivityで全View revision1、approvalsでcardsだけ2、clockでmembersだけ3を期待する。未対象Viewは古いrevisionのまま。同値として再利用したrevisionの証跡や、最新revision適用済みを示す仕組みはない。実rendererも渡されたrevを保持する契約にはなっていない。依存部分への一derive自体は成立。

**区分**：実装側の確定配布契約との差、および効率化を採用するなら仕様側の整理が必要。未対象Viewの内容が常に誤ると主張するものではない。意味上同値として省略を認めるかは調整担当・姫の協議へ返す。専用試験の部分配布assertは元の契約の証明にはならない。

### 2 snapshotの受信時刻・continuity成否が実入力に結び付かない

**期待・根拠**：H-14はsource別の世代・受信時刻・最新成否・last-goodを保持し、非同時性を区別する。

**実態**：applyStudioInputはinput.atがなければreceivedAt=null。ページのactivity(rows)、approvals(value.requests)、continuity(data, performance.now())はいずれもatを渡さず、continuityの公開入口自体もatを渡さない。またstudio.continuityは常にok:trueで入力するため、`{base:null,failed:true}`でもsources.continuity.ok=trueになる。公開入口の最小実行でactivity.receivedAt=null、continuity.receivedAt=null/ok=true/value.failed=trueを確認した。表示文字はvalue.failedを参照して不調を表示できるが、source状態は食い違う。activity/approval失敗のlast-good保持とgeneration加算は既存専用試験で成立。

**区分**：実装側。単体試験が人工のat:'a1'等を渡して成功しても、ページの実配線で受信時刻を保持する証拠にならない。continuity失敗を正常な配送として数える設計なら、source.okの意味を別に定義する必要があるが、現依頼の「成否」と一致したとは扱わない。

### 3 WAKE送信結果が送信先ではなく完了時の選択先へ結び付く

**期待・根拠**：H-14のUI入力と操作状態、返却の「結果の注記は1担当・1依頼に属する」。異なる操作の結果を混ぜない。

**実態**：wakeSendは開始時ownerをsendへ渡すが、await後のwakeNoteForはその時点のs.ui.wakeSelectedで作る。A選択→Aへ送信開始→Bへ選択変更→Aの成功応答の順を実関数・模擬Promiseで実行し、selected=B、noteFor=`B|none|`、文言「送信しました。記録の反映を待っています」を確認。Viewはselectを送信中に無効化しない。固定VM→DOMは与えられた誤帰属の文言を忠実に描くだけでは防げない。

**区分**：実装側（操作入力→VMの対応不一致）。実サーバーへの送信はしていない。現実の発生頻度・旧実装からの発生時点は未評価。送信開始時の対象と依頼状態への対応を保持する必要があるか、修正方針は担当へ返す。

## 二観点の成立範囲と既知差

入力境界ではcontinuityの遅い応答棄却、last-good、時計の55秒境界、ソース別不調・回復、WAKE二重送信防止を専用試験で確認。全体snapshotがサーバー同時点だとは扱っていない。

固定VM→DOMではmembers/cards/current-wake各専用試験がPASS。H-12の安定順UI入力と、固定VM順序へのDOM追従は前回指摘と分けて補正確認できた。メンバー14段（宣言差2段）、カード9段、current6+WAKE12段の互換結果は正しさの証明とは別。

activity不調中も時計/continuityで継続文字が進む差はH-14の明示済み差で、新規指摘に数えない。旧baselineファイルを変更していないことと、試験側が宣言差を許容していることを区別する。既知200件窓、旧宛先残存、取消未定、同名識別は今回の修正対象ではない。

## 検証と未確認

実行はtest-view-model.cjs、test-view-model-members.cjs、test-view-model-cards.cjs、test-view-model-current-wake.cjs、test-continuity.cjsの5本、各終了0/PASS。指摘2/3はメモリ上の実関数・模擬入力による最小照合を追加（ファイル変更なし）。

既存隔離WebKit証拠 `/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/tmp.bDtqpA3maX/results.json` を読み、開始待ち/着手、WAKE模擬成功、activity不調/回復、errors=[]を確認した。今回ブラウザを起動せず、画像の視覚検証も行っていない。ユーザー実画面や実サーバーの確認とは呼ばない。

コード/正本修正、sync、commit、実サーバー/HTTP/画面操作なし。返却後本人return・presence/continuity endedを記録し占有終了。最多3件で返し、独立した追加全体監査へ広げない。
