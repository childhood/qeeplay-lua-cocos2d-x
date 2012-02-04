
---- global helper functions
function ccp(x, y)
    return CCPoint(x, y)
end

module("display", package.seeall)

local sharedTextureCache = CCTextureCache:sharedTextureCache()
local sharedSpriteFrameCache = CCSpriteFrameCache:sharedSpriteFrameCache()

scale       = 1
if device.screenType == "ipad" then
    scale   = 1.066666667
end

size        = director.director:getWinSize()
width       = size.width
height      = size.height
centerX     = width / 2
centerY     = height / 2
left        = 0
right       = width - 1
top         = height - 1
bottom      = 0

sizeInPixels    = director.director:getWinSizeInPixels()
widthInPixels   = sizeInPixels.width
heightInPixels  = sizeInPixels.height
centerXInPixels = widthInPixels / 2
centerYInPixels = heightInPixels / 2
animationInterval = director.director:getAnimationInterval()

log.warning("# display.scale                = "..scale)
log.warning("# display.width                = "..width)
log.warning("# display.height               = "..height)
log.warning("# display.centerX              = "..centerX)
log.warning("# display.centerY              = "..centerY)
log.warning("# display.left                 = "..left)
log.warning("# display.right                = "..right)
log.warning("# display.top                  = "..top)
log.warning("# display.bottom               = "..bottom)
log.warning("#")

----------------------------------------
---- display object anchorPoint
CENTER        = 1
LEFT_TOP      = 2; TOP_LEFT      = 2
CENTER_TOP    = 3; TOP_CENTER    = 3
RIGHT_TOP     = 4; TOP_RIGHT     = 4
CENTER_LEFT   = 5; LEFT_CENTER   = 5
CENTER_RIGHT  = 6; RIGHT_CENTER  = 6
BOTTOM_LEFT   = 7; LEFT_BOTTOM   = 7
BOTTOM_RIGHT  = 8; RIGHT_BOTTOM  = 8
BOTTOM_CENTER = 9; CENTER_BOTTOM = 9

ANCHOR_POINT_ENUMS = {
    ccp(0.5, 0.5),  -- CENTER
    ccp(0, 1),      -- TOP_LEFT
    ccp(0.5, 1),    -- TOP_CENTER
    ccp(1, 1),      -- TOP_RIGHT
    ccp(0, 0.5),    -- CENTER_LEFT
    ccp(1, 0.5),    -- CENTER_RIGHT
    ccp(0, 0),      -- BOTTOM_LEFT
    ccp(1, 0),      -- BOTTOM_RIGHT
    ccp(0.5, 0),    -- BOTTOM_CENTER
}

--[[ change display object anchorPoint, move to position
syntax:
    display.align(image, anchorPoint, [{x, y} | CCPoint])

examples:
    display.align(image, display.TOP_LEFT)
    display.align(image, display.TOP_LEFT, 0, 0)

--]]
function align(node, anchorPoint, x, y)
    node.anchorPoint = ANCHOR_POINT_ENUMS[anchorPoint]
    if x or y then node:setPosition(x, y) end
end

--[[ create new layer (CCLayer)
syntax:
    display.newLayer([{x, y} | CCPoint])
--]]
function newLayer(x, y)
    local layer = _returnLayer(CCLayer:node(), x, y)
    return layer
end

--[[ create new display object container (CCNode)
syntax:
    display.newGroup([{x, y} | CCPoint])
--]]
function newGroup(x, y)
    return _returnGroup(CCNode:node(), x, y)
end

--[[ create new sprite from image file (CCSprite)
syntax:
    display.newSprite(filename, [{x, y} | CCPoint, bypassAutoHD])
    display.newImage(filename, [{x, y} | CCPoint, bypassAutoHD])
--]]
function newSprite(filename, x, y, bypassAutoHD)
    local sprite
    if string.sub(filename, 1, 1) == "#" then
        sprite = CCSprite:spriteWithSpriteFrameName(string.sub(filename, 2))
    else
        if bypassAutoHD ~= true then filename = getFilename(filename) end
        sprite = CCSprite:spriteWithFile(filename)
    end
    return _returnSprite(sprite, x, y)
end
newImage = newSprite

--[[ create new sprite from image file, move to screen center (CCSprite)
syntax:
    display.newBackgroundImage(filename, bypassAutoHD)
--]]
function newBackgroundImage(filename, bypassAutoHD)
    return newSprite(filename, centerX, centerY, bypassAutoHD)
end

--[[ create texture from image file (CCTexture2D)
syntax:
    display.newTextureWithFile(filename)
--]]
function newTextureWithFile(filename)
    local tex = sharedTextureCache:addImage(getFilename(filename))
    return _returnTexture(tex)
end

--[[ create frame from texture (CCSpriteFrame)
syntax:
    display.newFrameWithTexture(texture, {left, top, width, height} | CCRect)
--]]
function newFrameWithTexture(texture, left, top, width, height)
    local rect = left
    if type(left) == "number" then
        rect = CCRectMake(left, top, width, height)
    end
    local frame = CCSpriteFrame:frameWithTexture(texture, rect)
    return _returnFrame(frame)
end

--[[ create sprite from frame (CCSprite)
syntax:
    display.newSpriteWithFrame(frame, [{x, y} | CCPoint])
--]]
function newSpriteWithFrame(frame, x, y)
    local sprite = CCSprite:spriteWithSpriteFrame(frame)
    return _returnSprite(sprite, x, y)
end

--[[ adds multiple frames from a plist file
syntax:
    display.addSpriteFramesWithFile(plistFilename, filename | CCTexture2D)
--]]
function addSpriteFramesWithFile(plistFilename, image)
    sharedSpriteFrameCache:addSpriteFramesWithFile(plistFilename, getFilename(image))
