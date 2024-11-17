local speaker = peripheral.find("speaker")
local screenWidth, screenHeight = term.getSize()
local middleWidth, middleHeight = screenWidth / 2, screenHeight / 2
local nowPlaying = ""
local currentListIndex = 1

local allSongs = {
    ["5"] = "minecraft:music_disc.5",
    ["11"] = "minecraft:music_disc.11",
    ["13"] = "minecraft:music_disc.13",
    ["blocks"] = "minecraft:music_disc.blocks",
    ["cat"] = "minecraft:music_disc.cat",
    ["chirp"] = "minecraft:music_disc.chirp",
    ["far"] = "minecraft:music_disc.far",
    ["mall"] = "minecraft:music_disc.mall",
    ["mellohi"] = "minecraft:music_disc.mellohi",
    ["otherside"] = "minecraft:music_disc.otherside",
    ["pigstep"] = "minecraft:music_disc.pigstep",
    ["stal"] = "minecraft:music_disc.stal",
    ["strad"] = "minecraft:music_disc.strad",
    ["wait"] = "minecraft:music_disc.wait",
    ["ward"] = "minecraft:music_disc.ward",
    ["endseeker"] = "betterend:betterend.record.endseeker",
    ["eo dracona"] = "betterend:betterend.record.eo_dracona",
    ["grasping at stars"] = "betterend:betterend.record.grasping_at_stars",
    ["strange and alien"] = "betterend:betterend.record.strange_and_alien"
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
    term.setCursorPos(1, screenHeight - 1)
    term.setBackgroundColor(colors.gray)
    term.write("Playing: "..nowPlaying.."                                                   ")
    term.setCursorPos(middleWidth - 6, screenHeight)
    term.setTextColor((canScrollUp() and colors.white or colors.black))
    term.write(" ^ ")
    term.setCursorPos(middleWidth + 3, screenHeight)
    term.setTextColor((canScrollDown() and colors.white or colors.black))
    term.write(" V ")
    term.setCursorPos(middleWidth - 3, screenHeight)
    term.setBackgroundColor(colors.red)
    term.setTextColor(colors.white)
    term.write(" STOP ")
    resetColors()
end

function printSongs(startIndex)
    local index = 1
    for k, v in pairs(allSongs) do
        if index >= startIndex and (index - startIndex) <= screenHeight - 2 then
            term.setCursorPos(1, index - startIndex + 1)
            term.write(k)
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
    return (currentListIndex + screenHeight - 2 <= totalSongCount)
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
    if y == screenHeight - 1 then return end -- now playing row
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
        if rowIndex + (currentListIndex - 1) == iterIndex then
            return k, v
        end
        iterIndex = iterIndex + 1
    end
    return nil, nil
end

while true do
    term.clear()
    printSongs(currentListIndex)
    printControls()
    printQueuedDebugSymbol()
    local event, button, x, y = os.pullEvent("mouse_click")
    interpretMouseClick(button, x, y)
end
