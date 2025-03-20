local combat = {}

local pd = playdate
local gfx = pd.graphics

local playerImage = gfx.image.new("images/spaceman.png")
local enemyImage = gfx.image.new("images/spaceworm.png")

function combat.update()
    gfx.clear()
    
    -- Draw Sprites
    if playerImage then playerImage:draw(60, 100) end
    if enemyImage then enemyImage:draw(240, 100) end

    -- UI
    gfx.drawText("Choose your move!", 120, 50)

    return "combat"
end

return combat