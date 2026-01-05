/*
 
 UNSAFE_TREE
 2026-01-05 09:39:46 +0000

 running insert already presents 0... done! (199.69 ms)
 running insert already presents 32... done! (219.51 ms)
 running insert already presents 1024... done! (241.12 ms)
 running insert already presents 8192... done! (271.43 ms)
 running insert new 0... done! (302.73 ms)
 running insert new 32... done! (312.18 ms)
 running insert new 1024... done! (312.40 ms)
 running insert new 8192... done! (312.91 ms)
 running insert 0... done! (193.26 ms)
 running insert 32... done! (1015.55 ms)
 running insert 1024... done! (1692.37 ms)
 running insert 8192... done! (1695.47 ms)
 running insert 100000... done! (1810.77 ms)
 running insert 1000000... done! (2032.80 ms)
 running insert shuffled 0... done! (193.84 ms)
 running insert shuffled 32... done! (901.59 ms)
 running insert shuffled 1024... done! (1906.67 ms)
 running insert shuffled 8192... done! (2083.46 ms)
 running insert shuffled 100000... done! (1626.30 ms)
 running insert shuffled 1000000... done! (2785.03 ms)
 running remove 1000... done! (2312.09 ms)
 running remove 1000000... done! (2352.86 ms)
 running randomElement 0... done! (174.39 ms)
 running randomElement 32... done! (219.68 ms)
 running randomElement 1024... done! (219.78 ms)
 running randomElement 8192... done! (219.68 ms)
 running sequencial element 32... done! (180.53 ms)
 running sequencial element 1024... done! (180.98 ms)
 running sequencial element 8192... done! (182.03 ms)
 running lower bound 32... done! (198.04 ms)
 running lower bound 1024... done! (204.32 ms)
 running lower bound 8192... done! (210.33 ms)
 running upper bound 32... done! (198.29 ms)
 running upper bound 1024... done! (205.31 ms)
 running upper bound 8192... done! (214.64 ms)
 running first index 32... done! (196.28 ms)
 running first index 1024... done! (203.56 ms)
 running first index 8192... done! (205.94 ms)

 name                         time             std        iterations warmup
 ------------------------------------------------------------------------------------
 insert already presents 0          166.000 ns ±  25.61 %    1000000      5459.000 ns
 insert already presents 32         167.000 ns ±  46.75 %    1000000      4417.000 ns
 insert already presents 1024       208.000 ns ±  41.64 %    1000000     15083.000 ns
 insert already presents 8192       209.000 ns ±  32.25 %    1000000     22250.000 ns
 insert new 0                       250.000 ns ±  42.58 %    1000000     39916.000 ns
 insert new 32                      250.000 ns ±  30.76 %    1000000      4042.000 ns
 insert new 1024                    250.000 ns ±  30.01 %    1000000      5000.000 ns
 insert new 8192                    250.000 ns ±  55.11 %    1000000      3916.000 ns
 insert 0                           166.000 ns ±  37.73 %    1000000      1958.000 ns
 insert 32                          875.000 ns ±  31.39 %    1000000      8541.000 ns
 insert 1024                      26000.000 ns ±   4.62 %      53711     98209.000 ns
 insert 8192                     259750.000 ns ±   2.28 %       5371    846876.000 ns
 insert 100000                  3623375.000 ns ±   0.99 %        385  11514125.000 ns
 insert 1000000                44817834.000 ns ±   1.11 %         31 142494251.000 ns
 insert shuffled 0                  166.000 ns ±  44.91 %    1000000      3625.000 ns
 insert shuffled 32                 792.000 ns ±  28.89 %    1000000      7250.000 ns
 insert shuffled 1024             24125.000 ns ±  28.13 %      55141    173625.000 ns
 insert shuffled 8192            616875.000 ns ±   1.51 %       2236   2030999.000 ns
 insert shuffled 100000        13967854.000 ns ±   3.11 %        104  40446376.000 ns
 insert shuffled 1000000      303833000.000 ns ±   0.50 %          5 966657500.000 ns
 remove 1000                       8083.000 ns ±   7.86 %     172657     52750.000 ns
 remove 1000000                 7962042.000 ns ±   2.57 %        175  61394125.000 ns
 randomElement 0                    125.000 ns ±  43.23 %    1000000      1834.000 ns
 randomElement 32                   167.000 ns ±  58.33 %    1000000     24167.000 ns
 randomElement 1024                 167.000 ns ±  50.07 %    1000000      3958.000 ns
 randomElement 8192                 167.000 ns ±  51.19 %    1000000      3249.000 ns
 sequencial element 32              125.000 ns ±  39.25 %    1000000      2709.000 ns
 sequencial element 1024            125.000 ns ±  45.56 %    1000000      1458.000 ns
 sequencial element 8192            125.000 ns ±  88.34 %    1000000      1375.000 ns
 lower bound 32                     166.000 ns ±  51.35 %    1000000      2542.000 ns
 lower bound 1024                   167.000 ns ±  35.80 %    1000000      4000.000 ns
 lower bound 8192                   167.000 ns ±  50.33 %    1000000      4500.000 ns
 upper bound 32                     166.000 ns ±  44.24 %    1000000      2584.000 ns
 upper bound 1024                   167.000 ns ±  72.63 %    1000000      3042.000 ns
 upper bound 8192                   167.000 ns ±  46.76 %    1000000      3875.000 ns
 first index 32                     166.000 ns ±  40.76 %    1000000      3209.000 ns
 first index 1024                   167.000 ns ±  46.06 %    1000000      3168.000 ns
 first index 8192                   167.000 ns ±  33.33 %    1000000     12000.000 ns
 Program ended with exit code: 0
 
 */
