local pd <const> = playdate
local gfx <const> = pd.graphics
local isRunning = true -- turn this on in production 

class('titleMenu').extends()


function titleMenu:titleLogo()
    local titleLogo = gfx.image.new("images/title")
    local titleSprite = gfx.sprite.new(titleLogo)
    titleSprite:moveTo(200,80)
    titleSprite:add()
end


-- gfx.drawText("the Game", 160, 80)

local gridview = pd.ui.gridview.new(0,32)

local titleMenuOptions = {"start", "about", "quit"}


gridview:setNumberOfRows(#titleMenuOptions)
gridview:setCellPadding(4,4,4,4)

gridview.backgroundImage = gfx.nineSlice.new("images/menuBG", 7,7,18,18)
gridview:setContentInset(5,5,5,5)

local gridviewSprite = gfx.sprite.new()
gridviewSprite:setCenter(0,0)
gridviewSprite:moveTo(100,130)
gridviewSprite:add()

function gridview:drawCell(section, row, column, selected, x, y, width, height)
if selected then
        gfx.fillRoundRect(x, y, width, height, 4)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
else
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
end
local fontHeight = gfx.getSystemFont():getHeight()
gfx.drawTextInRect(titleMenuOptions[row], x, y + (height/2 - fontHeight/2) + 2, width, height, nil, nil, kTextAlignment.center)
end


function gridview:titleMenuInput()

        if pd.buttonJustPressed(pd.kButtonUp) then
            gridview:selectPreviousRow(true)
        elseif pd.buttonJustPressed(pd.kButtonDown) then
            gridview:selectNextRow(true)
        elseif pd.buttonJustPressed(pd.kButtonA) then
            menuSelection = gridview:getSelectedRow() 
        end
    
        if menuSelection == 1 then
            GameScene:startGame()
            isRunning = false
        end
    
   
end

function titleMenu:update()

    self:titleLogo()

    if isRunning then
        gridview:titleMenuInput()
    end
      

    if gridview.needsDisplay then
        local gridviewImage = gfx.image.new(200, 100)
        gfx.pushContext(gridviewImage)
        gridview:drawInRect(0, 0, 200, 100)
            gfx.popContext()
        gridviewSprite:setImage(gridviewImage)
    end


end
