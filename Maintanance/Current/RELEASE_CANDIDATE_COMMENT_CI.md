# PRコメントによる候補試験

作成者: Astra / 2026-10-16 / RELEASE-080

## 操作

同じrepositoryのopen PR（Draft可）へ、write/maintain/admin権限のあるユーザーが、本文を正確に `/test release` とした新規コメントを投稿する。受付jobが権限とPR状態を確認した時点のhead SHAを固定する。コメント投稿時刻そのもののSHAを遡及取得する方式ではない。受付後の追加commitは今回の結果に含まれない。

`.github/workflows/candidate.yml`をデフォルトブランチへ反映した後に利用できる。ローカル編集だけでは起動しない。既存candidate-* tagのpush経路も維持する。

Debug（既存の寿命balance検査除外trait＋Death Test）、Release（Death Test）、RedBlackTreeCollections DocC、性能比較を既存の条件で実行する。ASan併用は追加していない。通常CIの手動性能比較とは別経路。

結果はPRへ対象SHA・各jobの結果・Actionsリンクとして返す。全jobがsuccessのときだけPASS。失敗・cancelled・skippedはNOT PASSED。workflow全体を強制停止した場合やGitHub側障害・権限拒否では報告job自体が実行できないことがあり、Actionsの状態を確認する。無関係なコメントは受付jobをskipする。

## 境界

- fork PR、closed PR、write権限のない投稿者は試験を開始しない。
- 試験jobはcontents:read、checkoutの認証情報保存を無効化。
- PR書込み権限は候補コードをcheckout/実行しないreport jobだけに置く。受付はreadのみ。
- 元コメントから任意のshell文を実行しない。
- PRのmerge合成commitではなくリリースブランチのhead SHAを検査する。結果表示にSHAを明記する。
- このworkflowは整形、merge、tag、公開、受入判断を行わない。
- candidateの性能比較に必要なBenchmarks実行資材、Tests、DocC入力を整形で削除しない。

## 検証

Ruby PsychでYAMLをparseし、取り出したgithub-scriptをNodeでmock実行。tag経路、write/maintain/admin受付、read拒否、closed/fork拒否、4jobの固定SHA checkout、成功・失敗・cancelled・skippedの結果報告を確認。git diff --check成功。

実装時点ではGitHub上の実動疎通は未検証だった。その後の確認結果と残件は下記に記録する。既存試験内容と性能比較手順は変更していない。

公式仕様: https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#issue_comment

## 残る準備

毎回ワーカーへ渡す整形依頼手順書のドラフトは `Maintanance/Current/RELEASE_SHAPING_WORKER_REQUEST_DRAFT.md` に作成済み。人間主体の手順は `Maintanance/User/RELEASE_PROCESS.md` にPRコメント起動方式を反映済み。これらの文書整備をCI成功の証拠にはしない。

## 実動確認と後日調査（2026-10-16）

ユーザーの「CIの件はあとで」に従い、既存の `RELEASE-080` を原因調査の `DISCOVERY` として `FROZEN` に更新した。重複taskは作らず、明示的な再開指示まで調査・修正・再実行を進めない。

確認した実行：[run 38765855176](https://github.com/narumij/swift-ac-collections/actions/runs/38765855176)（issue_comment）。GitHub APIのjob・annotationを照合した。

- resolve、debug-all-tests、release-all-tests、documentation：success。
- performance：`Run baseline benchmarks` がexit code 1で失敗。比較元の実行段階であり、性能回帰の閾値超過と判断しない。
- report：`One or more candidate checks did not succeed.` のannotationで失敗。候補試験の失敗を集約して赤にする設計と一致する。PRへの結果コメントそのものは未照合。
- 詳細logのAPI取得は403で拒否された。失敗の具体的な原因、baseline tag、受付が固定した候補SHAは未確認。runに表示されるworkflow側のhead SHAを候補SHAとして代用しない。

再開時は実行logと結果コメントから対象SHA・baseline tag・失敗内容を確かめ、既存の候補tag経路と共通する問題かを切り分ける。原因と必要な修正範囲を記録した後、修正・検証の作業を具体化する。性能基準を緩めたり失敗をskipしたりして成功に見せない。最終的な疎通確認では、対象SHAに対する性能比較の完走と、各試験結果・PRへの結果返却を確認する。
