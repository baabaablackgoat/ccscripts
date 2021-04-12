-- Who likes writing in this language?? SERIOUSLY; WHO?!
package.path = "./disk/?.lua;" .. package.path
local speaker = peripheral.find("speaker")
local instruments = {
	a = "bass",
	b = "bell",
	B = "basedrum",
	c = "chime",
	C = "cow_bell",
	d = "didgeridoo",
	f = "flute",
	g = "guitar",
	h = "harp",
	H = "hat",
	j = "banjo",
	p = "pling",
	s = "snare",
	x = "xylophone",
	v = "iron_xylophone", --vibraphone
	z = "bit"
}

local function splitIndicator(a)
	local output = {}
	for w in string.gmatch(a, "%a%d+") do
		table.insert(output, w)
	end
	return output
end

local function tableLength(a) -- how is this not a fucking default?
	local count = 0
	for _ in pairs(a) do count = count + 1 end
	return count
end

local function playSong()
	local notes = require 'musicdata'
	local notesSize = tableLength(notes)
	local position = 1 -- FUCK YOU LUA
	local waiting = 0

	local volume = {}
	for _, instr in ipairs(instruments) do -- why
		volume[instr] = 3
	end

	while true do
		if waiting > 1 then
			waiting = waiting - 1
		elseif position > notesSize then break -- exit loop
		else
			local note = notes[position]
			if type(note) == "number" then
				waiting = note
			elseif type(note) == "string" then
				local toPlay = splitIndicator(note)
				for _, a in ipairs(toPlay) do
					local instrument = instruments[string.sub(a, 1, 1)]
					local pitch = tonumber(string.sub(a,2,3))
					if string.len(a) == 4 then volume[instrument] = tonumber(string.sub(a,4,4)) end
					speaker.playNote(instrument, volume[instrument], pitch)
				end
			end
			position = position + 1
		end
		os.sleep(0.05) -- 1 tick = 1/20th of second
	end
end

while true do
    local event, p1, p2, p3 = os.pullEvent()
    if (event == 'redstone') then
        local side = p1
        playSong()
    elseif (event == 'disk') then
        local side = p1
        playSong()
    end
end