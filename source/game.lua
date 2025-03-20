local game = {} -- Ensure 'game' is defined as a table

local pd = playdate
local gfx = pd.graphics
local spr = gfx.sprite

function game.update()
    gfx.clear()
    
    -- Player Movement
    if pd.buttonIsPressed(pd.kButtonUp) then playerY -= playerSpeed end
    if pd.buttonIsPressed(pd.kButtonDown) then playerY += playerSpeed end
    player:moveTo(playerX, playerY)

    -- Enemy Movement
    for _, enemy in ipairs(enemies) do
        local ex, ey = enemy.x, enemy.y
        enemy:moveTo(ex - enemySpeed, ey)

        -- Respawn enemy when off-screen
        if ex < -64 then
            enemy:moveTo(400 + math.random(0, 200), math.random(0, 240))
        end
    end

    -- Update Sprites
    playdate.graphics.sprite.update()

    return "game" -- Ensure game state stays in "game"
end

return game -- Ensure the module is returned correctly