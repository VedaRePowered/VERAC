local collision = {}
local registeredCollisionObjects = {}

function collision.new(width, height)
	local co = {
		x = 0,
		y = 0,
		vx = 0,
		vy = 0,
		width = width,
		height = height,
		registeredId = #registeredCollisionObjects+1,
	}
	registeredCollisionObjects[co.registeredId] = co
	return setmetatable(co, {__index=collision})
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
	for _, co in pairs(registeredCollisionObjects) do
		if co.registeredId ~= self.registeredId then
			table.insert(possibleCollisions, {x = co.x-co.width/2, y = co.y+co.height/2, width=co.width, height=co.height, dx = co.vx, dy = co.vy}) -- drag velocity
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
	local hitX, hitY = {collision=false, newX=gx}, {collision=false, newY=gy}
	local hEdge, vEdge = self.width/2, self.height/2

	local blocks = self:getPossibleCollisions(world, self.vx*delta, self.vy*delta)
	-- vertical collision
	for _, b in pairs(blocks) do
		if self.vy*delta > 0 then
			local colliding = self:singleFaceCollide(self.x-hEdge, self.y+vEdge, gx-hEdge, gy+vEdge, b.x, b.x+b.width, b.y-b.height)
			if colliding and (not hitY.collision or colliding < hitY.linear) then
				hitY = {collision=true, collider=b, linear=colliding, newY=b.y-b.height-vEdge}
			end
		elseif self.vy*delta < 0 then
			local colliding = self:singleFaceCollide(self.x-hEdge, self.y-vEdge, gx-hEdge, gy-vEdge, b.x, b.x+b.width, b.y)
			if colliding and (not hitY.collision or colliding < hitY.linear) then
				hitY = {collision=true, collider=b, linear=colliding, newY=b.y+vEdge}
			end
		end
	end
	-- horizontal collision
	for _, b in pairs(blocks) do
		if self.vx*delta > 0 then
			local colliding = self:singleFaceCollide(self.y-vEdge, self.x+hEdge, gy-vEdge, gx+hEdge, b.y, b.y-b.height, b.x)
			if colliding and (not hitX.collision or colliding < hitX.linear) then
				hitX = {collision=true, collider=b, linear=colliding, newX=b.x-hEdge}
			end
		elseif self.vx*delta < 0 then
			local colliding = self:singleFaceCollide(self.y-vEdge, self.x-hEdge, gy-vEdge, gx-hEdge, b.y, b.y-b.height, b.x+b.width)
			if colliding and (not hitX.collision or colliding < hitX.linear) then
				hitX = {collision=true, collider=b, linear=colliding, newX=b.x+b.width+hEdge}
			end
		end
	end

	return hitX, hitY
end

function collision:slide(world, delta)
	local hitX, hitY = self:onePass(world, delta)
	if hitX.collision and hitY.collision then
		local ox, oy, ovx, ovy = self.x, self.y, self.vx, self.vy
		do
			self.vy = 0
			self.y = hitY.newY
			hitX, _ = self:onePass(world, delta)
		end
		self.x, self.y, self.vx, self.vy = ox, oy, ovx, ovy
		do
			self.vx = 0
			self.x = hitX.newX
			_, hitY = self:onePass(world, delta)
		end
		self.x, self.y, self.vx, self.vy = ox, oy, ovx, ovy
		if not hitY.collision or (hitX.collision and hitY.linear > hitX.linear) then
			self.y = hitY.newY
			self.x = hitX.newX
			if hitX.collision then
				self.vx = 0
			end
		else
			self.x = hitX.newX
			self.y = hitY.newY
			if hitY.collision then
				self.vy = 0
			end
		end
	elseif hitY.collision and (not hitX.collision or hitY.linear < hitX.linear) then
		self.vy = 0
		self.y = hitY.newY
		local hitX, _ = self:onePass(world, delta)
		self.x = hitX.newX
		if hitX.collision then
			self.vx = 0
		end
	elseif hitX.collision then
		self.vx = 0
		self.x = hitX.newX
		local _, hitY = self:onePass(world, delta)
		self.y = hitY.newY
		if hitY.collision then
			self.vy = 0
		end
	else -- path clear
		self.x, self.y = hitX.newX, hitY.newY
	end
	return hitX.collider, hitY.collider
end

return collision
