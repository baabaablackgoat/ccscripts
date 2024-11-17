local speaker = peripheral.find("speaker")
local screenWidth, screenHeight = term.getSize()
local middleWidth, middleHeight = screenWidth / 2, screenHeight / 2
local nowPlaying = ""
local currentListIndex = 1

local allSongs = {
    ["5 - Samuel Åberg"] = "minecraft:music_disc.5",
    ["11 - C418"] = "minecraft:music_disc.11",
    ["13 - C418"] = "minecraft:music_disc.13",
    ["blocks - C418"] = "minecraft:music_disc.blocks",
    ["cat - C418"] = "minecraft:music_disc.cat",
    ["chirp - C418"] = "minecraft:music_disc.chirp",
    ["far - C418"] = "minecraft:music_disc.far",
    ["mall - C418"] = "minecraft:music_disc.mall",
    ["mellohi - C418"] = "minecraft:music_disc.mellohi",
    ["Otherside - Lena Raine"] = "minecraft:music_disc.otherside",
    ["pigstep - Lena Raine"] = "minecraft:music_disc.pigstep",
    ["stal - C418"] = "minecraft:music_disc.stal",
    ["strad - C418"] = "minecraft:music_disc.strad",
    ["wait - C418"] = "minecraft:music_disc.wait",
    ["ward - C418"] = "minecraft:music_disc.ward",
    ["Endseeker - Firel (Better End)"] = "betterend:betterend.record.endseeker",
    ["Eo Dracona - Firel (Better End)"] = "betterend:betterend.record.eo_dracona",
    ["Grasping At Stars - Firel (Better End)"] = "betterend:betterend.record.grasping_at_stars",
    ["Strange And Alien - Firel (Better End)"] = "betterend:betterend.record.strange_and_alien",
    ["Endure Emptiness - Kain Vinosec (Botania)"] = "botania:music.gaia1",
    ["Fight For Quiescence - Kain Vinosec (Botania)"] = "botania:music.gaia2",
    ["Creepy (Dimensional Doors)"] = "dimdoors:creepy",
    ["White Void (Dimensional Doors)"] = "dimdoors:white_void",
    ["Incarnated Evil - Rotch Gwylt (The Graveyard)"] = "graveyard:entity.lich.theme_01",
    ["Spectrum Theme (Spectrum)"] = "spectrum:music.spectrum_theme",
    ["Irrelevance Fading - Radiarc (Spectrum)"] = "spectrum:music.boss_theme",
    ["Everreflective - Proper Motions (Spectrum)"] = "spectrum:music.divinity",
    ["Deeper Down (Spectrum)"] = "spectrum:music.deeper_down_theme",
    ["Radiance - Rotch Gwylt (Twilight Forest)"] = "twilightforest:music_disc.twilightforest.radiance",
    ["Steps - Rotch Gwylt (Twilight Forest)"] = "twilightforest:music_disc.twilightforest.steps",
    ["Superstitious - Rotch Gwylt (Twilight Forest)"] = "twilightforest:music_disc.twilightforest.superstitious",
    ["Home - MrCompost (Twilight Forest)"] = "twilightforest:music_disc.twilightforest.home",
    ["Wayfarer - MrCompost (Twilight Forest)"] = "twilightforest:music_disc.twilightforest.wayfarer",
    ["Findings - MrCompost (Twilight Forest)"] = "twilightforest:music_disc.twilightforest.findings",
    ["Maker - MrCompost (Twilight Forest)"] = "twilightforest:music_disc.twilightforest.maker",
    ["Thread - MrCompost (Twilight Forest)"] = "twilightforest:music_disc.twilightforest.thread",
    ["Motion - MrCompost (Twilight Forest)"] = "twilightforest:music_disc.twilightforest.motion",
    ["A Carol - STiiX (Snowy Spirit)"] = "snowyspirit:music.winter"
}
table.sort(allSongs)

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local totalSongCount = tablelength(allSongs)


  

function resetColors()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

