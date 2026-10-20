# 担当者待機の最小試作を隔離して提示する

## TL;DR
既存watchの繰り返しを道具へ任せる最小試作を、本番と分離した場所で作ってユーザーに提示する。OPS-193はユーザー指示で凍結。今回は隔離試作プランと試作場所の提示だけを姫へ依頼する。実装はまだしない。

## 進め方
試作プラン → ユーザーの試作了承 → 試作提示 → 問題出し（必要なら反復）→ 次のフェーズ。問題が見つかったことを、その全件の修正指示や本番適用許可に変換しない。

## 最初の試作プランの範囲
既存watchを期限付きで繰り返し、既存機能が変化を検出すれば返る。まずこれが使いやすいか確かめる。返答後の補正・close・WAKEの取りこぼし対策は既知の残件として保持し、初回試作に追加しない。

## 試作場所と提示
本番の共有作業ツリー・稼働サーバー・実DBを変更しない。comm.pyなど実行時に読み直されるCLIも本番の一部として扱う。一時DBと試験portだけ分けても、実行コードが共用なら隔離とは呼ばない。試作コード・データ・実行経路を分離し、その場所とユーザーが試せる方法を最初のプランに明記する。場所の準備や実装は試作了承後。

## 既存成果
OPS-193の未受入コードはユーザー指示で巻き戻し、未追跡のパッチ・試験ログも削除した。過去Returnは経緯の記録としてのみ残す。試作は隔離場所で改めて行う。OPS-192の受入済み機能は今回の凍結対象外。

## 次の判断
ユーザーが試作プランを了承すること。現段階ではプラン作成だけを依頼。実装・本番適用の許可ではない。


## 第1区切り：隔離試作プランと場所の提示（姫への依頼）
ユーザー依頼（2026-10-20）。既存watchを期限付きで繰り返す最小試作について、以下だけを短く返してください。
- 作るものと試せること。既知の未対応は短く添える。
- 試作コード、試験用DB・状態ファイルの具体的な絶対パス案と、試験サーバーが必要なら接続先案。コード・データ・実行経路が本番から分離される理由を実物の設定で確かめる。
- ユーザーが試作を確認する手順・コマンド案。まだ実行しない。
- 了承後の変更ファイルと最小の作業内訳。
今回は読取確認と本書Returnへのプラン記入、連絡DBでの受領/返却だけ。試作場所の作成・実装・試験サーバー起動・本番コード/DB変更・commit・stashはしない。OPS-193の凍結を解除しない。
**この隔離と提示が困難なら、それ自体を問題として返す。** 確認できた障害と、何ができないかだけを報告する。解消プランはユーザーとAstraが巻き取る。姫が環境改造・制度追加・代案の作り込みへ広げたり、無断で本番共用へ戻ったりしない。
返却は本書「第1区切り Return」へ記入し、連絡DBの依頼へ短く返す。返却後はユーザーの試作了承を待つ。

### 第1区切り Return（姫記入）
- 受領（姫、2026-10-20）：LTR-20261020-DD51880C…の依頼v1。受領時の正本照合は一致。作業ツリーは6d9ab3e6eで変更なし（OPS-193の差分はAstraが巻き戻し済み）。
- 作るもの：`letter watch … --wait 秒 [--interval 秒]`。既存の単発watchを道具の中で繰り返し、変化があれば0、期限で3、エラーはすぐ返す。出力は最後の1回分だけ。
  - 試せること：待つ側の端末で1回呼んでおくと、別の端末から連絡を送った時点で返る。何もなければ期限で返る。
  - 既知の未対応：返答後の補正・close・WAKEは見えない（単発watchと同じ）。
- 試作場所の案：本番ツリーの外に、git worktreeを置く。
  - 場所：`/Users/narumij/Documents/GitHub/swift-ac-collections-trials/OPS-194`。今はない。
  - ブランチ：`trial/ops-194`。起点は6d9ab3e6e。
  - リポジトリの外なので、ユーザーの指定が必要（CLAUDE.mdの作業範囲の規則）。
  - 作ると、`.git`のworktree一覧に1件増える。本番ツリーのファイルは変わらない。
