# V3読取用viewの隔離生成

## TL;DR
既存文書の説明・目標・履歴を残し、DB管理の表だけを生成する。マイルストーン構造は別viewで照合する。本番文書は書き換えない。

OPS-175 / EXECUTION / Astra調整・姫 / OPS-167 K8a / 2026-10-19継続指示。

## 採用範囲
返却LTR-20261019-CF44B7F5905E4B7B86037AF1899F7A58の限定案。Registryのtask/precedence/親子/マイルストーン接続のdata行、Rules採番表のdata行のみを生成する。他の本文・見出し・表headerは保持し、生成注記を明示する。既存行順を維持、新規行はID順に追加する。存在しないgroupや曖昧な表、表現不能な値は推測せず拒否する。

出力は新規の隔離treeだけ。入力は固定copyでread-only。生成注記にはDB世代/改訂と行hashを持たせ、編集された生成行を無言で上書きしない。非生成部分の保持を検証する。

Registry表の再読込とDB属性/辺、Rules採番境界の一致をそれぞれ検証する。恒久指定の文章は変更せず、DBとの不一致を報告し正常扱いしない。退役taskの除外と関連辺の扱いは明示し、欠落を正常一致へ隠さない。

版順・card順・gate・focus・recordedDone等はDBから別STRUCTURE viewへ生成し再読込で一致確認。古いファイル配置をコピーして一致の証拠にしない。Milestones folder/HEADの一致やfull shadow roundtripを保証したとは呼ばない。配置差は検証とは別のdrift報告にする。

## 実装と検証
experiment内views module/test/READMEのみ。fixture、固定した現行正本copy、CLI更新後の再生成、未知layout/値拒否、生成行改変検出、入力不変を試す。原文全体を読み直す作業や履歴移行には広げない。HEAD・恒久指定の正本切替、本番採用は別。姫が実装・返却、Astraが受入・記録・commit。

## 受入確認（2026-10-19・補正待ち）
Astraによる独立実行では196試験が成功。ただしfixtureで次の2点を再現したため、受入は保留。
- 恒久指定が不一致でも全体の`equal`がtrueになる。文章は保持し、不一致を全体結果にも反映する必要がある。
- task行の余分なセル・重複IDを生成時に拒否せず、上書きで消してしまう。生成前に入力行の形と一意性を検証する必要がある。

姫へLTR-20261019-5EB84E8DD364492E88F683CDF2FDCD1Fで限定補正を依頼。実DB・本番文書は未変更。返却後に再検証する。

## 補正後の受入（2026-10-19）
LTR-20261019-5EB84E8DD364492E88F683CDF2FDCD1F返却をAstraが確認。恒久指定/件数accountingを全体結果に含め、生成前に既存importerの行形式検査とkey重複検査を行う補正を受入。Rules採番行も生成前に検査する。

Astra独立実行：`python3 -B -W always::ResourceWarning -m unittest discover -s Maintanance/RegistryApp/Experiments/registry_v3_read -p 'test_*.py'`、198件成功（47.291秒）。既存生成行の改変拒否、入力copyの不変、現行固定copyの範囲内一致を含む。`git diff --check`成功。

OPS-175はDONE。保証は隔離した読取view生成・照合まで。本番接続、Milestones folderの往復、移行全体の完了を意味しない。
