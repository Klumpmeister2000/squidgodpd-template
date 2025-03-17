local MenuScene = Noble.Scene.new("MenuScene")
local gfx = playdate.graphics

-- Menu items (buttons)
local menuItems = {"Start Game", "Options", "Exit"}
local selectedIndex = 1
local selectedItem = nil -- Stores which item is selected

function MenuScene.enter()
    print("Entered MenuScene")
end

function MenuScene.update()
    Noble.Scene.update()
    
    -- Clear the screen
    gfx.clear()
    
    -- Draw menu items horizontally
    for i, item in ipairs(menuItems) do
        local x = 60 + (i - 1) * 100  -- Positions items evenly spaced
        local y = 100  -- Fixed Y position

        -- Change appearance based on selection
        if selectedItem == i then
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite) -- Highlight selected item
        elseif selectedIndex == i then
            gfx.setImageDrawMode(gfx.kDrawModeInverted) -- Hovered item
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
        
        -- Draw the menu text
        gfx.drawTextAligned(item, x, y, kTextAlignment.center)
    end
end

-- Handle button input
function MenuScene.buttonDown(button)
    if button == playdate.kButtonLeft then
        selectedIndex = math.max(1, selectedIndex - 1) -- Move left
    elseif button == playdate.kButtonRight then
        selectedIndex = math.min(#menuItems, selectedIndex + 1) -- Move right
    elseif button == playdate.kButtonA then
        selectedItem = selectedIndex -- Select the item
        print("Selected: " .. menuItems[selectedItem])
        if selectedItem == 1 then
            Noble.Scene.push(GameScene) -- Load game scene if "Start Game" is selected
        elseif selectedItem == 2 then
            print("Options menu (to be implemented)")
        elseif selectedItem == 3 then
            print("Exiting game...")
            playdate.exit() -- Exits Playdate simulator
        end
    elseif button == playdate.kButtonB then
        selectedItem = nil -- Deselect
        print("Deselected")
    end
end

return MenuScene