function printControls()
    -- titlebar (has 1 line of space below)
    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.orange)
    term.setTextColor(colors.black)
    local titleSpacing = screenWidth / 2 - 8
    term.write(string.rep(" ", titleSpacing).."cool jukebox wow"..string.rep(" ", titleSpacing + 1))
    -- now playing bar (with one line of space)
    term.setCursorPos(1, screenHeight - 1)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.orange)
    term.write("\16 "..nowPlaying..string.rep(" ", screenWidth))
    -- controls bar
    term.setBackgroundColor(colors.gray)
    term.setCursorPos(middleWidth - 6, screenHeight)
    term.setTextColor((canScrollUp() and colors.white or colors.black))
    term.write(" \24 ")
    term.setCursorPos(middleWidth + 3, screenHeight)
    term.setTextColor((canScrollDown() and colors.white or colors.black))
    term.write(" \25 ")
    term.setCursorPos(middleWidth - 3, screenHeight)
    term.setBackgroundColor(colors.red)
    term.setTextColor(colors.white)
    term.write(" STOP ")
    resetColors()
end
local usedLines = 5
local firstLineOffset = 2

function printSongs(startIndex)
    local index = 1
    for k, v in pairs(allSongs) do
        if index >= startIndex and (index - startIndex) <= screenHeight - (usedLines + 1) then
            term.setCursorPos(1, index - startIndex + 1 + firstLineOffset)
            if (k == nowPlaying) then term.setTextColor(colors.orange) end
            term.write((k == nowPlaying and "\16 " or "  ") .. k)
            resetColors()
        end
        index = index + 1
    end
end

function stopSong()
    nowPlaying = ""
    speaker.stop()
end

function playSong(key, soundId)
    nowPlaying = key
    speaker.stop()
    os.sleep(0.1)
    speaker.playSound(soundId, 3, 1)
end

function canScrollUp()
    return (currentListIndex >= 2)
end

function canScrollDown()
    return (currentListIndex + screenHeight - usedLines <= totalSongCount)
end


function scrollUp()
    if (not canScrollUp()) then return end
    currentListIndex = currentListIndex - 1
end

function scrollDown()
    if (not canScrollDown()) then return end
    currentListIndex = currentListIndex + 1
end


local debugString = ""
function debugPrint(string)
    debugString = string
end

function printQueuedDebugSymbol()
    term.setCursorPos(middleWidth+6, screenHeight)
    term.write(debugString)
end

function interpretMouseClick(button, x, y)
    if button ~= 1 then return end
    if (y == screenHeight - 1 or y < 2) then return end -- display rows
    if y == screenHeight then
        if (x < middleWidth - 6 or x > middleWidth + 6) then return
        elseif (x > middleWidth - 6 and x < middleWidth - 3) then scrollUp() 
        elseif (x > middleWidth - 3 and x < middleWidth + 3) then stopSong()
        elseif (x > middleWidth + 3 and x < middleWidth + 6) then scrollDown()
        else return end
    else 
        key, soundId = getSongByIndex(y)
        if (key ~= nil and soundId ~= nil) then playSong(key, soundId) end
    end
end

function getSongByIndex(rowIndex)
    local iterIndex = 1
    for k, v in pairs(allSongs) do
        if (rowIndex - firstLineOffset) + (currentListIndex - 1) == iterIndex then
            return k, v
        end
        iterIndex = iterIndex + 1
    end
    return nil, nil
end

function interpretScroll(direction)
    if (direction == -1) then -- up
        if canScrollUp() then scrollUp() end
    elseif (direction == 1) then -- down
        if canScrollDown() then scrollDown() end
    else return end
end

while true do
    term.clear()
    printSongs(currentListIndex)
    printControls()
    printQueuedDebugSymbol()
    local event, a, b, c = os.pullEvent()
    if (event == "mouse_click") then interpretMouseClick(a, b, c)  -- button, x, y
    elseif (event == "mouse_scroll") then interpretScroll(a) -- direction, [x, y]
    else end
end
