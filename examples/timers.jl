# finish: time in seconds since epoch
@inline function wait_until(finish)
    delta = 0.0002
    if finish - 0.002 > time()
        sleep(finish - time() - 0.001)
    end
    # sleep 
    while finish - delta > time()
        Base.Libc.systemsleep(delta)
    end
    # busy waiting
    while finish > time()-0.95e-6
    end
    nothing
end