def kwadrat(x):
    '''
    Liczy kwadrat danej liczby.
    
    >>> kwadrat(2)
    4
    >>> kwadrat(3)
    9
    '''
    return x ** 2
   
if __name__ == '__main__':
    #testy jednostkowe
    assert kwadrat(2) == 4
    assert kwadrat(3) == 9
    for i in range(0, 10):
        assert kwadrat(i) == i**2
    import doctest
    doctest.testmod()
