# Release 0.5.2

最終更新: 2026-10-09 / Codex

## 状態

0.5.2を現在の中間ゴールとして、前提となるコメントドック作業を開始した。独立した事前棚卸しを閉じてから
執筆する方式は取りやめ、対象別にTest as Specificationを確認しながら期待動作を公開APIコメントへ記載した。
全公開対象のレビュー用ドラフトと検証は完了した。2026-10-09、ユーザーはBareArray、Permutation通常モード、
OptionalArray、RedBlackTreeのコメントドック・ドラフトを0.5.2の製品スコープとして採用し、release checklistへ
進むと決定した。現時点ではrelease候補commit、必須gate、tag位置をまだ決定していない。release rehearsal関連taskの
凍結も維持する。

2026-10-09、template branch方式は準備不足のため0.5.2では中止した。0.5.2は0.5.1相当の工程とし、作業branchで
候補を準備・検証し、PRでmainへmergeした後、main CIがgreenになった同一main commitをtag候補とする。
`prepare/release/template`または`release/0.5.2`は使用しない。この決定だけではPR作成、merge、tag、pushを
許可しない。

## Release branch方式

- 候補準備とlocal検証は現在の作業branchで行う。
- 固定候補をremote CIと独立確認へ渡し、必要な修正があれば候補を固定し直す。
- release可否判断後、別途承認されたPRをmainへmergeする。
- main CIが同じmerge commitでgreenになったことを確認し、そのmain commitをtag候補とする。
- tag作成、tag push、release pageはそれぞれ別操作として承認を得る。
- template branch rehearsalとrelease tree変換は0.5.2の工程へ含めない。

## Release検討開始条件

全公開対象のコメントドックについて、公開契約に接続され、ユーザーが内容をレビューできるドラフトが
揃っていることを、0.5.2のrelease検討を始める条件とする。

対象にはPermutation、OptionalArray、BareArray、RedBlackTreeの公開APIを含む。ドラフトは契約内容を
確認できる段階を指し、文章の最終校正、公開可能な初版への仕上げ、release noteの完成までは要求しない。

これはrelease完了条件ではない。条件到達後、ユーザーが0.5.2へ含める製品上の到達範囲と、release
checklistへ進むかを一つの判断として確定する。2026-10-09、この判断は採用で完了した。

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

## 候補計画の具体化

2026-10-09、製品範囲とbranch方式の決定を入力に、0.5.1から現HEADまでの差分を確認した。製品差分は
BareArray、OptionalArray、Permutation通常モードの公開コメントで、RedBlackTreeのレビュー用ドラフトは0.5.1時点の
treeですでに到達済みである。残りは内部管理文書であり、0.5.2ではmain commitをそのままtag候補にするため、
template方式のrelease tree変換や内部管理文書の除外は行わない。

0.5.1相当として、次を必須証拠とする。

- local gate: Debug／Releaseの全test、Death Test、documentation warning-as-error、公開API・再公開面・Package構成の差分確認。
- remote gate: 通常test、Linux、documentation、Address Sanitizer、performanceを含むworkflowの全必須job。
- 記録境界: CHANGELOGとrelease記録を候補commitへ含めてから固定し、tag後の記録は新しい作業branchへ積む。
- 独立確認: local／remote gateが同じ候補commitで揃った後にClaudeが変更せず確認する。使用量制約が解消するまで待つ。
- 操作境界: branch pushはユーザー専任とし、Codexは実行、承認依頼、催促を行わない。PR merge、tag作成、tag push、
  release pageも必要な段階でそれぞれの権限境界に従う。

この計画を、候補内容の準備・固定、local一次検収、remote CI、Claude独立確認へ分解した。候補固定後に製品差分または
release記録を変更した場合は、候補を固定し直し、影響する証拠を同じcommitへ取り直す。

### 候補内容の準備

2026-10-09、CHANGELOGへ0.5.2の実差分を追記し、内容基準commitを`5eb56236`（tree
`bea2f5a886c534a5695df9b897e2bf0e178750b0`）に固定した。0.5.1からの公開source差分はBareArray、
OptionalArray、Permutation通常モードのコメントだけで、Package.swift、workflow、READMEに差分はない。
RedBlackTreeのレビュー用ドラフトは0.5.1のtreeにすでに含まれる。Task Registryと本記録を同期した後のHEADを
local一次検収の対象とし、それ以降に製品差分が入った場合は候補を固定し直す。

### Local一次検収

2026-10-09、候補`c092d625`で次を実施した。

- `swift test --disable-sandbox -c debug`: 成功。通常testとDeath Testを含む。
- `swift test --disable-sandbox -c release`: 成功。通常testとDeath Testを含む。
- CIと同じRedBlackTreeCollectionsのRelease DocCを`--warnings-as-errors`付きで生成: 成功。
- BareArrayModule、OptionalArrayModule、PermutationModuleのDocCを`--warnings-as-errors`付きで生成: 成功。
- 0.5.1からPackage.swift、workflow、READMEに差分なし。公開sourceの変更は3対象のコメントだけ。

Permutationの`withUnsafeMutablePointers`未使用result警告とDebug probeのstrict-memory-safety警告は既存であり、
今回の製品差分では導入していない。testとDocCは成功しているため0.5.2の非阻害事項とし、暗黙に解消済みとは扱わない。
本記録の同期後、同じ内容のHEADをremote CI候補とする。branchのremote pushはユーザー専任であり、Codexは
実行、承認依頼、催促を行わず、push後のCI確認だけを担当する。

### Remote CIとrelease可否

2026-10-09、ユーザーが固定候補branchをremoteへpushし、CI greenを確認した。0.5.2はユーザーへのコメントドック・
ドラフト引き渡しを目的とし、Claudeの使用量制約下では独立レビューなしで進めるという既決事項に従い、独立確認は
release阻害条件から除外した。同日、ユーザーはlocal一次検収とremote CI greenを入力に、固定候補を0.5.2として
release可と判断した。この判断はPR merge、tag作成、tag push、release pageの操作承認を兼ねない。

### Main mergeとtag

2026-10-09、PR #178をmainへmergeし、merge commit `631cb59a2ae38e04d2429531a60e6441c7b1839b`に対する
main CI greenを確認した。ユーザーの明示承認後、message `Release 0.5.2`のannotated tag `0.5.2`を同commitへ
local作成し、tag対象を読み戻した。同じ明示指示に基づいて`refs/tags/0.5.2`だけをoriginへpushし、remoteの
peeled tagが同じcommitを指すことを確認した。

tag objectは`93b431deb0b6d810e996097533b36a82b7ac6928`、対象commitは`631cb59a2ae38e04d2429531a60e6441c7b1839b`。
release pageは作成しておらず、この操作の承認にも含めていない。tag後の記録はmainではなく
`develop/misc/54`へ積む。
