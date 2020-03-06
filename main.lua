local mode
function new(class, ...)
	local m = require("func." .. tostring(class))
	return m.new(...)
end

function love.load()
	print = require "func.print"
	mode = new "mode"
	mode:start "game" -- initialize the game
	mode:start "mainMenu" -- initialize the main menu
	mode:switch "mainMenu"
end

function love.update(delta)
	mode:update(delta)
end

function love.draw()
	mode:draw()
end
