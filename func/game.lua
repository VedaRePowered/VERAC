local game, f = {}, {}

function game.load()
	local function load(module) f[tostring(module)] = require("func." .. tostring(module)) end -- helper to load 1 library/class
	load "camera"
	load "world"
	load "terrainGen"
	load "buttons"
	load "player"
	load "menu"
	load "entity"
	load "particles"
end

function game.new()
	local g = setmetatable({
		state = {},
		updaters = {},
		renderers = {},
	}, {__index=game, __metatable=true})
	g.state.camera = f.camera.new()
	g.state.world = f.world.new(64)
	g.state.terrainGenerator = f.terrainGen.new(math.random(0, 0xFFFFFFFF))
	g.state.buttonMap = f.buttons.new(1)
	g.state.mainPlayer = f.player.new({1, 0, 0})

	g:addUpdater(g.state.mainPlayer, g.state.mainPlayer.updateLocal, g.state.world, g.state.camera)

	g:addRenderer(g.state.world, g.state.world.draw, g.state.camera, "")
	g:addRenderer(g.state.mainPlayer, g.state.mainPlayer.draw, g.state.world, g.state.camera)
	g:addRenderer(g.state.world, g.state.world.draw, g.state.camera, "foreground")

	g.state.mainPlayer:warpTo(31, 55)

	g.state.world.tileset:loadAssetPack("testTiles")
	g.state.terrainGenerator:generateNext(g.state.world, 100)

	return g
end

function game:addUpdater(obj, f, ...)
	if type(f) == "function" then
		local i = #self.renderers + 1
		self.renderers[i] = {self=obj, call=f, ...}
		return i
	end
	return 0
end

function game:addRenderer(obj, f, ...)
	if type(f) == "function" then
		local i = #self.renderers + 1
		self.renderers[i] = {self=obj, call=f, ...}
		return i
	end
	return 0
end

function game:update(delta, k)
	for _, u in ipairs(self.updaters) do
		u.call(unpack(u), u.self, delta, k)
	end
end

function game:draw()
	for _, r in ipairs(self.updaters) do
		r.call(r.self, delta, k, unpack(r))
	end
end

return game
