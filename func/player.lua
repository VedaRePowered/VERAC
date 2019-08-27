local player = {}
local collision = require "func.collision"

local xAirDrag = 0.15
local xGroundDrag = 0.002
local yAirDrag = 0.2
local yWallDrag = 0.0002
local jumpVelocity = 18
local airAcceleration = 20
local groundAcceleration = 70
local jumpGravity = 35
local gravity = 75

function player.new(colour)
	return setmetatable({
		collider = collision.new(2, 2),
		colour = colour,
		onGround = false,
		onLeftWall = false,
		onRightWall = false,
		jumping = false
	}, {__index=player})
end

function player:warpTo(x, y)
	self.collider.vx, self.collider.vy = 0, 0
	self.collider.x, self.collider.y = x, y
end

function player:updateLocal(world, cam, delta, k) -- update as if main player
	self.collider.vy = self.collider.vy - (self.jumping and jumpGravity or gravity)*delta -- gravity
	if k.playerLeft.held then
		self.collider.vx = self.collider.vx - (self.onGround and groundAcceleration or airAcceleration)*delta
	end
	if k.playerRight.held then
		self.collider.vx = self.collider.vx + (self.onGround and groundAcceleration or airAcceleration)*delta
	end
	if self.onGround and k.playerJump.down then
		self.collider.vy = jumpVelocity
		self.jumping = true
	end
	if self.collider.vy < 0 or not k.playerJump.held then
		self.jumping = false
	end

	local ovx, ovy = self.collider.vx, self.collider.vy
	local xCollider, yCollider = self.collider:slide(world, delta) -- store colliders for drag
	self.onGround =  self.collider.vy == 0 and ovy < 0
	self.onRightWall = self.collider.vx == 0 and ovx < 0
	self.onLeftWall = self.collider.vx == 0 and ovx > 0

	local xdm = (self.onGround and xGroundDrag or xAirDrag)^delta
	local ydm = ((self.onLeftWall or self.onRightWall) and yGroundDrag or yAirDrag)^delta
	-- adjust the multiplyer for averaging
	local txv = (yCollider and yCollider.dx or 0)*(1/xdm-1)
	local tyv = (xCollider and xCollider.dy or 0)*(1/ydm-1)
	self.collider.vx = (self.collider.vx + txv) * xdm
	self.collider.vy = (self.collider.vy + tyv) * ydm

	local camOffsetX = 0
	local camOffsetY = 0
	if k.cameraLookUp.held then
		camOffsetY = camOffsetY + 4
	end
	if k.cameraLookDown.held then
		camOffsetY = camOffsetY - 4
	end
	if k.cameraLookRight.held then
		camOffsetX = camOffsetX + 4
	end
	if k.cameraLookLeft.held then
		camOffsetX = camOffsetX - 4
	end
	cam:glideTo(self.collider.x+camOffsetX, self.collider.y+camOffsetY, 0.1)
end

function player:draw(world, cam)
	love.graphics.setColor(self.colour)
	local ss = cam:toScreenSize(2)
	local sx, sy = cam:toScreenPosition(self.collider.x-1, self.collider.y+1)
	love.graphics.rectangle("fill", sx, sy, ss, ss)
	love.graphics.setColor(1, 1, 1)
end

return player
