# Permutation module移行：Astra受入記録

作成者：Astra。2026-10-15。対象：PERM-076。基準HEAD：`cc87b5b8`と返却作業差分。

## 結果

担当者が作業終了・占有返却を明記した返却を受領し、実装・ローカル検証を受け入れた。Astraによる下記の文書訂正を含む。2026-10-15ユーザーのコミット許可を受領。実装・検証は`1f87e37a`に保存し、文書・受入記録とRegistryのDONEを後続コミットへ保存する。remote CI・PR・main到達は未実施であり、移行全体は未完了。

原回答：[ワーカー返却](PERMUTATION_MODULE_MIGRATION_IMPLEMENTATION_RESULT.md)。原回答は編集していない。

## 独立確認

- manifestの新実装target・旧再公開target・facade依存を確認。実装Swiftファイルを移動前と比較し、通常ownerのgeneric parameter `Value`→`Element`と対応するtypealias整理以外の実装変更がないことを確認。既存test差分はimport切替であり、assertion削除はない。
- benchmark差分がimportの一行だけであることを文字列比較で確認。CI差分はDocC matrixへの新target追加のみ。benchmark library・title・測定処理は維持。
- `swift test --disable-sandbox --filter PermutationTests`：通常61件・Death Test17件成功。
- `sh Utilities/Maintenance/VerifyPermutationCompilerDiagnostics.sh`：正常4入口・期待拒否3件成功。
- 同fixtureの4正常targetを、scratch path `.build/permutation-surface-compiler-diagnostics-2025b`、`-Xswiftc -DCOMPATIBLE_ATCODER_2025`付きの`swift build --disable-sandbox --package-path Utilities/Maintenance/CompilerDiagnostics/PermutationPublicSurface --target <target>`で再検証、全件成功。
- 新旧moduleを同時importし、`PermutationModule.NextPermutations<Int>`を新module側の同型へ返す関数と、入れ子型の`Element`がIntであることを、一時sourceの`swiftc -typecheck`で確認。module cacheは`/tmp`、import先は通常fixtureのDebug出力。成功。
- 通常Release再実行は別targetのdSYM生成で`Operation not permitted`となった。`swift test --disable-sandbox -c release -debug-info-format none --filter PermutationTests`では通常61件・Death Test17件成功。ワーカーの通常Release成功報告とAstra環境での構成差を区別する。
- `swift package --disable-sandbox generate-documentation --target <新旧各module> --warnings-as-errors`：双方成功。生成JSONの各module識別子も確認。
- `git diff --check`成功。ローカル実行logは`.build/astra-perm076-acceptance/`（再生成可能な非追跡ファイル）に保存。macOS arm64 / Swift 6.4での範囲であり、Linux remote成功を意味しない。

## 受入時の修正・境界

- `DOCUMENTATION_CI_PLAN.md`で2026-10-13の取得済み証拠に新module名が混入していた。旧名5 targetの原記録を復元し、今回の継続対象6 target追加は別段落に分けた。
- 品質プロファイルに残った「旧名互換は未決」、現行品質評価の「実装配置は旧名」「名称familyは暫定」を、現在の決定・作業差分と検証範囲に合わせた。
- ワーカーは依頼の編集範囲外だった`Utilities/Permutation/GenerateAtCoder2025Permutation.swift`も変更していた。停止・申告すべき範囲逸脱であり、許可済みだったとは扱わない。Astraは今回の受入照合で、変更が移動に伴う入力path2件のみ、生成器の処理と入力source本文が同一であることを確認し、生成経路を壊さない必要な追随差分として受け入れた。この確認を今後の範囲拡張許可へ一般化しない。
- benchmark release build・task一覧、Xcode build、2025互換runtime5件はワーカー報告であり、今回は同じ操作を独立再実行していない。独立確認は上記の範囲に限る。

## 後続

ユーザー許可に基づき、実装・検証と文書・受入記録を分けて保存する。PR・remote CIでは各jobの実結果を確認し、DocCのcontinue-on-errorを全体greenで見落とさない。benchmark名整理は遅らせ、旧互換入口は維持する。

2026-10-15、ユーザーから、ワーカーに変更をまとまりごとにコミットさせると障害時の切り分けが楽になるとの助言を受けた。一つの整合したPRと一つのコミットを混同しない。次の依頼では、変更の区切りとcommitの許可を事前に明確にする。今回の返却者へ追加操作は依頼していない。

原回答SHA-256：`dc3f48284193f92608b815cc0447fe520cad90128edc8b7187fad4dee9758377`。
