local pd = playdate
local gfx = pd.graphics

-- Player 
local playerX = 40
local playerY = 120
local playerSpeed = 3
local playerImage = gfx.image.new("images/capybara")

-- Buttons
local buttons = {
    {x = 60, y = 200, width = 50, height = 30, selected = false},
    {x = 120, y = 200, width = 50, height = 30, selected = false},
    {x = 180, y = 200, width = 50, height = 30, selected = false}
}
local currentButtonIndex = 1

function pd.update()
    gfx.clear()
    
    -- Handle crank position for player movement
    local crankPosition = pd.getCrankPosition()
    if crankPosition > 90 or crankPosition > 270 then
        playerY -= playerSpeed
    else 
        playerY += playerSpeed
    end
    playerImage:draw(playerX, playerY)
    
    -- Handle d-pad input for button selection
    if pd.buttonJustPressed(pd.kButtonLeft) then
        currentButtonIndex = math.max(1, currentButtonIndex - 1)
    elseif pd.buttonJustPressed(pd.kButtonRight) then
        currentButtonIndex = math.min(#buttons, currentButtonIndex + 1)
    end
    
    -- Handle A and B button input for selection/deselection
    if pd.buttonJustPressed(pd.kButtonA) then
        buttons[currentButtonIndex].selected = not buttons[currentButtonIndex].selected
    elseif pd.buttonJustPressed(pd.kButtonB) then
        buttons[currentButtonIndex].selected = false
    end
    
    -- Draw buttons
    for i, button in ipairs(buttons) do
        if button.selected then
            gfx.setColor(gfx.kColorBlack)
        else
            gfx.setColor(gfx.kColorWhite)
        end
        gfx.fillRect(button.x, button.y, button.width, button.height)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(button.x, button.y, button.width, button.height)
    end
end