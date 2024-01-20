local modem = peripheral.find("modem")
local speaker = peripheral.find("speaker")
local channel = 791
local label = os.computerLabel()

local lastReceivedSound = ""

modem.open(channel)
term.clear()

function resetColors()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

function updateStatus(text)
    term.setCursorPos(1,3)
    term.setTextColor(colors.lightGray)
    term.write(string.format("%-90s", text))
    resetColors()
end

function updateError(text)
    term.setCursorPos(1,4)
    term.setTextColor(colors.red)
    term.write(string.format("%-90s", text))
    resetColors()
end

function setHeader(text)
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.white)
    term.setCursorPos(1,1)
    term.write(string.format("%-90s", text))
    resetColors()
end

function tryPlayingSound()
	speaker.playSound(lastReceivedSound, 3)
end


setHeader("Sound Receiver - listening on "..channel)
while true do
	local event, side, freq, replyFreq, msg, dist = os.pullEvent("modem_message")
	if (msg == "!stop") then
		updateStatus("Sounds stopped")
		speaker.stop()
		modem.transmit(replyFreq, freq, "Stopped sound on "..label)
	else
		lastReceivedSound = msg
		updateStatus("Playing "..lastReceivedSound)
		local safe, err = pcall(tryPlayingSound)
    	if safe then 
			modem.transmit(replyFreq, freq, "Sound "..lastReceivedSound.." started on "..label)
		else
			modem.transmit(replyFreq, freq, "Sound failed on "..label..": "..err)
			updateError(err)
		end
	end
end