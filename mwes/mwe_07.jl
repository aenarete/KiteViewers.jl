# http example
using HTTP, JSON3, StructTypes, KiteUtils

url = "http://localhost:8080"

function init()
    response = HTTP.get(url*"/init")
    if response.status == 200
        return JSON3.read(response.body)
    else
        return nothing
    end
end

function get_sys_state()
    response = HTTP.get(url*"/sys_state")
    if response.status == 200
        return JSON3.read(response.body)
    else
        return nothing
    end
end

function get_sys_state2()
    response = HTTP.get(url*"/sys_state")
    if response.status == 200
        return (response.body)
    else
        return nothing
    end
end

# TODO: convert JSON into a SysState object

# JSON3.@generatetypes ss
# StructTypes.StructType(::Type{SysState{P}}) = StructTypes.Struct()
# ss = get_sys_state()
# P = length(ss.Z)
# sys_state = JSON3.read(get_sys_state(), SysState{P})