end

--[[ remove unused frames from cache
syntax:
    display.removeUnusedSpriteFrames()
--]]
function removeUnusedSpriteFrames()
    sharedSpriteFrameCache:removeUnusedSpriteFrames()
end

--[[ create new CCSpriteBatchNode from image file
syntax:
    display.newBatchNode(filename | CCTexture2D, [capacity])
--]]
function newBatchNode(image, capacity)
    capacity = capacity or 29
    local batchNode
    if type(image) == "string" then
        batchNode = CCSpriteBatchNode:batchNodeWithFile(getFilename(image), capacity)
    else
        batchNode = CCSpriteBatchNode:batchNodeWithTexture(image, capacity)
    end
    return _returnBatchNode(batchNode)
end

--[[ create new CCSpriteBatchNode from image, adds multiple frames from a plist file
syntax:
    display.newBatchNodeWithDataAndImage(plistFilename, filename | CCTexture2D, [capacity])
--]]
function newBatchNodeWithDataAndImage(plistFilename, image, capacity)
    local texture
    if type(image) == "string" then
        texture = newTextureWithFile(image)
    else
        texture = image
    end
    addSpriteFramesWithFile(plistFilename, texture)
    return newBatchNode(texture, capacity)
end

--[[ create multiple frames by pattern
syntax:
    display.newFrames(pattern, begin, length)

examples:
    -- create array [walk_01.png -> walk_20.png]
    display.newBatchNodeWithDataAndImage("walk.plist", "walk.png")
    local frames = display.newFrames("walk_%02d.png", 1, 20)
--]]
function newFrames(pattern, begin, length)
    local frames = {}
    for index = begin, begin + length - 1 do
        local frameName = string.format(pattern, index)
        local frame = sharedSpriteFrameCache:spriteFrameByName(frameName)
        frames[#frames + 1] = frame
    end
    return frames
end

--[[ create animate
syntax:
    display.newAnimate(frames, time, isRestoreOriginalFrame)

examples:
    local batchNode = display.newBatchNodeWithDataAndImage("walk.plist", "walk.png")
    local frames  = display.newFrames("walk_%02d.png", 1, 20)
    local animate = display.newAnimate(frames, 0.5 / 20) -- 0.5s play 20 frames
    local sprite  = display.newSpriteWithFrame(frames[1], 100, 50)
    batchNode:addChild(sprite)

    sprite:runAnimateRepeatForever(animate)
--]]
function newAnimate(frames, time, isRestoreOriginalFrame)
    local count = #frames
    local array = CCMutableArray_CCSpriteFrame_:new(count)
    linkCobject(array)
    for i = 1, count do
        array:addObject(frames[i])
    end

    time = time or 1.0 / count
    local animation = CCAnimation:animationWithFrames(array, time)
    isRestoreOriginalFrame = isRestoreOriginalFrame or false

    local animate = CCAnimate:actionWithAnimation(animation, isRestoreOriginalFrame)
    return _returnAnimate(linkCobject(animate))
end

---------------------------------------
---- bind methods to lua object

-- node
function _setNodeMethods(node)
    node.removeFromParentAndCleanup_ = node.removeFromParentAndCleanup
    function node:removeFromParentAndCleanup(isCleanup)
        self:removeFromParentAndCleanup_(isCleanup or true)
    end

    function node:removeSelf(isCleanup)
        self:removeFromParentAndCleanup(isCleanup)
    end

    function node:align(anchorPoint, x, y)
        align(self, anchorPoint, x, y)
    end
end

-- layer
function _setLayerMethods(node)
    _setNodeMethods(node)
    function node:addTouchEventListener(listener, isMultiTouches, priority, swallowsTouches)
        if type(isMultiTouches) ~= "boolean" then isMultiTouches = false end
        if type(priority) ~= "number" then priority = 0 end
        if type(swallowsTouches) ~= "boolean" then swallowsTouches = false end
        self:registerScriptTouchHandler(listener, isMultiTouches, priority, swallowsTouches)
    end

    function node:removeTouchEventListener()
        self:unregisterScriptTouchHandler()
    end
end

-- group
function _setGroupMethods(node)
    _setNodeMethods(node)
end

-- sprite
function _setSpriteMethods(node)
    _setNodeMethods(node)
    function node:runAnimateRepeatForever(animate)
        self:runAction(CCRepeatForever:actionWithAction(animate))
    end

    function node:setAliasTexParameters()
        self:getTexture():setAliasTexParameters()
    end

    function node:setAntiAliasTexParameters()
        self:getTexture():setAntiAliasTexParameters()
    end
end

-- batchNode
function _setBatchNodeMethods(node)
    _setNodeMethods(node)
end

----

function _returnNode(node, x, y)
    if x and y then node:setPosition(x, y) end
    return node
end

function _returnLayer(node, x, y)
    _setLayerMethods(node)
    return _returnNode(node, x, y)
end

function _returnGroup(node, x, y)
    _setGroupMethods(node)
    return _returnNode(node, x, y)
end

function _returnSprite(node, x, y)
    _setSpriteMethods(node)
    node:setScale(scale)
    return _returnNode(node, x, y)
end

function _returnBatchNode(node, x, y)
    _setBatchNodeMethods(node)
    return _returnNode(node, x, y)
end

function _returnTexture(texture)
    return texture
end

function _returnFrame(frame)
    return frame
end

function _returnAnimate(animate)
    return animate
end

----

function getFilename(filename)
    if type(filename) ~= "string" then return filename end
    local i = io.pathinfo(filename)
    local suffix = getSuffixName()
    return i.dirname..i.basename..suffix..i.extname
end

function getSuffixName()
    if device.screenType == "ipad" or device.screenType == "androidhd" then
        return "-hd"
    end
    return ""
end
