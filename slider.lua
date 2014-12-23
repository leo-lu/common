--region ui_itemBag.lua
--Author : lzt
--Date   : 2014/12/18
--此文件由[BabeLua]插件自动生成

local bgPath = DEF_RES_SC_PUBLISH .. "jindutiaoyuhuadongtiao_bar/bar2-2.png"
local blockPath = DEF_RES_SC_PUBLISH .. "jindutiaoyuhuadongtiao_bar/bar2-1.png"

local bgPath1 = DEF_RES_SC_PUBLISH .. "jindutiaoyuhuadongtiao_bar/bar2-2.png"
local blockPath1 = DEF_RES_SC_PUBLISH .. "jindutiaoyuhuadongtiao_bar/bar2-1.png"

g_sliderTypeViewEnum = {
	TABLE_VIEW 	= 1,
	LIST_VIEW	= 2,
}

local dirEnum = {
	vertical	= 1,
	horizontal	= 2,
}

local function getDir(view, type)
	local dir = nil
	if g_sliderTypeViewEnum.TABLE_VIEW == type then
		vSize = view:getViewSize()
    	cSize = view:getContainer():getContentSize()
    	local d = view:getDirection()
    	if d ==  cc.SCROLLVIEW_DIRECTION_HORIZONTAL then
			dir = dirEnum.horizontal
    	elseif d ==  cc.SCROLLVIEW_DIRECTION_VERTICAL then
			dir = dirEnum.vertical
		else
    		return nil
    	end

	elseif g_sliderTypeViewEnum.LIST_VIEW == type then
		view:doLayout()
		vSize = view:getContentSize()
    	cSize = view:getInnerContainer():getContentSize()
    	local d = view:getDirection()
    	if d == ccui.ScrollViewDir.horizontal then
    		dir = dirEnum.horizontal
    	elseif d == ccui.ScrollViewDir.vertical then
			dir = dirEnum.vertical
		else
			return nil
    	end
    else
    	return nil
	end

	return dir
end

local function getVal(dir, vSize, cSize)
	local vVal = nil
	local cVal = nil
	if dir == dirEnum.horizontal then
		vVal = vSize.width
		cVal = cSize.width
	elseif dir == dirEnum.vertical then
		vVal = vSize.height
		cVal = cSize.height
	end

	return vVal, cVal
end

slider = class("slider", function()
	--return cc.LayerColor:create(cc.c4b(0, 255, 120, 120))
	return cc.Layer:create()
end)

