local pd = playdate
local gfx = pd.graphics

-- Player 
 local playerX = 40
 local playerY = 120
 local playerSpeed = 3
 local playerImage = gfx.image.new("images/capybara")

function pd.update()
    gfx.clear()
    local crankPosition = pd.getCrankPosition()
    if crankPosition > 90 or crankPosition > 270 then
        playerY -= playerSpeed
    else 
        playerY += playerSpeed
    end
    playerImage:draw(playerX, playerY)
end