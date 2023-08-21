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
    self:addState("climb", 3,3)
    self:playAnimation() -- we call this line to make sure the animation is really getting played

    -- sprite properties
    self:moveTo(x, y)
    self:setCollideRect(3,3,10,13)

    --physics 
    self.xVelocity = 0
    self.yVelocity = 0
    self.gravity = 1.0
    self.maxSpeed = 3.0
    self.jumpVelocity = -8
    self.drag = 0.1
    self.minimumAirSpeed = 0.5

    self.jumpBufferAmount = 5
    self.jumpBuffer = 0


    -- player State
    self.touchingGround = false
    self.touchingCeiling = false
    self.touchingWall = false 
    self.dead = false
    self.doubleJumpAvailable = true 
    self.climbAvailable = false
   

end


function Player:collisionResponse(other)
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
    elseif self.currentState == "climb" then
        self:handleGroundInput()
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
                self.doubleJumpAvailable = true
                self.touchingGround = true
                elseif collision.normal.y == 1 then
                    self.touchingCeiling = true
                end
            end
            if collision.normal.x ~= 0 then
                self.climbAvailable = true
                self.touchingWall = true
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
        self.gameManager:enterRoom("north")
    elseif self.y > 240 then
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
    end)
end

-- input helper functions
function Player:handleGroundInput()
    if self:playerJumped() then
        self:changeToJumpState()
    elseif pd.buttonIsPressed(pd.kButtonB) and self.climbAvailable then
        self:changeToClimbState()
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        self:changeToRunState("left")
    elseif pd.buttonIsPressed(pd.kButtonRight)  then
        self:changeToRunState("right") 
    else
        self:changeToIdleState()
    end
end

function Player:handleAirInput()
    if self:playerJumped() and self.doubleJumpAvailable then
        self.doubleJumpAvailable = false
        self:changeToJumpState()
    elseif pd.buttonJustPressed(pd.kButtonB)  then
        print("b button is pressed")
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        self.xVelocity = -self.maxSpeed
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        self.xVelocity = self.maxSpeed
    end
end

function Player:changeToJumpState()
     self.yVelocity = self.jumpVelocity
        self.jumpBuffer = 0
        self:changeState("jump")
end

-- state Transitions 
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

function Player:changeToClimbState()
    print("now were climbing with power !")

end

function Player:changeToFallState()
    self:changeState("jump")
end


-- physics helper functions 
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