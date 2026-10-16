# Permutation移行調査の受入・統合記録

作成者：Astra。2026-10-15。対象：PERM-073・PERM-074・PERM-075。
基準HEAD：`cd2dd7ad3ac594b84bccc3fe62dd45779d88fb82`。

## 受入結果

ユーザーの起動・終了報告と3件の返却本文を受け、Astraが現行ファイルへ独立照合した。下記の訂正・補足を含む静的調査として3件を受け入れる。調査作業は完了。2026-10-15にユーザーがコミットを許可したため、成果・受入記録と同じコミットへRegistryのDONE記録を保存する。方式・工程の決定や実装開始は含まない。

原回答は変更しない。ワーカー1・2の冒頭の「未返却」は編集許可範囲外のテンプレート文として残っている。今回の返却受領・受入状態は本書とRegistryに記録する。

## 独立照合した主な根拠

- 構成：`Package.swift`のproduct、AcCollections・PermutationModule・PermutationTestsの依存とsettings、`Sources/AcCollections/AcCollections.swift`、既存RedBlackTree互換shimを照合。新旧入口とfacadeの検査が別に必要になるという整理を受け入れる。
- 公開面：通常型・入れ子型、borrowed版のcompiler条件、AtCoder 2025条件、公開surface testとcompiler fixture manifestを照合。新旧入口の型同一性や実buildの成功は未検証。
- 性能CI：`PermutationBenchmarks.swift`の登録titleと`CI.json`・`CI-Small.json`、`ci.yml`のcurrent/base分離、library転送、既存2系列の名前変換と結果正規化を照合。module改名だけではbenchmark title変更を要しない。
- 文書：module DocC入口とsymbol link、facade例、DocC matrix、既存Pages対象、`DOCUMENTATION_CI_PLAN.md`の公開先・URL未確認の記録を照合。品質文書に「旧module互換未決」が残ることも確認した。旧名を残すユーザー方針と、その実現方法の未決を区別して計画へ渡す。
- 確認時の未コミット変更はワーカー返却3ファイルのみ。source・manifest・workflow変更はない。今回もbuild・test・CI実行はしておらず、移行後の成功を保証しない。

## 統合時の訂正・補足

1. **先行互換の適用範囲**：Astraの依頼書にある「名前互換の先行merge後にrename」は範囲が広すぎた。ガイドが要求するのはbenchmark task title変更前のworkflow互換である。ワーカー1の新名shim先行追加・後段で依存を反転する案は選択肢であり、module移行の必須工程ではない。ワーカー3のDocC変更も、benchmark名互換を常に前提とはしない。各段階を動く状態に保つ条件は維持する。
2. **release candidate経路**：ワーカー2の主な照合対象は`ci.yml`だった。Astraが`.github/workflows/candidate.yml`も確認し、同じlibrary転送とArray系2系列の変換・正規化があることを補完した。benchmark titleを変える計画ではPR経路だけでなくcandidate経路も対象に含める。
3. **方式と要求の区別**：同じ型・実装を利用できることが要求であり、旧moduleからの再公開は有力な方式候補である。原回答の「維持対象」にある具体的なshim構成を、方式決定済みとは扱わない。
4. **確認範囲**：全ての外部URLや保存済み実行結果を網羅検査したものではない。旧名で取得した証拠は旧名のまま保持し、新targetのbuild・DocC・旧baseline比較は計画後の実行で確認する。

## 計画へ渡す入力

- 新実装targetを一つにし、旧入口とfacadeから同じ宣言へ到達させる構成を具体化する。新・旧・facadeの三入口と通常／2025互換modeを検証対象にする。
- module移行とbenchmark title整理を別の変更として扱える。titleを変更する場合だけ、PR・candidate双方で互換先行→green→title変更→比較完走の工程を設ける。凍結中PERM-063・064を自動再開しない。
- 新target・DocC入口・継続生成対象・現行品質説明を整合させる。旧名の履歴を一括置換せず、SPI URLは実在確認後に接続する。
- 具体的な方式・merge単位はユーザーと相談して計画する。旧moduleやCI互換の削除を完了条件にしない。

## 受領した原回答

- [ワーカー1返却](PERMUTATION_MIGRATION_WORKER_1_RESULT.md)：SHA-256 `3b43a52dfd23b1a0ef441558c7d498c621494812777f9a4aea6bdd9fe97225cc`。
- [ワーカー2返却](PERMUTATION_MIGRATION_WORKER_2_RESULT.md)：SHA-256 `7e9251306b66f0b255dad57625a60e25ad1072d6cd83d8a2c1147262061c96a5`。
- [ワーカー3返却](PERMUTATION_MIGRATION_WORKER_3_RESULT.md)：SHA-256 `7ba266b6cc6d2991d9504dd96bed3d03e1bcd1bf0181ab1dde3441d11d1b0cce`。

## 後続計画

2026-10-15、ユーザーが旧名を互換用として残し、benchmark名整理を後段まで遅らせる方針を確認した。[module移行計画](../../Current/PERMUTATION_MODULE_MIGRATION_PLAN.md)に、確認済み方針と具体工程案を分けて記録した。
