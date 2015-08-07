--region tools.lua
--Author : wzc
--Date   : 2015/1/27
--此文件由[BabeLua]插件自动生成
--endregion

module( ..., package.seeall )
local Tools     = _M
local DIC_TAG   = "dic@"

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

function Tools:formatDate( dt )
    local t = {}
    t.y = os.date("%Y", dt)
    t.m = os.date("%m", dt)
    t.d = os.date("%d", dt)
    t.H = os.date("%H", dt)
    t.M = os.date("%M", dt)
    t.S = os.date("%S", dt)
    return t, t.y.."-"..t.m.."-"..t.d.." "..t.H..":"..t.M..":"..t.S
end

function Tools:convertToTime( str )
    if nil == str or "" == str then return 0 end

    local dt    = self:Split( str, " ", false )
    local date  = self:Split( dt[1], "/", false )
    local time  = self:Split( dt[2], ":", false )

    local Y = date[1]
    local M = date[2]
    local D = date[3]
    local H = time[1]
    local MM = time[2]
    local SS = time[3]

    return os.time{ year = Y, month = M, day = D, hour = H, min = MM, sec = SS }
end

--分割字符串
function Tools:Split( szFullString, szSeparator, isToNumber )
    if szFullString == nil or string.len( szFullString ) == 0 then
        return {}
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

--富文本
function Tools:richTextConvertStr(str, valueList, ccSize, fontSize)
    local str = self:convertStr(str, valueList)
    return require("component/richText"):create(str, ccSize, fontSize)
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
    else
        targetSpirte:setGLProgram( cc.GLProgramCache:getInstance():getGLProgram( "ShaderPositionTextureColor_noMVP" ) )
    end
end


--Button置灰
function Tools:setButtonGrayed( targetButton ,isGrayed )
    self:setGrayed( targetButton:getVirtualRenderer():getSprite(), isGrayed )
    targetButton:setHighlighted( true )
    self:setGrayed( targetButton:getVirtualRenderer():getSprite(), isGrayed )
    targetButton:setHighlighted( false )
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
    return string.gsub( str, first, string.upper( first ), 1, 1 )
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

function Tools:showWithAction( target, enum, callback )
    enum = enum or LayerActionEnum.Normal

    local function call()
        if nil ~= callback then
            callback()
        end
    end

    local switch = {
        [LayerActionEnum.Normal] = function()
            call()
        end,
        [LayerActionEnum.Drop] = function()
            target:setPositionY( g_winH )
            target:runAction( cc.Sequence:create( cc.EaseBounceOut:create(
                                                  cc.MoveBy:create( 0.8, cc.p( 0, -g_winH ) ) ),
                                                  cc.CallFunc:create( function()
                                                        call()
                                                  end ) ) )
        end,
        [LayerActionEnum.Scale] = function()
            target:setScale( 0.2 )
            local aPos = target:getAnchorPoint()
            target:setAnchorPoint( 0.5, 0.5 )
            local tPos = myG.Helper:getPosition( target )
            target:setPosition( ( 0.5 - aPos.x ) * target:getContentSize().width + tPos.x,
                                ( 0.5 - aPos.y ) * target:getContentSize().height + tPos.y )
            target:runAction( cc.Sequence:create( cc.EaseBackOut:create(
                                                  cc.ScaleTo:create( 0.35, 1 ) ),
                                                  cc.CallFunc:create( function()
                                                        call()
                                                  end ) ) )
        end,
    }
    local action = switch[enum]
    if nil ~= action then
        action()
    end
end

function Tools:hideWithAction( target, enum, callback )
    enum = enum or LayerActionEnum.Normal

    local function call()
        if nil ~= callback then
            callback()
        end
    end

    local switch = {
        [LayerActionEnum.Normal] = function()
            call()
        end,
        [LayerActionEnum.Drop] = function()
            target:setPositionY( g_winH )
            target:runAction( cc.Sequence:create( cc.EaseBounceOut:create(
                                                  cc.MoveBy:create( 0.8, cc.p( 0, g_winH ) ) ),
                                                  cc.CallFunc:create( function()
                                                        call()
                                                  end ) ) )
        end,
        [LayerActionEnum.Scale] = function()
            target:runAction( cc.Sequence:create( cc.EaseBackIn:create(
                                                  cc.ScaleTo:create( 0.35, 0.2 ) ),
                                                  cc.CallFunc:create( function()
                                                        call()
                                                  end ) ) )
        end,
    }
    local action = switch[enum]
    if nil ~= action then
        action()
    end
