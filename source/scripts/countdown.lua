local pd <const> = playdate
local gfx <const> = pd.graphics


local countdown = pd.timer.new(6000)
countdown:pause()

local timeSprite = gfx.sprite.new()

class("Countdown").extends()

function Countdown:createCountdownDisplay()
    print(countdown.timeLeft)
    self:updateCountdownDisplay()
    timeSprite:setCenter(0,0)
    timeSprite:moveTo(180,20)
    timeSprite:add()
end

function Countdown:startTimer()
    countdown:start()
end

function Countdown:updateCountdownDisplay()
    timeText = "Time Left: "..countdown.timeLeft
    local textWidth, textHeight = gfx.getTextSize(timeText)
    timeImage = gfx.image.new(textWidth,textHeight)
    gfx.pushContext(timeImage)
        gfx.drawText(timeText,0,0)
    gfx.popContext()
    timeSprite:setImage(timeImage)
end


function Countdown:update()
    self:updateCountdownDisplay()
end