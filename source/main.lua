import "title"

local pd = playdate
local gfx = pd.graphics

-- Game state
local gameState = "title" -- Possible states: "title", "game", "collision", "end"

-- Player 
local playerX = 40
local playerY = 120
local playerSpeed = 3
local playerImage = gfx.image.new("images/capybara")

-- Enemies
local enemyImage = gfx.image.new("images/rock")
local enemies = {}
local enemySpeed = 2
local numEnemies = 5

-- Initialize enemies
for i = 1, numEnemies do
    table.insert(enemies, {
        x = 400 + math.random(0, 200),
        y = math.random(0, 240)
    })
end

-- Buttons
local buttons = {
    {x = 40, y = 200, width = 100, height = 30, selected = false, text = "Rock"},
    {x = 150, y = 200, width = 100, height = 30, selected = false, text = "Paper"},
    {x = 260, y = 200, width = 100, height = 30, selected = false, text = "Scissors"}
}
local currentButtonIndex = 1

function pd.update()
    gfx.clear()
    
    if gameState == "title" then
        -- Title screen update
        titleUpdate()
        
        -- Check for button press to start the game
        if pd.buttonJustPressed(pd.kButtonA) then
            gameState = "game"
        elseif pd.buttonJustPressed(pd.kButtonB) then
            gameState = "end"
        end
    elseif gameState == "game" then
        -- Main game update
        -- Handle crank position for player movement
        local crankPosition = pd.getCrankPosition()
        if crankPosition > 90 or crankPosition > 270 then
            playerY -= playerSpeed
        else 
            playerY += playerSpeed
        end
        playerImage:draw(playerX, playerY)
        
        -- Update enemy positions
        for _, enemy in ipairs(enemies) do
            enemy.x -= enemySpeed
            if enemy.x < -enemyImage.width then
                enemy.x = 400 + math.random(0, 200)
                enemy.y = math.random(0, 240)
            end
            enemyImage:draw(enemy.x, enemy.y)
            
            -- Check for collision with player
            if math.abs(playerX - enemy.x) < enemyImage.width and math.abs(playerY - enemy.y) < enemyImage.height then
                gameState = "collision"
            end
        end
    elseif gameState == "collision" then
        -- Display buttons
        for i, button in ipairs(buttons) do
            if button.selected then
                gfx.setColor(gfx.kColorBlack)
            else
                gfx.setColor(gfx.kColorWhite)
            end
            gfx.fillRoundRect(button.x, button.y, button.width, button.height, 5)
            gfx.setColor(gfx.kColorBlack)
            gfx.drawRoundRect(button.x, button.y, button.width, button.height, 5)
            
            -- Draw button text
            local textWidth, textHeight = gfx.getTextSize(button.text)
            gfx.drawText(button.text, button.x + (button.width - textWidth) / 2, button.y + (button.height - textHeight) / 2)
        end
        
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
    elseif gameState == "end" then
        -- End screen update
        gfx.drawText("Thanks for playing!", 100, 120)
    end
end