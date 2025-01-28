local pd = playdate
local gfx = pd.graphics

-- Player 
 local playerX = 40
 local playerY = 120
 local playerImage = gfx.image.new("images/capybara")

function pd.update()
    playerImage:draw(playerX, playerY)
end