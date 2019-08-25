local entity = {}
local collision = require "func.collision"

local xAirDrag = 0.15
local xGroundDrag = 0.002
local yAirDrag = 0.2
local yWallDrag = 0.0002

function entity.new(x, y, width, height, textures, gravity, animationSpeed)
	local loadedTextures = {}
	for _, t in ipairs(textures) do
		love.graphics.newImage("/assets/entities/" .. tostring(t))
	end
	local e = {
		collider = collision.new(width, height),
		textures = loadedTextures,
		animationTimer = 0,
		animationSpeed = 1/animationSpeed or 1,
		gravity = gravity or 0,
		onGround = false,
		onWall = false,
	}
	e.collider.x = x
	e.collider.y = y
	return setmetatable(e, {__index=entity})
end

function entity:update(world, delta)
	self.collider.vy = self.collider.vy - self.gravity*delta

	self.collider.vx = self.collider.vx * (self.onGround and xGroundDrag or xAirDrag)^delta
	self.collider.vy = self.collider.vy * ((self.oWall) and yGroundDrag or yAirDrag)^delta

	local ovx, ovy = self.collider.vx, self.collider.vy
	self.collider:slide(world, delta)
	self.onGround =  self.collider.vy == 0 and ovy < 0
	self.onWall = self.collider.vx == 0 and ovx ~= 0
end

return entity
