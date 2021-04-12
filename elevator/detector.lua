local linkLevel = 0
-- local linkName = "Basement" use this line at best for self ident

local m = peripheral.find("modem")
m.open(1)

local linkType = "detector"

function sendSignal()
	m.transmit(3,1,"i"..tostring(linkLevel))
	print("Sent signal")
end

function ident() -- ident also checks if the platform is currently stopped here.
	m.transmit(2,1,{linkType, linkLevel})
	print("sent ident")
	if redDetect() then sendSignal() end
end

function redDetect()
	for _,side in pairs(redstone.getSides()) do
		if redstone.getInput(side) then return true end
	end
	return false
end

ident() -- run ident on startup once

while true do
	local event, e1, e2, e3, e4, e5 = os.pullEvent() -- side freq rFreq msg dist
	if event == "modem_message" and e4 == "ident" then ident() end
	if event == "redstone" then
		if redDetect() then sendSignal() end
	end
end