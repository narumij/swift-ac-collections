# Release 0.5.2

最終更新: 2026-10-09 / Codex

## 状態

0.5.2を現在の中間ゴールとして、前提となるコメントドック作業を開始した。独立した事前棚卸しを閉じてから
執筆する方式は取りやめ、対象別にTest as Specificationを確認しながら期待動作を公開APIコメントへ記載する。
  全公開対象のレビュー用ドラフトと検証は完了し、release検討開始条件へ到達した。
現時点ではrelease候補commit、到達範囲、必須gate、tag位置をまだ決定していない。release rehearsal関連taskの
凍結も維持し、0.5.2の到達範囲判断時に採用するrelease工程を別途決める。

0.5.2は、製品上の到達範囲とは別に、`prepare/release/template`から`release/0.5.2`を作成し、mainをmergeして
専用工程を通すtemplate branch方式の初回rehearsal候補とする。実際の適用はrelease検討開始後に判断し、
この記録だけではbranch作成、merge、tag、pushを許可しない。

## Release検討開始条件

全公開対象のコメントドックについて、公開契約に接続され、ユーザーが内容をレビューできるドラフトが
揃っていることを、0.5.2のrelease検討を始める条件とする。

対象にはPermutation、OptionalArray、BareArray、RedBlackTreeの公開APIを含む。ドラフトは契約内容を
確認できる段階を指し、文章の最終校正、公開可能な初版への仕上げ、release noteの完成までは要求しない。

これはrelease完了条件ではない。条件到達後、ユーザーが0.5.2へ含める製品上の到達範囲と、release
checklistへ進むかを一つの判断として確定する。

## 依存の登録方針

各対象のコメントドック作業taskが具体化した時点で、この判断taskへ必須依存を接続する。未登録の作業を
推測でtask化したり、既存の利用者向け文書ドラフト中間ゴールをコメントドック完成と読み替えたりしない。

## コメントドック作業task

- `DOC-002`: 独立した事前棚卸しを完了させてから執筆する方式を取りやめ、`EXCLUDED`。各対象の実行taskで
  Test as Specificationを確認しながら期待動作を直接コメントへ記載する。
- `DOC-003`: Permutation全体のコメントドック・ドラフト完成判定。2026-10-09完了。通常版のドラフトと
  検証を受け入れ、AtCoder 2025互換modeを0.5.2の対象外とする`DOC-007`の決定により追加実行なしで閉じた。
- `DOC-004`: OptionalArrayのコメントドック・ドラフト作成と検証。2026-10-09完了。現行名の公開29宣言と
  4適合をTest as Specification・実装へ再照合し、所有、View寿命、破棄、変更共有、軸、境界、計算量を
  コメントへ記載した。Debug／Release通常35件＋Death Test 21件、documentation warning-as-error成功。
  0.5.2段階の成果としてユーザーへ引き渡し済み。命名判断は0.6.0の到達範囲判断へ移した。
- `DOC-005`: BareArrayのコメントドック・ドラフト作成と検証。8群のTest as Specificationを確認しながら、
  公開29宣言へ初期化、軸順、連鎖アクセス、View共有、`indices`、要素寿命、範囲外停止、writeback制約、
  不正寸法、計算量を記載した。Debug／Release通常testとDeath Test 42件、code issues 0件、documentation build成功。
- `DOC-006`: RedBlackTree 4公開型のコメントドック・ドラフト。既存の公開コメント横断監査、4公開型の
  Head原稿、API Matrix、Test as Specification、Release DocC検証により、0.5.2が要求するユーザーレビュー可能な
  段階へ到達済み。`RBT-014`は公開可能な利用者向け文書初版へ進む0.6.0側の作業として分離する。
- `DOC-007`: Permutation通常版とAtCoder 2025互換modeのコメントドック境界を一つ決める`DECISION` task。
  2026-10-09、0.5.2の対象は通常版だけとし、互換modeは含めないとユーザーが決定した。
- `DOC-008`: `DOC-005`のBareArrayコメントドックをTest as Specification、実装、受入済み契約と照合する
  Claudeの独立レビュー。公開29宣言のcoverage、Test as Specificationとの一致、BLOCKなしをCodexが受入済み。
