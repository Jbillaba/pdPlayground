local pd <const> = playdate
local gfx <const> = pd.graphics
local titleMenuOptions = {"start game", "about"}
local battleMenuOptions = {"attack", "defend", "run"}

class('menuSystem').extends()


-- from here these functions will only be called on to draw the menu they will have seperate functions to handle the logic and buttons 
function menuSystem:title_menu(section, row, column, selected, x,y, width, height)
     gridview = pd.ui.gridview.new(0,32)
     gridviewSprite = gfx.sprite.new()

    gridview:setNumberOfRows(#titleMenuOptions)
    gridview:setCellPadding(4,4,6,6)
    
    gridview.backgroundImage = gfx.nineSlice.new("images/menuBG", 7,7,18,18)
    gridview:setContentInset(5,5,5,5)
    
    gridviewSprite:setCenter(0,0)
    gridviewSprite:moveTo(100,130)
    gridviewSprite:add()
    

    if selected then
        gfx.fillRoundRect(x, y, width, height, 4)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    else 
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    end
    -- local fontHeight = gfx.getSystemFont():getHeight()
    -- gfx.drawTextInRect(titleMenuOptions[row], x, y + (height/2 - fontHeight/2) + 2, width, height, nil, nil, kTextAlignment.center)
end

function menuSystem:titleMenuInput()
    if pd.buttonJustPressed(pd.kButtonUp) then
        gridview:selectPreviousRow(true)
    elseif pd.buttonJustPressed(pd.kButtonDown) then
        gridview:selectNextRow(true)
    elseif pd.buttonJustPressed(pd.kButtonA) then
        selection = gridview:getSelectedRow()  
    end
    
    
end

function menuSystem:update()

    self:titleMenuInput()

    if gridview.needsDisplay then
        local gridviewImage = gfx.image.new(200, 100)
        gfx.pushContext(gridviewImage)
            gridview:drawInRect(0, 0, 200, 100)
        gfx.popContext()
        gridviewSprite:setImage(gridviewImage)
    end

end