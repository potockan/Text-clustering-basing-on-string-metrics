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
stringdist('a', 'b', method = 'lv', weight = c(0.1, 1, 0.3)) #??????????
stringdist('a', 'b', method = 'lv', weight = c(1, 0.1, 0.3)) 

stringdist('leia', 'leela', method = 'lv', weight = c(1, 0.1, 1)) 
stringdist('leia', 'leela', method = 'lv', weight = c(1, 0.1, 1)) 
stringdist('leia', 'leela', method = 'lv', weight = c(0.1, 1, 1)) 


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


stringdist('kozak', 'foczka', method = 'jaccard', q = 2)
stringdist('kozak', 'foczka', method = 'qgram', q = 2)
stringdist('kozak', 'foczka', method = 'cosine', q = 2)

stringdist('kozak', 'foczka', method = 'jaccard', q = 3)
stringdist('kozak', 'foczka', method = 'qgram', q = 3)
stringdist('kozak', 'foczka', method = 'cosine', q = 3)

stringdist('abaca', 'acaba', method = 'jaccard', q = 2)

stringdist('papaja', 'japa', method = 'jaccard', q = 2)
stringdist('palce', 'pałace', method = 'jaccard', q = 2)
stringdist('abcd', 'abdc', method = 'jaccard', q = 2)
stringdist('abdc', 'cdab', method = 'jaccard', q = 2)

stringdist('papaja', 'japa', method = 'qgram', q = 2)
stringdist('palce', 'pałace', method = 'qgram', q = 2)
stringdist('abaca', 'acaba', method = 'qgram', q = 2)

stringdist('papaja', 'japa', method = 'cosine', q = 2)
stringdist('palce', 'pałace', method = 'cosine', q = 2)

stringdist('kozak', 'foczka', method = 'jw')
stringdist('papaja', 'japa', method = 'jw')

stringdist('papaja', 'papablee', method = 'jw', p = 0.25)



stringdist('faktura', 'faktyczny', method = 'jw', p = 0)
stringdist('faktura', 'faktyczny', method = 'jw', p = 0.1)
stringdist('faktura', 'faktyczny', method = 'jw', p = 0.25)


stringdist('ab', 'cb', method = 'jw', p = 0)
stringdist('ab', 'cd', method = 'jw', p = 0)
stringdist('cb', 'cd', method = 'jw', p = 0)


stringdist('ab', 'cb', method = 'jw', p = 0.1)
stringdist('ab', 'cd', method = 'jw', p = 0.1)
stringdist('cb', 'cd', method = 'jw', p = 0.1)


stringdist('ab', 'cb', method = 'jw', p = 0.25)
stringdist('ab', 'cd', method = 'jw', p = 0.25)
stringdist('cb', 'cd', method = 'jw', p = 0.25)


