local player = {}
local collision = require "func.collision"

function player.new()
	return setmetatable({
		collider = collision.new(2, 2)
	}, {__index=player})
end

function player:warpTo(x, y)
	self.collider.vx, self.collider.vy = 0, 0
	self.collider.x, self.collider.y = x, y
end

function player:updateLocal(world, cam, delta, k) -- update as if main player
	self.collider.vy = self.collider.vy - 20*delta -- gravity
	if k.playerLeft.isDown then
		self.collider.vx = self.collider.vx - 20*delta
	end
	if k.playerRight.isDown then
		self.collider.vx = self.collider.vx + 20*delta
	end
	self.collider:slide(world, delta)

	cam:glideTo(self.collider.x, self.collider.y, 10^delta)
end

return player
