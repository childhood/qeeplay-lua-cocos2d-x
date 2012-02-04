
module("audio", package.seeall)

engine = SimpleAudioEngine:sharedEngine()

function preloadMusic(filename)
    engine:preloadBackgroundMusic(filename)
end

function playMusic(filename, isLoop)
    engine:playBackgroundMusic(filename, isLoop or true)
end

function playMusicList(filenames)

end

function stopMusic(isReleaseData)
    isReleaseData = isReleaseData or false
    engine:stopBackgroundMusic(isReleaseData)
end

function pauseMusic()
    engine:pauseBackgroundMusic()
end

function resumeMusic()
    engine:resumeBackgroundMusic()
end

function rewindMusic()
    ending:rewindBackgroundMusic()
end

function willPlayMusic()
    return engine:willPlayBackgroundMusic()
end

function isMusicPlaying()
    return engine:isBackgroundMusicPlaying()
end

function getMusicVolume()
    return engine:getBackgroundMusicVolume()
end

function setMusicVolume(volume)
    engine:setBackgroundMusicVolume(volume)
end

function getEffectsVolume()
    return engine:getEffectsVolume()
end

function setEffectsVolume(volume)
    engine:setEffectsVolume(volume)
end

function playEffect(filename, isLoop)
    return engine:playEffect(filename, isLoop or false)
end

function stopEffect(handle)
    engine:stopEffect(handle)
end

function preloadEffect(filename)
    engine:preloadEffect(filename)
end

function unloadEffect(filename)
    engine:unloadEffect(filename)
end

local handleFadeMusicVolumeTo = nil
function fadeMusicVolumeTo(time, volume)
    local currentVolume = getMusicVolume()
    if volume == currentVolume then return end

    if handleFadeMusicVolumeTo then
        scheduler.remove(handleFadeMusicVolumeTo)
    end
    local stepVolume = (volume - currentVolume) / time * (1.0 / 60)
    local isIncr     = volume > currentVolume

    local function changeVolumeStep()
        currentVolume = currentVolume + stepVolume
        if (isIncr and currentVolume >= volume)
           or (not isIncr and currentVolume <= volume) then
            currentVolume = volume
            scheduler.remove(handleFadeMusicVolumeTo)
        end
        setMusicVolume(currentVolume)
    end

    handleFadeMusicVolumeTo = scheduler.enterFrame(changeVolumeStep, false)
end

local handleFadeToMusic = nil
function fadeToMusic(music, time, volume)
    if handleFadeToMusic then scheduler.remove(handleFadeToMusic) end
    time = time / 2
    if type(volume) ~= "number" then volume = 1.0 end
    fadeMusicVolumeTo(volume, 0)
    handleFadeToMusic = scheduler.performWithDelay(time + 0.1, function()
        playMusic(music)
        fadeMusicVolumeTo(time, volume)
    end)
end


