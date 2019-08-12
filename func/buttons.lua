local buttons = {}

function buttons.new(id, mapping)
	return setmetatable({
		gamepad=love.joystick.getJoysticks()[id],
		mapping=require "assets.defaultButtonMap",
		pressed={},
		id = id
	}, {__index=buttons})
end

function buttons:get()
	assert(self.id == 1 or self.id == 0 or (self.gamepad and self.gamepad:isConnected()), "Gamepad not connected, can't get buttons")
	local k = {}
	for b, l in pairs(self.mapping) do
		k[b] = {}
		k[b].held = false
		for _, p in ipairs(l) do
			if self.id >= 1 and self.gamepad then
				if p.type == "button" then
					k[b].held = k[b].held or self.gamepad:isDown(p.button)
				elseif p.type == "hat" then
					k[b].held = k[b].held or tostring(self.gamepad:getHat(p.hat)):match(p.direction)
				elseif p.type == "axis" then
					k[b].held = k[b].held or self.gamepad:getAxis(p.axis)/p.direction >= 1
				end
			end
			if self.id <= 1 then
				if p.type == "key" then
					if p.scancode then
						k[b].held = k[b].held or love.keyboard.isScancodeDown(p.scancode)
					end
					if p.keycode then
						k[b].held = k[b].held or love.keyboard.isDown(p.keycode)
					end
				elseif p.type == "mouse" then
					k[b].held = k[b].held or love.mouse.isDown(p.button)
				end
			end
		end
		k[b].held = not not k[b].held --> bool
		if not self.pressed[b] then
			self.pressed[b] = {held = false, down = false, up = false}
		end
		k[b].down = k[b].held and not self.pressed[b].held
		k[b].up = self.pressed[b].held and not k[b].held
	end
	self.pressed = k
	return k
end

return buttons
