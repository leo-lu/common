--转成格子坐标
--pos 点击地图的像素坐标
local function tiledForPos(map, pos)
    local mapSize = map:getMapSize()
    local tileSize = map:getTileSize()

    cclog("mapSize: " .. mapSize.width .. "  " .. mapSize.height)
    cclog("tileSize: " .. tileSize.width .. "  " .. tileSize.height)

	local halfMapWidth = mapSize.width * 0.5
	local mapHeight = mapSize.height
	local tileWidth = tileSize.width
	local tileHeight = tileSize.height


	local tilePosDiv = cc.p(pos.x / tileWidth, pos.y / tileHeight)
	local inverseTileY = mapHeight - tilePosDiv.y

	--将得到的计算结果转换成 int，以确保得到的是整数
	local posX = math.floor(inverseTileY + tilePosDiv.x - halfMapWidth)
	local posY = math.floor(inverseTileY - tilePosDiv.x + halfMapWidth)
	--确保坐标在地图的边界之内
	posX = math.max(0, posX)
	posX = math.min(mapSize.width - 1, posX)
	posY = math.max(0, posY)
	posY = math.min(mapSize.height - 1, posY);

	return cc.p(posX, posY)
end