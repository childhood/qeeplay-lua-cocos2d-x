
if type(DEBUG) ~= "number" then DEBUG = 1 end
io.output():setvbuf('no')

local prt = function(...)
    print("[LUA] "..string.format(...))
end

log = {}
log.notice  = function() end
log.warning = function() end
log.error   = prt

if DEBUG > 0 then log.warning = prt end
if DEBUG > 1 then log.notice = prt end
