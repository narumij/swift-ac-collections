# コミット事前承認レーン（OPS-114）

2026-10-18 Astra。親OPS-048。ユーザーはコミットだけを対象とし、個別承認・全部承認を希望。実際のcommitを扱うのはAstraと明示。Sol・サーバーはcommitしない。

## 契約

- Astraが対象task ID・目的/範囲・対象ファイル（repo相対の完全パス一覧、ワイルドカードなし）・受入条件・branchをカードとして事前登録する。内容は登録後不変。変更は旧カードを取消し新しいカードにして再承認。差分内容の確定ではなく限定目的・対象範囲への事前承認であり、実行前にAstraが実差分と受入条件を確認する。
- UIはカードの個別承認・取消と「表示中を全部承認」。全部はクリック時に画面が保持するpending ID+revision集合だけ。後から追加されたカードを含めない。空集合は許可を作らない。古いrevision/statusからの変更は409、バッチは全件成功か無変更。
- durable storeはRegistryApp/Approvals/配下SQLite（同ディレクトリ.gitignoreでDB等除外）。sync/再起動/commitで消さない。現在状態と時刻・承認時の完全内容・取消/使用履歴を保持。履歴の削除/圧縮なし。
- 状態pending→approved→claimed→consumed。pending/approvedからcancelledへ。claimedはAstraが実行直前に排他的に確保済みで取消不可と明示する。失敗時はclaimedをapprovedへ自動で戻さず、Astraが取消して新カードで再承認。これにより再利用・二重使用を避ける。
- AstraだけがローカルCLIで登録/list/claim/finish/abandonを扱う。CLIには承認操作を用意しない。HTTPはGET一覧とユーザーUIのapprove/cancelのみ。Git commit実行API/CLIなし。claimは承認の状態とrepo/branch/受入記録の参照を照合して消費開始を記録する補助で、git操作の代行ではない。finishはclaim tokenと実SHAを記録する。
- 初回実装は承認受渡しの試作。AGENTS変更案は同ファイルへ下記のとおり記し、AIはAGENTSを編集しない。現行規則が変更されるまではAstraが画面承認だけを根拠にcommitしない。カードは申請するAstraが委任範囲を確認する。承認クリックは実行・push・merge・task受入の代行ではない。
- UIは既存編集版・未保存変更・選択・スクロールに触れず承認レーンだけ取得/変更。~3秒で更新、重複なし、非表示停止/timeout。不調時は最後の表示を残し操作停止。承認操作中の古いGET応答で状態を巻き戻さない。長いscope/pathはテキストとして安全に確認可能。pending/approvedが主表示、完了/取消は折り畳みで辿れる。

## 技術インターフェース（固定）

GET /commit-approvals → {requests:[{id,revision,taskId,title,scope,paths,condition,branch,status,createdAt,updatedAt,approvedAt,commitSha,...}], policyNotice:"規則反映前はAstraが会話で直前承認を確認します"}
POST /commit-approvals → {action:"approve"|"cancel",targets:[{id,revision}]}。Content-Type application/json、X-Registry-Studio: commit-approvals、既存同様のHost/Origin検証・body上限。応答200は同じ一覧形式、競合409。

## 分担

作業Sol backend：RegistryApp/approvals.py・Approvals/.gitignore・serve.py・test-approvals.py。frontend Sol：index.template.html・test-approvals.cjs・READMEの新節のみ。両者は共有API契約に従う。Registry/Rules/他正本/AGENTS/Inboxの変更禁止。commit/restart/UI操作/live syncなし。Astraが記録・生成・受入を担当。判断キャッシュは実参照のみ記録。

## AGENTS.md変更案（ユーザー反映済み）

「Git操作の取り決め」の先頭項を次の2項へ置き換える案：

- branch作成、branchまたはtagのpushは、操作ごとに、その直前の明示的なユーザー許可を必要とする。一つの許可を別の操作へ広げない。
- commit作成は、直前の明示的なユーザー許可、またはコミット事前承認レーンでユーザーが承認した未使用の依頼に基づき、Astraが実行する。事前承認は当該依頼のtask・目的・対象ファイル・受入条件・branchに限る。Astraは実行直前に承認の有効性と実差分・受入結果を照合し、一度だけ使用する。範囲・条件が変わった場合は再承認を得る。全部承認は操作時に表示されていた依頼だけに適用し、後続の依頼へ広げない。Solやサーバーへcommit実行を委任しない。

