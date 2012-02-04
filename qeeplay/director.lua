
module("director", package.seeall)

director = CCDirector:sharedDirector()

local transitionsMap = {}
transitionsMap["CCTRANSITIONCROSSFADE"]    = {CCTransitionCrossFade, 2}
transitionsMap["CCTRANSITIONFADE"]         = {CCTransitionFade, 3, ccc3(0, 0, 0)}
transitionsMap["CCTRANSITIONFADEBL"]       = {CCTransitionFadeBL, 2}
transitionsMap["CCTRANSITIONFADEDOWN"]     = {CCTransitionFadeDown, 2}
transitionsMap["CCTRANSITIONFADETR"]       = {CCTransitionFadeTR, 2}
transitionsMap["CCTRANSITIONFADEUP"]       = {CCTransitionFadeUp, 2}

transitionsMap["CCTRANSITIONFLIPANGULAR"]  = {CCTransitionFlipAngular, 3, kOrientationLeftOver}
transitionsMap["CCTRANSITIONFLIPX"]        = {CCTransitionFlipX, 3, kOrientationLeftOver}
transitionsMap["CCTRANSITIONFLIPY"]        = {CCTransitionFlipY, 3, kOrientationUpOver}
transitionsMap["CCTRANSITIONZOOMFLIPX"]    = {CCTransitionZoomFlipX, 3, kOrientationLeftOver}
transitionsMap["CCTRANSITIONZOOMFLIPY"]    = {CCTransitionZoomFlipY, 3, kOrientationUpOver}

transitionsMap["CCTRANSITIONJUMPZOOM"]     = {CCTransitionJumpZoom, 2}
transitionsMap["CCTRANSITIONROTOZOOM"]     = {CCTransitionRotoZoom, 2}

transitionsMap["CCTRANSITIONMOVEINB"]      = {CCTransitionMoveInB, 2}
transitionsMap["CCTRANSITIONMOVEINL"]      = {CCTransitionMoveInL, 2}
transitionsMap["CCTRANSITIONMOVEINR"]      = {CCTransitionMoveInR, 2}
transitionsMap["CCTRANSITIONMOVEINT"]      = {CCTransitionMoveInT, 2}

transitionsMap["CCTRANSITIONSLIDEINB"]     = {CCTransitionSlideInB, 2}
transitionsMap["CCTRANSITIONSLIDEINL"]     = {CCTransitionSlideInL, 2}
transitionsMap["CCTRANSITIONSLIDEINR"]     = {CCTransitionSlideInR, 2}
transitionsMap["CCTRANSITIONSLIDEINT"]     = {CCTransitionSlideInT, 2}

transitionsMap["CCTRANSITIONSHRINKGROW"]   = {CCTransitionShrinkGrow, 2}
transitionsMap["CCTRANSITIONSPLITCOLS"]    = {CCTransitionSplitCols, 2}
transitionsMap["CCTRANSITIONSPLITROWS"]    = {CCTransitionSplitRows, 2}
transitionsMap["CCTRANSITIONTURNOFFTILES"] = {CCTransitionTurnOffTiles, 2}

transitionsMap["CCTRANSITIONSCENEORIENTED"] = {CCTransitionSceneOriented, 3, kOrientationLeftOver}
transitionsMap["CCTRANSITIONZOOMFLIPANGULAR"] = {CCTransitionZoomFlipAngular, 2}

transitionsMap["CCTRANSITIONPAGETURN"] = {CCTransitionPageTurn, 3, false}
transitionsMap["CCTRANSITIONRADIALCCW"] = {CCTransitionRadialCCW, 2}
transitionsMap["CCTRANSITIONRADIALCW"] = {CCTransitionRadialCW, 2}


--[[ create new scene (CCScene)
syntax:
    display.newScene(name)
--]]
function newScene(name)
    local scene = CCScene:node()
    scene.name = name or "<none-name>"
    scene.isTouchEnabled = false
    return _returnScene(scene)
end

--[[ replaces the running scene with a new one.
syntax:
    director.replaceScene(newScene, [transition mode, transition time, [more parameter] ])

examples:
    director.replaceScene(newScene)
    director.replaceScene(newScene, "crossFade", 0.5)
    director.replaceScene(newScene, "fade", 0.5, ccc3(255, 255, 255))
--]]
function replaceScene(nextScene, transition_, transitionTime, more)
    local current = director:getRunningScene()
    if current then
        if current.beforeExit then current:beforeExit() end
        nextScene = newSceneWithTransition(nextScene, transition_, transitionTime, more)
        director:replaceScene(nextScene)
    else
        director:runWithScene(nextScene)
    end
end

----

function newSceneWithTransition(scene, transitionName, time, more)
    local key = string.upper(tostring(transitionName))
    if string.sub(key, 1, 12) ~= "CCTRANSITION" then
        key = "CCTRANSITION" .. key
    end

    if transitionsMap[key] then
        local cls, count, default = unpack(transitionsMap[key])
        transitionTime = transitionTime or 0.2

        if count == 3 then
            scene = cls:transitionWithDuration(time, scene, more or default)
        else
            scene = cls:transitionWithDuration(time, scene)
        end
    end
    return scene
end

function _returnScene(scene)
    local function sceneEventHandler(eventType)
        if eventType == kCCNodeOnEnter then
            print(string.format("## Scene \"%s:onEnter()\"", scene.name))
            scene.isTouchEnabled = true
            if scene.onEnter then scene:onEnter() end
        else
            print(string.format("## Scene \"%s:onExit()\"", scene.name))
            scene.isTouchEnabled = false
            if scene.onExit then scene:onExit() end
        end
    end

    scene:registerScriptHandler(sceneEventHandler)

    return scene
end
