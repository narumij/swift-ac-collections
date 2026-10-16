# 候補CIの比較元未登録taskへの限定対応

RELEASE-084 / 2026-10-16 / 作成・受入Astra、実装・検証Claude（姫）。ユーザーの「進行は任せる」に基づく限定依頼。RELEASE-083の調査受入済み成果を入力とする（commit待ちは実装開始を妨げない）。

## 方針と完了条件

候補CIが0.5.3を比較元にするとき、新規8測定が比較元に存在しないことを明示し、比較可能な測定と候補のみの測定を分ける。通常CIは今回変更しない。30%閾値・既存測定内容は維持する。

- 比較元SHAを139ffef8db3eb75d118dbaecc8a1ec05d2e9894fへ厳密に限定して、調査の8件だけを比較不能として許容する。別SHAの欠落は同じ名前でも失敗させる。存在する8件を機械的に除外しない。
- 候補側の全29測定を維持し、共通21件と比較元にない8件を結果・artifactに明示する。全29件の性能回帰が検証済みという表示にしない。
- 想定外の欠落、候補側の測定欠落、比較可能項目ゼロは失敗。名前変換後の完全なtitleで照合する。benchmark infoの出力形式を確認する。
- 取得可能な比較診断はstderrも保存し、測定結果や実装をbaselineへ移植しない。
- 実行workflowはdefault branch側から取得される。修正をPRに置くだけではコメント起動の仕組みが更新されない点を引継ぎに記載する。mainへ反映する操作は委任しない。

## 入力

- Current/RELEASE_CANDIDATE_BASELINE_INVESTIGATION.md の原ReturnとAstra受入。
- Current/Evidence/RELEASE-083/proposed/candidate-ci-baseline-tasks.patch は参考案。上記の制約に合わせて補修する。
- Current/PERFORMANCE_CI_CHANGE_GUIDE.md。特に古いPermutationと現行の性能契約の違いを保つ。8件欠落を直しても、異なる契約の比較まで有効と認定しない。比較契約の不一致が見つかれば報告して停止し、閾値・比較元を独断変更しない。
- .github/workflows/candidate.yml と Benchmarks/Libraries/CI.json・CI-Small.json。着手時にhashを記録する。

## 編集・検証範囲

編集可: .github/workflows/candidate.yml、Benchmarks/Scripts/配下の本対応専用filterと検証補助、Benchmarks/Libraries/配下の本対応専用の例外定義、以下Return、Maintanance/Current/Evidence/RELEASE-084/。

既存CI.json・CI-Small.json、ci.yml、製品・測定workload・Registry・Rules・他の返却物は変更しない。変更範囲外が必要なら理由を返す。共有.buildを使わず隔離した最小再現とし、一時物はCOMMONSに従う。

既知SHA＋8欠落、既知SHA＋想定外欠落、別SHA＋同じ8欠落、欠落なし、候補欠落、空比較、旧名変換を検証する。YAML・埋込shellの構文とpipelineの失敗伝播も確認。全規模性能測定・GitHub再実行・投稿・merge・commit・pushは含めない。修正を意味ある単位に整理し、後のcommitの分け方をReturnへ書く。

依頼完成をもって編集範囲を受渡し。Astraは返却まで対象を編集しない。既存のASan直接依頼とは独立。

## Return

未着手。変更一覧、入力hash、検証結果、未確認・残判断、公開前に必要な反映順序、作業終了・範囲解放を返す。
