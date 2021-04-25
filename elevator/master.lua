-- channel 1: sending to slaves
-- channel 2: ident messages
-- channel 3: info messages

local m = peripheral.find("modem")

m.open(2)
m.open(3)
m.transmit(1,2,"ident")

local connections = {}
local curFloor = nil
local targetFloor = nil

function tableLength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function sendAllFloors()
	local levels = {}
	for k,v in ipairs(connections) do
		if v[1] == "screen" then
			table.insert(levels,v)
		end
	end
	print("Transmitting "..tostring(tableLength(levels)).." floors")
	m.transmit(1,2,levels)
end

function printConnections()
	print("*** ALL CONNECTIONS ***")
	for k,v in ipairs(connections) do
		print(v[1], v[2], v[3])
	end
end

function isNotDupe(linkType, linkLevel)
	for k,v in pairs(connections) do
		if v[1] == linkType and v[2] == linkLevel then return false end
	end
	return true
end

function updateControl()
	if curFloor == nil then return end
	if targetFloor == nil and curFloor ~= nil then 
		targetFloor = curFloor
		return
	end
	if targetFloor > curFloor then
		m.transmit(1,2,"up")
		m.transmit(1,2,"go")
	elseif targetFloor < curFloor then
		m.transmit(1,2,"down")
		m.transmit(1,2,"go")
	else
		m.transmit(1,2,"stop")
		m.transmit(1,2,"chime_"..tostring(curFloor))
	end
end

function printState()
	print(tostring(curFloor)..">>"..tostring(targetFloor))
end

while true do
	local event, e1, e2, e3, e4, e5 = os.pullEvent() -- side freq rFreq msg dist
	if event == "modem_message" then
		if e2 == 2 then --ident messages
			local linkType = e4[1]
			local linkLevel = e4[2]
			local linkName = e4[3]
			if isNotDupe(linkType, linkLevel) then
				table.insert(connections,{linkType,linkLevel,linkName})
				sendAllFloors()
				printConnections()
			end
	
		elseif e2 == 3 then --informational messages
			-- control messages from screens should be "s#" with # as floor id
			-- info messages from sensors should be "i#" with # as floor id
			if string.sub(e4, 1, 1) == "s" then
				targetFloor = tonumber(string.sub(e4,2))
				printState()
			elseif string.sub(e4, 1, 1) == "i" then
				curFloor = tonumber(string.sub(e4,2))
				printState()
			end
			updateControl()
		end
	end
	if event == "redstone" then -- reset and send new ident
		connections = {}
		m.transmit(1,2,"ident")
	end
end