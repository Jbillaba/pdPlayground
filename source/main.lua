--libraries 
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "scripts/libraries/LDtk"
import "scripts/libraries/AnimatedSprite"

--game files 
import "scripts/GameScene"
import "scripts/player"


GameScene()


local pd <const> = playdate
local gfx <const> = pd.graphics 

function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
end