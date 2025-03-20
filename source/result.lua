local result = {}

local pd = playdate
local gfx = pd.graphics
local resultText = ""

function result.update()
    gfx.clear()
    gfx.drawText(resultText, 150, 80)

    if pd.buttonJustPressed(pd.kButtonA) then
        resultText = ""

        if enemyHealth > 0 then
            return "combat"
        else
            score += 1 -- Increase score ONLY when an enemy is defeated
            initializeEnemies() -- Reset enemies correctly
            return "game"
        end
    end
    return "result"
end