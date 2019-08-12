local menu = {}
local gui = require "func.gui"

function menu.new()
	local width, height = love.window.getMode()
	return setmetatable({
		targetWidth = width,
		gui = gui.new()
	}, {__index=menu})
end

function menu:button(displayMode, y, buttonMode, ...)
	local w = self.targetWidth
	local ox = 0
	local ow = 0
	if displayMode == "full" then
		ox = w/2-w/2*0.8
		ow = w*0.8
	elseif displayMode == "right" then
		ox = w/2-w/2*0.8
		ow = w/2*0.7
	elseif displayMode == "left" then
		ox = w/2+w/2*0.1
		ow = w/2*0.7
	elseif displayMode == "center" then
		ox = w/2-w/2*0.4
		ow = w*0.4
	end
	local text = ""
	local callback
	if buttonMode == "action" then
		text, callback = ...
	elseif buttonMode == "cycle" then
		local texts = (({...})[1])
		text = texts[1]
		local curNum = 1
		callback = function(self)
			curNum = curNum % #texts + 1
			self.label = texts[curNum]
		end
	end
	self.gui:add(gui.button.new(ox, y*60+10, ow, 40, text, callback))
end

function menu:update(delta, k)
	self.gui:update(delta, k)
end

function menu:draw()
	self.gui:draw()
end

return menu
