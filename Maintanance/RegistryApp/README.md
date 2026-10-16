# Registry Studio — Safari向け試作

## 開き方

index.htmlをSafariで開く。38タスク・9依存辺の生成時snapshotを内蔵しているので、最初の読込操作は不要。別のデータは「JSONを開く」で選ぶ。

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

JS構文とデータ処理：38件・9辺、変更前後、baseline維持、JSON往復、重複・自己依存・参照切れ・Flow不正・循環、未知状態・追加属性保持を確認済み。verify.cjsをNode.jsで再実行できる。

Safari UIは未検証。操作権限がなく実機試験できず、自動試験用WebKit本体も環境に未導入だった。DOM描画、実ダウンロード、画面レイアウトはユーザー試用で確認する。HTML file inputとdownloadを使う設計で、Safari専用の直接上書きAPIを必要としない。
公式参考：https://webkit.org/blog/12257/the-file-system-access-api-with-origin-private-file-system/

試作データは生成時点の写し。受入・状態更新で正本が進んでも自動更新しない。

## 起動スニペット

ユーザー希望により、プレビューは起動スニペットを渡し、ユーザーが実行する。

```sh
open -a Safari "/Users/narumij/Documents/GitHub/swift-ac-collections/Maintanance/RegistryApp/index.html"
```

Astra側のopenはSafari名解決失敗、絶対path指定でもkLSNoExecutableErrとなり、起動を確認できなかった。ユーザーによる実機試用結果は未記録。

## マイルストーンの骨格（追加試作）

0.6.0 → 0.7.0 → SPI公開 → 人間レビュー → 1.0品質判断を上段の金色nodeで示す。1.0品質判断は既存QUALITY-001を表示上の到達点として用い、同じ判断を重複nodeにしない。Validation計画レビューと赤黒木本文準備を含む6件の表示用milestonesと、正本の引用・path・hash・行番号付きmilestoneRelations 13件を追加した。MS-*はアプリ内IDで新規Task IDではない。

関係はstage（段階前提）、required（必須）、material（判断材料）、after（到達後の実施条件）、resume（到達後の再開判断）を区別する。単なる所属から必須依存は作らない。図の横順は実行順・実行許可を確定しない。全要件を網羅した図ではない。

task間依存と合わせたグラフを検査し、接続したtaskは独立列から外す。マイルストーン選択時は正本と前後関係を読み取り専用で表示する。選択状態は一覧・グラフ・独立列で共有する。マイルストーン編集は未実装。

旧JSONを開いた場合、そのデータにmilestonesがなければ旧taskグラフのみになる。最新版の内蔵データまたは同梱registry.jsonを使う。元Registryのsnapshot時点とマイルストーンを採取した時点は異なるため、各source情報を保持している。

2026-10-16：ユーザーによる関係除去とJSON保存・返却を初めて確認し、直接依存2本の除去を正本へ取り込んだ。配布snapshotも更新済み。線のクリックでtask依存・マイルストーン関係を除去できる。UI全体の検証完了を意味しない。

## 配置の共通ルール（2026-10-16）

1. 骨格を表示グループ順に並べる。通常の骨格間隔は基本列295pxの1.5倍。途中の横手順がある区間は必要な列数を確保する。
2. 下側の枝は骨格左端から黄金比短辺（幅250pxの約38.2%）右、上端から136px下。複数件は116px間隔で縦積みする。補助見出しがある場合は116px下に置き、枝はその下から積む。
3. 横手順は295px間隔で並べる。上側の枝は骨格から右295px・上130pxへ置き、次の骨格はその左端から黄金比短辺だけ右へずらす。
4. 全接続nodeの収容、辺の前進方向、カード矩形の非重複を確認する。表示グループに収まらない新nodeや接続変更があれば、全体を依存順の自動配置に切り替える。

6つの表示グループは`graphLayout`冒頭の宣言に集約。グループの所属・順番は表示上の意図であり、依存・担当・実行順を作らない。個別IDを条件にした座標補正は使わない。データ・依存・保存形式は変更しない。
