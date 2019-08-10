local buttons = {}

function buttons.new(id, mapping)
	return setmetatable({
		gamepad=love.joystick.getJoysticks()[id],
		mapping=require "assets.defaultButtonMap",
		pressed={}
	}, {__index=buttons})
end

function buttons:get()
	assert(self.gamepad and self.gamepad:isConnected(), "Gamepad not connected, can't get buttons")
	local k = {}
	for b, l in pairs(self.mapping) do
		k[b] = {}
		k[b].held = false
		for _, p in ipairs(l) do
			if p.type == "button" then
				k[b].held = k[b].held or self.gamepad:isDown(p.button)
			elseif p.type == "hat" then
				k[b].held = k[b].held or tostring(self.gamepad:getHat(p.hat)):match(p.direction)
			elseif p.type == "axis" then
				k[b].held = k[b].held or self.gamepad:getAxis(p.axis)/p.direction >= 1
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
