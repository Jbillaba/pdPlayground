local pd <const> = playdate
local gfx <const> = pd.graphics
local k_right = pd.kButtonRight
local k_left = pd.kButtonLeft
local k_down = pd.kButtonDown
local k_up = pd.kButtonUp


class("Player").extends(AnimatedSprite)

function Player:init(x,y,gameManager)
    self.gameManager = gameManager
    --state machine
    local playerImageTable = gfx.imagetable.new("images/player-table-16-16")
    Player.super.init(self, playerImageTable)

    self:addState("idle", 1,1)
    self:addState("run", 1,2, {tickStep = 4})
    
    self:playAnimation()

    --sprite properties 
    self:moveTo(x,y)
    self:setCollideRect(3,3,10,13)
    self.xVelocity = 0
    self.yVelocity = 0
    self.speed = 2 

end

function Player:update()
    self:updateAnimation()
    self:handleState()
    self:handleMovementAndCollison()
end

function Player:handleState()
    if self.currentState == "idle" then
        self:handleGroundInput()
    elseif self.currentState == "run" then 
        self:handleGroundInput()
    end
end

function Player:handleMovementAndCollison()
    local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

    -- self.touchingWall = false

    -- for i = 1, length do 
        
    --     local collision = collisions[i]
    --     local collisionType = collision.collisionType
    --     local collisionObject = collision.other 
    --     local collisionTag = collisionObject:getTag()
        
    --     if collisionType == gfx.sprite.kCollisionTypeSlide then
    --         self.touchingWall = true
    --     end

    --     if collision.normal.x ~= 0 then
    --         self.touchingWall = true
    --     end

    --     if collisionTag == TAGS.Pickup then
    --         collisionObject:pickUp(self)
    --     end

    -- end
   
    if self.xVelocity < 0 then
        self.globalFlip = 1
    elseif self.xVelocity > 0  then
        self.globalFlip = 0
    end

    -- if self.x < 0 then
    --     self.gameManager:enterRoom("west")
    -- elseif self.x > 400 then
    --     self.gameManager:enterRoom("east")
    -- elseif self.y < 0 then
    --     self.gameManager:enterRoom("north")
    -- elseif self.y > 240 then
    --     self.gameManager:enterRoom("south")
    -- end
end

function Player:handleGroundInput()
    if pd.buttonIsPressed(k_left) then
        self:changeToRunState("left")
    elseif pd.buttonIsPressed(k_right) then
        self:changeToRunState("right")
    elseif pd.buttonIsPressed(k_up) then
        self:changeToRunState("up")
    elseif pd.buttonIsPressed(k_down) then
        self:changeToRunState("down")
    else
        self:changeToIdleState()
    end
end

--state transitions

function Player:changeToIdleState()
    self.xVelocity = 0
    self.yVelocity = 0
    self:changeState("idle")
end

function Player:changeToRunState(direction)
    if direction == "left" then 
        self.xVelocity = -self.speed
        self.globalFlip = 1
    elseif direction == "right" then
        self.xVelocity = self.speed
        self.globalFlip = 0 
    elseif direction == "up" then
        self.yVelocity = -self.speed
    elseif direction == "down" then
        self.yVelocity = self.speed
    end
    self:changeState("run")
end