- `DOC-009`: View保持中のSendable注記候補。Codex再検収で、`@unchecked Sendable`の妥当性を覆す
  指摘ではなく一般的な並行アクセス規則を重ねる蛇足と判定し、追記せず`EXCLUDED`。
- `DOC-010`: 既存の「C言語の配列に近いアクセス性能」の再検討。比較対象はSwiftの`[[Element]]`で、
  COWと連鎖subscriptによる深刻な性能劣化を迂回する設計意図があると確認した。アンカリングを避けるため、
  ユーザー指示による再訪までCodex担当の`DISCOVERY`として`FROZEN`。
- `DOC-011`: Permutation通常版だけのコメントドック・レビュー用ドラフト作成と検証。2026-10-09完了。通常版のTest as
  Specificationへ照合し、Debug 32件＋Death Test 5件、Release 28件＋Death Test 5件、documentation
  warning-as-error成功。0.5.2段階ではユーザーがレビューできるドラフトの引き渡しを完了条件とし、内容の受入レビューと
  Claude独立レビューは要求しない。`DOC-007`は解除せず、互換modeのsource・test・文書は変更していない。

### 3対象の実行分解（2026-10-09）

- Permutation: 通常版には入口、列挙規則、重複要素、値semantics、Index、計算量、範囲条件の既存コメントが
  ある。通常版の公開memberをTest as Specificationへ接続する`DOC-011`は先行できる。互換modeを同じ対象へ
  含めるかは`DOC-007`で後から決め、Permutation全体の完成判定前に合流する。
- OptionalArray: 完了。既存ledgerの公開29宣言と4適合を現在のsourceへ再照合し、コメントの無かった19宣言、
  全宣言で未記載だった計算量、capacity保持、所有・破棄・View寿命・変更共有・境界・軸を現行名で文書化した。
  `OPT-044`と`OPT-045`は0.6.0ゲートで合流する。
- BareArray: 完了。受入済み契約判断と8群のTest as Specificationを公開宣言ごとに照合し、期待動作を
  コメントへ記載して検証した。

各実行taskの共通完了条件は、対象公開宣言にコメントが対応し、契約正本とTest as Specificationへ追跡でき、
documentation buildの結果と未確認事項が記録され、ユーザーが本文をレビューできることである。最終校正、
公開可能な初版への仕上げ、release実行は含めない。

## 中間ゴールとの距離

- `DOC-002`〜`DOC-006`は`NEAR`。0.5.2の到達範囲判断に必要な入力を揃えるが、それ自体は0.5.2の完成ではない。
- `RELEASE-006`は`DIRECT`。コメントドック完了後、0.5.2の製品上の到達範囲とrelease開始を決める。
- `RELEASE-022`は`DIRECT`。後から分解する準備・検収taskが証拠を揃えた後、固定候補を0.5.2として
  releaseしてよいか、ユーザーが一つだけ判断する。

準備・検収と可否決定後の公開操作は、採用するrelease工程が具体化した時点で別taskへ分解する。
早期に登録した`RELEASE-021`と`RELEASE-023`は未着手のまま`EXCLUDED`とし、IDを再利用しない。
`RELEASE-022`も現時点では`PROPOSED`であり、候補commit、gate、branch方式、tag、pushを許可しない。

## Release可否ゲート

`RELEASE-022`を0.5.2の明示的なgo/no-goゲートとする。これは到達範囲とrelease検討開始を決める
`RELEASE-006`とは別の判断である。`RELEASE-006`は「何を候補として検証するか」を決め、`RELEASE-022`は
「検証済みの固定候補を実際にreleaseしてよいか」を決める。

最低入力は、候補commitとtree、必須local gate、同じcommitに対するremote CI、documentation、必要な性能結果、
独立確認、release阻害・非阻害・後続へ分類した既知事項である。一つでも必須証拠が未確認または対象commitと
不一致なら、release可とは判断しない。可否決定はtag、push、release pageの承認を兼ねない。

## 条件到達後の流れ

1. 前versionからの差分を確認し、0.5.2へ含める変更と後続へ残す変更を分ける。
2. ユーザーが製品上の到達範囲とrelease検討開始を判断する。
3. 採用時だけ[`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md)に従い、候補commit、必須CI、文書、性能、
   独立チェックを設計する。
4. tag作成、push、release page、後続branch統合は、それぞれ対象を示して別途承認を得る。

この文書とtaskの登録は、release、tag、pushを許可しない。
