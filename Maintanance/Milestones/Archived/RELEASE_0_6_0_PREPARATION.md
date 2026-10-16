# 0.6.0変更範囲案と品質確認入力

2026-10-16 / Astra / RELEASE-081。ユーザーの継続指示とClaudeへの割当許可に基づく、リリース開始判断前の材料整理。候補採用・試験起動・release開始は行わない。

## 固定範囲と到達点

比較元はローカルtag 0.5.3（139ffef8）、比較先は8a0c8769。比較先は今回の調査基点であり、リリース候補としての採用ではない。並行作業の未コミット差分、特にRBT-048-death-probeやキャッシュ整備は対象外。

Astraが変更範囲案を整理し、Claudeが既存品質証拠の適用範囲と追加確認候補を返す。Astraが検収して、再利用可・差分確認が必要・判断待ちを区別した一つの材料にまとめたら調査完了。製品上の到達範囲と開始のユーザー判断はRELEASE_0_6_0へ返す。

## 変更範囲案（未採用）

- 公開文書：赤黒木4型の本文・コメント、4モジュールのDocC入口、README導線。DOC-034・035の結果を利用する。
- 導入条件：Package.swiftはSwift 6.2から6.4へ変更。現行の名称・公開入口はRELEASE-078の照合表を利用する。
- ElementBuffer系：BareArray/OptionalArrayからの名称・target移行、旧入口の整理、MutableRefアクセス、OptionalElementBufferのtrait opt-in。単なる文書改訂とは分けて変更履歴に示す。
- Permutation：NextPermutationModuleへの移行、旧PermutationModuleの互換再公開、一時Viewと借用iteratorの現行契約。旧版からの移行注意を確認する。
- 赤黒木：実装差分とTest as Spec補完を品質証拠へ照合する。DOC-035の文書検証を実装全体の品質保証に転用しない。
- CI・管理資料の変更は製品機能と区別する。リリース用整理は開始判断後の別工程で扱う。

根拠：0.5.3..8a0c8769のPackage.swift、公開入口、Sourcesの履歴。Sources / Tests / Package.swift / .githubの比較は147 files changed（8612 additions、9437 deletions）。移動・名称変更を含むため、この件数をリスクの大きさと同一視しない。個別変更の全リリースノートは未作成。

## 現在不足する材料

- CHANGELOGは0.5.3まで。上記を基に0.6.0の変更候補を作れるが、範囲採用前にリリース済み表記を追加しない。
- 8a0c8769に対する直近CIの全成功は未確認。以前の成功を代用しない。
- 候補コメントCIの正本には過去のperformance/report失敗記録がある。現行Registryとの対応と新しい成功証拠を照合する必要があり、旧FROZEN記載だけでtaskを復活・実行しない。
- 全体試験・trait組合せ・互換経路・差分の品質確認はClaudeの棚卸しを受けて必要範囲を確定する。1.0の全面評価は持ち込まない。

## 分担・引渡し

Claudeの返却先はRELEASE_0_6_0_QUALITY_EVIDENCE_RETURN.md。本書と固定入力を渡した後は、返却まで変更しない。Astra側の追加整理は返却後の検収に合流させる。共有ビルド領域・製品・テストをこの依頼で書き換えず、並行中のユーザー直接依頼を妨げない。

## Astra受入・統合（2026-10-16）

Claudeの[返却原文](RELEASE_0_6_0_QUALITY_EVIDENCE_RETURN.md)を保持し、読み取り調査として受け入れた。固定入力3件のhash、保存済みPR #196の受入記録、4cd0ebc2..8a0c8769のSources・Package.swift差分を独立照合した。コメント等を除くSwift実装差分は赤黒木4型の範囲erase、manifest差分は移動済みFixturesのexclude削除。今回テスト・CIは実行しておらず、GitHubの最新状態も取得していない。

### 返却への補正

- Swift 6.2の供用説明は未決ではない。現行ElementBufferModule.docc/ElementBufferModule.mdは、package導入はSwift 6.4、6.2での競技利用はbufferソース利用と明記済み。説明の再判断をユーザーへ戻さない。6.2での今回の対象ソースの実行証拠が未確認である点は別に残す。
- ElementBuffer座標アクセスの不足は旧Assessmentからそのまま引き継がない。Tests/ElementBufferModuleTests/BareArray_7_BorrowedReferenceTests.swiftには1〜4次元の全座標・非対称形状・対象要素だけの更新の検査がある。Archived/Reviews/ELEMENTBUFFER_TEST_AS_SPEC_REVIEW.mdには追加と受入記録がある。全座標APIの完全性を今回保証するものではないが、旧「未検証」4行を新たな必須課題へ転用しない。
- ASan＋Death Testは「成立した証拠がない」ではない。[調査正本](../../Current/ASAN_DEATH_TEST_INVESTIGATION.md)にはmacOS Swift 6.4の最小構成3件成功とASan検出の証拠がある。製品全体・Linuxでの成立は未確認で、今回の0.6.0必須条件へ自動昇格させない。
- 既定Linux CIは差分確認の提案経路であり「唯一の手段」ではない。保存された最後の全体CI証拠と、現在のGitHubの最新成功を区別する。

### 統合した開始判断材料

| 区分 | 適用範囲・次に確認すること |
| --- | --- |
| 再利用 | PR #196 head 4cd0ebc2の保存記録は、その版・既定構成の証拠。以後実装不変の3モジュールに利用可能。DOC-035の文書・例検証も、その対象版と範囲で利用する。 |
| 差分確認案 | 採用する候補SHAで既定Linux CIを実行し、範囲erase修正後のdebug/release/ASanと文書を確認する。候補コメントCIのperformance/reportも、新しい実行結果で確認する。過去の未確認から不合格とは断定しない。 |
| 構成別確認案 | 互換構成のbuild/test、Optional trait有効のfacade経路を確認対象案とする。通常CIの成功だけでこれらを通過扱いにしない。Linux death testは保存証拠の不足として残し、必要範囲は開始時の試験計画で確定する。 |
| 留保 | 候補SHA・リリース開始・試験範囲の承認は別。RBT-048、凍結中の並行初期化、後続マイルストーンの全面品質評価は持ち込まない。 |

変更範囲案と既存証拠の適用範囲の整理は完了。RELEASE-081はユーザーのcommit承認によりDONE。リリース合格・開始承認は意味しない。
