library("stringdist")

stringdist('koza', 'foka', method = 'hamming')
stringdist('koza', 'foka', method = 'lcs')
stringdist('koza', 'foka', method = 'lv')
stringdist('koza', 'foka', method = 'lv', weight = c(0.1, 1, 0.3))

stringdist('koza', 'foka', method = 'osa')
stringdist('koza', 'foka', method = 'dl')

