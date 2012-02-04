
module("scheduler", package.seeall)

scheduler = CCScheduler:sharedScheduler()

function enterFrame(listener, isPaused)
    return scheduler:scheduleScriptFunc(listener, 0, isPaused or false)
end

function schedule(listener, interval, isPaused)
    return scheduler:scheduleScriptFunc(listener, interval, isPaused or false)
end

function unschedule(handle)
    scheduler:unscheduleScriptEntry(handle)
end
remove = unschedule

function performWithDelay(time, listener)
    local handle
    handle = scheduler:scheduleScriptFunc(function()
        scheduler:unscheduleScriptEntry(handle)
        listener()
    end, time, false)
    return handle
end
