local GameScene = Noble.Scene.new("GameScene")
local gfx = playdate.graphics
local spr = playdate.graphics.sprite

-- Load images
local mechImage = gfx.image.new("images/mech")  -- Load the mech sprite
local bulletImage = gfx.image.new("images/bullet")  -- Load the bullet sprite
local shieldImage = gfx.image.new("images/shield")  -- Load the shield effect

-- Create the mech sprite
local mech = spr.new(mechImage)
mech:moveTo(50, 120) -- Start from the left side
mech:add()

-- Variables
local speed = 4  -- Movement speed
local bullets = {} -- Bullet storage
local shieldActive = false
local shieldTimer = nil

function GameScene.enter()
    print("Entered GameScene")
end

function GameScene.update()
    Noble.Scene.update()
    
    -- Get input for movement
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        mech:moveBy(0, -speed)
    elseif playdate.buttonIsPressed(playdate.kButtonDown) then
        mech:moveBy(0, speed)
    end
    
    -- Update bullets
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet:moveBy(8, 0) -- Move bullets right
        if bullet.x > 420 then
            bullet:remove() -- Remove bullets off-screen
            table.remove(bullets, i)
        end
    end
    
    -- Draw the shield if active
    if shieldActive then
        gfx.sprite.new(shieldImage):moveTo(mech.x, mech.y):add()
    end
    
    playdate.graphics.sprite.update() -- Update all sprites
end

function GameScene.buttonDown(button)
    if button == playdate.kButtonA then
        shootBullet()
    elseif button == playdate.kButtonB then
        activateShield()
    end
end

-- Shooting function
function shootBullet()
    local bullet = spr.new(bulletImage)
    bullet:moveTo(mech.x + 20, mech.y)
    bullet:add()
    table.insert(bullets, bullet)
end

-- Shield function (active for 2 seconds)
function activateShield()
    if not shieldActive then
        shieldActive = true
        shieldTimer = playdate.timer.performAfterDelay(2000, function()
            shieldActive = false
        end)
    end
end

return GameScene