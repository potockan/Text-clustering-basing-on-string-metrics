def compute(n):
    import time, socket
    time.sleep(n)
    host = socket.gethostname()
    return (host, n)
