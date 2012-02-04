
module("qeeplay", package.seeall)
require("qeeplay.debug")

log.warning("")
log.warning("# debug                        = "..DEBUG)
log.warning("#")

require("qeeplay.device")
require("qeeplay.functions")
require("qeeplay.director")
require("qeeplay.display")
require("qeeplay.scheduler")
require("qeeplay.transition")
require("qeeplay.ui")
require("qeeplay.ui")
require("qeeplay.audio")
require("qeeplay.json")
require("qeeplay.network")
require("qeeplay.localize")


local timeCount = 0
local function checkMemory(dt)
    timeCount = timeCount + dt
    print(string.format("[LUA] MEMORY USED: %04.2fs, %0.2f KB",
                        timeCount,
                        tonumber(collectgarbage("count"))))
end
-- scheduler.schedule(checkMemory, 1.0)

-- 设定垃圾回收参数
collectgarbage("setpause", 150)
collectgarbage("setstepmul", 1000)
