library("stringdist")

stringdist('koza', 'foka', method = 'hamming')
stringdist('koza', 'foka', method = 'lcs')
stringdist('koza', 'foka', method = 'lv')
stringdist('koza', 'foka', method = 'lv', weight = c(0.1, 1, 0.3))
stringdist('koza', 'foczka', method = 'lv', weight = c(0.1, 1, 0.3))
stringdist('foczka', 'koza', method = 'lv', weight = c(0.1, 1, 0.3))

stringdist('koza', 'foka', method = 'osa')
stringdist('palec', 'palace', method = 'osa')
stringdist('palec', 'palce', method = 'osa')
stringdist('palce', 'palace', method = 'osa')

stringdist('ba', 'acb', method = 'osa')
stringdist('ba', 'ab', method = 'osa')
stringdist('ab', 'acb', method = 'osa')

stringdist('ba', 'acb', method = 'dl')





stringdist('krolik', 'kolor', method = 'hamming')
stringdist('krolik', 'kolor', method = 'lcs')
stringdist('krolik', 'kolor', method = 'lv')
stringdist('krolik', 'kolor', method = 'lv', weight = c(0.1, 1, 0.3))
stringdist('krolik', 'kolor', method = 'lv', weight = c(1, 0.1, 0.3))
stringdist('kolor', 'krolik', method = 'lv', weight = c(0.1, 1, 0.3))

stringdist('krolik', 'krol', method = 'osa')
stringdist('krol', 'kolor', method = 'osa')
stringdist('krolik', 'kolor', method = 'osa')

stringdist('palec', 'palace', method = 'osa')
stringdist('palec', 'palce', method = 'osa')
stringdist('palce', 'palace', method = 'osa')

stringdist('ba', 'acb', method = 'osa')
stringdist('ba', 'ab', method = 'osa')
stringdist('ab', 'acb', method = 'osa')

stringdist('ba', 'acb', method = 'dl')
stringdist('krolik', 'kolor', method = 'dl')





