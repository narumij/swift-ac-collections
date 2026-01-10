/*
 (以前までのものはバグっていて速かった模様）
 
 UNSAFE_TREE＿V2
 2026-01-10 15:08:06 +0000

 not both, maybe pool v1

 running insert already presents 0... done! (191.51 ms)
 running insert already presents 32... done! (213.75 ms)
 running insert already presents 1024... done! (230.90 ms)
 running insert already presents 8192... done! (258.32 ms)
 running insert new 0... done! (309.30 ms)
 running insert new 32... done! (320.03 ms)
 running insert new 1024... done! (322.07 ms)
 running insert new 8192... done! (321.73 ms)
 running insert 0... done! (190.82 ms)
 running insert 32... done! (1206.84 ms)
 running insert 1024... done! (1679.34 ms)
 running insert 8192... done! (1662.25 ms)
 running insert 100000... done! (1799.41 ms)
 running insert 1000000... done! (2278.13 ms)
 running insert shuffled 0... done! (187.59 ms)
 running insert shuffled 32... done! (1083.10 ms)
 running insert shuffled 1024... done! (1565.02 ms)
 running insert shuffled 8192... done! (2050.76 ms)
 running insert shuffled 100000... done! (1579.33 ms)
 running insert shuffled 1000000... done! (1668.62 ms)
 running remove 1000... done! (1667.42 ms)
 running remove 1000000... done! (1648.81 ms)
 running randomElement 0... done! (168.89 ms)
 running randomElement 32... done! (219.46 ms)
 running randomElement 1024... done! (219.26 ms)
 running randomElement 8192... done! (219.05 ms)
 running sequencial element 32... done! (175.96 ms)
 running sequencial element 1024... done! (178.80 ms)
 running sequencial element 8192... done! (177.14 ms)
 running lower bound 32... done! (175.40 ms)
 running lower bound 1024... done! (175.99 ms)
 running lower bound 8192... done! (177.64 ms)
 running upper bound 32... done! (177.16 ms)
 running upper bound 1024... done! (176.82 ms)
 running upper bound 8192... done! (176.70 ms)
 running first index 32... done! (175.93 ms)
 running first index 1024... done! (176.12 ms)
 running first index 8192... done! (175.85 ms)

 name                         time             std        iterations
 -------------------------------------------------------------------
 insert already presents 0          166.000 ns ± 104.80 %    1000000
 insert already presents 32         167.000 ns ± 136.09 %    1000000
 insert already presents 1024       167.000 ns ±  80.74 %    1000000
 insert already presents 8192       208.000 ns ±  61.05 %    1000000
 insert new 0                       250.000 ns ±  63.88 %    1000000
 insert new 32                      250.000 ns ±  80.17 %    1000000
 insert new 1024                    250.000 ns ±  71.73 %    1000000
 insert new 8192                    250.000 ns ±  72.67 %    1000000
 insert 0                           166.000 ns ±  64.78 %    1000000
 insert 32                         1042.000 ns ±  23.11 %    1000000
 insert 1024                      25209.000 ns ±   3.83 %      55292
 insert 8192                     232417.000 ns ±   1.93 %       6009
 insert 100000                  3636417.000 ns ±   2.58 %        387
 insert 1000000                80306166.000 ns ±   0.58 %         17
 insert shuffled 0                  166.000 ns ±  39.12 %    1000000
 insert shuffled 32                 958.000 ns ±  24.26 %    1000000
 insert shuffled 1024             29667.000 ns ±  18.67 %      40700
 insert shuffled 8192            601792.000 ns ±   1.56 %       2300
 insert shuffled 100000        12971083.500 ns ±   2.28 %        112
 insert shuffled 1000000      271063750.000 ns ±   0.97 %          5
 remove 1000                       2041.000 ns ±  19.27 %     689067
 remove 1000000                 1912583.500 ns ±   0.82 %        728
 randomElement 0                    125.000 ns ±  68.35 %    1000000
 randomElement 32                   167.000 ns ±  60.61 %    1000000
 randomElement 1024                 167.000 ns ±  65.35 %    1000000
 randomElement 8192                 167.000 ns ±  69.47 %    1000000
 sequencial element 32              125.000 ns ±  68.03 %    1000000
 sequencial element 1024            125.000 ns ±  90.86 %    1000000
 sequencial element 8192            125.000 ns ±  70.38 %    1000000
 lower bound 32                     125.000 ns ±  68.94 %    1000000
 lower bound 1024                   125.000 ns ±  68.22 %    1000000
 lower bound 8192                   125.000 ns ±  76.66 %    1000000
 upper bound 32                     125.000 ns ±  65.49 %    1000000
 upper bound 1024                   125.000 ns ±  59.84 %    1000000
 upper bound 8192                   125.000 ns ±  77.14 %    1000000
 first index 32                     125.000 ns ±  79.98 %    1000000
 first index 1024                   125.000 ns ±  74.00 %    1000000
 first index 8192                   125.000 ns ±  57.95 %    1000000
 Program ended with exit code: 0
 
 */
