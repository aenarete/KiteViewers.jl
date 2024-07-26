# http example
using HTTP
using JSON3

url = "http://localhost:8080"

function get_data(url)
    response = HTTP.get(url)
    return JSON3.read(response.body)
end
