
module("transition", package.seeall)

local easingMap = {}
easingMap["CCEASEBACKIN"]           = {CCEaseBackIn, 1}
easingMap["CCEASEBACKINOUT"]        = {CCEaseBackInOut, 1}
easingMap["CCEASEBACKOUT"]          = {CCEaseBackOut, 1}
easingMap["CCEASEBOUNCE"]           = {CCEaseBounce, 1}
easingMap["CCEASEBOUNCEIN"]         = {CCEaseBounceIn, 1}
easingMap["CCEASEBOUNCEINOUT"]      = {CCEaseBounceInOut, 1}
easingMap["CCEASEBOUNCEOUT"]        = {CCEaseBounceOut, 1}
easingMap["CCEASEELASTIC"]          = {CCEaseElastic, 2, 0.3}
easingMap["CCEASEELASTICIN"]        = {CCEaseElasticIn, 2, 0.3}
easingMap["CCEASEELASTICINOUT"]     = {CCEaseElasticInOut, 2, 0.3}
easingMap["CCEASEELASTICOUT"]       = {CCEaseElasticOut, 2, 0.3}
easingMap["CCEASEEXPONENTIALIN"]    = {CCEaseExponentialIn, 1}
easingMap["CCEASEEXPONENTIALINOUT"] = {CCEaseExponentialInOut, 1}
easingMap["CCEASEEXPONENTIALOUT"]   = {CCEaseExponentialOut, 1}
easingMap["CCEASEIN"]               = {CCEaseIn, 2, 1}
easingMap["CCEASEINOUT"]            = {CCEaseInOut, 2, 1}
easingMap["CCEASEOUT"]              = {CCEaseOut, 2, 1}
easingMap["CCEASERATEACTION"]       = {CCEaseRateAction, 2, 1}
easingMap["CCEASESINEIN"]           = {CCEaseSineIn, 1}
easingMap["CCEASESINEINOUT"]        = {CCEaseSineInOut, 1}
easingMap["CCEASESINEOUT"]          = {CCEaseSineOut, 1}

local actionManager = CCActionManager:sharedManager()


function newEasing(action, easingName, more)
    local key = string.upper(tostring(easingName))
    if string.sub(key, 1, 6) ~= "CCEASE" then
        key = "CCEASE" .. key
    end
    if easingMap[key] then
        local cls, count, default = unpack(easingMap[key])
        if count == 2 then
            easing = cls:actionWithAction(action, more or default)
        else
            easing = cls:actionWithAction(action)
        end
    end
    return easing
end

function to(target, action, args)
    local delay = args.delay or 0
    local time = args.time or 0.2
    local onComplete = args.onComplete or onComplete

    if args.easing then
        if type(args.easing) == "table" then
            action = newEasing(action, unpack(args.easing))
        else
            action = newEasing(action, args.easing)
        end
    end

    if type(time) ~= "number" then time = 0.2 end

    if type(delay) == "number" and delay > 0 then
        action:retain()
        scheduler.performWithDelay(delay, function()
            target:runAction(action)
            action:release()
        end)
    else
        target:runAction(action)
    end

    if type(onComplete) == "function" then
        scheduler.performWithDelay(delay + time, onComplete)
    end

    return action
end

function moveTo(target, args)
    local x = args.x or target.x
    local y = args.y or target.y
    local action = CCMoveTo:actionWithDuration(args.time or 0.2, ccp(x, y))
    return to(target, action, args)
end

function fadeIn(target, args)
    local action = CCFadeIn:actionWithDuration(args.time or 0.2)
    return to(target, action, args)
end

function fadeOut(target, args)
    local action = CCFadeOut:actionWithDuration(args.time or 0.2)
    return to(target, action, args)
end

function cancel(target)
    actionManager:removeAllActionsFromTarget(target)
end

function pause(target)
    actionManager:pauseTarget(target)
end

function resume(target)
    actionManager:resumeTarget(target)
end

function newSequence(actions)
    local arr = CCArray:array()
    for i = 1, #actions do
        arr:addObject(actions[i])
    end
    return CCSequence:actionsWithArray(arr)
end
