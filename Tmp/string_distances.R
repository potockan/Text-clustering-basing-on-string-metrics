library("stringdist")

stringdist('kozak', 'foczka', method = 'hamming')
stringdist('koza', 'foka', method = 'lcs')
stringdist('koza', 'foka', method = 'lv')
stringdist('kozak', 'foczka', method = 'lv', weight = c(0.1, 1, 0.3))
stringdist('kozak', 'foczka', method = 'lv', weight = c(0.1, 1, 0.3))
stringdist('foczka', 'koza', method = 'lv', weight = c(0.1, 1, 0.3))

stringdist('koza', 'foka', method = 'osa')
stringdist('palec', 'palace', method = 'osa')
stringdist('palec', 'palce', method = 'osa')
stringdist('palce', 'palace', method = 'osa')

stringdist('ba', 'acb', method = 'osa')
stringdist('ba', 'ab', method = 'osa')
stringdist('ab', 'acb', method = 'osa')

stringdist('ba', 'acb', method = 'dl')

stringdist('koza', 'foka', method = 'lcs')
stringdist('kozak', 'foczka', method = 'lcs')
stringdist('kozak', 'foczka', method = 'lv')
stringdist('kozak', 'foczka', method = 'osa')
stringdist('kozak', 'foczka', method = 'dl')


stringdist('krolik', 'kolor', method = 'hamming')
stringdist('krolik', 'kolor', method = 'lcs')
stringdist('krolik', 'kolor', method = 'lv')
stringdist('koza', 'foka', method = 'lv', weight = c(0.1, 1, 0.3))
stringdist('kozak', 'foczka', method = 'lv', weight = c(1, 0.2, 0.3))
stringdist('foczka', 'kozak', method = 'lv', weight = c(0.2, 1, 0.3))
stringdist('a', 'k', method = 'lv', weight = c(0.1, 1, 0.3)) #??????????

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





