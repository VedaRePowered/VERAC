local particles = {}

function particles.new()
	local ps = {
		loaded = {},
		active = {},
	}
	return setmetatable(ps, {__index=particles})
end

function particles:add(folder)
	local p = require("assets." .. tostring(folder) .. ".metadata")
	for i, t in ipairs(p.textures) do
		p.textures[i] = love.graphics.newImage("assets/" .. tostring(folder) .. tostring(t))
	end
	self.loaded[folder] = p
end

local function rnd(range)
	return (math.random()*2-1)*rnd
end

function particles:instance(path, x, y)
	local s = self.loaded[path]
	for i = 1, math.floor(s.amount+rnd(s.amountRandom)+0.5) do
		local rotation = 0
		if s.rotation == "full" then
			rotation = rnd(math.pi)
		elseif s.rotation == "top" then
			rotation = rnd(math.pi/2)
		elseif s.rotation == "right" then
			rotation = math.random(-1, 2) * 90
		end
		table.insert(self.active, {
			x = x, y = y,
			vx = s.xVelocity+rnd(s.xVelocityRandom), vy = s.yVelocity+rnd(s.yVelocityRandom),
			timeLeft = lifeSpan,
			r = rotation,
			rv = rnd(s.rotationVelocity),
			drag = s.drag,
			weight = s.weight,
			tex = s.textures[math.random(1, #s.textures)],
		})
	end
end

function particles:update(delta)
	for id, p in pairs(self.active) do
		p.vy = p.vy + p.weight * delta
		p.vx, p.vy = p.vx * p.drag^delta, o.vy * p.drag^delta
		p.x, p.y = p.x + p.vx*delta, p.y + p.vy*delta
		p.r = p.rv*delta
		p.timeLeft = p.timeLeft - delta
		if p.timeLeft <= 0 then
			self.active[id] = nil
		end
	end
end

function particles:draw(cam)

end

return particles
