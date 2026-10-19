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
