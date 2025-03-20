import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd = playdate
local gfx = pd.graphics

-- Game state
local gameState = "title" -- Possible states: "title", "game", "combat", "result", "retry", "gameOver"

-- Player 
local playerX = 40
local playerY = 120
local playerSpeed = 3
local playerHealth = 3

-- Score
local score = 0

-- Bullets
local bullets = {}
local bulletSpeed = 5

-- Load images
local playerImage = gfx.image.new("images/spaceman.png")
local enemyImage = gfx.image.new("images/spaceworm.png")
local heartImage = gfx.image.new("images/heart.png")
local healthboxImage = gfx.image.new("images/healthbox.png")
local healthbox = nil

local combatEnemy = { x = 240, y = 100, isShaking = false } -- New global combat enemy table

-- Enemies
local enemies = {}
local enemySpeed = 2
local numEnemies = 5
local enemyHealth = 3

-- Initialize enemies
local function initializeEnemies()
    enemies = {}
    for i = 1, numEnemies do
        table.insert(enemies, { x = 400 + math.random(0, 200), y = math.random(0, 240), health = 3, isShaking = false })
    end
end
initializeEnemies()

local healthboxSpawnTimer = playdate.timer.new(2000)  -- spawn every 2 seconds for testing
healthboxSpawnTimer.completionCallback = function(timer)
    if healthbox == nil then
        healthbox = { x = math.random(50, 350), y = math.random(20, 220) }
    end
    timer.duration = 2000  -- keep the interval at 2 seconds
    timer:reset()
end

-- Function to shake an enemy sprite with a callback when complete
local function shakeEnemy(enemy, duration, shakeRange, onComplete)
    local originalX, originalY = enemy.x, enemy.y
    local shakeTimer = playdate.timer.new(duration)
    
    shakeTimer.updateCallback = function(timer)
        enemy.x = originalX + math.random(-shakeRange, shakeRange)
        enemy.y = originalY + math.random(-shakeRange, shakeRange)
    end
    
    shakeTimer.completionCallback = function(timer)
        enemy.x = originalX
        enemy.y = originalY
        enemy.isShaking = false
        if onComplete then onComplete() end
    end
end

-- Buttons for battle scene
local buttons = {
    {x = 40, y = 200, width = 100, height = 30, text = "Gun"},
    {x = 150, y = 200, width = 100, height = 30, text = "Sword"},
    {x = 260, y = 200, width = 100, height = 30, text = "Beam"}
}

local currentButtonIndex = 1
local playerChoice = nil
local enemyChoice = nil
local resultText = ""
local resultTimer = nil
local resultDisplayed = false

