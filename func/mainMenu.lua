local mainMenu = {}

function mainMenu.new()
	local m = setmetatable({
		gui = new "gui",
		buttonMap = new("buttons", 1),
	}, {__index=mainMenu})

	return m
end

function mainMenu:update(delta)
	local k = self.buttonMap:get()
	self.gui:update(delta, k)
end

function mainMenu:draw()
	self.gui:draw()
end

return mainMenu
