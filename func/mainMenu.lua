local mainMenu = {}

function mainMenu:new()
	local mm = {}

	return setmetatable(mm, {__index})
end

function mainMenu:update(delta)

end

function mainMenu:draw()

end

return mainMenu