function pd.update()
    gfx.clear()
    
    if gameState == "title" then
        gfx.drawText("Welcome to the Game!", 100, 100)
        gfx.drawText("Press A to Start", 100, 140)
        gfx.drawText("Press B to Quit", 100, 160)
        if pd.buttonJustPressed(pd.kButtonA) then
            gameState = "game"
        elseif pd.buttonJustPressed(pd.kButtonB) then
            gameState = "gameOver"
        end
    elseif gameState == "game" then
        if pd.buttonIsPressed(pd.kButtonUp) then playerY -= playerSpeed end
        if pd.buttonIsPressed(pd.kButtonDown) then playerY += playerSpeed end
        if playerY < 0 then playerY = 240 elseif playerY > 240 then playerY = 0 end

        if pd.buttonJustPressed(pd.kButtonA) then
            table.insert(bullets, {x = playerX + 20, y = playerY + 10})
        end

        for i = #bullets, 1, -1 do
            bullets[i].x += bulletSpeed
            if bullets[i].x > 400 then
                table.remove(bullets, i)
            else
                gfx.fillCircleAtPoint(bullets[i].x, bullets[i].y, 3)
            end
        end

        if playerImage then
            playerImage:draw(playerX, playerY)
        end
        
        local hitboxOffsetY = 20 -- Lower hitbox further
        for enemyIndex = #enemies, 1, -1 do
            local enemy = enemies[enemyIndex]
            if not enemy.isShaking then
                enemy.x -= enemySpeed
            end
            if enemy.x < -enemyImage.width then
                enemy.x = 400 + math.random(0, 200)
                enemy.y = math.random(0, 240)
            end
            enemyImage:draw(enemy.x, enemy.y)
            
            for bulletIndex = #bullets, 1, -1 do
                if math.abs(bullets[bulletIndex].x - enemy.x) < 32 and math.abs(bullets[bulletIndex].y - (enemy.y + hitboxOffsetY)) < 32 then
                    table.remove(bullets, bulletIndex)
                    table.remove(enemies, enemyIndex)
                    score = score + 1
                    table.insert(enemies, { x = 400 + math.random(0, 200), y = math.random(0, 240), health = 3, isShaking = false })
                    break
                end
            end
            
            if math.abs(playerX - enemy.x) < enemyImage.width and math.abs(playerY - (enemy.y + hitboxOffsetY)) < enemyImage.height then
                gameState = "combat"
            end
        end

        if healthbox then
            -- Move the healthbox left along with enemies
            healthbox.x = healthbox.x - enemySpeed
            
            -- If the healthbox moves off screen, remove it
            if healthbox.x < -healthboxImage.width then
                healthbox = nil
            else
                -- Draw the healthbox
                healthboxImage:draw(healthbox.x, healthbox.y)
                
                -- Debug: Draw text above the healthbox to indicate its presence
                gfx.drawText("HB", healthbox.x, healthbox.y - 10)
                
                -- Check collision with the player
                if math.abs(playerX - healthbox.x) < healthboxImage.width and math.abs(playerY - healthbox.y) < healthboxImage.height then
                    playerHealth = 3  -- Refresh player's health to full
                    healthbox = nil -- Remove the healthbox after pickup
                end
            end
        end
        
        -- Debug message for healthbox position
        if healthbox then
            gfx.drawText(string.format("Healthbox at (%.0f, %.0f)", healthbox.x, healthbox.y), 10, 220)
        end

        gfx.drawText("Score: " .. score, 300, 10)
    elseif gameState == "combat" then
        if playerImage then
            if playerImage then
                playerImage:draw(60, 100)
            end
        end
        if combatEnemy then
            if combatEnemy then
                if combatEnemy then
                    enemyImage:draw(combatEnemy.x, combatEnemy.y) -- Updated enemy drawing
                end
            end
        end

        local maxHearts = 3
        for i = 1, maxHearts do
            if i <= playerHealth then
                if heartImage then
                    if heartImage then
                        if heartImage then
                            heartImage:drawScaled(20 + (i - 1) * 32, 20, 0.1)
                        end
                    end
                end
            end
            if i <= enemyHealth then
                if heartImage then
                    heartImage:drawScaled(240 + (i - 1) * 32, 20, 0.1)
                end
            end
        end

        for i, button in ipairs(buttons) do
            gfx.drawRoundRect(button.x, button.y, button.width, button.height, 5)
            if i == currentButtonIndex then
                gfx.drawRoundRect(button.x - 2, button.y - 2, button.width + 4, button.height + 4, 5)
            end
            gfx.drawText(button.text, button.x + 25, button.y + 10)
        end

        if pd.buttonJustPressed(pd.kButtonLeft) then
            currentButtonIndex = math.max(1, currentButtonIndex - 1)
        elseif pd.buttonJustPressed(pd.kButtonRight) then
            currentButtonIndex = math.min(#buttons, currentButtonIndex + 1)
        elseif pd.buttonJustPressed(pd.kButtonA) then
            playerChoice = currentButtonIndex
            enemyChoice = math.random(1, #buttons)
            gameState = "result"
        end
    elseif gameState == "result" then
        playerImage:draw(60, 100)
        enemyImage:draw(combatEnemy.x, combatEnemy.y) -- Updated enemy drawing

        local maxHearts = 3
        for i = 1, maxHearts do
            if i <= playerHealth then
                heartImage:drawScaled(20 + (i - 1) * 32, 20, 0.1)
            end
            if i <= enemyHealth then
                heartImage:drawScaled(240 + (i - 1) * 32, 20, 0.1)
            end
        end

        gfx.drawText(resultText, 150, 80) -- Display between player and enemy

        if not resultDisplayed then
            resultDisplayed = true
            if playerChoice == enemyChoice then
                resultText = "Try again!"
            elseif (playerChoice == 1 and enemyChoice == 2) or (playerChoice == 2 and enemyChoice == 3) or (playerChoice == 3 and enemyChoice == 1) then
                enemyHealth -= 1
                if enemyHealth > 0 then
                    resultText = "Nice hit!"
                    combatEnemy.isShaking = true
                    shakeEnemy(combatEnemy, 500, 5, function() end) -- Added shake animation for a "Nice hit!"
                else
                    resultText = "You defeated the enemy!"
                end
            else
                resultText = "Ouch!"
                playerHealth -= 1
            end
        end

        if pd.buttonJustPressed(pd.kButtonA) then
            resultText = "" -- Reset text
            resultDisplayed = false -- Ensure text updates next round

            if enemyHealth > 0 and playerHealth > 0 then
                gameState = "combat" -- Resume combat round
            elseif enemyHealth <= 0 then
                gameState = "game" -- Return to main game loop
                enemyHealth = 3 -- Reset enemy health
                score += 1 -- Increment score for defeating an enemy
                initializeEnemies() -- Ensure new enemies spawn
            elseif playerHealth <= 0 then
                gameState = "gameOver"
            end
        end

        if playerHealth <= 0 then
            resultText = "You were defeated! Press A to continue"
            gameState = "gameOver"
        end
    elseif gameState == "gameOver" then
        gfx.clear()
        gfx.drawText("Game Over", 150, 100)
        gfx.drawText("Press A to Restart", 120, 140)
        if pd.buttonJustPressed(pd.kButtonA) then
            playerHealth, enemyHealth, score = 3, 3, 0
            initializeEnemies()
            gameState = "title"
        end
    end
end
