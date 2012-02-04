

_ = nil

module("localize", package.seeall)

---- localize 模块补充

local filename_localize_suffix = {
    cn = {suffix = "_cn"},
}
local dict = {}

-- 设置本地化查询的字典
function setDict(dict_)
    dict = dict_
end

-- 根据 device.language 查询文件名后缀
function suffix(lang)
    if lang == nil then lang = device.language end
    if type(filename_localize_suffix[lang]) ~= "table" then return "" end
    return filename_localize_suffix[lang].suffix
end

-- 根据 device.language 确定实际文件名
function filename(name)
    local pathinfo = io.pathinfo(name)
    return pathinfo.dirname..pathinfo.basename..suffix()..pathinfo.extname
end

-- 根据 device.language 查询翻译字符串
function text(source)
    if dict[device.language] then
        local result = dict[device.language][source]
        if result then return result end
    end

    if dict["en"] == nil then return source end
    if dict["en"][source] == nil then return source end
    return dict["en"][source]
end
_ = text
