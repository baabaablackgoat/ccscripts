local modem = peripheral.find("modem")
local speaker = peripheral.find("speaker")
local channel = 791

modem.open(channel)
term.clear()
print("òwó - listening on "..channel)

while true do
	local event, side, freq, rfreq, msg, dist = os.pullEvent("modem_message")
	print("Attempting to play "..msg)
	speaker.playSound(msg)
end