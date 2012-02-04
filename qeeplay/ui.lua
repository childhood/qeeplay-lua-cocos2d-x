
module("ui", package.seeall)

TOUCH_BEGAN = CCTOUCHBEGAN
TOUCH_MOVED = CCTOUCHMOVED
TOUCH_ENDED = CCTOUCHENDED
TOUCH_CANCELLED = CCTOUCHCANCELLED

local globalMenuItemTag = 0

function newMenu(items, x, y)
    local menu
    menu = CCMenu:node()
    _setMenuMethods(menu)

    if type(items) == "table" then
        for k, item in pairs(items) do
            menu:addChild(item)
        end
    end

    x = x or 0
    y = y or 0
    menu:setPosition(x, y)
    return menu
end

function newMenuItemImage(args)
    local imageNormal   = args.image
    local imageDown     = args.imageDown
    local imageDisabled = args.imageDisabled
    local listener      = args.listener
    local x             = args.x
    local y             = args.y

    globalMenuItemTag = globalMenuItemTag + 1
    local menuItemTag = args.tag or globalMenuItemTag

    local item
    if type(imageNormal) == "string" then
        imageNormal = display.newImage(imageNormal)
    end

    if type(imageDown) == "string" then
        imageDown = display.newImage(imageDown)
    end
    if type(imageDisabled) == "string" then
        imageDisabled = display.newImage(imageDisabled)
    end

    item = CCMenuItemSprite:itemFromNormalSprite(imageNormal, imageDown, imageDisabled)
    if item then
        item.menuItemTag = menuItemTag
        display._setSpriteMethods(item)
        if listener then item:registerScriptHandler(listener) end
        if x and y then item:setPosition(x, y) end
    end
    return item
end

function newBMFontLabel(string, font, x, y)
    string = tostring(string)
    local label = CCLabelBMFont:labelWithString(string, font)
    if label then
        display._setNodeMethods(label)
        if x and y then label:setPosition(x, y) end
    end
    return label
end

----

function _setMenuMethods(menu)
    menu.addChild_ = menu.addChild
    function menu:addChild(child)
        self:addChild_(child)
        if child.menuItemTag then child.tag = child.menuItemTag end
    end

    display._setNodeMethods(menu)
end
