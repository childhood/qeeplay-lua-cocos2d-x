
module("device", package.seeall)

local director = CCDirector:sharedDirector()

----
host = "ios"
model = "iphone"
platform = "ios"


-- landscape, landscape_right
-- landscape_left
-- portrait
-- upside_down
orientationPortrait = "portrait"
orientationUpsideDown = "upside_down"
orientationLandscapeLeft = "landscape_left"
orientationLandscapeRight = "landscape_right"

if DEVICE_ORIENTATION then
    orientation = string.lower(DEVICE_ORIENTATION)
    if orientation == "landscape"
       or orientation == "landscape_right"
       or orientation == "landscaperight" then
        orientation = orientationLandscapeRight
    elseif orientation == "landscape_left" or orientation == "landscapeleft" then
        orientation = orientationLandscapeLeft
    elseif orientation == "upside_down" or orientation == "upsidedown" then
        orientation = orientationUpsideDown
    else
        orientation = orientationPortrait
    end
else
    orientation = director:getDeviceOrientation()
    if orientation == kCCDeviceOrientationLandscapeLeft then
        orientation = orientationLandscapeLeft
    elseif orientation == kCCDeviceOrientationLandscapeRight then
        orientation = orientationLandscapeRight
    elseif orientation == kCCDeviceOrientationPortraitUpsideDown then
        orientation = orientationUpsideDown
    else
        orientation = orientationPortrait
    end
end


----
local winSizeInPixels = director:getWinSizeInPixels()
screenWidth = winSizeInPixels.width
screenHeight = winSizeInPixels.height
isRetinaDisplay = director:isRetinaDisplay()
scaleFactor = director:getContentScaleFactor()

screenType = "iphone"
if isRetinaDisplay then
    screenType = "iphonehd"
else
    if orientation == orientationLandscapeLeft or orientation == orientationLandscapeRight then
        if screenWidth == 1024 then
            screenType = "ipad"
        end
    else
        if screenWidth == 769 then
            screenType = "ipad"
        end
    end
end


----
local _language = CCApplication:getCurrentLanguage()
if _language == kLanguageChinese then
    language = "cn"
elseif _language == kLanguageFrench then
    language = "fr"
elseif _language == kLanguageItalian then
    language = "it"
elseif _language == kLanguageGerman then
    language = "gr"
elseif _language == kLanguageSpanish then
    language = "sp"
elseif _language == kLanguageRussian then
    language = "ru"
else
    language = "en"
end

writeablePath = CCFileUtils:getWriteablePath()


----
log.warning("# device.host                  = "..host)
log.warning("# device.model                 = "..model)
log.warning("# device.platform              = "..platform)
log.warning("# device.isRetinaDisplay       = "..tostring(isRetinaDisplay))
log.warning("# device.screenType            = "..screenType)
log.warning("# device.screenWidth           = "..screenWidth)
log.warning("# device.screenHeight          = "..screenHeight)
log.warning("# device.scaleFactor           = "..scaleFactor)
log.warning("# device.orientation           = "..orientation)
log.warning("# device.language              = "..language)
log.warning("#")
