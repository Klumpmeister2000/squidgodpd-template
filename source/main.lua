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
local playerHealth = 100

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

-- Load heart sprite
local heartImage = gfx.image.new("images/heart.png")
if not heartImage then
    error("Failed to load heart image: images/heart.png")
end

-- Enemies
local enemies = {}
local enemySpeed = 2
local numEnemies = 5
local enemyHealth = 100

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
    {x = 40, y = 200, width = 100, height = 30, selected = false, text = "Gun"},
    {x = 150, y = 200, width = 100, height = 30, selected = false, text = "Sword"},
    {x = 260, y = 200, width = 100, height = 30, selected = false, text = "Beam"}
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

        -- Loop the player back onto the screen
        if playerY < 0 then
            playerY = 240 -- Move to the bottom of the screen
        elseif playerY > 240 then
            playerY = 0 -- Move to the top of the screen
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
                -- Respawn enemy when it moves off-screen
                enemy.x = 400 + math.random(0, 200)
                enemy.y = math.random(0, 240)
            end
            if enemyImage ~= nil then
                enemyImage:draw(enemy.x, enemy.y)
            end

            -- Check for collision with bullets
            for bulletIndex = #bullets, 1, -1 do
                local bullet = bullets[bulletIndex]
                if math.abs(bullet.x - enemy.x) < 64 / 2 and math.abs(bullet.y - enemy.y) < 64 / 2 then
                    -- Remove the bullet and the enemy
                    table.remove(bullets, bulletIndex)
                    table.remove(enemies, enemyIndex)

                    -- Increment the score
                    score += 1

                    -- Respawn a new enemy
                    table.insert(enemies, {
                        x = 400 + math.random(0, 200),
                        y = math.random(0, 240)
                    })
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

        -- Display health bars as hearts
        for i = 1, playerHealth do
            heartImage:draw(20 + (i - 1) * 20, 20) -- Draw player hearts
        end
        for i = 1, enemyHealth do
            heartImage:draw(240 + (i - 1) * 20, 20) -- Draw enemy hearts
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
            resultText = "It's a tie! Press A to continue"
        elseif (playerChoice == 1 and enemyChoice == 2) or -- Gun beats Sword
               (playerChoice == 2 and enemyChoice == 3) or -- Sword beats Beam
               (playerChoice == 3 and enemyChoice == 1) then -- Beam beats Gun
            resultText = "You win! Press A to continue"
            enemyHealth -= 1 -- Decrease enemy health
        else
            resultText = "You lose! Press A to retry"
            playerHealth -= 1 -- Decrease player health
        end

        -- Check for victory or defeat
        if enemyHealth <= 0 then
            resultText = "You defeated the enemy! Press A to continue"
            gameState = "game" -- Return to the side-scroller game
            playerHealth = 3 -- Reset player health
            enemyHealth = 3 -- Reset enemy health
        elseif playerHealth <= 0 then
            resultText = "You were defeated! Press A to continue"
            gameState = "gameOver" -- Transition to the Game Over screen
        end

        -- Display result
        gfx.drawText(resultText, 100, 120)

        -- Wait for the player to press A to continue
        if pd.buttonJustPressed(pd.kButtonA) then
            if resultText == "You win! Press A to continue" or resultText == "It's a tie! Press A to continue" then
                gameState = "collision" -- Retry the collision screen
            elseif resultText == "You defeated the enemy! Press A to continue" then
                gameState = "game" -- Return to the side-scroller game
            elseif resultText == "You were defeated! Press A to continue" then
                gameState = "gameOver" -- Transition to the Game Over screen
            end
        end
    elseif gameState == "gameOver" then
        -- Display Game Over screen
        gfx.clear()
        gfx.drawText("Game Over", 150, 100)
        gfx.drawText("Press A to Restart", 120, 140)

        -- Handle A button input to restart the game
        if pd.buttonJustPressed(pd.kButtonA) then
            -- Reset game variables
            playerHealth = 3
            enemyHealth = 3
            score = 0
            initializeEnemies() -- Reinitialize enemies
            gameState = "title" -- Return to the title screen
        end
    end
end -- Close the pd.update function
