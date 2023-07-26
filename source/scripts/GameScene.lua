local pd <const> = playdate 
local gfx <const> = pd.graphics
local ldtk <const> = LDtk

ldtk.load("levels/world.ldtk", nil)

class("GameScene").extends()

function GameScene:init()
    self:goToLevel("Level_0")
    self.spawnX = 12 * 16 
    self.spawnY = 7 * 16

    self.player = Player(self.spawnX, self.spawnY, self)
end


function GameScene:goToLevel(level_name)
    gfx.sprite.removeAll()

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
end