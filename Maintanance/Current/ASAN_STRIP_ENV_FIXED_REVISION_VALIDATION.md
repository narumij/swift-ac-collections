# ASan strip_envの固定版検証案

RBT-049 / 作成Astra / 2026-10-16 / PROPOSED。追加実行は未依頼。

入力はASAN_DEATH_TEST_INVESTIGATION.mdの追加受入とCP-20261016-014の原報告・ログ。
次の品質検証で対象commitとSwift版・OS・環境変数・traitを固定し、隔離環境で既定条件とstrip_env=0を比較する。最小Probeの検出器負例、DeathTests、RedBlackTreeInternalCoverageTestsの順に検証範囲を明示し、完全ログと終了statusを保存する。全体suiteは所要時間・対象を決めてから扱う。

製品・Tests・CIは変更しない。Linuxへの効果は別環境で確認するまで主張しない。compiler-rtのstrip_env実装も原因説明を確定する際に照合する。完了は固定版で成立・不成立・未検証が区別された調査結果の受入。CI適用は後続判断。0.6.0の新しい必須ゲートにはしない。
