local pd <const> = playdate
local gfx <const> = pd.graphics
candlesOnCake = item.candlesCollected

class('Cake').extends(gfx.sprite)

function Cake:init(entityX,entityY)
    self:drawCake(entityX,entityY)
end

function Cake:drawCake(x,y)
    local cakeImage = gfx.image.new("images/Cake")
    assert(cakeImage)

    self:setImage(cakeImage)
    self:moveTo(x,y)
    self:add()
    self:setCollideRect(0,0,self:getSize())
end