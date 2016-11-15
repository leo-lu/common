local VituualControl = class("VituualControl", cc.Layer)  
  
function VituualControl:ctor(app, name)
    if self.onCreate then self:onCreate() end  
end  
  
function VituualControl:onTouchesEnded(touches, event )  
    self:_deactive()  
end  
  
function VituualControl:onTouchesBegan(touches, event )  
    self.start_pos = cc.p(touches[1]:getLocation())  
    self:_active(self.start_pos)  
end  
  
function VituualControl:onTouchesMove(touches, event )  
    local pos = cc.p(touches[1]:getLocation())  
    local distance = cc.pGetDistance(self.start_pos,pos)  
    local direction = cc.pNormalize(cc.pSub(pos,self.start_pos))  
    self:_update(direction,distance)
end  
  
  
function VituualControl:onCreate()  
    self.joystick = cc.Sprite:create( "res/block.png")
    self.joystick:setScale(0.2,0.2)  
    self.joystick_bg = cc.Sprite:create( "res/HelloWorld.png")
    self.joystick_bg:setScale(0.3,0.3)  
    self:addChild(self.joystick_bg)  
    self:addChild(self.joystick)
  
    local listener = cc.EventListenerTouchAllAtOnce:create()  
      
    listener:registerScriptHandler(function(...) self:onTouchesBegan(...) end,cc.Handler.EVENT_TOUCHES_BEGAN  )  
    listener:registerScriptHandler(function(...) self:onTouchesEnded(...) end,cc.Handler.EVENT_TOUCHES_ENDED  )  
    listener:registerScriptHandler(function(...) self:onTouchesMove(...) end,cc.Handler.EVENT_TOUCHES_MOVED  )  
    local eventDispatcher = self:getEventDispatcher()  
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)  
end  
  
function VituualControl:_active(pos)  
    self.joystick:setPosition(pos)  
    self.joystick_bg:setPosition(pos)  
    self.joystick:setVisible(true)  
    self.joystick_bg:setVisible(true)  
end  
  
function VituualControl:_deactive(pos)  
    self.joystick:setVisible(false)  
    self.joystick_bg:setVisible(false)
end  
  
function VituualControl:_update(direction,distance)  
    print("seayoung udpate",direction.x,direction.y,distance)  
    local start = cc.p(self.joystick_bg:getPosition())  
    if distance < 32 then
        self.joystick:setPosition(cc.pAdd(start , (cc.pMul(direction ,distance))))  
    elseif distance > 96 then  
        self.joystick:setPosition(cc.pAdd(start , (cc.pMul(direction ,64))))  
    else  
        self.joystick:setPosition(cc.pAdd(start , (cc.pMul(direction ,32))))
    end
end
  
return VituualControl