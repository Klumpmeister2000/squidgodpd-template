import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd = playdate
local gfx = pd.graphics

-- Game state
local gameState = "title" -- Possible states: "title", "game", "collision", "result", "retry", "gameOver"

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

-- Enemies
local enemies = {}
local enemySpeed = 2
local numEnemies = 5
local enemyHealth = 3

-- Initialize enemies
local function initializeEnemies()
    enemies = {}
    for i = 1, numEnemies do
        table.insert(enemies, { x = 400 + math.random(0, 200), y = math.random(0, 240), health = 3 })
    end
end
initializeEnemies()

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

        playerImage:draw(playerX, playerY)
        
        for enemyIndex = #enemies, 1, -1 do
            local enemy = enemies[enemyIndex]
            enemy.x -= enemySpeed
            if enemy.x < -enemyImage.width then
                enemy.x = 400 + math.random(0, 200)
                enemy.y = math.random(0, 240)
            end
            enemyImage:draw(enemy.x, enemy.y)
            
            for bulletIndex = #bullets, 1, -1 do
                if math.abs(bullets[bulletIndex].x - enemy.x) < 32 and math.abs(bullets[bulletIndex].y - enemy.y) < 32 then
                    table.remove(bullets, bulletIndex)
                    table.remove(enemies, enemyIndex)
                    score += 1
                    table.insert(enemies, { x = 400 + math.random(0, 200), y = math.random(0, 240), health = 3 }) -- New enemy starts with 3 health
                    break
                end
            end
            
            if math.abs(playerX - enemy.x) < enemyImage.width and math.abs(playerY - enemy.y) < enemyImage.height then
                gameState = "collision"
            end
        end
        
        gfx.drawText("Score: " .. score, 300, 10)
    elseif gameState == "collision" then
        playerImage:draw(60, 100)
        enemyImage:draw(240, 100)

        local maxHearts = 3
        for i = 1, maxHearts do
            if i <= playerHealth then
                heartImage:drawScaled(20 + (i - 1) * 25, 20, 0.25)
            end
            if i <= enemyHealth then
                heartImage:drawScaled(240 + (i - 1) * 25, 20, 0.25)
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
        if playerChoice == enemyChoice then
            resultText = "Try again!"
        elseif (playerChoice == 1 and enemyChoice == 2) or (playerChoice == 2 and enemyChoice == 3) or (playerChoice == 3 and enemyChoice == 1) then
            resultText = "Nice hit!"
            enemyHealth -= 1
            -- Make enemy shake
            for i = 1, 5 do
                enemyImage:draw(240 + (i % 2 == 0 and 2 or -2), 100)
                pd.timer.performAfterDelay(50, function() end)
            end
        else
            resultText = "Ouch!"
            playerHealth -= 1
        end

        if enemyHealth <= 0 then
            resultText = "You defeated the enemy! Press A to continue"
            enemyHealth = 3 -- Reset health for new enemy
        elseif playerHealth <= 0 then
            resultText = "You were defeated! Press A to continue"
            gameState = "gameOver"
        end

        gfx.drawText(resultText, 100, 120)

        if pd.buttonJustPressed(pd.kButtonA) then
            if enemyHealth <= 0 then
                enemyHealth = 3
                gameState = "game" -- Return to shooter game
            elseif playerHealth <= 0 then
                gameState = "gameOver"
            else
                gameState = "collision" -- Continue battle
            end
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
