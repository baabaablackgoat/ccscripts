local m = peripheral.find("modem")
m.open(1)

local clutchSide = "left"
local gearshiftSide = "right" -- on = down

function ident()
	local linkType = "controller"
	local linkLevel = nil
	m.transmit(2,1,{linkType,linkLevel})
	print("sent ident")
end

ident() -- run once on startup

while true do
	local event, e1, e2, e3, e4, e5 = os.pullEvent() -- side freq rFreq msg dist
	if event == "modem_message" then
		if e4 == "ident" then -- yes I know this is cursed af
			ident()
		elseif e4 == "up" then
			redstone.setOutput(gearshiftSide, false)
		elseif e4 == "down" then
			redstone.setOutput(gearshiftSide, true)
		elseif e4 == "stop" then
			redstone.setOutput(clutchSide, true)
		elseif e4 == "go" then
			redstone.setOutput(clutchSide, false)
		end
	end
end