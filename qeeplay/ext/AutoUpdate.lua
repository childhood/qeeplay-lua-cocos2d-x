
module("AutoUpdate", package.seeall)

---- 通用远程数据更新模块

-- 远程服务器地址
-- local BASE_URL = "http://updates.qeeplay.com"
local BASE_URL = "http://localhost/~dualface/qeeplay-site/updates"
-- 索引文件名
local INDEX_FILENAME = "index.php"

local listener = nil
local modulesName = nil
local autoUpdate = nil
local downloadsQueue = nil
local filesDownloadQueue = nil
local allUpdateIsSucceed = true
local numModulesUpdated = 0
local numModulesNeedUpdate = 0

-- 验证游戏状态数据中的 autoUpdate 部分
local function validateAutoUpdateData()
    if type(autoUpdate) ~= "table" then autoUpdate = {} end

    if type(autoUpdate.lastCheckDate) ~= "number" then
        autoUpdate.lastCheckDate = 0
    end
    if type(autoUpdate.modules) ~= "table" then
        autoUpdate.modules = {}
    end

    for i = 1, #modulesName do
        local moduleName = modulesName[i]
        if type(autoUpdate.modules[moduleName]) ~= "table" then
            autoUpdate.modules[moduleName] = {}
        end
        local moduleData = autoUpdate.modules[moduleName]
        if type(moduleData.version) ~= "number" then
            moduleData.version = 0
        end
    end
end

-- 更新 autoUpdate 状态
local function allDone()
    if allUpdateIsSucceed then
        autoUpdate.lastCheckDate = tonumber(os.date("%Y%m%d"))
        log.warning("# [AUTOUPDATE] COMPLETED, ALL DONE")
    else
        log.warning("# [AUTOUPDATE] COMPLETED, HAS SOME PROBLEM")
    end
    validateAutoUpdateData()
    gameState.autoUpdate = autoUpdate
    exGameState.save()
end

-- 通知回调函数
local function noticeListener(moduleName, version, dataset, files)
    if listener(moduleName, version, dataset, files) == true then
        autoUpdate.modules[moduleName].version = version
        log.warning("# [AUTOUPDATE] MODULE '%s' UPDATED TO VERSION '%s'", moduleName, version)
    else
        allUpdateIsSucceed = false
        log.warning("# [AUTOUPDATE] MODULE '%s' UPDATE FAILED", moduleName)
    end

    numModulesUpdated = numModulesUpdated + 1
    if numModulesUpdated == numModulesNeedUpdate then
        allDone()
    end
end

-- 下载模块的文件完成
local function onDownloadFileCompleted(event)
    local path = event.response
    local moduleName, filename, filesize, destpath = unpack(filesDownloadQueue.files[path])
    local info = filesDownloadQueue.modules[moduleName]
    filesDownloadQueue.files[path] = nil

    while true do
        if event.isError then
            log.warning("# [AUTOUPDATE] MODULE '%s' REMOTE FILE '%s' DOWNLOAD FAILED",
                        moduleName, filename)
            break
        end

        if io.filesize(path) ~= filesize then
            log.warning("# [AUTOUPDATE] MODULE '%s' REMOTE FILE '%s' SIZE INVALID",
                        moduleName, filename)
            break
        end

        log.warning("# [AUTOUPDATE] MODULE '%s' REMOTE FILE '%s' OK",
                    moduleName, filename)

        if os.rename(path, destpath) then
            info.succeedDownloadsCount = info.succeedDownloadsCount + 1
        end
        break
    end

    if info.succeedDownloadsCount == info.downloadsCount then
        noticeListener(moduleName, info.version, info.dataset, info.filenames)
        filesDownloadQueue.modules[moduleName] = nil
    end
end

