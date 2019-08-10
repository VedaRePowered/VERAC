local f = {} -- f for 'functions'
local s = {} -- s for 'state'
function love.load()
	local function load(module) f[tostring(module)] = require("func." .. tostring(module)) end -- helper to load 1 library/class
	load "camera"
	load "tileset"
	load "world"
	load "terrainGen"

	s.camera = f.camera.new()
	s.tileset = f.tileset.new()
	s.world = f.world.new(64)
	s.terrainGenerator = f.terrainGen.new(math.random(0, 0xFFFFFFFF))

	s.tileset:loadAssetPack("testTiles")

	s.terrainGenerator:generateNext(s.tileset, s.world, 100)
end

function love.update(delta)
	if love.keyboard.isDown("up") then
		s.camera.y = s.camera.y + delta*8
	end
	if love.keyboard.isDown("down") then
		s.camera.y = s.camera.y - delta*8
	end
	if love.keyboard.isDown("right") then
		s.camera.x = s.camera.x + delta*8
	end
	if love.keyboard.isDown("left") then
		s.camera.x = s.camera.x - delta*8
	end
end

function love.draw()
	s.world:draw(s.tileset, s.camera)
end
