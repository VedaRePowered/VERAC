local genTiles = {}

function genTiles.new()
    return setmetatable({
		tiles = {}
	}, {__index=genTiles})
end

function genTiles:set(x,y,newValue)
    self.tiles[y][x] = newValue
end

function genTiles:get(x,y)
    return self.tiles[y][x]
end

--todo
function genTiles:fill(x1,y1,x2,y2,newValue)

end

function genTiles:merge(x,y,mergeGrid)

end