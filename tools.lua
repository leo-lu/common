--region tools.lua
--Author : wzc
--Date   : 2015/1/27
--此文件由[BabeLua]插件自动生成
--endregion

module( ..., package.seeall )

local Tools = _M

function Tools:search (k, plist)
    for i=1, table.getn( plist ) do
        local v = plist[i][k]
		if v ~= nil then
			return v
		end
    end
end


function Tools:extend( child, parents )
    if child == nil or parents == nil then
        return
    end
    setmetatable( child, { __index = function( t, k ) 
        return self:search( k, parents ) 
    end } )
end


function Tools:tableFind( table, target )
    for k, v in pairs( table ) do
        if v == target then
            return true
        end
    end
    return false
end


function Tools:connectionTable( tableA, tableB )
    if tableA == nil or tableB == nil then
        return tableA
    end
    for k, v in ipairs( tableB ) do
        table.insert( tableA, v )
    end
    return tableA
end


--时间格式化
function Tools:formatTime( time )
    local t = {}
    t.h = math.floor( time / 3600 )
    t.m = math.floor( math.mod( time , 3600 ) / 60 )
    t.s = math.mod( time , 60 )
    return t
end


--分割字符串
function Tools:Split( szFullString, szSeparator, isToNumber )
    if string.len( szFullString ) == 0 then
        return
    end

    if nil == isToNumber then isToNumber = true end
    
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find( szFullString, szSeparator, nFindStartIndex )
        if not nFindLastIndex then
            if isToNumber then
                nSplitArray[nSplitIndex] = tonumber( string.sub(szFullString, nFindStartIndex, string.len( szFullString ) ) )
            else
                nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len( szFullString ) )
            end
            break
        end
        if isToNumber then
            nSplitArray[nSplitIndex] = tonumber( string.sub( szFullString, nFindStartIndex, nFindLastIndex - 1 ) )
        else
            nSplitArray[nSplitIndex] = string.sub( szFullString, nFindStartIndex, nFindLastIndex - 1 )
        end
        nFindStartIndex = nFindLastIndex + string.len( szSeparator )
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

--插入数字
function Tools:convertStr(str, valueList)
    if str == nil or valueList == nil then
        return
    end
    for i=0, #valueList-1 do
        local k = "{"..i.."}"
        str = string.gsub(str,k,tostring(valueList[i+1]))
    end
    return str
end

--置灰
function Tools:setGrayed( targetSpirte ,isGrayed )
    if targetSpirte == nil or isGrayed == nil then
        return
    end

    if isGrayed then
        local glProgam = cc.GLProgram:createWithFilenames( "Shaders/example_greyScale.vsh", "Shaders/example_greyScale.fsh" )
        glProgam:link() 
        glProgam:updateUniforms()
        local glprogramstate = cc.GLProgramState:getOrCreateWithGLProgram( glProgam )
        targetSpirte:setGLProgramState( glprogramstate )
        glprogramstate:release()
    else
        targetSpirte:setGLProgram( cc.GLProgramCache:getInstance():getGLProgram( "ShaderPositionTextureColor_noMVP" ) )
    end
end


--角度转弧度
function Tools:degreesToRadians( angle )
    return angle * 0.01745329252
end


--弧度转角度
function Tools:radiansToDegrees( angle )
    return angle * 57.29577951
end

function Tools:RFConvertR( rf )
    local r = rf.angle
    if rf.isFlipX and not rf.isFlipY then
        r = r + 90
    elseif rf.isFlipX and rf.isFlipY then
        r = r + 180
    elseif not rf.isFlipX and rf.isFlipY then
        r = r + 270
    end

    return r
end

