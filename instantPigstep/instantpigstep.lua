fuckingThirtytwothousandSevenhundredSixtyEight = 32768

mon = peripheral.find("monitor")
mon.setTextScale(0.5)
mon.clear()
local line = "               "
local function drawPig(up, looking)
	--top line black if necessary
	mon.setBackgroundColor(fuckingThirtytwothousandSevenhundredSixtyEight)
	if not up then
		mon.setCursorPos(1,1)
		mon.write(line)
	end
	--pink lines
	mon.setBackgroundColor(64)
	local height = up and 1 or 2
	for i = height, height+8 do
		if up then
			mon.setCursorPos(1,i)
		else 
			mon.setCursorPos(1,i+1)
		end
		mon.write(line)
	end
	--bottom line black if necessary
	mon.setBackgroundColor(fuckingThirtytwothousandSevenhundredSixtyEight)
	if up then
		mon.setCursorPos(1,10)
		mon.write(line)
	end
	--snout
	mon.setBackgroundColor(4)
	height = up and 5 or 6
	for i=height,height+2 do
		mon.setCursorPos(5,i)
		mon.write("       ")
	end
	mon.setBackgroundColor(4096)
	mon.setCursorPos(5,height+1)
	mon.write(" ")
	mon.setCursorPos(11,height+1)
	mon.write(" ")

	-- eyes
	height = up and 4 or 5
	-- eyeballs
	local eyeball = "    "
	mon.setBackgroundColor(1)
	mon.setCursorPos(1, height)
	mon.write(eyeball)
	mon.setCursorPos(12, height)
	mon.write(eyeball)
	-- pupils
	local pupil = "  "
	mon.setBackgroundColor(fuckingThirtytwothousandSevenhundredSixtyEight)
	local leftPos = (looking == "right") and 3 or 1
	local rightPos = (looking == "left") and 12 or 14
	mon.setCursorPos(leftPos, height)
	mon.write(pupil)
	mon.setCursorPos(rightPos, height)
	mon.write(pupil)
end

local function drawPrompt()
	mon.setBackgroundColor(fuckingThirtytwothousandSevenhundredSixtyEight)
	mon.setTextColor(4)
	mon.clear()
	mon.setCursorPos(3,5)
	mon.write("touch me.")
end

-- disk.playAudio("bottom")

local playing = false
local startMovement = nil
local stopMovement = nil
local nextMovement = nil

local moves = {{true, "left"}, {false, "center"}, {true, "right"}, {false, "center"}}
local nextMove = 1
local function doNextMove()
	drawPig(moves[nextMove][1], moves[nextMove][2])
	nextMove = (nextMove + 1 > 4) and 1 or (nextMove + 1)
	nextMovement = os.startTimer(0.30)
end

drawPrompt()
while true do
	local event, p1, p2, p3, p4, p5 = os.pullEvent()
	if event == "monitor_touch" then
		if not playing then
			drawPig(true, "center")
			disk.playAudio("bottom")
			startMovement = os.startTimer(23)
			playing = true
		else
			startMovement, stopMovement, nextMovement = nil, nil, nil
			disk.stopAudio("bottom")
			drawPrompt()
			playing = false
		end
	elseif event == "timer" then
		if p1 == nextMovement then
			doNextMove()
		elseif p1 == startMovement then
			startMovement = nil
			stopMovement = os.startTimer(120)
			doNextMove()
		elseif p1 == stopMovement then
			stopMovement, nextMovement = nil, nil
			drawPrompt()
			playing = false
		end
	end
end
