/*
 (以前までのものはバグっていて速かった模様）
 
 UNSAFE_TREE＿V2
 2026-01-09 14:45:31 +0000

 running insert already presents 0... done! (199.26 ms)
 running insert already presents 32... done! (219.82 ms)
 running insert already presents 1024... done! (239.85 ms)
 running insert already presents 8192... done! (266.95 ms)
 running insert new 0... done! (312.50 ms)
 running insert new 32... done! (323.64 ms)
 running insert new 1024... done! (320.49 ms)
 running insert new 8192... done! (320.22 ms)
 running insert 0... done! (195.33 ms)
 running insert 32... done! (1306.06 ms)
 running insert 1024... done! (1680.47 ms)
 running insert 8192... done! (1650.29 ms)
 running insert 100000... done! (1787.98 ms)
 running insert 1000000... done! (2197.59 ms)
 running insert shuffled 0... done! (195.10 ms)
 running insert shuffled 32... done! (1125.72 ms)
 running insert shuffled 1024... done! (1589.11 ms)
 running insert shuffled 8192... done! (2033.36 ms)
 running insert shuffled 100000... done! (1527.76 ms)
 running insert shuffled 1000000... done! (1497.52 ms)
 running remove 1000... done! (1667.65 ms)
 running remove 1000000... done! (1654.22 ms)
 running randomElement 0... done! (174.46 ms)
 running randomElement 32... done! (220.05 ms)
 running randomElement 1024... done! (220.18 ms)
 running randomElement 8192... done! (220.12 ms)
 running sequencial element 32... done! (181.83 ms)
 running sequencial element 1024... done! (183.01 ms)
 running sequencial element 8192... done! (183.13 ms)
 running lower bound 32... done! (181.67 ms)
 running lower bound 1024... done! (182.54 ms)
 running lower bound 8192... done! (181.90 ms)
 running upper bound 32... done! (181.67 ms)
 running upper bound 1024... done! (182.54 ms)
 running upper bound 8192... done! (181.12 ms)
 running first index 32... done! (182.53 ms)
 running first index 1024... done! (182.63 ms)
 running first index 8192... done! (182.31 ms)

 name                         time             std        iterations
 -------------------------------------------------------------------
 insert already presents 0          166.000 ns ± 109.49 %    1000000
 insert already presents 32         167.000 ns ± 110.71 %    1000000
 insert already presents 1024       208.000 ns ±  58.35 %    1000000
 insert already presents 8192       209.000 ns ±  35.07 %    1000000
 insert new 0                       250.000 ns ±  39.90 %    1000000
 insert new 32                      250.000 ns ±  34.13 %    1000000
 insert new 1024                    250.000 ns ±  39.86 %    1000000
 insert new 8192                    250.000 ns ±  42.70 %    1000000
 insert 0                           166.000 ns ±  37.45 %    1000000
 insert 32                         1125.000 ns ±  21.14 %    1000000
 insert 1024                      26000.000 ns ±   3.34 %      53152
 insert 8192                     232583.000 ns ±   2.04 %       5933
 insert 100000                  3528104.000 ns ±   1.35 %        396
 insert 1000000                70041375.000 ns ±   2.25 %         20
 insert shuffled 0                  166.000 ns ±  34.97 %    1000000
 insert shuffled 32                1000.000 ns ±  22.48 %    1000000
 insert shuffled 1024             25334.000 ns ±  16.77 %      46407
 insert shuffled 8192            578395.500 ns ±   1.52 %       2376
 insert shuffled 100000        13244500.000 ns ±   2.99 %        105
 insert shuffled 1000000      297700500.000 ns ±   3.83 %          4
 remove 1000                       2042.000 ns ±  14.86 %     686298
 remove 1000000                 1912542.000 ns ±   0.97 %        729
 randomElement 0                    125.000 ns ±  58.32 %    1000000
 randomElement 32                   167.000 ns ±  64.12 %    1000000
 randomElement 1024                 167.000 ns ±  49.26 %    1000000
 randomElement 8192                 167.000 ns ±  54.34 %    1000000
 sequencial element 32              125.000 ns ±  25.56 %    1000000
 sequencial element 1024            125.000 ns ±  60.60 %    1000000
 sequencial element 8192            125.000 ns ±  68.32 %    1000000
 lower bound 32                     125.000 ns ±  53.92 %    1000000
 lower bound 1024                   125.000 ns ±  88.70 %    1000000
 lower bound 8192                   125.000 ns ±  45.13 %    1000000
 upper bound 32                     125.000 ns ±  62.19 %    1000000
 upper bound 1024                   125.000 ns ±  90.64 %    1000000
 upper bound 8192                   125.000 ns ±  52.37 %    1000000
 first index 32                     125.000 ns ±  74.57 %    1000000
 first index 1024                   125.000 ns ±  83.71 %    1000000
 first index 8192                   125.000 ns ±  43.89 %    1000000
 Program ended with exit code: 0
 
 */
