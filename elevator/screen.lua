local linkLevel = 0
local linkName = "Basement"

local m = peripheral.find("modem")
m.open(1)
m.open(3)

local s = peripheral.find("monitor")
s.setBackgroundColor(32678)
s.clear()

local curFloor = nil
local levels = {}
local sorted_levels = {}
local linkType = "screen"

function tableLength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function specialSorter(a,b) -- this is dumb af
	return a[2] > b[2]
end

function sortLevels()
	sorted_levels = {}
	for k,v in pairs(levels) do table.insert(sorted_levels, {k,v[2]}) end
	table.sort(sorted_levels, specialSorter)
	print("Sorted "..tableLength(sorted_levels).." levels")
end

function ident()
	m.transmit(2,1,{linkType, linkLevel, linkName})
	print("sent ident")
end

ident() -- run once on startup

function updateScreen()
	s.clear()
	local lineNum = 1
	for _,v in ipairs(sorted_levels) do
		local tempLevel = levels[v[1]]
		s.setCursorPos(1,lineNum)
		s.setBackgroundColor(colors.black)
		s.setTextColor(colors.white)
		if tempLevel ~= nil then
			if curFloor == tempLevel[2] then s.setBackgroundColor(colors.green) end
			if linkLevel == tempLevel[2] then s.setTextColor(colors.orange) end
			s.write(tempLevel[3])
			lineNum = lineNum + 1
		end
	end
end



while true do
	local event, e1, e2, e3, e4, e5 = os.pullEvent() -- side freq rFreq msg dist
	if event == "modem_message" then
		if e2 == 1 then -- listening to controls
			if e4 == "ident" then
				ident()
			elseif type(e4) == "table" then
				print("recieved floor list")
				levels = e4
				sortLevels()
				updateScreen()
			end
		elseif e2 == 3 and string.sub(e4,1,1) == "i" then
			curFloor = tonumber(string.sub(e4,2))
			updateScreen()
		end
	elseif event == "monitor_touch" then
		if sorted_levels[e3] ~= nil then
			local msg = "s"..levels[sorted_levels[e3][1]][2]
			print("Sending "..msg)
			m.transmit(3, 1, msg)
		end
	end
end