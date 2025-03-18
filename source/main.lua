import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd = playdate
local gfx = pd.graphics

-- Game state
local gameState = "title" -- Possible states: "title", "game", "collision", "result", "retry", "end"

-- Player 
local playerX = 40
local playerY = 120
local playerSpeed = 3

-- Score
local score = 0

-- Bullets
local bullets = {}
local bulletSpeed = 5

-- Load player image
local playerImage = gfx.image.new("images/spaceman.png")
if not playerImage then
    error("Failed to load player image: images/spaceman.png")
end

-- Load enemy image
local enemyImage = gfx.image.new("images/spaceworm.png")
if not enemyImage then
    error("Failed to load enemy image: images/spaceworm.png")
end

-- Enemies
local enemies = {}
local enemySpeed = 2
local numEnemies = 5

-- Initialize enemies
local function initializeEnemies()
    enemies = {}
    for i = 1, numEnemies do
        table.insert(enemies, {
            x = 400 + math.random(0, 200),
            y = math.random(0, 240)
        })
    end
end

initializeEnemies()

-- Buttons
local buttons = {
    {x = 40, y = 200, width = 100, height = 30, selected = false, text = "Rock"},
    {x = 150, y = 200, width = 100, height = 30, selected = false, text = "Paper"},
    {x = 260, y = 200, width = 100, height = 30, selected = false, text = "Scissors"}
}
local currentButtonIndex = 1
local playerChoice = nil
local enemyChoice = nil
local resultText = ""

-- Define the titleUpdate function
local function titleUpdate()
    gfx.clear()
    gfx.drawText("Welcome to the Game!", 100, 100)
    gfx.drawText("Press A to Start", 100, 140)
    gfx.drawText("Press B to Quit", 100, 160)
end

-- Score
local score = 0

-- Bullets
local bullets = {}
local bulletSpeed = 5

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
        -- Handle d-pad input for player movement
        if pd.buttonIsPressed(pd.kButtonUp) then
            playerY -= playerSpeed -- Move up
        elseif pd.buttonIsPressed(pd.kButtonDown) then
            playerY += playerSpeed -- Move down
        end

        -- Shoot a bullet when A is pressed
        if pd.buttonJustPressed(pd.kButtonA) then
            table.insert(bullets, {x = playerX + 20, y = playerY + 10}) -- Spawn bullet near the player
        end

        -- Update and draw bullets
        for i = #bullets, 1, -1 do
            local bullet = bullets[i]
            bullet.x += bulletSpeed -- Move bullet to the right

            -- Remove bullet if it goes off-screen
            if bullet.x > 400 then
                table.remove(bullets, i)
            else
                gfx.fillCircleAtPoint(bullet.x, bullet.y, 3) -- Draw bullet
            end
        end

        -- Draw the player
        if playerImage ~= nil then
            playerImage:draw(playerX, playerY)
        end

        -- Update enemy positions
        for enemyIndex = #enemies, 1, -1 do
            local enemy = enemies[enemyIndex]
            enemy.x -= enemySpeed
            if enemyImage ~= nil and enemy.x < -enemyImage.width then
                enemy.x = 400 + math.random(0, 200)
                enemy.y = math.random(0, 240)
            end
            if enemyImage ~= nil then
                enemyImage:draw(enemy.x, enemy.y)
            end

            -- Check for collision with bullets
            for bulletIndex = #bullets, 1, -1 do
                local bullet = bullets[bulletIndex]
                if math.abs(bullet.x - enemy.x) < enemyImage.width / 2 and math.abs(bullet.y - enemy.y) < enemyImage.height / 2 then
                    -- Remove the bullet and the enemy
                    table.remove(bullets, bulletIndex)
                    table.remove(enemies, enemyIndex)

                    -- Increment the score
                    score += 1
                    break
                end
            end

            -- Check for collision with player
            if enemyImage ~= nil and math.abs(playerX - enemy.x) < enemyImage.width and math.abs(playerY - enemy.y) < enemyImage.height then
                gameState = "collision"
            end
        end

        -- Display the score
        gfx.drawText("Score: " .. score, 300, 10)
    elseif gameState == "collision" then
        -- Display player and enemy sprites
        if playerImage ~= nil then
            playerImage:draw(60, 100) -- Left center
        end
        if enemyImage ~= nil then
            enemyImage:draw(240, 100) -- Right center
        end
        
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
            
            -- Draw thicker border for the selected button
            if i == currentButtonIndex then
                gfx.setLineWidth(3)
                gfx.drawRoundRect(button.x - 2, button.y - 2, button.width + 4, button.height + 4, 5)
                gfx.setLineWidth(1)
            end
            
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
        
        -- Handle A button input for selection
        if pd.buttonJustPressed(pd.kButtonA) then
            playerChoice = currentButtonIndex
            enemyChoice = math.random(1, #buttons)
            gameState = "result"
        end
    elseif gameState == "result" then
        -- Determine the winner
        if playerChoice == enemyChoice then
            resultText = "It's a tie!"
            gameState = "collision"
        elseif (playerChoice == 1 and enemyChoice == 3) or (playerChoice == 2 and enemyChoice == 1) or (playerChoice == 3 and enemyChoice == 2) then
            resultText = "You win!"
            gameState = "game"
        else
            resultText = "You lose! Press A to retry"
            gameState = "retry"
        end
        
        -- Display result
        gfx.drawText(resultText, 100, 120)
    elseif gameState == "retry" then
        -- Display retry message
        gfx.drawText(resultText, 100, 120)
        
        -- Handle A button input to retry
        if pd.buttonJustPressed(pd.kButtonA) then
            initializeEnemies()
            gameState = "game"
        end
    elseif gameState == "end" then
        -- End screen update
        gfx.drawText("Thanks for playing!", 100, 120)
    end
end