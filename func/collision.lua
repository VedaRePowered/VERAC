local collision = {}

function collision.new()
	return setmetatable({
		x = 0,
		y = 0,
		vx = 0,
		vy = 0
	}, {__index=collision})
end

function collision:getPossibleCollisions(world)
	local possibleCollisions = {}
	local step = 1/math.max(math.abs(self.vx), math.abs(self.vy))
	for i = 0, 1, step do
		local tx, ty = self.x+self.vx*i, self.y+self.vy*i
		local boxes = {}
		local fx, cx = math.floor(tx), math.ceil(tx)
		local fy, cy = math.floor(ty), math.ceil(ty)
		table.insert(boxes, world.getBoxes(fx, fy))
		if fx ~= cx then
			table.insert(boxes, world.getBoxes(cx, fy))
		end
		if fy ~= cy then
			table.insert(boxes, world.getBoxes(fx, cy))
		end
		if fx ~= cx and fy ~= cy then
			table.insert(boxes, world.getBoxes(cx, cy))
		end
		for _, b1 in ipairs(boxes) do
			for _, b2 in ipairs(b1) do
				possibleCollisions[b2] = true
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

	-- collide line moving from (px1, py1 to px1+1, py1) to (px2, py2 to px2+1, py2) with line (lx1, ly, lx2, ly)
	local nLy = (ly-py1)/(py2-py1)
	if nLy < 0 or nLy > 1 then
		return false
	end
	local lPx = px1*(1-nLy) + px2*nLy
	if lx2 < lPx or lx1 > lPx + 1 then
		return false
	end
	return true
end

function collision:slide(world)
	local nx, ny, dx, dy = self.x+self.vx, self.y+self.vy, self.vx, self.vy
	local boxes = {}
	-- vertical collision #1
	boxes = self:getPossibleCollisions(world, dx, dy, self.x, self.y)
	for id, _ in pairs(boxes) do
		local b = world.getBox(id)
		if dy > 0 then
			local colliding = self:singleFaceCollide(self.x-0.5, self.y+0.5, nx-0.5, ny+0.5, b.x, b.x+b.width, b.y)
			if colliding then
				dy = 0
				ny = b.y-0.5
			end
		elseif dy < 0 then
			local colliding = self:singleFaceCollide(self.x-0.5, self.y-0.5, nx-0.5, ny-0.5, b.x, b.x+b.width, b.y+b.height)
			if colliding then
				dy = 0
				ny = b.y+b.height+0.5
			end
		end
	end
	-- horizontal collision #1
	boxes = self:getPossibleCollisions(world, dx, dy, self.x, self.y)
	for id, _ in pairs(boxes) do
		local b = world.getBox(id)
		if dx > 0 then
			local colliding = self:singleFaceCollide(self.y-0.5, self.x+0.5, self.y-0.5+self.vy, self.x+0.5+self.vx, b.y, b.y+b.height, b.x)
			if colliding then
				dx = 0
				nx = b.x-0.5
			end
		elseif dx < 0 then
			local colliding = self:singleFaceCollide(self.y-0.5, self.x-0.5, self.y-0.5+self.vy, self.x-0.5+self.vx, b.y, b.y+b.height, b.x+b.width)
			if colliding then
				dx = 0
				nx = b.x+b.width+0.5
			end
		end
	end
	self.x, self.y, self.vx, self.vy = nx, ny, dx, dy
end

return collision
