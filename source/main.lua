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
import "scripts/titleMenu"
import "scripts/GameScene"
import "scripts/player"
import "scripts/items"
import "scripts/countdown"


local pd <const> = playdate
local gfx <const> = pd.graphics 

GameScene()

function pd.update()
    titleMenu:update()        
    Countdown:updateCountdownDisplay()
    gfx.sprite.update()
    pd.timer.updateTimers()
end