-- 下载指定模块的远程文件
local function downloadModuleFiles(moduleName, version, dataset, remoteFiles)
    -- 记录下该模块的信息，当所有文件下载完成后通知回调函数
    filesDownloadQueue.modules[moduleName] = {
        numFiles = table.nums(remoteFiles),
        version = version,
        dataset = dataset,
        filenames = {},
        downloadsCount = 0,
        succeedDownloadsCount = 0,
    }
    local filenames = filesDownloadQueue.modules[moduleName].filenames
    local queue = filesDownloadQueue.files
    local info = filesDownloadQueue.modules[moduleName]

    for k, fileinfo in pairs(remoteFiles) do
        local filename = fileinfo.filename
        local filesize = tonumber(fileinfo.size)
        filenames[#filenames + 1] = filename

        local destpath = system.pathForFile(filename, system.DocumentsDirectory)
        if io.exists(destpath) and io.filesize(destpath) == filesize then
            -- 如果目标目标文件已经存在，则跳过下载步骤
            log.warning("# [AUTOUPDATE] MODULE '%s' REMOTE FILE '%s' EXISTS",
                        moduleName, filename)
        else
            local url = string.format("%s/files/%s", BASE_URL, filename)
            local savepath = system.pathForFile(filename, system.TemporaryDirectory)

            queue[savepath] = {moduleName, filename, filesize, destpath}
            info.downloadsCount = info.downloadsCount + 1

            os.remove(savepath)
            network.download(url,
                             "GET",
                             onDownloadFileCompleted,
                             filename,
                             system.TemporaryDirectory)
        end
    end

    if info.downloadsCount == 0 then
        -- 没有下载任何文件，直接通知回调函数
        noticeListener(moduleName, version, dataset, filenames)
        filesDownloadQueue.modules[moduleName] = nil
    end
end

-- 检查并更新模块数据
local function checkAndUpdateModuleData(moduleName, remoteData, remoteVersion)
    -- 检查远程数据版本号是否匹配
    if tostring(remoteData.version) ~= tostring(remoteVersion) then
        log.warning("# [AUTOUPDATE] MODULE '%s' VERSION INVALID", moduleName)
        return
    end

    if type(remoteData.dataset) ~= "table" then
        log.warning("# [AUTOUPDATE] MODULE '%s' DATASET NOT DEFINED", moduleName)
        return
    end

    if type(remoteData.files) == "table" and table.nums(remoteData.files) > 0 then
        -- 如果 remoteData 中包含 files 部分，则尝试下载所有远程文件
        -- 当所有远程文件下载成功后，才通知调用者
        downloadModuleFiles(moduleName, remoteVersion, remoteData.dataset, remoteData.files)
    else
        noticeListener(moduleName, remoteVersion, remoteData.dataset)
    end
end

-- 下载模块数据完成
local function onDownloadModuleCompleted(event)
    while true do
        local savepath = event.response
        local moduleName, remoteVersion = unpack(downloadsQueue[savepath])
        downloadsQueue[savepath] = nil

        if event.isError then
            log.warning("# [AUTOUPDATE] MODULE '%s' DOWNLOAD FAILED", moduleName)
            break
        end

        log.warning("# [AUTOUPDATE] MODULE '%s' DOWNLOAD COMPLETED", moduleName)
        local remoteData = json.decode(io.readfile(savepath))
        os.remove(savepath)

        if type(remoteData) ~= "table" then
            log.warning("# [AUTOUPDATE] MODULE '%s' DATA INVALID", moduleName)
            break
        end
        log.warning("# [AUTOUPDATE] MODULE '%s' DATA OK", moduleName)

        checkAndUpdateModuleData(moduleName, remoteData, remoteVersion)
        break
    end
end

-- 下载某个模块的数据文件，并保存到临时目录
local function downloadModule(moduleName, remoteVersion)
    local query = string.format("%s/module_%s.php?channel=%s&v=%s",
                                BASE_URL,
                                moduleName,
                                device.platform,
                                remoteVersion)
    local filename = string.format("module_%s_%s.txt", moduleName, remoteVersion)
    -- local savepath = system.pathForFile(filename, system.TemporaryDirectory)
    -- downloadsQueue[savepath] = {moduleName, remoteVersion}
    -- numModulesNeedUpdate = numModulesNeedUpdate + 1

    log.warning("# [AUTOUPDATE] MODULE '%s' DOWNLOAD DATA FROM '%s'", moduleName, query)
    -- network.download(query, "GET", onDownloadModuleCompleted, filename, system.TemporaryDirectory)
end

-- 检查更新
local function onCheckUpdateCompleted(ok, code, headers, response)
    if not ok then
        log.warning("# [AUTOUPDATE] INDEX QUERY FAILED, %s", code)
        return
    end

    local remoteData = json.decode(response)
    if type(remoteData) ~= "table" then
        log.warning("# [AUTOUPDATE] INDEX DATA ERROR")
        log.warning("# [AUTOUPDATE] EXIT")
        return
    end

    local downloadsCount = 0
    for moduleName, remoteVersion in pairs(remoteData) do
        remoteVersion = tonumber(remoteVersion)

        while true do
            if type(autoUpdate.modules[moduleName]) ~= "table" then
                log.warning("# [AUTOUPDATE] MODULE '%s (%s)' NOT DEFINED",
                            moduleName,
                            remoteVersion)
                break
            end

            local moduleData = autoUpdate.modules[moduleName]
            if moduleData.version >= remoteVersion then
                log.warning("# [AUTOUPDATE] MODULE '%s (%s)' UPDATED",
                            moduleName,
                            remoteVersion)
                break
            end

            downloadsCount = downloadsCount + 1
            downloadModule(moduleName, remoteVersion)
            break
        end
    end

    if downloadsCount == 0 then
        -- 没有任何模块需要更新
        log.warning("# [AUTOUPDATE] NO UPDATES")
        allDone()
    end
end

----


--[[

初始化远程更新

- modules: 指定要查询的模块
- onUpdatedListener: 回调函数


local function onUpdatedListener(moduleName, version, dataset, files)
    -- 如果成功处理了这个模块的更新，则应该返回 true，以便 exAutoUpdate 更新该的本地版本号
    return true
end

local modulesName = {"more", "levels"}
exAutoUpdate.init(modulesName, listener)

--]]
function init(modulesName_, listener_)
    modulesName = clone(modulesName_)
    listener = listener_
    downloadsQueue = {}
    filesDownloadQueue = {modules = {}, files = {}}

    log.warning("# [AUTOUPDATE] INIT")

    autoUpdate = gameState.autoUpdate
    validateAutoUpdateData()
    gameState.autoUpdate = autoUpdate

    -- 如果当天已经检查过远程数据版本，则不再检查
    local today = tonumber(os.date("%Y%m%d"))
    if autoUpdate.lastCheckDate >= today then
        -- 每天只检查一次
        log.warning("# [AUTOUPDATE] LAST CHECK IS TODAY")
        log.warning("# [AUTOUPDATE] EXIT")
        return
    end

    local query = string.format("%s/%s?channel=%s&r=%s",
                                BASE_URL,
                                INDEX_FILENAME,
                                device.platform,
                                math.random())
    log.warning("# [AUTOUPDATE] QUERY: %s", query)

    local params = {
        body = {
            app         = APP_NAME,
            black       = APP_BLACK_NAME,
            platform    = device.platform,
            model       = device.model,
            screen      = device.screenType,
            width       = device.screenWidth,
            height      = device.screenHeight,
            lang        = device.language
        }
    }
    network.request(query, "POST", onCheckUpdateCompleted, params)
end
