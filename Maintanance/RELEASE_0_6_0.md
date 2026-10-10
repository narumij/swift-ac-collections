# Release 0.6.0

最終更新: 2026-10-10 / Codex

## 現在の状態

release検討開始条件待ち。これはactive release Registryではなく、0.6.0を開始できる状態とversion固有の
要件だけを保持する入口である。現時点ではrelease候補commit、製品上の到達範囲、branch方式、必須gate、
tag位置を確定しない。

`_ReleaseTask/ACTIVE.md`は作成しない。この文書の存在、taskの登録、rehearsalの実施は、release、branch作成、
commit、tag、push、公開を許可しない。

## Release検討開始条件

全公開対象の利用者向けドキュメントが、公開可能な初版として揃っていることを、0.6.0のrelease検討を
始める条件とする。

対象にはPermutation、OptionalArray、BareArray、RedBlackTreeを含む。初版は公開契約と整合し、利用者が
主要な用途、基本操作、重要な制約を理解できる状態を指す。以後の加筆や改善余地がないことまでは要求しない。

これはrelease完了条件ではない。条件到達後、ユーザーが0.6.0へ含める製品上の到達範囲とrelease作業を
開始するかを、一つの判断として確定する。

## 開始判断までの依存

各対象の利用者向けドキュメント初版を完成させるtaskが具体化した時点で、通常Task Registryの0.6.0開始判断へ
必須依存を接続する。ドラフト作成taskを初版完成と読み替えず、レビューと公開可能性の確認を残す。

OptionalArrayの1D所有型名と次元名体系は、現行名で作成した0.5.2コメントドック・ドラフトとは分離する。
`OPT-044`と`OPT-045`を0.6.0の到達範囲判断の前提として合流させ、名称を変更する場合のsource、test、
コメントドック、移行措置は判断後の実行taskとして分ける。

## 新しいrelease方式での起動

開始条件に到達したら、次の順序で起動する。

1. 前versionからの差分と未完了のversion固有要件を確認し、0.6.0へ含める変更と後続へ残す変更を分ける。
2. ユーザーへ、0.6.0の製品上の到達範囲とrelease作業を開始するかを一問で確認する。
3. Yesの場合だけ、現在の`RELEASE_TASK_REGISTRY_TEMPLATE.md`から0.6.0の実行正本を生成する。
4. 汎用templateへ、確定したbranch方式、必要な品質gate、下記の0.6.0固有taskを追加し、通常branchへ
   コミットする。
5. コミット済み正本をGit管理対象外の`_ReleaseTask/ACTIVE.md`へコピーし、以後の状態、証拠、
   次に許可された一操作をactive Registryだけで管理する。
6. 完了または中止時は結果をこの文書と通常Task Registryへ還元し、最後に`ACTIVE.md`を削除する。

rehearsalが必要な場合は`RELEASE_TASK_REGISTRY_REHEARSAL_TEMPLATE.md`をoverlayとして使う。本番taskを
別に複製せず、本番templateから同じtask骨格を生成し、目的、模擬入力、除外、外部操作禁止だけを加える。
rehearsalの判断と証拠は本番へ流用しない。

## 0.6.0固有要件

0.5.xではmain pushとrelease tag pushの双方がGitHub Pagesをdeployし、完了順で表示内容が入れ替わり得る
状態を許容している。0.6.0のactive Registryには、次を独立したversion固有taskとして追加する。

- main由来のGitHub Pages deployを停止する。
- release tag commitから利用者向け文書を生成し、warningをerrorとして検証する。
- 検証した文書だけがPagesを更新することを確認する。
- workflow変更、release結果、残る公開経路を完了記録へ残す。

この要件はrelease開始前に先行実行しない。実装中に新しい製品判断または公開上の選択が見つかった場合は、
その場で推測せずactive Registry内で判断taskへ分ける。

## 権限境界

- branch作成、commit、tag作成は、それぞれ直前にユーザーの明示許可を得る。
- candidate branch push、GitHub merge、tag pushはユーザーが実行する。
- Codexは各報告後に対象commitまたはrefをremoteから確認してから後続へ進む。
- release pageやその他の公開操作を行う場合も、対象を示して別途判断する。
