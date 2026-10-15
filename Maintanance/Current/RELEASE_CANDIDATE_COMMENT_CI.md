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

GitHub上でのコメント受信・実際の権限API・job実行・結果投稿は未検証。workflowを反映してからの疎通確認が必要。既存試験内容と性能比較手順は変更していない。

公式仕様: https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#issue_comment

## 残る準備

毎回ワーカーへ渡すリリース整形依頼手順書は別成果物として準備する。RELEASE_PROCESS.mdのユーザー手順は今回変更していない。
