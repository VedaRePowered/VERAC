local mode
function new(class, ...)
	local m = require("func." .. tostring(class))
	return m.new(...)
end

function love.load()
	print = require "func.print"
	mode = new "mode"
	mode:create "game" -- initialize the game
	mode:create "mainMenu" -- initialize the main menu
	mode:switch "game"
end

function love.update(delta)
	mode:update(delta)
end

function love.draw()
	mode:draw()
end
