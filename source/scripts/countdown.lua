local pd <const> = playdate
local gfx <const> = pd.graphics

local timeSprite = nil
local time = nil

class("Countdown").extends()

function Countdown:createCountdownDisplay()
    self.countdown = pd.timer.new(6000)
    self.countdown:pause()
    self.timeSprite = gfx.sprite.new()
    print(self.countdown.currentTime)
    self:updateCountdownDisplay()
    self.timeSprite:setCenter(0,0)
    self.timeSprite:moveTo(200,20)
    self.timeSprite:add()
end

function Countdown:startTimer()
    self.countdown.start()
end

function Countdown:updateCountdownDisplay()
    self.timeText = "Time Left: "
    local textWidth, textHeight = gfx.getTextSize(self.timeText)
    self.timeImage = gfx.image.new(textWidth,textHeight)
    gfx.pushContext(self.timeImage)
        gfx.drawText(self.timeText,0,0)
    gfx.popContext()
    self.timeSprite:setImage(self.timeImage)
end


function Countdown:update()
    self:updateCountdownDisplay()
end