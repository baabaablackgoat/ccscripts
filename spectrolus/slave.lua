local modem = peripheral.find("modem")
local channel = 3841 -- random number
local listeningTo = 0 -- set differently for every computer
modem.open(channel)

term.clear()
term.setCursorPos(1,1)
print("=== Botania Spectrolus Slave ===")
print("Listening for "..listeningTo.."@"..channel)

local function pulseSignal()
	local pulseWidth = 1
	local side = "top"
	redstone.setOutput(side, true)
	os.sleep(pulseWidth)
	redstone.setOutput(side, false)
end

while true do
	local event, side, freq, rfreq, msg, dist = os.pullEvent("modem_message")
	if msg == listeningTo then
		print("Recieved "..msg..". Pulsing...")
		pulseSignal()
	end
end