function slider:ctor(size, bg, block, vSize, cSize, dir)
	self:setContentSize(size)

	local imgBg = ccui.ImageView:create(bg)
	imgBg:setScale9Enabled(true)
	imgBg:setCapInsets(cc.rect(0, 0, imgBg:getContentSize().width, imgBg:getContentSize().height))
	imgBg:setContentSize(size)
	imgBg:setPosition(size.width/2, size.height/2)
	self:addChild(imgBg)

	local imgBlock = ccui.ImageView:create(block)
	imgBlock:setScale9Enabled(true)
	imgBlock:setCapInsets(cc.rect(0, 0, imgBlock:getContentSize().width, imgBlock:getContentSize().height))

	local posOffset = nil

	local function init(vSize_, cSize_)
		self.vVal, self.cVal = getVal(dir, vSize_, cSize_)
		if self.cVal < self.vVal then self.cVal = self.vVal end

		if dir == dirEnum.horizontal then
			self.blockSize = cc.size(self.vVal/(self.cVal/self.vVal), size.height)
			posOffset = 1 - self.blockSize.width / size.width
			imgBlock:setAnchorPoint(0, 0.5)
			imgBlock:setPosition(0, size.height/2)
		elseif dir == dirEnum.vertical then
			self.blockSize = cc.size(size.width, self.vVal/(self.cVal/self.vVal))
			posOffset = 1 - self.blockSize.height / size.height
			imgBlock:setAnchorPoint(0.5, 1)
			imgBlock:setPosition(size.width/2, size.height)
		end
		
		imgBlock:setContentSize(self.blockSize)
	end
	init(vSize, cSize)
	self:addChild(imgBlock)

	function self:refresh()
		local vSize = nil
    	local cSize = nil
		if g_sliderTypeViewEnum.TABLE_VIEW == self.type then
			vSize = self.view:getViewSize()
	    	cSize = self.view:getContainer():getContentSize()
		elseif g_sliderTypeViewEnum.LIST_VIEW == self.type then
			vSize = self.view:getContentSize()
	    	cSize = self.view:getInnerContainer():getContentSize()
		end

		init(vSize, cSize)
	end

	local bounce = 1
	self:setCascadeOpacityEnabled(true)
	self:setOpacity(0)
	self.show = false
	self.showLastTime = 0
	function self:setValue(val)
		local sVal = nil
		local bVal = nil
		if dir == dirEnum.horizontal then
			sVal = size.width
			bVal = self.blockSize.width
		elseif dir == dirEnum.vertical then
			sVal = size.height
			bVal = self.blockSize.height
		end

		if sVal == bVal then return end
		if 0 ~= val and not self.show then
			self:runAction(cc.FadeIn:create(0.5))

			self.show = true
		end

		if 0 > val then
			local vV = self.vVal * (1 + val)
			local bV = vV/(self.cVal/vV)

			if dir == dirEnum.horizontal then
				imgBlock:setAnchorPoint(1, 0.5)
				imgBlock:setPositionX(size.width)
				imgBlock:setContentSize(cc.size(bV * bounce, self.blockSize.height))
			elseif dir == dirEnum.vertical then
				imgBlock:setAnchorPoint(0.5, 1)
				imgBlock:setPositionY(size.height)
				imgBlock:setContentSize(cc.size(self.blockSize.width, bV * bounce))
			end
		elseif posOffset < val then
			local vV = self.vVal * (1 - val + posOffset)
			local bV = vV/(self.cVal/vV)

			if dir == dirEnum.horizontal then
				imgBlock:setAnchorPoint(0, 0.5)
				imgBlock:setPositionX(0)
				imgBlock:setContentSize(cc.size(bV * bounce, self.blockSize.height))
			elseif dir == dirEnum.vertical then
				imgBlock:setAnchorPoint(0.5, 0)
				imgBlock:setPosition(self.blockSize.width/2, 0)
				imgBlock:setContentSize(cc.size(self.blockSize.width, bV * bounce))
			end
		else
			if dir == dirEnum.horizontal then
				imgBlock:setContentSize(self.blockSize)
				imgBlock:setAnchorPoint(1, 0.5)
				imgBlock:setPositionX(size.width - size.width * val)
			elseif dir == dirEnum.vertical then
				imgBlock:setContentSize(self.blockSize)
				imgBlock:setAnchorPoint(0.5, 1)
				imgBlock:setPositionY(size.height - size.height * val)
			end
		end

		self.showLastTime = os.time()
	end

	local scheduler = cc.Director:getInstance():getScheduler()
    self:registerScriptHandler(function(event)
        if "enter" == event then
		    self.schedulerEntry = scheduler:scheduleScriptFunc(function()
		        if self.show then
		        	local time = os.time()
		        	if 1 == time - self.showLastTime then
		        		self:runAction(cc.FadeOut:create(0.5))
		        		self.show = false
		        	end
		        end
		    end, 1, false )   
        elseif "exit" == event and nil ~= schedulerEntry then
            scheduler:unscheduleScriptEntry(self.schedulerEntry)
        end
	end)
end

function slider:createSlider(size, view, type)
    local bg = nil
    local block = nil
    local vSize = nil
    local cSize = nil

    self.view = view
    self.type = type

	if g_sliderTypeViewEnum.TABLE_VIEW == type then
		vSize = view:getViewSize()
    	cSize = view:getContainer():getContentSize()

	elseif g_sliderTypeViewEnum.LIST_VIEW == type then
		view:doLayout()
		vSize = view:getContentSize()
    	cSize = view:getInnerContainer():getContentSize()
    else
    	return nil
	end

	local dir = getDir(view, type)
	if dir == dirEnum.horizontal then
		bg = bgPath1
    	block = blockPath1
	elseif dir == dirEnum.vertical then
    	bg = bgPath
    	block = blockPath
	end

    local slider = slider.new(size, bg, block, vSize, cSize, dir)

    if g_sliderTypeViewEnum.TABLE_VIEW == type then
		local function scrollViewDidScroll(view)
			local pos = view:getContentOffset()
			local h = slider.vVal/(slider.cVal/slider.vVal)
			local p = nil
			if dir == dirEnum.horizontal then
				p = (slider.cVal - slider.vVal + pos.x)/slider.cVal
			elseif dir == dirEnum.vertical then
				p = (slider.cVal - slider.vVal + pos.y)/slider.cVal
			end
            if nil ~= slider.setValue then
			    slider:setValue(p)
            end
	    end
		view:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    elseif g_sliderTypeViewEnum.LIST_VIEW == type then
		local function scrollViewEvent(sender, evenType)
			if ccui.ScrollviewEventType.scrolling == evenType or
				ccui.ScrollviewEventType.bounceTop == evenType or 
				ccui.ScrollviewEventType.bounceBottom == evenType then
				local x, y = view:getInnerContainer():getPosition()
				local h = slider.vVal/(slider.cVal/slider.vVal)
				local p = nil
				if dir == dirEnum.horizontal then
					p = (slider.cVal - slider.vVal + x)/slider.cVal
				elseif dir == dirEnum.vertical then
					p = (slider.cVal - slider.vVal + y)/slider.cVal
				end
                if nil ~= slider.setValue then
				    slider:setValue(p)
                end
			end
		end
    	view:addScrollViewEventListener(scrollViewEvent)
    end

    return slider
end

return slider