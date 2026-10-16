# Registry閲覧編集試作

2026-10-16、Astra。OPS-051、親OPS-048。

ユーザーがSafari利用を示し、試作を依頼した。単一HTML＋JSONのローカル試作を行う。状態・担当・項目・条件と明示依存を編集してJSONを保存し、AIへ反映依頼する方式。原文と生成元のhash、編集前後を残す。実Registryへの書戻し・自動着手判定は行わない。

試作はMaintanance/RegistryApp/に置く。現行Registryからのsnapshotは取得時点の写しで、ライブ同期ではない。登録・受入による状態変化も含め版のずれを表示する必要がある。

## 検証と返却

[試作と使い方](../RegistryApp/README.md)に配置。HTMLに38 task・11辺のsnapshotを内蔵し、一覧・グラフ・条件等の編集・依存追加削除・変更表示・JSON読込/保存を実装した。外部package・通信・サーバーは不要。

verify.cjsでJS構文、データモデル、変更前後、baseline保持、JSON往復、不正依存の拒否、未知値保持を確認済み。Safari画面操作権限がなく実機試験はできなかった。PlaywrightのWebKit本体も未導入で、UI・ダウンロード・見た目は未検証。したがって試作実装済み・ユーザー試用待ちとし、動作受入完了にはしない。

JSONは実装中のRegistryを採取した固定snapshot。OPS-051の作業状態も取得時点のまま。アプリは版を表示し、ライブ同期や元Markdownへの直接反映は行わない。AIへの反映手順とデータ形式はREADMEに記載した。

2026-10-16、ユーザーが起動スニペット方式を希望。READMEへ起動手順を記載した。今回のcommit指示は作業保存として受け、OPS-051はSafari試用待ちのWAITING_USERを維持する。
