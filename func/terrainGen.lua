local terrainGen = {}

local cave = require("func.generation.basicGen")

local uuidMap = {
	testTiles_dirtInside = "dfba9564-c7a6-4b69-86d5-dfa92bbd2612",
	testTiles_dirtTop = "5da1f15f-76bb-4680-8f5a-b51173ac4ce4",
	stone="b36a8bae-bd43-4d78-9d15-307de8e2d900",
	testTiles_car = "584a1a1c-19ff-4e23-8cae-cd03b9491a6e",
	testTiles_big = "64b72878-c4be-4e9c-8ba8-37e3654de003",
}

function terrainGen.new(seed)
	return setmetatable({
		seed = seed,
		lastX = 0,
	}, {__index=terrainGen})
end

function terrainGen:generateNext(world, amount)
	for y = self.lastX, self.lastX+amount do
		if y < 50 then
			for x = 1, world.width do
				world:setBlock(x, y, world.tileset.uuids[uuidMap[math.random() > 0.99 and "testTiles_car" or (y == 49 and "testTiles_dirtTop" or "testTiles_dirtInside")]])
			end
		elseif y == 50 then
			world:setBlock(48, y, world.tileset.uuids[uuidMap["testTiles_big"]])
		elseif y == 51 then
			world:setBlock(15, y, world.tileset.uuids[uuidMap["testTiles_car"]])
		else
			world:newRow(y)
		end
	end
end

--todo
--multi tile setup
--tile surroundings thing
--integrate entities into worldgen

function terrainGen:loadIntoWorld(world,tiles)
	
	world:clear()
	local size = tiles:getSize()
	for y=1, size.y do 
		for x=1, size.x do 
			if tiles:get(x,y) then
				if tiles:get(x,y) == "dirt" then 
					world:setBlock(x,y, world.tileset.uuids[uuidMap["testTiles_dirtTop"]])
				else
					world:setBlock(x,y, world.tileset.uuids[uuidMap["stone"]])
				end
			end
		end
	end
	--takes a g2d and loads it into the world

end

return terrainGen
