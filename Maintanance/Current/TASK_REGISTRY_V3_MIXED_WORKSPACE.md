# V3保存と旧保存の隔離共存

## TL;DR
旧形式の編集を消さず、V3の保存・再開・更新を接続する。形式の違う保存を勝手に再開しない。現用画面と保存処理のコピーで試し、本番には反映しない。

OPS-177 / EXECUTION / Astra調整・姫 / OPS-167 S2・K6a / 2026-10-19継続指示。

## 範囲
LTR-20261019-99B42B7BDDAE4CF89C924B09EC11D523の内訳を採用。experiment内v3_inbox.pyとして現用inbox.pyのcopyを接続する。隔離serverとメモリ内template patch P6、対応試験とREADMEだけを変更する。

- legacyの基準は従来どおり。V3はkind/generation/revision/payloadHash/payloadHashOfを検証して保存し、偽または空のsha256を作らない。sourceとv3の不一致・未知kind・不正値をlegacyへfallbackしない。基準検証は既存adapter契約に合わせる。
- 形式の違う親saveへの接続を拒否。保存を上書きせず系列を保持。V3モードのworkspaceはV3の有効保存だけを再開対象とし、不正保存は一覧で区別する。
- 旧未処理保存はsaveId/日時/fileを表示用に返す。IMPORTS未記録は未照合候補を意味し、必ず新しい処理が必要とは断定しない。自動変換・削除・適用なし。
- 画面側でもcanonicalと再開保存のkindを照合し、異なる形式を再開しない。旧保存が残ることを通知する。
- 隔離V3 /syncはMarkdown再取込をせず、GETの最新DB exportへつなぐ。更新後も保存の再開と古い基準の通知を維持する。
- legacy-only入力で現用inboxとの互換を試す。V3が混在する場合も形式境界を守る。本番での物理配置は未決。

## 検証
一時folderのみでmixed保存・cross-kind parent拒否・不正base拒否/表示・旧ファイル不変を確認。WebKitで保存→別context再開、旧保存が新しくてもV3のみ再開、サーバーが異形式を返す場合の画面拒否、更新後再開を試す。既存215試験を維持。no-op /syncが本番での同期方式決定を意味しない。

## 返却
姫が実装・試験、Astraが独立受入とcommit。実server/DB/Inbox/template/syncの変更・本番切替・旧保存変換は禁止。

## 初回返却の確認（2026-10-19）
LTR-20261019-2605C8FA92894E49AADE3047BC0417DFを受領。Astraの一時folder再現で、sourceが配列の旧形式JSONはAttributeError、studioSaveが空objectのJSONはKeyErrorでlatest全体が停止した。不正保存の隔離表示という受入条件を満たさないため、LTR-20261019-15EFF45C27D24CD893C6824C6BFD1360で補正依頼。正常保存と混在しても正常分を再開でき、不正分はfile単位で報告すること。本番は未変更、受入保留。

## 補正後の受入（2026-10-19）
LTR-20261019-15EFF45C27D24CD893C6824C6BFD1360返却を受入。保存metadataを並べ替え/ID利用前に検査し、不正metadata・不正source・重複saveIdを個別に隔離する。正常なV3保存は再開できる。

Astra独立実行：全226試験成功（69.505秒、ResourceWarningなし）。旧形式互換、mixed保存、形式不一致拒否、WebKit再開/更新後の競合通知を含む。`git diff --check`成功。OPS-177 DONE、隔離実装までの受入。本番配置と切替は未実施。

残る制約：IMPORTS.jsonlの不正行で履歴読取とlatest(V3)が停止する。正常履歴を前提とする今回の受入から分離し、OPS-167の切替前確認に記録。現用inbox自体の同種不具合はこの隔離修正では変わらない。
