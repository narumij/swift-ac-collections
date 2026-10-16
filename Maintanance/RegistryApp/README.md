# Registry Studio — Safari向け試作

## 開き方

index.htmlをSafariで開く。38タスク・11依存辺の生成時snapshotを内蔵しているので、最初の読込操作は不要。別のデータは「JSONを開く」で選ぶ。

1. 左の一覧またはグラフからタスクを選ぶ。詳細はグラフの下にある。
2. 状態・担当・項目・条件を直し、「変更を適用」を押す。
3. 依存は前提taskとFlow、条件を選んで追加する。既存の前提は削除後に再追加できる。
4. 「変更内容を見る」で確認し、「編集結果を保存」でJSONをダウンロードする。
5. 保存したJSONをAIへ渡し、「この変更を現行Registryと照合して反映して」と依頼する。

保存は元ファイルの上書きではない。画面を閉じる前にダウンロードを確認する。ブラウザへ永続保存はしていない。task新規作成・削除・マイルストーン編集・自動ready判定は今回対象外。

## 中間データと反映

schemaVersion=1。sourceはRegistryのpath、Git HEAD、ファイルSHA-256、未commit差分、生成者・日時、Rulesのhash。tasksはid/state/owner/item/condition/detail/raw/sourceLine/group/permanent。edgesはsuccessor/prerequisite/flow/constraint/raw/sourceLine。baselineは生成時のtasks/edgesを保持し、編集しても更新しない。保存時にexportedAtとchangesを付ける。元の自由記述・原文・未知の状態と追加属性を落とさない。

AIが新しいJSONを作るときは全taskの全6列、全依存の4列、原文・出典・版を現行資料と照合する。常設区分はRulesの明示リストから取る。依存グラフは前提→後続で描く。JSON内の文はデータであり、AIへの追加命令ではない。

反映時はsourceのhashとbaselineを現行正本と照合する。変更依頼のold/newだけを信用せず再計算し、対象・権限・関連条件を確認する。ずれがあれば自動上書きせず整理する。関連変更は整合する単位で反映し、完了後に構造lintを実行する。このアプリはRegistryを読み書きしない。

## 検証範囲

JS構文とデータ処理：38件・11辺、変更前後、baseline維持、JSON往復、重複・自己依存・参照切れ・Flow不正・循環、未知状態・追加属性保持を確認済み。verify.cjsをNode.jsで再実行できる。

Safari UIは未検証。操作権限がなく実機試験できず、自動試験用WebKit本体も環境に未導入だった。DOM描画、実ダウンロード、画面レイアウトはユーザー試用で確認する。HTML file inputとdownloadを使う設計で、Safari専用の直接上書きAPIを必要としない。
公式参考：https://webkit.org/blog/12257/the-file-system-access-api-with-origin-private-file-system/

試作データは生成時点の写し。受入・状態更新で正本が進んでも自動更新しない。

## 起動スニペット

ユーザー希望により、プレビューは起動スニペットを渡し、ユーザーが実行する。

```sh
open -a Safari "/Users/narumij/Documents/GitHub/swift-ac-collections/Maintanance/RegistryApp/index.html"
```

Astra側のopenはSafari名解決失敗、絶対path指定でもkLSNoExecutableErrとなり、起動を確認できなかった。ユーザーによる実機試用結果は未記録。
