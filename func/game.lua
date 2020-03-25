local game = {}

function game.new()
	local g = setmetatable({
		camera = new "camera",
		world = new("world", 64),
		terrainGenerator = new("terrainGen", math.random(0, 0xFFFFFFFF)),
		buttonMap = new("buttons", 1),
		mainPlayer = new("player", {1, 0, 0}),
		testEntity = new("entity",
			32, 60, 2, 1.5,
			{"fox.png", "fox2.png", "fox3.png"},
			75, 4, function(self)
				self.direction = not self.direction
			end),
	}, {__index=game})
	g.mainPlayer:warpTo(31, 55)

	g.world.tileset:loadAssetPack("testTiles")
	g.terrainGenerator:generateNext(g.world, 100)

	g.testEntity.direction = false

	return g
end

function game:update(delta)
	local k = self.buttonMap:get()
	self.mainPlayer:updateLocal(self.world, self.camera, delta, k)
	if self.testEntity.direction then
		self.testEntity:accelerate(-delta*10, 0)
	else
		self.testEntity:accelerate(delta*10, 0)
	end
	self.testEntity:update(self.world, delta)

	if k.debugKillPlayer.down then --DEBUG: Kill player on command
		self.mainPlayer:kill()
	end
end

function game:draw()
	self.world:draw(self.camera, "")
	self.mainPlayer:draw(self.world, self.camera)
	self.testEntity:draw(self.world, self.camera)
	self.world:draw(self.camera, "foreground")
end

return game
