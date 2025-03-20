local gameOver = {}

local pd = playdate
local gfx = pd.graphics

function gameOver.update()
    gfx.clear()
    gfx.drawText("Game Over", 150, 100)
    gfx.drawText("Press A to Restart", 120, 140)

    if pd.buttonJustPressed(pd.kButtonA) then
        return "title"
    end
    return "gameOver"
end

return gameOver