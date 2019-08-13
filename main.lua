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

	s.camera = f.camera.new()
	s.world = f.world.new(64)
	s.terrainGenerator = f.terrainGen.new(math.random(0, 0xFFFFFFFF))
	s.buttonMap = f.buttons.new(1)

	s.mainPlayer = f.player.new({1, 0, 0})
	s.mainPlayer:warpTo(31, 55)

	s.world.tileset:loadAssetPack("testTiles")
	s.terrainGenerator:generateNext(s.world, 100)
end

function love.update(delta)
	local k = s.buttonMap:get()
	s.mainPlayer:updateLocal(s.world, s.camera, delta, k)

	s.testMenu:update(delta, k)
end

function love.draw()
	s.world:draw(s.camera)
	s.mainPlayer:draw(s.world, s.camera)

	s.testMenu:draw()
end