- 分離される理由（実物の設定で確認した）：
  - コード：comm.pyは、自分と同じディレクトリのstudio_clientを読む。serve.py・approvals.py・activity.pyのパスは、どれも`__file__`から決まる（`APP = Path(__file__).resolve().parent`、`ROOT = APP.parent.parent`、`activity.ROOT = parents[2]`）。worktreeのコードは、worktreeの中だけを指す。
  - データ：連絡DB `Approvals/approvals.sqlite3` と `Activity/events.jsonl` は、gitの管理外（`.gitignore`の`*`）。worktreeでは空から始まり、本番のDBと記録は入らない。
  - 実行の経路：試験サーバーは`serve.py --port 8199`（127.0.0.1だけに接続。今は空きを確認）。
  - 注意：試作のcomm.pyの接続先の既定は8088（本番）。必ず`REGISTRY_STUDIO_URL=http://127.0.0.1:8199`を付けて動かす。試作の中に`trial-env.sh`を置き、これと`unset REGISTRY_STUDIO_APPROVALS_DB`を必ず読み込む。今のシェルには、どちらの環境変数もない。
  - 状態ファイル：`/Users/narumij/Documents/GitHub/swift-ac-collections-trials/OPS-194/.trial/watch.json`（試作の中）。
- ユーザーが確認する手順（案。まだ実行しない）：
  1. 端末1：`cd /Users/narumij/Documents/GitHub/swift-ac-collections-trials/OPS-194 && . ./trial-env.sh && python3 Maintanance/RegistryApp/serve.py --port 8199`
  2. 端末2：`. ./trial-env.sh && python3 Maintanance/RegistryApp/comm.py letter senders --set Astra --recorded-by ユーザー`
  3. 端末2：`python3 Maintanance/RegistryApp/comm.py letter watch --owner 姫 --state-file .trial/watch.json --wait 120 --interval 2`（待つ）
  4. 端末3：`. ./trial-env.sh && echo 試し | python3 Maintanance/RegistryApp/comm.py letter send --sender Astra --recipient 姫 --task OPS-194 --body-file -`。数秒で、端末2が変化（exit 0）を出して返る。
  5. もう一度3を実行して、何もしなければ、期限（例 `--wait 10`）でexit 3。終わったら端末1をCtrl+Cで止める。
- 了承後の作業内訳：
  - (1) worktreeとブランチを作る。
  - (2) 試作の中だけを変更する：`trial-env.sh`、comm.py（`--wait`/`--interval`）、test-studio-letters.pyの限定試験1件、READMEの試作の注記。
  - (3) 試作の中で、限定試験とtest-letters-e2eを流す。
  - (4) 上の手順で、8199の試験サーバーを使ってユーザーに提示する。
  - 本番ツリー・8088・実DBは使わない。commitはしない。片付けは`git worktree remove`で、ユーザーの了承のあとに行う。
- 障害：確認できた範囲ではない。ただし、試作の場所がリポジトリの外なので、ユーザーの指定が要る。


## 第2区切り：了承済み最小試作の作成と提示（2026-10-20）
ユーザーは、提示した別フォルダ・8199番で姫が最小試作を作ることを「うん、いいよ」と了承し、続行を指示した。
姫へ：第1区切りのプランどおり、`/Users/narumij/Documents/GitHub/swift-ac-collections-trials/OPS-194`に隔離した作業ツリー（branch `trial/ops-194`、起点6d9ab3e6e）を準備し、既存watchの期限付き反復だけを試作・提示してください。この場所とbranch作成は今回の試作了承の対象。既存の同名場所/branchがあれば上書きせず状態を確認する。
本番と分離するのはコード・DB・状態ファイル・接続先。試作のCLIは試験接続先8199を明示し、本番8088へ送らない。プランで挙げたtrial-env.sh等を使い、提示時のコマンドは各端末から実行できる絶対パスまたは明示cd付きで書く。試験用DBは空から作り、本番DBをコピーしない。
最小範囲は`--wait`/`--interval`による反復と、変化/期限/エラーで返る動作。イベントカーソル、返答後補正/close/WAKE対応、新UIは足さない。限定試験とユーザー向けの試し方を用意し、そこで止めて問題出しに渡す。問題が出たらCLAUDE.mdの三つの関心を区別して報告する。隔離や提示が困難なら解消プランはこちらが巻き取る。
本番コード・サーバー・実DBへ変更せず、commit・push・merge・試作場所の削除をしない。正式連絡の受領/返却とこの正本Returnの記入だけは本番の連絡経路を使用する。試験通信と正式連絡を混同しない。実装ファイルは隔離側のみ。返却は今回のDB依頼に行い、試作場所・変更・確認結果・ユーザーの実行手順を本書へ残す。

### 第2区切り Return（姫記入）
