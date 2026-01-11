/*
 (以前までのものはバグっていて速かった模様）
 
 UNSAFE_TREE＿V2
 2026-01-10 20:15:53 +0000

 not both, maybe pool v1

 running insert already presents 0... done! (189.87 ms)
 running insert already presents 32... done! (208.05 ms)
 running insert already presents 1024... done! (229.37 ms)
 running insert already presents 8192... done! (258.20 ms)
 running insert new 0... done! (309.32 ms)
 running insert new 32... done! (315.65 ms)
 running insert new 1024... done! (319.82 ms)
 running insert new 8192... done! (317.09 ms)
 running insert 0... done! (187.93 ms)
 running insert 32... done! (1211.07 ms)
 running insert 1024... done! (1678.31 ms)
 running insert 8192... done! (1661.17 ms)
 running insert 100000... done! (1761.64 ms)
 running insert 1000000... done! (2251.48 ms)
 running insert shuffled 0... done! (187.19 ms)
 running insert shuffled 32... done! (1070.85 ms)
 running insert shuffled 1024... done! (1548.72 ms)
 running insert shuffled 8192... done! (2092.66 ms)
 running insert shuffled 100000... done! (1521.14 ms)
 running insert shuffled 1000000... done! (1628.34 ms)
 running remove 1000... done! (1638.78 ms)
 running remove 1000000... done! (1642.56 ms)
 running randomElement 0... done! (169.52 ms)
 running randomElement 32... done! (215.98 ms)
 running randomElement 1024... done! (216.03 ms)
 running randomElement 8192... done! (216.56 ms)
 running sequencial element 32... done! (175.89 ms)
 running sequencial element 1024... done! (176.89 ms)
 running sequencial element 8192... done! (176.37 ms)
 running lower bound 32... done! (174.85 ms)
 running lower bound 1024... done! (175.22 ms)
 running lower bound 8192... done! (175.47 ms)
 running upper bound 32... done! (175.42 ms)
 running upper bound 1024... done! (176.01 ms)
 running upper bound 8192... done! (175.48 ms)
 running first index 32... done! (175.47 ms)
 running first index 1024... done! (176.12 ms)
 running first index 8192... done! (176.40 ms)

 name                         time             std        iterations
 -------------------------------------------------------------------
 insert already presents 0          166.000 ns ±  38.70 %    1000000
 insert already presents 32         167.000 ns ±  36.63 %    1000000
 insert already presents 1024       167.000 ns ±  35.69 %    1000000
 insert already presents 8192       208.000 ns ±  22.27 %    1000000
 insert new 0                       250.000 ns ±  24.75 %    1000000
 insert new 32                      250.000 ns ±  17.88 %    1000000
 insert new 1024                    250.000 ns ±  12.05 %    1000000
 insert new 8192                    250.000 ns ±  29.20 %    1000000
 insert 0                           166.000 ns ±  19.62 %    1000000
 insert 32                         1083.000 ns ±   5.21 %    1000000
 insert 1024                      25083.000 ns ±   1.75 %      55796
 insert 8192                     223125.000 ns ±   0.96 %       6336
 insert 100000                  3305250.000 ns ±   0.62 %        421
 insert 1000000                78690875.000 ns ±   0.48 %         17
 insert shuffled 0                  166.000 ns ±  21.37 %    1000000
 insert shuffled 32                 958.000 ns ±  13.93 %    1000000
 insert shuffled 1024             26792.000 ns ±   3.10 %      44045
 insert shuffled 8192            622250.000 ns ±   1.16 %       2254
 insert shuffled 100000        12631875.000 ns ±   0.46 %        109
 insert shuffled 1000000      263673167.000 ns ±   0.68 %          5
 remove 1000                       2000.000 ns ±  16.15 %     688390
 remove 1000000                 1881750.000 ns ±   1.05 %        741
 randomElement 0                    125.000 ns ±  48.47 %    1000000
 randomElement 32                   167.000 ns ±  43.93 %    1000000
 randomElement 1024                 167.000 ns ±  44.32 %    1000000
 randomElement 8192                 167.000 ns ±  47.43 %    1000000
 sequencial element 32              125.000 ns ±  53.26 %    1000000
 sequencial element 1024            125.000 ns ±  85.16 %    1000000
 sequencial element 8192            125.000 ns ±  60.08 %    1000000
 lower bound 32                     125.000 ns ±  45.14 %    1000000
 lower bound 1024                   125.000 ns ±  46.14 %    1000000
 lower bound 8192                   125.000 ns ±  59.70 %    1000000
 upper bound 32                     125.000 ns ±  67.00 %    1000000
 upper bound 1024                   125.000 ns ± 101.15 %    1000000
 upper bound 8192                   125.000 ns ±  95.61 %    1000000
 first index 32                     125.000 ns ±  53.92 %    1000000
 first index 1024                   125.000 ns ±  78.97 %    1000000
 first index 8192                   125.000 ns ±  86.72 %    1000000
 Program ended with exit code: 0
 
 */
