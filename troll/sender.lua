local modem = peripheral.find("modem")
local speaker = peripheral.find("speaker")
local channel = 791

print("Enter a sound to play on all receivers.\n")
local input = read()
print("Attempting to play "..input..".")
modem.transmit(channel, channel, input)
if speaker then speaker.playSound(input) end
