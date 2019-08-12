local gui = {}

gui.button = require "func.gui.button"
gui.text = require "func.gui.text"
gui.selector = require "func.gui.selector"
gui.slider = require "func.gui.slider"

function gui.new()
	return setmetatable({
		guiElements = {}
	}, {__index = gui})
end

function gui:add(e)
	table.insert(guiElements)
end

function gui:get(id)
	return guiElements[id]
end

function gui:delete(id)
	guiElements[id] = nil
end

function gui:update(k)
	for _, e in pairs(guiElements) do
		e.update(k)
	end
end

function gui:draw()
	for _, e in pairs(guiElements) do
		e:draw()
	end
end

return gui
