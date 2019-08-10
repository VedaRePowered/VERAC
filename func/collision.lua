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

function collision:getPossibleCollisions(world)
	local possibleCollisions = {}
	local step = 1/math.max(math.abs(self.vx), math.abs(self.vy))
	for i = 0, 1, step do
		local tx, ty = self.x+self.vx*i, self.y+self.vy*i
		local boxes = {}
		local code = math.floor(tx) .. ":" .. math.floor(ty)
		if not possibleCollisionsReversed[code] then
			possibleCollisionsReversed[code] = true
			table.insert(possibleCollisions, {x = math.floor(tx), y = math.floor(ty)})
		end
		for x = tx, math.ceil(tx+self.width) do
			for y = ty, math.ceil(ty+self.height) do
				local code = math.ceil(tx) .. ":" .. math.ceil(ty)
				if not possibleCollisionsReversed[code] then
					possibleCollisionsReversed[code] = true
					table.insert(possibleCollisions, {x = math.ceil(tx), y = math.ceil(ty)})
				end
			end
		end
	end
	return possibleCollisions
end

function collision:singleFaceCollide(px1, py1, px2, py2, lx1, lx2, ly) -- x and y could be swapped and it would still work
	-- sort
	if py1 > py2 then
		local ty, tx = py1, px1
		py1, px1 = py2, px2
		py2, px2 = ty, tx
	end
	if lx1 > lx2 then
		local tx = lx1
		lx1 = lx2
		lx2 = tx
	end

	local pxl = self.width
	-- collide line moving from (px1, py1 to px1+pxl, py1) to (px2, py2 to px2+pxl, py2) with line (lx1, ly, lx2, ly)
	local nLy = (ly-py1)/(py2-py1) -- new line y (interpl for intersecting y)
	if nLy <= 0 or nLy >= 1 then
		return false
	end
	local lPx = px1*(1-nLy) + px2*nLy -- new px (px for intersecting y)
	if lx2 <= lPx or lx1 >= lPx + pxl then -- collide
		return false
	end
	return nLy -- how far until hit
end

function collision:onePass(world)
	local gx, gy = self.x+self.vx, self.y+self.vy -- goal
	local nx, ny = self.x+self.vx, self.y+self.vy -- new
	local hitY, hitX = false, false
	local hEdge, vEdge = self.width/2, self.height/2

	local blocks = self:getPossibleCollisions(world)
	-- vertical collision
	for _, pos in pairs(blocks) do
		local b = {x=pos.x, y=pos.y, width=1, height=1} -- magic to make box out of world tile (TODO: extended blocks)
		if self.vy > 0 then
			local colliding = self:singleFaceCollide(self.x-vEdge, self.y+vEdge, gx-vEdge, gy+vEdge, b.x, b.x+b.width, b.y)
			if colliding then
				ny = b.y-vEdge
				hitY = colliding
			end
		elseif self.vx < 0 then
			local colliding = self:singleFaceCollide(self.x-vEdge, self.y-vEdge, gx-vEdge, gy-vEdge, b.x, b.x+b.width, b.y+b.height)
			if colliding then
				ny = b.y+b.height+vEdge
				hitY = colliding
			end
		end
	end
	-- horizontal collision
	for _, pos in pairs(blocks) do
		local b = {x=pos.x, y=pos.y, width=1, height=1} -- magic to make box out of world tile (TODO: extended blocks)
		if dx > 0 then
			local colliding = self:singleFaceCollide(self.y-hEdge, self.x+hEdge, gy-hEdge, gx+hEdge, b.y, b.y+b.height, b.x)
			if colliding then
				nx = b.x-hEdge
				hitY = colliding
			end
		elseif dx < 0 then
			local colliding = self:singleFaceCollide(self.y-hEdge, self.x-hEdge, gy-hEdge, gx-hEdge, b.y, b.y+b.height, b.x+b.width)
			if colliding then
				nx = b.x+b.width+hEdge
				hitY = colliding
			end
		end
	end

	return hitX, hitY, nx, ny
end

function collision:slide(world)
	local hitX, hitY, nx, ny = collision:onePass(world)
	if hitY and (not hitX or hitY <= hitX) then
		self.vy = 0
		self.y = ny
		local hitX, _, nx, _ = collision:onePass(world)
		self.x = nx
		if hitX then
			self.vx = 0
		end
	elseif hitX then
		self.vx = 0
		self.x = nx
		local _, hitY, _, ny = collision:onePass(world)
		self.y = ny
		if hitX then
			self.vx = 0
		end
	end
end

return collision
