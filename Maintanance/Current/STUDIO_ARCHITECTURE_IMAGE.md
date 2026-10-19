# Registry Studioアーキテクチャ画像

## TL;DR（人間向け）
Studioの画面・ViewModel・サーバー・SQLite活動記録・Markdown作業正本の関係を、日本語の画像一枚で読めるようにする。実装済みと作業中/予定を区別する。

OPS-157 / ACTIVE / 2026-10-19。ユーザー「姫にアーキテクチャ図も描いてもらおう。がぞうで」。親OPS048。commit別承認。

## 範囲と受入

RegistryAppだけを対象に、View/VM/Model、server/API、SQLite活動SSoT、Markdown作業正本、CLI/agent経路、派生/互換出力を整理する。横長、日本語、過密回避。SVG等の編集元とPNGをRegistryApp/Docsへ配置予定。READMEからリンクし、画像を実際に開いて内容と文字可読性を確認する。作業中の構造を完成扱いしない。

姫H21を妨げず、その返却区切り後に正式割当。今は準備で、画像未作成。


## 姫への正式依頼 H-20261019-26

連絡DB H25は返却固定し独立評価中。その間、ユーザー依頼の画像を作成してください。占有はRegistryApp/Docs内の新SVG/PNG、README.mdの図への入口のみ、本書の新返却欄。実装コード・DB・liveサーバーは触れない。commitなし。

日本語の横長一枚。実装済み作業VM、部分実装タスクVM、サーバー/API、承認・通信SQLite、Markdownのタスク/成果/仕様/判断、CLI/エージェントの関係を示す。連絡DBは実装返却済みだが受入前、履歴閲覧UI/待機連携は予定と区別する。活動SSoT移行済み/未移行の境界も分かるようにし、全ログ移行済みと描かない。図を簡潔にするため全API列挙は不要。

編集元SVGとPNGを保存し、実画像の文字可読性/矢印/切れを確認。返却に画像の絶対パス、根拠にしたファイル、未完部分の描き分けを添える。返却後連続待機。

## 姫返却（H-20261019-26：構成図）

2026-10-19 姫・Opus 5.5。実装のコード・DB・実サーバーには触れていない。commitなし。

**画像**（日本語の横長1枚、1900×1080）：
- PNG：`/Users/narumij/Documents/GitHub/swift-ac-collections/Maintanance/RegistryApp/Docs/studio-architecture.png`
- 編集元のSVG：`/Users/narumij/Documents/GitHub/swift-ac-collections/Maintanance/RegistryApp/Docs/studio-architecture.svg`
- READMEの入口：`Maintanance/RegistryApp/README.md`の見出しの直下に、1行（PNGとSVGへのリンク）を足しただけ。

**描き分け**（凡例つき）：
- **緑（実装・受入済み）**：
  - 作業ページ（OPS-153、共通snapshot・deriveStudio・View）
  - タスクページの地図VM（区切り0/1）
  - サーバーの承認・保存・待機完了と、読み取り
  - 承認の表（requests・history）
  - events.jsonl、Markdownの正本
  - CLI群
- **橙（実装返却済み・受入前）**：
  - 記録のAPI（H21・H22）と連絡のAPI（H25）
  - SQLiteの`operations`・`messages`・`acks`・`meta`と、`letters`・`letter_texts`・`letter_events`
  - H21とH22は、正本に正式な受入の記録が見当たらないので、受入前として描いた。
- **灰の破線（予定）**：
  - タスクページの残り（近傍・編集欄・共通配線、版の切り替えで入力が消える件）
  - 連絡の履歴の閲覧、メンバー欄のPING、操作の記録の閲覧
  - エージェントの待機の連携（inbox）
- **活動の正本の境界**：events.jsonlの欄に、次の3点を書いた。「移したのは新方式の連絡だけ（受入前）。全ログではない」と明記している。
  - 未移行：依頼・着手・返却・受入・commit
  - WAKEは第2段で移す予定
  - PINGはcutoverが未実施なので、jsonlにも書ける
- そのほか、図の上部に「サーバーだけがSQLiteを開く」「名前は本人申告で認証ではない」を、サーバーの下に「ボタンや名前は権限ではない」を書いた。APIの全部は並べていない。

**確かめたこと**：
- SVGを隔離したheadlessのWebKitで描き、PNGを目で見て確かめた。文字が読めること、箱の外へ文字が切れないこと、矢印の向きと行き先が正しいこと。
- 1回目の版は、長い矢印が画面の欄の箱を横切り、continuity.pyからタスクページへ向かう誤った矢印もあった。そのため配置を組み替えた（画面｜サーバー｜AIエージェント｜保存先。エージェントを下半分に置き、サーバーからSQLiteへの矢印の通り道を空けた）。
- ユーザーから画面への矢印が見出しに重なっていたのも、右へずらした。
- 描画用の一時スクリプトは、作業の後に削除した。

**根拠にしたファイル**：
- `index.template.html`（OPS-151・153の作業ページ、OPS-154の地図VM）
- `serve.py`、`approvals.py`、`studio_store.py`、`studio_client.py`、`comm.py`、`activity.py`、`continuity.py`、`sync.py`
- `Maintanance/Current/STUDIO_VIEW_MODEL_DISCUSSION.md`、`TASK_VIEW_MODEL_MIGRATION.md`、`STUDIO_COMMUNICATION_STORE.md`（H21・H22・H24・H25）、`MEMBER_START_VISIBILITY_FIX.md`

**描いていない・注意**：
- 実サーバーは13:02に、その時点の作業ツリー（H21の段階）のコードで起動されている。H22とH25は、まだ実サーバーには入っていない。図は「作業ツリーのコードの構成」を描いたもので、実稼働の状態ではない。
- probe（疎通の試験用の別のレーン）は省いた。


## Astra確認（2026-10-19）

PNGを実際に開き、日本語文字の可読性・切れなし・実装/受入前/予定の区別を確認。H25時点の作業ツリー図として技術受入。実稼働図とは区別する。今後の連絡UI完成を表す図ではない。commit待ち。
