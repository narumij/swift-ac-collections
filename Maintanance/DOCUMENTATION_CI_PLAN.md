# Documentation CI Verification Plan

## 役割

この文書は、公開library targetのDocC継続検証範囲と段階導入方針の正本である。
GitHub Pagesの公開元、利用者向け文書の完成条件、およびwarningをerrorとして扱う品質判断は変更しない。

## 取得した証拠

2026-10-13、Xcode上のWorker Codexが次の5 targetをmacOSで個別に生成した。

- `AcCollections`
- `RedBlackTreeModule`
- `PermutationModule`
- `OptionalArrayModule`
- `BareArrayModule`

各targetは、固有のoutput directoryとlogを用いた`swift package --disable-sandbox
generate-documentation`でexit 0となった。各logのwarning 8件は、user-level SwiftPM cacheがread-onlyである
実行環境に由来し、DocCのdocumentation diagnosticはerror 0件だった。Prime Codexが5 log、5 output directory、
終了文、および診断件数を再確認した。

最初の`AcCollections`実行は`--disable-sandbox`なしでnested sandboxによりmanifest評価前に失敗した。
これはdocumentation failureではなく、現行Xcode実行環境の制約として分離する。

この証拠は、現在のmacOS workspaceで5 targetを個別生成できることを示す。Ubuntu CIでのDocC安定性、
rendered contentの完全性、利用者による理解、および将来のwarning 0件は証明しない。

## 継続検証範囲

PR CIで継続生成する対象は、上記5 targetすべてとする。targetごとにcommand、output、log、終了statusを分離し、
一つのtargetの結果で他targetの成否を推定しない。

既存の`RedBlackTreeCollections` documentation jobとGitHub Pages公開は、利用者向け公開物を生成する別責務である。
この計画によって公開target、hosting base path、Pages更新元、またはrelease時の公開判断を変更しない。

## 公開構成

公開moduleのAPI referenceは、Swift Package Indexが生成するtarget別DocCを正本の公開先とする。
GitHub Pages上でexperimental combined documentationを用いて複数targetを一つのDocC archiveへ束ねる方式は
採用しない。

GitHub Pagesは既存の利用者向け文書とpackageの入口を担い、READMEまたはPagesからSwift Package Index上の
各moduleへ導線を置く。API referenceの生成・hostingと、repositoryが編集する利用者向け説明を分離する。

2026-10-13時点で、`https://github.com/narumij/swift-ac-collections.git`はSwift Package Indexのcanonical
`packages.json`に見つからず、package pageとmodule別documentation URLも確認できなかった。登録は1.0 release後の
中間ゴールとし、それまではrepository CIで各targetのDocC生成可能性を維持する。

1.0 release後、Swift Package Indexへのpackage登録とDocC build成立を確認する。登録後にpackage pageの
`Do you maintain this package?`から提供されるMarkdownを正として互換性badgeをREADMEへ追加し、READMEまたは
Pagesからmodule別API referenceへの導線を接続する。badge URLやdocumentation URLを登録前に推測して固定しない。

## 段階導入

1. PR CIに5 targetの個別生成とdiagnostic artifact採取を追加する。生成commandの非zero終了はtargetごとのfailureとして
   観測するが、初期段階では`--warnings-as-errors`を付けない。
2. Ubuntu runner上でtoolchain crashとrepository由来diagnosticを区別し、5 targetの再現可能な結果を得る。
3. 安定したtargetからrequiredな継続生成へ移す。順序は実測上の安定性で決め、moduleの重要度や文書完成度を
   推測して先取りしない。
4. `--warnings-as-errors`の採用は、各targetの利用者向け文書がその品質gateを受け入れられる段階で別途判断する。

この順序は、生成不能を見逃さず、未完成文書のwarningを新しい公開品質判断なしにCI failureへ変えないためのものとする。

## 後続境界

2026-10-13、PR限定の`public-target-documentation` matrix jobを`.github/workflows/ci.yml`へ実装した。
5 targetは個別entryとなり、`fail-fast: false`、job単位の`continue-on-error: true`、target別output・diagnostic・
artifact、および`if: always()`のartifact uploadを持つ。DocC commandはpipelineの実statusを記録して同じstatusで
終了するため、job全体を非blockingにしてもtarget failure自体を隠さない。

Prime CodexはYAML parse、matrix 5件、non-blocking設定、target別path、artifact upload、終了status伝播、
`--warnings-as-errors`不使用、および既存`documentation` jobが無変更であることをlocalで再検証した。

remote Ubuntu上のjob実行、artifact upload、およびtoolchain安定性は、このlocal受入から推定しない。
実装commitのuser push後に別の受入境界で確認する。
