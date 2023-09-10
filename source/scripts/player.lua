local pd <const> = playdate
local gfx <const> = pd.graphics

class("Player").extends(AnimatedSprite)

function Player:init(x, y, gameManager)
    self.gameManager = gameManager

    --state machine
    local playerImageTable = gfx.imagetable.new("images/player-table-16-16")
    Player.super.init(self, playerImageTable) -- init function adds the sprite to the draw list so its automatically handled 

    self:addState("idle", 1, 1)
    self:addState("run", 1, 2, {tickStep = 4}) --tickStep : determines speed of the animation the larger the value -> slower the animation
    self:addState("jump", 3,3)
    self:addState("jumpStomp", 3,3)
    self:playAnimation() -- we call this line to make sure the animation is really getting played

    -- sprite properties
    self:moveTo(x, y)
    self:setZIndex(Z_INDEXES.Player)
    self:setTag(TAGS.Player)
    self:setCollideRect(3,3,10,13)

    --physics 
    self.xVelocity = 0
    self.yVelocity = 0
    self.gravity = 1.0
    self.maxSpeed = 3.0
    self.maxRunSpeed = 6.0
    self.jumpVelocity = -8
    self.drag = 0.1
    self.minimumAirSpeed = 0.5
    self.jumpBufferAmount = 5
    self.jumpBuffer = 0

    --jumpStomp
    self.jumpStompSpeed = 10
    self.jumpStompAvailable = true
    self.dashMinimumSpeed = 3
    self.dashDrag = 0.8    

    -- player State
    self.touchingGround = false
    self.touchingCeiling = false
    self.touchingWall = false 
    self.dead = false
    
   

end


function Player:collisionResponse(other)
    local tag = other:getTag()
    if tag == TAGS.Hazard then
        return gfx.sprite.kCollisionTypeBounce
    elseif tag == TAGS.Pickup then
        return gfx.sprite.kCollisionTypeOverlap
    end
    return gfx.sprite.kCollisionTypeSlide
end

function Player:update() -- this function gets called on automatically if its on the draw list, it works in tandem with the main update function in the main file

    if self.dead then
        return -- if dead this runs and nothing else will be run i guess
    end
    self:updateAnimation()

    self:updateJumpBuffer()
    self:handleState()
    self:handleMovementAndCollisions()
end

function Player:updateJumpBuffer()
    self.jumpBuffer -= 1
    if self.jumpBuffer <=0 then
        self.jumpBuffer = 0
    end
    if pd.buttonJustPressed(pd.kButtonA) then
        self.jumpBuffer = self.jumpBufferAmount
    end
end

function Player:playerJumped()
    return self.jumpBuffer > 0 
end

function Player:handleState()
    if self.currentState == "idle" then
        self:applyGravity()
        self:handleGroundInput()
    elseif self.currentState == "run" then
        self:applyGravity()
        self:handleGroundInput()
    elseif self.currentState == "jump" then
        if self.touchingGround then
            self:changeToIdleState()
        end
        self:applyGravity()
        self:applyDrag(self.drag)
        self:handleAirInput()
    elseif self.currentState == "jumpStomp" then
    self:applyDrag(self.dashDrag)
    if math.abs(self.xVelocity) <= self.dashMinimumSpeed then
        self:changeToFallState()
    end
    end
end

function Player:handleMovementAndCollisions()
    local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

    self.touchingGround = false
    self.touchingCeiling = false
    self.touchingWall = false
    local died = false
    

    for i = 1, length do
        local collision = collisions[i]
        local collisionType = collision.type
        local collisionObject = collision.other
        local collisionTag = collisionObject:getTag()
        
        if collisionType == gfx.sprite.kCollisionTypeSlide then
            if collision.normal.y == -1 then
                self.jumpStompAvailable = true
                self.touchingGround = true
                elseif collision.normal.y == 1 then
                    self.touchingCeiling = true
                end
            end
            if collision.normal.x ~= 0 then
                self.touchingWall = true
            end

            if collisionTag == TAGS.Hazard then
                dead = true 
            elseif collisionTag == TAGS.Pickup then
                collisionObject:pickUp(self)
            end
        end
     
       

    if self.xVelocity < 0 then 
        self.globalFlip = 1 
    elseif self.xVelocity > 0 then
        self.globalFlip = 0
    end

    if self.x < 0 then
        self.gameManager:enterRoom("west")
    elseif self.x > 400 then
        self.gameManager:enterRoom("east")
    elseif self.y < 0 then
        self.yVelocity  = 0
    elseif self.y > 240 then
        self:die()
    end

    if countdownTimer.timeLeft == 0 then
        self:die()
    end

    if died then
        self:die()
    end

end

function Player:die()
    self.xVelocity = 0
    self.yVelocity = 0
    self.dead = true
    self:setCollisionsEnabled(false)
    pd.timer.performAfterDelay(200, function ()
        self:setCollisionsEnabled(true)
        self.dead = false
        self.gameManager:resetPlayer(0)
        countdownTimer:reset()
    end)
end

-- input helper functions
function Player:handleGroundInput()
    if self:playerJumped() then
        self:changeToJumpState()
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        self:changeToRunState("left")
    elseif pd.buttonIsPressed(pd.kButtonRight)  then
        self:changeToRunState("right")
    elseif pd.buttonIsPressed(pd.kButtonLeft) and pd.BButtonHeld() then
        self:changeToSprintState("left")
    elseif pd.buttonIsPressed(pd.kButtonRight)  then
        self:changeToSprintState("right")
        
    else
        self:changeToIdleState()
    end
end

function Player:handleAirInput()
    if self:playerJumped() then
        return
    elseif pd.buttonJustPressed(pd.kButtonDown) and self.jumpStompAvailable then
        self:changeToJumpStompState()
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        self.xVelocity = -self.maxSpeed
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        self.xVelocity = self.maxSpeed
    end
end

-- state functions 

function Player:changeToJumpState()
    self.yVelocity = self.jumpVelocity
    self.jumpBuffer = 0
    self:changeState("jump")
end

function Player:changeToIdleState()
    self.xVelocity = 0
    self:changeState("idle")
end

function Player:changeToRunState(direction)
    if direction == "left" then
        self.xVelocity = -self.maxSpeed
        self.globalFlip = 1
    elseif direction == "right" then
        self.xVelocity = self.maxSpeed
        self.globalFlip = 0
    end
    self:changeState("run")
end

function Player:changeToSprintState(direction)
    if direction == "left" then
        self.xVelocity = -self.maxRunSpeed
        self.globalFlip = 1
    elseif direction == "right" then
        self.xVelocity = self.maxRunSpeed
        self.globalFlip = 0
    end
    self:changeState("run")
    
end

function Player:changeToJumpStompState()
    self.jumpStompAvailable = false
    self.yVelocity = self.jumpStompSpeed
    self:changeState("jumpStomp")
end


function Player:changeToFallState()
    self:changeState("jump")
end

-- physics functions 
function Player:applyGravity() 
    self.yVelocity += self.gravity
        if self.touchingGround or self.touchingCeiling then
            self.yVelocity = 0
        end
end

function Player:applyDrag(amount)
    if self.xVelocity > 0 then
       self.xVelocity -= amount 
    elseif self.xVelocity < 0 then
        self.xVelocity += amount
    end

    if math.abs(self.xVelocity) < self.minimumAirSpeed or self.touchingWall then
        self.xVelocity = 0
    end
end

