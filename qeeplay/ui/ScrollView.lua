
module("ui.ScrollView", package.seeall)

local SCROLL_TO_VALID_RANGE_SPEED = 400

function new(args)
    local view = display.newLayer()

    view.marginTop          = 0
    view.marginBottom       = 0
    view.items              = {}

    ----

    local sumHeight         = 0
    local frameTime         = 0
    local touch             = nil
    local layer             = nil
    local swiping           = nil
    local enterFrameHandle  = nil
    local paddingTop        = display.height / 8
    local paddingBottom     = paddingTop

    local validTouchTop     = 0
    local validTouchBottom  = 0
    local validTouchHeight  = 0

    ----

    local function snapLayer(isAutoScroll)
        local ny = layer.y
        if layer.y < layer.minY then
            ny = layer.minY
        elseif layer.y > layer.maxY then
            ny = layer.maxY
        end

        if layer.y ~= ny then
            local time = math.abs(layer.y - ny) / SCROLL_TO_VALID_RANGE_SPEED
            local easing = "backOut"
            if isAutoScroll then easing = {"inOut", 2} end
            transition.moveTo(layer, {y = ny, time = time, easing = easing})
        end
    end

    local function onEnterFrame(dt)
        frameTime = frameTime + dt
        if not swiping then return end

        local moving = swiping.speed * dt
        if swiping.direction then
            -- up
            layer.y = layer.y - moving
        else
            -- down
            layer.y = layer.y + moving
        end
        if moving < 1 then
            swiping = nil
            snapLayer(true)
        elseif layer.y < layer.minY or layer.y > layer.maxY then
            swiping.speed = swiping.speed * 0.5;
        else
            swiping.speed = swiping.speed * 0.9;
        end
    end

    local function onTouch(event, x, y)
        if event == CCTOUCHBEGAN then
            if y > validTouchTop or y < validTouchBottom then return false end

            touch = {
                initTouchY      = y,
                initLayerY      = layer.y,
                isMaybeTap      = (swiping == nil), -- 如果触摸开始时视图尚在自动卷动，则不考虑 tap 事件
                lastTouchTime   = frameTime,
                lastTouchY      = y,
                isMaybySwiping  = false,
                swipingBeganTime= 0,
                swipingBeganY   = 0
            }
            swiping = nil -- 一旦开始触摸，立即停止当前的自动卷动
            return true
        end

        if event == CCTOUCHMOVED then
            if touch.lastTouchY == y then
                -- 如果两次触摸事件之间，坐标没有变化，则取消轻扫状态
                touch.isMaybySwiping = false
            else
                -- 如果当前处于轻扫状态，但本次事件距离上次事件的间隔时间超过一定范围，则取消轻扫状态
                if touch.isMaybySwiping then
                    if frameTime - touch.lastTouchTime > 0.034 then
                        touch.isMaybySwiping = false
                    end
                else
                    touch.isMaybySwiping   = true
                    touch.swipingBeganTime = frameTime
                    touch.swipingBeganY    = y
                end
            end

            touch.lastTouchY = y
            touch.lastTouchTime = frameTime

            if touch.isMaybeTap and math.abs(y - touch.initTouchY) >= 10 then
                -- 触摸移动范围超过 10 点，则不再视为 tap 操作
                touch.isMaybeTap = false
            end

            if not touch.isMaybeTap then
                local ny = touch.initLayerY + (y - touch.initTouchY)
                if ny < layer.minY - validTouchHeight / 2 then
                    ny = layer.minY - validTouchHeight / 2
                end
                if ny > layer.maxY + validTouchHeight / 2 then
                    ny = layer.maxY + validTouchHeight / 2
                end
                layer.y = ny
            end

            return true
        end

        if event == CCTOUCHENDED and touch.isMaybeTap then
            -- tap 事件，确定触发哪一个条目的 listener
            local offset = view.y + layer.y
            for i = 1, #view.items do
                local item = view.items[i]
                if y <= offset and y >= offset - item.itemHeight + 1 then
                    if type(item.onItemTap) == "function" then
                        item:onItemTap(view, i)
                    end
                    break
                end
                offset = offset - item.itemHeight
            end

            return false
        end

        if layer.y <= layer.minY or layer.y >= layer.maxY then
            snapLayer()
        elseif touch.isMaybySwiping then
            -- 根据一定时间范围内手指的滑动速度计算惯性
            local time = frameTime - touch.swipingBeganTime
            if time > 0 then
                local offset = y - touch.swipingBeganY
                local speed = math.abs(offset) / time
                swiping = {speed = speed, direction = offset < 0} -- true = up, false = down
            end
        end

        return false
    end

    function setSumHeight()
        -- 计算列表的总高度，并依次排列所有条目
        sumHeight = 0
        for i = 1, #view.items do
            local item = view.items[i]
            item.y = -sumHeight
            sumHeight = sumHeight + item.itemHeight
        end

        -- 计算条目层的 y 值有效范围
        layer.minY = 0
        layer.maxY = sumHeight - validTouchHeight + 1
    end

    local function init()
        local keys = {marginTop = "number", marginBottom = "number"}
        for k, t in pairs(keys) do
            if type(args[k]) == t then view[k] = args[k] end
        end

        layer = display.newGroup()
        view:addChild(layer)

        validTouchTop    = display.height - view.marginTop - 1
        validTouchBottom = view.marginBottom
        validTouchHeight = validTouchTop - validTouchBottom + 1

        setSumHeight()
    end

    ----

    function view:addItem(item)
        item.y = sumHeight
        layer:addChild(item)
        self.items[#self.items + 1] = item
        setSumHeight()
    end

    -- 滚动到指定的条目，确保该条目完整显示在屏幕上
    function view:scrollToItem(itemIndex)
        if itemIndex < 1 or itemIndex > #self.items then return end

        setSumHeight()

        local top    = 0
        local bottom = 0
        for i = 1, #self.items do
            if i == itemIndex then
                bottom = top - self.items[i].itemHeight
                break
            else
                top = top - self.items[i].itemHeight
            end
        end

        local y = -layer.y
        if top <= y and bottom >= y - validTouchHeight then return end
        if bottom < y - validTouchHeight then
            -- 如果是条目底部不在有效区，则向上滚动
            transition.moveTo(layer, {y = -bottom - validTouchHeight, time = 0.2})
        else
            -- 如果是条目顶部不在有效区，则向下滚动
            transition.moveTo(layer, {y = -top, time = 0.2})
        end
    end

    function view:enable()
        if enterFrameHandle then return end
        self:addTouchEventListener(onTouch)
        enterFrameHandle = scheduler.enterFrame(onEnterFrame)
    end

    function view:disable()
        self:removeTouchEventListener()
        scheduler.remove(enterFrameHandle)
    end

    ----

    init()
    return view
end
