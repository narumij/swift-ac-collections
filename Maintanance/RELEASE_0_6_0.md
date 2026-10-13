# Release 0.6.0

最終更新: 2026-10-10 / Codex

## 現在の状態

release検討開始条件待ち。これはactive release Registryではなく、0.6.0を開始できる状態とversion固有の
要件だけを保持する入口である。現時点ではrelease候補commit、製品上の到達範囲、branch方式、必須gate、
tag位置を確定しない。

`_ReleaseTask/`へ人間向け工程表をコピーする前の段階では、release、branch作成、commit、tag、push、公開を
許可しない。

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

OptionalArrayの1D所有型名は、後発の横断命名判断でunsuffixedの
`OptionalElementBuffer`に確定し、実装反映も完了した。旧`OPT-044`はその判断へ吸収し、
0.6.0の未解決依存にしない。次元名体系の`OPT-045`は、0.6.0の到達範囲判断前の前提として残す。

## Release作業の起動

開始条件に到達したら、次の順序で起動する。

1. 前versionからの差分と未完了のversion固有要件を確認し、0.6.0へ含める変更と後続へ残す変更を分ける。
2. ユーザーへ、0.6.0の製品上の到達範囲とrelease作業を開始するかを一問で確認する。
3. Yesの場合だけ、`User/RELEASE_PROCESS.md`を`_ReleaseTask/`へコピーし、versionを実値へ置き換える。
4. 確定したbranch方式、必要な品質gate、下記の0.6.0固有taskを人間向け工程表と通常Task Registryへ反映する。
5. release中の状態と証拠は人間向け工程表と各工程の正本へ記録し、完了または中止時にこの文書と通常Task Registryへ還元する。

2026-10-13、旧release checklist、release専用Task Registry方式、およびrehearsal templateは採用せず
Archivedへ移した。人間向け工程の正本は`User/RELEASE_PROCESS.md`とする。

## 0.6.0固有要件

0.5.xではmain pushとrelease tag pushの双方がGitHub Pagesをdeployし、完了順で表示内容が入れ替わり得る
状態を許容している。0.6.0の通常Task Registryには、次を独立したversion固有taskとして追加する。

- main由来のGitHub Pages deployを停止する。
- release tag commitから利用者向け文書を生成し、warningをerrorとして検証する。
- 検証した文書だけがPagesを更新することを確認する。
- workflow変更、release結果、残る公開経路を完了記録へ残す。

この要件はrelease開始前に先行実行しない。実装中に新しい製品判断または公開上の選択が見つかった場合は、
その場で推測せず通常Task Registry内で判断taskへ分ける。

## 権限境界

- branch作成、commit、tag作成は、それぞれ直前にユーザーの明示許可を得る。
- candidate branch push、GitHub merge、tag pushはユーザーが実行する。
- Codexは各報告後に対象commitまたはrefをremoteから確認してから後続へ進む。
- release pageやその他の公開操作を行う場合も、対象を示して別途判断する。
