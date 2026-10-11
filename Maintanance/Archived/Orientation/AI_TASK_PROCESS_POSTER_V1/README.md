# AI task process poster V1

2026-10-09時点の実験版posterを、SVGとPNGの組で保存する。

- `AI_TASK_PROCESS_POSTER.svg`: 編集可能な生成結果
- `AI_TASK_PROCESS_POSTER.png`: 2400 × 2400のpreview
- `Utilities/Maintenance/Archived/GenerateAITaskProcessPosterV1.py`: V1生成script

V1はtaskの状態、分解、依存、割り当て、および責任境界を中心にした。V2では実運用で得た
「変更によってどの品質主張と証拠が失効したか」を中心へ移し、個別の状態一覧とCI閾値をposterから外した。
