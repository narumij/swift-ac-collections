# V3画面対応の現用テンプレート統合

## TL;DR
試験時だけ当てていたV3画面対応を現用テンプレートへ移す。従来形式の表示・編集は維持する。サーバーのV3モード有効化と本番切替はまだ行わない。

OPS-180 / EXECUTION / Astra調整・姫 / OPS-167 S3b / 2026-10-19継続指示。

## 範囲
受入済みP1〜P6をindex.template.htmlに統合。V3固有処理はsource.kindで区別し、legacyの検証・表示・計画編集・保存再開を変えない。版位置UI等のV3限定条件も確認する。harness/serverのメモリpatchを削除し同じtemplateを使わせる。二重実装なし。

対象はtemplate、v3 harness/fixture server/関連tests/README。serve.pyのモード接続は後続。実server起動/再起動、実DB/Inbox/Cache更新、ユーザー画面操作なし。生成物は一時領域に限定。

## 受入
V3全233試験、現用画面の関係するJavaScript試験/verifyを隔離入力で確認。legacyが従来動作を保ち、V3の基準検証・通知・新規版位置・異形式再開拒否・履歴不明表示が機能すること。patch残存なしを検証。姫が実装・証拠返却、Astraが独立受入・commit。

## 受入（2026-10-19）
LTR-20261019-21BCA09313F646C2800CD81754C2DD43を受入。P1〜P6を共通templateへ統合、試験用patchを除去。版位置選択はV3のみ。ファイルを開く操作でも形式不一致を拒否し、legacy/V3の相互誤読を防ぐ補正を受入。

Astra独立実行：V3全238試験成功（78.576秒）、現用JavaScript試験23ファイル成功、cached diff --check成功。姫は加えて現用Python7ファイルと隔離生成ページのverify成功を報告。OPS-180 DONE。本番サーバーのV3 modeとデータ切替は後続。
