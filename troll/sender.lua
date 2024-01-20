-- configuration
local channel = 791
local replyChannel = channel + 1

-- globals
local modem = peripheral.find("modem")
local speaker = peripheral.find("speaker")
local textInput = ""
local lastReceivedMessages = {}

-- button locations
local stopX = 1
local stopY = 5

local clearX = 6
local clearY = 5

-- helpers
function nilIsEmptyString(string)
    if (string == nil) then
        return ""
    else 
        return string
    end
end

-- "rendering"

function resetColors()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

function setHeader(text)
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.white)
    term.setCursorPos(1,1)
    term.write(string.format("%-90s", text))
    resetColors()
end

function makeButtons()
    -- stop button
    term.setBackgroundColor(colors.red)
    term.setTextColor(colors.white)
    term.setCursorPos(stopX, stopY)
    term.write("STOP")
    -- clear button
    term.setBackgroundColor(colors.lightBlue)
    term.setTextColor(colors.black)
    term.setCursorPos(clearX, clearY)
    term.write("Clear")
    -- finally, reset
    resetColors()
end

function updateTextInput()
    term.setCursorPos(1,3)
    term.write(string.format("> %-90s", textInput))
    resetColors()
end

function updateStatus(text)
    term.setCursorPos(1,7)
    term.setTextColor(colors.lightGray)
    term.write(string.format("%-90s", text))
    resetColors()
end

function updateError(text)
    term.setCursorPos(1,8)
    term.setTextColor(colors.red)
    term.write(string.format("%-90s", text))
    resetColors()
end

function updateModemMessages(text)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.lightGray)
    for i = 1, 5 do
        term.setCursorPos(1, 9 + i)
        term.write(string.format("%-90s", nilIsEmptyString(lastReceivedMessages[i])))
    end
    resetColors()
end

function resetScreen()
    resetColors()
    term.clear()
    setHeader("Sound sender - sending on "..channel)
    makeButtons()
    updateTextInput()
    updateStatus("Type a sound to be played")
end

-- actual behaviour stuff

function clearInput()
    textInput = ""
    updateTextInput()
end

function tryPlayingSound()
    if speaker then speaker.playSound(textInput, 3) end
end

function sendInternalSound()
    updateStatus("Transmitting "..textInput)
    modem.transmit(channel, replyChannel, textInput)
    local safe, err = pcall(tryPlayingSound)
    if not safe then updateError(err) end
    clearInput()
end

function stopSounds()
    updateStatus("Stopping sounds...")
    modem.transmit(channel, replyChannel, "!stop")
    if speaker then speaker.stop() end
end

function addAndTrimModemMessages(msg)
    table.insert(lastReceivedMessages, 1, msg) -- god I fucking hate 1-indexing
    table.remove(lastReceivedMessages, 6)
    updateModemMessages()
end



-- event handlers

function handleModemMessage(side, freq, replyFreq, msg, dist)
    addAndTrimModemMessages(msg)
end

function handleChar(char)
    textInput = textInput..char
    updateTextInput()
end

function handleSpecialKeys(key, keyHeld)
    local keyName = keys.getName(key)
    if (keyName == "backspace") then
        textInput = textInput:sub(1, -2)
        updateTextInput()
    elseif (keyName == "enter") then
        sendInternalSound()
    end
end

function handleClick(button, x, y)
    if (x >= stopX and x < stopX + 4 and y == stopY) then
        stopSounds()
    elseif (x >= clearX and x < clearX + 5 and y == clearY) then
        clearInput()
    end
end

function handlePaste(text)
    textInput = textInput..text
    updateTextInput()
end

-- await messages on the reply channel
modem.open(replyChannel)

resetScreen()

-- wire up event handlers
while true do
    local ev, arg1, arg2, arg3, arg4, arg5 = os.pullEvent()
    if (ev == "char") then
        handleChar(arg1)
    elseif (ev == "key") then
        handleSpecialKeys(arg1, arg2)
    elseif (ev == "modem_message") then
        handleModemMessage(arg1, arg2, arg3, arg4, arg5)
    elseif (ev == "mouse_click") then
        handleClick(arg1, arg2, arg3)
    elseif (ev == "paste") then
        handlePaste(arg1)
    end
end
