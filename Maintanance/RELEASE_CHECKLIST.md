# Release checklist

最終更新: 2026-10-09 / Codex

## 目的

release候補の品質、対象commit、履歴操作を分離して確認し、tagやpushの直前に思い込みが一人分だけ
残らないようにする。Codexがrelease全体を統合・受入し、Claudeが最終候補を独立に再確認する。

この文書は汎用手順である。version固有の到達範囲、実行結果、既知事項、commit hashは、
`RELEASE_<VERSION>.md`などの個別正本へ記録する。

2026-10-09、0.5.1実績に基づく本checklistの見直しとrelease rehearsalは、前任conversationの意図と途中経過が
失われ、そのままでは安全な再開が困難なため一旦凍結した。現行本文と設計ドラフトは部分的な参考資料として
当面保存するが、未完の見直しや次releaseへの適用を開始しない。再開時はTask Registryから入り、
`RELEASE_TEMPLATE_BRANCH_DESIGN.md`の「前任conversationの残存資料」を既決事項ではなく参考として扱う。

## 責任境界

- ユーザーは、versionの製品上の到達範囲、公開上の約束、release実行、tag、pushを最終承認する。
- Codexは、候補commitの固定、検証設計、結果の統合、既知事項の分類、Claudeへの確認依頼、
  不一致解消、個別正本とTask Registryの更新を担当する。
- Claudeは、Codexの結論を前提にせず、固定された候補commitと証拠を独立に確認する。修正やtag作成、
  pushは行わず、不一致と未確認事項を報告して停止する。
- Claudeの確認はCodexの受入責任を置き換えない。両者の結論が異なる場合、releaseを止め、Codexが
  根拠を再確認する。

## 0. Release計画

- [ ] versionと製品上の到達範囲をユーザーが確認した。
- [ ] releaseへ含める変更と、後続branch・次version・1.0へ残す変更を分けた。
- [ ] version固有のrelease正本を用意した。
- [ ] 必須CI、追加test、性能gate、documentation gateを決めた。
- [ ] tag、remote push、release page、後続branchへの統合を別操作として扱うことを確認した。
- [ ] release記録をmerge前に完成させるか、tag後の記録を新しい作業branchへ積むか決めた。

## 1. 候補commitの固定

- [ ] release候補のbranch名、commit hash、treeを記録した。
- [ ] worktreeに未コミット変更がない。
- [ ] 意図しないmerge、生成物、local専用fileが含まれていない。
- [ ] 前versionのtagから候補commitまでの差分とcommit一覧を確認した。
- [ ] version表記、Package設定、README、CHANGELOG、利用者向け文書の整合を確認した。
- [ ] 通常版、互換mode、experimental traitなど、release対象外の構成が混入していない。

候補commit固定後に製品差分を変更した場合、以降の検証はすべて新しいcommitを対象にやり直す。

## 2. Codexによる一次検収

個別releaseで必要と決めた構成を実行し、command、環境、結果をversion固有の正本へ記録する。

- [ ] Debug build / testが成功した。
- [ ] Release build / testが成功した。
- [ ] 通常CIに含まれない契約testやDeath Testを確認した。
- [ ] documentationをwarning error扱いで生成できた。
- [ ] Address Sanitizerなど、必須にした追加jobが成功した。
- [ ] 性能gateを設けた場合、固定した基準と候補の比較が成功した。
- [ ] 公開API、再公開面、symbol、Package構成に意図しない差分がない。
- [ ] CIの全必須jobが同じ候補commitに対してgreenである。
- [ ] 未確認事項と既知事項を、release阻害／非阻害／後続判断へ分類した。

性能差を再現できない場合や原因を説明できない場合、単に測定ノイズとして閉じない。toolchain、
最適化、特殊化、inline、symbol配置、benchmark条件を候補に含め、releaseを許可できる証拠が
揃うまで未解決として扱う。

## 3. Claudeによる独立チェック

CodexはClaudeへ、少なくともversion、候補commit、前versionのtag、個別release正本、必須CIのURLまたは
結果、変更禁止を渡す。Claudeは次を独立に確認する。

- [ ] tag予定commitと、全必須CIが検証したcommitが一致する。
- [ ] version、README、CHANGELOG、Package設定、release正本の記述が一致する。
- [ ] release対象外の通常版／互換mode／trait／後続作業が混入していない。
- [ ] test、documentation、性能などの必須gateに未実施や赤が残っていない。
- [ ] 既知事項を解消済みと誤記しておらず、後続taskを暗黙に完了扱いしていない。
- [ ] worktree、branch、tag予定位置、push予定refが明示されている。
- [ ] tag後の記録commitや後続branch統合が、tag対象commitへ誤って混入していない。

Claudeの報告形式:

1. 対象commitと確認した証拠。
2. `PASS`、`BLOCK`、`UNVERIFIED`の項目別結果。
3. Codexの一次検収との不一致。
4. releaseを止める事項。

Claudeは修正せず、報告後に停止する。Codexは報告を原資料と照合し、`BLOCK`と`UNVERIFIED`を
解消する。修正が入った場合は候補commitを固定し直し、必要な一次検収と独立チェックを再実施する。

## 4. ユーザーへの最終確認

Codexは次を短く提示する。

- versionとtag予定commit。
- 製品上の到達範囲。
- Codexの一次検収結果。
- Claudeの独立チェック結果と、解消済みの不一致。
- release後へ残す既知事項。
- 次に行う操作を一つだけ。

tag作成、tagのremote push、release page作成、配布、後続branchへのmergeは、それぞれ自動的に
承認済みと扱わない。不可逆または外部へ影響する操作の直前に、対象を明示してユーザーへ確認する。

## 5. Tag作成

- [ ] tag名、対象commit、annotated tag messageを再確認した。
- [ ] tag対象が、CodexとClaudeの確認後に変更されていない。
- [ ] local tagを作成した。
- [ ] tagが意図したcommitを指すことを読み戻した。
- [ ] version固有の正本へtag名、commit、作成結果を記録した。

tag後の記録変更は、原則として新しい作業branchへcommitする。local `main`へ直接積まない。

## 6. 外部反映

- [ ] pushするbranchまたはtagの正確なrefをユーザーへ提示した。
- [ ] ユーザーがそのpushを明示的に承認した。
- [ ] remote上のtagとcommitを読み戻した。
- [ ] release pageや配布物を作る場合、tagと内容の一致を確認した。
- [ ] 後続branchへ統合する場合、統合先と対象commitを別途確認した。
- [ ] Task Registryとversion固有の正本を最終状態へ更新した。

## Hard stops

次の場合はreleaseを進めない。

- 候補commitを一意に示せない。
- 必須CIが別commitを検証している、未完了、または赤である。
- CodexとClaudeの結果に未解消の不一致がある。
- release対象と後続作業の境界が曖昧である。
- 未コミット変更や無関係な差分が混在している。
- tag、push、mergeの対象またはユーザー承認が曖昧である。
