# ワーカー1：Permutation移行調査 — 構成・互換入口

固定ID：`PERM-073`。種別：DISCOVERY。担当：Worker Codex 1。作成者：Astra。

## 今回の前提と境界

2026-10-15、ユーザーが立案フェーズ完了と調査への移行を承認した。
到達像は、新名`NextPermutationModule`を主入口とし、mainに旧名`PermutationModule`の互換入口を維持すること。
同じ型・実装・契約を利用でき、過去baselineとの性能比較も継続する。旧名とCI互換の削除は完了条件にしない。
具体的な実現方式・工程・merge単位は未決であり、調査後にユーザーと計画する。

現在の名称決定は`Maintanance/Current/PUBLIC_API_NAMING_DECISIONS.md`を参照する。
過去文書の「互換を残すか未決」は今回の存続方針より古い。具体的方法が未決であることとは区別する。
CIの順序は`Maintanance/Current/PERFORMANCE_CI_CHANGE_GUIDE.md`に従い、名前互換の先行mergeとgreen確認後にrenameする。
baselineへcurrentのsourceを移植しない。各段階のgreenが次段階の前提。調査ではCIを実行・変更しない。

## 許可範囲・停止条件

担当範囲の読み取り調査と、自分専用の返却ファイルへの記入だけを行う。
開始時にHEAD・branch・関係ファイルの未コミット差分を確認し、観測対象を明記する。
他ワーカーの回答を前提にせず独立に調べる。共有ファイルは編集しない。
source、test、manifest、workflow、Registry、依頼書、他者返却物を変更せず、commit・push・branch作成・CI起動を行わない。
build・benchmarkや試作は今回含めない。静的確認で分からないことは、次に必要な最小の検証として返す。
凍結taskは再開しない。権限・仕様の判断が必要な箇所は未確定として分離し、独立に調べられる範囲は続ける。
作業中に関係ファイルが変わったら、その影響を確認して対象版の混在を避ける。

## 受入条件

- 実在するパス・行・定義に基づく対応表。検索ヒットを無差別に列挙せず、移行に関わるものへ絞る。
- 現行事実、推論、選択肢、未確認を区別する。リンク先の実在を確認する。
- 変更が必要なもの、維持するもの、履歴だけのものを分ける。
- 工程の制約、他担当との接点、計画時に決める点、追加検証が必要な点を示す。
- 調査した範囲と調査していない範囲を残す。方式決定・実装完了・CI greenを推定しない。

返却後の独立照合と統合はAstraが担当する。依頼本文は受渡し後に固定し、ワーカーは返却先だけを編集する。

## 担当調査

target／product／moduleの対応、依存・import・再公開の経路、新旧入口を同じ型・実装へつなぐ際の制約を調べる。互換入口の実現方法は選択肢と要確認点として示し、方式は決定しない。

読む起点：Package.swift、Sources/AcCollections、Sources/PermutationModule、関係する公開surface test・compiler fixture。そこから明示参照を必要な範囲だけ辿る。

## 専用返却先

`Maintanance/Current/PERMUTATION_MIGRATION_WORKER_1_RESULT.md`の「調査結果」以下だけを編集する。ファイルの追加作成や共通依頼書への転記は不要。
