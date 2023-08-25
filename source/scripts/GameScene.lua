local pd <const> = playdate 
local gfx <const> = pd.graphics
local ldtk <const> = LDtk


ldtk.load("levels/world.ldtk", nil)

class("GameScene").extends()

function GameScene:init()
    self:goToLevel("Level_0")
    self.spawnX = 2 * 16 
    self.spawnY = 11 * 16

    self.player = Player(self.spawnX, self.spawnY, self)
end

function GameScene:resetPlayer()
    self.player:moveTo(self.spawnX, self.spawnY)
end

function GameScene:enterRoom(direction)
    local level = ldtk.get_neighbours(self.levelName, direction)[1]
    self:goToLevel(level)
    self.player:add()
    local spawnX, spawnY
    if direction == "north" then
        spawnX, spawnY = self.player.x, 240
    elseif direction == "south" then
        spawnX, spawnY = self.player.x, 0
    elseif direction == "east" then
        spawnX, spawnY = 0, self.player.y
    elseif direction == "west" then
        spawnX, spawnY = 400, self.player.y
    end
    self.player:moveTo(spawnX, spawnY)
    self.spawnX = spawnX
    self.spawnY = spawnY
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