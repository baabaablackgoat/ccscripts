local modem = peripheral.find("modem")
local channel = 3841 -- random number
local curSignal = 0
local dropDelay = 5

term.clear()
term.setCursorPos(1,1)
print("=== Botania Spectrolus Master ===")
print("Sending on "..channel)

local function sendNext()
	print("Sending "..curSignal)
	modem.transmit(channel, channel, curSignal)
	curSignal = curSignal + 1
	if curSignal > 15 then curSignal = 0 end
end

while true do
	if redstone.getInput("front") then
		sendNext()
	end
	os.sleep(dropDelay)
end