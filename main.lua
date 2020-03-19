local f, test, game = {}, {} -- f for 'functions'
function love.load()
	f.game = require "func.game"
	f.game.load()
	f.entity = require "func.entity"
	f.particles = require "func.particles"

	game = f.game.new()

	test.testEntity = f.entity.new(32, 60, 2, 1.5, {"fox.png", "fox2.png", "fox3.png"}, 75, 4, function()s.testEntity.direction = not s.testEntity.direction end)
	test.testEntity.direction = false

	test.testParticles = f.particles.new()
	test.testParticles:add("dirt")
end

function love.update(delta)
	local k = game.state.buttonMap:get()
	game:update(delta, k)
	if test.testEntity.direction then
		test.testEntity:accelerate(-delta*10, 0)
	else
		test.testEntity:accelerate(delta*10, 0)
	end
	if math.random(1, 50) == 1 then
		test.testEntity:accelerate(0, 20)
	end
	test.testEntity:update(game.state.world, delta)

	if math.random() < 0.01 then
		test.testParticles:instance("dirt", game.state.mainPlayer.collider.x, game.state.mainPlayer.collider.y-1)
	end

	test.testParticles:update(delta)
end

function love.draw()
	game:draw()
	test.testEntity:draw(game.state.world, game.state.camera)
	test.testParticles:draw(game.state.camera)
end
