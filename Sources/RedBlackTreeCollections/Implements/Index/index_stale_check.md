
|  | (A) CROSS=OFF / LAZY=OFF / 同じ木 | (B) CROSS=OFF / LAZY=OFF / 別の木 | (C) CROSS=OFF / LAZY=ON / 同じ木 | (D) CROSS=OFF / LAZY=ON / 別の木 | (E) CROSS=ON / LAZY=OFF / 同じ木 | (F) CROSS=ON / LAZY=OFF / 別の木 | (G) CROSS=ON / LAZY=ON / 同じ木 | (H) CROSS=ON / LAZY=ON / 別の木 |
|---|---|---|---|---|---|---|---|---|
| **(1) 健全** | o | x | o | x | o | o | o | o |
| **(2) 世代違い** | x | x | x | x | x | x | x | x |
| **(3) デタッチ済み** | - | x | - | x | - | o | - | o |
| **(4) デタッチ済み + 世代違い** | - | x | - | x | - | x | - | x |

表は現状を反映している

CoWは別の木という判定になる

LAZY=ONはdeprecated

現在の標準構成はCROSS=ON / LAZY=OFFである

- CROSS=ONは、CoWで分岐したコレクション間のIndex利用を保証するために用いる。
- 無関係なコレクションから取得したIndexの使用は事前条件違反とし、その検出は保証しない。
- 表の「別の木」で利用可能となっていても、無関係なコレクションでの動作を保証するものではない。
