local player = {}
local collision = require "func.collision"

function player.new(colour)
	return setmetatable({
		collider = collision.new(2, 2),
		colour = colour
	}, {__index=player})
end

function player:warpTo(x, y)
	self.collider.vx, self.collider.vy = 0, 0
	self.collider.x, self.collider.y = x, y
end

function player:updateLocal(world, cam, delta, k) -- update as if main player
	self.collider.vy = self.collider.vy - 20*delta -- gravity
	if k.playerLeft.held then
		self.collider.vx = self.collider.vx - 20*delta
	end
	if k.playerRight.held then
		self.collider.vx = self.collider.vx + 20*delta
	end
	self.collider:slide(world, delta)

	cam:glideTo(self.collider.x, self.collider.y, 10^delta)
end

function player:draw(cam)
	love.graphics.setColor(self.colour)
	local ss = cam:toScreenSize(2)
	local sx, sy = cam:toScreenPosition(self.collider.x-1, self.collider.y+1)
	love.graphics.rectangle("fill", sx, sy, ss, ss)
	love.graphics.setColor(1, 1, 1)
	local sx, sy = cam:toScreenPosition(self.collider.x, self.collider.y)
	local ex, ey = cam:toScreenPosition(self.collider.x+self.collider.vx/5, self.collider.y+self.collider.vy/5)
	love.graphics.line(sx, sy, ex, ey)
end

return player
