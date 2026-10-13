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

## 段階導入

1. PR CIに5 targetの個別生成とdiagnostic artifact採取を追加する。生成commandの非zero終了はtargetごとのfailureとして
   観測するが、初期段階では`--warnings-as-errors`を付けない。
2. Ubuntu runner上でtoolchain crashとrepository由来diagnosticを区別し、5 targetの再現可能な結果を得る。
3. 安定したtargetからrequiredな継続生成へ移す。順序は実測上の安定性で決め、moduleの重要度や文書完成度を
   推測して先取りしない。
4. `--warnings-as-errors`の採用は、各targetの利用者向け文書がその品質gateを受け入れられる段階で別途判断する。

この順序は、生成不能を見逃さず、未完成文書のwarningを新しい公開品質判断なしにCI failureへ変えないためのものとする。

## 後続境界

このDiscoveryではworkflowを変更しない。CI実装は、Ubuntu上の証拠保存、target別failure、artifact名、既存の
`RedBlackTreeCollections` jobとの重複を明示した別の`EXECUTION`として扱う。
