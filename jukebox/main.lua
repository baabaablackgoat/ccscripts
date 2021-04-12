local mon = peripheral.wrap("top")

local disks = {}
local playing = nil
local stopLine = 17

local function scanDisks()
	for i=0,12 do
		disks[i] = disk.getAudioTitle("drive_"..i)
	end
end 

local function lineToDiskNo(y)
	return y - 3
end

local function diskToLineNo(i)
	return i + 3
end

local function writeTitle(i, active)
	active = active or false
	if disks[i] then
		if active then
			mon.write("> "..disks[i])
		else
			mon.write("- "..disks[i])
		end
	else 
		mon.write("[NO DISK]")
	end
end

local function defaultCol()
	mon.setTextColor(1)
	mon.setBackgroundColor(32768)
end

local function highlightCol()
	mon.setTextColor(32768)
	mon.setBackgroundColor(4)
end

local function stfuCol()
	mon.setTextColor(16384)
	mon.setBackgroundColor(32768)
end

local function fullRewrite()
	mon.clear()
	defaultCol()
	mon.setCursorPos(1,1)
	mon.write("Hi am jukebox pls click thamk")
	for i=0,12 do
		mon.setCursorPos(1,diskToLineNo(i))
		writeTitle(i)
	end
	stfuCol()
	mon.setCursorPos(1, stopLine)
	mon.write("Shut the fuck up richard")
end

local function stopPlaying(i)
	disk.stopAudio("drive_"..i)
	mon.setCursorPos(1,diskToLineNo(i))
	mon.clearLine()
	defaultCol()
	writeTitle(i)
end

local function startPlaying(i)
	disk.playAudio("drive_"..i)
	playing = i
	mon.setCursorPos(1, diskToLineNo(i))
	mon.clearLine()
	highlightCol()
	writeTitle(i, true)
	defaultCol()
end


-- Setting up
scanDisks()
fullRewrite()

-- Main logic loop
while true do
	local event, p1, p2, p3, p4, p5 = os.pullEvent()
	if event == "monitor_touch" then 
		local x = p2
		local y = p3
		if disks[lineToDiskNo(y)] then
			if playing then stopPlaying(playing) end
			startPlaying(lineToDiskNo(y))
		elseif y == stopLine then
			stopPlaying(playing)
		end
	end
	if event == "disk" or event == "diskEject" then scanDisks() end
end
