local world = {}

function world.new(width)
	return setmetatable({
		width = width,
		tiles = {}
	}, {__index=world})
end

function world:newRow(y)
	if not self.tiles[y] then
		self.tiles[y] = {}
		for i = 1, self.width do
			self.tiles[y][i] = {
				uuid = false, -- false for empty
				intersecting = {}
			}
		end
	end
end

function world:setBlock(x, y, tile)
	assert(x >= 1 and x <= self.width, "World position out of range.")
	self:newRow(y)
	self.tiles[y][x].uuid = tile.uuid
	for i = x+tile.offset.x, x+tile.offset.x+tile.width do
		if i > 0 and i <= self.width then
			for j = y-tile.offset.y, y-tile.offset.y+tile.height do
				if i ~= x or j ~= y then
					self:newRow(j)
					table.insert(self.tiles[j][i].intersecting, {x=x, y=y})
				end
			end
		end
	end
end

function world:getBlock(x, y)
	self:newRow(y)
	return self.tiles[y][x] or {uuid=false, intersecting={}}
end

function world:draw(tileset, cam) -- draw a region based around the camera's telemetry
	local width, height = love.window.getMode()
	local xMax, yMax = math.ceil(width/cam.scale/2), math.ceil(height/cam.scale/2)
	local xPos, yPos = math.floor(cam.x), math.floor(cam.y)
	local drawn = {}
	local function drawTile(x, y)
		if self.tiles[y][x].uuid and not drawn[x+y*self.width] then
			drawn[x+y*self.width] = true
			local sx, sy = cam:toScreenPosition(x, y)
			tileset:draw(self.tiles[y][x].uuid, cam.scale, sx, sy)
		end
	end
	for y = yPos-yMax+1, yPos+yMax+1 do
		for x = xPos-xMax, xPos+xMax do
			if self.tiles[y] and self.tiles[y][x] then
				drawTile(x, y)
			end
		end
	end
	drawn = {}
	for y = yPos-yMax+1, yPos+yMax+1 do
		for x = xPos-xMax, xPos+xMax do
			if self.tiles[y] and self.tiles[y][x] then
				for _, t in ipairs(self.tiles[y][x].intersecting) do
					drawTile(t.x, t.y)
				end
			end
		end
	end
end

return world
