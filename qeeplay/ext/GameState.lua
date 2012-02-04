
module("GameState", package.seeall)

--[[

提供游戏状态读取和保存

- GameState.init() 初始化
- GameState.load() 读取游戏状态文件，返回一个包含游戏状态数据的数组
- GameState.save() 将指定数组的数据存入游戏状态文件

使用方法：

-- 定义游戏状态默认值
local defaults = {
    lastUnlockedLevel = 0,  -- 最后一个解锁的关卡
    numCoins = 1000,        -- 玩家的金币总数
}

local function callback(event, state)
end

GameState.init(defaults, callback)
local state = GameState.load()
GameState.save(state)

]]--

local stateData = {}
local defaults = {}
local keys = {}
local callback = nil
local stateFilename = "state.txt"

-- 确定游戏状态数据文件名
local function getGameStatePath()
    return io.pathForFile(stateFilename, device.writeablePath)
end

----

-- 初始化
function init(defaults_, callback_, stateFilename_)
    defaults = clone(defaults_)
    if type(defaults.version) ~= "number" then
        defaults.version = 1
    end

    keys = {}
    for k, v in pairs(defaults) do
        keys[#keys + 1] = k
    end

    callback = callback_
    if stateFilename_ then stateFilename = stateFilename_ end
end

-- 载入游戏状态
function load()
    local filename = getGameStatePath()
    local state = nil
    log.warning("LOAD GAME STATE:", filename)
    if io.exists(filename) then
        stateData = json.decode(io.readfile(filename))
    end

    if type(stateData) ~= "table" then
        log.warning("# [GAMESTATE] USE DEFAULTS")
        stateData = clone(defaults)
    else
        for i = 1, #keys do
            local key = keys[i]
            if type(stateData[key]) ~= type(defaults[key]) then
                stateData[key] = clone(defaults[key])
            end
        end
    end

    stateData = callback("load", stateData)
end

-- 保存游戏状态
function save(state)
    stateData = callback("save", state)

    local save = {}
    for i = 1, #keys do
        local key = keys[i]
        save[key] = clone(stateData[key])
    end

    local filename = getGameStatePath()
    log.warning("SAVE GAME STATE:", filename)
    return io.writefile(filename, json.encode(save))
end

function data()
    return stateData
end
