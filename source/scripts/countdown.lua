local pd <const> = playdate
local gfx <const> = pd.graphics


countdownTimer = pd.timer.new(6000)
countdownTimer:pause()

local timeSprite = gfx.sprite.new()

class("Countdown").extends()

function Countdown:createCountdownDisplay()
    self:updateCountdownDisplay()
    timeSprite:setCenter(0,0)
    timeSprite:moveTo(180,20)
    timeSprite:add()
end

function Countdown:startTimer()
    countdownTimer:start()
end

function Countdown:updateCountdownDisplay()
    timeText = "Time Left: "..countdownTimer.timeLeft
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