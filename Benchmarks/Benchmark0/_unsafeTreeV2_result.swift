/*
 (以前までのものはバグっていて速かった模様）
 
 UNSAFE_TREE＿V2
 2026-01-10 15:34:14 +0000

 not both, maybe pool v1

 running insert already presents 0... done! (191.28 ms)
 running insert already presents 32... done! (213.10 ms)
 running insert already presents 1024... done! (231.59 ms)
 running insert already presents 8192... done! (258.73 ms)
 running insert new 0... done! (307.92 ms)
 running insert new 32... done! (318.07 ms)
 running insert new 1024... done! (318.65 ms)
 running insert new 8192... done! (318.76 ms)
 running insert 0... done! (189.81 ms)
 running insert 32... done! (1214.51 ms)
 running insert 1024... done! (1663.47 ms)
 running insert 8192... done! (1645.51 ms)
 running insert 100000... done! (1787.82 ms)
 running insert 1000000... done! (2367.89 ms)
 running insert shuffled 0... done! (187.69 ms)
 running insert shuffled 32... done! (1084.51 ms)
 running insert shuffled 1024... done! (1497.61 ms)
 running insert shuffled 8192... done! (2087.55 ms)
 running insert shuffled 100000... done! (1553.18 ms)
 running insert shuffled 1000000... done! (1419.31 ms)
 running remove 1000... done! (1670.89 ms)
 running remove 1000000... done! (1645.31 ms)
 running randomElement 0... done! (168.72 ms)
 running randomElement 32... done! (215.98 ms)
 running randomElement 1024... done! (215.66 ms)
 running randomElement 8192... done! (215.46 ms)
 running sequencial element 32... done! (175.35 ms)
 running sequencial element 1024... done! (176.00 ms)
 running sequencial element 8192... done! (176.15 ms)
 running lower bound 32... done! (175.02 ms)
 running lower bound 1024... done! (175.03 ms)
 running lower bound 8192... done! (175.08 ms)
 running upper bound 32... done! (175.47 ms)
 running upper bound 1024... done! (174.83 ms)
 running upper bound 8192... done! (175.74 ms)
 running first index 32... done! (175.23 ms)
 running first index 1024... done! (175.10 ms)
 running first index 8192... done! (175.36 ms)

 name                         time             std        iterations
 -------------------------------------------------------------------
 insert already presents 0          166.000 ns ±  84.66 %    1000000
 insert already presents 32         167.000 ns ± 129.12 %    1000000
 insert already presents 1024       167.000 ns ±  85.09 %    1000000
 insert already presents 8192       208.000 ns ±  78.36 %    1000000
 insert new 0                       250.000 ns ±  71.73 %    1000000
 insert new 32                      250.000 ns ±  67.22 %    1000000
 insert new 1024                    250.000 ns ±  76.17 %    1000000
 insert new 8192                    250.000 ns ±  76.38 %    1000000
 insert 0                           166.000 ns ±  83.70 %    1000000
 insert 32                         1083.000 ns ±  31.78 %    1000000
 insert 1024                      24584.000 ns ±   6.59 %      55952
 insert 8192                     223500.000 ns ±   3.15 %       6215
 insert 100000                  3428125.000 ns ±   2.74 %        414
 insert 1000000                84181917.000 ns ±   0.45 %         17
 insert shuffled 0                  166.000 ns ±  70.02 %    1000000
 insert shuffled 32                 958.000 ns ±  23.53 %    1000000
 insert shuffled 1024             26333.000 ns ±  12.43 %      40088
 insert shuffled 8192            615708.000 ns ±   1.27 %       2282
 insert shuffled 100000        12116229.500 ns ±   4.20 %        114
 insert shuffled 1000000      275528687.500 ns ±   1.03 %          4
 remove 1000                       2041.000 ns ±  14.54 %     691924
 remove 1000000                 1887562.500 ns ±   1.23 %        742
 randomElement 0                    125.000 ns ±  43.75 %    1000000
 randomElement 32                   167.000 ns ±  54.13 %    1000000
 randomElement 1024                 167.000 ns ±  47.71 %    1000000
 randomElement 8192                 167.000 ns ±  48.51 %    1000000
 sequencial element 32              125.000 ns ±  75.95 %    1000000
 sequencial element 1024            125.000 ns ±  54.38 %    1000000
 sequencial element 8192            125.000 ns ±  48.83 %    1000000
 lower bound 32                     125.000 ns ±  55.90 %    1000000
 lower bound 1024                   125.000 ns ±  45.18 %    1000000
 lower bound 8192                   125.000 ns ±  62.23 %    1000000
 upper bound 32                     125.000 ns ±  86.55 %    1000000
 upper bound 1024                   125.000 ns ±  47.07 %    1000000
 upper bound 8192                   125.000 ns ±  59.17 %    1000000
 first index 32                     125.000 ns ±  21.59 %    1000000
 first index 1024                   125.000 ns ±  43.78 %    1000000
 first index 8192                   125.000 ns ±  49.00 %    1000000
 Program ended with exit code: 0
 
 */
