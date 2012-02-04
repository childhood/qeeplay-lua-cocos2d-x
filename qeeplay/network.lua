
-- module("network", package.seeall)
-- local _llthreads = require("llthreads")
-- local _url       = require("socket.url")
-- local _http      = require("socket.http")
-- local _ltn12     = require("ltn12")
-- local _mime      = require("mime")

-- --[[ generate URL-encoded query string
-- syntax:
--     network.http_build_query(params)

-- examples:
--     local query = network.http_build_query({
--         title = "Title",
--         message = "Hello"
--     })
-- --]]
-- function http_build_query(params)
--     local query = ""
--     for k, v in pairs(params) do
--         query = query..string.format("%s=%s&", k, _url.escape(v))
--     end
--     return string.sub(query, 1, string.len(query) - 1)
-- end


-- local request_thread_code = [[
--     local _http  = require("socket.http")
--     local _ltn12 = require("ltn12")

--     local args = ...
--     local url = args.url
--     local method = args.method
--     local response = {}

--     _http.TIMEOUT = args.timeout or 10

--     local requestParams = {
--         url    = url,
--         method = method,
--         sink   = _ltn12.sink.table(response)
--     }
--     local params = args.params
--     if type(params) == "table" then
--         if params.body then
--             requestParams.source = _ltn12.source.string(tostring(params.body))
--         end
--         if params.headers then
--             requestParams.headers = params.headers
--         end
--     end

--     local result, code, headers = _http.request(requestParams)
--     return result, code, headers, table.concat(response)
-- ]]

-- -- makes an asynchronous HTTP or HTTPS request to a URL
-- function request(url, method, listener, params)
--     local thread
--     local function onComplete(result, code, headers, response)
--         if result then
--             -- succeed
--             listener(true, code, headers, response)
--         else
--             -- failed
--             listener(false, code) -- code is error message
--         end
--         thread = nil -- reference to thread object, avoid gc call join()
--     end

--     if type(params) == "table" and type(params.body) == "table" then
--         params.body = http_build_query(params.body)
--     end

--     thread = _llthreads.new(request_thread_code, onComplete, {
--         url = url,
--         method = method,
--         timeout = 3,
--         params = params
--     })
--     thread:start()
-- end
