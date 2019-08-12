local collision = {}

function collision.new(width, height)
	return setmetatable({
		x = 0,
		y = 0,
		vx = 0,
		vy = 0,
		width = width,
		height = height,
	}, {__index=collision})
end

function collision:getPossibleCollisions(world, dx, dy)
	local possibleCollisionsReversed = {}
	local possibleCollisions = {}
	local step = math.min(1/math.max(math.abs(dx), math.abs(dy), 0.001), 1)
	local function addOne(ix, iy)
		local code = math.ceil(ix) .. ":" .. math.ceil(iy)
		if not possibleCollisionsReversed[code] then
			possibleCollisionsReversed[code] = true
			local block = world:getBlock(math.ceil(ix), math.ceil(iy))
			local tid = block.uuid
			if tid then
				local t = world.tileset.uuids[tid]
				if t.decoCollide then
					table.insert(possibleCollisions, {x = math.ceil(ix)+t.offset.x, y = math.ceil(iy)-t.offset.y, width=t.width+1, height=t.height+1})
				elseif t.collide then
					table.insert(possibleCollisions, {x = math.ceil(ix), y = math.ceil(iy), width=1, height=1})
				end
			end
			for _, i in ipairs(block.intersecting) do
				addOne(i.x, i.y)
			end
		end
	end
	for i = 0, 1+step, step do
		local tx, ty = self.x-self.width/2+dx*i, self.y-self.height/2+dy*i
		local boxes = {}
		for ix = math.floor(tx), math.ceil(tx+self.width) do
			for iy = math.floor(ty), math.ceil(ty+self.height) do
				addOne(ix, iy)
			end
		end
	end
	return possibleCollisions
end

function collision:singleFaceCollide(px1, py1, px2, py2, lx1, lx2, ly) -- x and y could be swapped and it would still work
	local swapped = false
	-- sort
	if py1 > py2 then
		local ty, tx = py1, px1
		py1, px1 = py2, px2
		py2, px2 = ty, tx
		swapped = true
	end
	if lx1 > lx2 then
		local tx = lx1
		lx1 = lx2
		lx2 = tx
	end

	local pxl = self.width
	-- collide line moving from (px1, py1 to px1+pxl, py1) to (px2, py2 to px2+pxl, py2) with line (lx1, ly, lx2, ly)
	local nLy = (ly-py1)/(py2-py1) -- new line y (interpl for intersecting y)
	if nLy < 0 or nLy > 1 then
		return false
	end
	local lPx = px1*(1-nLy) + px2*nLy -- new px (px for intersecting y)
	if lx2 <= lPx or lx1 >= lPx + pxl then -- collide
		return false
	end
	return swapped and (1-nLy) or nLy -- how far until hit
end

function collision:onePass(world, delta)
	local gx, gy = self.x+self.vx*delta, self.y+self.vy*delta -- goal
	local nx, ny = gx, gy -- output position
	local hitY, hitX = false, false
	local hEdge, vEdge = self.width/2, self.height/2

	local blocks = self:getPossibleCollisions(world, self.vx*delta, self.vy*delta)
	-- vertical collision
	for _, b in pairs(blocks) do
		if self.vy*delta > 0 then
			local colliding = self:singleFaceCollide(self.x-hEdge, self.y+vEdge, gx-hEdge, gy+vEdge, b.x, b.x+b.width, b.y-b.height)
			if colliding and (not hitY or colliding < hitY) then
				ny = b.y-b.height-vEdge
				hitY = colliding
			end
		elseif self.vy*delta < 0 then
			local colliding = self:singleFaceCollide(self.x-hEdge, self.y-vEdge, gx-hEdge, gy-vEdge, b.x, b.x+b.width, b.y)
			if colliding and (not hitY or colliding < hitY) then
				ny = b.y+vEdge
				hitY = colliding
			end
		end
	end
	-- horizontal collision
	for _, b in pairs(blocks) do
		if self.vx*delta > 0 then
			local colliding = self:singleFaceCollide(self.y-vEdge, self.x+hEdge, gy-vEdge, gx+hEdge, b.y, b.y-b.height, b.x)
			if colliding and (not hitX or colliding < hitX) then
				nx = b.x-hEdge
				hitX = colliding
			end
		elseif self.vx*delta < 0 then
			local colliding = self:singleFaceCollide(self.y-vEdge, self.x-hEdge, gy-vEdge, gx-hEdge, b.y, b.y-b.height, b.x+b.width)
			if colliding and (not hitX or colliding < hitX) then
				nx = b.x+b.width+hEdge
				hitX = colliding
			end
		end
	end

	return hitX, hitY, nx, ny
end

function collision:slide(world, delta)
	local hitX, hitY, nx, ny = self:onePass(world, delta)
	if hitX and hitY then
		local ox, oy, ovx, ovy = self.x, self.y, self.vx, self.vy
		do
			self.vy = 0
			self.y = ny
			hitX, _, nx, _ = self:onePass(world, delta)
		end
		self.x, self.y, self.vx, self.vy = ox, oy, ovx, ovy
		do
			self.vx = 0
			self.x = nx
			_, hitY, _, ny = self:onePass(world, delta)
		end
		self.x, self.y, self.vx, self.vy = ox, oy, ovx, ovy
		if not hitY or (hitX and hitY > hitX) then
			self.y = ny
			self.x = nx
			if hitX then
				self.vx = 0
			end
		else
			self.x = nx
			self.y = ny
			if hitY then
				self.vy = 0
			end
		end
	elseif hitY and (not hitX or hitY < hitX) then
		self.vy = 0
		self.y = ny
		local hitX, _, nx, _ = self:onePass(world, delta)
		self.x = nx
		if hitX then
			self.vx = 0
		end
	elseif hitX then
		self.vx = 0
		self.x = nx
		local _, hitY, _, ny = self:onePass(world, delta)
		self.y = ny
		if hitY then
			self.vy = 0
		end
	else -- path clear
		self.x, self.y = nx, ny
	end
end

return collision
