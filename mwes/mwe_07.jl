# http example
using HTTP, JSON3, KiteUtils

url = "http://localhost:8080"

function init()
    response = HTTP.get(url*"/init")
    if response.status == 200
        return JSON3.read(response.body)
    else
        return nothing
    end
end

function sys_state()
    response = HTTP.get(url*"/sys_state")
    if response.status == 200
        return JSON3.read(response.body)
    else
        return nothing
    end
end

# TODO: convert JSON into a SystemState object

