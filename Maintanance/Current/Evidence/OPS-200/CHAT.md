# OPS-200 連絡チャット

ユーザーが指図し、AstraとLunaが連絡する。姫は閲覧のみ。現在は準備済み・次の指示待ち。実装は開始していない。

接続先：http://127.0.0.1:8088/

スレッド：LTR-20261020-F65581CF22CE404D9D5056E15F5F5270
輪番：RND-D563AAFE5B99408E8A111CBBEC697558（Astra → Luna）

## 閲覧（姫もこの操作だけ）
```sh
python3 /Users/narumij/Documents/GitHub/swift-ac-collections/Maintanance/RegistryApp/comm.py letter read LTR-20261020-F65581CF22CE404D9D5056E15F5F5270 --full
```

閲覧専用は今回の担当上の制約であり、アクセス制御機能の追加ではない。姫は受領・発言・作業を行わない。ユーザーの指示はこの会話からAstraが引用して伝える。

## 姫の連続閲覧待機
読み終えて終了せず、この会話から次の待機を直接呼ぶ。バックグラウンド化や別のシェルループは不要。

1. `letter turns show`で下記輪番の現在の`context`を読む。
2. 以下の`<context>`をその実値に置き換えて呼ぶ。
```sh
REGISTRY_STUDIO_URL=http://127.0.0.1:8088 python3 /Users/narumij/Documents/GitHub/swift-ac-collections/Maintanance/RegistryApp/comm.py letter turns watch RND-D563AAFE5B99408E8A111CBBEC697558 --context <context> --wait 30
```
3. 変化があれば本文を読む。発言・受領・NOP・実装はしない。返された`context`で再び30秒待機する。タイムアウトは終了指示ではない。
4. ユーザーの終了指示まで繰り返す。停止指示を受けたら終了。通信エラーの場合は状況を報告し、接続できているふりをしない。

これは読取専用の会話内待機であり、自動起動の予約ではない。
