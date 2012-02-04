
module("json", package.seeall)
local cjson = require("cjson")
local _encode = cjson.encode
local _decode = cjson.decode

function encode(var)
    local status, result = pcall(_encode, var)
    if status then return result end
    log.warning("[JSON ENCODE] %s", result)
    return nil
end

function decode(text)
    local status, result = pcall(_decode, text)
    if status then return result end
    log.warning("[JSON DECODE] %s", result)
    return nil
end
