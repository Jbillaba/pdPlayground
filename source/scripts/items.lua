local gfx <const> = playdate.graphics
candlesCollected = 0


class("item").extends(gfx.sprite)

function item:init(x,y,entity)
    self.fields = entity.fields
    if self.fields.pickedUp == true then
        return
    end

    self.itemName = self.fields.Collectables
    local itemImage = gfx.image.new("images/"..self.itemName)
    assert(itemImage)

    self.nextLevel = self.fields.LevelName

    self:setImage(itemImage)
    self:setZIndex(Z_INDEXES.Pickup)
    self:setCenter(0,0)
    self:moveTo(x,y)
    self:add()

    self:setTag(TAGS.Pickup)
    self:setCollideRect(5,6,5,6)

end

function item:pickUp(player)
    if  self.itemName == "Usb" then
        print("you got a usb")
        GameScene:goToLevel(self.nextLevel)
    elseif self.itemName == "Candle" then
        candlesCollected += 1 
        GameScene:goToLevel(self.nextLevel)
        print(candlesCollected)
        print("you got a candle !!")
    end
    self.fields.pickedUp = true
    self:remove()
end