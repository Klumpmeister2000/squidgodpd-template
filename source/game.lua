local game = {} -- Ensure 'game' is defined as a table

-- Define player speed
local playerSpeed = 2

local pd = playdate
local gfx = pd.graphics
local spr = gfx.sprite

-- Initialize player sprite
local player = spr.new()
local playerImage = gfx.image.new("images/spaceman.png")
assert(playerImage, "Error: Could not load player image at 'images/spaceman.png'")
player:setImage(playerImage) -- Ensure the image path is correct
player:moveTo(200, 120) -- Initial position
player:add()
local playerX, playerY = 200, 120 -- Track player position

-- Initialize enemies
local enemies = {}
local enemySpeed = 1 -- Define enemy speed
for i = 1, 5 do
    local enemy = spr.new()
    local enemyImage = gfx.image.new("images/spaceworm.png")
    assert(enemyImage, "Error: Could not load enemy image at 'images/spaceworm.png'")
    enemy:setImage(enemyImage) -- Ensure the image path is correct
    enemy:moveTo(400 + math.random(0, 200), math.random(0, 240))
    enemy:add()
    table.insert(enemies, enemy)
end

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