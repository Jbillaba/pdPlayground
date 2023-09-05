--libraries 
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/nineslice"
import "scripts/libraries/LDtk"
import "scripts/libraries/AnimatedSprite"

--game files 
import "scripts/menuSystem"
import "scripts/GameScene"
import "scripts/player"


local pd <const> = playdate
local gfx <const> = pd.graphics 

menuSystem:title_menu()

function pd.update()
    menuSystem:update()
    gfx.sprite.update()
    pd.timer.updateTimers()
end