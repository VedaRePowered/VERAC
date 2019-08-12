local player = {}
local collision = require "func.collision"

local drag = 0.02
local jumpVelocity = 30
local airAcceleration = 5
local groundAcceleration = 50
local gravity = 90

function player.new(colour)
	return setmetatable({
		collider = collision.new(2, 2),
		colour = colour,
		onGround = false,
		onLeftWall = false,
		onRightWall = false
	}, {__index=player})
end

function player:warpTo(x, y)
	self.collider.vx, self.collider.vy = 0, 0
	self.collider.x, self.collider.y = x, y
end

function player:updateLocal(world, cam, delta, k) -- update as if main player
	self.collider.vy = self.collider.vy - gravity*delta -- gravity
	if k.playerLeft.held then
		self.collider.vx = self.collider.vx - (self.onGround and groundAcceleration or airAcceleration)*delta
	end
	if k.playerRight.held then
		self.collider.vx = self.collider.vx + (self.onGround and groundAcceleration or airAcceleration)*delta
	end
	if self.onGround and k.playerJump.down then
		self.collider.vy = jumpVelocity
	end

	self.collider.vx, self.collider.vy = self.collider.vx * drag^delta, self.collider.vy * drag^delta

	local ovx, ovy = self.collider.vx, self.collider.vy
	self.collider:slide(world, delta)
	self.onGround =  self.collider.vy == 0 and ovy < 0
	self.onRightWall = self.collider.vx == 0 and ovx < 0
	self.onLeftWall = self.collider.vx == 0 and ovx > 0

	cam:glideTo(self.collider.x, self.collider.y, 10^delta)
end

function player:draw(world, cam)
	love.graphics.setColor(self.colour)
	local ss = cam:toScreenSize(2)
	local sx, sy = cam:toScreenPosition(self.collider.x-1, self.collider.y+1)
	love.graphics.rectangle("fill", sx, sy, ss, ss)
	love.graphics.setColor(1, 1, 1)
end

return player
