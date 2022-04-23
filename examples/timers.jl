# finish: time in seconds since epoch
@inline function wait_until(finish)
    delta1 = 0.002
    delta2 = 0.0002
    if finish - delta1 > time()
        sleep(finish - time() - 0.001)
    end
    # sleep 
    while finish - delta2 > time()
        Base.Libc.systemsleep(delta2)
    end
    # busy waiting
    while finish > time()-0.95e-6
    end
    nothing
end