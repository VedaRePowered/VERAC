local f = {} -- f for 'functions'
local s = {} -- s for 'state'
function love.load()
	local function load(module) f[tostring(module)] = require("func." .. tostring(module)) end -- helper to load 1 library/class
	load "camera"
	load "world"
	load "terrainGen"
	load "buttons"
	load "player"
	load "gui"

	s.camera = f.camera.new()
	s.world = f.world.new(64)
	s.terrainGenerator = f.terrainGen.new(math.random(0, 0xFFFFFFFF))
	s.buttonMap = f.buttons.new(1)

	s.mainPlayer = f.player.new({1, 0, 0})
	s.mainPlayer:warpTo(31, 55)

	s.world.tileset:loadAssetPack("testTiles")
	s.terrainGenerator:generateNext(s.world, 100)

	s.testGui = f.gui.new()
	s.testGui:add(f.gui.button.new(300, 300, 50, 20, "Test.BTN"))
	s.testGui:add(f.gui.text.new(300, 200, 200, "Enter %TEST% Here."))
	s.testGui:add(f.gui.selector.new(100, 100, {"One", "2", "0b0011", "IV"}))
	s.testGui:add(f.gui.slider.new(300, 100, 100, 20, false))
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
	local k = s.buttonMap:get()
	s.mainPlayer:updateLocal(s.world, s.camera, delta, k)

	s.testGui:update(delta, k)
end

function love.draw()
	s.world:draw(s.camera)
	s.mainPlayer:draw(s.world, s.camera)

	s.testGui:draw()
end
