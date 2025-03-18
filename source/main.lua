import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd = playdate
local gfx = pd.graphics

-- Game state
local gameState = "title" -- Start with the title screen

-- Player variables
local playerX = 40 -- Initial X position of the player
local playerY = 120 -- Initial Y position of the player
local playerSpeed = 3 -- Speed at which the player moves
local playerImage = gfx.image.new("images/capybara") -- Load the player image

-- Define the titleUpdate function
function titleUpdate()
    gfx.clear() -- Clear the screen
    gfx.drawText("Welcome to the Game!", 100, 100) -- Title text
    gfx.drawText("Press A to Start", 100, 140) -- Instruction text
    gfx.drawText("Press B to Quit", 100, 160) -- Instruction text
end

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
        playerImage:draw(playerX, playerY) -- Draw the player image
        
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
        -- Display player and enemy sprites
        playerImage:draw(60, 100) -- Left center
        enemyImage:draw(240, 100) -- Right center
        
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
            initializeEnemies() -- Reinitialize enemies
            gameState = "game" -- Return to the game loop
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