end

--给数字label绑定 setNum 函数；实现加减数字动画
function _M:bindSetNumFun( lblObj )
    function lblObj:setNum( curNum, num, delay, callback )
        if nil == curNum then
            curNum =  tonumber( self:getString() )
        end
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

function Tools:convertDictionary( root )
    local childList = root:getChildren()
    if #childList > 0 then
        for k, v in ipairs( childList ) do
            if v:getDescription() == "Label" then
                local text = v:getString()
                if text:find( DIC_TAG ) then
                    local dicText = self:Split( myG.getStrForDictionary( v:getString() ), "@", false )
                    if nil ~= dicText then
                        v:setString( myG.getStrForDictionary( dicText[2] ) )
                    end
                end
            end
            self:convertDictionary( v )
        end
    end
end

--互斥按钮
function Tools:createMutexButton( mutexButtonList, selectIndex, eventCallback )    
    local function mutexButtonCallback( sender, eventType )
--        local arrow = mutexButtonList[selectIndex]:getChildByTag( 1 )
        if eventType == ccui.CheckBoxEventType.selected then
--            if arrow then
--                arrow:setVisible( false )
--            end
            mutexButtonList[selectIndex]:setSelected( false )
            selectIndex = sender.lua_index
--            arrow = mutexButtonList[selectIndex]:getChildByTag( 1 )
--            if arrow then
--                arrow:setVisible( true )
--            end
            eventCallback( sender, eventType )
        else
            mutexButtonList[selectIndex]:setSelected( true )
        end
        
    end

    for idx, cbx in ipairs( mutexButtonList ) do
        cbx.lua_index = idx
        cbx:addEventListener( mutexButtonCallback )
    end
    mutexButtonList[selectIndex]:setSelected( true )
end
--检查TableView内的点击是否有效（滑出tableView外的内容点击无效）
function Tools:checkTouchValid(obj)
    local pos = obj:getTouchEndPosition()

    local function checkPos( obj_, pos_ )
        local affectByClipping = false
        local node = obj_:getParent()
        local clippingParent = nil
        while node do
            if nil ~= node.isClippingEnabled and node.isClippingEnabled then
                affectByClipping = true
                clippingParent = node
                break
            end
            node = node:getParent()
        end

        if not affectByClipping then
            return true
        end    

        local function hitTest(obj, pt)
            local nsp = obj:convertToNodeSpace(pt)
            local size = obj:getContentSize()
            local rect = cc.rect( 0, 0, size.width, size.height )

            if (cc.rectContainsPoint( rect, nsp)) then
                return true
            end
            return false
        end

        if clippingParent then
            local bRet = false

            if hitTest(clippingParent, pos_) then
                bRet = true
            end

            if bRet then
                return checkPos(clippingParent, pos_);
            end

            return false
        end

        return true
    end

    return checkPos( obj, pos )
end

local isOpeLog = true
function Tools:createTimer()
    local timer = {}
    timer.cur = os.clock()
    timer.isOpeLog = isOpeLog
    timer.log = function( str )
                    if timer.isOpeLog == false then
                        return
                    end
                    str = str or ""
                    cclog( "[Timer Log] "..str.." "..( os.clock() - timer.cur ) )
                    timer.cur = os.clock()
                end
    return timer
end


--拆分字符串
function Tools:splitWord(str)
    local len = #str
    local left = 0
    local arr = { 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
    local t = {}
    local start = 1
    local wordLen = 0
    while len ~= left do
        local tmp = string.byte(str, start)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                break
            end
            i = i - 1
        end
        wordLen = i + wordLen
        local tmpString = string.sub(str, start, wordLen)
        start = start + i
        left = left + i
        t[#t + 1] = tmpString
    end
    return t
end

