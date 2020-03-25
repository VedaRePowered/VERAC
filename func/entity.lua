local entity = {}
local collision = require "func.collision"

local xAirDrag = 0.15
local xGroundDrag = 0.002
local yAirDrag = 0.2
local yWallDrag = 0.0002

function entity.new(x, y, width, height, textures, gravity, animationSpeed, hitCallback)
	local loadedTextures = {}
	for _, t in ipairs(textures) do
		table.insert(loadedTextures, love.graphics.newImage("/assets/entities/" .. tostring(t)))
		loadedTextures[#loadedTextures]:setFilter("nearest", "nearest")
	end
	local e = {
		collider = collision.new(width, height),
		textures = loadedTextures,
		animationTimer = 0,
		animationSpeed = animationSpeed or 1,
		gravity = gravity or 0,
		onGround = false,
		onWall = false,
		hitCallback = hitCallback,
	}
	e.collider.x = x
	e.collider.y = y
	return setmetatable(e, {__index=entity})
end

function entity:update(world, delta)
	self.animationTimer = self.animationTimer%#self.textures + self.animationSpeed*delta

	self.collider.vy = self.collider.vy - self.gravity*delta

	self.collider.vx = self.collider.vx * (self.onGround and xGroundDrag or xAirDrag)^delta
	self.collider.vy = self.collider.vy * ((self.oWall) and yGroundDrag or yAirDrag)^delta

	local ovx, ovy = self.collider.vx, self.collider.vy
	self.collider:slide(world, delta)
	self.onGround =  self.collider.vy == 0 and ovy < 0
	self.onWall = self.collider.vx == 0 and ovx ~= 0
	-- print(ovx, "->", self.collider.vx)
	if self.onWall and self.hitCallback then
		self:hitCallback()
	end
end

function entity:draw(world, cam)
	local sx, sy = cam:toScreenPosition(self.collider.x-self.collider.width/2, self.collider.y+self.collider.height/2)
	local ss = cam.scale/8
	local tex = self.textures[math.max(math.min(math.ceil(self.animationTimer), #self.textures), 1)]
	love.graphics.draw(tex, sx-tex:getWidth()/2, sy-tex:getHeight()/2, 0, ss)
end

function entity:accelerate(x, y)
	self.collider.vx, self.collider.vy = self.collider.vx + x, self.collider.vy + y
end

return entity
