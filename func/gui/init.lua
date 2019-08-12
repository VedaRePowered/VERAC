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
	table.insert(self.guiElements, e)
end

function gui:delete(id)
	self.guiElements[id] = nil
end

function gui:update(delta, k)
	gui.text.updateBlink(delta)
	gui.slider.updateMouse(delta)
	for _, e in pairs(self.guiElements) do
		e:update(k)
	end
	gui.slider.updateKeys(delta)
end

function gui:draw()
	for _, e in pairs(self.guiElements) do
		e:draw()
	end
end

return gui
