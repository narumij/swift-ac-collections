# Inbox — Studioの編集版の保存先・受渡し先（OPS-082試行）

Registry Studioをローカルサーバー（`serve.py`）で開いて「保存」を押すと、編集結果のJSONがここに1回ごとに別ファイル（`registry-edited-<UTC時刻>-<乱数>.json`）で追加される。以前の保存は上書きしない。保存先はサーバー側で固定で、画面からは場所を選べない。

- ここにあるJSONは、Registryへの反映でも、作業の着手許可でもない。AIはユーザーに取込を頼まれたときだけ読む。
- 取込の手順は`../README.md`の「AIがJSONを取り込むとき」と「サーバー保存とInbox」に従う。
- 各保存には`studioSave`（保存ID・保存時刻・系列・前版・土台の正本sha256）が付く。Studioは直近の保存を編集版として再開する。古いタブから保存すると、上書きせずに別の系列として残る。
- 取込記録は`IMPORTS.jsonl`（保存とは別ファイル）。`python3 ../inbox.py list`で保存と取込済みかを確認し、`python3 ../inbox.py record <保存ID> --note "…"`で記録する（同じIDの二重記録は拒まれる）。
- 保存JSON（`*.json`）と取込記録（`*.jsonl`）は`.gitignore`でcommitの対象外。保存は上書き・期限削除・取込後削除をしない。
