local f = {} -- f for 'functions'
local s = {} -- s for 'state'
function love.load()
	local function load(module) f[tostring(module)] = require("func." .. tostring(module)) end -- helper to load 1 library/class
	load "camera"
	load "world"
	load "terrainGen"
	load "buttons"
	load "player"
	load "menu"
	load "entity"
	load "particles"

	s.camera = f.camera.new()
	s.world = f.world.new(64)
	s.terrainGenerator = f.terrainGen.new(math.random(0, 0xFFFFFFFF))
	s.buttonMap = f.buttons.new(1)

	s.mainPlayer = f.player.new({1, 0, 0})
	s.mainPlayer:warpTo(31, 55)

	s.world.tileset:loadAssetPack("testTiles")
	s.terrainGenerator:generateNext(s.world, 100)

	s.testEntity = f.entity.new(32, 60, 2, 1.5, {"fox.png", "fox2.png", "fox3.png"}, 75, 4, function()s.testEntity.direction = not s.testEntity.direction end)
	s.testEntity.direction = false

	s.testParticles = f.particles.new()
	s.testParticles:add("dirt")
end

function love.update(delta)
	local k = s.buttonMap:get()
	s.mainPlayer:updateLocal(s.world, s.camera, delta, k)
	if s.testEntity.direction then
		s.testEntity:accelerate(-delta*10, 0)
	else
		s.testEntity:accelerate(delta*10, 0)
	end
	if math.random(1, 50) == 1 then
		s.testEntity:accelerate(0, 20)
	end
	s.testEntity:update(s.world, delta)

	if math.random() < 0.01 then
		s.testParticles:instance("dirt", s.mainPlayer.collider.x, s.mainPlayer.collider.y-1)
	end

	s.testParticles:update(delta)
end

function love.draw()
	s.world:draw(s.camera, "")
	s.mainPlayer:draw(s.world, s.camera)
	s.testEntity:draw(s.world, s.camera)
	s.world:draw(s.camera, "foreground")
	s.testParticles:draw(s.camera)
end
