# 現用サーバーのV3モード接続

## TL;DR
現用サーバーに既定offのV3モードを追加する。DBと保存先を明示指定した場合だけ使い、自動作成・移行はしない。一時環境で試し、本番再起動はまだ行わない。

OPS-181 / EXECUTION / Astra調整・姫 / OPS-167 S3c / 継続指示。

## 範囲
S3内訳LTR-20261019-7CA4DD1A19B3406CBEF66A62C6EE79A6に基づく。serve.pyに--v3-db PATHと--v3-saves DIRを対で追加。必要時--v3-documents DIRも明示。既存DB/保存dirのみ使用し未指定は従来経路、欠落時自動生成なし。DB schemaとURI escapingを検証。通常GETは読取のみ、適用routeは本番serverに追加しない。

GET /のdocuments/pending等は既存builder由来を維持し、Registry seedのみDB exportへ置換。/registry.jsonも新しいDB export。workspaceはV3のみ、saveはV3のみ、旧保存は保持。/syncの文書/pending更新とDB seedを分離しMarkdownをDBへ再取込しない。既定modeは従来動作。

テストfixture serverは共通のpage/storage処理を使い重複実装を除去、試験専用apply routeだけ保持。runtime fingerprintへ関係moduleを加える。構造を作り直さず既存関数を再利用する。

## 検証と禁止
一時root/port0で全route、引数不足/DB不在/非V3DB/保存dir不在、DB非作成、legacy post拒否、DB読取の不変を確認。WebKitで共通builderの往復、CLI更新後/registry.json検出、mixed保存と履歴不明の再開を確認。既存V3/legacy試験維持。実DB/Inbox/Cacheの変更、port8088起動、現用server再起動、ユーザー画面操作は禁止。出力は一時領域。配置/backup/復旧方針の採用は含まない。姫が実装・返却、Astraが独立受入・commit。
