local terrainGen = {}

local uuidMap = {
	testTiles_dirtInside = "dfba9564-c7a6-4b69-86d5-dfa92bbd2612",
	testTiles_dirtTop = "5da1f15f-76bb-4680-8f5a-b51173ac4ce4",
	testTiles_car = "584a1a1c-19ff-4e23-8cae-cd03b9491a6e",
	testTiles_big = "64b72878-c4be-4e9c-8ba8-37e3654de003",
}

local dirtMap = {

}

function replaceTile(x,y,uuid)

end

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

return terrainGen
