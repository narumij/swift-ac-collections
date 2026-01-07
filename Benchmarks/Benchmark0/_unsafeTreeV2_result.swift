/*
 (以前までのものはバグっていて速かった模様）
 
 UNSAFE_TREE＿V2
 2026-01-07 19:18:59 +0000

 running insert already presents 0... done! (194.92 ms)
 running insert already presents 32... done! (220.38 ms)
 running insert already presents 1024... done! (238.87 ms)
 running insert already presents 8192... done! (266.32 ms)
 running insert new 0... done! (297.45 ms)
 running insert new 32... done! (308.05 ms)
 running insert new 1024... done! (305.85 ms)
 running insert new 8192... done! (307.28 ms)
 running insert 0... done! (193.35 ms)
 running insert 32... done! (1289.28 ms)
 running insert 1024... done! (1688.38 ms)
 running insert 8192... done! (1643.35 ms)
 running insert 100000... done! (1787.40 ms)
 running insert 1000000... done! (2207.97 ms)
 running insert shuffled 0... done! (191.42 ms)
 running insert shuffled 32... done! (1124.75 ms)
 running insert shuffled 1024... done! (1678.21 ms)
 running insert shuffled 8192... done! (2066.27 ms)
 running insert shuffled 100000... done! (1529.76 ms)
 running insert shuffled 1000000... done! (1521.92 ms)
 running remove 1000... done! (2277.01 ms)
 running remove 1000000... done! (2256.92 ms)
 running randomElement 0... done! (173.32 ms)
 running randomElement 32... done! (218.24 ms)
 running randomElement 1024... done! (217.65 ms)
 running randomElement 8192... done! (218.25 ms)
 running sequencial element 32... done! (178.66 ms)
 running sequencial element 1024... done! (179.27 ms)
 running sequencial element 8192... done! (179.96 ms)
 running lower bound 32... done! (196.86 ms)
 running lower bound 1024... done! (203.38 ms)
 running lower bound 8192... done! (210.01 ms)
 running upper bound 32... done! (196.37 ms)
 running upper bound 1024... done! (240.67 ms)
 running upper bound 8192... done! (213.82 ms)
 running first index 32... done! (196.44 ms)
 running first index 1024... done! (203.32 ms)
 running first index 8192... done! (204.69 ms)

 name                         time             std        iterations
 -------------------------------------------------------------------
 insert already presents 0          166.000 ns ±  91.30 %    1000000
 insert already presents 32         167.000 ns ± 126.53 %    1000000
 insert already presents 1024       208.000 ns ±  45.83 %    1000000
 insert already presents 8192       208.000 ns ±  54.69 %    1000000
 insert new 0                       250.000 ns ±  49.13 %    1000000
 insert new 32                      250.000 ns ±  54.89 %    1000000
 insert new 1024                    250.000 ns ±  34.72 %    1000000
 insert new 8192                    250.000 ns ±  55.21 %    1000000
 insert 0                           166.000 ns ±  52.12 %    1000000
 insert 32                         1125.000 ns ±  18.45 %    1000000
 insert 1024                      26042.000 ns ±   4.12 %      53310
 insert 8192                     226417.000 ns ±   2.20 %       6073
 insert 100000                  3503833.500 ns ±   1.49 %        396
 insert 1000000                73519875.000 ns ±   1.48 %         19
 insert shuffled 0                  166.000 ns ±  60.49 %    1000000
 insert shuffled 32                1000.000 ns ±  21.08 %    1000000
 insert shuffled 1024             33291.000 ns ±  15.99 %      35441
 insert shuffled 8192            608812.500 ns ±   2.49 %       2258
 insert shuffled 100000        13732625.000 ns ±   3.77 %        101
 insert shuffled 1000000      303955083.500 ns ±   3.91 %          4
 remove 1000                       7750.000 ns ±   8.30 %     179758
 remove 1000000                 7325708.000 ns ±   0.76 %        191
 randomElement 0                    125.000 ns ±  49.89 %    1000000
 randomElement 32                   167.000 ns ±  53.42 %    1000000
 randomElement 1024                 167.000 ns ±  91.32 %    1000000
 randomElement 8192                 167.000 ns ±  64.62 %    1000000
 sequencial element 32              125.000 ns ±  48.99 %    1000000
 sequencial element 1024            125.000 ns ±  27.87 %    1000000
 sequencial element 8192            125.000 ns ±  66.62 %    1000000
 lower bound 32                     166.000 ns ±  68.88 %    1000000
 lower bound 1024                   167.000 ns ±  51.41 %    1000000
 lower bound 8192                   167.000 ns ±  46.14 %    1000000
 upper bound 32                     166.000 ns ±  41.67 %    1000000
 upper bound 1024                   167.000 ns ± 844.86 %    1000000
 upper bound 8192                   167.000 ns ±  28.35 %    1000000
 first index 32                     166.000 ns ±  48.39 %    1000000
 first index 1024                   167.000 ns ±  42.78 %    1000000
 first index 8192                   167.000 ns ±  40.97 %    1000000
 Program ended with exit code: 0
 
 */
