local tileset = {}

function tileset:new()
	return setmetatable({
		uuids = {},
		indexable = {}
	}, {__index=tileset})
end

local tile = {}

function tile:draw(scale, x, y)
	love.graphics.draw(self.texture, x+self.offset.x, y+self.offset.y, 0, scale)
end

function tileset:add(uuid, texture, origin, boxCollide, extraCollide)
	local texImage = love.graphics.newImage(texture)
	assert(texImage:getWidth() % 8 == 0 and texImage:getHeight() % 8 == 0, "Texture size not a multiple of 8x8.")
	texImage:setFilter("linear", "nearest")
	self.uuids[uuid] = setmetatable({
		uuid = uuid,
		texture = texImage,
		offset = {x=-origin.x*8, y=-origin.x*8},
		center = origin,
		collide = boxCollide,
		decoCollide = extraCollide,
		width = texImage:getWidth()/8-1,
		height = texImage:getHeight()/8-1
	}, {__index=tile})
	table.insert(self.indexable, self.uuids[uuid])
end

function tileset:loadAssetPack(pack)
	local packMetadata = require("assets." .. tostring(pack) .. ".metadata")
	for _, v in ipairs(packMetadata) do
		self:add(v.uuid, "assets/" .. tostring(pack) .. v.texture, v.center, v.collisionOnBlock, v.collisionOnExtra)
	end
end

function tileset:draw(uuid, scale, x, y)
	assert(self.uuids[uuid], "Tile UUID does not exist.")
	self.uuids[uuid]:draw(scale, x, y)
end

return tileset
