local width = 34 -- East X+ West X-
local height = 5 -- Y
local depth = 20 -- North Z- South Z+

local function refuel()
	if (turtle.getFuelLevel() < 20) then turtle.refuel() end
end

local goUp = true
local function digColumn()
	refuel()
	if (goUp) then -- dig up
		for i=1, height do
			turtle.dig()
			if i ~= height then
				if (turtle.detectUp()) then turtle.digUp() end
				turtle.up()
			end
		end
		goUp = false
	else
		for i=height, 1, -1 do
			turtle.dig()
			if i ~= 1 then
				if (turtle.detectDown()) then turtle.digDown() end
				turtle.down()
			end
		end
		goUp = true
	end
end

local nextTurnRight = true
local function doTurn()
	if (nextTurnRight) then turtle.turnRight() else turtle.turnLeft() end
	digColumn()
	turtle.forward()
	if (nextTurnRight) then turtle.turnRight() else turtle.turnLeft() end
	nextTurnRight = not nextTurnRight
end


local function digRow()
	for i=1, depth do
		digColumn()
		turtle.forward()
	end
end

for i = 1, width do
	digRow()
	if (i ~= width) then doTurn() end
end