## 返却・受入

実装準備済み。事前承認の保存はcommit実行許可の現在規則を自動変更しない。

## 受入（2026-10-18）

保存側Sol・画面側Solが分担実装し、確認Solが独立照合。Astraが限定試験・統合を確認して試作として受入。途中確認でGitのNUL区切りファイル名の先頭空白を除去していた箇所を差し戻し、原名を保持する補正と回帰試験を追加した。

Python隔離試験8件（HTTP・永続化・内容固定・一括承認の競合時無変更・排他・実Git fixtureの親/branch/対象ファイル照合・二重使用拒否等）、JS疑似DOM/通信試験（個別/表示中の全部・古い応答・不調時停止・詳細安全表示・既存状態分離）、既存activity試験、Astraのsync/verifyと差分検査が成功。確認SolのHTTP試験はsandboxのbind制約で未実施だったためAstraが別途成功を確認した。実ブラウザ表示・操作は未確認。利用中サーバーは再起動していない。

acceptanceRefはAstraの照合記録への参照であり、品質判定の自動証明ではない。CLIの実行モデル認証はなく、Astra担当という運用上の委任に従う。finishはclaim時HEADの直接の子である実HEADの1commitと、対象ファイル集合を確認する。実commit前の差分照合と受入判断はAstraが行う。失敗時は自動再利用しない。

判断キャッシュ参照：3担当ともになし。AGENTSは未変更。規則反映と本変更のcommitは未実施。

## Astraの利用手順

`python3 -B Maintanance/RegistryApp/approvals.py add --task-id ID --title TITLE --scope SCOPE --path PATH --condition CONDITION --branch BRANCH` で依頼を作る（pathは必要な数だけ指定）。listで保存状態を読む。ユーザーがUIで承認する。

規則が整い受入済みになったら、Astraは依頼内容と実際の差分・branch・承認状態を照合する。`claim ID --repo REPO --branch BRANCH --acceptance-ref REF` で排他的に確保してtokenを受け取る。Astraが承認範囲のみをstageしてcommitし、`finish ID --token TOKEN --sha SHA` で実SHAを保存する。claim以後の失敗は `abandon ID --token TOKEN --reason REASON` で閉じ、新しい依頼で再承認する。tokenを公開文書へ転記しない。

## 登録・承認確認のタイミング（2026-10-18 ユーザー指定）

- **作業開始時**：範囲と対象ファイルが定まった時点で、作業単位ごとに承認カードを登録する。完了まで登録を遅らせず、独立した仕事を一枚にまとめない。
- **作業完了・受入完了時**：最終報告の前に `approvals.py list` で保存された最新状態を確認する。会話で「承認した」と言われていなくても確認し、有効な承認と受入条件がそろっていれば、承認範囲のcommitまで進める。
- **ユーザーから承認の連絡を受けた時・中断後に再開した時**：対象依頼の最新状態を確認する。以前の確認結果だけで承認待ちと判断しない。
- **commit直前**：最新の承認状態・未使用であること・task・目的・対象ファイル・branch・実差分・受入結果を再照合してからclaimする。完了時の確認だけでこの照合を省かない。
- **承認待ちと報告する直前**：保存状態を確認済みであることを確かめる。取得できなかった場合は「承認状態を確認できない」と報告し、未承認と決めつけない。承認済みでも範囲変更や受入未了で進めない場合は、その理由を伝える。

UIの承認は会話を自動起動しない。上記はAstraが作業中・再開時に確認する手順であり、常時監視を前提にしない。使用済み承認は後続作業へ流用しない。

## 完了確認（2026-10-18）

ユーザーがAGENTSの規則を反映し、a3eff0573でcommit済み。画面からの承認保存を確認。Astraが承認ID `224f3795fae14f6fae5e5c0a27cd2d8f` の範囲を照合し、OPS-114だけをcommitする。後続OPS-115の疎通機能は含めない。使用後の実SHAは承認履歴に記録する。上記の未反映・未実施記述は受入時点の履歴。