--画弧
function Tools:drawRadian( drawNode, center ,radius, color, startAngle, endAngle, segments, scaleX, scaleY )
    segments = segments or 100
    scaleX = scaleX or 1
    scaleY = scaleY or 1
    startAngle = startAngle or 0
    endAngle = endAngle or 360

    startAngle = self:degreesToRadians( startAngle )
    endAngle = self:degreesToRadians( endAngle )

    local angle = endAngle - startAngle
    local coef = angle / segments

    local vertices = {}
    table.insert( vertices, center )

    for i=0, segments do
        local rads = startAngle + i * coef
        local j = radius * math.cos(rads) * scaleX + center.x
        local k = radius * math.sin(rads) * scaleY + center.y

        table.insert( vertices, cc.p( j, k ) )
    end
    
    drawNode:drawSolidPoly( vertices, table.getn( vertices ), color )
end


--首字母大写
function Tools:getUpFirst( str )
    if not str then
        return ""
    end
    local first = string.sub( str, 1, 1 )
    return string.gsub( str, first, string.upper( first ) )
end


--获取二维数组给定坐标相邻的8个对象
function Tools:getNeighborObj( gArr, pos, t )
    local function getObj( p )
        local gCol = gArr[p.y]
        if nil ~= gCol then
            local obj = gCol[p.x]
            if nil ~= t and 0 ~= obj then
    	        if nil ~= obj and t == obj._elementID then
        	        return obj
                end
            else
                return obj
            end
        end
	    return nil
    end

    local gLT = getObj(cc.p(pos.x - 1, pos.y - 1))
	local gT  = getObj(cc.p(pos.x,     pos.y - 1))
	local gRT = getObj(cc.p(pos.x + 1, pos.y - 1))
	local gL  = getObj(cc.p(pos.x - 1, pos.y))
	local gR  = getObj(cc.p(pos.x + 1, pos.y))
	local gLB = getObj(cc.p(pos.x - 1, pos.y + 1))
	local gB  = getObj(cc.p(pos.x,     pos.y + 1))
	local gRB = getObj(cc.p(pos.x + 1, pos.y + 1))

    return {[1] = gLT, [2] = gT, [3] = gRT, [4] = gL, [5] = gR, [6] = gLB, [7] = gB, [8] = gRB}
end


--获取十字扩散坐标
function Tools:getCrossDiffusionPos( centerPos, radius )
    if centerPos == nil or radius == nil then
        return
    end
    local posList = {}
    for cr=1, radius do
        for r=0, cr do
            local x = r
            local y = cr - r
            table.insert( posList, cc.p( centerPos.x + x, centerPos.y + y ) )
            if x ~= 0 then
                table.insert( posList, cc.p( centerPos.x - x, centerPos.y + y ) )
            end
            if y ~= 0 then
                table.insert( posList, cc.p( centerPos.x + x, centerPos.y - y ) )
            end
            if x ~= 0 and y ~= 0 then
                table.insert( posList, cc.p( centerPos.x - x, centerPos.y - y ) )
            end
        end
    end
    return posList
end

function Tools:addChildForDrop( child, callback, zOrder )
    zOrder = zOrder or 0
    myG.getRunningScene():addChild( child, zOrder )
    child:setPositionY( child:getContentSize().height )
    child:runAction( cc.Sequence:create( cc.EaseBounceOut:create( cc.MoveBy:create( 1, cc.p( 0, -child:getContentSize().height ) ) ),
                                            cc.CallFunc:create( function()
                                                if nil ~= callback then
                                                    callback()
                                                end
                                            end ) ) )
end
--给数字label绑定 setNum 函数；实现加减数字动画
function _M:bindSetNumFun( lblObj )
    function lblObj:setNum( num, delay, callback )
        local curNum =  tonumber( self:getString() )
	    if nil == curNum or curNum == num then
		    return
	    end
	    delay = delay or 1

	    local spwan = math.abs( num - curNum )
	    local dt = delay / spwan
	    local PN = spwan / ( num - curNum )


	    for i = 1, spwan do
		    self:runAction( cc.Sequence:create( cc.DelayTime:create( dt * ( i - 1 ) ),
												     cc.CallFunc:create( function()
												 	    curNum = curNum + PN
												 	    if nil ~= callback then
												 		    callback( curNum )
                                                        else
                                                            self:setString( curNum )
												 	    end
												     end ) ) )
	    end
    end   
end