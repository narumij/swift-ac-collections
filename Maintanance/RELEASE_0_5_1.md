# Release 0.5.1

最終更新: 2026-10-09 / Codex

## 状態

製品上の到達範囲を確定し、release checklistによる候補準備中。現時点ではrelease候補commitとtag位置を
固定せず、tag・pushを行わない。

## Release検討開始条件

次の三対象でTest as Specification整理が完了していることを、0.5.1のrelease検討を始める条件とする。

- Permutation: 完了済み
- OptionalArray: 完了済み
- BareArray: 完了済み

これはrelease完了条件ではない。条件到達後、ユーザーが0.5.1へ含める製品上の到達範囲と、release
checklistへ進むかを一つの判断として確定する。

## 条件到達後の流れ

1. 前versionからの差分を確認し、0.5.1へ含める変更と後続へ残す変更を分ける。
2. ユーザーが製品上の到達範囲とrelease検討開始を判断する。
3. 採用時だけ[`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md)に従い、候補commit、必須CI、文書、性能、
   独立チェックを設計する。
4. tag作成、push、release page、後続branch統合は、それぞれ対象を示して別途承認を得る。

この文書とtaskの登録は、release、tag、pushを許可しない。

## 2026-10-09 到達範囲の判断材料

`0.5.0..HEAD`の製品コード差分はBareArrayが中心である。公開名と型構成は維持し、次を確定・実装した。

- 公開initializerへ、各次元が非負、zero許可、次元積が`Int`で表現可能という事前条件を追加。
- 所有2D〜4DとView 2D〜3Dの連鎖writebackを、同一pointer・shapeだけ許す検査付きsetterへ変更。
- 非対称寸法、境界、writeback、不正寸法、参照寿命を含むBareArrayの番号付きTest as Specificationを完成。
- Permutation、OptionalArray、BareArrayの三対象でTest as Specificationが揃った。
- BareArray品質評価初版は文書作業への入力であり、コメントドック全件整備、利用者向け文書初版、性能基準、
  View寿命、strict memory safetyの1.0判断は後続releaseへ残る。

Codex推奨の0.5.1到達範囲は「BareArrayの既存公開契約を堅牢化し、三対象のTest as Specificationをrelease
根拠として揃えたmaintenance release」とする。新しい公開機能、公開名変更、ユーザードキュメント初版、
1.0品質判断は含めない。

ユーザーがこの範囲を採用した場合だけ、release検討を開始し、`RELEASE_CHECKLIST.md`に従って候補commitと
必須gateを具体化する。

### User decision

2026-10-09、上記のCodex推奨範囲を0.5.1として採用し、release checklistへ進むと決定した。

## Release計画

- 到達範囲: BareArrayの既存公開契約の堅牢化と、Permutation・OptionalArray・BareArrayのTest as
  Specification整備。新しい公開機能、名称変更、文書初版、1.0品質判断は含めない。
- 必須local gate: Debug／Releaseの通常test、Death Test、documentation warning-as-error、公開API・再公開面・
  Package構成の差分確認。
- 必須remote gate: 通常test、Linux、documentation、Address Sanitizer、performanceを含むworkflowの全必須job。
  performanceは製品性能変更を主張するためではなく、候補commit全体のrelease gateとして扱う。
- 独立チェック: local・remote gateが同一候補commitで揃った後、Claudeが変更せずに最終候補を確認する。
- 記録境界: release記録を候補commitへ含めてから固定する。tag後の記録は新しい作業branchへ積む。
- 操作境界: tag作成、tag push、release page、後続branch統合は別々にユーザー承認を得る。

## Checklist進捗

### 0. Release計画

- [x] version `0.5.1`と製品上の到達範囲をユーザーが確認した。
- [x] releaseへ含める変更と、文書作業・1.0判断へ残す変更を分けた。
- [x] 本書をversion固有のrelease正本とした。
- [x] 必須local／remote gateとClaude独立チェックを定めた。
- [x] tag、push、release page、後続branch統合を別操作と確認した。
- [x] release記録を候補commitへ含め、tag後の記録は新しい作業branchへ積むと決定した。

### 1. 候補commit固定前

- [x] `0.5.0..HEAD`のcommit一覧と差分を確認した。
- [x] READMEにversion固定表記がなく、Package manifestにもrelease version設定がないことを確認した。
- [x] CHANGELOGの`Unreleased`へ0.5.1固有のTest as Specification整理とBareArray修正を追記した。
- [x] release計画とCHANGELOGをcommitし、`7d1a9a79`を暫定候補に固定した。
- [ ] 意図しないmerge、生成物、local専用file、release対象外構成の混入がないことを最終確認する。

### 候補固定後の再固定記録

`7d1a9a79`のDebug検証で、OptionalArrayの品質評価文書がSwiftPMの未処理ファイル警告として残ることを
検出した。BareArray targetでは同種の警告を除外済みであり、OptionalArray targetにも`Documentation`の
excludeを追加する。この修正により暫定候補を解除し、commit後に候補commitとlocal gateを固定し直す。

### 2. Codex一次検収

検証候補`7884ecb4`（repository tree `227801b5699f51c6a8c5a3d3687c3240b067bdc6`）で実施した。

- [x] Debug package全test成功。BareArray通常35件、Death Test 42件を含む。
- [x] Release package全test成功。BareArray通常28件、Death Test 42件を含む。
- [x] CIと同じRedBlackTreeCollections documentation commandを`--warnings-as-errors`付きで実行し成功。
- [x] OptionalArray／BareArrayの品質評価文書をtargetからexcludeし、SwiftPM未処理file警告を解消。
- [ ] 公開API・再公開面・Package構成の意図しない差分を最終確認する。
- [ ] remote CIの全必須jobを同一候補commitでgreenにする。
- [ ] Claudeの独立チェックを実施する。

既知の非阻害候補として、Permutation sourceの未使用result警告と既存testの`var`等の警告が残る。今回の
製品差分で導入した警告ではなく、testは成功している。documentation gateのwarning-as-errorには影響しない。
release阻害／後続扱いの最終分類は公開差分確認とClaude独立チェック後に確定する。

本節を加えるcommitはrelease記録だけを変更する。commit後のHEADをremote CIと独立チェックの最終候補とし、
`7884ecb4..HEAD`でsource、test、Package、workflow、利用者向け文書に差分がないことを確認する。

### 独立チェック1回目

Claudeは候補`4d5ce7b8`について、CHANGELOGで0.5.0と0.5.1の項目が同じ`Unreleased`節へ混在し、0.5.1の
変更を版単位で識別できない点を`BLOCK`とした。CIのhead SHAを直接確認できなかった2項目は`UNVERIFIED`、
その他は`PASS`だった。このBLOCKを受け入れ、`Unreleased`を空にし、`0.5.1`の3項目と従来の`0.5.0`項目を
別の版見出しへ分離する。修正後のcommitを新候補とし、remote CIと独立チェックを再実施する。
