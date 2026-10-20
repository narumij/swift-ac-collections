# OPS-187 証拠

- base: `689ba68f9e1be76f09034f36c33af731deb25523`（使い捨てのclone）
- `changes.patch`（sha256 `5e640c4f030f78ce9bedf583503a725f18c1fce43bd46bc33ace81c6e8165720`）
  - 新規2ファイルだけ：`Maintanance/RegistryApp/test-letters-e2e.py`・`Maintanance/RegistryApp/letters_e2e.cjs`
  - 実装の変更はない。
  - baseの`Maintanance/RegistryApp`をexportした場所に、`patch -p1 --dry-run`で当たることを確かめた。
  - 補足：`git apply --check`は、この環境の確認フックが時間切れになって実行できなかった。
- 実行の命令（リポジトリ直下で）：`python3 -B Maintanance/RegistryApp/test-letters-e2e.py -v`
  - 要るもの：node、globalのPlaywright（WebKit）、起動時のsyncに使うnodeとmarked。
  - marked：生きた`local-tools.json`があれば、読み取りだけで一時の出力先に写す。cloneでは`REGISTRY_STUDIO_MARKED`で与えた。

| file | 内容 |
|---|---|
| `run1.txt`〜`run3.txt` | base＋patchで3回、各OK（約7秒） |
| `roundtrip.json` | 3回目のdriverの記録（行・本文・要求の一覧・期待の時刻）と、サーバーの記録（`/letters/<id>`） |
| `negative-ui-receipt.txt` | 画面の一覧が受領日時を無視する改変 → FAIL（状態は「受領」なのに「受領日時 未受領」のまま） |
| `negative-server-brief.txt` | サーバーの一覧が`receivedAt`を返さない改変 → FAIL |
| `negative.sh`・`negative-summary.txt` | 否定対照の手順と結果（cloneの中だけで改変し、`git checkout`で戻した） |
| `existing-letters-py.txt`・`existing-letters-cjs.txt` | 既存の`test-studio-letters.py`（25件OK）と`test-view-model-letters.cjs`（PASS）。base＋patchで実行 |
