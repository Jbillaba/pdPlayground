local pd <const> = playdate 
local gfx <const> = pd.graphics
local ldtk <const> = LDtk
local inDebug <const> = false
local currLevelNumber = 0 

TAGS = {
Player = 1,
Hazard = 2,
Pickup = 3
}

Z_INDEXES = {
Player = 100,
Hazard = 20,
Pickup = 50
}

ldtk.load("levels/world.ldtk", nil)

class("GameScene").extends()

function GameScene:init()
    if inDebug then
    self:startGame()        
    else
        titleMenu:titleLogo()
        titleMenu() 
    end
end


function GameScene:startGame()
    gfx.sprite.removeAll() -- remove menu sprites 
    self:goToLevel("Level_"..currLevelNumber)
end


function GameScene:goToNextLevel()
    gfx.sprite.removeAll()
    currLevelNumber += 1 
    self:goToLevel("Level_"..currLevelNumber)
end

function GameScene:enterRoom(direction)
    local level = ldtk.get_neighbours(self.levelName, direction)[1]
    self:goToLevel(level)
end

function GameScene:goToLevel(level_name)
    gfx.sprite.removeAll()
    -- Countdown:createCountdownDisplay()

    self.levelName = level_name
    for layer_name, layer in pairs(ldtk.get_layers(level_name)) do 
        if layer.tiles then
            local tileMap = ldtk.create_tilemap(level_name, layer_name)

            local layerSprite = gfx.sprite.new()
            layerSprite:setTilemap(tileMap)
            layerSprite:setCenter(0, 0)
            layerSprite:moveTo(0, 0)
            layerSprite:setZIndex(layer.zIndex)
            layerSprite:add()

            local emptyTiles = ldtk.get_empty_tileIDs(level_name, "Solid", layer_name)
            if emptyTiles then
                gfx.sprite.addWallSprites(tileMap, emptyTiles)
            end

        end
    end
    for _, entity in ipairs(ldtk.get_entities(level_name)) do
        local entityX, entityY = entity.position.x, entity.position.y
        local entityName = entity.name
        if entityName == "Collectable" then
            item(entityX,entityY,entity)
        elseif entityName == "Player" then
            self.player = Player(entityX,entityY,self)
            self.player:add()
        elseif entityName == "CompletionCake" then
            -- maybe a function should be called ?? who knows 
        end
    end
end

